// CLDR plural categories, from the Unicode CLDR data built into Node.js (Intl.PluralRules), so
// the categories match what i18next and FormatJS select at run time with the same data.
// https://cldr.unicode.org/index/cldr-spec/plural-rules

export type PluralType = 'cardinal' | 'ordinal';

/** Canonical BCP 47 tag for a locale written as in .lproj folders or ARB files (`pt_BR`). */
export function toLanguageTag(locale: string): string | undefined {
  const candidate = locale.replace(/_/g, '-');
  try {
    const [tag] = Intl.getCanonicalLocales(candidate);
    return tag;
  } catch {
    return undefined;
  }
}

const cache = new Map<string, readonly string[] | undefined>();

/**
 * The plural categories a locale uses, in CLDR order, or undefined when CLDR has no rules for
 * it (`Base`, `mul`, an unknown code).
 */
export function pluralCategories(
  locale: string,
  type: PluralType = 'cardinal',
): readonly string[] | undefined {
  const cacheKey = `${type}:${locale}`;
  if (cache.has(cacheKey)) return cache.get(cacheKey);
  const tag = toLanguageTag(locale);
  let categories: readonly string[] | undefined;
  if (tag && Intl.PluralRules.supportedLocalesOf([tag]).length > 0) {
    const found = new Intl.PluralRules(tag, { type }).resolvedOptions().pluralCategories;
    const order = ['zero', 'one', 'two', 'few', 'many', 'other'];
    categories = [...found].sort((a, b) => order.indexOf(a) - order.indexOf(b));
  }
  cache.set(cacheKey, categories);
  return categories;
}

const SAMPLES = [0, 1, 2, 3, 4, 5, 6, 7, 10, 11, 12, 13, 15, 20, 21, 22, 25, 100, 101, 1000000];

/** Up to three numbers that select `category` in `locale`, to show in a message. */
export function pluralExamples(
  locale: string,
  category: string,
  type: PluralType = 'cardinal',
): number[] {
  const tag = toLanguageTag(locale);
  if (!tag) return [];
  const rules = new Intl.PluralRules(tag, { type });
  return SAMPLES.filter((sample) => rules.select(sample) === category).slice(0, 3);
}

/** A locale for which every catalog format falls back to the key or the source text. */
export const isPseudoLocale = (locale: string): boolean => /^(base|mul|und)$/i.test(locale);

/**
 * Whether two locales are the same language (`en` and `en-GB`), where a translation equal to the
 * source text is expected.
 */
export function sameLanguage(a: string, b: string): boolean {
  const language = (locale: string) =>
    (toLanguageTag(locale) ?? locale).split('-')[0]?.toLowerCase();
  return language(a) === language(b);
}

/** Turkish and Azerbaijani: the languages with dotted and dotless I in Unicode's special casing. */
export const isTurkic = (locale: string): boolean => /^(tr|az)\b/i.test(locale.replace(/_/g, '-'));
