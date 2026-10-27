// The checks that need only the catalogs: missing, empty, untranslated, stale and orphan keys,
// placeholders, plural forms, duplicates and dotted or dotless I in keys.
import type { Catalog, CatalogEntry, LocaleCoverage, MessageText, Translation } from '../model.js';
import { parsePrintf } from '../messages/printf.js';
import {
  isPseudoLocale,
  pluralCategories,
  pluralExamples,
  sameLanguage,
  toLanguageTag,
} from '../plural.js';
import { type Draft, quote } from './draft.js';
import { KIND_NAMES, type Signature, type Slot, signature } from './placeholders.js';

export interface CatalogCheckOptions {
  /** Target locales from the configuration; by default every locale the catalog has. */
  locales?: string[];
  /** Keys to leave out (from the configuration). */
  ignoreKey: (key: string) => boolean;
  /** Stop adding findings after this many; a crafted catalog cannot fill the memory. */
  limit?: number;
}

export interface CatalogCheckResult {
  drafts: Draft[];
  coverage: LocaleCoverage[];
  keys: number;
  /** Whether findings were left out because of `limit`. */
  truncated: boolean;
}

const displayNames = new Intl.DisplayNames(['en'], { type: 'language', fallback: 'none' });

/** "German (de)", or the code alone when it has no English name. */
export function localeLabel(locale: string): string {
  const tag = toLanguageTag(locale);
  let name: string | undefined;
  try {
    name = tag ? displayNames.of(tag) : undefined;
  } catch {
    name = undefined;
  }
  return name ? `${name} (${locale})` : locale;
}

const normalize = (locale: string) => (toLanguageTag(locale) ?? locale).toLowerCase();

/** The source text a translated text is compared with: same variant, else "other", else the first. */
function counterpart(source: Translation, path: string): MessageText | undefined {
  const exact = source.texts.find((text) => text.path === path);
  if (exact) return exact;
  const other = path.replace(/[^.]+$/, 'other');
  return (
    source.texts.find((text) => text.path === other) ??
    source.texts.find((text) => text.path === '') ??
    source.texts.find((text) => text.path.endsWith('.other')) ??
    source.texts[0]
  );
}

/** Plural forms that leave out the number on purpose ("one file", "two files" as words). */
const mayDropPlaceholders = (path: string) => /(^|\.)(zero|one|two)$/.test(path);

const hasLetters = (text: string) => (text.match(/\p{L}/gu)?.length ?? 0) >= 3;

class Checker {
  readonly drafts: Draft[] = [];
  truncated = false;
  private readonly seen = new Set<string>();

  constructor(
    private readonly catalog: Catalog,
    private readonly limit: number,
  ) {}

  add(draft: Omit<Draft, 'ecosystem'>): void {
    if (this.drafts.length >= this.limit) {
      this.truncated = true;
      return;
    }
    const id = `${draft.rule}|${draft.file}|${draft.key ?? ''}|${draft.locale ?? ''}|${draft.subject}`;
    if (this.seen.has(id)) return;
    this.seen.add(id);
    this.drafts.push({ ...draft, ecosystem: this.catalog.ecosystem });
  }

  signatureOf(text: MessageText): Signature {
    return signature(text, this.catalog.syntax, this.catalog.apostropheQuoting ?? true);
  }

  syntax(entry: CatalogEntry, translation: Translation): void {
    if (translation.syntaxError) {
      this.add({
        rule: 'FMT003',
        file: translation.file,
        line: translation.line,
        key: entry.key,
        locale: translation.locale,
        message: `${quote(entry.key)} in ${localeLabel(translation.locale)} is not a valid ICU message: ${translation.syntaxError}`,
        subject: 'icu',
      });
    }
    if (this.catalog.syntax !== 'printf') return;
    for (const text of translation.texts) {
      for (const invalid of parsePrintf(text.text.replace(/%arg\b/g, '')).invalid) {
        this.add({
          rule: 'FMT003',
          file: translation.file,
          line: text.line,
          key: entry.key,
          locale: translation.locale,
          message: `${quote(entry.key)} in ${localeLabel(translation.locale)} has "${invalid}", which is not a format specifier; write %% for a percent sign`,
          subject: invalid,
        });
      }
    }
  }

