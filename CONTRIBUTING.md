# Contributing to GlobalLingo

Thanks for taking the time to improve GlobalLingo. The
[shared contributing guide](https://github.com/muhittincamdali/.github/blob/main/CONTRIBUTING.md)
applies (small fixes as a pull request, larger changes as an issue first, security issues through
[SECURITY.md](SECURITY.md), the
[code of conduct](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md) for
everyone). This file adds what is specific to this repository.

## Set up

Node.js 22.12 or later, then:

```sh
git clone https://github.com/muhittincamdali/GlobalLingo.git
cd GlobalLingo
npm ci
npm test          # builds dist/ first, then runs every test
```

CI runs `npm run lint`, `npm run typecheck`, `npm test` and `npm run build` on Node.js 22 and 24;
if they pass locally they pass on your pull request. Tests read only files in the repository and
temporary folders; they need neither the network nor Xcode or Flutter.

| Command                      | What it does                                                                                          |
| ---------------------------- | ----------------------------------------------------------------------------------------------------- |
| `npm run lint`               | Biome (code) and Prettier (formatting); `npm run format` fixes formatting                             |
| `npm run typecheck`          | TypeScript in strict mode over `src/`, `test/` and `scripts/`                                         |
| `npm test`                   | Unit, integration, snapshot and robustness tests                                                      |
| `npm run demo`               | Records the terminal SVGs in `docs/media/` from the CLI                                               |
| `npm run docs`               | Builds the documentation site into `site/` (run `npm ci --prefix docs/site` once first)               |
| `npm run smoke`              | Packs the package, installs the tarball and runs it                                                   |
| `scripts/simulator-shots.sh` | Mac with Xcode 27 and XcodeGen: builds the UIKit fixture and takes the README's simulator screenshots |

## Where things live

- `src/parse/`: JSON, `.strings` and property list readers that keep line numbers and duplicate
  keys, and the text decoder (UTF-8, UTF-16).
- `src/messages/`: placeholder parsers for format specifiers, ICU, i18next and i18n-js.
- `src/catalogs/`: one reader per format into the shared model in `src/model.ts`.
- `src/project/`: the folder walk with its limits, catalog discovery, `l10n.yaml` and
  `package.json` settings.
- `src/rules/`: the rule list with fixes (`registry.ts`) and the catalog checks.
- `src/code/`: the comment-blanking lexer, the source patterns and the code checks.
- `src/report/`: the five output formats. `src/cli/`: arguments and exit codes.
- `fixtures/`: small apps; [fixtures/README.md](fixtures/README.md) says how each was made and
  what mistakes it holds.

## Tests

- A bug fix starts with a test that fails without it. A false positive or a missed finding is
  best reported with the smallest project that shows it; `test/helpers/tree.ts` builds one in a
  temporary folder.
- `test/integration/fixtures.test.ts` lists the expected findings of each fixture; change that
  list deliberately, never to make a run pass. The terminal reports are recorded in
  `test/__snapshots__/fixtures`; after a deliberate change run `npm test -- -u`, read the diff,
  and run `npm run demo` if the terminal output changed.
- Anything that reads files or matches patterns gets a case in
  `test/integration/robustness.test.ts`: deep nesting, huge inputs, links, control characters.

## Adding a rule

1. Add the ID to `RuleId` in `src/model.ts` and the rule, with a fix for each ecosystem, to
   `src/rules/registry.ts`.
2. Add it to `schema/config.schema.json`; a test keeps the two in step.
3. Write a `### <ID>` section in [docs/rules.md](docs/rules.md) with the sources it rests on
   (Apple's, Flutter's, Unicode's or the library's own documentation); the reports link there and a
   test fails without it.
4. Add the mistake to a fixture when it fits one, and list it in `fixtures/README.md`.

## Wording

GlobalLingo reports what it can show. A message says what is in the file and what that does at
run time, as far as the platform's documentation or a recorded run says so; anything else is
"may" or left out. Keep planned features marked as planned. The hygiene check in CI rejects
unverifiable superlatives.

## Commits and pull requests

[Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) (`feat:`, `fix:`, `docs:`,
`test:`, `refactor:`, `build:`, `ci:`, `chore:`), one topic per pull request, and an entry under
"Unreleased" in [CHANGELOG.md](CHANGELOG.md) for anything a user would notice.

## Releases

Maintainers bump `version` in `package.json`, move the "Unreleased" entries under the new version
in `CHANGELOG.md`, and push a `v<version>` tag. The release workflow checks, packs and publishes;
see the comment at the top of `.github/workflows/release.yml`.

## License

By contributing, you agree that your contributions are licensed under the [MIT license](LICENSE).
