import { describe, expect, it } from 'vitest';
import { readAppleTable } from '../../src/catalogs/apple-tables.ts';
import { readArb } from '../../src/catalogs/arb.ts';
import { readJsonCatalog } from '../../src/catalogs/json-catalog.ts';
import { readXcstrings } from '../../src/catalogs/xcstrings.ts';
import type { Catalog } from '../../src/model.ts';
import { pluralCategories, pluralExamples, sameLanguage, toLanguageTag } from '../../src/plural.ts';
import { checkCatalog, localeLabel } from '../../src/rules/catalog-checks.ts';
import { stringsdict, unit, xcstrings } from '../helpers/tree.ts';

const check = (catalog: Catalog, locales?: string[], ignore: string[] = []) =>
  checkCatalog(catalog, {
    ...(locales ? { locales } : {}),
    ignoreKey: (key) => ignore.includes(key),
  });

const rules = (catalog: Catalog, locales?: string[]) =>
  check(catalog, locales).drafts.map(
    (draft) => `${draft.rule} ${draft.key ?? '-'} ${draft.locale ?? '-'}`,
  );

const strings = (files: Record<string, string>, source = 'en') =>
  readAppleTable(
    '*.lproj/Localizable',
    'Localizable',
    source,
    Object.entries(files).map(([locale, text]) => ({
      locale,
      file: `${locale}.lproj/Localizable.${text.startsWith('<?xml') ? 'stringsdict' : 'strings'}`,
      kind: text.startsWith('<?xml') ? ('stringsdict' as const) : ('strings' as const),
      text,
    })),
  );

const json = (syntax: 'i18next' | 'icu' | 'i18n-js', files: Record<string, unknown>) =>
  readJsonCatalog(
    'locales/*.json',
    'locales',
    'en',
    syntax,
    Object.entries(files).map(([locale, content]) => ({
      locale,
      file: `locales/${locale}.json`,
      text: JSON.stringify(content, null, 1),
    })),
  );

describe('plural data', () => {
  it('comes from CLDR through Intl.PluralRules', () => {
    expect(pluralCategories('en')).toEqual(['one', 'other']);
    expect(pluralCategories('pl')).toEqual(['one', 'few', 'many', 'other']);
    expect(pluralCategories('ar')).toEqual(['zero', 'one', 'two', 'few', 'many', 'other']);
    expect(pluralCategories('ja')).toEqual(['other']);
    expect(pluralCategories('pt_BR')).toEqual(pluralCategories('pt-BR'));
    expect(pluralCategories('en', 'ordinal')).toEqual(['one', 'two', 'few', 'other']);
    expect(pluralCategories('Base')).toBeUndefined();
    expect(pluralCategories('mul')).toBeUndefined();
    expect(pluralExamples('pl', 'few')).toEqual([2, 3, 4]);
  });

  it('normalises locale codes and compares languages', () => {
    expect(toLanguageTag('zh_Hant_TW')).toBe('zh-Hant-TW');
    expect(toLanguageTag('not a locale')).toBeUndefined();
    expect(sameLanguage('en', 'en-GB')).toBe(true);
    expect(sameLanguage('pt-BR', 'es')).toBe(false);
    expect(localeLabel('de')).toBe('German (de)');
    expect(localeLabel('Base')).toBe('Base');
  });
});

