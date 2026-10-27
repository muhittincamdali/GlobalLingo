// Finds and reads the localization files of a project: String Catalogs, .lproj strings tables,
// Flutter ARB files (through l10n.yaml where there is one) and JSON translation files of
// JavaScript apps. Reading is separate from checking: the result is a list of catalogs.
import { posix } from 'node:path';
import { readAppleTable, type TableFile } from '../catalogs/apple-tables.js';
import { type ArbFile, arbLocale, readArb } from '../catalogs/arb.js';
import { type JsonFile, readJsonCatalog } from '../catalogs/json-catalog.js';
import { readXcstrings } from '../catalogs/xcstrings.js';
import type { Config } from '../config.js';
import type { Catalog, MessageSyntax } from '../model.js';
import { decode, isBinaryPlist } from '../parse/decode.js';
import { MAX_CATALOG_BYTES, readLimited } from './files.js';
import { detectJsonSyntax, readFlutterSettings, type FlutterSettings } from './settings.js';

const { basename, dirname, join } = posix;

export interface Discovered {
  catalogs: Catalog[];
  notes: string[];
}

/** Folder names that hold JSON translation files in JavaScript apps. */
const LOCALE_FOLDERS = new Set([
  'locales',
  'locale',
  'i18n',
  'l10n',
  'lang',
  'langs',
  'languages',
  'translations',
  'messages',
]);

const displayNames = new Intl.DisplayNames(['en'], { type: 'language', fallback: 'none' });

/** Whether a file or folder name is a locale code such as `en`, `pt-BR` or `zh_Hant`. */
export function isLocaleName(name: string): boolean {
  if (!/^[a-z]{2,3}(?:[-_][A-Za-z0-9]{2,8})*$/.test(name)) return false;
  try {
    const [tag] = Intl.getCanonicalLocales(name.replace(/_/g, '-'));
    const language = tag?.split('-')[0];
    return language !== undefined && displayNames.of(language) !== undefined;
  } catch {
    return false;
  }
}

async function readText(root: string, file: string): Promise<{ text?: string; problem?: string }> {
  const read = await readLimited(root, file, MAX_CATALOG_BYTES);
  if ('problem' in read) return { problem: read.problem };
  if (isBinaryPlist(read.bytes))
    return { problem: 'a binary property list (build output); not read' };
  return { text: decode(read.bytes).text };
}

async function stringCatalogs(root: string, files: string[]): Promise<Catalog[]> {
  const catalogs: Catalog[] = [];
  for (const file of files.filter((path) => path.endsWith('.xcstrings'))) {
    const read = await readText(root, file);
    try {
      if (read.text === undefined) throw new Error(read.problem);
      catalogs.push(readXcstrings(read.text, file));
    } catch (error) {
      catalogs.push({
        id: file,
        name: basename(file, '.xcstrings'),
        format: 'xcstrings',
        syntax: 'printf',
        ecosystem: 'apple',
        sourceLocale: 'en',
        locales: [],
        files: new Map(),
        entries: new Map(),
        duplicates: [],
        problems: [
          { file, line: (error as { line?: number }).line ?? 0, message: (error as Error).message },
        ],
      });
    }
  }
  return catalogs;
}

/** The development region from the first Xcode project that names one. */
async function developmentRegion(root: string, files: string[]): Promise<string | undefined> {
  for (const file of files.filter((path) => path.endsWith('.xcodeproj/project.pbxproj'))) {
    const read = await readText(root, file);
    const region =
      read.text && /\bdevelopmentRegion\s*=\s*"?([A-Za-z_-]+)"?\s*;/.exec(read.text)?.[1];
    if (region) return region;
  }
  return undefined;
}

