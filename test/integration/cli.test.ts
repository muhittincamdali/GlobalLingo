import { spawnSync } from 'node:child_process';
import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';
import { type CliEnvironment, EXIT, HELP, reportWidth, run } from '../../src/cli/run.ts';
import { VERSION } from '../../src/version.ts';
import { tree } from '../helpers/tree.ts';

const ROOT = fileURLToPath(new URL('../../', import.meta.url));

async function cli(
  argv: string[],
  cwd: string,
  env: Record<string, string | undefined> = {},
  tty = false,
) {
  let stdout = '';
  let stderr = '';
  const io: CliEnvironment = {
    cwd,
    env,
    stdout: (text) => {
      stdout += text;
    },
    stderr: (text) => {
      stderr += text;
    },
    stdoutIsTty: tty,
    columns: tty ? 80 : undefined,
  };
  const code = await run(argv, io);
  return { code, stdout, stderr };
}

const project = () =>
  tree({
    'locales/en.json':
      '{"title": "Title", "count_one": "{{count}} item", "count_other": "{{count}} items"}',
    'locales/de.json':
      '{"title": "Titel", "count_one": "{{count}} Artikel", "count_other": "{{count}} Artikel"}',
    'locales/pl.json':
      '{"title": "Tytuł", "count_one": "{{count}} element", "count_other": "{{count}} elementu"}',
    'src/App.tsx': "<Text>{t('title')}</Text>",
  });

describe('exit codes', () => {
  it('is 0 without errors, 1 with findings at --fail-on, 2 for nothing to check', async () => {
    const root = project();
    expect((await cli([], root)).code).toBe(EXIT.ok);
    expect((await cli(['--fail-on', 'warning'], root)).code).toBe(EXIT.findings);
    expect((await cli(['--fail-on', 'none', '--locales', 'de,fr'], root)).code).toBe(EXIT.ok);
    expect((await cli(['--locales', 'de,fr'], root)).code).toBe(EXIT.findings);
    const empty = await cli([], tree({ 'README.md': '' }));
    expect(empty.code).toBe(EXIT.error);
    expect(empty.stderr).toMatch(/^globallingo: No localization files found/);
    expect(empty.stderr).not.toContain('bug');
  });

  it('is 2 for bad arguments, with a hint', async () => {
    const root = project();
    for (const argv of [
      ['--format', 'xml'],
      ['--fail-on', 'all'],
      ['--bogus'],
      ['a', 'b'],
      ['--locales', ','],
      ['--output', ''],
    ]) {
      const result = await cli(argv, root);
      expect(result.code, argv.join(' ')).toBe(EXIT.error);
      expect(result.stderr).toContain('(add --help for usage)');
    }
  });

  it('is 2 for a broken configuration or baseline', async () => {
    const root = project();
    expect((await cli(['--config', 'missing.json'], root)).stderr).toMatch(/missing\.json: ENOENT/);
    const bad = tree({ 'b.json': '{"tool": "other"}' });
    const result = await cli([root, '--baseline', join(bad, 'b.json')], bad);
    expect(result.code).toBe(EXIT.error);
    expect(result.stderr).toMatch(/not a GlobalLingo baseline/);
  });
});

describe('options', () => {
  it('prints help and the version', async () => {
    const root = project();
    expect(await cli(['--help'], root)).toEqual({ code: 0, stdout: HELP, stderr: '' });
    expect((await cli(['-v'], root)).stdout).toBe(`${VERSION}\n`);
  });

  it('writes the report to a file and the summary to stderr', async () => {
    const root = project();
    const result = await cli(['--format', 'markdown', '--output', 'report.md'], root);
    expect(result.stdout).toBe('');
    expect(result.stderr).toMatch(/^Wrote report\.md: /);
    expect(readFileSync(join(root, 'report.md'), 'utf8')).toMatch(/^## GlobalLingo: /);
  });

  it('writes a baseline that a later run accepts', async () => {
    const root = project();
    const write = await cli(['--locales', 'de,fr', '--write-baseline', 'baseline.json'], root);
    expect(write.code).toBe(EXIT.findings);
    expect(write.stderr).toContain('Wrote baseline.json with ');
    const again = await cli(['--locales', 'de,fr', '--baseline', 'baseline.json'], root);
    expect(again.code).toBe(EXIT.ok);
    expect(again.stdout).toContain('BASELINE');
  });

  it('colours only for a terminal and respects NO_COLOR and FORCE_COLOR', async () => {
    const root = project();
    const ansi = /\u001b\[/;
    expect((await cli([], root, {}, true)).stdout).toMatch(ansi);
    expect((await cli([], root, { NO_COLOR: '1' }, true)).stdout).not.toMatch(ansi);
    expect((await cli(['--no-color'], root, {}, true)).stdout).not.toMatch(ansi);
    expect((await cli([], root, { FORCE_COLOR: '1' })).stdout).toMatch(ansi);
    expect((await cli(['--format', 'json'], root, { FORCE_COLOR: '1' })).stdout).not.toMatch(ansi);
  });

  it('keeps the report width between 60 and 100 columns, and 100 for anything odd', () => {
    const io = (columns: number | undefined, tty = true) => ({
      cwd: '.',
      env: {},
      stdout() {},
      stderr() {},
      stdoutIsTty: tty,
      columns,
    });
    expect([
      reportWidth(io(80)),
      reportWidth(io(20)),
      reportWidth(io(300)),
      reportWidth(io(Number.NaN)),
      reportWidth(io(80, false)),
    ]).toEqual([80, 60, 100, 100, 100]);
  });

  it('skips the source code with --no-code and takes the source language from --source', async () => {
    const root = tree({
      'locales/de.json': '{"a": "A", "b": "B"}',
      'locales/fr.json': '{"a": "A"}',
      'src/App.tsx': '<Text>Hello world</Text>',
    });
    const json = JSON.parse(
      (await cli(['--format', 'json', '--no-code', '--source', 'de'], root)).stdout,
    );
    expect(json.sourceFiles).toBe(0);
    expect(json.catalogs[0].sourceLocale).toBe('de');
    expect(
      json.findings.map(
        (finding: { rule: string; key: string }) => `${finding.rule} ${finding.key}`,
      ),
    ).toEqual(['MIS001 b']);
  });

  it('cleans what it writes to stderr', async () => {
    const result = await cli(['--format', 'json\u001b[2J'], project());
    expect(result.stderr).not.toContain('\u001b');
    expect(result.stderr).toContain('\\u{001B}');
  });
});

describe('the installed command', () => {
  it('runs from dist/ with node and reports a fixture', () => {
    const result = spawnSync(
      process.execPath,
      [join(ROOT, 'dist/cli/main.js'), 'fixtures/expo-i18next', '--no-color'],
      {
        cwd: ROOT,
        encoding: 'utf8',
        env: { ...process.env, NO_COLOR: '1' },
      },
    );
    expect(result.status).toBe(1);
    expect(result.stdout).toContain('GlobalLingo ');
    expect(result.stdout).toContain('src/locales/*.json');
  });
});
