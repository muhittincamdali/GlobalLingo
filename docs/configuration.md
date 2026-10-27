# Configuration

GlobalLingo needs no configuration. When the checked folder has a `.globallingo.json`, it reads
it; `--config <file>` names another file. Every field is optional. An unknown field, an unknown
rule or a wrong type stops the run with exit code 2, so a typo cannot quietly turn a check off.

```json
{
  "$schema": "./node_modules/@mcamdali/globallingo/schema/config.schema.json",
  "sourceLanguage": "en",
  "locales": ["de", "fr", "tr", "pl"],
  "ignore": {
    "paths": ["**/Tests/**", "ios/Pods/**", "lib/generated/**"],
    "keys": ["debug.*", "app_name"]
  },
  "rules": {
    "MIS004": "off",
    "HCS001": "error",
    "PLU001": "info"
  },
  "jsonSyntax": "i18next",
  "catalogDirs": ["app/i18n/strings"]
}
```

| Field            | What it does                                                                                                                                                                                                                                                 |
| ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `sourceLanguage` | The language the others are translated from, for files that do not say it (`.strings` tables without an Xcode project, JSON folders without `en`). String Catalogs use their own `sourceLanguage`, ARB folders their template file. `--source` overrides it. |
| `locales`        | Check only these locales, and report each one a catalog has no file for. `--locales de,fr` overrides it.                                                                                                                                                     |
| `ignore.paths`   | Globs matched against paths from the checked folder. `*` stays within a folder, `**` crosses folders, and a folder pattern covers everything below it.                                                                                                       |
| `ignore.keys`    | Globs matched against keys, in every catalog and in code.                                                                                                                                                                                                    |
| `rules`          | `error`, `warning`, `info` or `off` per rule ID. See [rules](rules.md).                                                                                                                                                                                      |
| `jsonSyntax`     | `i18next`, `icu` or `i18n-js`: the placeholder syntax of JSON translation files, when package.json does not show which library the app uses.                                                                                                                 |
| `catalogDirs`    | Folders with JSON translation files that GlobalLingo does not find on its own (see below). They must be inside the checked folder.                                                                                                                           |

The `$schema` line lets editors complete and check the file once the package is installed in the
project; [schema/config.schema.json](../schema/config.schema.json) is the same schema.

## What GlobalLingo finds on its own

| Files                                                                | Read as                                                                                                                                                                                             |
| -------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `*.xcstrings`                                                        | One String Catalog per file                                                                                                                                                                         |
| `<folder>/<locale>.lproj/<Table>.strings` and `.stringsdict`         | One table per folder and table name; the source language is the Xcode project's `developmentRegion`, else `en`, else `Base`                                                                         |
| `*.arb`, with `l10n.yaml`                                            | One catalog per folder; `arb-dir`, `template-arb-file`, `output-class` and `use-escaping` from l10n.yaml                                                                                            |
| `<folder>/<locale>.json`, `<folder>/<locale>/<namespace>.json`       | One catalog per folder (or per namespace), when the folder is called `locales`, `locale`, `i18n`, `l10n`, `lang`, `langs`, `languages`, `translations` or `messages`, or holds at least two locales |
| `*.swift`, `*.m`, `*.mm`, `*.dart`, `*.js`, `*.jsx`, `*.ts`, `*.tsx` | Source code for the KEY, HCS and TRI rules (`--no-code` skips it)                                                                                                                                   |

The placeholder syntax of JSON files comes from the nearest package.json: react-intl, FormatJS,
next-intl, use-intl, Lingui or i18next-icu mean ICU; i18next, react-i18next or next-i18next mean
i18next; i18n-js means i18n-js. Without a package.json it comes from the files themselves.

Skipped: `node_modules`, `Pods`, `Carthage`, `build`, `.build`, `DerivedData`, `.dart_tool`,
`dist`, `vendor`, version control and editor folders, and symbolic links. Tests, stories and
generated localization code are not checked for hard-coded text.

## Limits

GlobalLingo reads at most 200,000 files and folders, 24 folder levels, catalogs up to 16 MB,
source files up to 2 MB and 20,000 source files, and stops at 100,000 findings. Each limit adds a
note to the report; point GlobalLingo at the app's folder in a monorepo.

## In the code

A line that ends with a `globallingo-ignore` comment is not reported by the code rules, and
neither is the line after a `globallingo-ignore-next-line` comment:

```dart
// globallingo-ignore-next-line
const Text('GlobalLingo'), // brand name, the same in every language
```

## Baseline

A baseline file accepts the findings a project has today, so CI fails only on new ones:

```sh
npx @mcamdali/globallingo --write-baseline .globallingo-baseline.json
npx @mcamdali/globallingo --baseline .globallingo-baseline.json
```

The file stores a fingerprint per finding (rule, file, key, locale and what the finding is
about, hashed), not line numbers, so findings keep matching when lines move. Fixed findings drop
out of the count; write the file again to shrink it. Baseline findings are still reported, marked
`BASELINE` in the terminal and as suppressed results in SARIF.