  placeholders(entry: CatalogEntry, source: Translation, target: Translation): void {
    const union = new Map<string, Slot>();
    for (const text of source.texts) {
      for (const slot of this.signatureOf(text).slots.values()) {
        if (!union.has(slot.id)) union.set(slot.id, slot);
      }
    }
    const used = new Set<string>();
    for (const text of target.texts) {
      const own = this.signatureOf(text);
      for (const id of own.slots.keys()) used.add(id);
      const where = `${quote(entry.key)} in ${localeLabel(target.locale)}${text.path ? ` (${text.path})` : ''}`;
      for (const slot of own.slots.values()) {
        const known = union.get(slot.id);
        if (!known) {
          this.add({
            rule: 'FMT001',
            file: target.file,
            line: text.line,
            key: entry.key,
            locale: target.locale,
            message: `${where} uses ${slot.raw}, which the source text does not have`,
            subject: `extra:${slot.id}`,
          });
        } else if (known.kind !== slot.kind) {
          this.add({
            rule: 'FMT001',
            file: target.file,
            line: text.line,
            key: entry.key,
            locale: target.locale,
            message: `${where} uses ${slot.raw} (${KIND_NAMES[slot.kind] ?? slot.kind}) for argument ${slot.id}; the source text has ${known.raw} (${KIND_NAMES[known.kind] ?? known.kind})`,
            subject: `type:${slot.id}:${slot.kind}`,
          });
        }
      }
      // Named placeholders: each text against its own source variant, so a plural form for one
      // item may leave out the count.
      if (this.catalog.syntax === 'printf' || mayDropPlaceholders(text.path)) continue;
      const reference = counterpart(source, text.path);
      for (const slot of reference ? this.signatureOf(reference).slots.values() : []) {
        if (own.slots.has(slot.id)) continue;
        this.add({
          rule: 'FMT002',
          file: target.file,
          line: text.line,
          key: entry.key,
          locale: target.locale,
          message: `${where} leaves out ${slot.raw} of the source text`,
          subject: `missing:${slot.id}`,
        });
      }
    }
    // Format specifiers: plural variants are substituted into the format string, so an argument
    // counts as used when any text of the translation uses it.
    if (this.catalog.syntax !== 'printf') return;
    for (const slot of union.values()) {
      if (used.has(slot.id)) continue;
      this.add({
        rule: 'FMT002',
        file: target.file,
        line: target.texts[0]?.line ?? target.line,
        key: entry.key,
        locale: target.locale,
        message: `${quote(entry.key)} in ${localeLabel(target.locale)} leaves out ${slot.raw} of the source text`,
        subject: `missing:${slot.id}`,
      });
    }
  }

  plurals(entry: CatalogEntry, translation: Translation, source: Translation | undefined): void {
    const where = `${quote(entry.key)} in ${localeLabel(translation.locale)}`;
    for (const forms of translation.plurals) {
      if (!forms.categories.includes('other')) {
        this.add({
          rule: 'PLU002',
          file: translation.file,
          line: forms.line,
          key: entry.key,
          locale: translation.locale,
          message: `${where} has plural forms for ${forms.categories.join(', ') || 'nothing'} but no "other"`,
          subject: `other:${forms.name}`,
        });
      }
      this.missingCategories(
        entry,
        translation,
        forms.name,
        forms.type,
        forms.categories,
        forms.line,
      );
    }
    // The source varies by plural but this translation does not.
    for (const forms of source && source !== translation ? source.plurals : []) {
      if (translation.plurals.some((own) => own.name === forms.name)) continue;
      // Apple formats name plural variables freely; any plural in the translation answers this.
      if (this.catalog.syntax === 'printf' && translation.plurals.length > 0) continue;
      this.missingCategories(
        entry,
        translation,
        forms.name,
        forms.type,
        ['other'],
        translation.line,
      );
    }
  }

  private missingCategories(
    entry: CatalogEntry,
    translation: Translation,
    name: string,
    type: 'cardinal' | 'ordinal',
    present: string[],
    line: number,
  ): void {
    const required = pluralCategories(translation.locale, type);
    if (!required) return;
    // A missing "other" is PLU002's finding.
    const missing = required.filter(
      (category) => !present.includes(category) && (category !== 'other' || present.length === 0),
    );
    if (missing.length === 0) return;
    const examples = missing
      .map((category) => {
        const numbers = pluralExamples(translation.locale, category, type);
        return numbers.length > 0 ? `${category} (e.g. ${numbers.join(', ')})` : category;
      })
      .join(', ');
    const variable = name === 'value' || name === 'count' ? '' : ` for "${name}"`;
    this.add({
      rule: 'PLU001',
      file: translation.file,
      line,
      key: entry.key,
      locale: translation.locale,
      message: `${quote(entry.key)} in ${localeLabel(translation.locale)} has no ${type === 'ordinal' ? 'ordinal ' : ''}plural form${missing.length > 1 ? 's' : ''}${variable} for ${examples}`,
      subject: `${name}:${missing.join(',')}`,
    });
  }
}

const isEmpty = (translation: Translation) =>
  translation.texts.length > 0 && translation.texts.every((text) => text.text.trim() === '');

function targetsOf(catalog: Catalog, options: CatalogCheckOptions): string[] {
  const own = [...new Set([...catalog.locales, ...(catalog.expectedLocales ?? [])])].filter(
    (locale) => locale !== catalog.sourceLocale && !isPseudoLocale(locale),
  );
  if (!options.locales || options.locales.length === 0) return own.sort();
  return options.locales.map(
    (wanted) => own.find((locale) => normalize(locale) === normalize(wanted)) ?? wanted,
  );
}

