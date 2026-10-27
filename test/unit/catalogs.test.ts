import { describe, expect, it } from 'vitest';
import { readAppleTable } from '../../src/catalogs/apple-tables.ts';
import { readArb } from '../../src/catalogs/arb.ts';
import { readJsonCatalog } from '../../src/catalogs/json-catalog.ts';
import { readXcstrings } from '../../src/catalogs/xcstrings.ts';
import { stringsdict, unit, xcstrings } from '../helpers/tree.ts';

describe('readXcstrings', () => {
  const catalog = readXcstrings(
    xcstrings({
      Hello: { localizations: { de: unit('Hallo'), tr: unit('', 'new') } },
      '%lld photos in %@': {
        localizations: {
          en: {
            stringUnit: { state: 'translated', value: '%#@photos@ in %2$@' },
            substitutions: {
              photos: {
                argNum: 1,
                formatSpecifier: 'lld',
                variations: { plural: { one: unit('%arg photo'), other: unit('%arg photos') } },
              },
            },
          },
          pl: {
            variations: {
              plural: {
                one: unit('%lld zdjęcie w %@'),
                few: unit('%lld zdjęcia w %@', 'needs_review'),
                other: unit('%lld zdjęć w %@'),
              },
            },
          },
        },
      },
      Old: { extractionState: 'stale' },
      Brand: { shouldTranslate: false },
      Devices: {
        localizations: {
          en: {
            variations: { device: { iphone: unit('Tap'), mac: unit('Click'), other: unit('Use') } },
          },
        },
      },
    }),
    'App/Localizable.xcstrings',
  );

  it('reads the source language, every locale and the catalog name', () => {
    expect(catalog.sourceLocale).toBe('en');
    expect(catalog.locales).toEqual(['en', 'de', 'pl', 'tr']);
    expect(catalog.name).toBe('Localizable');
    expect(catalog.format).toBe('xcstrings');
  });

  it('uses the key as the source text when the source language has no value', () => {
    const hello = catalog.entries.get('Hello');
    expect(hello?.translations.get('en')?.texts).toEqual([{ text: 'Hello', path: '', line: 4 }]);
    expect(hello?.translations.get('tr')?.state).toBe('new');
    expect(hello?.translations.get('de')?.texts[0]?.text).toBe('Hallo');
  });

  it('reads plural variations, substitutions and the weakest state', () => {
    const photos = catalog.entries.get('%lld photos in %@');
    const en = photos?.translations.get('en');
    expect(en?.plurals).toMatchObject([{ name: 'photos', categories: ['one', 'other'] }]);
    expect(en?.texts.map((text) => text.path)).toEqual([
      '',
      'substitutions.photos.plural.one',
      'substitutions.photos.plural.other',
    ]);
    expect(en?.texts[0]?.substitutions).toEqual({ photos: { argNum: 1, specifier: 'lld' } });
    const pl = photos?.translations.get('pl');
    expect(pl?.plurals).toMatchObject([{ name: 'value', categories: ['one', 'few', 'other'] }]);
    expect(pl?.state).toBe('needs_review');
  });

  it('reads stale keys, keys not to translate and device variations', () => {
    expect(catalog.entries.get('Old')?.stale).toBe(true);
    expect(catalog.entries.get('Brand')?.doNotTranslate).toBe(true);
    expect(
      catalog.entries
        .get('Devices')
        ?.translations.get('en')
        ?.texts.map((text) => text.path),
    ).toEqual(['device.iphone', 'device.mac', 'device.other']);
  });

  it('reports a key that appears twice', () => {
    const text = '{\n "sourceLanguage": "en",\n "strings": {\n  "A": {},\n  "A": {}\n }\n}';
    expect(readXcstrings(text, 'L.xcstrings').duplicates).toEqual([
      { file: 'L.xcstrings', key: 'A', line: 5, firstLine: 4 },
    ]);
  });

  it.each(['1e309', '-1', '1.5', '"1"', '0'])('ignores the argNum %s, which is not a positive whole number', (argNum) => {
    const text = `{"sourceLanguage": "en", "strings": {"k": {"localizations": {"en": {
      "stringUnit": {"state": "translated", "value": "%#@n@"},
      "substitutions": {"n": {"argNum": ${argNum}, "formatSpecifier": "d"}}}}}}}`;
    const odd = readXcstrings(text, 'X.xcstrings');
    expect(odd.entries.get('k')?.translations.get('en')?.texts[0]?.substitutions).toEqual({
      n: { argNum: 0, specifier: 'd' },
    });
  });
});