describe('missing, empty and untranslated', () => {
  const catalog = readXcstrings(
    xcstrings({
      Done: {
        localizations: {
          de: unit('Fertig'),
          fr: unit('', 'new'),
          tr: unit('Bitti', 'needs_review'),
        },
      },
      Cancel: { localizations: { de: unit(''), fr: unit('Annuler') } },
      Settings: {
        localizations: {
          de: unit('Settings'),
          fr: unit('Réglages'),
          tr: unit('Ayarlar'),
          'en-GB': unit('Settings'),
        },
      },
      Brand: { shouldTranslate: false },
      Old: { extractionState: 'stale', localizations: { de: unit('Alt') } },
    }),
    'Localizable.xcstrings',
  );
  const result = check(catalog);
  const found = result.drafts.map((draft) => `${draft.rule} ${draft.key} ${draft.locale ?? '-'}`);

  it('reports absent translations, state "new", empty values and needs_review', () => {
    expect(found).toEqual(
      expect.arrayContaining([
        'MIS001 Done en-GB',
        'MIS001 Done fr',
        'MIS003 Done tr',
        'MIS002 Cancel de',
        'MIS001 Cancel tr',
        'MIS004 Settings de',
        'STA001 Old -',
      ]),
    );
  });

  it('does not report keys not to translate, stale keys, or same-language copies', () => {
    expect(found.filter((line) => line.includes('Brand'))).toEqual([]);
    expect(found.filter((line) => line.startsWith('MIS') && line.includes('Old'))).toEqual([]);
    expect(found).not.toContain('MIS004 Settings en-GB');
  });

  it('counts coverage per locale over the keys that need translating', () => {
    expect(result.keys).toBe(3);
    expect(result.coverage).toEqual([
      { locale: 'de', translated: 2, total: 3 },
      { locale: 'en-GB', translated: 1, total: 3 },
      { locale: 'fr', translated: 2, total: 3 },
      { locale: 'tr', translated: 2, total: 3 },
    ]);
  });

  it('checks only the configured locales and reports one that has no file', () => {
    const configured = rules(catalog, ['de', 'pl']);
    expect(configured).toContain('MIS001 - pl');
    expect(configured.some((line) => line.endsWith(' fr'))).toBe(false);
  });

  it('leaves out ignored keys', () => {
    expect(check(catalog, undefined, ['Done']).drafts.some((draft) => draft.key === 'Done')).toBe(
      false,
    );
  });

  it('reports keys a locale has but the source does not, only when the source file exists', () => {
    const table = strings({ en: '"a" = "A";', de: '"a" = "A1";\n"gone" = "Weg";' });
    expect(rules(table)).toEqual(['STA002 gone de']);
    const storyboard = strings({ de: '"Abc-12.text" = "Hallo";' });
    expect(rules(storyboard)).toEqual([]);
  });
});

describe('placeholders', () => {
  it('reports a type swap and an argument the source does not have (format specifiers)', () => {
    const table = strings({
      en: '"files" = "%@ has %lld files";\n"reorder" = "%1$@ sent %2$lld";',
      de: '"files" = "%@ hat %@ Dateien";\n"reorder" = "%2$lld von %1$@";',
      fr: '"files" = "%@ a %lld fichiers %3$@";\n"reorder" = "%1$@ a envoyé %2$lld";',
    });
    const drafts = check(table).drafts;
    expect(
      drafts.map((draft) => `${draft.rule} ${draft.key} ${draft.locale} ${draft.subject}`),
    ).toEqual(['FMT001 files de type:2:object', 'FMT001 files fr extra:3']);
    expect(drafts[0]?.message).toBe(
      '"files" in German (de) uses %@ (an object) for argument 2; the source text has %lld (a 64-bit integer)',
    );
  });

  it('reports a dropped argument once per translation for format specifiers', () => {
    const table = strings({
      en: '"sent" = "%1$@ sent %2$lld";',
      de: '"sent" = "%1$@ hat gesendet";',
    });
    expect(rules(table)).toEqual(['FMT002 sent de']);
  });

  it('resolves String Catalog substitutions and %arg', () => {
    const catalog = readXcstrings(
      xcstrings({
        '%lld photos': {
          localizations: {
            en: {
              stringUnit: unit('%#@photos@').stringUnit,
              substitutions: {
                photos: {
                  argNum: 1,
                  formatSpecifier: 'lld',
                  variations: { plural: { one: unit('%arg photo'), other: unit('%arg photos') } },
                },
              },
            },
            de: { variations: { plural: { one: unit('%lld Foto'), other: unit('%lld Fotos') } } },
            fr: {
              variations: {
                plural: {
                  one: unit('%@ photo'),
                  other: unit('%@ photos'),
                  many: unit('%@ de photos'),
                },
              },
            },
          },
        },
      }),
      'L.xcstrings',
    );
    expect(rules(catalog)).toEqual(['FMT001 %lld photos fr']);
  });

  it('compares plural variants of a stringsdict against the source as a whole', () => {
    const table = strings({
      en: stringsdict({
        files: {
          format: '%1$#@n@ in %2$@',
          variable: 'n',
          type: 'lld',
          forms: { one: '%1$lld file', other: '%1$lld files' },
        },
      }),
      pl: stringsdict({
        files: {
          format: '%#@value@',
          variable: 'value',
          type: 'lld',
          forms: {
            one: 'plik w %2$@',
            few: '%1$lld pliki w %2$@',
            many: '%1$lld plików w %2$@',
            other: '%1$lld pliku w %2$@',
          },
        },
      }),
    });
    expect(rules(table)).toEqual([]);
  });

  it('compares names for ICU and i18next, and lets "one" forms drop the count', () => {
    const icu = json('icu', {
      en: { hi: 'Hi {name}, {count, plural, one{# file} other{# files}}' },
      de: { hi: 'Hallo {nom}, {count, plural, one{eine Datei} other{# Dateien}}' },
    });
    expect(rules(icu)).toEqual(['FMT001 hi de', 'FMT002 hi de']);
    const next = json('i18next', {
      en: { item_one: '{{count}} item', item_other: '{{count}} items', greet: 'Hello {{name}}' },
      de: { item_one: 'Ein Element', item_other: 'Elemente', greet: 'Hallo {{user}}' },
    });
    expect(rules(next)).toEqual(['FMT002 item de', 'FMT001 greet de', 'FMT002 greet de']);
  });

  it('reports invalid syntax in ICU messages, format strings and files', () => {
    const icu = json('icu', { en: { a: 'ok {x}' }, de: { a: 'kaputt {x' } });
    expect(rules(icu)).toEqual(['FMT003 a de']);
    const printf = strings({ en: '"a" = "Save %@";', de: '"a" = "%@ sparen %k";' });
    expect(rules(printf)).toEqual(['FMT003 a de']);
    const broken = strings({ en: '"a" = "A";', de: '"a" = ' });
    expect(rules(broken)).toEqual(['FMT003 - -', 'MIS001 a de']);
  });
});

