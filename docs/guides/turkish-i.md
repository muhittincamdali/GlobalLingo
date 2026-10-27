# The Turkish I

Turkish and Azerbaijani write four letters where English writes two: dotted `i` and `İ`, dotless
`ı` and `I`. Lower-case `i` goes with upper-case `İ`, and `ı` with `I`. Unicode keeps this in its
special casing table
([SpecialCasing.txt](https://www.unicode.org/Public/UCD/latest/ucd/SpecialCasing.txt)), so
every case change has two possible answers, depending on whether it uses the locale.

The outputs below come from Node.js 26 and Swift 6.4 on macOS.

| Code                                                            | Result                                          |
| --------------------------------------------------------------- | ----------------------------------------------- |
| `"istanbul".toLocaleUpperCase('tr')`                            | `İSTANBUL`                                      |
| `"istanbul".toUpperCase()`                                      | `ISTANBUL`                                      |
| `"TITLE".toLocaleLowerCase('tr')`                               | `tıtle`                                         |
| `"TITLE".toLowerCase()`                                         | `title`                                         |
| `"istanbul".uppercased(with: Locale(identifier: "tr"))` (Swift) | `İSTANBUL`                                      |
| `"istanbul".uppercased()` (Swift)                               | `ISTANBUL`                                      |
| `"İ".toLowerCase()`, `"İ".lowercased()`                         | `i̇`: `i` followed by U+0307 COMBINING DOT ABOVE |

Two different mistakes follow from this, and GlobalLingo reports both.

## Keys must not follow the locale (TRI001)

Keys are identifiers. Code that changes their case with the device's locale breaks on Turkish
and Azerbaijani devices, even in an app that only ships English:

```ts
// The server sends "IDLE"; the translation file has "status.idle".
t(`status.${state.toLocaleLowerCase()}`); // on a Turkish device: "status.ıdle", not found
t(`status.${state.toLowerCase()}`); // "status.idle" everywhere
```

```swift
NSLocalizedString("status.\(name)".localizedLowercase, comment: "") // follows the device
NSLocalizedString("status.\(name)".lowercased(), comment: "") // does not
```

[fixtures/expo-i18next/App.tsx](../../fixtures/expo-i18next/App.tsx) and
[fixtures/swiftui-catalog](../../fixtures/swiftui-catalog/Sources/Shelf/Messages.swift) have one
each. Keys that contain `İ` or `ı` themselves (TRI002) have the same problem from the other side:
no case change gives them back.

## Text must follow the language (TRI003)

Translated text is the opposite: an upper-case heading in Turkish needs the Turkish mapping, or
"Kitap teslim edildi" ("the book was delivered") becomes "KITAP TESLIM EDILDI" instead of
"KİTAP TESLİM EDİLDİ", with four wrong letters. GlobalLingo reports a
case change right after a lookup when the app ships Turkish or Azerbaijani:

```ts
t('pickup.city').toUpperCase(); // TRI003
t('pickup.city').toLocaleUpperCase(i18n.language); // the app's language
```

```swift
String(localized: "Pickup in \(city)").uppercased() // TRI003
String(localized: "Pickup in \(city)").uppercased(with: locale) // the language of the text
```

Dart has no locale-aware `toUpperCase()`
([its documentation](https://api.dart.dev/dart-core/String/toUpperCase.html): "uses the language
independent Unicode mapping and thus only works in some languages"). In Flutter, put the
upper-case text in the ARB file as a message of its own, so the Turkish translator writes the
dotted capital:

```json
{
  "pickupHeading": "PICKUP IN {city}",
  "@pickupHeading": { "placeholders": { "city": { "type": "String" } } }
}
```

The city itself is data; if it must be upper case too, upper-case it where the app knows the
language, for example on the server.

## Why not just ignore it

Both mistakes pass every test that runs in English, and both are invisible in a simulator set to
English. They show up as raw keys or misspelled words for users with a Turkish or Azerbaijani
device, which is why GlobalLingo checks the code for them instead of waiting for a screenshot.