describe('readAppleTable', () => {
  const catalog = readAppleTable('*.lproj/Localizable', 'Localizable', 'en', [
    {
      locale: 'en',
      file: 'en.lproj/Localizable.strings',
      kind: 'strings',
      text: '"a" = "A";\n"files" = "%d files";\n',
    },
    {
      locale: 'en',
      file: 'en.lproj/Localizable.stringsdict',
      kind: 'stringsdict',
      text: stringsdict({
        files: {
          format: '%#@n@',
          variable: 'n',
          type: 'd',
          forms: { one: '%d file', other: '%d files' },
        },
      }),
    },
    {
      locale: 'de',
      file: 'de.lproj/Localizable.strings',
      kind: 'strings',
      text: '"a" = "A1";\n"a" = "A2";\n',
    },
    { locale: 'fr', file: 'fr.lproj/Localizable.strings', kind: 'strings', text: '"a" = ' },
    {
      locale: 'tr',
      file: 'tr.lproj/Localizable.strings',
      kind: 'strings',
      text: '<?xml version="1.0" encoding="UTF-8"?>\n<plist version="1.0">\n<dict>\n\t<key>a</key>\n\t<string>Bir</string>\n</dict>\n</plist>\n',
    },
    { locale: 'ja', file: 'ja.lproj/Localizable.strings', kind: 'strings', problem: 'EACCES' },
  ]);

  it('lets a stringsdict entry replace the .strings entry of the same key, as Foundation does', () => {
    const files = catalog.entries.get('files')?.translations.get('en');
    expect(files?.file).toBe('en.lproj/Localizable.stringsdict');
    expect(files?.plurals).toMatchObject([{ name: 'n', categories: ['one', 'other'] }]);
    expect(files?.texts.map((text) => [text.path, text.text])).toEqual([
      ['', '%#@n@'],
      ['n.one', '%d file'],
      ['n.other', '%d files'],
    ]);
  });

  it('records duplicates with the last value, XML .strings files, and unreadable files', () => {
    expect(catalog.duplicates).toEqual([
      { file: 'de.lproj/Localizable.strings', key: 'a', line: 2, firstLine: 1 },
    ]);
    expect(catalog.entries.get('a')?.translations.get('de')?.texts[0]?.text).toBe('A2');
    expect(catalog.entries.get('a')?.translations.get('tr')?.texts[0]?.text).toBe('Bir');
    expect(catalog.problems.map((problem) => [problem.file, problem.line])).toEqual([
      ['fr.lproj/Localizable.strings', 1],
      ['ja.lproj/Localizable.strings', 0],
    ]);
    expect(catalog.locales).toEqual(['en', 'de', 'fr', 'ja', 'tr']);
  });
});

