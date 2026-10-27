// Text helpers shared by the reports.
import type { CatalogFormat, MessageSyntax, Report } from '../model.js';

/**
 * Makes text from the checked project safe to print: control characters (C0 except tab and
 * newline, DEL, C1) and the bidirectional overrides and isolates that can reorder what a terminal
 * or a code review shows (CVE-2021-42574, "Trojan Source") are written as `\u{…}`. Translations
 * keep their right-to-left text; only the invisible controls are made visible.
 */
export function clean(text: string): string {
  return text.replace(
    // biome-ignore lint/suspicious/noControlCharactersInRegex: matching control characters is the point.
    /[\u0000-\u0008\u000B-\u001F\u007F-\u009F\u202A-\u202E\u2066-\u2069]/g,
    escapeChar,
  );
}

/**
 * clean() for text that has to stay on one line: a file name, key or message in a terminal line or
 * a Markdown table cell. Tabs, line feeds and the line and paragraph separators are escaped too,
 * so a file named "a\n| row |" cannot start a line of its own.
 */
export function cleanLine(text: string): string {
  return clean(text).replace(/[\t\n\u2028\u2029]/g, escapeChar);
}

const escapeChar = (char: string) =>
  `\\u{${(char.codePointAt(0) as number).toString(16).toUpperCase().padStart(4, '0')}}`;

/** A copy of a value with every string passed through clean(). */
export function cleaned<T>(value: T): T {
  if (typeof value === 'string') return clean(value) as T;
  if (Array.isArray(value)) return value.map(cleaned) as T;
  if (value === null || typeof value !== 'object') return value;
  return Object.fromEntries(Object.entries(value).map(([key, item]) => [key, cleaned(item)])) as T;
}

/** Splits text into lines of at most `width` columns (a longer word gets a line of its own). */
export function wrap(text: string, width: number): string[] {
  const lines: string[] = [];
  let line = '';
  for (const word of text.split(/[ \t]+/).filter(Boolean)) {
    if (line && line.length + 1 + word.length > width) {
      lines.push(line);
      line = word;
    } else {
      line = line ? `${line} ${word}` : word;
    }
  }
  if (line) lines.push(line);
  return lines;
}

export const plural = (count: number, word: string) => `${count} ${word}${count === 1 ? '' : 's'}`;

export const FORMAT_LABELS: Record<CatalogFormat, string> = {
  xcstrings: 'String Catalog',
  strings: 'strings table',
  arb: 'ARB',
  json: 'JSON',
};

export const SYNTAX_LABELS: Record<MessageSyntax, string> = {
  printf: 'format specifiers',
  icu: 'ICU',
  i18next: 'i18next',
  'i18n-js': 'i18n-js',
};

export const percent = (translated: number, total: number) =>
  total === 0 ? '100%' : `${Math.floor((translated / total) * 100)}%`;

/** "2 errors, 5 warnings and 1 info finding", or "No findings". */
export function summaryLine(report: Report): string {
  const { error, warning, info, baselined } = report.summary;
  const parts = [
    error ? plural(error, 'error') : '',
    warning ? plural(warning, 'warning') : '',
    info ? `${info} info` : '',
  ].filter(Boolean);
  const head = parts.length === 0 ? 'No findings' : parts.join(', ');
  const tail = baselined ? ` (${baselined} more in the baseline)` : '';
  return `${head} in ${plural(report.catalogs.length, 'catalog')} and ${plural(report.sourceFiles, 'source file')}${tail}`;
}
