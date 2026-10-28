// Placeholders of the JSON catalogs that do not use ICU:
// - i18next: `{{name}}`, `{{name, format}}`, `{{- name}}` (unescaped), and `$t(key)` nesting.
//   https://www.i18next.com/translation-function/interpolation
// - i18n-js: `%{name}` and `{{name}}`. https://github.com/fnando/i18n

/**
 * Names of the `{{…}}` placeholders in an i18next value, in order of appearance. The space after
 * `-` is matched only after a `-`: `\s*-?\s*` could split a long run of spaces in every way.
 */
export function i18nextPlaceholders(text: string): string[] {
  const names: string[] = [];
  for (const match of text.matchAll(/\{\{\s*(?:-\s*)?([^{}\s,]+)\s*(?:,[^{}]*)?\}\}/g)) {
    names.push(match[1] as string);
  }
  return names;
}

/** Keys referenced with `$t(key)` or `$t(key, {…})` in an i18next value. */
export function i18nextNesting(text: string): string[] {
  return [...text.matchAll(/\$t\(\s*([^,)\s]+)/g)].map((match) => match[1] as string);
}

/** Names of the `%{name}` and `{{name}}` placeholders in an i18n-js value. */
export function i18nJsPlaceholders(text: string): string[] {
  return [...text.matchAll(/%\{\s*([^{}\s]+)\s*\}|\{\{\s*([^{}\s]+)\s*\}\}/g)].map(
    (match) => (match[1] ?? match[2]) as string,
  );
}
