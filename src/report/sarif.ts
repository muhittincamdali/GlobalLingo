// SARIF 2.1.0, for GitHub code scanning and other tools that read static analysis results.
// https://docs.oasis-open.org/sarif/sarif/v2.1.0/sarif-v2.1.0.html
import type { Report, RuleId, Severity } from '../model.js';
import { RULE_IDS, RULES, ruleDocs } from '../rules/registry.js';
import { REPOSITORY_URL } from '../version.js';

const LEVELS: Record<Severity, 'error' | 'warning' | 'note'> = {
  error: 'error',
  warning: 'warning',
  info: 'note',
};

export function renderSarif(report: Report): string {
  const rules = RULE_IDS.map((id: RuleId) => ({
    id,
    name: RULES[id].title.replace(/[^A-Za-z0-9]+(.)?/g, (_match, next: string | undefined) =>
      (next ?? '').toUpperCase(),
    ),
    shortDescription: { text: RULES[id].title },
    fullDescription: { text: RULES[id].summary },
    helpUri: ruleDocs(id),
    help: { text: `${RULES[id].summary} See ${ruleDocs(id)}` },
    defaultConfiguration: { level: LEVELS[RULES[id].severity] },
  }));
  const results = report.findings.map((finding) => ({
    ruleId: finding.rule,
    ruleIndex: RULE_IDS.indexOf(finding.rule),
    level: LEVELS[finding.severity],
    message: { text: `${finding.message}. Fix: ${finding.fix}` },
    locations: [
      {
        physicalLocation: {
          artifactLocation: { uri: encodeURI(finding.file), uriBaseId: '%SRCROOT%' },
          ...(finding.line > 0
            ? {
                region: {
                  startLine: finding.line,
                  ...(finding.column ? { startColumn: finding.column } : {}),
                },
              }
            : {}),
        },
      },
    ],
    partialFingerprints: { 'globallingo/v1': finding.fingerprint },
    ...(finding.baselined
      ? { suppressions: [{ kind: 'external', justification: 'In the GlobalLingo baseline file' }] }
      : {}),
  }));
  const sarif = {
    $schema: 'https://json.schemastore.org/sarif-2.1.0.json',
    version: '2.1.0',
    runs: [
      {
        tool: {
          driver: {
            name: 'GlobalLingo',
            version: report.tool.version,
            semanticVersion: report.tool.version,
            informationUri: REPOSITORY_URL,
            rules,
          },
        },
        results,
      },
    ],
  };
  return `${JSON.stringify(sarif, null, 2)}\n`;
}
