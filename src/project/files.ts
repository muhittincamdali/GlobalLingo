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
