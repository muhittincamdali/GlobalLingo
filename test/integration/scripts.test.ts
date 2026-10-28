import { readdirSync, readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
import { DEMOS, mediaPath, record } from '../../scripts/demo.ts';
import { DESCRIPTION, formula } from '../../scripts/homebrew-formula.ts';
import { releaseNotes } from '../../scripts/release-notes.ts';
import { parseAnsi, terminalSvg } from '../../scripts/terminal-svg.ts';
import { RULE_IDS } from '../../src/rules/registry.ts';

const root = new URL('../../', import.meta.url);

// The version in the first output line changes with each release; the demo stays valid.
const withoutVersion = (svg: string) =>
  svg.replace(/GlobalLingo \d+\.\d+\.\d+(?:-[\w.]+)?/g, 'GlobalLingo x');

describe('terminal SVG', () => {
  it('splits a line at its colour codes', () => {
    expect(parseAnsi('\u001b[1m\u001b[31mERROR\u001b[39m\u001b[22m  plain')).toEqual([
      { text: 'ERROR', bold: true, dim: false, color: 'red' },
      { text: '  plain', bold: false, dim: false, color: null },
    ]);
  });

  it('escapes text, has no scripts or external references, and uses only blues', () => {
    const svg = terminalSvg(
      {
        title: 'demo',
        command: 'npx @mcamdali/globallingo',
        output: '\u001b[31ma <b> & c\u001b[39m\n',
      },
      'light',
    );
    expect(svg).toContain('a &lt;b&gt; &amp; c');
    expect(svg).not.toMatch(/<script|href=|url\(|@import/);
    expect(svg).not.toMatch(/#(?:FF0000|FFFF00|00FF00)/i);
    expect(svg).toContain('@media (prefers-reduced-motion:reduce)');
  });
});

describe.each(DEMOS)('docs/media/demo-$name', (demo) => {
  it('matches what the CLI prints today (npm run demo records it again)', () => {
    const session = record(demo);
    expect(session.output).toContain('GlobalLingo');
    for (const theme of ['light', 'dark'] as const) {
      const committed = readFileSync(mediaPath(demo.name, theme), 'utf8');
      expect(withoutVersion(committed)).toBe(withoutVersion(terminalSvg(session, theme)));
    }
  });
});

describe('release notes', () => {
  const changelog = `# Changelog\n\n## [Unreleased]\n\n## [2.1.0] - 2026-12-01\n\n### Added\n\n- A rule.\n\n## [2.0.0] - 2026-11-01\n\n### Changed\n\n- Everything.\n\n[Unreleased]: https://github.com/muhittincamdali/GlobalLingo/compare/v2.1.0...HEAD\n[2.1.0]: https://github.com/muhittincamdali/GlobalLingo/releases/tag/v2.1.0\n`;

  it('returns the section of one version without its heading or link definitions', () => {
    expect(releaseNotes(changelog, '2.1.0')).toBe('### Added\n\n- A rule.\n');
    expect(releaseNotes(changelog, '2.0.0')).toBe('### Changed\n\n- Everything.\n');
  });

  it('fails for a missing or empty section', () => {
    expect(() => releaseNotes(changelog, '9.9.9')).toThrow('no section for 9.9.9');
    expect(() => releaseNotes(changelog, 'Unreleased')).toThrow('is empty');
  });
});

describe('Homebrew formula', () => {
  const sha = 'a'.repeat(64);

  it('installs the release tarball with Homebrew’s npm arguments and tests the command', () => {
    const text = formula({ version: '2.0.0', sha256: sha });
    expect(text).toContain(
      'url "https://github.com/muhittincamdali/GlobalLingo/releases/download/v2.0.0/globallingo-2.0.0.tgz"',
    );
    expect(text).toContain('system "npm", "install", *std_npm_args');
    expect(text).toContain('shell_output("#{bin}/globallingo #{testpath} 2>&1", 2)');
    expect(text).toContain('assert_match "No localization files found", output');
  });

  it('keeps the description within brew audit rules and rejects bad input', () => {
    expect(DESCRIPTION.length).toBeLessThanOrEqual(80);
    expect(DESCRIPTION).not.toMatch(/^(?:a|an|the|globallingo)\b/i);
    expect(DESCRIPTION).not.toMatch(/\.$/);
    expect(() => formula({ version: 'v2.0.0', sha256: sha })).toThrow();
    expect(() => formula({ version: '2.0.0', sha256: 'abc' })).toThrow();
  });
});

describe('documentation', () => {
  const rules = readFileSync(new URL('docs/rules.md', root), 'utf8');

  it('has a section for every rule, which the report links to', () => {
    for (const id of RULE_IDS) expect(rules, id).toContain(`### ${id}\n`);
  });

  it('lists every guide in the guides index and the documentation site', () => {
    const guides = readdirSync(new URL('docs/guides/', root)).filter(
      (file) => file.endsWith('.md') && file !== 'README.md',
    );
    const index = readFileSync(new URL('docs/guides/README.md', root), 'utf8');
    const site = JSON.parse(readFileSync(new URL('docs/site/typedoc.json', root), 'utf8')) as {
      projectDocuments: string[];
    };
    expect(guides.length).toBeGreaterThanOrEqual(3);
    for (const guide of guides) {
      expect(index, guide).toContain(`](${guide})`);
      expect(site.projectDocuments, guide).toContain(`../guides/${guide}`);
    }
  });
});
