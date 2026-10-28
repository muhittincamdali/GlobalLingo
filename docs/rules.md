# Rules

Every finding names its rule. The severity is the default; `rules` in
[`.globallingo.json`](configuration.md) changes it or turns a rule off. Each rule lists what it
checks, why it matters, how to fix a finding in each ecosystem and the documents it is based on.

| Rule              | Severity | Finding                                  |
| ----------------- | -------- | ---------------------------------------- |
| [MIS001](#mis001) | error    | Missing translation                      |
| [MIS002](#mis002) | error    | Empty translation                        |
| [MIS003](#mis003) | warning  | Needs review                             |
| [MIS004](#mis004) | info     | Same as the source                       |
| [STA001](#sta001) | warning  | Stale key                                |
| [STA002](#sta002) | warning  | Key not in the source language           |
| [FMT001](#fmt001) | error    | Placeholder mismatch                     |
| [FMT002](#fmt002) | warning  | Placeholder dropped                      |
| [FMT003](#fmt003) | error    | Invalid syntax                           |
| [PLU001](#plu001) | warning  | Missing plural form                      |
| [PLU002](#plu002) | error    | Plural without "other"                   |
| [DUP001](#dup001) | error    | Duplicate key                            |
| [KEY001](#key001) | error    | Unknown key                              |
| [KEY002](#key002) | warning  | SwiftUI text not in the String Catalog   |
| [KEY003](#key003) | info     | Unused key                               |
| [HCS001](#hcs001) | warning  | Hard-coded UI text                       |
| [TRI001](#tri001) | warning  | Locale-dependent case change on a key    |
| [TRI002](#tri002) | warning  | Dotted or dotless I in a key             |
| [TRI003](#tri003) | warning  | Translated text cased without the locale |

The locales a catalog is checked for are the ones it has: the localizations in a String Catalog,
the `.lproj` folders of a strings table, the ARB files of an `arb-dir`, the JSON files (or locale
folders) of a translation folder. `locales` in the configuration, or `--locales`, narrows the list
and reports a listed locale that has no file. `Base`, `mul` and `und` are never targets.

## Translations

### MIS001

**Missing translation** · error

A key of the source language has no translation in a locale the catalog has. In a String Catalog
a localization in state `new` also counts as missing: Xcode creates it when a string is added and
nobody has translated it yet.

What users see depends on the library: Foundation returns the key or the default value given in
code, gen_l10n uses the template's message, i18next and i18n-js fall back to the fallback
language or show the key, react-intl shows the `defaultMessage` or the id.

- **Apple**: translate the key in Xcode's String Catalog editor, or add it to the locale's
  `.strings` file.
- **Flutter**: add the key to the locale's ARB file.
- **JavaScript**: add the key to the locale's translation file.

Sources: [Localizing and varying text with a String Catalog](https://developer.apple.com/documentation/xcode/localizing-and-varying-text-with-a-string-catalog),
[Flutter internationalization](https://docs.flutter.dev/ui/internationalization).

### MIS002

**Empty translation** · error

The translation is `""` while the source text is not. Xcode, gen_l10n and i18next use an empty
value as it is, so the label or button shows nothing. Write the translation, or remove the empty
entry so the fallback is used until someone translates it.

### MIS003

**Needs review** · warning

A String Catalog localization is in state `needs_review` (Xcode sets it when the source text
changes after translation) or `stale`. Check it against the current source text and mark it as
reviewed in the String Catalog editor.

### MIS004

**Same as the source** · info

The translation is identical to the source text (and has at least three letters), which often
means it was copied and never translated. Locales of the source language (`en-GB` for `en`) are
left out. Brand names and words that are the same in both languages belong in `ignore.keys`.

## Stale and orphan keys

### STA001

**Stale key** · warning

Xcode marks a String Catalog key `"extractionState": "stale"` when it no longer finds the string
in the source code. The catalog still ships it and translators still see it. Delete it (the
editor's Remove Stale Strings) or mark it as manually managed if the code builds the key at run
time.

### STA002

**Key not in the source language** · warning

A translation has a key that the source language file does not: a leftover after a rename, or a
typo in the key. The app never asks for it. Delete it, or add it to the source language if the
app uses it. Strings tables of storyboards and XIBs (no source `.strings` file) are not checked.

## Placeholders and syntax

GlobalLingo compares placeholders the way each runtime reads them:

- **Format specifiers** (String Catalogs, `.strings`, `.stringsdict`) by argument position and
  type: `%@` is an object, `%d` a 32-bit integer, `%ld` and `%lld` 64-bit integers, `%f` a
  double. `%1$@` and `%2$lld` give positions explicitly; `%#@name@` refers to a plural rule whose
  `NSStringFormatValueTypeKey` (or `formatSpecifier` in a String Catalog) gives the type, and
  `%arg` in a String Catalog substitution stands for that argument.
- **ICU** (ARB files, react-intl/FormatJS messages) by argument name: `{name}`,
  `{count, plural, …}`, `{gender, select, …}`.
- **i18next** by `{{name}}` (also `{{name, format}}` and `{{- name}}`), **i18n-js** by `%{name}`.

### FMT001

**Placeholder mismatch** · error

The translation uses a placeholder the source text does not have, or reads an argument as
another type. With format specifiers this is a run-time fault: `%@` given an integer reads it as
an object pointer, `%d` given a 64-bit integer prints the wrong number. With named placeholders
the value is not passed: FormatJS reports a missing value, i18next leaves `{{username}}` in the
text, and gen_l10n adds the unknown name as a new parameter of the generated method, so the code
that calls it stops compiling (see [fixtures/flutter-arb](../fixtures/README.md#what-each-fixture-contains)).

- **Apple**: use the source's specifiers; when the word order changes, give positions:
  `"%2$@ rafında %1$lld kitap"`.
- **Flutter**: use the template's placeholder names, declared in its `@key` metadata.
- **JavaScript**: use the source's placeholder names; the code passes values under those names.

Sources: [String Format Specifiers](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Strings/Articles/formatSpecifiers.html),
[ICU message syntax (FormatJS)](https://formatjs.github.io/docs/core-concepts/icu-syntax),
[i18next interpolation](https://www.i18next.com/translation-function/interpolation).

### FMT002

**Placeholder dropped** · warning

The translation leaves out a placeholder of the source text, so a name or a count is not shown.
Plural forms for zero, one and two may leave the number out ("one file", "un fichier"), so those
forms are not reported. For format specifiers the whole translation counts: an argument is used
when any of its plural variants uses it.

### FMT003

**Invalid syntax** · error

A file does not parse (broken JSON, an unterminated `.strings` entry, a malformed `.stringsdict`),
or a message is not valid in its syntax: an unbalanced brace or an unknown plural category in
ICU, or a `%` followed by a letter that is no conversion in a format string (write `%%` for a
percent sign). Code generation fails (gen_l10n), the library throws or prints the raw text
(FormatJS), or the whole file is not loaded.

- **Apple**: `plutil -lint` checks `.strings` and `.stringsdict` files.
- **Flutter**: with `use-escaping: true` in l10n.yaml, quote literal braces: `'{'`.
- **JavaScript**: in ICU messages, quote literal braces with apostrophes.

Source: [ICU message formatting](https://unicode-org.github.io/icu/userguide/format_parse/messages/).

## Plurals

Plural categories come from the Unicode CLDR data built into Node.js (`Intl.PluralRules`), the
same data i18next and FormatJS select with at run time. English has `one` and `other`; Polish
and Russian add `few` and `many`; Arabic uses all six; Japanese only `other`. CLDR assigns
`many` to French, Spanish, Italian and Portuguese for large round numbers such as 1,000,000.

### PLU001

**Missing plural form** · warning

A plural in the translation lacks a category the locale's CLDR rules have, or the translation
does not vary by plural where the source does. Numbers in the missing category get the `other`
form, which is grammatically wrong in that language: in Polish, "5 plików" needs `many`, not the
`other` form "5 pliku". The finding lists the missing categories with example numbers.

- **Apple**: in the String Catalog editor, Vary by Plural shows every category of the language.
  In a `.stringsdict`, add the category key.
- **Flutter / ICU**: add the category to the plural, e.g. `few{…}`.
- **i18next**: add `key_few`; **i18n-js**: add a `few` entry.

Sources: [CLDR plural rules](https://cldr.unicode.org/index/cldr-spec/plural-rules),
[CLDR language plural rules chart](https://www.unicode.org/cldr/charts/latest/supplemental/language_plural_rules.html),
[Localizing strings that contain plurals](https://developer.apple.com/documentation/xcode/localizing-strings-that-contain-plurals),
[i18next plurals](https://www.i18next.com/translation-function/plurals),
[Intl.PluralRules](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/PluralRules).

### PLU002

**Plural without "other"** · error

Every plural needs an `other` form: it is the form for any number no other category covers.
ICU requires it, and a `.stringsdict` rule without it has nothing to show for most numbers.

## Duplicates

### DUP001

**Duplicate key** · error

The same key appears twice in one file. JSON.parse, Foundation and gen_l10n keep one of the
values without a warning; `plutil -lint` accepts a `.strings` file with a duplicate key, and so
does an Xcode build (see [fixtures/uikit-strings](../fixtures/README.md#what-each-fixture-contains)). In JSON, a
duplicate object hides every key of the first copy, which GlobalLingo then also reports as
missing.

## Keys in code

### KEY001

**Unknown key** · error

The code looks up a literal key that no catalog defines: `NSLocalizedString("key", …)`,
`String(localized: "key")`, `LocalizedStringResource("key")`, `Bundle.localizedString(forKey:)`
(Apple, per table; tables the project does not define are left alone), `t('key')`,
`<Trans i18nKey="key">`, `formatMessage({ id: 'key' })` and `<FormattedMessage id="key">`
(JavaScript; `ns:key` for i18next namespaces, plural base keys included). Keys built at run time
are not checked. Dart is not checked: a missing getter of the generated class does not compile.

### KEY002

**SwiftUI text not in the String Catalog** · warning

A SwiftUI view or modifier that takes a `LocalizedStringKey` (`Text`, `Button`, `Label`,
`Toggle`, `TextField`, `.navigationTitle`, …) gets a literal that the String Catalog of its
table does not have, so it shows the source text in every language. Build the target so Xcode
extracts it, translate it and commit the catalog; use `Text(verbatim:)` for text that must not be
translated. Literals with interpolation or `%` are left out, because Xcode turns them into format
keys.

### KEY003

**Unused key** · info

No source file mentions the key. Any string literal equal to the key counts as a use, a template
or interpolated string (``t(`errors.${code}`)``, `"status.\(name)"`) or a literal ending in `.`,
`_` or `:` counts as a prefix of any key, Dart member access with the message's name counts, and
i18next `$t(key)` inside translations counts. String Catalogs are left to Xcode's stale marking
(STA001); InfoPlist, storyboard and App Shortcuts tables are not looked up by key in code. Code
can still build keys in ways no pattern sees, so the rule is info and does not fail a run unless
`--fail-on info` is set.

### HCS001

**Hard-coded UI text** · warning

Text shown to the user is a literal in the code: UIKit `.text`, `.title`, `.placeholder`,
`setTitle`, `UIAlertController` and `UIAlertAction` titles; Flutter `Text('…')` and text
parameters (`hintText`, `labelText`, `tooltip`, `title`, `label`, …); React Native `<Text>`
content, `title`, `placeholder` and `accessibilityLabel` props, header titles and `Alert.alert`.
Literals without letters, identifiers (`ok_button`, `LOGIN`), routes and URLs are left out, and so
are tests, stories, previews of generated code, and lines marked `globallingo-ignore`.

SwiftUI `Text("…")` is not hard-coded: the literal is a localization key (KEY002 checks it).

## The Turkish I

Turkish and Azerbaijani have a dotted and a dotless I in both cases: `i` ↔ `İ` and `ı` ↔ `I`.
Unicode's special casing gives them their own mappings, so case changes that use the locale
differ from those that do not:

| Case change             | With the Turkish locale | With any other locale |
| ----------------------- | ----------------------- | --------------------- |
| `"title"` to upper case | `TİTLE`                 | `TITLE`               |
| `"TITLE"` to lower case | `tıtle`                 | `title`               |
| `"İ"` to lower case     | `i`                     | `i̇` (i and U+0307)    |

Functions that take the locale give the left column for Turkish: `toLocaleUpperCase('tr')` in
JavaScript, `uppercased(with: Locale(identifier: "tr"))` in Swift. Those that do not, such as
`toUpperCase()` in JavaScript and Dart and `uppercased()` in Swift, always give the right column.
Functions that use the device's locale (`toLocaleUpperCase()` without an argument,
`localizedUppercase`) give the left column on a Turkish device, whatever language the app shows.

Sources: [SpecialCasing.txt](https://www.unicode.org/Public/UCD/latest/ucd/SpecialCasing.txt),
[toLocaleUpperCase](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/toLocaleUpperCase),
[toLocaleLowerCase](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/toLocaleLowerCase),
[Dart String.toUpperCase](https://api.dart.dev/dart-core/String/toUpperCase.html).
The [Turkish I guide](guides/turkish-i.md) shows each case.

### TRI001

**Locale-dependent case change on a key** · warning

A lookup key goes through a case change that uses the device locale:
`toLocaleLowerCase()` or `toLocaleUpperCase()` without a locale (JavaScript), `localizedLowercase`,
`localizedUppercase`, `lowercased(with: .current)` (Swift), `lowercaseStringWithLocale:[NSLocale
currentLocale]` (Objective-C). On a Turkish or Azerbaijani device `"STATUS.IDLE"` becomes
`"status.ıdle"` and the lookup misses, whatever languages the app ships. Use `toLowerCase()` or
`lowercased()`, which do not depend on the locale.

### TRI002

**Dotted or dotless I in a key** · warning

A key contains `İ` or `ı`. A case change of such a key does not give it back (`"İ"` lower-cases
to `i` plus a combining dot, `"ı"` upper-cases to `I`), so code that normalises keys misses it.
Rename the key to ASCII letters in every locale and in the code.

### TRI003

**Translated text cased without the locale** · warning

The app ships Turkish or Azerbaijani, and translated text is upper- or lower-cased right after the
lookup with a function that ignores the locale: `t('city').toUpperCase()`,
`String(localized: …).uppercased()`, `.capitalized`, or Dart's `toUpperCase()` on a message of the
generated localizations class. "istanbul" becomes "ISTANBUL" instead of "İSTANBUL".

- **Apple**: `uppercased(with: Locale(identifier: "tr"))`, or `localizedUppercase` when the text
  is in the device's language.
- **Flutter**: Dart has no locale-aware `toUpperCase()`; put the upper-case text in the ARB file
  as its own message so the translator writes İ.
- **JavaScript**: `toLocaleUpperCase(i18n.language)`.
