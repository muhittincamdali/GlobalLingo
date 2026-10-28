// Crafted inputs a pull request could add to make a run take hours: each case grows 16 times, to
// 2 MB, and must take about 16 times as long, not 256. See test/helpers/growth.ts for why a ratio.
import { describe, expect, it } from 'vitest';
import { readAppleTable } from '../../src/catalogs/apple-tables.ts';
import { readArb } from '../../src/catalogs/arb.ts';
import { readJsonCatalog } from '../../src/catalogs/json-catalog.ts';
import { readXcstrings } from '../../src/catalogs/xcstrings.ts';
import { checkSource, codeContext } from '../../src/code/check-code.ts';
import { collectUsage, emptyUsage, unusedKeys } from '../../src/code/usage.ts';
import { parseIcu } from '../../src/messages/icu.ts';
import {
  i18nextNesting,
  i18nextPlaceholders,
  i18nJsPlaceholders,
} from '../../src/messages/interpolation.ts';
import { parsePrintf } from '../../src/messages/printf.ts';
import type { Catalog } from '../../src/model.ts';
import { parseJson } from '../../src/parse/json.ts';
import { parsePlist } from '../../src/parse/plist.ts';
import { parseStrings } from '../../src/parse/strings.ts';
import { globMatcher, MAX_GLOB_CHARACTERS, MAX_GLOB_LENGTH } from '../../src/project/glob.ts';
import { readFlutterSettings, syntaxFromContent } from '../../src/project/settings.ts';
import { checkCatalog } from '../../src/rules/catalog-checks.ts';
import { BASE_SIZE, fill, growth, MAX_GROWTH } from '../helpers/growth.ts';

/** Whole catalogs with their checks are slower per byte; they grow from 32 KB to 512 KB. */
const CATALOG_SIZE = BASE_SIZE / 4;

const check = (catalog: Catalog) => checkCatalog(catalog, { ignoreKey: () => false });
const pair = <T>(value: T) => ({ en: value, de: value });

describe('source files', () => {
  it.each([
    ['a.tsx', 't('],
    ['a.tsx', 'a.a.'],
    ['a.tsx', '<Trans '],
    ['a.tsx', '<FormattedMessage '],
    ['a.tsx', '<Text>a '],
    ['a.tsx', 'formatMessage({ id: '],
    ['a.tsx', "Alert.alert('"],
    ['a.tsx', '/ '],
    ['a.tsx', '`${'],
    ['a.swift', 'NSLocalizedString('],
    ['a.swift', '.text = "\\'],
    ['a.swift', '/*'],
    ['a.swift', '"""'],
    ['a.m', 'NSLocalizedString(@"%'],
    ['a.dart', "hintText: '"],
    ['a.dart', 'l10n.a.'],
    ['a.dart', "Text('"],
  ])('reads %s filled with %j in linear time', (path, unit) => {
    const context = codeContext([]);
    context.shipsTurkic = true;
    expect(
      growth((size) => () => checkSource({ path, text: fill(unit, size) }, context)),
    ).toBeLessThan(MAX_GROWTH);
  });

  it.each([
    ['a.tsx', '<Text>'],
    ['a.swift', 'UIAlertController('],
  ])('reads %s with %j and one long word in linear time', (path, head) => {
    const context = codeContext([]);
    context.shipsTurkic = true;
    expect(
      growth((size) => () => checkSource({ path, text: `${head}${'a'.repeat(size)}` }, context)),
    ).toBeLessThan(MAX_GROWTH);
  });
});

