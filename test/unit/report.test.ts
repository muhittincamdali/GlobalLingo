import { describe, expect, it } from 'vitest';
import type { Finding, Report } from '../../src/model.ts';
import { render } from '../../src/report/index.ts';
import { escapeMarkdown } from '../../src/report/markdown.ts';
import { clean, cleanLine, summaryLine, wrap } from '../../src/report/text.ts';
import { RULE_IDS } from '../../src/rules/registry.ts';

const finding = (overrides: Partial<Finding> = {}): Finding => ({
  rule: 'MIS001',
  severity: 'error',
  file: 'locales/de.json',
  line: 3,
  key: 'cart.title',
  locale: 'de',
  message: '"cart.title" has no German (de) translation',
  fix: "Add the key to this locale's translation file.",
  docs: 'https://github.com/muhittincamdali/GlobalLingo/blob/master/docs/rules.md#mis001',
  fingerprint: '0123456789abcdef0123',
  ...overrides,
});

const report = (findings: Finding[], notes: string[] = []): Report => ({
  schemaVersion: 1,
  tool: { name: 'globallingo', version: '2.0.0' },
  path: 'app',
  ecosystems: ['js'],
  catalogs: [
    {
      id: 'locales/*.json',
      name: 'locales',
      format: 'json',
      syntax: 'i18next',
      sourceLocale: 'en',
      locales: ['en', 'de'],
      keys: 4,
      coverage: [{ locale: 'de', translated: 3, total: 4 }],
    },
  ],
  sourceFiles: 2,
  findings,
  notes,
  summary: {
    error: findings.filter((item) => !item.baselined && item.severity === 'error').length,
    warning: findings.filter((item) => !item.baselined && item.severity === 'warning').length,
    info: findings.filter((item) => !item.baselined && item.severity === 'info').length,
    baselined: findings.filter((item) => item.baselined).length,
  },
});

const hostile = 'key\u001b]8;;https://evil\u0007\u202Eevil\u009B2J';

describe('text helpers', () => {
  it('makes control and bidirectional characters visible', () => {
    expect(clean(hostile)).toBe('key\\u{001B}]8;;https://evil\\u{0007}\\u{202E}evil\\u{009B}2J');
    expect(clean('Tab\there\nnew line, مرحبا')).toBe('Tab\there\nnew line, مرحبا');
  });

  it('keeps one-line text on one line', () => {
    expect(cleanLine('a\tb\nc\r\nd\u2028e')).toBe(
      'a\\u{0009}b\\u{000A}c\\u{000D}\\u{000A}d\\u{2028}e',
    );
    expect(cleanLine(hostile)).toBe(clean(hostile));
  });

  it('wraps on spaces and summarises a report', () => {
    expect(wrap('one two three four', 9)).toEqual(['one two', 'three', 'four']);
    expect(
      summaryLine(
        report([finding(), finding({ severity: 'warning' }), finding({ baselined: true })]),
      ),
    ).toBe('1 error, 1 warning in 1 catalog and 2 source files (1 more in the baseline)');
    expect(summaryLine(report([]))).toBe('No findings in 1 catalog and 2 source files');
  });
});

describe('tty', () => {
  it('prints coverage, findings with fix and link, notes and the summary', () => {
    const text = render(report([finding()], ['lib/x.dart: larger than 2 MB; not read']), 'tty');
    expect(text).toContain('locales/*.json  JSON, i18next · source en · 4 keys');
    expect(text).toContain('    de 75%');
    expect(text).toContain('ERROR    MIS001  locales/de.json:3  Missing translation');
    expect(text).toContain("Fix: Add the key to this locale's translation file.");
    expect(text).toContain(
      'https://github.com/muhittincamdali/GlobalLingo/blob/master/docs/rules.md#mis001',
    );
    expect(text).toContain('  - lib/x.dart: larger than 2 MB; not read');
    expect(text.trimEnd().endsWith('✗ 1 error in 1 catalog and 2 source files')).toBe(true);
    expect(text).not.toContain('\u001b');
  });

  it('keeps a file name with a line break on the finding line', () => {
    const file = 'src/x\nERROR    MIS001  forged.json:1\t.js';
    const text = render(report([finding({ file, message: 'm\nforged' })]), 'tty');
    expect(text).toContain('src/x\\u{000A}ERROR    MIS001  forged.json:1\\u{0009}.js:3');
    expect(text).toContain('m\\u{000A}forged');
    expect(text.split('\n').filter((line) => line.startsWith('ERROR'))).toHaveLength(1);
  });

  it('colours only when asked and never passes project text through raw', () => {
    const colored = render(report([finding({ message: hostile })]), 'tty', {
      color: true,
      width: 100,
    });
    expect(colored).toContain('\u001b[31m');
    expect(colored).not.toContain('\u001b]8');
    expect(colored).not.toContain('\u202E');
  });

  it('marks baseline findings and a clean run', () => {
    expect(render(report([finding({ baselined: true })]), 'tty')).toContain('BASELINE');
    expect(render(report([]), 'tty')).toContain('✓ No findings');
  });
});

