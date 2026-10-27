# Fixtures

Small apps with the localization mistakes GlobalLingo looks for, one per ecosystem. The tests in
[test/integration/fixtures.test.ts](../test/integration/fixtures.test.ts) list what GlobalLingo must
find in each, and the README demos are recorded from them (`npm run demo`). Every mistake is there
on purpose; do not fix them.

| Fixture                            | What it is                                                                                                                   | How it was made                                                                                                                                                             | Checked with                                                                      |
| ---------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------- |
| [swiftui-catalog](swiftui-catalog) | Swift package with a SwiftUI view and a String Catalog (en, de, fr, pl, tr)                                                  | `Package.swift` by hand; the catalog's keys extracted by Xcode 27.1 (`xcodebuild` with `SWIFT_EMIT_LOC_STRINGS=YES`, then `xcstringstool sync`), translations added by hand | `swift build` (Swift 6.4) compiles the catalog                                    |
| [uikit-strings](uikit-strings)     | UIKit app with `Localizable.strings` and `.stringsdict` per `.lproj` (en, de, ru, tr); the English `.strings` file is UTF-16 | `project.yml` for XcodeGen 2.45, `xcodegen generate`                                                                                                                        | `plutil -lint` on every table; `xcodebuild` for the iOS simulator with Xcode 27.1 |
| [flutter-arb](flutter-arb)         | Flutter app with `l10n.yaml` and ARB files (en, de, pl, tr)                                                                  | `flutter create --empty` with Flutter 3.47.5, then the setup from Flutter's internationalization guide                                                                      | `flutter gen-l10n` succeeds; see below                                            |
| [expo-i18next](expo-i18next)       | Expo SDK 58 app with i18next and JSON files (en, de, pl, tr)                                                                 | Written by hand after Expo's localization guide; no `node_modules`                                                                                                          | GlobalLingo only                                                                  |

Only the files that matter are kept: no build output, generated localization code, platform
folders or lockfiles.

## What each fixture contains

**swiftui-catalog**: a French translation that swaps the order of `%lld` and `%@` without
positions and does not vary by plural (FMT001, PLU001), Polish without the plural forms for 2–4 and 5+ (PLU001), a missing Polish
and an empty Polish translation (MIS001, MIS002), a Turkish translation still in state "new"
(MIS001), a French one marked for review (MIS003), a stale key (STA001), `sync.retry` looked up
but not in the catalog (KEY001), `Text("Pull to refresh")` added after the last extraction
(KEY002), a lookup key passed through `localizedLowercase` (TRI001) and translated text
upper-cased with `uppercased()` in an app that ships Turkish (TRI003).

**uikit-strings**: a duplicate key in German that `plutil -lint` and the build both accept
(DUP001), a Turkish plural form that reads the 64-bit count with `%1$d` (FMT001), Russian without
the forms for 2–4 and 5+ (PLU001), a key missing in Turkish (MIS001), a Turkish key the source
does not have (STA002), `archive.confirm.ok` looked up but in no table (KEY001), and a button
title set from a literal (HCS001).

**flutter-arb**: the German message renames the `{shelf}` placeholder to `{regal}` (FMT001,
FMT002). `flutter gen-l10n` accepts it and adds a third parameter, `Object regal`, to
`booksOnShelf` in every generated locale class, so the existing call
`l10n.booksOnShelf(count, shelf)` stops compiling (`flutter analyze`: "3 positional arguments
expected by 'booksOnShelf', but 2 found"). Also: Polish without few and many (PLU001), a
Polish message still in English (MIS004), a message missing in Turkish and used nowhere in the code (MIS001, KEY003), hard-coded
`MaterialApp(title:)` and `Text('Pull to refresh')` (HCS001), and translated text upper-cased
with Dart's `toUpperCase()` in an app that ships Turkish (TRI003).

**expo-i18next**: a renamed placeholder in German (FMT001, FMT002), a duplicate `checkout`
object in German whose second copy hides `checkout.total` (DUP001, MIS001), Polish without few
and many (PLU001), a missing and an empty Turkish translation (MIS001, MIS002; the empty one's key is also unused, KEY003), a Turkish key the
source does not have (STA002), `checkout.terms` looked up but not defined (KEY001), hard-coded
text in `<Text>` (HCS001), a key built with `toLocaleLowerCase()` (TRI001) and
`t('cart.title').toUpperCase()` (TRI003).