describe('catalog readers', () => {
  it.each([
    ['escapes', (size: number) => `["${fill('\\n\\u0041', size)}"]`],
    ['numbers', (size: number) => `[${fill('1e5,', size)}0]`],
    ['an unterminated array', (size: number) => fill('[1,', size)],
  ])('reads JSON with %s in linear time', (_name, make) => {
    expect(growth((size) => () => parseJson(make(size)))).toBeLessThan(MAX_GROWTH);
  });

  it.each([
    ['escapes', (size: number) => `"a" = "${fill('\\U0041\\101\\n', size)}";`],
    ['comments', (size: number) => fill('/**/ // x\n', size)],
    ['unquoted pairs', (size: number) => fill('a.b = c/d;\n', size)],
    ['an unterminated string', (size: number) => `"a" = "${fill('\\"', size)}`],
  ])('reads a .strings file with %s in linear time', (_name, make) => {
    expect(growth((size) => () => parseStrings(make(size)))).toBeLessThan(MAX_GROWTH);
  });

  it.each([
    ['arguments', (size: number) => fill('{a} {b, number} ', size)],
    ['quotes', (size: number) => fill("'{' ''", size)],
    ['plural options', (size: number) => `{n, plural, ${fill('one {#} ', size)}other {x}}`],
    ['an unterminated style', (size: number) => `{a, number, ${fill('{', size)}`],
  ])('reads ICU with %s in linear time', (_name, make) => {
    expect(growth((size) => () => parseIcu(make(size), { apostropheQuoting: true }))).toBeLessThan(
      MAX_GROWTH,
    );
  });

  it.each([
    ['specifiers', (size: number) => fill('%1$@ %lld %.2f ', size)],
    ['digits', (size: number) => `%${'1'.repeat(size)}`],
    ['a reference', (size: number) => `%#@${'a'.repeat(size)}`],
    ['zeros', (size: number) => `%${'0'.repeat(size)}`],
    ['a position and zeros', (size: number) => `%1$${'0'.repeat(size)}`],
  ])('reads printf with %s in linear time', (_name, make) => {
    expect(growth((size) => () => parsePrintf(make(size)))).toBeLessThan(MAX_GROWTH);
  });

  it.each([
    ['i18n-js', (size: number) => i18nJsPlaceholders(`%{${' '.repeat(size)}`)],
    ['nesting', (size: number) => i18nextNesting(`$t(${' '.repeat(size)}`)],
    ['i18next', (size: number) => i18nextPlaceholders(`{{${' '.repeat(size)}`)],
    ['i18next formatted', (size: number) => i18nextPlaceholders(`{{a,${' '.repeat(size)}`)],
  ])('reads %s placeholders in linear time', (_name, read) => {
    expect(growth((size) => () => read(size))).toBeLessThan(MAX_GROWTH);
  });
});

describe('property lists', () => {
  it.each([
    ['a long tag', (size: number) => `<plist><dict${'a'.repeat(size)}/x>`],
    ['long tags', (size: number) => `<plist><array>${fill('<true    />', size)}</array></plist>`],
    [
      'CDATA sections',
      (size: number) => `<plist><string>${fill('<![CDATA[x]]>', size)}</string></plist>`,
    ],
    [
      'many strings',
      (size: number) => `<plist><array>${fill('<string>a</string>', size)}</array></plist>`,
    ],
    [
      'entities',
      (size: number) => `<plist><string>${fill('&amp;&#x131;&a', size)}</string></plist>`,
    ],
  ])('reads %s in linear time', (_name, make) => {
    expect(growth((size) => () => parsePlist(make(size)))).toBeLessThan(MAX_GROWTH);
  });
});

