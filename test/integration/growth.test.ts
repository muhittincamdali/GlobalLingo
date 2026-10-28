// Crafted inputs a pull request could add to make a run take hours: each case grows 16 times, to
// 2 MB, and must take about 16 times as long, not 256. See test/helpers/growth.ts for why a ratio.
import { describe, expect, it } from 'vitest';
import { readAppleTable } from '../../src/catalogs/apple-tables.ts';
import { readArb } from '../../src/catalogs/arb.ts';
import { readJsonCatalog } from '../../src/catalogs/json-catalog.ts';
import { readXcstrings } from '../../src/catalogs/xcstrings.ts';
import { checkSource, codeContext } from '../../src/code/check-code.ts';
import { parseIcu } from '../../src/messages/icu.ts';
import { i18nextNesting, i18nJsPlaceholders } from '../../src/messages/interpolation.ts';
import { parsePrintf } from '../../src/messages/printf.ts';
import type { Catalog } from '../../src/model.ts';
import { parseJson } from '../../src/parse/json.ts';
import { parsePlist } from '../../src/parse/plist.ts';
import { parseStrings } from '../../src/parse/strings.ts';
import { globMatcher } from '../../src/project/files.ts';
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
  ])('reads printf with %s in linear time', (_name, make) => {
    expect(growth((size) => () => parsePrintf(make(size)))).toBeLessThan(MAX_GROWTH);
  });

  it.each([
    ['i18n-js', (size: number) => i18nJsPlaceholders(`%{${' '.repeat(size)}`)],
    ['nesting', (size: number) => i18nextNesting(`$t(${' '.repeat(size)}`)],
  ])('reads %s placeholders in linear time', (_name, read) => {
    expect(growth((size) => () => read(size))).toBeLessThan(MAX_GROWTH);
  });
});

describe('property lists', () => {
  it.each([
    ['a long tag', (size: number) => `<plist><dict${'a'.repeat(size)}/x>`],
    ['long tags', (size: number) => `<plist><array>${fill('<true    />', size)}</array></plist>`],
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

describe('ignore globs', () => {
  it('matches a pathological glob in linear time', () => {
    const match = globMatcher(['**/**/**/**/**/**/**/**/a*a*a*a*a*a*a*a*a*a*b']);
    expect(growth((size) => () => match('a'.repeat(size)))).toBeLessThan(MAX_GROWTH);
  });
});