describe('readArb', () => {
  it('reads messages with ICU plurals, skips metadata and reports non-string values', () => {
    const catalog = readArb(
      'lib/l10n/*.arb',
      'app',
      { sourceLocale: 'en', useEscaping: false, outputClass: 'AppLocalizations' },
      [
        {
          locale: 'en',
          file: 'lib/l10n/app_en.arb',
          text: '{\n "@@locale": "en",\n "hello": "Hello {name}",\n "@hello": {"placeholders": {"name": {}}},\n "items": "{count, plural, one{# item} other{# items}}",\n "bad": 3\n}',
        },
        { locale: 'tr', file: 'lib/l10n/app_tr.arb', text: '{\n "hello": "Merhaba {name"\n}' },
      ],
    );
    expect([...catalog.entries.keys()]).toEqual(['hello', 'items']);
    expect(catalog.entries.get('items')?.translations.get('en')?.plurals).toMatchObject([
      { name: 'count', categories: ['one', 'other'] },
    ]);
    expect(catalog.entries.get('hello')?.translations.get('tr')?.syntaxError).toMatch(
      /Missing "}"/,
    );
    expect(catalog.problems).toEqual([
      { file: 'lib/l10n/app_en.arb', line: 6, message: 'The value of "bad" is not a string' },
    ]);
    expect(catalog.apostropheQuoting).toBe(false);
  });
});

describe('readJsonCatalog', () => {
  it('flattens nested keys and groups i18next plural suffixes that have an "other" form', () => {
    const catalog = readJsonCatalog('locales/*.json', 'locales', 'en', 'i18next', [
      {
        locale: 'en',
        file: 'locales/en.json',
        text: JSON.stringify({
          home: { title: 'Home' },
          item_one: '{{count}} item',
          item_other: '{{count}} items',
          status_new: 'New',
          place_ordinal_one: '{{count}}st',
          place_ordinal_other: '{{count}}th',
          list: ['a'],
        }),
      },
      {
        locale: 'pl',
        file: 'locales/pl.json',
        text: JSON.stringify({ item_few: '{{count}} elementy' }),
      },
    ]);
    expect([...catalog.entries.keys()].sort()).toEqual([
      'home.title',
      'item',
      'place_ordinal',
      'status_new',
    ]);
    expect(catalog.entries.get('item')?.translations.get('en')?.plurals).toMatchObject([
      { name: 'count', type: 'cardinal', categories: ['one', 'other'] },
    ]);
    expect(catalog.entries.get('item')?.translations.get('pl')?.plurals).toMatchObject([
      { categories: ['few'] },
    ]);
    expect(catalog.entries.get('place_ordinal')?.translations.get('en')?.plurals).toMatchObject([
      { type: 'ordinal' },
    ]);
    expect(catalog.notes).toEqual([
      'locales/en.json: "list" is an array; its items are not checked',
    ]);
  });

  it('groups i18n-js plural objects and reads ICU values for react-intl', () => {
    const i18nJs = readJsonCatalog('t/*.json', 't', 'en', 'i18n-js', [
      {
        locale: 'en',
        file: 't/en.json',
        text: JSON.stringify({ inbox: { one: '1 message', other: '%{count} messages' } }),
      },
    ]);
    expect(
      i18nJs.entries
        .get('inbox')
        ?.translations.get('en')
        ?.texts.map((text) => text.path),
    ).toEqual(['plural.one', 'plural.other']);
    const icu = readJsonCatalog('m/*.json', 'm', 'en', 'icu', [
      { locale: 'en', file: 'm/en.json', text: JSON.stringify({ greeting: 'Hi {name' }) },
    ]);
    expect(icu.entries.get('greeting')?.translations.get('en')?.syntaxError).toMatch(/Missing/);
  });

  it('reports duplicate keys with their dotted path and files that are not JSON objects', () => {
    const catalog = readJsonCatalog('l/*.json', 'l', 'en', 'i18next', [
      { locale: 'en', file: 'l/en.json', text: '{\n "a": {\n  "b": "1",\n  "b": "2"\n }\n}' },
      { locale: 'de', file: 'l/de.json', text: '[1]' },
    ]);
    expect(catalog.duplicates).toEqual([{ file: 'l/en.json', key: 'a.b', line: 4, firstLine: 3 }]);
    expect(catalog.problems[0]?.message).toBe('A translation file is a JSON object');
  });
});