describe('markdown', () => {
  it('escapes table cells so file content cannot add markup', () => {
    expect(escapeMarkdown('a | b `c` <img src=x> [l](u)\nnext')).toBe(
      'a \\| b \\`c\\` \\<img src=x\\> \\[l\\]\\(u\\)\\\\u\\{000A\\}next',
    );
    const text = render(
      report([finding({ message: 'pipe | and <b>' }), finding({ baselined: true })]),
      'markdown',
    );
    expect(text).toContain('| Catalog | Format | Source | Keys | Translated |');
    expect(text).toContain('pipe \\| and \\<b\\>');
    expect(render(report([finding({ file: 'a|b.json' })]), 'markdown')).toContain('`a\\|b.json:3`');
    expect(text).toContain(
      '[MIS001](https://github.com/muhittincamdali/GlobalLingo/blob/master/docs/rules.md#mis001)',
    );
    expect(text).toContain('1 finding in the baseline file is not listed.');
  });

  it('keeps a file name with a line break inside its table row', () => {
    const file = 'x\n| error | [PWN](javascript:alert%281%29) | injected | row |\n.js';
    const text = render(report([finding({ file })]), 'markdown');
    const rows = text.split('\n').filter((line) => line.startsWith('| error |'));
    expect(rows).toHaveLength(1);
    expect(rows[0]).toContain('`x\\u{000A}\\| error \\| [PWN](javascript:alert%281%29) \\|');
    expect(text).not.toMatch(/^\| injected/m);
  });
});

describe('sarif', () => {
  it('lists every rule and maps findings to results with fingerprints', () => {
    const sarif = JSON.parse(
      render(
        report([
          finding(),
          finding({
            rule: 'HCS001',
            severity: 'info',
            line: 0,
            file: 'src/a b.tsx',
            baselined: true,
          }),
        ]),
        'sarif',
      ),
    );
    expect(sarif.version).toBe('2.1.0');
    const run = sarif.runs[0];
    expect(run.tool.driver.rules.map((rule: { id: string }) => rule.id)).toEqual(RULE_IDS);
    expect(run.tool.driver.rules[0].name).toBe('MissingTranslation');
    expect(run.results[0]).toMatchObject({
      ruleId: 'MIS001',
      ruleIndex: 0,
      level: 'error',
      locations: [
        {
          physicalLocation: {
            artifactLocation: { uri: 'locales/de.json', uriBaseId: '%SRCROOT%' },
            region: { startLine: 3 },
          },
        },
      ],
      partialFingerprints: { 'globallingo/v1': '0123456789abcdef0123' },
    });
    expect(run.results[1].level).toBe('note');
    expect(run.results[1].locations[0].physicalLocation.region).toBeUndefined();
    expect(run.results[1].locations[0].physicalLocation.artifactLocation.uri).toBe('src/a%20b.tsx');
    expect(run.results[1].suppressions).toEqual([
      { kind: 'external', justification: 'In the GlobalLingo baseline file' },
    ]);
  });
});

describe('github', () => {
  it('writes one escaped annotation per finding outside the baseline', () => {
    const text = render(
      report([
        finding({ file: 'a,b:c.json', message: '100% done\nnext', key: 'k:1' }),
        finding({ baselined: true }),
      ]),
      'github',
    );
    const lines = text.trimEnd().split('\n');
    expect(lines).toHaveLength(2);
    expect(lines[0]).toMatch(
      /^::error file=a%2Cb%3Ac\.json,line=3,title=MIS001 k%3A1::100%25 done%0Anext\. Fix: /,
    );
    expect(lines[1]).toBe(
      'GlobalLingo 2.0.0: 1 error in 1 catalog and 2 source files (1 more in the baseline)',
    );
  });
});

describe('json', () => {
  it('is the report itself, with invisible controls escaped', () => {
    const text = render(report([finding({ message: hostile })]), 'json');
    expect(text).not.toMatch(/[\u0080-\u009F\u202A-\u202E]/);
    const parsed = JSON.parse(text);
    expect(parsed.findings[0].message).toBe(hostile);
    expect(parsed.schemaVersion).toBe(1);
  });
});
