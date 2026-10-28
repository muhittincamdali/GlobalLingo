# Changelog

All notable changes to GlobalLingo are listed here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

GlobalLingo 2.0.0 replaces the Swift translation framework of 1.0.0 with a localization linter for
mobile apps, published on npm as `@mcamdali/globallingo` with the command `globallingo`. Nothing of
the 1.0.0 API remains.

### Added

- Readers for Xcode String Catalogs (`.xcstrings`), `.strings` (UTF-8, UTF-16 and XML) and
  `.stringsdict` tables per `.lproj` folder, Flutter ARB files with the settings of `l10n.yaml`,
  and JSON translation files of i18next, i18n-js and react-intl/FormatJS apps, with the line of
  every key and the keys that appear twice.
- 19 rules: missing, empty, untranslated and needs-review translations (MIS001–MIS004), stale and
  orphan keys (STA001, STA002), placeholder mismatches, dropped placeholders and invalid syntax
  (FMT001–FMT003), CLDR plural forms and plurals without `other` (PLU001, PLU002), duplicate keys
  (DUP001), unknown, missing-from-catalog and unused keys in code (KEY001–KEY003), hard-coded UI
  text (HCS001), and Turkish dotted and dotless I traps (TRI001–TRI003). Each finding has a fix
  per ecosystem and a link to [docs/rules.md](docs/rules.md).
- Output as text, Markdown, JSON, SARIF 2.1.0 and GitHub annotations; exit codes 0, 1 and 2 with
  `--fail-on`; `--locales`, `--source`, `--no-code`.
- `.globallingo.json` settings with a JSON schema, `globallingo-ignore` comments, and baseline
  files (`--write-baseline`, `--baseline`) that fail a run only on new findings.
- Limits for crafted repositories: no symbolic links, nesting limits in every reader, bounded
  patterns, file size and count limits, at most 100,000 findings, and control and bidirectional
  characters escaped in every output, including line breaks and tabs in file names and messages
  of the terminal and Markdown reports.
- Time that grows in step with the input on crafted files, measured by tests as a ratio (an
  input grown 16 times to 2 MB must not take more than 100 times as long; quadratic work takes
  256 times): property list tags are read in one pass and refused over 1024 characters, closing
  tags and CDATA sections are searched once, placeholder syntax detection and `l10n.yaml` lines
  are read without backtracking patterns, the printf width and the i18next `{{- name}}` patterns
  no longer split a long run of zeros or spaces in every way, variant and plural comparisons use
  maps, ignore globs match the folders of a path in the same pass, and KEY003 looks up code
  prefixes with a binary search in a sorted list, which also keeps their memory to the prefixes
  themselves.
- Four fixture apps (SwiftUI with a String Catalog, UIKit with `.strings`, Flutter with ARB, Expo
  with i18next) with their expected findings, terminal demos recorded from the CLI, examples for
  GitHub Actions, shell, the API, a pre-commit hook and a configuration, an API reference and
  guides site, and a release workflow for GitHub releases, npm and Homebrew.

### Removed

- The Swift package (`GlobalLingo` library, CocoaPods spec, examples and documentation). Its
  sources did not compile and its translation, voice and AI engines were placeholders.

## [1.0.0] - 2026-02-02

The Swift translation framework, withdrawn in 2.0.0.

[Unreleased]: https://github.com/muhittincamdali/GlobalLingo/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/muhittincamdali/GlobalLingo/releases/tag/v1.0.0
