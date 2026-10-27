import { describe, expect, it } from 'vitest';
import { decode, isBinaryPlist } from '../../src/parse/decode.ts';
import {
  JsonSyntaxError,
  MAX_JSON_DEPTH,
  member,
  parseJson,
  uniqueMembers,
} from '../../src/parse/json.ts';
import { dictValue, MAX_PLIST_DEPTH, PlistSyntaxError, parsePlist } from '../../src/parse/plist.ts';
import { StringsSyntaxError, parseStrings } from '../../src/parse/strings.ts';

describe('parseJson', () => {
  it('keeps the line of every key and the value JSON.parse would keep', () => {
    const text = '{\n  "a": 1,\n  "b": {\n    "c": "x"\n  }\n}';
    const { root } = parseJson(text);
    expect(root.type).toBe('object');
    if (root.type !== 'object') return;
    expect(root.members.map((item) => [item.key, item.line])).toEqual([
      ['a', 2],
      ['b', 3],
    ]);
    const b = member(root, 'b')?.value;
    expect(b?.type === 'object' && member(b, 'c')?.line).toBe(4);
  });

  it('reports a key that appears twice in one object, and keeps the last value', () => {
    const { root, duplicates } = parseJson(
      '{\n "k": "first",\n "o": {"x": 1, "x": 2},\n "k": "second"\n}',
    );
    expect(duplicates).toEqual([
      { path: ['o'], key: 'x', line: 3, firstLine: 3 },
      { path: [], key: 'k', line: 4, firstLine: 2 },
    ]);
    if (root.type !== 'object') throw new Error('object expected');
    expect(member(root, 'k')?.value).toMatchObject({ value: 'second' });
    expect(uniqueMembers(root).map((item) => item.key)).toEqual(['k', 'o']);
    expect(JSON.parse('{"k": "first", "k": "second"}').k).toBe('second');
  });

  it('reads escapes, a byte order mark and numbers like JSON.parse', () => {
    const text = '﻿{"s": "a\\"b\\\\c\\u00e7\\n", "n": -1.5e3, "t": true, "z": null, "l": []}';
    const { root } = parseJson(text);
    if (root.type !== 'object') throw new Error('object expected');
    expect(member(root, 's')?.value).toMatchObject({ value: 'a"b\\cç\n' });
    expect(member(root, 'n')?.value).toMatchObject({ value: -1500 });
    expect(member(root, 't')?.value).toMatchObject({ value: true });
    expect(member(root, 'z')?.value).toMatchObject({ value: null });
  });

  it.each([
    ['{"a": }', 1],
    ['{"a": "x",\n}', 2],
    ['{"a": "x"} extra', 1],
    ['{"a": "line\nbreak"}', 1],
    ['{"a": "\\q"}', 1],
    ['{"a": "open', 1],
    ['', 1],
    ["{'a': 1}", 1],
  ])('rejects %j with the line of the problem', (text, line) => {
    expect(() => parseJson(text)).toThrow(JsonSyntaxError);
    try {
      parseJson(text);
    } catch (error) {
      expect((error as JsonSyntaxError).line).toBe(line);
    }
  });

  it('stops at the nesting limit instead of exhausting the stack', () => {
    const deep = `${'['.repeat(MAX_JSON_DEPTH + 2)}${']'.repeat(MAX_JSON_DEPTH + 2)}`;
    expect(() => parseJson(deep)).toThrow(/Nested deeper than/);
    const veryDeep = `${'{"a":'.repeat(100_000)}1${'}'.repeat(100_000)}`;
    expect(() => parseJson(veryDeep)).toThrow(/Nested deeper than/);
    const ok = `${'['.repeat(MAX_JSON_DEPTH)}${']'.repeat(MAX_JSON_DEPTH)}`;
    expect(() => parseJson(ok)).not.toThrow();
  });
});

describe('parseStrings', () => {
  it('reads quoted and unquoted pairs, comments, escapes and line numbers', () => {
    const text = [
      '/* Title of the main screen */',
      '"title" = "Welcome";',
      '// a comment with "quotes" = "inside";',
      'unquoted_key = unquoted.value;',
      '"escapes" = "Tab\\there \\"quoted\\" \\U00E7 \\\\ \\n";',
      '"multi" =',
      '  "line";',
      '"same";',
    ].join('\n');
    expect(parseStrings(text).pairs).toEqual([
      { key: 'title', value: 'Welcome', line: 2 },
      { key: 'unquoted_key', value: 'unquoted.value', line: 4 },
      { key: 'escapes', value: 'Tab\there "quoted" ç \\ \n', line: 5 },
      { key: 'multi', value: 'line', line: 6 },
      { key: 'same', value: 'same', line: 8 },
    ]);
  });

  it.each([
    ['"a" = "b"', 1, /Expected ";"/],
    ['"a" = "b";\n"c" = ;', 2, /Expected a value/],
    ['"a" = "unterminated;', 1, /Unterminated string/],
    ['/* open comment\n"a" = "b";', 1, /Unterminated comment/],
    ['= "b";', 1, /Expected a key/],
  ])('rejects %j', (text, line, message) => {
    expect(() => parseStrings(text)).toThrow(message);
    try {
      parseStrings(text);
    } catch (error) {
      expect(error).toBeInstanceOf(StringsSyntaxError);
      expect((error as StringsSyntaxError).line).toBe(line);
    }
  });
});

