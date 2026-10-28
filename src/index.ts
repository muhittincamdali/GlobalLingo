/**
 * GlobalLingo's programmatic API: {@link scan} a folder for its localization files and source
 * code, then {@link render} the report as text, Markdown, JSON, SARIF or GitHub annotations.
 *
 * ```ts
 * import { render, scan } from '@mcamdali/globallingo';
 *
 * const report = await scan('path/to/app', { locales: ['de', 'tr'] });
 * console.log(render(report, 'markdown'));
 * ```
 *
 * @module
 */
export {
  applyBaseline,
  type Baseline,
  BaselineError,
  createBaseline,
  readBaseline,
  writeBaseline,
} from './baseline.js';
export {
  type Config,
  ConfigError,
  loadConfig,
  type RuleSetting,
  validateConfig,
} from './config.js';
export type {
  CatalogFormat,
  CatalogSummary,
  Ecosystem,
  Finding,
  LocaleCoverage,
  MessageSyntax,
  Report,
  RuleId,
  Severity,
} from './model.js';
export {
  type IcuArgument,
  type IcuOptions,
  type IcuParse,
  type IcuPlural,
  parseIcu,
} from './messages/icu.js';
export { parsePrintf, type FormatSpecifier, type PrintfParse } from './messages/printf.js';
export { type PluralType, pluralCategories } from './plural.js';
export { FORMATS, type Format, render } from './report/index.js';
export type { TtyOptions } from './report/tty.js';
export { RULE_IDS, RULES, type Rule } from './rules/registry.js';
export {
  MAX_FINDINGS,
  MAX_SOURCE_FILES,
  NothingToCheckError,
  type ScanOptions,
  scan,
} from './scan.js';
export { VERSION } from './version.js';
