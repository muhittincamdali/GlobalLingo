// What each rule checks, its default severity and how to fix a finding in each ecosystem. The
// long form of every rule, with sources, is docs/rules.md.
import type { Ecosystem, RuleId, Severity } from '../model.js';
import { DOCS_BRANCH, REPOSITORY_URL } from '../version.js';

export interface Rule {
  id: RuleId;
  severity: Severity;
  title: string;
  /** One sentence: what the rule finds and why it matters. */
  summary: string;
  /** How to fix a finding, per ecosystem. */
  fix: Record<Ecosystem, string>;
}

const same = (text: string): Record<Ecosystem, string> => ({
  apple: text,
  flutter: text,
  js: text,
});

export const RULES: Record<RuleId, Rule> = {
  MIS001: {
    id: 'MIS001',
    severity: 'error',
    title: 'Missing translation',
    summary:
      'A key of the source language has no translation in a locale the catalog has, so users of that locale see the fallback text or the key.',
    fix: {
      apple:
        "Translate the key for this locale in Xcode's String Catalog editor, or add it to the locale's .strings file.",
      flutter:
        "Add the key to this locale's ARB file. Until then gen_l10n uses the template's message for it.",
      js: "Add the key to this locale's translation file. Until then the library shows the fallback language or the key.",
    },
  },
  MIS002: {
    id: 'MIS002',
    severity: 'error',
    title: 'Empty translation',
    summary: 'The translation is an empty string, so the app shows nothing where the text belongs.',
    fix: same(
      'Write the translation, or remove the empty value so the fallback text is used until it is translated.',
    ),
  },
  MIS003: {
    id: 'MIS003',
    severity: 'warning',
    title: 'Needs review',
    summary:
      'The String Catalog marks the translation as needing review, usually because the source text changed after it was translated.',
    fix: same(
      'Check the translation against the current source text, correct it if needed, and mark it as reviewed in the String Catalog editor.',
    ),
  },
  MIS004: {
    id: 'MIS004',
    severity: 'info',
    title: 'Same as the source',
    summary:
      'The translation is identical to the source text, which often means it was copied and never translated.',
    fix: same(
      'Translate it, or ignore the key in .globallingo.json when the text is the same in both languages (brand names, "OK").',
    ),
  },
  STA001: {
    id: 'STA001',
    severity: 'warning',
    title: 'Stale key',
    summary:
      'Xcode marks the key as stale: it no longer finds the string in the source code, but the catalog still ships it.',
    fix: same(
      'Delete the key in the String Catalog editor (Remove Stale Strings), or mark it as manually managed if the code builds it at run time.',
    ),
  },
  STA002: {
    id: 'STA002',
    severity: 'warning',
    title: 'Key not in the source language',
    summary:
      'A locale has a key that the source language does not: a leftover after a rename or deletion, or a typo in the key.',
    fix: same(
      'Delete the key from this locale, or add it to the source language if the app uses it.',
    ),
  },
  FMT001: {
    id: 'FMT001',
    severity: 'error',
    title: 'Placeholder mismatch',
    summary:
      'The translation uses a placeholder the source does not have, or one of a different type; at run time this prints the wrong value, fails, or crashes.',
    fix: {
      apple:
        'Use the same format specifiers as the source text, with positions (%1$@, %2$lld) when the order changes.',
      flutter:
        'Use the placeholder names of the template message; every placeholder needs a declaration in the template\'s "@key" metadata.',
      js: 'Use the placeholder names of the source text exactly; the code passes values under those names only.',
    },
  },
  FMT002: {
    id: 'FMT002',
    severity: 'warning',
    title: 'Placeholder dropped',
    summary:
      'The translation leaves out a placeholder of the source text, so a value the user should see (a name, a count) is not shown.',
    fix: same(
      'Add the placeholder to the translation. Plural forms for one or two items may leave out the number on purpose; this rule does not report those.',
    ),
  },
  FMT003: {
    id: 'FMT003',
    severity: 'error',
    title: 'Invalid syntax',
    summary:
      'A file or a message is not valid in its syntax (broken JSON, an unbalanced brace in ICU, a broken format specifier), so loading, code generation or formatting fails.',
    fix: {
      apple:
        'Fix the syntax at that line (plutil -lint checks .strings and .stringsdict files); in a format string, write each specifier in full (%@, %lld, %.2f) and %% for a percent sign.',
      flutter:
        'Fix the JSON, balance the braces and use plural categories (zero, one, two, few, many, other) or =N. Turn on use-escaping in l10n.yaml to write literal braces as quoted text.',
      js: "Fix the JSON, balance the braces and use plural categories (zero, one, two, few, many, other) or =N; in ICU messages quote literal braces with apostrophes ('{').",
    },
  },
  PLU001: {
    id: 'PLU001',
    severity: 'warning',
    title: 'Missing plural form',
    summary:
      'The locale\'s CLDR plural rules have a category the translation does not cover; numbers in that category get the "other" form, which is grammatically wrong in that language.',
    fix: {
      apple:
        'In the String Catalog editor, add the missing plural form for this locale (Vary by Plural shows every category the language uses).',
      flutter: "Add the missing category to the plural in this locale's message, e.g. few{…}.",
      js: 'Add the missing category to this locale: key_few for i18next, a "few" entry for i18n-js, few{…} in ICU messages.',
    },
  },
  PLU002: {
    id: 'PLU002',
    severity: 'error',
    title: 'Plural without "other"',
    summary:
      'A plural has no "other" form, which every plural needs: it is the form used for any number no other category covers.',
    fix: same('Add an "other" form.'),
  },
  DUP001: {
    id: 'DUP001',
    severity: 'error',
    title: 'Duplicate key',
    summary:
      'The same key appears twice in one file; the tools keep one of the values without a warning, so the other translation is lost.',
    fix: same('Keep one of the two entries, with the right translation, and delete the other.'),
  },
  KEY001: {
    id: 'KEY001',
    severity: 'error',
    title: 'Unknown key',
    summary:
      'The code looks up a key that no catalog defines, so users see the raw key or the fallback text.',
    fix: {
      apple:
        'Add the key to the String Catalog or .strings table the lookup names, or correct the key in the code.',
      flutter: 'Add the key to the template ARB file, or correct it in the code.',
      js: 'Add the key to the source language file, or correct it in the code (namespaces are written ns:key).',
    },
  },
  KEY002: {
    id: 'KEY002',
    severity: 'warning',
    title: 'SwiftUI text not in the String Catalog',
    summary:
      'A SwiftUI view gets a string literal that the String Catalog of its table does not have, so it is not translated.',
    fix: {
      apple:
        'Build the target once so Xcode adds the string to the catalog (with "Use Compiler to Extract Swift Strings"), translate it, and commit the catalog. Use Text(verbatim:) for text that must not be translated.',
      flutter: 'Not used for Flutter.',
      js: 'Not used for JavaScript.',
    },
  },
  HCS001: {
    id: 'HCS001',
    severity: 'warning',
    title: 'Hard-coded UI text',
    summary:
      'Text shown to the user is written in the code instead of being looked up in a catalog, so it appears untranslated in every language.',
    fix: {
      apple:
        'Use String(localized:) or a localized SwiftUI initializer and add the string to the String Catalog.',
      flutter:
        'Add the text to the template ARB file and read it through the generated class, e.g. AppLocalizations.of(context)!.title.',
      js: "Add the text to the translation files and render it through the library, e.g. t('home.title').",
    },
  },
  TRI001: {
    id: 'TRI001',
    severity: 'warning',
    title: 'Locale-dependent case change on a key',
    summary:
      'A lookup key is upper- or lower-cased with the device locale. On a Turkish or Azerbaijani device "i" becomes "İ" and "I" becomes "ı", so the key no longer matches.',
    fix: {
      apple:
        'Use lowercased() or uppercased(), which do not depend on the locale, or no case change at all; keep keys in one case in the catalog.',
      flutter: 'Use toLowerCase() or toUpperCase(), which do not depend on the locale.',
      js: 'Use toLowerCase() or toUpperCase(), which do not depend on the locale, instead of toLocaleLowerCase() and toLocaleUpperCase() without a locale.',
    },
  },
  TRI002: {
    id: 'TRI002',
    severity: 'warning',
    title: 'Dotted or dotless I in a key',
    summary:
      'A key contains İ or ı. Case changes do not round-trip for these letters ("İ" lower-cases to "i̇" with a combining dot, "ı" upper-cases to "I"), so code that changes the case of keys misses them.',
    fix: same(
      'Rename the key to ASCII letters (for example "title" instead of "tıtle") in every locale and in the code.',
    ),
  },
  TRI003: {
    id: 'TRI003',
    severity: 'warning',
    title: 'Translated text cased without the locale',
    summary:
      'The app ships Turkish or Azerbaijani and upper- or lower-cases translated text without the locale: "istanbul" becomes "ISTANBUL" instead of "İSTANBUL".',
    fix: {
      apple:
        'Use uppercased(with:) with the locale the text is in, e.g. uppercased(with: Locale(identifier: "tr")), or localizedUppercase when that is the device locale.',
      flutter:
        "Dart's toUpperCase() ignores the locale. Put the upper-case text in the ARB file as its own message, so the Turkish translator writes İ.",
      js: "Use toLocaleUpperCase(language) with the app's current language, e.g. i18n.language.",
    },
  },
};

export const RULE_IDS = Object.keys(RULES) as RuleId[];

/** Link to the rule's section in docs/rules.md. */
export const ruleDocs = (id: RuleId): string =>
  `${REPOSITORY_URL}/blob/${DOCS_BRANCH}/docs/rules.md#${id.toLowerCase()}`;
