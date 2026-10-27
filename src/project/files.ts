// Walks the project folder once, with limits: symbolic links are not followed, dependency and
// build folders are skipped, and the walk stops after MAX_ENTRIES entries or MAX_DEPTH levels, so
// a huge or looping tree cannot hold up a CI job.
import type { Dirent } from 'node:fs';
import { constants } from 'node:fs';
import type { FileHandle } from 'node:fs/promises';
import { open, readdir } from 'node:fs/promises';
import { join } from 'node:path';

/** Folders that hold dependencies, build output or tool state, never an app's own files. */
export const SKIPPED_FOLDERS = new Set([
  'node_modules',
  'Pods',
  'Carthage',
  '.git',
  '.hg',
  '.svn',
  'build',
  '.build',
  'DerivedData',
  '.dart_tool',
  '.gradle',
  '.idea',
  '.vscode',
  '.expo',
  '.next',
  '.turbo',
  '.swiftpm',
  'xcuserdata',
  'dist',
  'coverage',
  'vendor',
  '.fvm',
  '.symlinks',
  'ephemeral',
]);

export const MAX_ENTRIES = 200_000;
export const MAX_DEPTH = 24;
/** Larger catalogs exist only by mistake; reading them would only slow the run down. */
export const MAX_CATALOG_BYTES = 16 * 1024 * 1024;
export const MAX_SOURCE_BYTES = 2 * 1024 * 1024;

export interface WalkResult {
  /** Files, relative to the root with `/` separators, sorted. */
  files: string[];
  notes: string[];
}

export async function walk(
  root: string,
  isIgnored: (path: string) => boolean,
): Promise<WalkResult> {
  const files: string[] = [];
  const notes: string[] = [];
  let entries = 0;
  let truncated = false;
  const visit = async (relative: string, depth: number): Promise<void> => {
    if (truncated) return;
    if (depth > MAX_DEPTH) {
      notes.push(`${relative}: deeper than ${MAX_DEPTH} folders; not read`);
      return;
    }
    let children: Dirent[];
    try {
      children = await readdir(join(root, relative), { withFileTypes: true });
    } catch (error) {
      notes.push(
        `${relative || '.'}: ${(error as NodeJS.ErrnoException).code ?? 'not readable'}; not read`,
      );
      return;
    }
    children.sort((a, b) => (a.name < b.name ? -1 : a.name > b.name ? 1 : 0));
    for (const child of children) {
      entries += 1;
      if (entries > MAX_ENTRIES) {
        truncated = true;
        notes.push(
          `Stopped after ${MAX_ENTRIES} files and folders; point GlobalLingo at the app's folder`,
        );
        return;
      }
      const path = relative ? `${relative}/${child.name}` : child.name;
      if (child.isSymbolicLink()) continue;
      if (isIgnored(path)) continue;
      if (child.isDirectory()) {
        if (SKIPPED_FOLDERS.has(child.name)) continue;
        await visit(path, depth + 1);
      } else if (child.isFile()) {
        files.push(path);
      }
    }
  };
  await visit('', 0);
  return { files, notes };
}

/**
 * Writes a report or baseline without following a symbolic link at the path: a link committed
 * under the report's name cannot redirect the write to another file.
 */
export async function writeOwnFile(path: string, text: string): Promise<void> {
  const flags =
    constants.O_WRONLY | constants.O_CREAT | constants.O_TRUNC | (constants.O_NOFOLLOW ?? 0);
  const handle = await open(path, flags, 0o644);
  try {
    await handle.writeFile(text);
  } finally {
    await handle.close();
  }
}

export type ReadResult = { bytes: Uint8Array } | { problem: string };

/**
 * Reads a regular file of at most `limit` bytes; anything else gets a reason instead. The file is
 * opened first and checked through the open handle, so a symbolic link or a larger file swapped
 * in after the check cannot be what is read. O_NONBLOCK keeps a named pipe from blocking the open.
 */