describe('catalogs and their checks', () => {
  const xcstrings = (strings: Record<string, unknown>) =>
    JSON.stringify({ sourceLanguage: 'en', strings, version: '1.1' });
  const unit = (value: string) => ({ stringUnit: { state: 'translated', value } });
  const many = <T>(size: number, per: number, make: (i: number) => [string, T]) =>
    Object.fromEntries(Array.from({ length: Math.floor(size / per) }, (_, i) => make(i)));

  it('reads a String Catalog with many keys in linear time', () => {
    const make = (size: number) => {
      const text = xcstrings(many(size, 60, (i) => [`k${i}`, { localizations: pair(unit('%@')) }]));
      return () => check(readXcstrings(text, 'L.xcstrings'));
    };
    expect(growth(make, CATALOG_SIZE)).toBeLessThan(MAX_GROWTH);
  });

  it('reads a String Catalog with many variants and substitutions in linear time', () => {
    const make = (size: number) => {
      const variants = { variations: { device: many(size / 2, 40, (i) => [`d${i}`, unit('%d')]) } };
      const subs = many(size / 2, 80, (i) => [
        `s${i}`,
        { argNum: 1, formatSpecifier: 'lld', variations: { plural: { other: unit('%arg') } } },
      ]);
      const text = xcstrings({
        a: { localizations: pair(variants) },
        b: { localizations: pair({ stringUnit: unit('x').stringUnit, substitutions: subs }) },
      });
      return () => check(readXcstrings(text, 'L.xcstrings'));
    };
    expect(growth(make, CATALOG_SIZE)).toBeLessThan(MAX_GROWTH);
  });

  it('compares many variants with the same text in linear time', () => {
    const make = (size: number) => {
      const variants = { variations: { device: many(size, 40, (i) => [`d${i}`, unit('Same')]) } };
      const catalog = readXcstrings(xcstrings({ k: { localizations: pair(variants) } }), 'L');
      return () => check(catalog);
    };
    // Only the checks are timed, on the full 2 MB: reading would hide how they grow.
    expect(growth(make)).toBeLessThan(MAX_GROWTH);
  });

  it('compares a variant with a long name in linear time', () => {
    const make = (size: number) => {
      const variant = (name: string) => ({ variations: { device: { [name]: unit('%d') } } });
      const text = xcstrings({
        k: { localizations: { en: variant('a'), de: variant(`${'b'.repeat(size)}.`) } },
      });
      return () => check(readXcstrings(text, 'L.xcstrings'));
    };
    expect(growth(make, CATALOG_SIZE)).toBeLessThan(MAX_GROWTH);
  });

  it('reads ARB files with many messages in linear time', () => {
    const make = (size: number) => {
      const text = JSON.stringify({
        '@@locale': 'en',
        ...many(size, 40, (i) => [`k${i}`, '{n, plural, one{# a} other{# b}}']),
      });
      const files = [
        { locale: 'en', file: 'app_en.arb', text },
        { locale: 'de', file: 'app_de.arb', text },
      ];
      const settings = { sourceLocale: 'en', useEscaping: true, outputClass: 'AppLocalizations' };
      return () => check(readArb('lib/l10n', 'app', settings, files));
    };
    expect(growth(make, CATALOG_SIZE)).toBeLessThan(MAX_GROWTH);
  });

  it('matches many plural arguments in another order in linear time', () => {
    const make = (size: number) => {
      const plurals = Array.from(
        { length: Math.floor(size / 24) },
        (_, i) => `{a${i}, plural, other{x}}`,
      );
      const files = [
        { locale: 'en', file: 'app_en.arb', text: JSON.stringify({ k: plurals.join(' ') }) },
        {
          locale: 'de',
          file: 'app_de.arb',
          text: JSON.stringify({ k: plurals.reverse().join(' ') }),
        },
      ];
      const settings = { sourceLocale: 'en', useEscaping: false, outputClass: 'AppLocalizations' };
      const catalog = readArb('lib/l10n', 'app', settings, files);
      return () => check(catalog);
    };
    expect(growth(make)).toBeLessThan(MAX_GROWTH);
  });

  it('reads .strings tables with many pairs in linear time', () => {
    const make = (size: number) => {
      const text = Object.keys(many(size, 24, (i) => [`k${i}`, 0]))
        .map((key) => `"${key}" = "%@ %d";`)
        .join('\n');
      const files = (['en', 'de'] as const).map((locale) => ({
        locale,
        file: `${locale}.lproj/Localizable.strings`,
        kind: 'strings' as const,
        text,
      }));
      return () => check(readAppleTable('Localizable', 'Localizable', 'en', files));
    };
    expect(growth(make, CATALOG_SIZE)).toBeLessThan(MAX_GROWTH);
  });

  it('reads .stringsdict tables with many plural forms in linear time', () => {
    const make = (size: number) => {
      const forms = fill('<key>few</key><string>%d x</string>', size);
      const text = `<plist><dict><key>k</key><dict><key>NSStringLocalizedFormatKey</key><string>%#@v@</string><key>v</key><dict><key>NSStringFormatSpecTypeKey</key><string>NSStringPluralRuleType</string><key>NSStringFormatValueTypeKey</key><string>d</string>${forms}<key>other</key><string>%d</string></dict></dict></dict></plist>`;
      const files = (['en', 'de'] as const).map((locale) => ({
        locale,
        file: `${locale}.lproj/Localizable.stringsdict`,
        kind: 'stringsdict' as const,
        text,
      }));
      return () => check(readAppleTable('Localizable', 'Localizable', 'en', files));
    };
    expect(growth(make, CATALOG_SIZE)).toBeLessThan(MAX_GROWTH);
  });

  it.each([
    [
      'plural keys',
      (size: number) => JSON.stringify(many(size, 30, (i) => [`k${i}_other`, '{{a}}'])),
    ],
    ['one long key', (size: number) => JSON.stringify({ [`${'_'.repeat(size)}x`]: 'v' })],
  ])('reads JSON translation files with %s in linear time', (_name, make) => {
    const read = (size: number) => {
      const text = make(size);
      const files = [
        { locale: 'en', file: 'locales/en.json', text },
        { locale: 'de', file: 'locales/de.json', text },
      ];
      return () => check(readJsonCatalog('locales', 'locales', 'en', 'i18next', files));
    };
    expect(growth(read, CATALOG_SIZE)).toBeLessThan(MAX_GROWTH);
  });
});

