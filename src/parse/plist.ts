// Reads an XML property list, enough for .stringsdict files: dict, array, string, integer, real,
// true, false, date and data, with the line of every dictionary key. Duplicate keys in a dict are
// recorded, because Foundation keeps only one of them.

export type PlistValue = PlistDict | PlistArray | PlistScalar;

export interface PlistDict {
  type: 'dict';
  line: number;
  entries: { key: string; line: number; value: PlistValue }[];
}

export interface PlistArray {
  type: 'array';
  line: number;
  items: PlistValue[];
}

export interface PlistScalar {
  type: 'string' | 'integer' | 'real' | 'boolean' | 'date' | 'data';
  line: number;
  value: string;
}

export interface PlistDocument {
  root: PlistValue;
  duplicates: { key: string; line: number; firstLine: number }[];
}

export class PlistSyntaxError extends Error {
  constructor(
    message: string,
    readonly line: number,
  ) {
    super(`${message} (line ${line})`);
  }
}

export const MAX_PLIST_DEPTH = 64;
/** Far longer than `<plist version="1.0">`; a longer tag is a crafted file, not a property list. */
export const MAX_TAG_LENGTH = 1024;

const ENTITIES: Record<string, string> = { lt: '<', gt: '>', amp: '&', quot: '"', apos: "'" };

function decodeEntities(text: string, fail: (message: string) => never): string {
  return text.replace(/&(#x[0-9a-fA-F]+|#\d+|[a-z]+);/g, (_match, name: string) => {
    if (name.startsWith('#')) {
      const code = name[1] === 'x' ? Number.parseInt(name.slice(2), 16) : Number(name.slice(1));
      if (!Number.isSafeInteger(code) || code < 0 || code > 0x10ffff) {
        return fail(`Invalid character reference &${name};`);
      }
      return String.fromCodePoint(code);
    }
    const value = ENTITIES[name];
    return value ?? fail(`Unknown entity &${name};`);
  });
}

interface Tag {
  name: string;
  closing: boolean;
  selfClosing: boolean;
  line: number;
}

const isLetter = (code: number) => (code >= 65 && code <= 90) || (code >= 97 && code <= 122);

/**
 * Reads the text between `<` and `>`: an optional `/`, the name, attributes without a `/`, and an
 * optional `/` before trailing space. One pass; a pattern for this backtracks on a long tag.
 */
function readTag(body: string, line: number): Tag | undefined {
  const closing = body.startsWith('/');
  let end = closing ? 1 : 0;
  while (end < body.length && isLetter(body.charCodeAt(end))) end += 1;
  const name = body.slice(closing ? 1 : 0, end);
  if (!name) return undefined;
  let rest = body.slice(end).trimEnd();
  const selfClosing = rest.endsWith('/');
  if (selfClosing) rest = rest.slice(0, -1);
  if (rest.includes('/')) return undefined;
  return { name, closing, selfClosing, line };
}

