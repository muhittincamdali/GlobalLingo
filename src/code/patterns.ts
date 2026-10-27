// What GlobalLingo looks for in source code, per language. Every pattern runs over code whose
// comments are blanked (lexer.ts); string literals are matched with their escapes. These are
// patterns, not a parser: they cover the common ways each ecosystem looks up and shows text.

/** A double-quoted literal; group 1 is its body. */
export const DQ = '"((?:[^"\\\\\\n]|\\\\.)*)"';
/** A single- or double-quoted literal; group 1 is the quote, group 2 the body. */
export const SQ_OR_DQ = '([\'"])((?:(?!\\1)[^\\\\\\n]|\\\\.)*)\\1';

export interface LookupPattern {
  /** Matches the start of the call; group `key` is the literal key when there is one. */
  regex: RegExp;
  /** For Apple lookups: the argument naming the table. */
  tableArgument?: RegExp;
}

// Apple: explicit lookups. The key literal must be the whole first argument.
export const SWIFT_LOOKUPS: LookupPattern[] = [
  {
    regex: new RegExp(`\\bNSLocalizedString\\s*\\(\\s*${DQ}(?=\\s*[,)])`, 'g'),
    tableArgument: new RegExp(`\\btableName:\\s*${DQ}`),
  },
  {
    regex: new RegExp(`\\bString\\s*\\(\\s*localized:\\s*${DQ}(?=\\s*[,)])`, 'g'),
    tableArgument: new RegExp(`\\btable:\\s*${DQ}`),
  },
  {
    regex: new RegExp(`\\bLocalizedStringResource\\s*\\(\\s*${DQ}(?=\\s*[,)])`, 'g'),
    tableArgument: new RegExp(`\\btable:\\s*${DQ}`),
  },
  {
    regex: new RegExp(`\\.localizedString\\s*\\(\\s*forKey:\\s*${DQ}(?=\\s*[,)])`, 'g'),
    tableArgument: new RegExp(`\\btable:\\s*${DQ}`),
  },
];

export const OBJC_LOOKUPS: LookupPattern[] = [
  { regex: new RegExp(`\\bNSLocalizedString\\s*\\(\\s*@${DQ}(?=\\s*[,)])`, 'g') },
  {
    regex: new RegExp(`\\bNSLocalizedStringFromTable\\s*\\(\\s*@${DQ}(?=\\s*,)`, 'g'),
    tableArgument: new RegExp(`^[^,]*,\\s*@${DQ}`),
  },
];

/** SwiftUI views and modifiers whose string literal is a LocalizedStringKey. */
export const SWIFTUI_TEXT = new RegExp(
  `(?<![\\w.])(?:Text|Button|Label|Toggle|TextField|SecureField|Picker|Link|Menu|NavigationLink|Section|Stepper|LabeledContent|GroupBox|DisclosureGroup)\\s*\\(\\s*${DQ}|\\.(?:navigationTitle|navigationSubtitle|alert|confirmationDialog|help)\\s*\\(\\s*${DQ}`,
  'g',
);

