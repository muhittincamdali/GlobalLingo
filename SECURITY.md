# Security policy

## Supported versions

Security fixes are made for the latest release of each project. If you are on an older version,
the fix will be in a new release and the upgrade notes will say if anything changes for you.

## Reporting a vulnerability

Please report vulnerabilities privately, not in a public issue, pull request or discussion.

1. **Preferred:** open the repository's **Security** tab and choose
   **Report a vulnerability** ([how private reporting works](https://docs.github.com/en/code-security/how-tos/report-and-fix-vulnerabilities/report-privately)).
2. **Or** email [muhittincamdali@gmail.com](mailto:muhittincamdali@gmail.com) with
   "Security" in the subject.

Include what you can of the following:

- the affected repository and version (tag or commit),
- what an attacker can do and under which conditions,
- steps or a small project that reproduces it,
- any fix or mitigation you already have in mind.

## What happens next

- You get a reply within 7 days confirming that the report arrived.
- I confirm the issue, work on a fix and agree a disclosure date with you. Fixes are released as
  soon as they are ready, together with a GitHub security advisory.
- You are credited in the advisory unless you prefer not to be.

Please give a reasonable amount of time to fix the issue before disclosing it publicly.

## Scope for GlobalLingo

GlobalLingo reads the files of the folder you point it at: String Catalogs, `.strings` and
`.stringsdict` files, ARB files and `l10n.yaml`, JSON translation files, `package.json`, the
`developmentRegion` of `project.pbxproj`, `.globallingo.json`, and Swift, Objective-C, Dart and
JavaScript/TypeScript source files. It writes only the report (`--output`) or baseline
(`--write-baseline`) you ask for, makes no network requests, never runs project code, and has no
runtime dependencies.

Its reports quote the project's own keys, translations, file names and code literals, and contain
nothing else from your machine. A CI log that shows the report shows those quotes.

What it guards against, with tests in
[test/integration/robustness.test.ts](test/integration/robustness.test.ts): symbolic links are not
followed while reading the folder; a `.globallingo.json` or baseline that is a link is refused unread,
and a JSON error in either names the line, never the text; reports and baselines are not written
through a link; JSON, property list and ICU readers stop at a nesting limit; source patterns and ignore
globs run in time linear in the input; catalogs over 16 MB, source files over 2 MB, more than
200,000 files, 24 folder levels or 100,000 findings are not read or kept; and control characters
and bidirectional overrides from the project are escaped in every output format.

Reports that fit this policy include, for example: a crafted file or configuration that makes
GlobalLingo write outside the file you named, follow a link out of the folder, run code, hang,
exhaust memory, or print terminal escape sequences.