async function stringsTables(
  root: string,
  files: string[],
  config: Config,
  notes: string[],
): Promise<Catalog[]> {
  const tables = new Map<
    string,
    {
      folder: string;
      name: string;
      files: { locale: string; file: string; kind: TableFile['kind'] }[];
    }
  >();
  for (const file of files) {
    const match = /^(?:(.*)\/)?([^/]+)\.lproj\/([^/]+)\.(strings|stringsdict)$/.exec(file);
    if (!match) continue;
    const [, folder = '', lproj, name, kind] = match as unknown as [
      string,
      string | undefined,
      string,
      string,
      TableFile['kind'],
    ];
    const id = `${folder ? `${folder}/` : ''}*.lproj/${name}`;
    let table = tables.get(id);
    if (!table) {
      table = { folder, name, files: [] };
      tables.set(id, table);
    }
    table.files.push({ locale: lproj.replace(/_/g, '-'), file, kind });
  }
  if (tables.size === 0) return [];
  const region = config.sourceLanguage ?? (await developmentRegion(root, files));
  const interfaceFiles = new Set(
    files
      .map((path) => /^(?:(.*)\/)?[^/]+\.lproj\/([^/]+)\.(?:storyboard|xib)$/.exec(path))
      .filter((match) => match !== null)
      .map((match) => `${match[1] ? `${match[1]}/` : ''}*.lproj/${match[2]}`),
  );
  const catalogs: Catalog[] = [];
  for (const [id, table] of tables) {
    const locales = new Set(table.files.map((file) => file.locale));
    const source =
      (region && [...locales].find((locale) => locale.toLowerCase() === region.toLowerCase())) ??
      (locales.has('en') ? 'en' : locales.has('Base') ? 'Base' : ([...locales].sort()[0] ?? 'en'));
    if (interfaceFiles.has(id) && !locales.has(source)) {
      notes.push(
        `${id}: translations of a storyboard or XIB; Xcode keeps their source in Interface Builder, so only syntax and duplicates are checked`,
      );
    }
    const read: TableFile[] = [];
    for (const file of table.files) read.push({ ...file, ...(await readText(root, file.file)) });
    catalogs.push(readAppleTable(id, table.name, source, read));
  }
  return catalogs;
}

const ARB_LOCALE_SUFFIX = /_[a-z]{2,3}(?:_[A-Z][a-z]{3})?(?:_(?:[A-Z]{2}|\d{3}))?$/;

async function arbCatalogs(
  root: string,
  files: string[],
  config: Config,
  notes: string[],
): Promise<Catalog[]> {
  const arbFiles = files.filter((path) => path.endsWith('.arb'));
  if (arbFiles.length === 0) return [];
  const settingsByFolder = new Map<string, FlutterSettings>();
  for (const file of files.filter((path) => basename(path) === 'l10n.yaml')) {
    const read = await readText(root, file);
    if (read.text === undefined) continue;
    const settings = readFlutterSettings(read.text, dirname(file) === '.' ? '' : dirname(file));
    settingsByFolder.set(settings.arbDir, settings);
  }
  const groups = new Map<string, string[]>();
  for (const file of arbFiles) {
    const folder = dirname(file) === '.' ? '' : dirname(file);
    groups.set(folder, [...(groups.get(folder) ?? []), file]);
  }
  const catalogs: Catalog[] = [];
  for (const [folder, group] of groups) {
    const settings = settingsByFolder.get(folder);
    const template = settings ? join(folder, settings.templateArbFile) : undefined;
    // app_en.arb, app_pt_BR.arb, intl_zh_Hant_TW.arb: the prefix is what comes before the locale.
    const prefix = basename(template ?? group[0] ?? '', '.arb').replace(ARB_LOCALE_SUFFIX, '');
    const read: ArbFile[] = [];
    let sourceLocale: string | undefined;
    for (const file of group) {
      const content = await readText(root, file);
      const name = basename(file, '.arb');
      const fromName =
        prefix && name.startsWith(`${prefix}_`)
          ? name.slice(prefix.length + 1)
          : ARB_LOCALE_SUFFIX.exec(name)?.[0].slice(1);
      const locale = (content.text && arbLocale(content.text)) || fromName || name;
      if (file === template) sourceLocale = locale;
      read.push({ locale, file, ...content });
    }
    if (template && !group.includes(template)) {
      notes.push(`${template}: the template ARB file named in l10n.yaml does not exist`);
    }
    const locales = read.map((file) => file.locale);
    const source =
      sourceLocale ??
      (config.sourceLanguage && locales.find((locale) => locale === config.sourceLanguage)) ??
      locales.find((locale) => locale === 'en') ??
      locales.sort()[0] ??
      'en';
    catalogs.push(
      readArb(
        folder ? `${folder}/*.arb` : '*.arb',
        prefix || basename(folder) || 'arb',
        {
          sourceLocale: source,
          useEscaping: settings?.useEscaping ?? false,
          outputClass: settings?.outputClass ?? 'AppLocalizations',
        },
        read,
      ),
    );
  }
  return catalogs;
}