/** Calls whose arguments are a lookup key (for TRI001) and whose result is translated text (TRI003). */
export const SWIFT_LOOKUP_CALLS =
  /\b(?:NSLocalizedString\s*\(|String\s*\(\s*localized:|\.localizedString\s*\(\s*forKey:)/g;
export const OBJC_LOOKUP_CALLS = /\bNSLocalizedString(?:FromTable)?\s*\(/g;
export const JS_LOOKUP_CALLS = /(?<![\w$])(?:[A-Za-z_$][\w$]*\.)*t\s*\(|\bformatMessage\s*\(/g;

/** Case changes that use the device locale. */
export const SWIFT_LOCALE_CASE =
  /\.localized(?:Lowercase|Uppercase|Capitalized)\b|\.(?:lowercased|uppercased|capitalized)\s*\(\s*with:\s*(?:\.current|\.autoupdatingCurrent|Locale\.current|Locale\.autoupdatingCurrent)\b/;
export const OBJC_LOCALE_CASE =
  /\blocalized(?:Lowercase|Uppercase|Capitalized)String\b|\b(?:lowercase|uppercase|capitalized)StringWithLocale:\s*\[NSLocale\s+(?:currentLocale|autoupdatingCurrentLocale)\]/;
export const JS_LOCALE_CASE = /\.toLocale(?:Lower|Upper)Case\s*\(\s*\)/;

/** Case changes that ignore the locale, right after a lookup. */
export const SWIFT_PLAIN_CASE_AFTER =
  /^\s*\.\s*(?:(?:uppercased|lowercased)\s*\(\s*\)|capitalized\b(?!\s*\())/;
export const JS_PLAIN_CASE_AFTER = /^\s*\.\s*to(?:Upper|Lower)Case\s*\(\s*\)/;

/** Dart: a message of the generated localizations class, then toUpperCase() or toLowerCase(). */
export function dartPlainCase(outputClasses: readonly string[]): RegExp {
  const classes = [...new Set(['AppLocalizations', 'S', ...outputClasses])].map((name) =>
    name.replace(/[^\w]/g, ''),
  );
  const receiver = `(?:(?:${classes.join('|')})\\.of\\(\\s*context\\s*\\)!?|S\\.current|context\\.l10n|\\bl10n|\\bloc|\\blocalizations)`;
  return new RegExp(
    `${receiver}\\s*\\.\\s*\\w+(?:\\([^()\\n]*\\))?\\s*\\.\\s*to(?:Upper|Lower)Case\\s*\\(\\s*\\)`,
    'g',
  );
}

// JavaScript lookups with a literal key.
export const JS_KEY_LOOKUPS: RegExp[] = [
  new RegExp(`(?<![\\w$])(?:[A-Za-z_$][\\w$]*\\.)*t\\s*\\(\\s*${SQ_OR_DQ}(?=\\s*[,)])`, 'g'),
  new RegExp(`<Trans\\b[^>]*?\\bi18nKey=(?:\\{\\s*)?${SQ_OR_DQ}`, 'g'),
  new RegExp(`\\bformatMessage\\s*\\(\\s*\\{\\s*id:\\s*${SQ_OR_DQ}`, 'g'),
  new RegExp(`<FormattedMessage\\b[^>]*?\\bid=(?:\\{\\s*)?${SQ_OR_DQ}`, 'g'),
];

// Hard-coded UI text. Group `text` (named) holds the literal body.
export const SWIFT_HARDCODED: RegExp[] = [
  new RegExp(
    `\\.(?:text|title|placeholder|accessibilityLabel|accessibilityHint|prompt)\\s*=\\s*${DQ}`,
    'g',
  ),
  new RegExp(`\\bsetTitle\\s*\\(\\s*${DQ}\\s*,\\s*for:`, 'g'),
  new RegExp(
    `\\b(?:UIAlertController|UIAlertAction|UIBarButtonItem)\\s*\\(\\s*title:\\s*${DQ}`,
    'g',
  ),
  new RegExp(`\\bUIAlertController\\s*\\([^()\\n]*?message:\\s*${DQ}`, 'g'),
];

export const OBJC_HARDCODED: RegExp[] = [
  new RegExp(`\\.(?:text|title|placeholder|accessibilityLabel)\\s*=\\s*@${DQ}`, 'g'),
  new RegExp(`\\bsetTitle:\\s*@${DQ}`, 'g'),
  new RegExp(`\\balertControllerWithTitle:\\s*@${DQ}`, 'g'),
];

export const DART_HARDCODED: RegExp[] = [
  new RegExp(`(?<![\\w.])Text\\s*\\(\\s*${SQ_OR_DQ}`, 'g'),
  new RegExp(
    `\\b(?:hintText|labelText|helperText|errorText|counterText|prefixText|suffixText|tooltip|semanticLabel|semanticsLabel|label|title|message|text)\\s*:\\s*${SQ_OR_DQ}`,
    'g',
  ),
];

export const JS_HARDCODED: RegExp[] = [
  /<(?:Text|Animated\.Text)\b[^<>]*>([^<>{}]*\p{L}[^<>{}]*)</gu,
  new RegExp(
    `\\b(?:title|placeholder|accessibilityLabel|accessibilityHint|headerTitle|tabBarLabel|headerBackTitle)=${SQ_OR_DQ}`,
    'g',
  ),
  new RegExp(`\\b(?:headerTitle|tabBarLabel|headerBackTitle)\\s*:\\s*${SQ_OR_DQ}`, 'g'),
  new RegExp(`\\bAlert\\.alert\\s*\\(\\s*${SQ_OR_DQ}`, 'g'),
];

/** Test, preview, story and generated files, where hard-coded text is expected. */
export const NOT_APP_CODE =
  /(^|\/)(?:test|tests|Tests|__tests__|__mocks__|spec|e2e|integration_test|test_driver|generated|Generated)(\/|$)|[^/]*Tests?\/|\.(?:test|spec|stories)\.[cm]?[jt]sx?$|Tests?\.swift$|\.g\.dart$|\.freezed\.dart$|(^|\/)app_localizations[\w]*\.dart$|\.d\.ts$|\.min\.js$/;
