// Blanks the comments of Swift, Objective-C, Dart and JavaScript/TypeScript source while keeping
// string literals and the length and line breaks of the text, so patterns can run over code
// without matching commented-out lines, and offsets still give the right line.

export type SourceLanguage = 'swift' | 'objc' | 'dart' | 'js';

const blank = (text: string) => text.replace(/[^\n]/g, ' ');

/** Index after the string literal that starts at `start`, or the end of the line for a broken one. */
function skipString(code: string, start: number, language: SourceLanguage): number {
  const char = code[start] as string;
  // Triple-quoted strings (Swift """, Dart ''' and """).
  if ((language === 'swift' || language === 'dart') && code.startsWith(char.repeat(3), start)) {
    const end = code.indexOf(char.repeat(3), start + 3);
    return end === -1 ? code.length : end + 3;
  }
  const multiline = char === '`';
  for (let i = start + 1; i < code.length; i += 1) {
    const current = code[i];
    if (current === '\\') {
      i += 1;
    } else if (current === char) {
      return i + 1;
    } else if (current === '\n' && !multiline) {
      return i;
    }
  }
  return code.length;
}

/** Whether a `/` at `index` starts a JavaScript regular expression rather than a division. */
function startsRegex(code: string, index: number): boolean {
  let i = index - 1;
  while (i >= 0 && (code[i] === ' ' || code[i] === '\t')) i -= 1;
  if (i < 0) return true;
  const previous = code[i] as string;
  if ('(,=:[!&|?{};+-*%<>~^\n'.includes(previous)) return true;
  return /\b(?:return|typeof|case|do|else|in|of|yield|await|void|delete)$/.test(
    code.slice(Math.max(0, i - 7), i + 1),
  );
}

function skipRegex(code: string, start: number): number {
  let inClass = false;
  for (let i = start + 1; i < code.length; i += 1) {
    const char = code[i];
    if (char === '\\') i += 1;
    else if (char === '[') inClass = true;
    else if (char === ']') inClass = false;
    else if (char === '/' && !inClass) return i + 1;
    else if (char === '\n') return i;
  }
  return code.length;
}

export function stripComments(source: string, language: SourceLanguage): string {
  const nests = language === 'swift' || language === 'dart';
  let output = '';
  let index = 0;
  while (index < source.length) {
    const char = source[index] as string;
    const next = source[index + 1];
    if (char === '/' && next === '/') {
      const end = source.indexOf('\n', index);
      const stop = end === -1 ? source.length : end;
      output += blank(source.slice(index, stop));
      index = stop;
      continue;
    }
    if (char === '/' && next === '*') {
      let depth = 1;
      let i = index + 2;
      while (i < source.length && depth > 0) {
        if (nests && source[i] === '/' && source[i + 1] === '*') {
          depth += 1;
          i += 2;
        } else if (source[i] === '*' && source[i + 1] === '/') {
          depth -= 1;
          i += 2;
        } else {
          i += 1;
        }
      }
      output += blank(source.slice(index, i));
      index = i;
      continue;
    }
    const isQuote =
      char === '"' || (char === "'" && language !== 'swift') || (char === '`' && language === 'js');
    if (isQuote) {
      const end = skipString(source, index, language);
      output += source.slice(index, end);
      index = end;
      continue;
    }
    if (char === '/' && language === 'js' && startsRegex(source, index)) {
      const end = skipRegex(source, index);
      output += source.slice(index, end);
      index = end;
      continue;
    }
    output += char;
    index += 1;
  }
  return output;
}

/**
 * The `)` that closes each `(` of the code, found in one pass (string literals skipped), so
 * looking up many calls in a crafted file stays linear. Unclosed parentheses map to -1.
 */
export function parenPairs(code: string): (open: number) => number {
  const pairs = new Map<number, number>();
  const stack: number[] = [];
  for (let i = 0; i < code.length; i += 1) {
    const char = code[i];
    if (char === '"' || char === "'" || char === '`') {
      let j = i + 1;
      while (j < code.length && code[j] !== char && code[j] !== '\n') j += code[j] === '\\' ? 2 : 1;
      i = j;
    } else if (char === '(') {
      stack.push(i);
    } else if (char === ')') {
      const open = stack.pop();
      if (open !== undefined) pairs.set(open, i);
    }
  }
  return (open) => pairs.get(open) ?? -1;
}

/** 1-based line of an offset. */
export function lineAt(text: string, offset: number): number {
  let line = 1;
  for (let i = 0; i < offset && i < text.length; i += 1) if (text.charCodeAt(i) === 10) line += 1;
  return line;
}

/** Decodes the content of a string literal (without its quotes); undefined when it interpolates. */
export function literalValue(body: string, language: SourceLanguage): string | undefined {
  if (language === 'swift' && body.includes('\\(')) return undefined;
  if (language === 'dart' && /\$[{A-Za-z_]/.test(body)) return undefined;
  if (language === 'js' && body.includes('${')) return undefined;
  return body.replace(
    /\\(u\{[0-9a-fA-F]{1,6}\}|u[0-9a-fA-F]{4}|.)/g,
    (_match, sequence: string) => {
      if (sequence.startsWith('u{')) {
        const code = Number.parseInt(sequence.slice(2, -1), 16);
        return code <= 0x10ffff ? String.fromCodePoint(code) : '';
      }
      if (sequence.length === 5 && sequence.startsWith('u'))
        return String.fromCharCode(Number.parseInt(sequence.slice(1), 16));
      return (
        ({ n: '\n', t: '\t', r: '\r', '0': '\0' } as Record<string, string>)[sequence] ?? sequence
      );
    },
  );
}
