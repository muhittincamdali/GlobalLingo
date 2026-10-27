<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/banner-light.svg" alt="GlobalLingo: Lints iOS, Flutter and React Native localization files and names the fix for each finding."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/GlobalLingo/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/GlobalLingo/actions/workflows/ci.yml/badge.svg" alt="CI status"></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-version-light.svg" alt="Latest version: v1.0.0 · older Swift package"></picture></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/blob/master/package.json"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-language-light.svg" alt="Language version: Node.js 22.12+"></picture></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/blob/master/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-license-light.svg" alt="License: MIT"></picture></a>
</p>

<p align="center">
<a href="#quick-start"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-start-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-start-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-start-en-light.svg" alt="Get started"></picture></a>
<a href="https://muhittincamdali.github.io/GlobalLingo/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-docs-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-docs-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-docs-en-light.svg" alt="Documentation"></picture></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/tree/master/docs/guides"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-guides-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-guides-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-guides-en-light.svg" alt="Guides"></picture></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/tree/master/examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-examples-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-examples-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-examples-en-light.svg" alt="Examples"></picture></a>
</p>

<!-- brand:end -->
GlobalLingo checks the localization files of an iOS, Flutter or React Native/Expo app before they
ship: Xcode String Catalogs, `.strings` and `.stringsdict` files, Flutter ARB files and JSON
translation files. It finds missing, empty and stale translations, placeholders and plural forms
that do not match across languages, duplicate keys, keys the code looks up but no file defines,
hard-coded UI text, and Turkish dotted and dotless I traps, and names the fix for each finding.
It reads files only and needs nothing but Node.js.

<picture><source media="(prefers-color-scheme: dark)" srcset="docs/media/demo-flutter-dark.svg"><source media="(prefers-color-scheme: light)" srcset="docs/media/demo-flutter-light.svg"><img src="docs/media/demo-flutter-light.svg" alt="GlobalLingo run on a Flutter app: a renamed placeholder in the German ARB file (FMT001, FMT002), Polish without the plural forms for 2 to 4 and 5 or more (PLU001), an unused and a missing message, hard-coded text and toUpperCase on Turkish text, each with its fix"></picture>

<sub>Recorded from the real CLI on the <a href="fixtures/flutter-arb">flutter-arb fixture</a>, a
Flutter 3.47.5 app (<code>npm run demo</code>). <code>flutter gen-l10n</code> accepts the German
file and then breaks the build; see <a href="docs/guides/placeholders-and-plurals.md">the
guide</a>.</sub>

## Highlights

- **Four formats, one report.** String Catalogs, `.strings`/`.stringsdict`, ARB and JSON (i18next,
  i18n-js, react-intl/FormatJS) are read into the same model and checked with the same 19 rules,
  so a monorepo with a native app, a Flutter app and an Expo app gets one report.
- **Placeholders the way each runtime reads them.** Format specifiers by position and type
  (`%@` against `%lld`, `%d` against `%lld`, `%#@name@` substitutions), ICU and i18next
  placeholders by name, per plural form.
- **Plural forms from CLDR.** Each locale is checked for the categories its language uses (Polish
  `few` and `many`, Arabic all six), with example numbers in the message.
- **The code, too.** Keys the code looks up but no catalog defines, keys no code mentions,
  SwiftUI literals missing from the String Catalog, hard-coded text in UIKit, Flutter and React
  Native, and case changes that break on Turkish and Azerbaijani devices.
- **Made for CI.** Exit codes 0/1/2, `--fail-on`, a baseline file so only new findings fail, and
  output as text, Markdown, JSON, SARIF (code scanning) or GitHub annotations.
- **Bounded on any repository.** No runtime dependencies, no network, symbolic links not followed,
  limits on file sizes, depth and findings, and text from the project never reaches the terminal
  with control characters in it.

## Quick start

You need [Node.js](https://nodejs.org/) 22.12 or later (`node --version` prints it; on a Mac,
`brew install node` installs it). Nothing else: no Xcode, Flutter or React Native toolchain.

**1. Open a terminal in your app's folder**, the one with the `.xcodeproj`, `pubspec.yaml` or
`package.json`:

```sh
cd path/to/YourApp
```

**2. Run GlobalLingo:**

```sh
npx @mcamdali/globallingo
```

The npm package is `@mcamdali/globallingo`; the command it installs is `globallingo`.

**3. Read the findings.** Each one names its rule, the file and line, what is wrong and how to fix
it, with a link to the rule's documentation. **ERROR** findings make the exit code 1; the last
line counts them. To fail on warnings too, add `--fail-on warning`.

## What GlobalLingo checks