export function checkCatalog(catalog: Catalog, options: CatalogCheckOptions): CatalogCheckResult {
  const check = new Checker(catalog, options.limit ?? Number.POSITIVE_INFINITY);
  const sourceFile = catalog.files.get(catalog.sourceLocale) ?? catalog.id;

  for (const problem of catalog.problems) {
    check.add({
      rule: 'FMT003',
      file: problem.file,
      line: problem.line,
      message: `${problem.file} could not be read: ${problem.message}`,
      subject: 'file',
    });
  }
  for (const duplicate of catalog.duplicates) {
    check.add({
      rule: 'DUP001',
      file: duplicate.file,
      line: duplicate.line,
      key: duplicate.key,
      message: `${quote(duplicate.key)} appears again (first on line ${duplicate.firstLine}); only one of the two values is used`,
      subject: `duplicate:${duplicate.firstLine}`,
    });
  }

  const targets = targetsOf(catalog, options);
  for (const locale of targets) {
    if (catalog.files.has(locale)) continue;
    check.add({
      rule: 'MIS001',
      file: sourceFile,
      line: 0,
      locale,
      message: options.locales?.length
        ? `${catalog.name} has no ${localeLabel(locale)} file, but the configuration lists the locale`
        : `${catalog.name} has no ${localeLabel(locale)} file, but other files next to it have the locale`,
      subject: 'locale',
    });
  }

  const counts = new Map<string, number>(targets.map((locale) => [locale, 0]));
  let total = 0;
  for (const entry of catalog.entries.values()) {
    if (options.ignoreKey(entry.key)) continue;
    const source = entry.translations.get(catalog.sourceLocale);
    if (!source) {
      if (!catalog.files.has(catalog.sourceLocale)) continue;
      for (const translation of entry.translations.values()) {
        check.add({
          rule: 'STA002',
          file: translation.file,
          line: translation.line,
          key: entry.key,
          locale: translation.locale,
          message: `${quote(entry.key)} is in ${localeLabel(translation.locale)} but not in the source language ${localeLabel(catalog.sourceLocale)}`,
          subject: 'orphan',
        });
      }
      continue;
    }
    if (/[İı]/u.test(entry.key)) {
      check.add({
        rule: 'TRI002',
        file: source.file,
        line: source.line,
        key: entry.key,
        message: `The key ${quote(entry.key)} contains ${entry.key.includes('İ') ? '"İ"' : '"ı"'}; a case change of the key does not give it back`,
        subject: 'key',
      });
    }
    check.syntax(entry, source);
    if (entry.stale) {
      check.add({
        rule: 'STA001',
        file: source.file,
        line: source.line,
        key: entry.key,
        message: `${quote(entry.key)} is stale: Xcode no longer finds it in the source code`,
        subject: 'stale',
      });
      continue;
    }
    if (entry.doNotTranslate) continue;
    check.plurals(entry, source, undefined);
    total += 1;
    for (const locale of targets) {
      const translation = entry.translations.get(locale);
      if (!translation) {
        check.add({
          rule: 'MIS001',
          file: catalog.files.get(locale) ?? sourceFile,
          line: catalog.format === 'xcstrings' ? source.line : 0,
          key: entry.key,
          locale,
          message: `${quote(entry.key)} has no ${localeLabel(locale)} translation`,
          subject: 'missing',
        });
        continue;
      }
      check.syntax(entry, translation);
      if (translation.state === 'new') {
        check.add({
          rule: 'MIS001',
          file: translation.file,
          line: translation.line,
          key: entry.key,
          locale,
          message: `${quote(entry.key)} is not translated into ${localeLabel(locale)} yet (state "new")`,
          subject: 'missing',
        });
        continue;
      }
      if (isEmpty(translation) && !isEmpty(source)) {
        check.add({
          rule: 'MIS002',
          file: translation.file,
          line: translation.line,
          key: entry.key,
          locale,
          message: `${quote(entry.key)} has an empty ${localeLabel(locale)} translation`,
          subject: 'empty',
        });
        continue;
      }
      counts.set(locale, (counts.get(locale) ?? 0) + 1);
      if (translation.state === 'needs_review' || translation.state === 'stale') {
        check.add({
          rule: 'MIS003',
          file: translation.file,
          line: translation.line,
          key: entry.key,
          locale,
          message: `The ${localeLabel(locale)} translation of ${quote(entry.key)} is marked as needing review`,
          subject: 'review',
        });
      }
      const identical =
        !sameLanguage(locale, catalog.sourceLocale) &&
        translation.texts.length > 0 &&
        translation.texts.every((text) => {
          const reference = counterpart(source, text.path);
          return reference !== undefined && reference.text === text.text && hasLetters(text.text);
        });
      if (identical) {
        check.add({
          rule: 'MIS004',
          file: translation.file,
          line: translation.line,
          key: entry.key,
          locale,
          message: `The ${localeLabel(locale)} translation of ${quote(entry.key)} is the same as the source text`,
          subject: 'identical',
        });
      }
      // A message that does not parse has its own finding; comparing it would only add noise.
      if (translation.syntaxError || source.syntaxError) continue;
      check.placeholders(entry, source, translation);
      check.plurals(entry, translation, source);
    }
  }
  return {
    drafts: check.drafts,
    truncated: check.truncated,
    keys: total,
    coverage: targets.map((locale) => ({ locale, translated: counts.get(locale) ?? 0, total })),
  };
}
