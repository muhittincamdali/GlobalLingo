// The checks that read source code: keys the code looks up (KEY001, KEY002), hard-coded UI text
// (HCS001), and case changes around lookups (TRI001, TRI003).
import type { Catalog, Ecosystem } from '../model.js';
import { isTurkic } from '../plural.js';
import { type Draft, quote } from '../rules/draft.js';
import { literalValue, parenPairs, type SourceLanguage, stripComments } from './lexer.js';
import {
  DART_HARDCODED,
  dartPlainCase,
  JS_HARDCODED,
  JS_KEY_LOOKUPS,
  JS_LOCALE_CASE,
  JS_LOOKUP_CALLS,
  JS_PLAIN_CASE_AFTER,
  NOT_APP_CODE,
  OBJC_HARDCODED,
  OBJC_LOCALE_CASE,
  OBJC_LOOKUP_CALLS,
  OBJC_LOOKUPS,
  SWIFT_HARDCODED,
  SWIFT_LOCALE_CASE,
  SWIFT_LOOKUP_CALLS,
  SWIFT_LOOKUPS,
  SWIFT_PLAIN_CASE_AFTER,
  SWIFTUI_TEXT,
} from './patterns.js';

export const SOURCE_EXTENSIONS: Record<string, SourceLanguage> = {
  swift: 'swift',
  m: 'objc',
  mm: 'objc',
  dart: 'dart',
  js: 'js',
  jsx: 'js',
  ts: 'js',
  tsx: 'js',
  mjs: 'js',
  cjs: 'js',
};

const ECOSYSTEM: Record<SourceLanguage, Ecosystem> = {
  swift: 'apple',
  objc: 'apple',
  dart: 'flutter',
  js: 'js',
};

export function sourceLanguage(path: string): SourceLanguage | undefined {
  if (path.endsWith('.d.ts')) return undefined;
  return SOURCE_EXTENSIONS[path.slice(path.lastIndexOf('.') + 1)];
}

/** What the code checks need to know about the catalogs. */
export interface CodeContext {
  /** Apple tables by name, with every key in any locale. */
  appleTables: Map<string, { keys: Set<string>; stringCatalog: boolean }>;
  /** Keys of the JSON catalogs, plain and as `namespace:key`. */
  jsKeys: Set<string>;
  jsNamespaces: Set<string>;
  /** Whether a catalog has Turkish or Azerbaijani. */
  shipsTurkic: boolean;
  /** Flutter output classes from l10n.yaml. */
  outputClasses: string[];
}

export function codeContext(catalogs: Catalog[]): CodeContext {
  const context: CodeContext = {
    appleTables: new Map(),
    jsKeys: new Set(),
    jsNamespaces: new Set(),
    shipsTurkic: catalogs.some((catalog) => catalog.locales.some(isTurkic)),
    outputClasses: catalogs.flatMap((catalog) =>
      catalog.outputClass ? [catalog.outputClass] : [],
    ),
  };
  for (const catalog of catalogs) {
    if (catalog.ecosystem === 'apple') {
      const table = context.appleTables.get(catalog.name) ?? {
        keys: new Set<string>(),
        stringCatalog: false,
      };
      for (const key of catalog.entries.keys()) table.keys.add(key);
      table.stringCatalog ||= catalog.format === 'xcstrings';
      context.appleTables.set(catalog.name, table);
    } else if (catalog.format === 'json') {
      context.jsNamespaces.add(catalog.name);
      for (const key of catalog.entries.keys()) {
        context.jsKeys.add(key);
        context.jsKeys.add(`${catalog.name}:${key}`);
      }
    }
  }
  return context;
}

/** Offsets of line starts, for turning a match offset into a line number. */
function lineFinder(text: string): (offset: number) => number {
  const starts = [0];
  for (let i = 0; i < text.length; i += 1) if (text.charCodeAt(i) === 10) starts.push(i + 1);
  return (offset) => {
    let low = 0;
    let high = starts.length - 1;
    while (low < high) {
      const middle = (low + high + 1) >> 1;
      if ((starts[middle] as number) <= offset) low = middle;
      else high = middle - 1;
    }
    return low + 1;
  };
}