describe('decode', () => {
  const utf16le = (text: string, bom: boolean) => {
    const bytes = Buffer.from(text, 'utf16le');
    return new Uint8Array(bom ? Buffer.concat([Buffer.from([0xff, 0xfe]), bytes]) : bytes);
  };

  it('reads UTF-16 with and without a byte order mark, and UTF-8', () => {
    expect(decode(utf16le('"a" = "ğ";', true))).toEqual({
      text: '"a" = "ğ";',
      encoding: 'utf-16le',
    });
    expect(decode(utf16le('"a" = "b";', false))).toEqual({
      text: '"a" = "b";',
      encoding: 'utf-16le',
    });
    const be = Buffer.from(utf16le('"x"', false)).swap16();
    expect(decode(new Uint8Array(Buffer.concat([Buffer.from([0xfe, 0xff]), be])))).toEqual({
      text: '"x"',
      encoding: 'utf-16be',
    });
    expect(decode(new Uint8Array(Buffer.from('﻿"İ"', 'utf8')))).toEqual({
      text: '"İ"',
      encoding: 'utf-8',
    });
  });

  it('recognises a binary property list', () => {
    expect(isBinaryPlist(new Uint8Array(Buffer.from('bplist00\u0000\u0001')))).toBe(true);
    expect(isBinaryPlist(new Uint8Array(Buffer.from('<?xml version="1.0"?>')))).toBe(false);
  });
});

describe('parsePlist', () => {
  const plist = (body: string) =>
    `<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n<plist version="1.0">\n${body}\n</plist>\n`;

  it('reads dictionaries, arrays and scalars with key lines, entities and CDATA', () => {
    const { root, duplicates } = parsePlist(
      plist(
        '<dict>\n<key>a &amp; b</key>\n<string>x &lt; y &#x131; &#304;</string>\n<key>n</key><integer>3</integer>\n<key>list</key><array><true/><string/><string><![CDATA[<raw>]]></string></array>\n<!-- comment --><key>e</key><dict/>\n</dict>',
      ),
    );
    expect(duplicates).toEqual([]);
    if (root.type !== 'dict') throw new Error('dict expected');
    expect(root.entries.map((entry) => [entry.key, entry.line])).toEqual([
      ['a & b', 5],
      ['n', 7],
      ['list', 8],
      ['e', 9],
    ]);
    expect(dictValue(root, 'a & b')).toMatchObject({ type: 'string', value: 'x < y ı İ' });
    const list = dictValue(root, 'list');
    expect(
      list?.type === 'array' &&
        list.items.map((item) => (item.type === 'array' || item.type === 'dict' ? item.type : item.value)),
    ).toEqual(['true', '', '<raw>']);
  });

  it('records duplicate keys and keeps the last value', () => {
    const { root, duplicates } = parsePlist(
      plist('<dict>\n<key>k</key><string>1</string>\n<key>k</key><string>2</string>\n</dict>'),
    );
    expect(duplicates).toEqual([{ key: 'k', line: 6, firstLine: 5 }]);
    expect(root.type === 'dict' && dictValue(root, 'k')).toMatchObject({ value: '2' });
  });

  it.each([
    ['<dict><key>a</key></dict>', /Missing a value/],
    ['<dict><string>x</string></dict>', /Expected <key>/],
    ['<dict><key>a</key><string>x</dict>', /Missing <\/string>/],
    ['<dict><key>a</key><string>&bogus;</string></dict>', /Unknown entity/],
    ['<dict><key>a</key><string>&#x110000;</string></dict>', /Invalid character reference/],
    ['<dict><key>a</key><unknown/></dict>', /Unexpected <unknown>/],
    ['', /no property list value/],
  ])('rejects %j', (body, message) => {
    expect(() => parsePlist(plist(body))).toThrow(message);
    expect(() => parsePlist(plist(body))).toThrow(PlistSyntaxError);
  });

  it('stops at the nesting limit', () => {
    const deep = `${'<array>'.repeat(MAX_PLIST_DEPTH + 2)}${'</array>'.repeat(MAX_PLIST_DEPTH + 2)}`;
    expect(() => parsePlist(plist(deep))).toThrow(/Nested deeper than/);
  });
});
