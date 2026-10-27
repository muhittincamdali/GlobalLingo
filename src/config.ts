// .globallingo.json: optional settings at the root of the checked folder. Every field is optional,
// and so is the file. Unknown fields and wrong types are errors, so a typo cannot quietly turn a
// check off. schema/config.schema.json describes the same shape for editors.
import { readFile } from 'node:fs/promises';
import type { MessageSyntax, RuleId, Severity } from './model.js';
import { RULE_IDS } from './rules/registry.js';

export type RuleSetting = Severity | 'off';

export interface Config {
  /** The language the others are translated from, when the files do not say. */
  sourceLanguage?: string;
  /** Only these locales are checked, and each must exist. */
  locales?: string[];
  ignore?: {
    /** Globs matched against paths from the checked folder, e.g. `**\/Tests/**`. */
    paths?: string[];
    /** Globs matched against keys, e.g. `debug.*`. */
    keys?: string[];
  };
  /** A different severity for a rule, or `off`. */
  rules?: Partial<Record<RuleId, RuleSetting>>;
  /** Placeholder syntax of JSON translation files, when package.json does not tell. */
  jsonSyntax?: Exclude<MessageSyntax, 'printf'>;
  /** Folders with JSON translation files that are not found on their own. */
  catalogDirs?: string[];
}

export const CONFIG_FILE = '.globallingo.json';

export class ConfigError extends Error {}

const SETTINGS: readonly RuleSetting[] = ['error', 'warning', 'info', 'off'];
const SYNTAXES = ['i18next', 'icu', 'i18n-js'] as const;
export const CONFIG_FIELDS = [
  '$schema',
  'sourceLanguage',
  'locales',
  'ignore',
  'rules',
  'jsonSyntax',
  'catalogDirs',
];

const isObject = (value: unknown): value is Record<string, unknown> =>
  typeof value === 'object' && value !== null && !Array.isArray(value);

function stringList(value: unknown, field: string, file: string): string[] {
  if (!Array.isArray(value) || value.some((item) => typeof item !== 'string' || item === '')) {
    throw new ConfigError(`${file}: "${field}" must be a list of non-empty strings`);
  }
  if (value.length > 1000) throw new ConfigError(`${file}: "${field}" has more than 1000 entries`);
  return value as string[];
}

/** Checks a parsed configuration and returns it typed; throws ConfigError with the problem. */
export function validateConfig(value: unknown, file = CONFIG_FILE): Config {
  if (!isObject(value)) throw new ConfigError(`${file}: the file must contain a JSON object`);
  for (const field of Object.keys(value)) {
    if (!CONFIG_FIELDS.includes(field)) {
      throw new ConfigError(
        `${file}: unknown field "${field}" (known: ${CONFIG_FIELDS.slice(1).join(', ')})`,
      );
    }
  }
  const config: Config = {};
  if (value.sourceLanguage !== undefined) {
    if (typeof value.sourceLanguage !== 'string' || value.sourceLanguage === '') {
      throw new ConfigError(`${file}: "sourceLanguage" must be a locale such as "en"`);
    }
    config.sourceLanguage = value.sourceLanguage;
  }
  if (value.locales !== undefined) config.locales = stringList(value.locales, 'locales', file);
  if (value.catalogDirs !== undefined) {
    config.catalogDirs = stringList(value.catalogDirs, 'catalogDirs', file);
    for (const dir of config.catalogDirs) {
      if (dir.startsWith('/') || dir.split(/[\\/]/).includes('..')) {
        throw new ConfigError(
          `${file}: "catalogDirs" entries must stay inside the checked folder (${dir})`,
        );
      }
    }
  }
  if (value.ignore !== undefined) {
    if (!isObject(value.ignore)) throw new ConfigError(`${file}: "ignore" must be an object`);
    const ignore: NonNullable<Config['ignore']> = {};
    for (const field of Object.keys(value.ignore)) {
      if (field !== 'paths' && field !== 'keys') {
        throw new ConfigError(`${file}: unknown field "ignore.${field}" (known: paths, keys)`);
      }
    }
    if (value.ignore.paths !== undefined)
      ignore.paths = stringList(value.ignore.paths, 'ignore.paths', file);
    if (value.ignore.keys !== undefined)
      ignore.keys = stringList(value.ignore.keys, 'ignore.keys', file);
    config.ignore = ignore;
  }
  if (value.rules !== undefined) {
    if (!isObject(value.rules)) throw new ConfigError(`${file}: "rules" must be an object`);
    const rules: NonNullable<Config['rules']> = {};
    for (const [id, setting] of Object.entries(value.rules)) {
      if (!(RULE_IDS as string[]).includes(id)) {
        throw new ConfigError(`${file}: unknown rule "${id}" in "rules"`);
      }
      if (!SETTINGS.includes(setting as RuleSetting)) {
        throw new ConfigError(`${file}: "rules.${id}" must be one of ${SETTINGS.join(', ')}`);
      }
      rules[id as RuleId] = setting as RuleSetting;
    }
    config.rules = rules;
  }
  if (value.jsonSyntax !== undefined) {
    if (!SYNTAXES.includes(value.jsonSyntax as (typeof SYNTAXES)[number])) {
      throw new ConfigError(`${file}: "jsonSyntax" must be one of ${SYNTAXES.join(', ')}`);
    }
    config.jsonSyntax = value.jsonSyntax as Config['jsonSyntax'] & string;
  }
  return config;
}

/** Reads the configuration file; a missing file is an empty configuration unless it was named. */
export async function loadConfig(path: string, required: boolean): Promise<Config> {
  let text: string;
  try {
    text = await readFile(path, 'utf8');
  } catch (error) {
    if (!required && (error as NodeJS.ErrnoException).code === 'ENOENT') return {};
    throw new ConfigError(`${path}: ${(error as NodeJS.ErrnoException).code ?? 'not readable'}`);
  }
  if (text.length > 1024 * 1024) throw new ConfigError(`${path}: larger than 1 MB`);
  let parsed: unknown;
  try {
    parsed = JSON.parse(text);
  } catch (error) {
    throw new ConfigError(`${path}: not valid JSON (${(error as Error).message})`);
  }
  return validateConfig(parsed, path);
}