export async function readLimited(root: string, path: string, limit: number): Promise<ReadResult> {
  const flags = constants.O_RDONLY | (constants.O_NOFOLLOW ?? 0) | (constants.O_NONBLOCK ?? 0);
  let handle: FileHandle;
  try {
    handle = await open(join(root, path), flags);
  } catch (error) {
    const code = (error as NodeJS.ErrnoException).code;
    // O_NOFOLLOW refuses a link with ELOOP (Linux, macOS) or EMLINK (FreeBSD).
    if (code === 'ELOOP' || code === 'EMLINK') return { problem: NOT_REGULAR };
    return { problem: code ?? 'not readable' };
  }
  try {
    const info = await handle.stat();
    if (!info.isFile()) return { problem: NOT_REGULAR };
    if (info.size > limit) return { problem: tooLarge(limit) };
    // One byte more than the size seen, to notice a file that grew since.
    const bytes = new Uint8Array(info.size + 1);
    let length = 0;
    while (length < bytes.length) {
      const { bytesRead } = await handle.read(bytes, length, bytes.length - length, length);
      if (bytesRead === 0) break;
      length += bytesRead;
    }
    if (length > info.size) return { problem: 'changed while being read; not read' };
    return { bytes: bytes.subarray(0, length) };
  } catch (error) {
    return { problem: (error as NodeJS.ErrnoException).code ?? 'not readable' };
  } finally {
    await handle.close();
  }
}

const NOT_REGULAR = 'not a regular file';
const tooLarge = (limit: number) => `larger than ${Math.round(limit / 1024 / 1024)} MB; not read`;

type GlobToken = { kind: 'char'; char: string } | { kind: 'one' | 'star' | 'any' | 'dirs' };

function tokenize(pattern: string): GlobToken[] {
  const text = pattern.replace(/^\.\//, '');
  const tokens: GlobToken[] = [];
  for (let i = 0; i < text.length; i += 1) {
    const char = text[i] as string;
    if (char === '*' && text[i + 1] === '*') {
      while (text[i + 1] === '*') i += 1;
      const dirs = text[i + 1] === '/';
      if (dirs) i += 1;
      // "**/**/" is "**/": repeated wildcards would only cost time.
      const previous = tokens[tokens.length - 1];
      if (!(previous && (previous.kind === 'dirs' || previous.kind === 'any'))) {
        tokens.push({ kind: dirs ? 'dirs' : 'any' });
      }
    } else if (char === '*') {
      if (tokens[tokens.length - 1]?.kind !== 'star') tokens.push({ kind: 'star' });
    } else if (char === '?') {
      tokens.push({ kind: 'one' });
    } else {
      tokens.push({ kind: 'char', char });
    }
  }
  return tokens;
}

/**
 * Whether the tokens match the whole text. Dynamic programming over (token, position), so the
 * time is at most tokens × length whatever the pattern: no backtracking for a crafted glob.
 */
function matchTokens(tokens: GlobToken[], text: string): boolean {
  let row = new Uint8Array(text.length + 1);
  row[0] = 1;
  for (const token of tokens) {
    const next = new Uint8Array(text.length + 1);
    let seen = 0;
    for (let j = 0; j <= text.length; j += 1) {
      const before = text[j - 1];
      switch (token.kind) {
        case 'char':
          next[j] = j > 0 && row[j - 1] && before === token.char ? 1 : 0;
          break;
        case 'one':
          next[j] = j > 0 && row[j - 1] && before !== '/' ? 1 : 0;
          break;
        case 'star':
          next[j] = row[j] || (j > 0 && next[j - 1] && before !== '/') ? 1 : 0;
          break;
        case 'any':
          next[j] = row[j] || (j > 0 && next[j - 1]) ? 1 : 0;
          break;
        case 'dirs':
          // Nothing, or anything that ends with a slash.
          next[j] = row[j] || (seen && before === '/') ? 1 : 0;
          break;
      }
      if (row[j]) seen = 1;
    }
    row = next;
  }
  return row[text.length] === 1;
}

/** Turns globs (`**`, `*`, `?`) matched against paths from the project root into a test. */
export function globMatcher(patterns: readonly string[]): (path: string) => boolean {
  if (patterns.length === 0) return () => false;
  const compiled = patterns.map(tokenize);
  return (path) => {
    // A folder pattern also covers everything below it.
    const candidates = [path];
    for (let index = path.indexOf('/'); index !== -1; index = path.indexOf('/', index + 1)) {
      candidates.push(path.slice(0, index));
    }
    return compiled.some((tokens) =>
      candidates.some((candidate) => matchTokens(tokens, candidate)),
    );
  };
}
