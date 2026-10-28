// Records the README demos as terminal SVGs (light and dark) in docs/media/: the built CLI runs on
// each fixture from the repository root, as a reader would, and its coloured output becomes an
// animated SVG. Run with `npm run demo` (builds first). The tests check that the committed SVGs
// match what this script writes today.
import { execFileSync } from 'node:child_process';
import { mkdirSync, writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { type Session, terminalSvg } from './terminal-svg.ts';

const ROOT = fileURLToPath(new URL('../', import.meta.url));
export const MEDIA = `${ROOT}docs/media/`;

export interface Demo {
  name: string;
  fixture: string;
  title: string;
  comment: string;
  /** Extra arguments after the fixture path. */
  args?: string[];
}

export const DEMOS: Demo[] = [
  {
    name: 'expo',
    fixture: 'expo-i18next',
    title: 'GlobalLingo · Expo app with i18next',
    comment: '# fixtures/expo-i18next: Expo SDK 58, i18next, en/de/pl/tr',
  },
  {
    name: 'flutter',
    fixture: 'flutter-arb',
    title: 'GlobalLingo · Flutter app with ARB files',
    comment: '# fixtures/flutter-arb: Flutter 3.47.5, gen_l10n, en/de/pl/tr',
  },
  {
    name: 'swiftui',
    fixture: 'swiftui-catalog',
    title: 'GlobalLingo · SwiftUI package with a String Catalog',
    comment: '# fixtures/swiftui-catalog: keys extracted by Xcode 27.1, en/de/fr/pl/tr',
  },
  {
    name: 'uikit',
    fixture: 'uikit-strings',
    title: 'GlobalLingo · UIKit app with .strings and .stringsdict',
    comment: '# fixtures/uikit-strings: XcodeGen project, en/de/ru/tr',
  },
];

/** Runs the CLI for one demo and returns what a terminal would have shown. */
export function record(demo: Demo): Session {
  const env: NodeJS.ProcessEnv = { ...process.env, FORCE_COLOR: '1' };
  delete env.NO_COLOR;
  const args = [`fixtures/${demo.fixture}`, ...(demo.args ?? [])];
  let output: string;
  try {
    output = execFileSync(process.execPath, [`${ROOT}dist/cli/main.js`, ...args], {
      cwd: ROOT,
      env,
      encoding: 'utf8',
    });
  } catch (error) {
    // Exit code 1 means findings; the report is still on stdout.
    output = (error as { stdout?: string }).stdout ?? '';
  }
  return {
    title: demo.title,
    comment: demo.comment,
    command: `npx @mcamdali/globallingo ${args.join(' ')}`,
    output,
  };
}

export const mediaPath = (name: string, theme: 'light' | 'dark') =>
  `${MEDIA}demo-${name}-${theme}.svg`;

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  mkdirSync(MEDIA, { recursive: true });
  for (const demo of DEMOS) {
    const session = record(demo);
    for (const theme of ['light', 'dark'] as const) {
      writeFileSync(mediaPath(demo.name, theme), terminalSvg(session, theme));
    }
    console.log(`docs/media/demo-${demo.name}-{light,dark}.svg`);
  }
}