export function parsePlist(text: string): PlistDocument {
  let index = 0;
  let line = 1;
  const duplicates: PlistDocument['duplicates'] = [];
  const fail = (message: string): never => {
    throw new PlistSyntaxError(message, line);
  };
  const advanceTo = (end: number) => {
    for (let i = index; i < end; i += 1) if (text[i] === '\n') line += 1;
    index = end;
  };

  /** Skips text, comments, the XML declaration and the DOCTYPE; returns the next element tag. */
  const nextTag = (): Tag | undefined => {
    for (;;) {
      const open = text.indexOf('<', index);
      if (open === -1) {
        advanceTo(text.length);
        return undefined;
      }
      advanceTo(open);
      if (text.startsWith('<!--', index)) {
        const end = text.indexOf('-->', index);
        if (end === -1) fail('Unterminated comment');
        advanceTo(end + 3);
        continue;
      }
      if (text.startsWith('<?', index) || text.startsWith('<!', index)) {
        const end = text.indexOf('>', index);
        if (end === -1) fail('Unterminated declaration');
        advanceTo(end + 1);
        continue;
      }
      const end = text.indexOf('>', index);
      if (end === -1) fail('Unterminated tag');
      if (end - index - 1 > MAX_TAG_LENGTH) fail(`Tag longer than ${MAX_TAG_LENGTH} characters`);
      const tagLine = line;
      const body = text.slice(index + 1, end);
      advanceTo(end + 1);
      return readTag(body, tagLine) ?? fail(`Unreadable tag <${body.slice(0, 40)}>`);
    }
  };

  /** Text up to `</name>`, entities decoded; CDATA sections are kept as they are. */
  const readText = (name: string): string => {
    let result = '';
    for (;;) {
      const cdata = text.indexOf('<![CDATA[', index);
      const close = text.indexOf(`</${name}>`, index);
      if (close === -1) fail(`Missing </${name}>`);
      if (cdata !== -1 && cdata < close) {
        result += decodeEntities(text.slice(index, cdata), fail);
        const end = text.indexOf(']]>', cdata);
        if (end === -1) fail('Unterminated CDATA section');
        result += text.slice(cdata + 9, end);
        advanceTo(end + 3);
        continue;
      }
      result += decodeEntities(text.slice(index, close), fail);
      advanceTo(close + name.length + 3);
      return result;
    }
  };

  const readValue = (tag: Tag, depth: number): PlistValue => {
    if (depth > MAX_PLIST_DEPTH) fail(`Nested deeper than ${MAX_PLIST_DEPTH} levels`);
    switch (tag.name) {
      case 'dict': {
        const dict: PlistDict = { type: 'dict', line: tag.line, entries: [] };
        if (tag.selfClosing) return dict;
        const seen = new Map<string, number>();
        for (;;) {
          const keyTag = nextTag() ?? fail('Missing </dict>');
          if (keyTag.closing && keyTag.name === 'dict') return dict;
          if (keyTag.name !== 'key' || keyTag.closing)
            fail(`Expected <key>, found <${keyTag.name}>`);
          const key = keyTag.selfClosing ? '' : readText('key');
          const valueTag = nextTag() ?? fail(`Missing a value for key "${key}"`);
          if (valueTag.closing) fail(`Missing a value for key "${key}"`);
          const value = readValue(valueTag, depth + 1);
          const firstLine = seen.get(key);
          if (firstLine === undefined) seen.set(key, keyTag.line);
          else duplicates.push({ key, line: keyTag.line, firstLine });
          dict.entries.push({ key, line: keyTag.line, value });
        }
      }
      case 'array': {
        const array: PlistArray = { type: 'array', line: tag.line, items: [] };
        if (tag.selfClosing) return array;
        for (;;) {
          const item = nextTag() ?? fail('Missing </array>');
          if (item.closing && item.name === 'array') return array;
          if (item.closing) fail(`Unexpected </${item.name}>`);
          array.items.push(readValue(item, depth + 1));
        }
      }
      case 'true':
      case 'false':
        if (!tag.selfClosing) readText(tag.name);
        return { type: 'boolean', line: tag.line, value: tag.name };
      case 'string':
      case 'integer':
      case 'real':
      case 'date':
      case 'data': {
        const value = tag.selfClosing ? '' : readText(tag.name);
        const type = tag.name === 'string' ? 'string' : tag.name;
        return { type: type as PlistScalar['type'], line: tag.line, value };
      }
      default:
        return fail(`Unexpected <${tag.name}>`);
    }
  };

  let first = nextTag();
  if (first?.name === 'plist' && !first.closing) first = nextTag();
  if (!first || first.closing) fail('The file has no property list value');
  const root = readValue(first as Tag, 0);
  return { root, duplicates };
}

export const dictValue = (dict: PlistDict, key: string): PlistValue | undefined => {
  for (let i = dict.entries.length - 1; i >= 0; i -= 1) {
    if (dict.entries[i]?.key === key) return dict.entries[i]?.value;
  }
  return undefined;
};
