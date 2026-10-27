// Inputs a pull request could add to make GlobalLingo crash, hang, run out of memory or write to
// the terminal: deep nesting, huge counts, crafted globs and source files, odd numbers.
import { mkdirSync, readFileSync, symlinkSync } from 'node:fs';
import { join } from 'node:path';
import { describe, expect, it } from 'vitest';
import { checkSource, codeContext } from '../../src/code/check-code.ts';
import { checkCatalog } from '../../src/rules/catalog-checks.ts';
import { readJsonCatalog } from '../../src/catalogs/json-catalog.ts';
import { globMatcher, MAX_DEPTH } from '../../src/project/files.ts';
import { render } from '../../src/report/index.ts';
import { readBaseline } from '../../src/baseline.ts';
import { run } from '../../src/cli/run.ts';
import { scan } from '../../src/scan.ts';
import { tree } from '../helpers/tree.ts';

const elapsed = (work: () => void) => {
  const start = performance.now();
  work();
  return performance.now() - start;
};

describe('hostile catalogs', () => {
  it('reports a JSON file nested 100,000 levels deep as invalid instead of overflowing the stack', async () => {
    const deep = `${'{"a":'.repeat(100_000)}"x"${'}'.repeat(100_000)}`;
    const report = await scan(tree({ 'locales/en.json': '{"a": "A"}', 'locales/de.json': deep }));
    expect(report.findings.map((finding) => finding.rule)).toContain('FMT003');
    expect(report.findings.find((finding) => finding.rule === 'FMT003')?.message).toMatch(
      /Nested deeper than 128 levels/,
    );
  });

  it('caps the number of findings a catalog can produce', () => {
    const keys = Object.fromEntries(Array.from({ length: 2000 }, (_, i) => [`k${i}`, 'v']));
    const files = [{ locale: 'en', file: 'l/en.json', text: JSON.stringify(keys) }];
    for (let i = 0; i < 50; i += 1)
      files.push({
        locale: `de-${String(i).padStart(2, '0')}x`.slice(0, 8),
        file: `l/${i}.json`,
        text: '{}',
      });
    const catalog = readJsonCatalog('l/*.json', 'l', 'en', 'i18next', files);
    const result = checkCatalog(catalog, { ignoreKey: () => false, limit: 500 });
    expect(result.drafts).toHaveLength(500);
    expect(result.truncated).toBe(true);
  });

  it('keeps going below the folder depth limit with a note', async () => {
    const root = tree({ 'locales/en.json': '{"a": "A"}', 'locales/de.json': '{"a": "B"}' });
    let path = root;
    for (let i = 0; i < MAX_DEPTH + 3; i += 1) path = join(path, 'd');
    mkdirSync(path, { recursive: true });
    const report = await scan(root);
    expect(report.notes.some((note) => note.includes(`deeper than ${MAX_DEPTH} folders`))).toBe(
      true,
    );
  });

  it('never writes terminal escapes from keys, values or file names', async () => {
    const root = tree({
      'locales/en.json': JSON.stringify({ 'k\u001b[2Jx': 'v', title: 'T' }),
      'locales/de.json': JSON.stringify({ title: '\u202Eevil\u009B31m' }),
      'src/App.tsx': '<Text>\u001b]0;pwned\u0007 hello world</Text>',
    });
    const report = await scan(root);
    for (const format of ['tty', 'markdown', 'github', 'json', 'sarif'] as const) {
      // biome-ignore lint/suspicious/noControlCharactersInRegex: finding control characters is the point.
      expect(render(report, format), format).not.toMatch(/[\u001b\u0007\u009B\u202E]/);
    }
  });
});