interface JsonGroup {
  folder: string;
  namespace: string;
  files: { locale: string; file: string }[];
}

/** Groups `<folder>/<locale>.json` and `<folder>/<locale>/<namespace>.json` files. */
export function jsonGroups(files: string[], extraFolders: readonly string[]): JsonGroup[] {
  const flat = new Map<string, { locale: string; file: string }[]>();
  const nested = new Map<string, { locale: string; file: string }[]>();
  for (const file of files) {
    if (
      !file.endsWith('.json') ||
      file.split('/').some((part) => part === 'ios' || part === 'android')
    )
      continue;
    const name = basename(file, '.json');
    const folder = dirname(file) === '.' ? '' : dirname(file);
    if (isLocaleName(name)) flat.set(folder, [...(flat.get(folder) ?? []), { locale: name, file }]);
    const parent = basename(folder);
    if (folder && isLocaleName(parent)) {
      const key = `${dirname(folder) === '.' ? '' : dirname(folder)}\n${name}`;
      nested.set(key, [...(nested.get(key) ?? []), { locale: parent, file }]);
    }
  }
  const known = (folder: string) =>
    LOCALE_FOLDERS.has(basename(folder).toLowerCase()) || extraFolders.includes(folder);
  const groups: JsonGroup[] = [];
  for (const [folder, items] of flat) {
    if (items.length >= 2 || known(folder))
      groups.push({ folder, namespace: basename(folder) || 'translation', files: items });
  }
  for (const [key, items] of nested) {
    const [folder = '', namespace = ''] = key.split('\n');
    if (items.length >= 2 || known(folder)) groups.push({ folder, namespace, files: items });
  }
  return groups.sort((a, b) => (a.folder + a.namespace).localeCompare(b.folder + b.namespace));
}

async function jsonCatalogs(
  root: string,
  files: string[],
  config: Config,
  notes: string[],
): Promise<Catalog[]> {
  const groups = jsonGroups(
    files,
    config.catalogDirs?.map((dir) => dir.replace(/^\.\/|\/$/g, '')) ?? [],
  );
  const catalogs: Catalog[] = [];
  for (const group of groups) {
    const read: JsonFile[] = [];
    for (const item of group.files) read.push({ ...item, ...(await readText(root, item.file)) });
    const locales = read.map((file) => file.locale);
    const configured =
      config.sourceLanguage &&
      locales.find((locale) => locale.toLowerCase() === config.sourceLanguage?.toLowerCase());
    const source =
      configured ||
      locales.find((locale) => /^en(?:[-_]|$)/.test(locale)) ||
      [...locales].sort()[0] ||
      'en';
    if (!configured && !/^en(?:[-_]|$)/.test(source)) {
      notes.push(
        `${group.folder || '.'}: assumed ${source} is the source language; set "sourceLanguage" in .globallingo.json`,
      );
    }
    const detected: MessageSyntax =
      config.jsonSyntax ??
      (await detectJsonSyntax(
        root,
        files,
        group.folder,
        read.map((file) => file.text ?? ''),
      ));
    const id =
      group.namespace === basename(group.folder)
        ? `${group.folder}/*.json`
        : `${group.folder ? `${group.folder}/` : ''}*/${group.namespace}.json`;
    const catalog = readJsonCatalog(id, group.namespace, source, detected, read);
    // Namespaces of one folder share their locales: a locale folder without this file misses it.
    const siblings = groups.filter(
      (other) => other.folder === group.folder && other.namespace !== basename(group.folder),
    );
    if (group.namespace !== basename(group.folder) && siblings.length > 1) {
      catalog.expectedLocales = [
        ...new Set(siblings.flatMap((other) => other.files.map((file) => file.locale))),
      ];
    }
    catalogs.push(catalog);
  }
  return catalogs;
}

export async function discoverCatalogs(
  root: string,
  files: string[],
  config: Config,
): Promise<Discovered> {
  const notes: string[] = [];
  const catalogs = [
    ...(await stringCatalogs(root, files)),
    ...(await stringsTables(root, files, config, notes)),
    ...(await arbCatalogs(root, files, config, notes)),
    ...(await jsonCatalogs(root, files, config, notes)),
  ];
  for (const catalog of catalogs) notes.push(...(catalog.notes ?? []));
  return { catalogs, notes };
}
