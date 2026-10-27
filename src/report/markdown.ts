// The Markdown report, for a pull request comment or a CI job summary.
import type { Report } from '../model.js';
import { RULES } from '../rules/registry.js';
import { cleanLine, FORMAT_LABELS, percent, plural, summaryLine } from './text.js';

/** Escapes text for a Markdown table cell or paragraph, so file content cannot add markup or lines. */
export function escapeMarkdown(text: string): string {
  return cleanLine(text).replace(/[\\`*_{}[\]()#+!|<>~]/g, '\\$&');
}

export function renderMarkdown(report: Report): string {
  const lines: string[] = [];
  lines.push(`## GlobalLingo: ${escapeMarkdown(summaryLine(report))}`, '');
  lines.push(
    '| Catalog | Format | Source | Keys | Translated |',
    '| --- | --- | --- | ---: | --- |',
  );
  for (const catalog of report.catalogs) {
    const coverage =
      catalog.coverage
        .map((item) => `${escapeMarkdown(item.locale)} ${percent(item.translated, item.total)}`)
        .join(', ') || 'source only';
    lines.push(
      `| ${escapeMarkdown(catalog.id)} | ${FORMAT_LABELS[catalog.format]} | ${escapeMarkdown(catalog.sourceLocale)} | ${catalog.keys} | ${coverage} |`,
    );
  }
  lines.push('');
  const active = report.findings.filter((finding) => !finding.baselined);
  if (active.length > 0) {
    lines.push('| Severity | Rule | Where | Finding | Fix |', '| --- | --- | --- | --- | --- |');
    for (const finding of active) {
      const where = finding.line > 0 ? `${finding.file}:${finding.line}` : finding.file;
      lines.push(
        `| ${finding.severity} | [${finding.rule}](${finding.docs}) ${escapeMarkdown(RULES[finding.rule].title)} | \`${cleanLine(where).replace(/`/g, "'").replace(/\|/g, '\\|')}\` | ${escapeMarkdown(finding.message)} | ${escapeMarkdown(finding.fix)} |`,
      );
    }
    lines.push('');
  }
  const baselined = report.findings.length - active.length;
  if (baselined > 0)
    lines.push(
      `${plural(baselined, 'finding')} in the baseline file ${baselined === 1 ? 'is' : 'are'} not listed.`,
      '',
    );
  if (report.notes.length > 0) {
    lines.push('<details><summary>Notes</summary>', '');
    for (const note of report.notes) lines.push(`- ${escapeMarkdown(note)}`);
    lines.push('', '</details>', '');
  }
  lines.push(`<sub>GlobalLingo ${report.tool.version}</sub>`);
  return `${lines.join('\n')}\n`;
}
