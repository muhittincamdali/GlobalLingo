import type { Ecosystem, RuleId } from '../model.js';

/** A finding before the configuration sets its severity and the report adds fix and links. */
export interface Draft {
  rule: RuleId;
  ecosystem: Ecosystem;
  file: string;
  line: number;
  column?: number;
  key?: string;
  locale?: string;
  message: string;
  /**
   * What the finding is about beyond rule, file, key and locale (a placeholder, a category, a
   * literal); with them it makes the fingerprint, so a finding keeps it when lines move.
   */
  subject: string;
}

/** Quotes a key or a value for a message, shortened so a report stays readable. */
export function quote(text: string, max = 60): string {
  const flat = text.replace(/\s+/g, ' ');
  return `"${flat.length > max ? `${flat.slice(0, max - 1)}…` : flat}"`;
}
