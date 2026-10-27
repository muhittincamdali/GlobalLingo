import { writeFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { parseArgs } from 'node:util';
import { BaselineError, readBaseline, writeBaseline } from '../baseline.js';
import { ConfigError } from '../config.js';
import type { Report, Severity } from '../model.js';
import { FORMATS, type Format, render } from '../report/index.js';
import { clean, summaryLine } from '../report/text.js';
import { NothingToCheckError, scan } from '../scan.js';
import { REPOSITORY_URL, VERSION } from '../version.js';

/** Exit codes; documented in the README and `--help`. */
export const EXIT = { ok: 0, findings: 1, error: 2 } as const;

export const FAIL_ON = ['error', 'warning', 'info', 'none'] as const;
type FailOn = (typeof FAIL_ON)[number];

/** The npm package; the command it installs is `globallingo`. */
export const PACKAGE_NAME = '@mcamdali/globallingo';

/** Everything the CLI touches outside its arguments, so tests can run it in-process. */
export interface CliEnvironment {
  cwd: string;
  env: Record<string, string | undefined>;
  stdout: (text: string) => void;
  stderr: (text: string) => void;
  /** Whether stdout is a terminal; turns colour on for the tty format. */
  stdoutIsTty: boolean;
  /** Terminal width, when stdout is a terminal. */
  columns?: number | undefined;
}

export const HELP = `Usage: globallingo [path] [options]

Lints the localization files of an iOS, Flutter or React Native/Expo app: String Catalogs,
.strings and .stringsdict, ARB, and JSON translation files. Reads files only.

Options:
  -f, --format <format>      tty (default), markdown, json, sarif or github
  -o, --output <file>        write the report to a file instead of stdout
      --fail-on <severity>   error (default), warning, info or none: what makes the exit code 1
  -c, --config <file>        settings file (default: <path>/.globallingo.json when it exists)
      --source <locale>      the source language, when the files do not say
      --locales <list>       comma-separated locales to check, e.g. de,tr,pl
      --baseline <file>      findings in this file are reported but do not fail the run
      --write-baseline <file>  write every finding of this run to a baseline file
      --no-code              check the localization files only, not the source code
      --no-color             plain text even in a terminal (NO_COLOR is respected)
  -h, --help                 show this help
  -v, --version              show the version

Exit codes:
  0  no findings at or above --fail-on (baseline findings do not count)
  1  findings at or above --fail-on
  2  bad arguments or settings, no localization files found, or an unexpected error

Examples:
  globallingo                                  checks the app in the current folder
  globallingo ios/MyApp --locales de,fr,tr
  globallingo --format sarif --output globallingo.sarif
  globallingo --write-baseline .globallingo-baseline.json   accept what exists today
  globallingo --baseline .globallingo-baseline.json         fail only on new findings

The npm package is ${PACKAGE_NAME}; the command is globallingo:
  npx ${PACKAGE_NAME}       runs the latest version without installing it

Rules and fixes: ${REPOSITORY_URL}/blob/master/docs/rules.md
`;

class UsageError extends Error {}

interface Parsed {
  path: string;
  format: Format;
  output?: string;
  failOn: FailOn;
  config?: string;
  source?: string;
  locales?: string[];
  baseline?: string;
  writeBaseline?: string;
  code: boolean;
  color: boolean;
  help: boolean;
  version: boolean;
}

const OPTIONS = {
  format: { type: 'string', short: 'f', default: 'tty' },
  output: { type: 'string', short: 'o' },
  'fail-on': { type: 'string', default: 'error' },
  config: { type: 'string', short: 'c' },
  source: { type: 'string' },
  locales: { type: 'string' },
  baseline: { type: 'string' },
  'write-baseline': { type: 'string' },
  code: { type: 'boolean', default: true },
  color: { type: 'boolean', default: true },
  help: { type: 'boolean', short: 'h', default: false },
  version: { type: 'boolean', short: 'v', default: false },
} as const;

function readArgs(argv: readonly string[]) {
  try {
    return parseArgs({
      args: [...argv],
      allowPositionals: true,
      allowNegative: true,
      options: OPTIONS,
    });
  } catch (error) {
    throw new UsageError((error as Error).message);
  }
}

function parse(argv: readonly string[]): Parsed {
  const { values, positionals } = readArgs(argv);
  if (positionals.length > 1)
    throw new UsageError(
      `Expected one folder, got ${positionals.length}: ${positionals.join(' ')}`,
    );
  if (!(FORMATS as readonly string[]).includes(values.format)) {
    throw new UsageError(`--format must be one of ${FORMATS.join(', ')}, not "${values.format}"`);
  }
  if (!(FAIL_ON as readonly string[]).includes(values['fail-on'])) {
    throw new UsageError(
      `--fail-on must be one of ${FAIL_ON.join(', ')}, not "${values['fail-on']}"`,
    );
  }
  const locales = values.locales
    ?.split(',')
    .map((locale) => locale.trim())
    .filter(Boolean);
  if (values.locales !== undefined && (!locales || locales.length === 0)) {
    throw new UsageError('--locales needs at least one locale, e.g. --locales de,tr');
  }
  for (const [name, value] of [
    ['source', values.source],
    ['output', values.output],
    ['config', values.config],
    ['baseline', values.baseline],
    ['write-baseline', values['write-baseline']],
  ] as const) {
    if (value === '') throw new UsageError(`--${name} needs a value`);
  }
  return {
    path: positionals[0] ?? '.',
    format: values.format as Format,
    failOn: values['fail-on'] as FailOn,
    code: values.code,
    color: values.color,
    help: values.help,
    version: values.version,
    ...(values.output ? { output: values.output } : {}),
    ...(values.config ? { config: values.config } : {}),
    ...(values.source ? { source: values.source } : {}),
    ...(locales ? { locales } : {}),
    ...(values.baseline ? { baseline: values.baseline } : {}),
    ...(values['write-baseline'] ? { writeBaseline: values['write-baseline'] } : {}),
  };
}

function useColor(options: Parsed, io: CliEnvironment): boolean {
  if (options.format !== 'tty' || options.output || !options.color) return false;
  if (io.env.NO_COLOR) return false;
  if (io.env.FORCE_COLOR && io.env.FORCE_COLOR !== '0') return true;
  return io.stdoutIsTty;
}

const RANK: Record<Severity, number> = { error: 3, warning: 2, info: 1 };

/** Whether the report has a finding outside the baseline at or above `failOn`. */
export function failsOn(report: Report, failOn: FailOn): boolean {
  if (failOn === 'none') return false;
  return report.findings.some(
    (finding) => !finding.baselined && RANK[finding.severity] >= RANK[failOn],
  );
}

/** Terminal width for the report: the terminal's, between 60 and 100 columns, else 100. */
export function reportWidth(io: CliEnvironment): number {
  const columns = io.columns;
  if (!io.stdoutIsTty || typeof columns !== 'number' || !Number.isFinite(columns)) return 100;
  return Math.min(100, Math.max(60, Math.floor(columns)));
}

/** Runs the CLI with the given arguments (without `node` and the script) and returns the exit code. */
export async function run(argv: readonly string[], environment: CliEnvironment): Promise<number> {
  // Messages name files and keys of the checked project; every write to stderr is cleaned so none
  // of them can carry an escape sequence to the terminal.
  const io = { ...environment, stderr: (text: string) => environment.stderr(clean(text)) };
  let options: Parsed;
  try {
    options = parse(argv);
  } catch (error) {
    io.stderr(`globallingo: ${(error as Error).message}\n(add --help for usage)\n`);
    return EXIT.error;
  }
  if (options.help) {
    io.stdout(HELP);
    return EXIT.ok;
  }
  if (options.version) {
    io.stdout(`${VERSION}\n`);
    return EXIT.ok;
  }
  try {
    const baseline = options.baseline
      ? await readBaseline(resolve(io.cwd, options.baseline))
      : undefined;
    const report = await scan(resolve(io.cwd, options.path), {
      ...(options.config ? { configFile: resolve(io.cwd, options.config) } : {}),
      ...(options.source ? { sourceLanguage: options.source } : {}),
      ...(options.locales ? { locales: options.locales } : {}),
      ...(baseline ? { baseline } : {}),
      code: options.code,
    });
    report.path = options.path;
    if (options.writeBaseline) {
      await writeBaseline(resolve(io.cwd, options.writeBaseline), report.findings);
      io.stderr(`Wrote ${options.writeBaseline} with ${report.findings.length} finding(s)\n`);
    }
    const output = render(report, options.format, {
      color: useColor(options, io),
      width: reportWidth(io),
    });
    if (options.output) {
      await writeFile(resolve(io.cwd, options.output), output);
      io.stderr(`Wrote ${options.output}: ${summaryLine(report)}\n`);
    } else {
      io.stdout(output);
    }
    return failsOn(report, options.failOn) ? EXIT.findings : EXIT.ok;
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    io.stderr(`globallingo: ${message}\n`);
    const expected =
      error instanceof NothingToCheckError ||
      error instanceof ConfigError ||
      error instanceof BaselineError;
    if (!expected && !(error as NodeJS.ErrnoException).code) {
      io.stderr(
        `This looks like a bug in GlobalLingo; please report it at ${REPOSITORY_URL}/issues\n`,
      );
    }
    return EXIT.error;
  }
}
