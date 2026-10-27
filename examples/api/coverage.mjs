// GlobalLingo from JavaScript: the translation coverage of every catalog, one line per locale,
// and the number of findings per rule. Run from the repository root after `npm run build`:
//
//   node examples/api/coverage.mjs fixtures/expo-i18next
//
// Inside this repository the package name resolves to the package itself (its "exports"), so this
// runs the code you just built; in an app it runs the installed @mcamdali/globallingo.
import { scan } from '@mcamdali/globallingo';

const path = process.argv[2] ?? '.';
const report = await scan(path);

for (const catalog of report.catalogs) {
  console.log(`${catalog.id} (${catalog.keys} keys, source ${catalog.sourceLocale})`);
  for (const { locale, translated, total } of catalog.coverage) {
    const share = total === 0 ? 100 : Math.floor((translated / total) * 100);
    console.log(`  ${locale.padEnd(8)} ${String(share).padStart(3)}%  ${translated}/${total}`);
  }
}

const perRule = new Map();
for (const finding of report.findings) perRule.set(finding.rule, (perRule.get(finding.rule) ?? 0) + 1);
console.log([...perRule].map(([rule, count]) => `${rule} ${count}`).join(', ') || 'No findings');
