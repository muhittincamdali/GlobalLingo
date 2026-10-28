// Puts the pieces together: reads the configuration, walks the folder, reads the catalogs, runs
// the catalog and code checks, and turns their drafts into the findings of a report.
import { stat } from 'node:fs/promises';
import { join } from 'node:path';
import { applyBaseline, type Baseline, fingerprint } from './baseline.js';
import { type CodeFile, checkSource, codeContext, sourceLanguage } from './code/check-code.js';
import { collectUsage, emptyUsage, unusedKeys } from './code/usage.js';
import { CONFIG_FILE, type Config, loadConfig } from './config.js';
import type { CatalogSummary, Ecosystem, Finding, Report, Severity } from './model.js';
import { decode } from './parse/decode.js';
import { discoverCatalogs } from './project/discover.js';
import { MAX_SOURCE_BYTES, readLimited, walk } from './project/files.js';
import { globMatcher } from './project/glob.js';
import { checkCatalog } from './rules/catalog-checks.js';
import type { Draft } from './rules/draft.js';
import { RULES, ruleDocs } from './rules/registry.js';
import { VERSION } from './version.js';

export interface ScanOptions {
  /** Configuration to use instead of the folder's .globallingo.json. */
  config?: Config;
  /** A configuration file to read instead of `<root>/.globallingo.json`. */
  configFile?: string;
  /** Overrides `sourceLanguage` of the configuration. */
  sourceLanguage?: string;
  /** Overrides `locales` of the configuration. */
  locales?: string[];
  /** Whether to read source code (KEY, HCS and TRI001/TRI003 rules); default true. */
  code?: boolean;
  /** Findings to mark as accepted. */
  baseline?: Baseline;
}

/** Raised when there is nothing to check: no folder, or no localization files in it. */
export class NothingToCheckError extends Error {}

/** At most this many source files are read; a monorepo gets a note to narrow the path. */
export const MAX_SOURCE_FILES = 20_000;

/** At most this many findings are kept; more than that is a project to fix in steps. */
export const MAX_FINDINGS = 100_000;

const SEVERITY_ORDER: Record<Severity, number> = { error: 0, warning: 1, info: 2 };

function finalize(drafts: Draft[], config: Config): Finding[] {
  const findings: Finding[] = [];
  for (const draft of drafts) {
    const setting = config.rules?.[draft.rule];
    if (setting === 'off') continue;
    const rule = RULES[draft.rule];
    findings.push({
      rule: draft.rule,
      severity: setting ?? rule.severity,
      file: draft.file,
      line: draft.line,
      ...(draft.column !== undefined ? { column: draft.column } : {}),
      ...(draft.key !== undefined ? { key: draft.key } : {}),
      ...(draft.locale !== undefined ? { locale: draft.locale } : {}),
      message: draft.message,
      fix: rule.fix[draft.ecosystem],
      docs: ruleDocs(draft.rule),
      fingerprint: fingerprint(draft),
    });
  }
  return findings.sort(
    (a, b) =>
      a.file.localeCompare(b.file) ||
      a.line - b.line ||
      SEVERITY_ORDER[a.severity] - SEVERITY_ORDER[b.severity] ||
      a.rule.localeCompare(b.rule) ||
      a.message.localeCompare(b.message),
  );
}

/**
 * The answer for each text, worked out once: a key is asked about by the catalog checks and by
 * KEY003, and again in every catalog that has it.
 */
function remembered(test: (text: string) => boolean): (text: string) => boolean {
  const answers = new Map<string, boolean>();
  return (text) => {
    let answer = answers.get(text);
    if (answer === undefined) {
      answer = test(text);
      answers.set(text, answer);
    }
    return answer;
  };
}

