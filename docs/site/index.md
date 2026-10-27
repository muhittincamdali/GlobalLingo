# GlobalLingo

GlobalLingo lints the localization files of iOS, Flutter and React Native/Expo apps: String
Catalogs, `.strings` and `.stringsdict`, ARB files and JSON translation files. It finds missing,
empty and stale translations, placeholders and plural forms that do not match across languages,
duplicate keys, keys the code looks up but no catalog defines, hard-coded UI text and Turkish
dotted and dotless I traps, and names the fix for each finding. It reads files only.

```sh
npx @mcamdali/globallingo
```

## Reference

- [Rules](../rules.md): what each rule checks, with sources
- [Configuration](../configuration.md): `.globallingo.json`, baselines, limits

## Guides

- [Run GlobalLingo in CI](../guides/ci.md)
- [Placeholders and plurals across Apple, Flutter and JavaScript](../guides/placeholders-and-plurals.md)
- [The Turkish I](../guides/turkish-i.md)

## API

The command line is a thin layer over the package's exports, so the same checks run from
JavaScript:

```ts
import { render, scan } from '@mcamdali/globallingo';

const report = await scan('path/to/app', { locales: ['de', 'tr'] });
for (const catalog of report.catalogs) {
  console.log(
    catalog.id,
    catalog.coverage.map((item) => `${item.locale} ${item.translated}/${item.total}`).join(', '),
  );
}
console.log(render(report, 'markdown'));
```

`scan` returns a `Report`: the catalogs with their coverage per locale, the findings (rule,
severity, file, line, key, locale, message, fix, documentation link, fingerprint), notes and
totals. `render` turns it into `tty`, `markdown`, `json`, `sarif` or `github` output.
