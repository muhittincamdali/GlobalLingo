// Runs the examples the way examples/README.md says, against the fixtures, so they keep working.
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';

const ROOT = fileURLToPath(new URL('../../', import.meta.url));
const run = (command: string, args: string[]) =>
  spawnSync(command, args, { cwd: ROOT, encoding: 'utf8', env: { ...process.env, NO_COLOR: '1' } });
const hasJq = spawnSync('jq', ['--version']).status === 0;

describe('examples', () => {
  it.skipIf(!hasJq)('shell/errors-by-locale.sh counts errors per locale and rule', () => {
    const result = run('sh', ['examples/shell/errors-by-locale.sh', 'fixtures/expo-i18next']);
    expect(result.status).toBe(0);
    expect(result.stdout).toBe(
      [
        'Errors per locale:',
        '  (all): 2',
        '  de: 2',
        '  tr: 2',
        'Rules:',
        '  DUP001 × 1',
        '  FMT001 × 1',
        '  KEY001 × 1',
        '  MIS001 × 2',
        '  MIS002 × 1',
        '',
      ].join('\n'),
    );
  });

  it('api/coverage.mjs prints coverage per locale and findings per rule', () => {
    const result = run(process.execPath, ['examples/api/coverage.mjs', 'fixtures/flutter-arb']);
    expect(result.status).toBe(0);
    expect(result.stdout.split('\n').slice(0, 4)).toEqual([
      'lib/l10n/*.arb (5 keys, source en)',
      '  de       100%  5/5',
      '  pl       100%  5/5',
      '  tr        80%  4/5',
    ]);
  });

  it('config/.globallingo.json is valid and changes the result', () => {
    const result = run(process.execPath, [
      'dist/cli/main.js',
      'fixtures/expo-i18next',
      '--config',
      'examples/config/.globallingo.json',
      '--format',
      'json',
    ]);
    expect(result.status).toBe(1);
    const report = JSON.parse(result.stdout);
    const rules = report.findings.map(
      (finding: { rule: string; severity: string }) => `${finding.rule}:${finding.severity}`,
    );
    expect(rules).toContain('HCS001:error');
    // legacy.banner is an ignored key.
    expect(rules.some((rule: string) => rule.startsWith('STA002'))).toBe(false);
  });

  it('pre-commit does nothing when no localization file is staged', () => {
    const result = spawnSync('sh', [`${ROOT}examples/pre-commit/pre-commit`], {
      cwd: ROOT,
      encoding: 'utf8',
      env: { ...process.env, GIT_INDEX_FILE: `${ROOT}.git/globallingo-empty-index` },
    });
    expect(result.status).toBe(0);
  });
});
