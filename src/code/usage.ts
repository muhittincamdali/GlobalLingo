// KEY003: keys of a catalog that no source file mentions. The check is deliberately generous to
// the code: any string literal with the key counts as a use (keys kept in constants), a literal
// that ends in "." or "_" or a template or interpolated string counts as a prefix that any key
// may complete, and in Dart any member access with the key's name counts. What is left is most
// likely dead, but code can build keys in ways no pattern sees, so the rule is "info".
import type { Catalog, Ecosystem } from '../model.js';
import { i18nextNesting } from '../messages/interpolation.js';
import { type Draft, quote } from '../rules/draft.js';
import { type SourceLanguage, stripComments } from './lexer.js';

export interface Usage {
  literals: Set<string>;
  prefixes: Set<string>;
  dartMembers: Set<string>;
  /** Ecosystems with at least one source file read. */
  ecosystems: Set<Ecosystem>;
}

export const emptyUsage = (): Usage => ({
  literals: new Set(),
  prefixes: new Set(),
  dartMembers: new Set(),
  ecosystems: new Set(),
});

const ECOSYSTEM: Record<SourceLanguage, Ecosystem> = {
  swift: 'apple',
  objc: 'apple',
  dart: 'flutter',
  js: 'js',
};

/** Longest literal kept; a key is never longer, and a crafted file cannot fill the set. */
const MAX_LITERAL = 300;

export function collectUsage(text: string, language: SourceLanguage, usage: Usage): void {
  usage.ecosystems.add(ECOSYSTEM[language]);
  const code = stripComments(text, language);
  for (const match of code.matchAll(/(["'`])((?:(?!\1)[^\\\n]|\\.){1,300})\1/g)) {
    const body = match[2] as string;
    const dynamic =
      (match[1] === '`' && body.indexOf('${') >= 0) ||
      (language === 'swift' && body.includes('\\(')) ||
      (language === 'dart' && /\$[{A-Za-z_]/.test(body));
    if (dynamic) {
      const prefix = body.slice(
        0,
        Math.min(
          ...['${', '\\(', '$'].map((mark) => body.indexOf(mark)).filter((index) => index >= 0),
        ),
      );
      if (prefix) usage.prefixes.add(prefix);
      continue;
    }
    if (body.length > MAX_LITERAL) continue;
    usage.literals.add(body);
    if (/[._:]$/.test(body)) usage.prefixes.add(body);
  }
  if (language === 'dart') {
    for (const match of code.matchAll(/\.\s*([A-Za-z_]\w*)/g))
      usage.dartMembers.add(match[1] as string);
  }
}

interface PrefixNode {
  end: boolean;
  next: Map<string, PrefixNode>;
}

/**
 * A test for "starts with one of the prefixes" that walks the text once through a tree of the
 * prefixes' characters. Calling startsWith for every prefix on every key would multiply the
 * number of literals in the code by the number of keys.
 */
function startsWithAny(prefixes: Iterable<string>): (text: string) => boolean {
  const root: PrefixNode = { end: false, next: new Map() };
  for (const prefix of prefixes) {
    let node = root;
    // UTF-16 units, as startsWith compares them.
    for (const char of prefix.split('')) {
      let child = node.next.get(char);
      if (!child) {
        child = { end: false, next: new Map() };
        node.next.set(char, child);
      }
      node = child;
    }
    node.end = true;
  }
  return (text) => {
    let node: PrefixNode | undefined = root;
    if (node.end) return true;
    for (let index = 0; index < text.length; index += 1) {
      node = node.next.get(text[index] as string);
      if (!node) return false;
      if (node.end) return true;
    }
    return false;
  };
}

/** Tables whose keys the code does not name: Info.plist keys, and generated or storyboard ones. */
const NOT_LOOKED_UP = /^(?:InfoPlist|AppShortcuts|Root|Main|LaunchScreen)$/;

export function unusedKeys(
  catalogs: Catalog[],
  usage: Usage,
  ignoreKey: (key: string) => boolean,
): Draft[] {
  const drafts: Draft[] = [];
  const startsWithPrefix = startsWithAny(usage.prefixes);
  for (const catalog of catalogs) {
    if (!usage.ecosystems.has(catalog.ecosystem) || catalog.format === 'xcstrings') continue;
    if (catalog.format === 'strings' && NOT_LOOKED_UP.test(catalog.name)) continue;
    // i18next values can use other keys with $t(key).
    const nested = new Set(
      catalog.syntax === 'i18next'
        ? [...catalog.entries.values()].flatMap((entry) =>
            [...entry.translations.values()].flatMap((translation) =>
              translation.texts.flatMap((text) => i18nextNesting(text.text)),
            ),
          )
        : [],
    );
    for (const entry of catalog.entries.values()) {
      const source = entry.translations.get(catalog.sourceLocale);
      if (!source || ignoreKey(entry.key)) continue;
      // i18next ordinal plurals are looked up by their base key with { ordinal: true }.
      const key = entry.key.replace(/_ordinal$/, '');
      const mentioned =
        catalog.format === 'arb'
          ? usage.dartMembers.has(key)
          : usage.literals.has(key) ||
            usage.literals.has(`${catalog.name}:${key}`) ||
            startsWithPrefix(key) ||
            startsWithPrefix(`${catalog.name}:${key}`);
      const used = mentioned || nested.has(entry.key);
      if (used) continue;
      drafts.push({
        rule: 'KEY003',
        ecosystem: catalog.ecosystem,
        file: source.file,
        line: source.line,
        key,
        message: `${quote(key)} is not mentioned in any source file`,
        subject: 'unused',
      });
    }
  }
  return drafts;
}
