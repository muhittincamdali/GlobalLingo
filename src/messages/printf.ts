// Format specifiers in Apple strings: `%@`, `%d`, `%lld`, `%.2f`, `%1$@`, and the `%#@name@`
// references of plural rules (stringsdict variables and String Catalog substitutions).
// https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Strings/Articles/formatSpecifiers.html

export interface FormatSpecifier {
  /** 1-based argument position. */
  position: number;
  /** What the argument must be: `object`, `int32`, `int64`, `double`, `char`, `cstring`... */
  kind: string;
  /** As written, e.g. `%2$lld`. */
  raw: string;
}

export interface PrintfParse {
  specifiers: FormatSpecifier[];
  /** Names of `%#@name@` references, with the position they take. */
  references: { name: string; position: number; raw: string }[];
  /** Specifiers that are not valid format specifiers, e.g. a lone `%` before a letter. */
  invalid: string[];
}

// %[position$][flags][width][.precision][length]conversion; '*' width/precision take an argument.
// The space flag is left out on purpose: "50 % de remise" is a percent sign in French typography,
// not `% d`. A width cannot start with 0 (that is the flag): with `\d+` there, a long run of zeros
// could be split between flags and width in every possible way before the match fails.
const SPECIFIER =
  /%(?:(?<refPosition>\d+)\$)?#@(?<reference>[^@\s]+)@|%(?:(?<position>\d+)\$)?[-+#0]*(?<width>\*|[1-9]\d*)?(?:\.(?<precision>\*|\d+))?(?<length>hh|h|ll|l|q|L|z|t|j)?(?<conversion>[@dDiuUxXoOfFeEgGaAcCsSp%])|%(?<other>\S)?/g;

const INT_CONVERSIONS = new Set(['d', 'D', 'i', 'u', 'U', 'x', 'X', 'o', 'O']);
const FLOAT_CONVERSIONS = new Set(['f', 'F', 'e', 'E', 'g', 'G', 'a', 'A']);

/** The argument kind a conversion and length modifier read; 64-bit Apple platforms throughout. */
export function specifierKind(length: string, conversion: string): string {
  if (conversion === '@') return 'object';
  if (INT_CONVERSIONS.has(conversion)) {
    // %D, %U and %O are 64-bit (long) on Apple platforms, like %ld.
    if (conversion === 'D' || conversion === 'U' || conversion === 'O') return 'int64';
    if (length === 'hh') return 'int8';
    if (length === 'h') return 'int16';
    if (length === '') return 'int32';
    return 'int64';
  }
  if (FLOAT_CONVERSIONS.has(conversion)) return length === 'L' ? 'long double' : 'double';
  if (conversion === 'c' || conversion === 'C') return 'char';
  if (conversion === 's' || conversion === 'S') return 'cstring';
  return 'pointer';
}

/** The kind a String Catalog substitution's `formatSpecifier` (e.g. `lld`, `@`) stands for. */
export function kindOfSpecifierText(specifier: string): string | undefined {
  const match = /^(hh|h|ll|l|q|L|z|t|j)?([@dDiuUxXoOfFeEgGaAcCsSp])$/.exec(specifier);
  return match ? specifierKind(match[1] ?? '', match[2] as string) : undefined;
}

export function parsePrintf(text: string): PrintfParse {
  const specifiers: FormatSpecifier[] = [];
  const references: PrintfParse['references'] = [];
  const invalid: string[] = [];
  let next = 1;
  for (const match of text.matchAll(SPECIFIER)) {
    const raw = match[0];
    const groups = match.groups ?? {};
    if (groups.reference !== undefined) {
      // References come first: `%#@name@` would otherwise read as `%#@` with the # flag.
      const explicit = groups.refPosition ? Number(groups.refPosition) : undefined;
      const position = explicit ?? next;
      if (explicit === undefined) next += 1;
      references.push({ name: groups.reference, position, raw });
    } else if (groups.conversion !== undefined) {
      if (groups.conversion === '%') continue;
      const explicit = groups.position ? Number(groups.position) : undefined;
      if (groups.width === '*') next += 1;
      if (groups.precision === '*') next += 1;
      const position = explicit ?? next;
      if (explicit === undefined) next += 1;
      specifiers.push({
        position,
        kind: specifierKind(groups.length ?? '', groups.conversion),
        raw,
      });
    } else if (groups.other !== undefined && /[A-Za-z]/.test(groups.other)) {
      // `%` before a letter that is no conversion, such as `%k`: printf prints garbage or crashes.
      invalid.push(raw);
    }
  }
  return { specifiers, references, invalid };
}

/** `%arg` in a String Catalog substitution variant stands for the substituted argument. */
export const ARG_TOKEN = /%arg\b/g;
