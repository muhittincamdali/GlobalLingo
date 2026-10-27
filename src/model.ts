// The data GlobalLingo works with: catalogs read from localization files, findings, and the report.

export type Severity = 'error' | 'warning' | 'info';

/** Where a catalog or a source file belongs. */
export type Ecosystem = 'apple' | 'flutter' | 'js';

/** The file format a catalog was read from. */
export type CatalogFormat = 'xcstrings' | 'strings' | 'arb' | 'json';

/**
 * How placeholders and plurals are written in a catalog's messages: printf-style format
 * specifiers (Apple), ICU MessageFormat (Flutter ARB, react-intl/FormatJS), i18next's
 * `{{name}}` interpolation, or i18n-js's `%{name}`.
 */
export type MessageSyntax = 'printf' | 'icu' | 'i18next' | 'i18n-js';

export type TranslationState = 'translated' | 'new' | 'needs_review' | 'stale';

/** One text of a translation: the whole value, or one variant of it (a plural form, a device). */
export interface MessageText {
  text: string;
  /** Variant path such as `plural.one` or `device.iphone`; empty for a plain value. */
  path: string;
  line: number;
  /** printf only: the format specifier each `%#@name@` substitution stands for. */
  substitutions?: Record<string, { argNum: number; specifier: string }>;
}

/** A set of plural forms for one variable (or the whole value) in one translation. */
export interface PluralForms {
  /** The variable the forms belong to: an ICU argument, a stringsdict variable, or `value`. */
  name: string;
  type: 'cardinal' | 'ordinal';
  categories: string[];
  line: number;
}

/** A key's value in one locale. */
export interface Translation {
  locale: string;
  file: string;
  line: number;
  texts: MessageText[];
  plurals: PluralForms[];
  state?: TranslationState;
  /** A syntax error in the message, when the syntax has one (ICU). */
  syntaxError?: string;
}

export interface CatalogEntry {
  key: string;
  /** Translations by locale. */
  translations: Map<string, Translation>;
  /** String Catalog: Xcode no longer finds the key in the source code. */
  stale?: boolean;
  /** String Catalog: "Don't translate". */
  doNotTranslate?: boolean;
  /** String Catalog: the key itself is the source text when the source locale has no value. */
  keyIsSource?: boolean;
}

export interface DuplicateKey {
  file: string;
  key: string;
  line: number;
  firstLine: number;
}

export interface CatalogProblem {
  file: string;
  line: number;
  message: string;
}

export interface Catalog {
  /** Stable identifier: the file, or the folder and table for a set of files. */
  id: string;
  /** Short name for reports: the table, the ARB prefix or the namespace. */
  name: string;
  format: CatalogFormat;
  syntax: MessageSyntax;
  ecosystem: Ecosystem;
  sourceLocale: string;
  /** Every locale the catalog has, the source locale first. */
  locales: string[];
  /** The file of each locale (a String Catalog has one file for all of them). */
  files: Map<string, string>;
  entries: Map<string, CatalogEntry>;
  duplicates: DuplicateKey[];
  /** Files that could not be read or parsed. */
  problems: CatalogProblem[];
  /** Things skipped while reading, for the report's notes. */
  notes?: string[];
  /** Flutter: the generated class (`output-class` in l10n.yaml). */
  outputClass?: string;
  /** ICU: whether apostrophes quote text (FormatJS always; Flutter with `use-escaping`). */
  apostropheQuoting?: boolean;
}

/** A rule identifier; see `RULES` for what each one checks. */
export type RuleId =
  | 'MIS001'
  | 'MIS002'
  | 'MIS003'
  | 'MIS004'
  | 'STA001'
  | 'STA002'
  | 'FMT001'
  | 'FMT002'
  | 'FMT003'
  | 'PLU001'
  | 'PLU002'
  | 'DUP001'
  | 'KEY001'
  | 'KEY002'
  | 'HCS001'
  | 'TRI001'
  | 'TRI002'
  | 'TRI003';

export interface Finding {
  rule: RuleId;
  severity: Severity;
  /** Path relative to the checked folder, with `/` separators. */
  file: string;
  /** 1-based; 0 when the finding is about a whole file. */
  line: number;
  column?: number;
  key?: string;
  locale?: string;
  message: string;
  /** What to change, for this finding's ecosystem. */
  fix: string;
  /** The rule's documentation. */
  docs: string;
  /** Stable across runs and line moves; what a baseline file stores. */
  fingerprint: string;
  /** In the baseline file: reported, but does not count for the exit code. */
  baselined?: boolean;
}

export interface LocaleCoverage {
  locale: string;
  /** Keys with a usable translation (not missing, empty, or untranslated). */
  translated: number;
  total: number;
}

export interface CatalogSummary {
  id: string;
  name: string;
  format: CatalogFormat;
  syntax: MessageSyntax;
  sourceLocale: string;
  locales: string[];
  keys: number;
  coverage: LocaleCoverage[];
}

export interface Report {
  /** Version of the JSON layout. */
  schemaVersion: 1;
  tool: { name: 'globallingo'; version: string };
  /** The folder as given on the command line (or to `scan`). */
  path: string;
  ecosystems: Ecosystem[];
  catalogs: CatalogSummary[];
  /** Number of Swift, Objective-C, Dart and JavaScript/TypeScript files read. */
  sourceFiles: number;
  findings: Finding[];
  /** Things the reader should know: files skipped, assumptions made. */
  notes: string[];
  summary: { error: number; warning: number; info: number; baselined: number };
}
