// GitHub Actions workflow commands: one annotation per finding, shown on the pull request's
// changed lines and in the job summary.
// https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-commands
import type { Report, Severity } from '../model.js';
import { clean, summaryLine } from './text.js';

const COMMANDS: Record<Severity, string> = { error: 'error', warning: 'warning', info: 'notice' };

/** Escapes a message: `%`, CR and LF would end or change the command. */
const escapeData = (text: string) =>
  clean(text).replace(/%/g, '%25').replace(/\r/g, '%0D').replace(/\n/g, '%0A');

/** Escapes a property value, where `:` and `,` also separate fields. */
const escapeProperty = (text: string) => escapeData(text).replace(/:/g, '%3A').replace(/,/g, '%2C');

export function renderGithub(report: Report): string {
  const lines: string[] = [];
  for (const finding of report.findings) {
    if (finding.baselined) continue;
    const properties = [`file=${escapeProperty(finding.file)}`];
    if (finding.line > 0) properties.push(`line=${finding.line}`);
    properties.push(
      `title=${escapeProperty(`${finding.rule} ${finding.key ? finding.key : finding.file}`)}`,
    );
    lines.push(
      `::${COMMANDS[finding.severity]} ${properties.join(',')}::${escapeData(`${finding.message}. Fix: ${finding.fix} ${finding.docs}`)}`,
    );
  }
  lines.push(`GlobalLingo ${report.tool.version}: ${escapeData(summaryLine(report))}`);
  return `${lines.join('\n')}\n`;
}