describe('plurals', () => {
  it('reports CLDR categories a locale needs, with example numbers', () => {
    const next = json('i18next', {
      en: { item_one: '{{count}} item', item_other: '{{count}} items' },
      pl: { item_one: '{{count}} element', item_other: '{{count}} elementu' },
      ja: { item_other: '{{count}} 個' },
    });
    const drafts = check(next).drafts;
    expect(drafts.map((draft) => `${draft.rule} ${draft.locale}`)).toEqual(['PLU001 pl']);
    expect(drafts[0]?.message).toBe(
      '"item" in Polish (pl) has no plural forms for few (e.g. 2, 3, 4), many (e.g. 0, 5, 6)',
    );
  });

  it('reports a translation that does not vary where the source does', () => {
    const icu = json('icu', {
      en: { n: '{count, plural, one{# day} other{# days}}' },
      ru: { n: '{count} дней' },
      ja: { n: '{count}日' },
    });
    expect(rules(icu)).toEqual(['PLU001 n ru']);
  });

  it('reports a plural without "other"', () => {
    const arb = readArb(
      'l/*.arb',
      'app',
      { sourceLocale: 'en', useEscaping: false, outputClass: 'AppLocalizations' },
      [
        {
          locale: 'en',
          file: 'l/app_en.arb',
          text: '{"n": "{count, plural, one{# day} other{# days}}"}',
        },
        { locale: 'de', file: 'l/app_de.arb', text: '{"n": "{count, plural, one{# Tag}}"}' },
      ],
    );
    expect(rules(arb)).toEqual(['PLU002 n de']);
  });
});

describe('duplicates and keys', () => {
  it('reports duplicate keys and keys with dotted or dotless I', () => {
    const next = readJsonCatalog('l/*.json', 'l', 'en', 'i18next', [
      {
        locale: 'en',
        file: 'l/en.json',
        text: '{\n "title": "A",\n "title": "B",\n "başlık": "Title",\n "İndex": "Index"\n}',
      },
    ]);
    const drafts = check(next).drafts;
    expect(drafts.map((draft) => `${draft.rule} ${draft.key} ${draft.line}`)).toEqual([
      'DUP001 title 3',
      'TRI002 başlık 4',
      'TRI002 İndex 5',
    ]);
    expect(drafts[1]?.message).toContain('"ı"');
  });
});
