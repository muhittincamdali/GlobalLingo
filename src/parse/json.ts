// A JSON reader that keeps what JSON.parse throws away: the line of every key, and keys that
// appear twice in one object (JSON.parse keeps the last one without a word, and so do Xcode,
// gen_l10n and i18next). Nesting is limited so a hostile file cannot exhaust the stack.

export type JsonValue = JsonObject | JsonArray | JsonScalar;

export interface JsonObject {
  type: 'object';
  line: number;
  /** Members in file order, duplicates included. */
  members: JsonMember[];
}

export interface JsonMember {
  key: string;
  line: number;
  value: JsonValue;
}

export interface JsonArray {
  type: 'array';
  line: number;
  items: JsonValue[];
}

export interface JsonScalar {
  type: 'string' | 'number' | 'boolean' | 'null';
  line: number;
  value: string | number | boolean | null;
}

export interface JsonDuplicate {
  /** Keys from the root to the object holding the duplicate. */
  path: string[];
  key: string;
  line: number;
  firstLine: number;
}

export interface JsonDocument {
  root: JsonValue;
  duplicates: JsonDuplicate[];
}

export class JsonSyntaxError extends Error {
  constructor(
    message: string,
    readonly line: number,
  ) {
    super(`${message} (line ${line})`);
  }
}

/** Deeper than any real catalog; String Catalogs nest about eight levels. */
export const MAX_JSON_DEPTH = 128;

const ESCAPES: Record<string, string> = {
  '"': '"',
  '\\': '\\',
  '/': '/',
  b: '\b',
  f: '\f',
  n: '\n',
  r: '\r',
  t: '\t',
};

export function parseJson(text: string): JsonDocument {
  let index = text.charCodeAt(0) === 0xfeff ? 1 : 0;
  let line = 1;
  const duplicates: JsonDuplicate[] = [];

  const fail = (message: string): never => {
    throw new JsonSyntaxError(message, line);
  };

  const skipSpace = () => {
    while (index < text.length) {
      const char = text[index];
      if (char === '\n') line += 1;
      else if (char !== ' ' && char !== '\t' && char !== '\r') return;
      index += 1;
    }
  };

  const readString = (): string => {
    index += 1; // opening quote
    let result = '';
    let start = index;
    while (index < text.length) {
      const char = text[index];
      if (char === '"') {
        result += text.slice(start, index);
        index += 1;
        return result;
      }
      if (char === '\\') {
        result += text.slice(start, index);
        const next = text[index + 1] ?? '';
        if (next === 'u') {
          const hex = text.slice(index + 2, index + 6);
          if (!/^[0-9a-fA-F]{4}$/.test(hex)) fail('Invalid \\u escape in a string');
          result += String.fromCharCode(Number.parseInt(hex, 16));
          index += 6;
        } else {
          const escaped = ESCAPES[next];
          if (escaped === undefined) fail(`Invalid escape \\${next} in a string`);
          result += escaped;
          index += 2;
        }
        start = index;
        continue;
      }
      if (char === '\n' || (char !== undefined && char.charCodeAt(0) < 0x20)) {
        fail('Unescaped control character in a string');
      }
      index += 1;
    }
    return fail('Unterminated string');
  };

  const readValue = (path: string[], depth: number): JsonValue => {
    if (depth > MAX_JSON_DEPTH) fail(`Nested deeper than ${MAX_JSON_DEPTH} levels`);
    skipSpace();
    const startLine = line;
    const char = text[index];
    if (char === '{') {
      index += 1;
      const members: JsonMember[] = [];
      const seen = new Map<string, number>();
      skipSpace();
      if (text[index] === '}') {
        index += 1;
        return { type: 'object', line: startLine, members };
      }
      for (;;) {
        skipSpace();
        if (text[index] !== '"') fail('Expected a key in double quotes');
        const keyLine = line;
        const key = readString();
        skipSpace();
        if (text[index] !== ':') fail(`Expected ":" after "${key}"`);
        index += 1;
        const value = readValue([...path, key], depth + 1);
        const firstLine = seen.get(key);
        if (firstLine === undefined) seen.set(key, keyLine);
        else duplicates.push({ path, key, line: keyLine, firstLine });
        members.push({ key, line: keyLine, value });
        skipSpace();
        if (text[index] === ',') {
          index += 1;
          continue;
        }
        if (text[index] === '}') {
          index += 1;
          return { type: 'object', line: startLine, members };
        }
        fail('Expected "," or "}" in an object');
      }
    }
    if (char === '[') {
      index += 1;
      const items: JsonValue[] = [];
      skipSpace();
      if (text[index] === ']') {
        index += 1;
        return { type: 'array', line: startLine, items };
      }
      for (;;) {
        items.push(readValue([...path, String(items.length)], depth + 1));
        skipSpace();
        if (text[index] === ',') {
          index += 1;
          continue;
        }
        if (text[index] === ']') {
          index += 1;
          return { type: 'array', line: startLine, items };
        }
        fail('Expected "," or "]" in an array');
      }
    }
    if (char === '"') return { type: 'string', line: startLine, value: readString() };
    const literal = /^(?:true|false|null|-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE][+-]?\d+)?)/.exec(
      text.slice(index, index + 64),
    );
    if (!literal) return fail(char === undefined ? 'Unexpected end of file' : 'Unexpected text');
    index += literal[0].length;
    const word = literal[0];
    if (word === 'true' || word === 'false') {
      return { type: 'boolean', line: startLine, value: word === 'true' };
    }
    if (word === 'null') return { type: 'null', line: startLine, value: null };
    return { type: 'number', line: startLine, value: Number(word) };
  };

  const root = readValue([], 0);
  skipSpace();
  if (index < text.length) fail('Unexpected text after the end of the document');
  return { root, duplicates };
}

/** The value of `key` the way JSON.parse sees it: the last member with that key. */
export function member(object: JsonObject, key: string): JsonMember | undefined {
  for (let i = object.members.length - 1; i >= 0; i -= 1) {
    const candidate = object.members[i];
    if (candidate?.key === key) return candidate;
  }
  return undefined;
}

/** The members of an object with duplicates resolved the way JSON.parse resolves them. */
export function uniqueMembers(object: JsonObject): JsonMember[] {
  const last = new Map<string, JsonMember>();
  for (const item of object.members) last.set(item.key, item);
  return [...last.values()];
}

export const asObject = (value: JsonValue | undefined): JsonObject | undefined =>
  value?.type === 'object' ? value : undefined;

export const asString = (value: JsonValue | undefined): string | undefined =>
  value?.type === 'string' ? (value.value as string) : undefined;