| Rule   | Severity | Finding                                                                                        |
| ------ | -------- | ---------------------------------------------------------------------------------------------- |
| MIS001 | error    | A translation is missing (or a String Catalog entry is still in state "new")                   |
| MIS002 | error    | A translation is empty                                                                         |
| MIS003 | warning  | A String Catalog translation needs review                                                      |
| MIS004 | info     | A translation is the same as the source text                                                   |
| STA001 | warning  | Xcode marks the key as stale                                                                   |
| STA002 | warning  | A translation has a key the source language does not                                           |
| FMT001 | error    | A placeholder the source does not have, or of another type                                     |
| FMT002 | warning  | A placeholder of the source is left out                                                        |
| FMT003 | error    | A file or message does not parse (JSON, `.strings`, plist, ICU, `%` sequences)                 |
| PLU001 | warning  | A plural form the language needs (CLDR) is missing                                             |
| PLU002 | error    | A plural has no `other` form                                                                   |
| DUP001 | error    | A key appears twice in one file                                                                |
| KEY001 | error    | The code looks up a key no catalog defines                                                     |
| KEY002 | warning  | A SwiftUI literal is not in the String Catalog                                                 |
| KEY003 | info     | No source file mentions the key                                                                |
| HCS001 | warning  | Text shown to the user is hard-coded                                                           |
| TRI001 | warning  | A lookup key is case-changed with the device locale                                            |
| TRI002 | warning  | A key contains `İ` or `ı`                                                                      |
| TRI003 | warning  | Translated text is case-changed without the locale in an app that ships Turkish or Azerbaijani |

[docs/rules.md](docs/rules.md) describes each rule with examples, the fix per ecosystem and the
Apple, Flutter, Unicode, ICU and library documents it rests on.

## Installation

Run it without installing, as above, or install the `globallingo` command:

```sh
npm i -g @mcamdali/globallingo
globallingo
```

