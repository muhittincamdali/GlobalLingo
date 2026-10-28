# Run GlobalLingo in CI

GlobalLingo reads files, needs only Node.js, and exits with 1 when it finds something at or above
`--fail-on` (`error` by default). Any CI system that can run `npx` can run it; this guide uses
GitHub Actions.

## The smallest job

```yaml
- uses: actions/setup-node@949feb2413d6458794dcd2491c4babbbce0c15c1 # v7.1.0
  with:
    node-version: '24'
- run: npx --yes @mcamdali/globallingo@2
```

Exit code 2 means GlobalLingo could not run: a bad argument or setting, or no localization
files in the folder. A wrong path therefore fails the job instead of passing it quietly.

## Report in the pull request

[examples/github-actions/globallingo.yml](../../examples/github-actions/globallingo.yml) is a
complete workflow to copy. It writes three reports in one run:

1. **Annotations** (`--format github`): each finding appears on the changed line of the pull
   request, as an error, a warning or a notice.
2. **Job summary** (`--format markdown`): the coverage of each catalog per locale and a table of
   findings with fixes.
3. **Code scanning** (`--format sarif`): the findings in the Security tab, tracked across runs.
   Uploading SARIF needs `security-events: write`; on a private repository it also needs GitHub
   Advanced Security. See
   [Uploading a SARIF file to GitHub](https://docs.github.com/en/code-security/code-scanning/integrating-with-code-scanning/uploading-a-sarif-file-to-github).

One run writes one format, so the example runs the command once per format.

## Start with a baseline

A project that already has hundreds of findings should not have to fix them all before the check
can be required. Accept today's findings once, commit the file, and fail only on new ones:

```sh
npx @mcamdali/globallingo --write-baseline .globallingo-baseline.json
git add .globallingo-baseline.json
```

```yaml
- run: npx --yes @mcamdali/globallingo@2 --baseline .globallingo-baseline.json
```

Fingerprints do not contain line numbers, so moving code does not invalidate the baseline.
Rewrite the file after a clean-up to lock the progress in.

## Choose what fails

| Setting                     | Fails on                                                                                                                  |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| `--fail-on error` (default) | missing and empty translations, placeholder mismatches, invalid syntax, duplicates, unknown keys, plurals without `other` |
| `--fail-on warning`         | also missing plural forms, stale and orphan keys, hard-coded text, Turkish I traps                                        |
| `--fail-on info`            | also untranslated copies of the source and unused keys                                                                    |
| `--fail-on none`            | nothing: report only                                                                                                      |

`rules` in [.globallingo.json](../configuration.md) moves a single rule up or down, e.g.
`"HCS001": "error"` once the code has no hard-coded text left.

## Only some locales

A release that ships German and Turkish first can require those two and leave the others for
later:

```sh
npx @mcamdali/globallingo --locales de,tr
```

A listed locale that a catalog has no file for is a finding of its own (MIS001).

## Before a commit

[examples/pre-commit/pre-commit](../../examples/pre-commit/pre-commit) runs GlobalLingo on
`git commit` when a localization file is staged. Copy it to `.git/hooks/pre-commit` or call it
from your hook manager.

## Other CI systems

The command is the same everywhere. Write `--format markdown --output globallingo.md` and attach
the file, or `--format json` and process it; [examples/shell/errors-by-locale.sh](../../examples/shell/errors-by-locale.sh)
counts errors per locale with `jq`.
