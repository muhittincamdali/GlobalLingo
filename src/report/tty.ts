// The terminal report: catalogs with their coverage per locale, then each finding with its fix
// and documentation link, then the totals. Colour is optional and only marks severity.
import type { Finding, Report, Severity } from '../model.js';
import { RULES } from '../rules/registry.js';
import {
  cleanLine,
  FORMAT_LABELS,
  percent,
  plural,
  SYNTAX_LABELS,
  summaryLine,
  wrap,
} from './text.js';

export interface TtyOptions {
  color: boolean;
  width: number;
}

const CODES = {
  bold: [1, 22],
  dim: [2, 22],
  red: [31, 39],
  yellow: [33, 39],
  cyan: [36, 39],
  blue: [34, 39],
} as const;
type Style = keyof typeof CODES;

const LABELS: Record<Severity, string> = { error: 'ERROR', warning: 'WARNING', info: 'INFO' };
const STYLES: Record<Severity, Style> = { error: 'red', warning: 'yellow', info: 'blue' };
const INDENT = '         ';

export function renderTty(report: Report, options: TtyOptions): string {
  const paint = (style: Style, text: string) =>
    options.color ? `\u001b[${CODES[style][0]}m${text}\u001b[${CODES[style][1]}m` : text;
  const width = Math.max(40, options.width);
  const lines: string[] = [];
  lines.push(
    `${paint('bold', `GlobalLingo ${report.tool.version}`)} ${paint('dim', '·')} ${cleanLine(report.path)}`,
  );
  lines.push('');
  for (const catalog of report.catalogs) {
    const kind = `${FORMAT_LABELS[catalog.format]}, ${SYNTAX_LABELS[catalog.syntax]}`;
    lines.push(
      `  ${paint('bold', cleanLine(catalog.id))}  ${paint('dim', `${kind} · source ${cleanLine(catalog.sourceLocale)} · ${plural(catalog.keys, 'key')}`)}`,
    );
    if (catalog.coverage.length > 0) {
      const cells = catalog.coverage.map(
        (item) => `${cleanLine(item.locale)} ${percent(item.translated, item.total)}`,
      );
      for (const line of wrap(cells.join(' · '), width - 4)) lines.push(`    ${line}`);
    }
  }
  if (report.findings.length > 0) lines.push('');
  for (const finding of report.findings) lines.push(...renderFinding(finding, paint, width), '');
  if (report.notes.length > 0) {
    if (report.findings.length === 0) lines.push('');
    lines.push(paint('bold', 'Notes'));
    for (const note of report.notes) {
      const [first = '', ...rest] = wrap(cleanLine(note), width - 4);
      lines.push(`  - ${first}`, ...rest.map((line) => `    ${line}`));
    }
    lines.push('');
  }
  if (report.findings.length === 0 && report.notes.length === 0) lines.push('');
  const { error, warning } = report.summary;
  const mark =
    error > 0 ? paint('red', '✗') : warning > 0 ? paint('yellow', '!') : paint('cyan', '✓');
  lines.push(`${mark} ${summaryLine(report)}`);
  return `${lines.join('\n')}\n`;
}

function renderFinding(
  finding: Finding,
  paint: (style: Style, text: string) => string,
  width: number,
): string[] {
  const label = finding.baselined ? 'BASELINE' : LABELS[finding.severity];
  const style: Style = finding.baselined ? 'dim' : STYLES[finding.severity];
  const where = finding.line > 0 ? `${finding.file}:${finding.line}` : finding.file;
  const head = `${paint(style, paint('bold', label.padEnd(8)))} ${paint('bold', finding.rule)}  ${cleanLine(where)}  ${paint('dim', RULES[finding.rule].title)}`;
  const body = wrap(cleanLine(finding.message), width - INDENT.length).map(
    (line) => `${INDENT}${line}`,
  );
  const fix = wrap(`Fix: ${cleanLine(finding.fix)}`, width - INDENT.length).map(
    (line) => `${INDENT}${paint('dim', line)}`,
  );
  return [head, ...body, ...fix, `${INDENT}${paint('dim', finding.docs)}`];
}
