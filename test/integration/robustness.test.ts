// Inputs a pull request could add to make GlobalLingo crash, run out of memory, read or write
// through a link or write to the terminal: deep nesting, huge counts, odd names. Inputs that could
// make it hang are in growth.test.ts.
import { execFileSync } from 'node:child_process';
import { mkdirSync, readFileSync, symlinkSync } from 'node:fs';
import { join } from 'node:path';
import { describe, expect, it } from 'vitest';
import { checkCatalog } from '../../src/rules/catalog-checks.ts';
import { readJsonCatalog } from '../../src/catalogs/json-catalog.ts';
import { MAX_DEPTH, readLimited } from '../../src/project/files.ts';
import { render } from '../../src/report/index.ts';
import { readBaseline } from '../../src/baseline.ts';
import { run } from '../../src/cli/run.ts';
import { scan } from '../../src/scan.ts';
import { tree } from '../helpers/tree.ts';

describe('hostile catalogs', () => {
  it('reports a JSON file nested 100,000 levels deep as invalid instead of overflowing the stack', async () => {
    const deep = `${'{"a":'.repeat(100_000)}"x"${'}'.repeat(100_000)}`;
    const report = await scan(tree({ 'locales/en.json': '{"a": "A"}', 'locales/de.json': deep }));
    expect(report.findings.map((finding) => finding.rule)).toContain('FMT003');
    expect(report.findings.find((finding) => finding.rule === 'FMT003')?.message).toMatch(
      /Nested deeper than 128 levels/,
    );
  });

  it('caps the number of findings a catalog can produce', () => {
    const keys = Object.fromEntries(Array.from({ length: 2000 }, (_, i) => [`k${i}`, 'v']));
    const files = [{ locale: 'en', file: 'l/en.json', text: JSON.stringify(keys) }];
    for (let i = 0; i < 50; i += 1)
      files.push({
        locale: `de-${String(i).padStart(2, '0')}x`.slice(0, 8),
        file: `l/${i}.json`,
        text: '{}',
      });
    const catalog = readJsonCatalog('l/*.json', 'l', 'en', 'i18next', files);
    const result = checkCatalog(catalog, { ignoreKey: () => false, limit: 500 });
    expect(result.drafts).toHaveLength(500);
    expect(result.truncated).toBe(true);
  });

  it('keeps going below the folder depth limit with a note', async () => {
    const root = tree({ 'locales/en.json': '{"a": "A"}', 'locales/de.json': '{"a": "B"}' });
    let path = root;
    for (let i = 0; i < MAX_DEPTH + 3; i += 1) path = join(path, 'd');
    mkdirSync(path, { recursive: true });
    const report = await scan(root);
    expect(report.notes.some((note) => note.includes(`deeper than ${MAX_DEPTH} folders`))).toBe(
      true,
    );
  });

  it('never writes terminal escapes from keys, values or file names', async () => {
    const root = tree({
      'locales/en.json': JSON.stringify({ 'k\u001b[2Jx': 'v', title: 'T' }),
      'locales/de.json': JSON.stringify({ title: '\u202Eevil\u009B31m' }),
      'src/App.tsx': '<Text>\u001b]0;pwned\u0007 hello world</Text>',
    });
    const report = await scan(root);
    for (const format of ['tty', 'markdown', 'github', 'json', 'sarif'] as const) {
      // biome-ignore lint/suspicious/noControlCharactersInRegex: finding control characters is the point.
      expect(render(report, format), format).not.toMatch(/[\u001b\u0007\u009B\u202E]/);
    }
  });

  it('keeps a file name with a line break or tab on one report line', async () => {
    const name = 'x\n| error | [PWN](javascript:alert%281%29) | injected | row |\t.js';
    const root = tree({
      'locales/en.json': '{"hello": "Hello"}',
      'locales/de.json': '{"hello": "Hallo"}',
      [`src/${name}`]: 'const a = t("missing.key");\n',
    });
    const report = await scan(root);
    expect(report.findings.some((finding) => finding.file === `src/${name}`)).toBe(true);
    const markdown = render(report, 'markdown');
    expect(markdown).not.toMatch(/^\| error \| \[PWN\]/m);
    expect(markdown).toContain('src/x\\u{000A}\\| error');
    const tty = render(report, 'tty');
    expect(tty).not.toMatch(/^\| error/m);
    expect(tty).toContain('src/x\\u{000A}| error |');
    expect(tty).toContain('\\u{0009}.js');
  });
});

