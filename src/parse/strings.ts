// Reads a .strings file: `"key" = "value";` pairs with C-style comments, in the old-style
// property list syntax Foundation accepts (unquoted keys and values made of letters, digits and
// `_$+/:.-`, and `"key";` for a value equal to its key).

export interface StringsPair {
  key: string;
  value: string;
  line: number;
}

export interface StringsFile {
  pairs: StringsPair[];
}

export class StringsSyntaxError extends Error {
  constructor(
    message: string,
    readonly line: number,
  ) {
    super(`${message} (line ${line})`);
  }
}

const UNQUOTED = /[A-Za-z0-9_$+/:.-]/;

const SIMPLE_ESCAPES: Record<string, string> = {
  a: '\u0007',
  b: '\b',
  f: '\f',
  n: '\n',
  r: '\r',
  t: '\t',
  v: '\v',
  '"': '"',
  "'": "'",
  '\\': '\\',
  '\n': '\n',
};

export function parseStrings(text: string): StringsFile {
  let index = 0;
  let line = 1;
  const pairs: StringsPair[] = [];

  const fail = (message: string): never => {
    throw new StringsSyntaxError(message, line);
  };

  const skip = () => {
    while (index < text.length) {
      const char = text[index];
      if (char === '\n') {
        line += 1;
        index += 1;
      } else if (char === ' ' || char === '\t' || char === '\r' || char === '\f') {
        index += 1;
      } else if (char === '/' && text[index + 1] === '/') {
        while (index < text.length && text[index] !== '\n') index += 1;
      } else if (char === '/' && text[index + 1] === '*') {
        const end = text.indexOf('*/', index + 2);
        if (end === -1) fail('Unterminated comment');
        for (let i = index; i < end; i += 1) if (text[i] === '\n') line += 1;
        index = end + 2;
      } else {
        return;
      }
    }
  };

  const readQuoted = (): string => {
    index += 1;
    let result = '';
    while (index < text.length) {
      const char = text[index] as string;
      if (char === '"') {
        index += 1;
        return result;
      }
      if (char === '\n') line += 1;
      if (char !== '\\') {
        result += char;
        index += 1;
        continue;
      }
      const next = text[index + 1] ?? '';
      if (next === 'U' || next === 'u') {
        const hex = /^[0-9a-fA-F]{1,4}/.exec(text.slice(index + 2, index + 6))?.[0] ?? '';
        if (!hex) fail(`Invalid \\${next} escape`);
        result += String.fromCharCode(Number.parseInt(hex, 16));
        index += 2 + hex.length;
      } else if (/[0-7]/.test(next)) {
        const octal = /^[0-7]{1,3}/.exec(text.slice(index + 1, index + 4))?.[0] ?? '0';
        result += String.fromCharCode(Number.parseInt(octal, 8));
        index += 1 + octal.length;
      } else {
        if (next === '\n') line += 1;
        result += SIMPLE_ESCAPES[next] ?? next;
        index += 2;
      }
    }
    return fail('Unterminated string');
  };

  const readToken = (what: string): string => {
    if (text[index] === '"') return readQuoted();
    const start = index;
    while (index < text.length && UNQUOTED.test(text[index] as string)) index += 1;
    if (index === start) fail(`Expected ${what}`);
    return text.slice(start, index);
  };

  for (;;) {
    skip();
    if (index >= text.length) break;
    const pairLine = line;
    const key = readToken('a key in double quotes');
    skip();
    let value = key;
    if (text[index] === '=') {
      index += 1;
      skip();
      value = readToken(`a value for "${key}"`);
      skip();
    }
    if (text[index] !== ';') fail(`Expected ";" after "${key}"`);
    index += 1;
    pairs.push({ key, value, line: pairLine });
  }
  return { pairs };
}
