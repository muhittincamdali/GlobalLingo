import type { Report } from '../model.js';
import { renderGithub } from './github.js';
import { renderMarkdown } from './markdown.js';
import { renderSarif } from './sarif.js';
import { renderTty, type TtyOptions } from './tty.js';

export const FORMATS = ['tty', 'markdown', 'json', 'sarif', 'github'] as const;
export type Format = (typeof FORMATS)[number];

/**
 * C1 controls and bidirectional controls pass through JSON.stringify unchanged; written as
 * escapes they cannot act on a terminal that prints the JSON. Both only occur inside strings.
 */
const escapeInvisible = (json: string) =>
  json.replace(
    /[\u007F-\u009F\u202A-\u202E\u2066-\u2069]/g,
    (char) => `\\u${(char.codePointAt(0) as number).toString(16).padStart(4, '0')}`,
  );

export function render(
  report: Report,
  format: Format,
  options: TtyOptions = { color: false, width: 100 },
): string {
  switch (format) {
    case 'tty':
      return renderTty(report, options);
    case 'markdown':
      return renderMarkdown(report);
    case 'json':
      return `${escapeInvisible(JSON.stringify(report, null, 2))}\n`;
    case 'sarif':
      return escapeInvisible(renderSarif(report));
    case 'github':
      return renderGithub(report);
  }
}
