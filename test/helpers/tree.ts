import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { afterAll } from 'vitest';

const roots: string[] = [];
afterAll(() => {
  for (const root of roots) rmSync(root, { recursive: true, force: true });
});

/** Writes the given files (path relative to the root → content) into a new temporary folder. */
export function tree(files: Record<string, string | Uint8Array>): string {
  const root = mkdtempSync(join(tmpdir(), 'globallingo-test-'));
  roots.push(root);
  for (const [path, content] of Object.entries(files)) {
    const file = join(root, path);
    mkdirSync(dirname(file), { recursive: true });
    writeFileSync(file, content);
  }
  return root;
}

/** A String Catalog with the given strings, as Xcode writes it. */
export function xcstrings(strings: Record<string, unknown>, sourceLanguage = 'en'): string {
  return `${JSON.stringify({ sourceLanguage, strings, version: '1.1' }, null, 2)}\n`;
}

/** A string unit, the leaf of a String Catalog localization. */
export const unit = (value: string, state = 'translated') => ({ stringUnit: { state, value } });

/** A stringsdict file with one plural entry. */
export function stringsdict(
  entries: Record<
    string,
    { format: string; variable: string; type: string; forms: Record<string, string> }
  >,
): string {
  const body = Object.entries(entries)
    .map(
      ([key, entry]) => `\t<key>${key}</key>
\t<dict>
\t\t<key>NSStringLocalizedFormatKey</key>
\t\t<string>${entry.format}</string>
\t\t<key>${entry.variable}</key>
\t\t<dict>
\t\t\t<key>NSStringFormatSpecTypeKey</key>
\t\t\t<string>NSStringPluralRuleType</string>
\t\t\t<key>NSStringFormatValueTypeKey</key>
\t\t\t<string>${entry.type}</string>
${Object.entries(entry.forms)
  .map(([category, text]) => `\t\t\t<key>${category}</key>\n\t\t\t<string>${text}</string>`)
  .join('\n')}
\t\t</dict>
\t</dict>`,
    )
    .join('\n');
  return `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
${body}
</dict>
</plist>
`;
}