/** A UI string worth reporting: has letters, and is not an identifier, a path or a URL. */
function looksLikeText(value: string): boolean {
  const text = value.trim();
  if (text.length < 2 || !/\p{L}/u.test(text)) return false;
  if (/^[a-z0-9_.-]+$/.test(text) || /^[A-Z0-9_]+$/.test(text)) return false;
  if (/^(?:https?:|mailto:|tel:|\/|#|\.\/)/.test(text) || /^[\w.-]+@[\w.-]+$/.test(text))
    return false;
  return true;
}

export interface CodeFile {
  path: string;
  text: string;
}

export function checkSource(file: CodeFile, context: CodeContext): Draft[] {
  const language = sourceLanguage(file.path);
  if (!language) return [];
  const ecosystem = ECOSYSTEM[language];
  const code = stripComments(file.text, language);
  const lineOf = lineFinder(code);
  const lines = file.text.split('\n');
  const closingParen = parenPairs(code);
  // Lines with a suppression comment, found once rather than per finding.
  const quiet = new Set<number>();
  lines.forEach((line, index) => {
    if (!line.includes('globallingo-ignore')) return;
    if (/globallingo-ignore-next-line/.test(line)) quiet.add(index + 2);
    if (/globallingo-ignore(?!-next-line)/.test(line)) quiet.add(index + 1);
  });
  const suppressed = (line: number) => quiet.has(line);
  const drafts: Draft[] = [];
  const add = (draft: Omit<Draft, 'ecosystem' | 'file'>) => {
    if (!suppressed(draft.line)) drafts.push({ ...draft, ecosystem, file: file.path });
  };
  const appCode = !NOT_APP_CODE.test(file.path);

  // KEY001: explicit lookups of keys no catalog has.
  if (language === 'swift' || language === 'objc') {
    for (const pattern of language === 'swift' ? SWIFT_LOOKUPS : OBJC_LOOKUPS) {
      for (const match of code.matchAll(pattern.regex)) {
        const key = literalValue(match[1] ?? '', 'swift');
        if (key === undefined || key === '') continue;
        const open = code.indexOf('(', match.index);
        const end = closingParen(open);
        const args = end === -1 ? '' : code.slice(match.index + match[0].length, end);
        const tableName = pattern.tableArgument?.exec(args)?.[1] ?? 'Localizable';
        const table = context.appleTables.get(tableName);
        if (!table || table.keys.has(key)) continue;
        add({
          rule: 'KEY001',
          line: lineOf(match.index),
          key,
          message: `${quote(key)} is not in the ${tableName} table`,
          subject: `${tableName}:${key}`,
        });
      }
    }
  }
  if (language === 'swift') {
    for (const match of code.matchAll(SWIFTUI_TEXT)) {
      const body = match[1] ?? match[2] ?? '';
      const key = literalValue(body, 'swift');
      if (key === undefined || !/\p{L}/u.test(key) || key.includes('%')) continue;
      const open = code.indexOf('(', match.index);
      const end = closingParen(open);
      const args = end === -1 ? '' : code.slice(open, end);
      const tableName = /\btableName:\s*"([^"\n]*)"/.exec(args)?.[1] ?? 'Localizable';
      const table = context.appleTables.get(tableName);
      if (!table?.stringCatalog || table.keys.has(key)) continue;
      add({
        rule: 'KEY002',
        line: lineOf(match.index),
        key,
        message: `${quote(key)} is shown by SwiftUI but is not in the ${tableName} String Catalog`,
        subject: `${tableName}:${key}`,
      });
    }
  }
  if (language === 'js' && context.jsKeys.size > 0) {
    for (const regex of JS_KEY_LOOKUPS) {
      for (const match of code.matchAll(regex)) {
        const key = literalValue(match[2] ?? '', 'js');
        if (key === undefined || key === '' || context.jsKeys.has(key)) continue;
        const namespace = key.includes(':') ? key.slice(0, key.indexOf(':')) : undefined;
        if (
          namespace &&
          !context.jsNamespaces.has(namespace) &&
          context.jsKeys.has(key.slice(namespace.length + 1))
        )
          continue;
        add({
          rule: 'KEY001',
          line: lineOf(match.index),
          key,
          message: `${quote(key)} is not in any translation file`,
          subject: key,
        });
      }
    }
  }

  // HCS001: text shown to the user, written in the code.
  if (appCode) {
    const patterns = {
      swift: SWIFT_HARDCODED,
      objc: OBJC_HARDCODED,
      dart: DART_HARDCODED,
      js: JS_HARDCODED,
    }[language];
    for (const regex of patterns) {
      for (const match of code.matchAll(regex)) {
        const body = match.length > 2 ? match[2] : match[1];
        const value = body === undefined ? undefined : literalValue(body, language);
        if (value === undefined || !looksLikeText(value)) continue;
        add({
          rule: 'HCS001',
          line: lineOf(match.index),
          message: `${quote(value.trim())} is shown to the user but is not localized`,
          subject: value.trim(),
        });
      }
    }
  }

  // TRI001 and TRI003: case changes on lookup keys and on translated text.
  const calls = {
    swift: SWIFT_LOOKUP_CALLS,
    objc: OBJC_LOOKUP_CALLS,
    js: JS_LOOKUP_CALLS,
    dart: undefined,
  }[language];
  const localeCase = {
    swift: SWIFT_LOCALE_CASE,
    objc: OBJC_LOCALE_CASE,
    js: JS_LOCALE_CASE,
    dart: undefined,
  }[language];
  const plainCase = {
    swift: SWIFT_PLAIN_CASE_AFTER,
    objc: undefined,
    js: JS_PLAIN_CASE_AFTER,
    dart: undefined,
  }[language];
  for (const match of calls ? code.matchAll(calls) : []) {
    const open = code.indexOf('(', match.index);
    const end = closingParen(open);
    if (end === -1) continue;
    const args = code.slice(open + 1, end);
    const caseCall = localeCase?.exec(args);
    if (caseCall) {
      add({
        rule: 'TRI001',
        line: lineOf(open + 1 + caseCall.index),
        message: `The lookup key goes through ${caseCall[0].replace(/^\./, '').replace(/\s+/g, ' ')}, which depends on the device locale`,
        subject: caseCall[0].replace(/\s+/g, ''),
      });
    }
    const after = context.shipsTurkic ? plainCase?.exec(code.slice(end + 1, end + 80)) : undefined;
    if (after) {
      add({
        rule: 'TRI003',
        line: lineOf(end),
        message: `Translated text is changed with ${after[0].trim().replace(/^\.\s*/, '')}, which ignores the locale; Turkish and Azerbaijani need İ and ı`,
        subject: after[0].replace(/\s+/g, ''),
      });
    }
  }
  if (language === 'dart' && context.shipsTurkic) {
    for (const match of code.matchAll(dartPlainCase(context.outputClasses))) {
      add({
        rule: 'TRI003',
        line: lineOf(match.index),
        message: `Translated text is changed with ${/to(?:Upper|Lower)Case/.exec(match[0])?.[0]}(), which ignores the locale; Turkish and Azerbaijani need İ and ı`,
        subject: match[0].replace(/\s+/g, ''),
      });
    }
  }
  return drafts.sort((a, b) => a.line - b.line);
}
