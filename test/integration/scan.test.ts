import { symlinkSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { describe, expect, it } from 'vitest';
import { applyBaseline, createBaseline } from '../../src/baseline.ts';
import { readFileSync } from 'node:fs';
import { CONFIG_FIELDS, ConfigError, validateConfig } from '../../src/config.ts';
import { RULE_IDS } from '../../src/rules/registry.ts';
import { isLocaleName, jsonGroups } from '../../src/project/discover.ts';
import { globMatcher, MAX_CATALOG_BYTES } from '../../src/project/files.ts';
import {
  readFlutterSettings,
  syntaxFromContent,
  syntaxFromPackageJson,
} from '../../src/project/settings.ts';
import { NothingToCheckError, scan } from '../../src/scan.ts';
import { tree, unit, xcstrings } from '../helpers/tree.ts';

const rules = (report: Awaited<ReturnType<typeof scan>>) =>
  report.findings.map(
    (finding) =>
      `${finding.rule} ${finding.file}${finding.key ? ` ${finding.key}` : ''}${finding.locale ? ` ${finding.locale}` : ''}`,
  );

describe('finding catalogs', () => {
  it('reads String Catalogs, strings tables, ARB files and JSON locales in one project', async () => {
    const root = tree({
      'ios/App/Localizable.xcstrings': xcstrings({
        Hello: { localizations: { de: unit('Hallo') } },
      }),
      'ios/App/en.lproj/InfoPlist.strings': '"NSCameraUsageDescription" = "Scan books";',
      'ios/App/de.lproj/InfoPlist.strings': '"NSCameraUsageDescription" = "Bücher scannen";',
      'flutter/l10n.yaml': 'arb-dir: lib/i18n\ntemplate-arb-file: intl_en.arb\noutput-class: S\n',
      'flutter/lib/i18n/intl_en.arb': '{"title": "Title"}',
      'flutter/lib/i18n/intl_pt_BR.arb': '{"title": "Título"}',
      'web/package.json': JSON.stringify({ dependencies: { 'react-intl': '7.0.0' } }),
      'web/src/locales/en.json': '{"a": "Hi {name}"}',
      'web/src/locales/fr.json': '{"a": "Salut {name}"}',
    });
    const report = await scan(root);
    expect(
      report.catalogs.map((catalog) => [
        catalog.id,
        catalog.format,
        catalog.syntax,
        catalog.sourceLocale,
        catalog.locales,
      ]),
    ).toEqual([
      ['ios/App/Localizable.xcstrings', 'xcstrings', 'printf', 'en', ['en', 'de']],
      ['ios/App/*.lproj/InfoPlist', 'strings', 'printf', 'en', ['en', 'de']],
      ['flutter/lib/i18n/*.arb', 'arb', 'icu', 'en', ['en', 'pt_BR']],
      ['web/src/locales/*.json', 'json', 'icu', 'en', ['en', 'fr']],
    ]);
    expect(report.findings).toEqual([]);
    expect(report.ecosystems).toEqual(['apple', 'flutter', 'js']);
  });

  it('uses the development region of the Xcode project as the source of strings tables', async () => {
    const root = tree({
      'App.xcodeproj/project.pbxproj': '{ objects = { P = { developmentRegion = de; }; }; }',
      'App/de.lproj/Localizable.strings': '"a" = "A";\n"b" = "B";',
      'App/en.lproj/Localizable.strings': '"a" = "A";',
    });
    const report = await scan(root);
    expect(report.catalogs[0]?.sourceLocale).toBe('de');
    expect(rules(report)).toEqual(['MIS001 App/en.lproj/Localizable.strings b en']);
  });

  it('groups JSON files by folder and namespace, and only in locale folders or pairs', () => {
    const groups = jsonGroups(
      [
        'locales/en/common.json',
        'locales/de/common.json',
        'locales/en/home.json',
        'i18n/en.json',
        'config/en.json',
        'data/fr.json',
        'data/de.json',
        'tsconfig.json',
        'ios/Pods/x/en.json',
      ],
      [],
    );
    expect(
      groups.map((group) => [
        group.folder,
        group.namespace,
        group.files.map((file) => file.locale),
      ]),
    ).toEqual([
      ['data', 'data', ['fr', 'de']],
      ['i18n', 'i18n', ['en']],
      ['locales', 'common', ['en', 'de']],
      ['locales', 'home', ['en']],
    ]);
    expect(isLocaleName('pt_BR')).toBe(true);
    expect(isLocaleName('zh-Hant')).toBe(true);
    expect(isLocaleName('app')).toBe(false);
    expect(isLocaleName('package')).toBe(false);
  });

  it('reads the placeholder syntax from package.json or the files, and Flutter settings with defaults', () => {
    expect(syntaxFromPackageJson('{"dependencies": {"react-i18next": "1"}}')).toBe('i18next');
    expect(syntaxFromPackageJson('{"dependencies": {"i18next": "1", "i18next-icu": "1"}}')).toBe(
      'icu',
    );
    expect(syntaxFromPackageJson('{"dependencies": {"i18n-js": "4"}}')).toBe('i18n-js');
    expect(syntaxFromPackageJson('not json')).toBeUndefined();
    expect(syntaxFromContent(['{"a": "%{n} items"}'])).toBe('i18n-js');
    expect(syntaxFromContent(['{"a": "{{n}} items"}'])).toBe('i18next');
    expect(syntaxFromContent(['{"a": "{n} items"}'])).toBe('icu');
    expect(readFlutterSettings('# comment\nuse-escaping: true # quoted text\n', 'app')).toEqual({
      arbDir: 'app/lib/l10n',
      templateArbFile: 'app_en.arb',
      outputClass: 'AppLocalizations',
      useEscaping: true,
    });
  });

  it('needs a name inside the braces, and reads l10n.yaml lines as gen_l10n does', () => {
    expect(syntaxFromContent(['%{} {{}} {n}'])).toBe('icu');
    expect(syntaxFromContent(['{{a} b}} {{}'])).toBe('icu');
    expect(syntaxFromContent(['{{{a}}'])).toBe('i18next');
    expect(syntaxFromContent(['%{%{}'])).toBe('i18n-js');
    expect(syntaxFromContent(['{"a": "%{n"}', '{"b": "}"}'])).toBe('i18n-js');
    const yaml = [
      'arb-dir :  "lib/i18n"   # where the files are',
      'template-arb-file: app_tr.arb\t',
      "output-class:'Strings'",
      'not a key: x',
      '  nested: y',
      'use-escaping: true#not a comment',
    ].join('\n');
    expect(readFlutterSettings(yaml, '')).toEqual({
      arbDir: 'lib/i18n',
      templateArbFile: 'app_tr.arb',
      outputClass: 'Strings',
      useEscaping: false,
    });
  });

  it('fails with a clear error when there is nothing to check', async () => {
    await expect(scan(tree({ 'README.md': '# app' }))).rejects.toThrow(NothingToCheckError);
    await expect(scan(join(tree({}), 'missing'))).rejects.toThrow(/is not a folder/);
  });
});

describe('limits', () => {
  it('does not follow symbolic links and skips dependency folders', async () => {
    const root = tree({
      'app/locales/en.json': '{"a": "A"}',
      'app/locales/de.json': '{"a": "A2"}',
      'node_modules/lib/locales/en.json': '{"x": "X"}',
      'node_modules/lib/locales/de.json': '{}',
    });
    symlinkSync(join(root, 'app'), join(root, 'loop'));
    symlinkSync(root, join(root, 'app', 'self'));
    const report = await scan(root);
    expect(report.catalogs.map((catalog) => catalog.id)).toEqual(['app/locales/*.json']);
  });

  it('does not read a catalog larger than the limit', async () => {
    const root = tree({ 'locales/en.json': '{"a": "A"}', 'locales/de.json': '{"a": "A2"}' });
    writeFileSync(join(root, 'locales/de.json'), `{"a": "${'x'.repeat(MAX_CATALOG_BYTES)}"}`);
    const report = await scan(root);
    expect(report.findings.map((finding) => [finding.rule, finding.message])).toEqual([
      ['FMT003', 'locales/de.json could not be read: larger than 16 MB; not read'],
      ['MIS001', '"a" has no German (de) translation'],
    ]);
  });
});

describe('configuration', () => {
  const project = {
    'locales/en.json': '{"a": "A", "debug": {"x": "X"}, "b": "Same text"}',
    'locales/de.json': '{"a": "A2", "b": "Same text"}',
    'src/App.tsx': "<Text>Hard coded text</Text>\nt('missing.key')\nt('a')\nt('b')",
    'src/__tests__/App.test.tsx': '<Text>Test text</Text>',
    'vendor-ui/Thing.tsx': '<Text>Vendored text</Text>',
  };

  it('applies rule settings, ignored keys and paths, and locales', async () => {
    const root = tree({
      ...project,
      '.globallingo.json': JSON.stringify({
        ignore: { keys: ['debug.*'], paths: ['vendor-ui/**'] },
        rules: { HCS001: 'error', MIS004: 'off' },
      }),
    });
    const report = await scan(root);
    expect(
      report.findings.map((finding) => `${finding.rule}:${finding.severity} ${finding.file}`),
    ).toEqual(['HCS001:error src/App.tsx', 'KEY001:error src/App.tsx']);
    const defaults = await scan(tree(project));
    expect(
      defaults.findings.map((finding) => `${finding.rule}:${finding.severity} ${finding.file}`),
    ).toEqual([
      'MIS001:error locales/de.json',
      'MIS004:info locales/de.json',
      'KEY003:info locales/en.json',
      'HCS001:warning src/App.tsx',
      'KEY001:error src/App.tsx',
      'HCS001:warning vendor-ui/Thing.tsx',
    ]);
  });

  it('can skip the source code', async () => {
    const report = await scan(tree(project), { code: false });
    expect(report.sourceFiles).toBe(0);
    expect(report.findings.every((finding) => finding.file.startsWith('locales/'))).toBe(true);
  });

  it('rejects unknown fields, rules and wrong types', () => {
    expect(() => validateConfig({ rule: {} })).toThrow(/unknown field "rule"/);
    expect(() => validateConfig({ rules: { XYZ001: 'off' } })).toThrow(/unknown rule "XYZ001"/);
    expect(() => validateConfig({ rules: { MIS001: 'fatal' } })).toThrow(
      /must be one of error, warning, info, off/,
    );
    expect(() => validateConfig({ locales: 'de' })).toThrow(/list of non-empty strings/);
    expect(() => validateConfig({ ignore: { files: [] } })).toThrow(/ignore.files/);
    expect(() => validateConfig({ catalogDirs: ['../outside'] })).toThrow(
      /inside the checked folder/,
    );
    expect(() => validateConfig({ jsonSyntax: 'yaml' })).toThrow(ConfigError);
    expect(() => validateConfig([])).toThrow(/JSON object/);
    expect(
      validateConfig({ $schema: './schema/config.schema.json', sourceLanguage: 'en' }),
    ).toEqual({ sourceLanguage: 'en' });
  });

  it('has a JSON schema with the same fields and rules as the validator', () => {
    const schema = JSON.parse(
      readFileSync(new URL('../../schema/config.schema.json', import.meta.url), 'utf8'),
    );
    expect(Object.keys(schema.properties).sort()).toEqual([...CONFIG_FIELDS].sort());
    expect(Object.keys(schema.properties.rules.properties)).toEqual(RULE_IDS);
  });

  it('reports a broken configuration file', async () => {
    const root = tree({ ...project, '.globallingo.json': '{ not json' });
    await expect(scan(root)).rejects.toThrow(/not valid JSON/);
  });

  it('matches globs against paths from the root', () => {
    const match = globMatcher(['**/Tests/**', 'build.*', 'docs']);
    expect(
      [
        'App/Tests/a.swift',
        'Tests/b.swift',
        'build.json',
        'docs/x.md',
        'App/TestsX/a.swift',
        'a/build.json',
      ].map(match),
    ).toEqual([true, true, true, true, false, false]);
  });
});

describe('baseline', () => {
  it('marks accepted findings, keeps counting new ones, and survives moved lines', async () => {
    const files = { 'locales/en.json': '{"a": "A", "b": "B"}', 'locales/de.json': '{}' };
    const before = await scan(tree(files));
    const baseline = createBaseline(before.findings);
    const moved = await scan(
      tree({ ...files, 'locales/en.json': '{\n\n"a": "A",\n"b": "B",\n"c": "C"}' }),
      { baseline },
    );
    expect(
      moved.findings.filter((finding) => finding.baselined).map((finding) => finding.key),
    ).toEqual(['a', 'b']);
    expect(
      moved.findings.filter((finding) => !finding.baselined).map((finding) => finding.key),
    ).toEqual(['c']);
    expect(moved.summary).toEqual({ error: 1, warning: 0, info: 0, baselined: 2 });
  });

  it('accepts as many identical findings as the baseline lists', () => {
    const finding = { fingerprint: 'f'.repeat(20) } as Parameters<typeof applyBaseline>[0][number];
    const findings = [{ ...finding }, { ...finding }];
    applyBaseline(findings, {
      schemaVersion: 1,
      tool: 'globallingo',
      fingerprints: ['f'.repeat(20)],
    });
    expect(findings.map((item) => item.baselined ?? false)).toEqual([true, false]);
  });
});
