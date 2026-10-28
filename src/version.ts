import { readFileSync } from 'node:fs';

// src/ and dist/ are both one level below the package root, so the same relative path works when
// running from source (tests) and from the published package.
const manifest = JSON.parse(readFileSync(new URL('../package.json', import.meta.url), 'utf8')) as {
  version: string;
};

/** Version of the installed GlobalLingo package, read from its package.json. */
export const VERSION: string = manifest.version;

/** The repository; rule documentation links point into it. */
export const REPOSITORY_URL = 'https://github.com/muhittincamdali/GlobalLingo';

/** The branch the documentation links name. */
export const DOCS_BRANCH = 'master';
