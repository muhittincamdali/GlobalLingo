// Reads a strings table: `Localizable.strings` and `Localizable.stringsdict` in each
// `<locale>.lproj` folder. At run time Foundation looks a key up in the .stringsdict first and in
// the .strings file second, so the two files of a locale form one set of keys.
// https://developer.apple.com/documentation/xcode/localizing-strings-that-contain-plurals
import type { Catalog, CatalogEntry, MessageText, PluralForms, Translation } from '../model.js';
import { dictValue, type PlistDict, type PlistValue, parsePlist } from '../parse/plist.js';
import { parseStrings } from '../parse/strings.js';

export interface TableFile {
  locale: string;
  file: string;
  kind: 'strings' | 'stringsdict';
  /** The decoded text, or undefined with `problem` when the file could not be read. */
  text?: string;
  problem?: string;
}

const PLURAL_RULE = 'NSStringPluralRuleType';
const FORMAT_KEY = 'NSStringLocalizedFormatKey';
const SPEC_TYPE = 'NSStringFormatSpecTypeKey';
const VALUE_TYPE = 'NSStringFormatValueTypeKey';

const stringValue = (value: PlistValue | undefined): string | undefined =>
  value?.type === 'string' ? value.value : undefined;

/** One stringsdict entry as a translation: the format key and every rule's variants. */
function stringsdictTranslation(
  locale: string,
  file: string,
  line: number,
  body: PlistDict,
): Translation {
  const texts: MessageText[] = [];
  const plurals: PluralForms[] = [];
  const formatKey = dictValue(body, FORMAT_KEY);
  const format = stringValue(formatKey) ?? '';
  texts.push({ text: format, path: '', line: formatKey?.line ?? line });
  const substitutions: NonNullable<MessageText['substitutions']> = {};
  for (const entry of body.entries) {
    if (entry.key === FORMAT_KEY || entry.value.type !== 'dict') continue;
    const rule = entry.value;
    const ruleType = stringValue(dictValue(rule, SPEC_TYPE));
    substitutions[entry.key] = {
      argNum: 0,
      specifier: stringValue(dictValue(rule, VALUE_TYPE)) ?? '@',
    };
    const categories: string[] = [];
    for (const variant of rule.entries) {
      if (variant.key === SPEC_TYPE || variant.key === VALUE_TYPE) continue;
      const text = stringValue(variant.value);
      if (text === undefined) continue;
      categories.push(variant.key);
      texts.push({ text, path: `${entry.key}.${variant.key}`, line: variant.line });
    }
    if (ruleType === PLURAL_RULE) {
      plurals.push({ name: entry.key, type: 'cardinal', categories, line: entry.line });
    }
  }
  // Variant strings carry their own specifiers; only the format key refers to rules by name.
  if (texts[0]) texts[0].substitutions = substitutions;
  return { locale, file, line, texts, plurals };
}

/** Pairs of a .strings file, which may also be an XML property list (Xcode can write either). */
function stringsPairs(text: string, file: string, catalog: Catalog) {
  if (!/^\s*<(?:\?xml|!DOCTYPE|plist)/.test(text)) return parseStrings(text).pairs;
  const document = parsePlist(text);
  for (const duplicate of document.duplicates) catalog.duplicates.push({ file, ...duplicate });
  if (document.root.type !== 'dict') throw new Error('The root of a .strings property list is a dictionary');
  return document.root.entries.flatMap((entry) =>
    entry.value.type === 'string' ? [{ key: entry.key, value: entry.value.value, line: entry.line }] : [],
  );
}

export function readAppleTable(
  id: string,
  name: string,
  sourceLocale: string,
  files: TableFile[],
): Catalog {
  const catalog: Catalog = {
    id,
    name,
    format: 'strings',
    syntax: 'printf',
    ecosystem: 'apple',
    sourceLocale,
    locales: [],
    files: new Map(),
    entries: new Map(),
    duplicates: [],
    problems: [],
  };
  const entry = (key: string): CatalogEntry => {
    let found = catalog.entries.get(key);
    if (!found) {
      found = { key, translations: new Map() };
      catalog.entries.set(key, found);
    }
    return found;
  };
  // .strings first, so a .stringsdict entry of the same key replaces it, as at run time.
  const ordered = [...files].sort((a, b) =>
    a.kind === b.kind ? 0 : a.kind === 'strings' ? -1 : 1,
  );
  for (const table of ordered) {
    if (!catalog.files.has(table.locale) || table.kind === 'strings')
      catalog.files.set(table.locale, table.file);
    if (table.text === undefined) {
      catalog.problems.push({ file: table.file, line: 0, message: table.problem ?? 'Not read' });
      continue;
    }
    try {
      if (table.kind === 'strings') {
        const seen = new Map<string, number>();
        for (const pair of stringsPairs(table.text, table.file, catalog)) {
          const first = seen.get(pair.key);
          if (first !== undefined) {
            catalog.duplicates.push({
              file: table.file,
              key: pair.key,
              line: pair.line,
              firstLine: first,
            });
          } else {
            seen.set(pair.key, pair.line);
          }
          entry(pair.key).translations.set(table.locale, {
            locale: table.locale,
            file: table.file,
            line: pair.line,
            texts: [{ text: pair.value, path: '', line: pair.line }],
            plurals: [],
          });
        }
      } else {
        const document = parsePlist(table.text);
        for (const duplicate of document.duplicates)
          catalog.duplicates.push({ file: table.file, ...duplicate });
        if (document.root.type !== 'dict')
          throw new Error('The root of a .stringsdict file is a dictionary');
        for (const item of document.root.entries) {
          if (item.value.type !== 'dict') continue;
          entry(item.key).translations.set(
            table.locale,
            stringsdictTranslation(table.locale, table.file, item.line, item.value),
          );
        }
      }
    } catch (error) {
      catalog.problems.push({
        file: table.file,
        line: (error as { line?: number }).line ?? 0,
        message: (error as Error).message,
      });
    }
  }
  const locales = [...catalog.files.keys()];
  catalog.locales = [sourceLocale, ...locales.filter((locale) => locale !== sourceLocale).sort()];
  if (!catalog.files.has(sourceLocale)) catalog.locales = catalog.locales.slice(1);
  return catalog;
}
