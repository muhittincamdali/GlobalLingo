// A baseline file lists the findings a team has accepted for now, so CI fails only on new ones.
// It stores fingerprints (rule, file, key, locale and subject, hashed), not line numbers, so
// findings keep matching when lines move.
import { createHash } from 'node:crypto';
import { readFile, writeFile } from 'node:fs/promises';
import type { Finding } from './model.js';
import { VERSION } from './version.js';

export interface Baseline {
  schemaVersion: 1;
  tool: 'globallingo';
  /** Sorted; a fingerprint appears once per accepted finding. */
  fingerprints: string[];
}

export class BaselineError extends Error {}

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
  let parsed: unknown;
  try {
    const text = await readFile(path, 'utf8');
    if (text.length > 64 * 1024 * 1024) throw new BaselineError(`${path}: larger than 64 MB`);
    parsed = JSON.parse(text);
  } catch (error) {
    if (error instanceof BaselineError) throw error;
    const code = (error as NodeJS.ErrnoException).code;
    throw new BaselineError(`${path}: ${code ?? `not valid JSON (${(error as Error).message})`}`);
  }
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
  await writeFile(path, `${body}\n`);
}