describe('project settings', () => {
  it.each([
    ['"%{"', (size: number) => syntaxFromContent([fill('%{', size)])],
    ['"{{a"', (size: number) => syntaxFromContent([fill('{{a', size)])],
    ['"{{a}"', (size: number) => syntaxFromContent([fill('{{a}', size)])],
  ])('detects the placeholder syntax of files full of %s in linear time', (_name, read) => {
    expect(growth((size) => () => read(size))).toBeLessThan(MAX_GROWTH);
  });

  it.each([
    ['spaces before a value', (size: number) => `a:${' '.repeat(size)}x`],
    ['spaces inside a value', (size: number) => `a: x${' '.repeat(size)}y`],
    ['spaces before a comment', (size: number) => `a: x${' '.repeat(size)}#`],
    ['a long key', (size: number) => `${'a'.repeat(size)} x`],
  ])('reads l10n.yaml with %s in linear time', (_name, make) => {
    expect(growth((size) => () => readFlutterSettings(make(size), ''))).toBeLessThan(MAX_GROWTH);
  });
});

describe('ignore globs and unused keys', () => {
  it('matches a pathological glob in linear time', () => {
    const match = globMatcher(['**/**/**/**/**/**/**/**/a*a*a*a*a*a*a*a*a*a*b']);
    expect(growth((size) => () => match('a'.repeat(size)))).toBeLessThan(MAX_GROWTH);
  });

  it('matches a glob against a key with many slashes in linear time', () => {
    const match = globMatcher(['b*', 'a/**/c']);
    expect(growth((size) => () => match(fill('a/', size)))).toBeLessThan(MAX_GROWTH);
  });

  // The slowest globs the configuration accepts: every `**a` keeps every position alive, and they
  // differ only at the end, so none is matched once for all.
  const slowGlobs = (count: number) =>
    Array.from(
      { length: count },
      (_, i) =>
        '**a'.repeat(MAX_GLOB_LENGTH).slice(0, MAX_GLOB_LENGTH - 6) +
        `Z${String(i).padStart(5, '0')}`,
    );
  const fullList = slowGlobs(Math.floor(MAX_GLOB_CHARACTERS / MAX_GLOB_LENGTH));

  it('matches a full ignore.keys list against many keys in linear time', () => {
    const match = globMatcher(fullList);
    const make = (size: number) => {
      const keys = Array.from(
        { length: Math.floor(size / 48) },
        (_, i) => `k${'a'.repeat(40)}${i}`,
      );
      return () => keys.filter(match);
    };
    expect(growth(make, CATALOG_SIZE)).toBeLessThan(MAX_GROWTH);
  });

  it('matches a full ignore.paths list against many paths in linear time', () => {
    const match = globMatcher(fullList);
    const make = (size: number) => {
      const paths = Array.from(
        { length: Math.floor(size / 100) },
        (_, i) => `${'a'.repeat(30)}/${'a'.repeat(30)}/${'a'.repeat(30)}/${i}`,
      );
      return () => paths.filter(match);
    };
    expect(growth(make, CATALOG_SIZE)).toBeLessThan(MAX_GROWTH);
  });

  it('takes time in step with the number of globs, up to the configuration limit', () => {
    expect(fullList.join('')).toHaveLength(MAX_GLOB_CHARACTERS);
    const keys = Array.from({ length: 4000 }, (_, i) => `k${'a'.repeat(40)}${i}`);
    // From one glob to the 16 that fill a list; the keys stay the same.
    const make = (count: number) => {
      const match = globMatcher(slowGlobs(count));
      return () => keys.filter(match);
    };
    expect(growth(make, 1)).toBeLessThan(MAX_GROWTH);
  });

  it('looks for many keys among many prefixes in the code in linear time', () => {
    const make = (size: number) => {
      const count = Math.floor(size / 12);
      const code = Array.from({ length: count }, (_, i) => `t("p${i}.");`).join('\n');
      const keys = Object.fromEntries(Array.from({ length: count }, (_, i) => [`k${i}`, 'v']));
      const text = JSON.stringify(keys);
      const files = [
        { locale: 'en', file: 'locales/en.json', text },
        { locale: 'de', file: 'locales/de.json', text },
      ];
      const catalog = readJsonCatalog('locales', 'locales', 'en', 'i18next', files);
      return () => {
        const usage = emptyUsage();
        collectUsage(code, 'js', usage);
        unusedKeys([catalog], usage, () => false);
      };
    };
    expect(growth(make, CATALOG_SIZE)).toBeLessThan(MAX_GROWTH);
  });
});