describe('settings files that point elsewhere', () => {
  const secret = 'AKIA-SECRET-VALUE-1234';
  const project = () => tree({ 'locales/en.json': '{"a": "A"}', 'locales/de.json': '{"a": "B"}' });

  it('refuses a configuration or baseline that is a symbolic link, without reading it', async () => {
    const outside = tree({ 'secrets.env': `TOKEN=${secret}\n` });
    const root = project();
    symlinkSync(join(outside, 'secrets.env'), join(root, '.globallingo.json'));
    symlinkSync(join(outside, 'secrets.env'), join(root, 'baseline.json'));
    const config = await scan(root).catch((error: Error) => error.message);
    expect(config).toMatch(/\.globallingo\.json: not a regular file$/);
    const baseline = await readBaseline(join(root, 'baseline.json')).catch(
      (error: Error) => error.message,
    );
    expect(baseline).toMatch(/baseline\.json: not a regular file$/);
  });

  it('does not write a report or baseline through a symbolic link', async () => {
    const outside = tree({ 'important.txt': 'keep me' });
    const root = project();
    symlinkSync(join(outside, 'important.txt'), join(root, 'report.md'));
    symlinkSync(join(outside, 'important.txt'), join(root, 'baseline.json'));
    const io = { cwd: root, env: {}, stdout() {}, stderr() {}, stdoutIsTty: false };
    expect(await run(['--format', 'markdown', '--output', 'report.md'], io)).toBe(2);
    expect(await run(['--write-baseline', 'baseline.json'], io)).toBe(2);
    expect(readFileSync(join(outside, 'important.txt'), 'utf8')).toBe('keep me');
  });

  it('names only the line of a JSON error, never the text', async () => {
    const root = tree({
      'locales/en.json': '{}',
      'locales/de.json': '{}',
      '.globallingo.json': `{\n"a": 1,\n${secret}\n}`,
    });
    const message = await scan(root).catch((error: Error) => error.message);
    expect(message).toMatch(/not valid JSON \(line 3\)$/);
    expect(message).not.toContain('SECRET');
    const baseline = tree({ 'b.json': `[${secret}]` });
    const baselineMessage = await readBaseline(join(baseline, 'b.json')).catch(
      (error: Error) => error.message,
    );
    expect(baselineMessage).not.toContain('SECRET');
  });
});

describe('crafted patterns and source files', () => {
  it('matches a pathological glob against a long path in linear time', () => {
    const match = globMatcher(['**/**/**/**/**/**/**/**/a*a*a*a*a*a*a*a*a*a*b']);
    const path = `${'a/'.repeat(200)}${'a'.repeat(2000)}`;
    expect(elapsed(() => expect(match(path)).toBe(false))).toBeLessThan(2000);
  });

  const size = 2 * 1024 * 1024;
  const fill = (unit: string) => unit.repeat(Math.floor(size / unit.length));
  it.each([
    ['a.tsx', fill('t(')],
    ['a.tsx', fill('a.a.')],
    ['a.tsx', fill('<Trans ')],
    ['a.tsx', fill('<FormattedMessage ')],
    ['a.tsx', `<Text>${'a'.repeat(size)}`],
    ['a.tsx', fill('<Text>a ')],
    ['a.tsx', fill('formatMessage({ id: ')],
    ['a.tsx', fill("Alert.alert('")],
    ['a.tsx', fill('/ ')],
    ['a.tsx', fill('`${')],
    ['a.swift', fill('NSLocalizedString(')],
    ['a.swift', `UIAlertController(${'a'.repeat(size)}`],
    ['a.swift', fill('.text = "\\')],
    ['a.swift', fill('/*')],
    ['a.swift', fill('"""')],
    ['a.m', fill('NSLocalizedString(@"%')],
    ['a.dart', fill("hintText: '")],
    ['a.dart', fill('l10n.a.')],
    ['a.dart', fill("Text('")],
  ])('reads a crafted 2 MB %s in linear time', (path, text) => {
    const context = codeContext([]);
    context.shipsTurkic = true;
    expect(elapsed(() => checkSource({ path, text }, context))).toBeLessThan(3000);
  });
});
