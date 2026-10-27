// Project settings that change how catalogs are read: Flutter's l10n.yaml, and the i18n library a
// JavaScript app depends on, which decides the placeholder syntax of its JSON files.
import { posix } from 'node:path';
import type { MessageSyntax } from '../model.js';
import { decode } from '../parse/decode.js';
import { readLimited } from './files.js';

const { dirname, join } = posix;

export interface FlutterSettings {
  /** `arb-dir`, relative to the checked folder. */
  arbDir: string;
  templateArbFile: string;
  outputClass: string;
  useEscaping: boolean;
}

/**
 * Reads the flat `key: value` lines of l10n.yaml that matter here, with gen_l10n's defaults.
 * https://docs.flutter.dev/ui/internationalization#configuring-the-l10n-yaml-file
 */
export function readFlutterSettings(text: string, folder: string): FlutterSettings {
  const values = new Map<string, string>();
  for (const line of text.split(/\r?\n/)) {
    const match = /^([A-Za-z-]+)\s*:\s*(.*?)\s*$/.exec(line.replace(/\s+#.*$/, ''));
    if (!match) continue;
    values.set(match[1] as string, (match[2] as string).replace(/^(['"])(.*)\1$/, '$2'));
  }
  const arbDir = (values.get('arb-dir') ?? 'lib/l10n').replace(/^\.\/|\/$/g, '');
  return {
    arbDir: folder ? join(folder, arbDir) : arbDir,
    templateArbFile: values.get('template-arb-file') ?? 'app_en.arb',
    outputClass: values.get('output-class') ?? 'AppLocalizations',
    useEscaping: values.get('use-escaping') === 'true',
  };
}

const ICU_PACKAGES = /^(react-intl|@formatjs\/|next-intl$|use-intl$|i18next-icu$|@lingui\/)/;
const I18NEXT_PACKAGES = /^(i18next|react-i18next|next-i18next|i18next-)/;
const I18N_JS_PACKAGES = /^i18n-js$/;

/** The placeholder syntax a package.json's dependencies imply, if any. */
export function syntaxFromPackageJson(text: string): MessageSyntax | undefined {
  let manifest: Record<string, unknown>;
  try {
    manifest = JSON.parse(text) as Record<string, unknown>;
  } catch {
    return undefined;
  }
  const names = ['dependencies', 'devDependencies', 'peerDependencies'].flatMap((field) => {
    const deps = manifest[field];
    return deps && typeof deps === 'object' ? Object.keys(deps) : [];
  });
  if (names.some((name) => ICU_PACKAGES.test(name))) return 'icu';
  if (names.some((name) => I18NEXT_PACKAGES.test(name))) return 'i18next';
  if (names.some((name) => I18N_JS_PACKAGES.test(name))) return 'i18n-js';
  return undefined;
}

/** Placeholders written in the files themselves, for apps whose package.json says nothing. */
export function syntaxFromContent(texts: string[]): MessageSyntax {
  const all = texts.join('\n');
  if (/%\{[^}]+\}/.test(all)) return 'i18n-js';
  if (/\{\{[^}]+\}\}/.test(all)) return 'i18next';
  return 'icu';
}

/** The syntax of a JSON translation folder: nearest package.json up the tree, then the content. */
export async function detectJsonSyntax(
  root: string,
  files: string[],
  folder: string,
  texts: string[],
): Promise<MessageSyntax> {
  const manifests = new Set(
    files.filter((file) => file === 'package.json' || file.endsWith('/package.json')),
  );
  let current = folder;
  for (;;) {
    const candidate = current ? `${current}/package.json` : 'package.json';
    if (manifests.has(candidate)) {
      const read = await readLimited(root, candidate, 1024 * 1024);
      const syntax = 'bytes' in read ? syntaxFromPackageJson(decode(read.bytes).text) : undefined;
      if (syntax) return syntax;
    }
    if (!current) break;
    const parent = dirname(current);
    current = parent === '.' ? '' : parent;
  }
  return syntaxFromContent(texts);
}