export async function scan(root: string, options: ScanOptions = {}): Promise<Report> {
  const info = await stat(root).catch(() => undefined);
  if (!info?.isDirectory()) throw new NothingToCheckError(`${root} is not a folder`);
  const loaded =
    options.config ??
    (await loadConfig(options.configFile ?? join(root, CONFIG_FILE), Boolean(options.configFile)));
  const config: Config = {
    ...loaded,
    ...(options.sourceLanguage ? { sourceLanguage: options.sourceLanguage } : {}),
    ...(options.locales ? { locales: options.locales } : {}),
  };
  const ignoredPath = globMatcher(config.ignore?.paths ?? []);
  const ignoredKey = remembered(globMatcher(config.ignore?.keys ?? []));
  const tree = await walk(root, ignoredPath);
  const notes = [...tree.notes];

  const discovered = await discoverCatalogs(root, tree.files, config);
  notes.push(...discovered.notes);
  const { catalogs } = discovered;
  if (catalogs.length === 0) {
    throw new NothingToCheckError(
      `No localization files found in ${root}: looked for *.xcstrings, *.lproj/*.strings and *.stringsdict, *.arb, and <locale>.json files in a locales folder. Name the folder in "catalogDirs" in ${CONFIG_FILE} if yours is elsewhere.`,
    );
  }

  const drafts: Draft[] = [];
  let truncated = false;
  const summaries: CatalogSummary[] = [];
  for (const catalog of catalogs) {
    const result = checkCatalog(catalog, {
      ...(config.locales ? { locales: config.locales } : {}),
      ignoreKey: ignoredKey,
      limit: MAX_FINDINGS - drafts.length,
    });
    drafts.push(...result.drafts);
    truncated ||= result.truncated;
    summaries.push({
      id: catalog.id,
      name: catalog.name,
      format: catalog.format,
      syntax: catalog.syntax,
      sourceLocale: catalog.sourceLocale,
      locales: catalog.locales,
      keys: result.keys,
      coverage: result.coverage,
    });
  }

  const ecosystems = new Set<Ecosystem>(catalogs.map((catalog) => catalog.ecosystem));
  let sourceFiles = 0;
  if (options.code !== false) {
    const context = codeContext(catalogs);
    const usage = emptyUsage();
    const sources = tree.files.filter((file) => sourceLanguage(file) !== undefined);
    if (sources.length > MAX_SOURCE_FILES) {
      notes.push(
        `Read the first ${MAX_SOURCE_FILES} of ${sources.length} source files; point GlobalLingo at the app's folder`,
      );
    }
    for (const path of sources.slice(0, MAX_SOURCE_FILES)) {
      const read = await readLimited(root, path, MAX_SOURCE_BYTES);
      if ('problem' in read) {
        notes.push(`${path}: ${read.problem}`);
        continue;
      }
      sourceFiles += 1;
      const file: CodeFile = { path, text: decode(read.bytes).text };
      const language = sourceLanguage(path);
      if (language) collectUsage(file.text, language, usage);
      for (const draft of checkSource(file, context)) {
        if (draft.key !== undefined && ignoredKey(draft.key)) continue;
        if (drafts.length >= MAX_FINDINGS) truncated = true;
        else drafts.push(draft);
      }
    }
    for (const draft of unusedKeys(catalogs, usage, ignoredKey)) {
      if (drafts.length >= MAX_FINDINGS) truncated = true;
      else drafts.push(draft);
    }
  }

  if (truncated) notes.push(`Stopped after ${MAX_FINDINGS} findings; fix or baseline these first`);
  const findings = finalize(drafts, config);
  if (options.baseline) applyBaseline(findings, options.baseline);
  const summary = { error: 0, warning: 0, info: 0, baselined: 0 };
  for (const finding of findings) {
    if (finding.baselined) summary.baselined += 1;
    else summary[finding.severity] += 1;
  }
  return {
    schemaVersion: 1,
    tool: { name: 'globallingo', version: VERSION },
    path: root,
    ecosystems: [...ecosystems].sort(),
    catalogs: summaries,
    sourceFiles,
    findings,
    notes,
    summary,
  };
}
