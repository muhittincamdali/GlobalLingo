// The globs of .globallingo.json (`**`, `*`, `?`), matched against paths from the project root
// and against keys. A glob is a list of tokens, and matching keeps the set of text positions the
// tokens so far can end at: no backtracking, whatever the glob. The set is a row of bits, 32
// positions to a word, so each token costs a pass over the words of the text, not its characters.

type GlobToken = { kind: 'char'; char: string } | { kind: 'one' | 'star' | 'any' | 'dirs' };

function tokenize(pattern: string): GlobToken[] {
  const text = pattern.replace(/^\.\//, '');
  const tokens: GlobToken[] = [];
  for (let i = 0; i < text.length; i += 1) {
    const char = text[i] as string;
    if (char === '*' && text[i + 1] === '*') {
      while (text[i + 1] === '*') i += 1;
      const dirs = text[i + 1] === '/';
      if (dirs) i += 1;
      // "**/**/" is "**/": repeated wildcards would only cost time.
      const previous = tokens[tokens.length - 1];
      if (!(previous && (previous.kind === 'dirs' || previous.kind === 'any'))) {
        tokens.push({ kind: dirs ? 'dirs' : 'any' });
      }
    } else if (char === '*') {
      if (tokens[tokens.length - 1]?.kind !== 'star') tokens.push({ kind: 'star' });
    } else if (char === '?') {
      tokens.push({ kind: 'one' });
    } else {
      tokens.push({ kind: 'char', char });
    }
  }
  return tokens;
}

/** Character bit sets kept per text, in words; past this, a set is made again when needed. */
const MAX_KEPT_WORDS = 1 << 18;

/**
 * One text and its bit sets. Bit j of a row means "the tokens so far match the first j
 * characters", for j from 0 to the length. Bit i of a mask describes character i.
 */
class Text {
  readonly text: string;
  readonly words: number;
  /** Characters 0 to length - 1. */
  readonly all: Uint32Array;
  readonly slash: Uint32Array;
  readonly notSlash: Uint32Array;
  /** Rows for the matching, used again for every glob. */
  readonly rows: [Uint32Array, Uint32Array, Uint32Array];
  private readonly chars = new Map<string, Uint32Array>();
  private keptWords = 0;

  constructor(text: string) {
    this.text = text;
    this.words = (text.length >>> 5) + 1;
    this.all = new Uint32Array(this.words);
    this.slash = new Uint32Array(this.words);
    this.notSlash = new Uint32Array(this.words);
    this.rows = [0, 1, 2].map(() => new Uint32Array(this.words)) as Text['rows'];
    for (let i = 0; i < text.length; i += 1) {
      const bit = 1 << (i & 31);
      const word = i >>> 5;
      this.all[word] = (this.all[word] as number) | bit;
      if (text[i] === '/') this.slash[word] = (this.slash[word] as number) | bit;
      else this.notSlash[word] = (this.notSlash[word] as number) | bit;
    }
  }

  /** The characters equal to `char`. */
  mask(char: string): Uint32Array {
    const kept = this.chars.get(char);
    if (kept) return kept;
    const mask = new Uint32Array(this.words);
    for (let i = this.text.indexOf(char); i !== -1; i = this.text.indexOf(char, i + 1)) {
      mask[i >>> 5] = (mask[i >>> 5] as number) | (1 << (i & 31));
    }
    if (this.keptWords + this.words <= MAX_KEPT_WORDS) {
      this.chars.set(char, mask);
      this.keptWords += this.words;
    }
    return mask;
  }
}

/** to[j] = from[j - 1] and mask[j - 1]: one character that the mask allows. */
function step(from: Uint32Array, mask: Uint32Array, to: Uint32Array): void {
  let carry = 0;
  for (let w = 0; w < from.length; w += 1) {
    const bits = (from[w] as number) & (mask[w] as number);
    to[w] = (bits << 1) | carry;
    carry = bits >>> 31;
  }
}

/**
 * to = from, plus every position reached from a bit of `from` over characters the mask allows:
 * `*` and `**`. A carry through a run of ones in the mask does this a word at a time, the
 * addition trick of bit-parallel string matching: ((from & mask) + mask) ^ mask, or from.
 */
function spread(from: Uint32Array, mask: Uint32Array, to: Uint32Array): void {
  let carry = 0;
  for (let w = 0; w < from.length; w += 1) {
    const allowed = mask[w] as number;
    const sum = (((from[w] as number) & allowed) >>> 0) + allowed + carry;
    to[w] = ((sum >>> 0) ^ allowed) | (from[w] as number);
    carry = sum > 0xffffffff ? 1 : 0;
  }
}

function isEmpty(row: Uint32Array): boolean {
  for (const word of row) if (word !== 0) return false;
  return true;
}

function matches(tokens: readonly GlobToken[], text: Text): boolean {
  let [row, next] = text.rows;
  const spare = text.rows[2];
  row.fill(0);
  row[0] = 1;
  for (const token of tokens) {
    switch (token.kind) {
      case 'char':
        step(row, text.mask(token.char), next);
        break;
      case 'one':
        step(row, text.notSlash, next);
        break;
      case 'star':
        spread(row, text.notSlash, next);
        break;
      case 'any':
        spread(row, text.all, next);
        break;
      case 'dirs':
        // Nothing, or anything that ends with a slash.
        spread(row, text.all, spare);
        step(spare, text.slash, next);
        for (let w = 0; w < next.length; w += 1) next[w] = (next[w] as number) | (row[w] as number);
        break;
    }
    [row, next] = [next, row];
    if (isEmpty(row)) return false;
  }
  const end = text.text.length;
  if ((row[end >>> 5] as number) & (1 << (end & 31))) return true;
  // A folder pattern also covers everything below it: the row says whether the pattern matches
  // the part of the path before each slash.
  return row.some((word, w) => (word & (text.slash[w] as number)) !== 0);
}

/** Turns globs (`**`, `*`, `?`) matched against paths from the project root into a test. */
export function globMatcher(patterns: readonly string[]): (path: string) => boolean {
  if (patterns.length === 0) return () => false;
  const compiled = [...new Set(patterns)].map(tokenize);
  return (path) => {
    const text = new Text(path);
    return compiled.some((tokens) => matches(tokens, text));
  };
}
