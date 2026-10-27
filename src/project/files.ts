// Walks the project folder once, with limits: symbolic links are not followed, dependency and
// build folders are skipped, and the walk stops after MAX_ENTRIES entries or MAX_DEPTH levels, so
// a huge or looping tree cannot hold up a CI job.
import type { Dirent } from 'node:fs';
import { lstat, readdir, readFile } from 'node:fs/promises';
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

export type ReadResult = { bytes: Uint8Array } | { problem: string };

/** Reads a regular file of at most `limit` bytes; anything else gets a reason instead. */
export async function readLimited(root: string, path: string, limit: number): Promise<ReadResult> {
  try {
    const info = await lstat(join(root, path));
    if (!info.isFile()) return { problem: 'not a regular file' };
    if (info.size > limit) {
      return { problem: `larger than ${Math.round(limit / 1024 / 1024)} MB; not read` };
    }
    return { bytes: await readFile(join(root, path)) };
  } catch (error) {
    return { problem: (error as NodeJS.ErrnoException).code ?? 'not readable' };
  }
}

/** Turns a glob (`**`, `*`, `?`) matched against paths from the project root into a test. */
export function globMatcher(patterns: readonly string[]): (path: string) => boolean {
  if (patterns.length === 0) return () => false;
  const expressions = patterns.map((pattern) => {
    let source = '';
    const text = pattern.replace(/^\.\//, '');
    for (let i = 0; i < text.length; i += 1) {
      const char = text[i] as string;
      if (char === '*' && text[i + 1] === '*') {
        if (text[i + 2] === '/') {
          source += '(?:.*/)?';
          i += 2;
        } else {
          source += '.*';
          i += 1;
        }
      } else if (char === '*') {
        source += '[^/]*';
      } else if (char === '?') {
        source += '[^/]';
      } else {
        source += char.replace(/[\\^$.|+()[\]{}]/g, '\\$&');
      }
    }
    // A folder pattern also covers everything below it.
    return new RegExp(`^${source}(?:/.*)?$`);
  });
  return (path) => expressions.some((expression) => expression.test(path));
}
