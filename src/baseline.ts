// A baseline file lists the findings a team has accepted for now, so CI fails only on new ones.
// It stores fingerprints (rule, file, key, locale and subject, hashed), not line numbers, so
// findings keep matching when lines move.
import { createHash } from 'node:crypto';
import { parseSettingsJson } from './config.js';
import type { Finding } from './model.js';
import { readLimited, writeOwnFile } from './project/files.js';
import { VERSION } from './version.js';

export interface Baseline {
  schemaVersion: 1;
  tool: 'globallingo';
  /** Sorted; a fingerprint appears once per accepted finding. */
  fingerprints: string[];
}

export class BaselineError extends Error {}

const MAX_BASELINE_BYTES = 64 * 1024 * 1024;

export function fingerprint(parts: {
  rule: string;
  file: string;
  key?: string | undefined;
  locale?: string | undefined;
  subject: string;
}): string {
  const text = [parts.rule, parts.file, parts.key ?? '', parts.locale ?? '', parts.subject].join(
    '\u0000',
  );
  return createHash('sha256').update(text).digest('hex').slice(0, 20);
}

/** Marks the findings the baseline lists; each fingerprint in the file covers one finding. */
export function applyBaseline(findings: Finding[], baseline: Baseline): void {
  const remaining = new Map<string, number>();
  for (const print of baseline.fingerprints) remaining.set(print, (remaining.get(print) ?? 0) + 1);
  for (const finding of findings) {
    const count = remaining.get(finding.fingerprint) ?? 0;
    if (count > 0) {
      finding.baselined = true;
      remaining.set(finding.fingerprint, count - 1);
    }
  }
}

export function createBaseline(findings: Finding[]): Baseline {
  return {
    schemaVersion: 1,
    tool: 'globallingo',
    fingerprints: findings.map((finding) => finding.fingerprint).sort(),
  };
}

export async function readBaseline(path: string): Promise<Baseline> {
  // A regular file only, like the configuration: a link could point at a file with secrets.
  const read = await readLimited('', path, MAX_BASELINE_BYTES);
  if ('problem' in read) throw new BaselineError(`${path}: ${read.problem}`);
  const parsed = parseSettingsJson(
    new TextDecoder().decode(read.bytes),
    path,
    (message) => new BaselineError(message),
  );
  const value = parsed as Partial<Baseline> | null;
  if (
    value?.tool !== 'globallingo' ||
    value.schemaVersion !== 1 ||
    !Array.isArray(value.fingerprints) ||
    value.fingerprints.some((item) => typeof item !== 'string' || !/^[0-9a-f]{20}$/.test(item))
  ) {
    throw new BaselineError(
      `${path}: not a GlobalLingo baseline (write one with --write-baseline)`,
    );
  }
  return value as Baseline;
}

export async function writeBaseline(path: string, findings: Finding[]): Promise<void> {
  const baseline = createBaseline(findings);
  const body = JSON.stringify({ ...baseline, toolVersion: VERSION }, null, 2);
  await writeOwnFile(path, `${body}\n`);
}