In a JavaScript project, `npm install --save-dev @mcamdali/globallingo` pins a version and
`npx globallingo` runs that copy. Each
[GitHub release](https://github.com/muhittincamdali/GlobalLingo/releases) also carries the package
as `globallingo-<version>.tgz` with a `SHA256SUMS` file, and the release workflow opens a Homebrew
formula for `brew install muhittincamdali/tap/globallingo`.

From a clone:

```sh
git clone https://github.com/muhittincamdali/GlobalLingo.git
cd GlobalLingo && npm ci && npm run build
node dist/cli/main.js path/to/YourApp
```

## Usage

```text
globallingo [path] [options]
```

| Option                    | What it does                                                               |
| ------------------------- | -------------------------------------------------------------------------- |
| `path`                    | The app's folder; default is the current folder                            |
| `-f, --format <format>`   | `tty` (default), `markdown`, `json`, `sarif` or `github`                   |
| `-o, --output <file>`     | Write the report to a file instead of the terminal                         |
| `--fail-on <severity>`    | `error` (default), `warning`, `info` or `none`: what makes the exit code 1 |
| `-c, --config <file>`     | Settings file; default is `<path>/.globallingo.json` when it exists        |
| `--source <locale>`       | The source language, when the files do not say                             |
| `--locales <list>`        | Check only these locales, e.g. `de,tr,pl`                                  |
| `--baseline <file>`       | Findings in this file are reported but do not fail the run                 |
| `--write-baseline <file>` | Write every finding of this run to a baseline file                         |
| `--no-code`               | Check the localization files only, not the source code                     |
| `--no-color`              | Plain text even in a terminal (`NO_COLOR` and `FORCE_COLOR` are respected) |

Exit codes: `0` no findings at or above `--fail-on`, `1` findings at or above it, `2` bad
arguments or settings, no localization files found, or an unexpected error. A folder without
localization files is an error, so a wrong path in CI does not pass quietly.

### Run it in CI

[examples/github-actions/globallingo.yml](examples/github-actions/globallingo.yml) annotates the
pull request, writes the coverage and findings to the job summary, uploads SARIF for code scanning
and fails the job on errors. [Run GlobalLingo in CI](docs/guides/ci.md) explains each part.

### Start with a baseline

```sh
npx @mcamdali/globallingo --write-baseline .globallingo-baseline.json
npx @mcamdali/globallingo --baseline .globallingo-baseline.json
```

The first command accepts today's findings; the second fails only on new ones. Fingerprints do
not include line numbers, so moving code does not invalidate the file.

### Configure

A `.globallingo.json` in the app's folder sets the source language, the required locales, ignored
paths and keys, and a severity (or `off`) per rule:

```json
{
  "locales": ["de", "pl", "tr"],
  "ignore": { "paths": ["**/__tests__/**"], "keys": ["legacy.*"] },
  "rules": { "HCS001": "error", "MIS004": "off" }
}
```

[docs/configuration.md](docs/configuration.md) lists every field, what GlobalLingo finds on its
own, and the limits. In code, a line ending in `// globallingo-ignore` is not reported.

### Use the JSON report or the API

```sh
npx @mcamdali/globallingo --format json > globallingo.json
```

The report has the catalogs with coverage per locale, and each finding's `rule`, `severity`,
`file`, `line`, `key`, `locale`, `message`, `fix`, `docs` and `fingerprint` (`schemaVersion` 1).
[examples/shell/errors-by-locale.sh](examples/shell/errors-by-locale.sh) counts errors per locale
with `jq`. The same checks run from JavaScript:

```js
import { render, scan } from '@mcamdali/globallingo';

const report = await scan('path/to/app', { locales: ['de', 'tr'] });
console.log(report.summary);
console.log(render(report, 'markdown'));
```

[examples/api/coverage.mjs](examples/api/coverage.mjs) prints the coverage of every catalog.

## Demo

The terminal recordings come from the CLI on the [fixtures](fixtures/README.md), small apps made
with each toolchain:

| Project                                                        | Recording                                                                             |
| -------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| Flutter 3.47.5 app with ARB files                              | top of this page                                                                      |
| Expo SDK 58 app with i18next                                   | [light](docs/media/demo-expo-light.svg) · [dark](docs/media/demo-expo-dark.svg)       |
| SwiftUI package whose String Catalog keys Xcode 27.1 extracted | [light](docs/media/demo-swiftui-light.svg) · [dark](docs/media/demo-swiftui-dark.svg) |
| UIKit app with `.strings` and `.stringsdict` (XcodeGen)        | [light](docs/media/demo-uikit-light.svg) · [dark](docs/media/demo-uikit-dark.svg)     |

Measured on 28 October 2026 on a Mac (Apple silicon, M5 Max) with Node.js 26.12 while other jobs
kept its load average above 40: three sets of 100 runs of `node dist/cli/main.js` on the four
fixtures, Node.js start-up included. The medians of the three sets were 0.12, 0.13 and 0.14
seconds; the slowest run took 0.54 seconds.

### What users see

The UIKit fixture in the iOS 27.0 simulator (iPhone 17, built with Xcode 27.1), English on the
left and Turkish on the right. Foundation shows the key itself where a translation is missing
(`archive.confirm.message` in Turkish, MIS001) and where no table has the key at all
(`archive.confirm.ok`, KEY001). `scripts/simulator-shots.sh` takes both screenshots.

<p align="center"><img src="docs/media/simulator/inbox-en.png" width="300" alt="The Inbox app in English: the alert asks 'Archive all messages?' with the message text, and the button shows the raw key archive.confirm.ok"> <img src="docs/media/simulator/inbox-tr.png" width="300" alt="The Inbox app in Turkish: the alert title is translated, but the message shows the raw key archive.confirm.message and the button the raw key archive.confirm.ok"></p>

## Status

| Feature                                                                                                                    | Status  |
| -------------------------------------------------------------------------------------------------------------------------- | ------- |
| String Catalogs, `.strings` (UTF-8, UTF-16, XML) and `.stringsdict`, ARB with l10n.yaml, i18next, i18n-js and ICU JSON     | works   |
| 19 rules: translations, stale and orphan keys, placeholders, plurals, duplicates, keys in code, hard-coded text, Turkish I | works   |
| Terminal, Markdown, JSON, SARIF and GitHub annotation output; `--fail-on`; baselines; `.globallingo.json`                  | works   |
| Programmatic API with type declarations                                                                                    | works   |
| YAML translation files (Rails-style i18n, i18next YAML)                                                                    | planned |
| Android `strings.xml` for native Android and the Android side of cross-platform apps                                       | planned |
| A GitHub Action wrapper (`uses: muhittincamdali/GlobalLingo@v2`) and pull request comments                                 | planned |
| Translator comments: report keys without a comment or `@key` description                                                   | planned |

## Limits

- **Patterns, not a compiler.** The code rules read Swift, Objective-C, Dart and
  JavaScript/TypeScript with comments blanked and look for the common ways each ecosystem looks up
  and shows text. Keys built at run time, wrappers around the lookup functions and text set
  through variables are not seen.
- **Literal keys only.** KEY001 checks keys written as literals. KEY003 counts any literal,
  prefix or Dart member with the key's name as a use and still reports a key whose use it cannot
  see, which is why it is an info finding.
- **SwiftUI interpolation.** Xcode turns `Text("\(count) books")` into the key `%lld books` using
  the compiler's type information. GlobalLingo does not have it, so KEY002 skips literals with
  interpolation or `%`.
- **CLDR version.** Plural categories come from the CLDR data of the Node.js that runs
  GlobalLingo (CLDR 49 in Node.js 26.12). A newer CLDR can add a category to a language.
- **Files only.** GlobalLingo does not build, run or change anything; it writes only the report or
  baseline you ask for.

## Documentation

API reference, rules, configuration and guides:
[muhittincamdali.github.io/GlobalLingo](https://muhittincamdali.github.io/GlobalLingo/).

## Guides

- [Run GlobalLingo in CI](docs/guides/ci.md)
- [Placeholders and plurals across Apple, Flutter and JavaScript](docs/guides/placeholders-and-plurals.md)
- [The Turkish I](docs/guides/turkish-i.md)
- Reference: [rules](docs/rules.md) and [configuration](docs/configuration.md)

## Related tools

Other projects check some of the same files; which one fits depends on what you use:

- [xcstrings-lint](https://github.com/thatswiftguy/xcstrings-lint) is a GitHub Action for String
  Catalogs and `.strings` files, with a ratchet mode that blocks only the problems a pull request
  introduces and a pull request comment.
- [i18n-check](https://github.com/lingualdev/i18n-check) validates JSON and YAML translation files
  of JavaScript apps (ICU and i18next), including unused and undefined keys through i18next-parser.
- [BartyCrouch](https://github.com/FlineDev/BartyCrouch) keeps `.strings` files in sync with Swift
  code and storyboards, can translate through an API, and lints duplicate keys and empty values.
- [StringsLint](https://github.com/dral3x/StringsLint) reports missing and unused `.strings` keys
  in Swift and Objective-C projects.
- Xcode's String Catalog editor shows the translation progress of each language, and Flutter's
  `gen-l10n` lists untranslated messages with `untranslated-messages-file`.

GlobalLingo reads all four formats in one run and adds placeholder types, CLDR plural forms,
the code checks and the Turkish I rules. The descriptions above are from each project's README
on 28 October 2026.

## Requirements

| Toolchain | Minimum version |
| --------- | --------------- |
| Node.js   | 22.12           |

GlobalLingo does not need Xcode, Flutter or React Native: it reads files, so it also runs on Linux. CI runs the tests on Node.js 22 and 24 (Linux); locally
all 192 pass on Node.js 22.23, 24.22 and 26.12 on a Mac (Apple silicon).

## Architecture

```text
path ─► walk                 files of the folder (no symbolic links, no dependency folders, limits)
     ─► discoverCatalogs     String Catalogs, .lproj tables, ARB folders (l10n.yaml), JSON locale folders
          parse/             JSON, .strings, plist readers with line numbers and duplicate keys
          catalogs/          one model: catalog → key → translation per locale (texts, plurals, state)
     ─► checkCatalog         MIS, STA, FMT, PLU, DUP, TRI002 rules
          messages/          printf, ICU, i18next and i18n-js placeholder parsers; CLDR via Intl
     ─► checkSource          KEY001, KEY002, HCS001, TRI001, TRI003 on comment-blanked source code
     ─► unusedKeys           KEY003 from the literals and members of all source files
     ─► render               tty | markdown | json | sarif | github
```

- Each finding is a rule ID, a severity (the rule's default, or the configuration's), a file and
  line, a message, the rule's fix for the finding's ecosystem, a documentation link and a
  fingerprint for baselines.
- Every reader stops at a nesting limit and every pattern is bounded, so crafted files cannot
  exhaust the stack or the time; the tests feed it 100,000 levels of JSON and 2 MB source files.
- The CLI (`src/cli/`) only parses arguments, picks colours and widths, and sets the exit code.

## Roadmap

See the [Status](#status) table: YAML files, Android `strings.xml`, a GitHub Action wrapper and
translator comments are planned. [CHANGELOG.md](CHANGELOG.md) lists what each release changed.

## FAQ

**Does GlobalLingo change my files?** No. It reads them and writes only the report or baseline you
ask for.

**Why does Polish need four forms when English has two?** Polish uses one form for 1, another
for 2–4 (and 22–24, 32–34…), another for 0 and 5–21 (and 25–31…), and a fourth for fractions.
CLDR records these rules per language; [the plural guide](docs/guides/placeholders-and-plurals.md)
has the table.

**My app has no Turkish translation. Can TRI001 still matter?** Yes. It is about the device's
language, not the app's: a key lower-cased with `toLocaleLowerCase()` turns `I` into `ı` on any
Turkish device. [The Turkish I](docs/guides/turkish-i.md) shows it.

**A finding is wrong for my project. What do I do?** Turn the rule down or off in
`.globallingo.json`, ignore the key or path, or mark the line with `globallingo-ignore`, and
please open an issue with the smallest example that shows it.

## Contributing

Contributions are welcome: read [CONTRIBUTING.md](CONTRIBUTING.md) and the
[code of conduct](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md) before
opening a pull request, and report security issues as described in [SECURITY.md](SECURITY.md).

## License

Released under the MIT license. See [LICENSE](LICENSE).
