import { describe, expect, it } from 'vitest';
import { readAppleTable } from '../../src/catalogs/apple-tables.ts';
import { readArb } from '../../src/catalogs/arb.ts';
import { readJsonCatalog } from '../../src/catalogs/json-catalog.ts';
import { collectUsage, emptyUsage, unusedKeys } from '../../src/code/usage.ts';

const unused = (
  catalogs: Parameters<typeof unusedKeys>[0],
  sources: [string, 'swift' | 'dart' | 'js' | 'objc'][],
) => {
  const usage = emptyUsage();
  for (const [text, language] of sources) collectUsage(text, language, usage);
  return unusedKeys(catalogs, usage, (key) => key === 'ignored').map(
    (draft) => `${draft.key}:${draft.line}`,
  );
};

describe('KEY003', () => {
  const json = readJsonCatalog('l/*.json', 'l', 'en', 'i18next', [
    {
      locale: 'en',
      file: 'l/en.json',
      text: JSON.stringify(
        {
          home: { title: 'Home', unused: 'Old' },
          errors: { network: 'Offline', timeout: 'Slow' },
          status: { idle: 'Idle' },
          help: 'See $t(home.footer)',
          place_ordinal_one: '{{count}}st',
          place_ordinal_other: '{{count}}th',
          ignored: 'x',
          constant: 'Kept in a constant',
        },
        null,
        1,
      ),
    },
    { locale: 'de', file: 'l/de.json', text: '{"home": {"footer": "Fuß"}}' },
  ]);

  it('counts literals, template prefixes, concatenation prefixes, nesting and ordinals as uses', () => {
    const code = [
      "t('home.title')",
      "t('help')",
      // biome-ignore lint/suspicious/noTemplateCurlyInString: source code under test.
      't(`errors.${code}`)',
      "t('status.' + state)",
      "t('place', { count, ordinal: true })",
      "const KEY = 'constant';",
      "// t('home.unused') in a comment does not count",
    ].join('\n');
    expect(unused([json], [[code, 'js']])).toEqual(['home.unused:4']);
  });

  it('does nothing for an ecosystem without source files', () => {
    expect(unused([json], [['let a = 1', 'swift']])).toEqual([]);
  });

  it('counts Dart member access for ARB messages', () => {
    const arb = readArb(
      'l/*.arb',
      'app',
      { sourceLocale: 'en', useEscaping: false, outputClass: 'AppLocalizations' },
      [
        {
          locale: 'en',
          file: 'l/app_en.arb',
          text: '{\n "title": "T",\n "greeting": "Hi {name}",\n "@greeting": {},\n "orphan": "O"\n}',
        },
      ],
    );
    expect(
      unused(
        [arb],
        [["Text(l10n.title)\nText(AppLocalizations.of(context)!.greeting('Ada'))", 'dart']],
      ),
    ).toEqual(['orphan:5']);
  });

  it('counts Swift literals and interpolation prefixes, and leaves Info.plist tables alone', () => {
    const table = readAppleTable('*.lproj/Localizable', 'Localizable', 'en', [
      {
        locale: 'en',
        file: 'en.lproj/Localizable.strings',
        kind: 'strings',
        text: '"a" = "A";\n"status.idle" = "Idle";\n"b" = "B";',
      },
    ]);
    const plist = readAppleTable('*.lproj/InfoPlist', 'InfoPlist', 'en', [
      {
        locale: 'en',
        file: 'en.lproj/InfoPlist.strings',
        kind: 'strings',
        text: '"NSCameraUsageDescription" = "Scan";',
      },
    ]);
    const swift =
      'NSLocalizedString("a", comment: "")\nNSLocalizedString("status.\\(name)", comment: "")';
    expect(unused([table, plist], [[swift, 'swift']])).toEqual(['b:3']);
  });
});
