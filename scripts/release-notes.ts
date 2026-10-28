// Prints the CHANGELOG.md section of one version, the body of its GitHub release:
//
//   node scripts/release-notes.ts 0.1.0 > notes.md
//
// Exits 1 when the section is missing or empty, so a release cannot go out without notes.
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

/** The text under `## [version]` up to the next `## ` heading, without the heading itself. */
export function releaseNotes(changelog: string, version: string): string {
  const lines = changelog.split('\n');
  const start = lines.findIndex((line) => line.startsWith(`## [${version}]`));
  if (start === -1) throw new Error(`CHANGELOG.md has no section for ${version}.`);
  const end = lines.findIndex((line, index) => index > start && line.startsWith('## '));
  const body = lines
    .slice(start + 1, end === -1 ? undefined : end)
    // Link reference definitions at the bottom of the file are not part of the section.
    .filter((line) => !/^\[[^\]]+\]: /.test(line))
    .join('\n')
    .trim();
  if (!body) throw new Error(`The ${version} section of CHANGELOG.md is empty.`);
  return `${body}\n`;
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const version = process.argv[2] ?? '';
  const changelog = readFileSync(
    fileURLToPath(new URL('../CHANGELOG.md', import.meta.url)),
    'utf8',
  );
  try {
    process.stdout.write(releaseNotes(changelog, version));
  } catch (error) {
    console.error((error as Error).message);
    process.exitCode = 1;
  }
}
