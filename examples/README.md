# Examples

| Example                                                          | What it shows                                                                                                                                         |
| ---------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| [github-actions/globallingo.yml](github-actions/globallingo.yml) | A workflow for an app repository: annotations on the pull request, the report in the job summary, SARIF for code scanning, and a failed job on errors |
| [shell/errors-by-locale.sh](shell/errors-by-locale.sh)           | The JSON report filtered with `jq`: errors per locale and per rule                                                                                    |
| [api/coverage.mjs](api/coverage.mjs)                             | GlobalLingo from JavaScript: coverage per catalog and locale, findings per rule                                                                       |
| [pre-commit/pre-commit](pre-commit/pre-commit)                   | A Git hook that checks the translations when a localization file is staged                                                                            |
| [config/.globallingo.json](config/.globallingo.json)             | A configuration with required locales, ignored paths and keys, and rule settings                                                                      |

Run the shell and API examples from the repository root after `npm ci && npm run build`:

```sh
sh examples/shell/errors-by-locale.sh fixtures/expo-i18next
node examples/api/coverage.mjs fixtures/flutter-arb
node dist/cli/main.js fixtures/expo-i18next --config examples/config/.globallingo.json
```

`coverage.mjs` imports `@mcamdali/globallingo` by name; inside this repository that resolves to the
package itself, so it runs the code you just built. The tests run all three on every change
([test/integration/examples.test.ts](../test/integration/examples.test.ts)), and actionlint checks
the workflow.
