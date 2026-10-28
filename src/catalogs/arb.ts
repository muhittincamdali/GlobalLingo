// Reads the ARB files of a Flutter app: one JSON file per locale, messages in ICU syntax,
// `@key` metadata next to each message and `@@locale` for the file's locale. gen_l10n reads the
// template file (`template-arb-file` in l10n.yaml) as the source.
// https://docs.flutter.dev/ui/internationalization
import type { Catalog, CatalogEntry, Translation } from '../model.js';
import { parseIcu } from '../messages/icu.js';
import { asObject, asString, member, parseJson } from '../parse/json.js';

export interface ArbFile {
  locale: string;
  file: string;
  text?: string;
  problem?: string;
}

export interface ArbSettings {
  /** Template file's locale. */
  sourceLocale: string;
  /** `use-escaping` in l10n.yaml: apostrophes quote text. */
  useEscaping: boolean;
  /** `output-class` in l10n.yaml. */
  outputClass: string;
}

/** The locale an ARB file declares with `@@locale`, if it declares one. */
export function arbLocale(text: string): string | undefined {
  try {
    const root = asObject(parseJson(text).root);
    return root ? asString(member(root, '@@locale')?.value) : undefined;
  } catch {
    return undefined;
  }
}

export function icuTranslation(
  locale: string,
  file: string,
  line: number,
  text: string,
  apostropheQuoting: boolean,
): Translation {
  const parsed = parseIcu(text, { apostropheQuoting });
  return {
    locale,
    file,
    line,
    texts: [{ text, path: '', line }],
    plurals: parsed.plurals.map((plural) => ({
      name: plural.name,
      type: plural.type,
      categories: plural.categories,
      line,
    })),
    ...(parsed.error ? { syntaxError: parsed.error } : {}),
  };
}

export function readArb(
  id: string,
  name: string,
  settings: ArbSettings,
  files: ArbFile[],
): Catalog {
  const catalog: Catalog = {
    id,
    name,
    format: 'arb',
    syntax: 'icu',
    ecosystem: 'flutter',
    sourceLocale: settings.sourceLocale,
    locales: [],
    files: new Map(),
    entries: new Map(),
    duplicates: [],
    problems: [],
    outputClass: settings.outputClass,
    apostropheQuoting: settings.useEscaping,
  };
  for (const arb of files) {
    catalog.files.set(arb.locale, arb.file);
    if (arb.text === undefined) {
      catalog.problems.push({ file: arb.file, line: 0, message: arb.problem ?? 'Not read' });
      continue;
    }
    try {
      const document = parseJson(arb.text);
      const root = asObject(document.root);
      if (!root) throw new Error('An ARB file is a JSON object');
      for (const duplicate of document.duplicates) {
        if (duplicate.path.length === 0) {
          catalog.duplicates.push({
            file: arb.file,
            key: duplicate.key,
            line: duplicate.line,
            firstLine: duplicate.firstLine,
          });
        }
      }
      for (const item of root.members) {
        if (item.key.startsWith('@')) continue;
        const value = asString(item.value);
        if (value === undefined) {
          catalog.problems.push({
            file: arb.file,
            line: item.line,
            message: `The value of "${item.key}" is not a string`,
          });
          continue;
        }
        let entry: CatalogEntry | undefined = catalog.entries.get(item.key);
        if (!entry) {
          entry = { key: item.key, translations: new Map() };
          catalog.entries.set(item.key, entry);
        }
        entry.translations.set(
          arb.locale,
          icuTranslation(arb.locale, arb.file, item.line, value, settings.useEscaping),
        );
      }
    } catch (error) {
      catalog.problems.push({
        file: arb.file,
        line: (error as { line?: number }).line ?? 0,
        message: (error as Error).message,
      });
    }
  }
  const locales = [...catalog.files.keys()];
  catalog.locales = [
    ...(catalog.files.has(settings.sourceLocale) ? [settings.sourceLocale] : []),
    ...locales.filter((locale) => locale !== settings.sourceLocale).sort(),
  ];
  return catalog;
}
