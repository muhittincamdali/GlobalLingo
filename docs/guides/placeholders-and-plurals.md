# Placeholders and plurals across Apple, Flutter and JavaScript

The two mistakes that reach users most often in a translated app are a placeholder that does not
match the source and a plural form that is missing. Each ecosystem writes both differently. This
guide shows what GlobalLingo compares in each, with the mistakes from its
[fixtures](../../fixtures/README.md).

## Apple: format specifiers by position and type

String Catalogs, `.strings` and `.stringsdict` files use printf-style
[format specifiers](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Strings/Articles/formatSpecifiers.html).
`String(format:)` and SwiftUI read the arguments in the order and with the types the specifiers
say, so a translation that reorders them without positions reads an integer as an object:

```json
"%lld books on %@" : {
  "localizations" : {
    "en" : { "variations" : { "plural" : { "one" : { "stringUnit" : { "value" : "%1$lld book on %2$@" } }, … } } },
    "fr" : { "stringUnit" : { "state" : "translated", "value" : "%@ contient %lld livres" } }
  }
}
```

```text
ERROR    FMT001  Sources/Shelf/Resources/Localizable.xcstrings:45  Placeholder mismatch
         "%lld books on %@" in French (fr) uses %@ (an object) for argument 1; the source text has
         %1$lld (a 64-bit integer)
```

The fix keeps the French word order and states the positions: `"%2$@ contient %1$lld livres"`.

Sizes count too: `%d` reads 32 bits and `%lld` 64. A Turkish `.stringsdict` in
[fixtures/uikit-strings](../../fixtures/README.md#what-each-fixture-contains) reads the count with `%1$d` where the source
passes it with `%1$lld`, which prints a wrong number once the count no longer fits in 32 bits.

In a `.stringsdict` or a String Catalog with substitutions, the plural variants are substituted
into one format string, so GlobalLingo checks the translation as a whole: an argument counts as
used when any variant uses it, and `%#@name@` takes the type of its rule
(`NSStringFormatValueTypeKey`, or `formatSpecifier` in a String Catalog; `%arg` stands for that
argument).

## Flutter: ICU argument names

ARB messages use ICU MessageFormat. The names of the template's placeholders are the parameters
of the generated method, so a translation must use the same names:

```jsonc
// app_en.arb (template)
"booksOnShelf": "{count, plural, =0{No books on {shelf}} one{One book on {shelf}} other{{count} books on {shelf}}}",
// app_de.arb
"booksOnShelf": "{count, plural, =0{Keine Bücher auf {regal}} one{Ein Buch auf {regal}} other{{count} Bücher auf {regal}}}"
```

`flutter gen-l10n` (Flutter 3.47.5) accepts this. It adds `regal` as a third parameter,
`booksOnShelf(int count, String shelf, Object regal)`, to every locale's class, and the
existing call `l10n.booksOnShelf(count, shelf)` stops compiling. GlobalLingo reports it at the
ARB file:

```text
ERROR    FMT001  lib/l10n/app_de.arb:4  Placeholder mismatch
         "booksOnShelf" in German (de) uses {regal}, which the source text does not have
WARNING  FMT002  lib/l10n/app_de.arb:4  Placeholder dropped
         "booksOnShelf" in German (de) leaves out {shelf} of the source text
```

Without `use-escaping: true` in l10n.yaml, gen_l10n treats apostrophes as plain text; with it,
`'{'` is a literal brace. GlobalLingo reads l10n.yaml and parses the same way.

## JavaScript: i18next, i18n-js and ICU names

i18next writes `{{name}}`, i18n-js `%{name}`, react-intl and other FormatJS libraries ICU's
`{name}`. When a translation renames a placeholder, i18next leaves the text as it is and the user
sees `Hallo {{username}}`; FormatJS reports that the value for `username` was not provided.

GlobalLingo reads the syntax from package.json (or `jsonSyntax` in
[.globallingo.json](../configuration.md)) and compares names per plural form, so `key_one` may
say "one item" without `{{count}}`.

## Plural forms: CLDR categories per language

Languages split numbers into different groups. The Unicode CLDR defines the groups (categories)
per language; i18next and FormatJS select with these rules at run time through
`Intl.PluralRules`, and Apple's and Flutter's plural support uses the same category names.

| Language                             | Categories                       | Example numbers                |
| ------------------------------------ | -------------------------------- | ------------------------------ |
| English, German, Turkish             | one, other                       | 1 / 0, 2, 5                    |
| French, Spanish, Italian, Portuguese | one, many, other                 | many: 1,000,000                |
| Polish, Russian, Ukrainian           | one, few, many, other            | few: 2–4, 22–24; many: 0, 5–21 |
| Arabic                               | zero, one, two, few, many, other | all six                        |
| Japanese, Chinese, Korean            | other                            | one form for every number      |

([CLDR language plural rules](https://www.unicode.org/cldr/charts/latest/supplemental/language_plural_rules.html))

A Polish translation with only `one` and `other`, copied from English, shows the `other` form
("5 pliku") where Polish needs `many` ("5 plików"). GlobalLingo lists the missing categories and
example numbers for each:

```text
WARNING  PLU001  src/locales/pl.json:6  Missing plural form
         "cart.items" in Polish (pl) has no plural forms for few (e.g. 2, 3, 4), many (e.g. 0, 5, 6)
```

A translation that does not vary by plural at all, where the source does, gets the same finding
for every category besides `other`. Japanese, which has only `other`, does not. A plural without
`other` is an error (PLU002): it is the form for every number the other categories do not cover.

Explicit values such as `=0` in ICU are extra forms for one number: they neither replace a
category nor count as missing.
