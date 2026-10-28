// ICU MessageFormat, as Flutter's gen_l10n and FormatJS (react-intl) read it: `{name}`,
// `{name, number}`, `{count, plural, =0{…} one{…} other{…}}`, `{gender, select, …}` and
// `{n, selectordinal, …}`. The parser collects argument names and plural forms and reports the
// first syntax error; it does not format anything.
// https://unicode-org.github.io/icu/userguide/format_parse/messages/

export interface IcuArgument {
  name: string;
  /** `plain` for `{name}`; otherwise the type after the first comma. */
  type: string;
}

export interface IcuPlural {
  name: string;
  type: 'cardinal' | 'ordinal';
  /** CLDR keywords used as selectors (`=0`-style exact values are not included). */
  categories: string[];
  hasOther: boolean;
}

export interface IcuParse {
  arguments: IcuArgument[];
  plurals: IcuPlural[];
  /** The first syntax error, if any. */
  error?: string;
}

export interface IcuOptions {
  /**
   * Whether an apostrophe starts quoted text, as in ICU and FormatJS. Flutter turns this on only
   * with `use-escaping: true` in l10n.yaml.
   */
  apostropheQuoting: boolean;
}

export const PLURAL_KEYWORDS = ['zero', 'one', 'two', 'few', 'many', 'other'] as const;
export const MAX_ICU_DEPTH = 32;

class IcuError extends Error {}

const NAME = /[^\s{},#'|]/u;

export function parseIcu(text: string, options: IcuOptions): IcuParse {
  const result: IcuParse = { arguments: [], plurals: [] };
  let index = 0;

  const fail = (message: string): never => {
    throw new IcuError(`${message} at character ${index + 1}`);
  };
  const skipSpace = () => {
    while (index < text.length && /\s/u.test(text[index] as string)) index += 1;
  };
  const readName = (what: string): string => {
    skipSpace();
    const start = index;
    while (index < text.length && NAME.test(text[index] as string)) index += 1;
    if (index === start) fail(`Expected ${what}`);
    return text.slice(start, index);
  };

  /** Reads message text up to an unmatched `}` (or the end at depth 0). */
  const readMessage = (depth: number, inPlural: boolean) => {
    if (depth > MAX_ICU_DEPTH) fail(`Nested deeper than ${MAX_ICU_DEPTH} levels`);
    while (index < text.length) {
      const char = text[index];
      if (char === "'" && options.apostropheQuoting) {
        const next = text[index + 1];
        if (next === "'") {
          index += 2;
        } else if (next === '{' || next === '}' || (inPlural && next === '#') || next === '|') {
          const end = text.indexOf("'", index + 1);
          // An unterminated quote runs to the end of the message, as in ICU.
          index = end === -1 ? text.length : end + 1;
        } else {
          index += 1;
        }
      } else if (char === '{') {
        index += 1;
        readArgument(depth + 1);
      } else if (char === '}') {
        if (depth === 0) fail('Unmatched "}"');
        return;
      } else {
        index += 1;
      }
    }
    if (depth > 0) fail('Missing "}"');
  };

  const readSubMessage = (depth: number, inPlural: boolean) => {
    skipSpace();
    if (text[index] !== '{') fail('Expected "{" after a selector');
    index += 1;
    readMessage(depth, inPlural);
    if (text[index] !== '}') fail('Missing "}"');
    index += 1;
  };

  const readArgument = (depth: number) => {
    const name = readName('an argument name');
    skipSpace();
    if (index >= text.length) fail(`Missing "}" after "${name}"`);
    if (text[index] === '}') {
      index += 1;
      result.arguments.push({ name, type: 'plain' });
      return;
    }
    if (text[index] !== ',') fail(`Expected "," or "}" after "${name}"`);
    index += 1;
    const type = readName(`a type for "${name}"`);
    result.arguments.push({ name, type });
    skipSpace();
    if (type === 'plural' || type === 'selectordinal' || type === 'select') {
      if (text[index] !== ',') fail(`Expected "," after "${type}"`);
      index += 1;
      readOptions(name, type, depth);
      return;
    }
    // number, date, time, spellout... with an optional style up to the closing brace.
    if (text[index] === ',') {
      index += 1;
      let nested = 0;
      while (index < text.length && (text[index] !== '}' || nested > 0)) {
        if (text[index] === '{') nested += 1;
        if (text[index] === '}') nested -= 1;
        index += 1;
      }
    }
    skipSpace();
    if (text[index] !== '}') fail(`Missing "}" after the "${name}" argument`);
    index += 1;
  };

  const readOptions = (name: string, type: string, depth: number) => {
    const isPlural = type !== 'select';
    const categories: string[] = [];
    const seen = new Set<string>();
    let hasOther = false;
    skipSpace();
    if (isPlural && text.startsWith('offset:', index)) {
      index += 7;
      skipSpace();
      if (!/\d/.test(text[index] ?? '')) fail('Expected a number after "offset:"');
      while (/\d/.test(text[index] ?? '')) index += 1;
    }
    for (;;) {
      skipSpace();
      if (text[index] === '}') {
        index += 1;
        break;
      }
      if (index >= text.length) fail(`Missing "}" at the end of the ${type}`);
      let selector: string;
      if (isPlural && text[index] === '=') {
        index += 1;
        const start = index;
        while (/[\d.]/.test(text[index] ?? '')) index += 1;
        if (index === start) fail('Expected a number after "="');
        selector = `=${text.slice(start, index)}`;
      } else {
        selector = readName(`a ${type} selector`);
        if (isPlural && !(PLURAL_KEYWORDS as readonly string[]).includes(selector)) {
          fail(`"${selector}" is not a plural category (zero, one, two, few, many, other)`);
        }
      }
      if (seen.has(selector)) fail(`"${selector}" appears twice in "${name}"`);
      seen.add(selector);
      if (selector === 'other') hasOther = true;
      if (isPlural && !selector.startsWith('=')) categories.push(selector);
      readSubMessage(depth, isPlural);
    }
    if (seen.size === 0) fail(`"${name}" has no options`);
    if (isPlural) {
      result.plurals.push({
        name,
        type: type === 'selectordinal' ? 'ordinal' : 'cardinal',
        categories,
        hasOther,
      });
    } else if (!hasOther) {
      fail(`The select "${name}" has no "other" option`);
    }
  };

  try {
    readMessage(0, false);
  } catch (error) {
    if (!(error instanceof IcuError)) throw error;
    result.error = error.message;
  }
  return result;
}
