// Reads an Xcode String Catalog (.xcstrings): one JSON file with every key, its source language
// and each localization as a string unit or variations by plural, device or width, with plural
// substitutions for strings that have several numbers.
// https://developer.apple.com/documentation/xcode/localizing-and-varying-text-with-a-string-catalog
import type {
  Catalog,
  CatalogEntry,
  MessageText,
  PluralForms,
  Translation,
  TranslationState,
} from '../model.js';
import {
  asObject,
  asString,
  type JsonObject,
  member,
  parseJson,
  uniqueMembers,
} from '../parse/json.js';

const STATES = new Set<TranslationState>(['translated', 'new', 'needs_review', 'stale']);

interface Collected {
  texts: MessageText[];
  plurals: PluralForms[];
  states: TranslationState[];
}

/** Walks `stringUnit` and `variations` below a localization (or a variation case). */
function collect(node: JsonObject, path: string, into: Collected, depth = 0): void {
  if (depth > 8) return;
  const unit = asObject(member(node, 'stringUnit')?.value);
  if (unit) {
    const valueMember = member(unit, 'value');
    const state = asString(member(unit, 'state')?.value) as TranslationState | undefined;
    into.texts.push({
      text: asString(valueMember?.value) ?? '',
      path,
      line: valueMember?.line ?? unit.line,
    });
    if (state && STATES.has(state)) into.states.push(state);
  }
  const variations = asObject(member(node, 'variations')?.value);
  if (!variations) return;
  for (const kind of uniqueMembers(variations)) {
    const cases = asObject(kind.value);
    if (!cases) continue;
    if (kind.key === 'plural') {
      into.plurals.push({
        name: path ? `${path}.plural` : 'value',
        type: 'cardinal',
        categories: uniqueMembers(cases).map((item) => item.key),
        line: kind.line,
      });
    }
    for (const item of uniqueMembers(cases)) {
      const child = asObject(item.value);
      if (child)
        collect(
          child,
          path ? `${path}.${kind.key}.${item.key}` : `${kind.key}.${item.key}`,
          into,
          depth + 1,
        );
    }
  }
}

function readLocalization(
  locale: string,
  node: JsonObject,
  file: string,
  line: number,
): Translation {
  const into: Collected = { texts: [], plurals: [], states: [] };
  collect(node, '', into);
  const substitutions: NonNullable<MessageText['substitutions']> = {};
  const subs = asObject(member(node, 'substitutions')?.value);
  for (const sub of subs ? uniqueMembers(subs) : []) {
    const body = asObject(sub.value);
    if (!body) continue;
    const argNum = member(body, 'argNum')?.value;
    const specifier = asString(member(body, 'formatSpecifier')?.value) ?? '@';
    const position =
      argNum?.type === 'number' &&
      Number.isSafeInteger(argNum.value) &&
      (argNum.value as number) > 0
        ? (argNum.value as number)
        : 0;
    substitutions[sub.key] = { argNum: position, specifier };
    const inner: Collected = { texts: [], plurals: [], states: [] };
    collect(body, `substitutions.${sub.key}`, inner);
    for (const plural of inner.plurals) plural.name = sub.key;
    into.texts.push(...inner.texts);
    into.plurals.push(...inner.plurals);
    into.states.push(...inner.states);
  }
  if (Object.keys(substitutions).length > 0) {
    for (const text of into.texts) text.substitutions = substitutions;
  }
  // The weakest state wins: one untranslated plural form makes the localization untranslated.
  const order: TranslationState[] = ['new', 'stale', 'needs_review', 'translated'];
  const state = order.find((candidate) => into.states.includes(candidate));
  return {
    locale,
    file,
    line,
    texts: into.texts,
    plurals: into.plurals,
    ...(state ? { state } : {}),
  };
}

export function readXcstrings(text: string, file: string): Catalog {
  const document = parseJson(text);
  const root = asObject(document.root);
  if (!root) throw new Error('A String Catalog is a JSON object');
  const sourceLocale = asString(member(root, 'sourceLanguage')?.value) ?? 'en';
  const strings = asObject(member(root, 'strings')?.value);
  const entries = new Map<string, CatalogEntry>();
  const locales = new Set<string>([sourceLocale]);
  for (const item of strings ? uniqueMembers(strings) : []) {
    const body = asObject(item.value);
    const entry: CatalogEntry = { key: item.key, translations: new Map(), keyIsSource: true };
    if (body) {
      const extraction = asString(member(body, 'extractionState')?.value);
      if (extraction === 'stale') entry.stale = true;
      const shouldTranslate = member(body, 'shouldTranslate')?.value;
      if (shouldTranslate?.type === 'boolean' && shouldTranslate.value === false) {
        entry.doNotTranslate = true;
      }
      const localizations = asObject(member(body, 'localizations')?.value);
      for (const localization of localizations ? uniqueMembers(localizations) : []) {
        const node = asObject(localization.value);
        if (!node) continue;
        locales.add(localization.key);
        entry.translations.set(
          localization.key,
          readLocalization(localization.key, node, file, localization.line),
        );
      }
    }
    if (!entry.translations.has(sourceLocale)) {
      entry.translations.set(sourceLocale, {
        locale: sourceLocale,
        file,
        line: item.line,
        texts: [{ text: item.key, path: '', line: item.line }],
        plurals: [],
      });
    }
    entries.set(item.key, entry);
  }
  return {
    id: file,
    name:
      file
        .split('/')
        .pop()
        ?.replace(/\.xcstrings$/, '') ?? file,
    format: 'xcstrings',
    syntax: 'printf',
    ecosystem: 'apple',
    sourceLocale,
    locales: [sourceLocale, ...[...locales].filter((locale) => locale !== sourceLocale).sort()],
    files: new Map([...locales].map((locale) => [locale, file])),
    entries,
    duplicates: document.duplicates.map((duplicate) => ({
      file,
      // A duplicate in "strings" is a duplicate string key; a deeper one also names its place.
      key: [...duplicate.path.slice(1), duplicate.key].join(' › '),
      line: duplicate.line,
      firstLine: duplicate.firstLine,
    })),
    problems: [],
  };
}
