// Reads the JSON translation files of a React Native, Expo or other JavaScript app: one file per
// locale (`en.json`) or one per locale and namespace (`en/common.json`). Nested objects are
// flattened with dots, the way i18next, i18n-js and react-intl address them. Plural forms are
// grouped under their base key:
// - i18next: `key_one`, `key_other`, `key_ordinal_one`. https://www.i18next.com/translation-function/plurals
// - i18n-js: `{ "key": { "one": "…", "other": "…" } }`. https://github.com/fnando/i18n
import type { Catalog, CatalogEntry, MessageSyntax, MessageText, Translation } from '../model.js';
import { asObject, type JsonObject, type JsonValue, parseJson } from '../parse/json.js';
import { icuTranslation } from './arb.js';

export interface JsonFile {
  locale: string;
  file: string;
  text?: string;
  problem?: string;
}

const CATEGORIES = new Set(['zero', 'one', 'two', 'few', 'many', 'other']);
const I18NEXT_SUFFIX = /^(.*?)_(ordinal_)?(zero|one|two|few|many|other)$/;

interface Leaf {
  key: string;
  text: string;
  line: number;
}

interface PluralLeaf extends Leaf {
  base: string;
  category: string;
  ordinal: boolean;
}

/** Flattens nested objects into dotted keys; i18n-js plural objects become `key.one` leaves. */
function flatten(
  object: JsonObject,
  prefix: string,
  into: Leaf[],
  problems: string[],
  depth = 0,
): void {
  for (const item of object.members) {
    const key = prefix ? `${prefix}.${item.key}` : item.key;
    const value: JsonValue = item.value;
    if (value.type === 'string') into.push({ key, text: value.value as string, line: item.line });
    else if (value.type === 'object' && depth < 32) flatten(value, key, into, problems, depth + 1);
    else if (value.type === 'array')
      problems.push(`"${key}" is an array; its items are not checked`);
  }
}

function pluralLeaf(leaf: Leaf, syntax: MessageSyntax): PluralLeaf | undefined {
  if (syntax === 'i18next') {
    const match = I18NEXT_SUFFIX.exec(leaf.key);
    if (!match?.[1]) return undefined;
    return { ...leaf, base: match[1], category: match[3] as string, ordinal: Boolean(match[2]) };
  }
  if (syntax === 'i18n-js') {
    const dot = leaf.key.lastIndexOf('.');
    const category = leaf.key.slice(dot + 1);
    if (dot <= 0 || !CATEGORIES.has(category)) return undefined;
    return { ...leaf, base: leaf.key.slice(0, dot), category, ordinal: false };
  }
  return undefined;
}

const groupKey = (leaf: PluralLeaf) => `${leaf.ordinal ? 'o' : 'c'}:${leaf.base}`;

/** Plural groups: base keys that have an "other" form in some locale, so `status_new` stays a key. */
function pluralGroups(leavesByLocale: Leaf[][], syntax: MessageSyntax): Set<string> {
  const groups = new Set<string>();
  for (const leaves of leavesByLocale) {
    for (const leaf of leaves) {
      const plural = pluralLeaf(leaf, syntax);
      if (plural?.category === 'other') groups.add(groupKey(plural));
    }
  }
  return groups;
}

function readLocale(
  locale: string,
  file: string,
  leaves: Leaf[],
  syntax: MessageSyntax,
  groups: Set<string>,
): Map<string, Translation> {
  const result = new Map<string, Translation>();
  const candidates = leaves.map((leaf) => pluralLeaf(leaf, syntax));
  leaves.forEach((leaf, index) => {
    const plural = candidates[index];
    if (plural && groups.has(groupKey(plural))) {
      const key = plural.ordinal ? `${plural.base}_ordinal` : plural.base;
      let translation = result.get(key);
      if (!translation) {
        translation = {
          locale,
          file,
          line: leaf.line,
          texts: [],
          plurals: [
            {
              name: 'count',
              type: plural.ordinal ? 'ordinal' : 'cardinal',
              categories: [],
              line: leaf.line,
            },
          ],
        };
        result.set(key, translation);
      }
      const text: MessageText = {
        text: leaf.text,
        path: `plural.${plural.category}`,
        line: leaf.line,
      };
      translation.texts.push(text);
      translation.plurals[0]?.categories.push(plural.category);
      return;
    }
    if (syntax === 'icu') {
      result.set(leaf.key, icuTranslation(locale, file, leaf.line, leaf.text, true));
      return;
    }
    result.set(leaf.key, {
      locale,
      file,
      line: leaf.line,
      texts: [{ text: leaf.text, path: '', line: leaf.line }],
      plurals: [],
    });
  });
  return result;
}

export function readJsonCatalog(
  id: string,
  name: string,
  sourceLocale: string,
  syntax: MessageSyntax,
  files: JsonFile[],
): Catalog {
  const catalog: Catalog = {
    id,
    name,
    format: 'json',
    syntax,
    ecosystem: 'js',
    sourceLocale,
    locales: [],
    files: new Map(),
    entries: new Map(),
    duplicates: [],
    problems: [],
  };
  const parsed: { json: JsonFile; leaves: Leaf[] }[] = [];
  for (const json of files) {
    catalog.files.set(json.locale, json.file);
    if (json.text === undefined) {
      catalog.problems.push({ file: json.file, line: 0, message: json.problem ?? 'Not read' });
      continue;
    }
    try {
      const document = parseJson(json.text);
      const root = asObject(document.root);
      if (!root) throw new Error('A translation file is a JSON object');
      for (const duplicate of document.duplicates) {
        catalog.duplicates.push({
          file: json.file,
          key: [...duplicate.path, duplicate.key].join('.'),
          line: duplicate.line,
          firstLine: duplicate.firstLine,
        });
      }
      const leaves: Leaf[] = [];
      const notes: string[] = [];
      flatten(root, '', leaves, notes);
      for (const note of notes) {
        catalog.notes = [...(catalog.notes ?? []), `${json.file}: ${note}`];
      }
      parsed.push({ json, leaves });
    } catch (error) {
      catalog.problems.push({
        file: json.file,
        line: (error as { line?: number }).line ?? 0,
        message: (error as Error).message,
      });
    }
  }
  const groups = pluralGroups(
    parsed.map(({ leaves }) => leaves),
    syntax,
  );
  for (const { json, leaves } of parsed) {
    for (const [key, translation] of readLocale(json.locale, json.file, leaves, syntax, groups)) {
      let entry: CatalogEntry | undefined = catalog.entries.get(key);
      if (!entry) {
        entry = { key, translations: new Map() };
        catalog.entries.set(key, entry);
      }
      entry.translations.set(json.locale, translation);
    }
  }
  const locales = [...catalog.files.keys()];
  catalog.locales = [
    ...(catalog.files.has(sourceLocale) ? [sourceLocale] : []),
    ...locales.filter((locale) => locale !== sourceLocale).sort(),
  ];
  return catalog;
}