describe('reading a file', () => {
  it('reads only regular files within the limit, through the opened file', async () => {
    const outside = tree({ 'secret.txt': 'TOKEN' });
    const root = tree({ 'a.json': '{"a": 1}', 'big.json': 'x'.repeat(2048), 'dir/x': '' });
    symlinkSync(join(outside, 'secret.txt'), join(root, 'link.json'));
    expect(await readLimited(root, 'a.json', 1024)).toEqual({
      bytes: new TextEncoder().encode('{"a": 1}'),
    });
    expect(await readLimited(root, 'link.json', 1024)).toEqual({ problem: 'not a regular file' });
    expect(await readLimited(root, 'dir', 1024)).toEqual({ problem: 'not a regular file' });
    expect(await readLimited(root, 'none.json', 1024)).toEqual({ problem: 'ENOENT' });
    expect(await readLimited(root, 'big.json', 1024)).toEqual({
      problem: 'larger than 0 MB; not read',
    });
  });

  it.skipIf(process.platform === 'win32')('does not wait on a named pipe', async () => {
    const root = tree({});
    execFileSync('mkfifo', [join(root, 'pipe.json')]);
    expect(await readLimited(root, 'pipe.json', 1024)).toEqual({ problem: 'not a regular file' });
  });
});

describe('settings files that point elsewhere', () => {
  const secret = 'AKIA-SECRET-VALUE-1234';
  const project = () => tree({ 'locales/en.json': '{"a": "A"}', 'locales/de.json': '{"a": "B"}' });

  it('refuses a configuration or baseline that is a symbolic link, without reading it', async () => {
    const outside = tree({ 'secrets.env': `TOKEN=${secret}\n` });
    const root = project();
    symlinkSync(join(outside, 'secrets.env'), join(root, '.globallingo.json'));
    symlinkSync(join(outside, 'secrets.env'), join(root, 'baseline.json'));
    const config = await scan(root).catch((error: Error) => error.message);
    expect(config).toMatch(/\.globallingo\.json: not a regular file$/);
    const baseline = await readBaseline(join(root, 'baseline.json')).catch(
      (error: Error) => error.message,
    );
    expect(baseline).toMatch(/baseline\.json: not a regular file$/);
  });

  it('does not write a report or baseline through a symbolic link', async () => {
    const outside = tree({ 'important.txt': 'keep me' });
    const root = project();
    symlinkSync(join(outside, 'important.txt'), join(root, 'report.md'));
    symlinkSync(join(outside, 'important.txt'), join(root, 'baseline.json'));
    const io = { cwd: root, env: {}, stdout() {}, stderr() {}, stdoutIsTty: false };
    expect(await run(['--format', 'markdown', '--output', 'report.md'], io)).toBe(2);
    expect(await run(['--write-baseline', 'baseline.json'], io)).toBe(2);
    expect(readFileSync(join(outside, 'important.txt'), 'utf8')).toBe('keep me');
  });

  it('names only the line of a JSON error, never the text', async () => {
    const root = tree({
      'locales/en.json': '{}',
      'locales/de.json': '{}',
      '.globallingo.json': `{\n"a": 1,\n${secret}\n}`,
    });
    const message = await scan(root).catch((error: Error) => error.message);
    expect(message).toMatch(/not valid JSON \(line 3\)$/);
    expect(message).not.toContain('SECRET');
    const baseline = tree({ 'b.json': `[${secret}]` });
    const baselineMessage = await readBaseline(join(baseline, 'b.json')).catch(
      (error: Error) => error.message,
    );
    expect(baselineMessage).not.toContain('SECRET');
  });
});
