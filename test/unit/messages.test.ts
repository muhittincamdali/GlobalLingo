import { describe, expect, it } from 'vitest';
import { MAX_ICU_DEPTH, parseIcu } from '../../src/messages/icu.ts';
import {
  i18nextNesting,
  i18nextPlaceholders,
  i18nJsPlaceholders,
} from '../../src/messages/interpolation.ts';
import { kindOfSpecifierText, parsePrintf, specifierKind } from '../../src/messages/printf.ts';

describe('parsePrintf', () => {
  const kinds = (text: string) =>
    parsePrintf(text).specifiers.map((item) => [item.position, item.kind, item.raw]);

  it('reads zero flags before a width, with or without a position', () => {
    expect(
      parsePrintf('%05d %-05d %00d %010.2f %1$05lld %0%').specifiers.map((item) => item.raw),
    ).toEqual(['%05d', '%-05d', '%00d', '%010.2f', '%1$05lld']);
    expect(parsePrintf('%0000x %1$00').invalid).toEqual([]);
  });

  it('numbers specifiers in order and honours explicit positions', () => {
    expect(kinds('%@ has %lld files')).toEqual([
      [1, 'object', '%@'],
      [2, 'int64', '%lld'],
    ]);
    expect(kinds('%2$lld files from %1$@')).toEqual([
      [2, 'int64', '%2$lld'],
      [1, 'object', '%1$@'],
    ]);
  });

  it('gives each length modifier its argument size on 64-bit Apple platforms', () => {
    expect(
      ['%d', '%i', '%u', '%x', '%hhd', '%hd', '%ld', '%lld', '%qd', '%zd', '%D', '%U'].map(
        (raw) => kinds(raw)[0]?.[1],
      ),
    ).toEqual([
      'int32',
      'int32',
      'int32',
      'int32',
      'int8',
      'int16',
      'int64',
      'int64',
      'int64',
      'int64',
      'int64',
      'int64',
    ]);
    expect(kinds('%.2f %e %Lf %c %s %p')).toEqual([
      [1, 'double', '%.2f'],
      [2, 'double', '%e'],
      [3, 'long double', '%Lf'],
      [4, 'char', '%c'],
      [5, 'cstring', '%s'],
      [6, 'pointer', '%p'],
    ]);
  });

  it('counts an asterisk width or precision as an argument', () => {
    expect(kinds('%*d and %.*f then %@')).toEqual([
      [2, 'int32', '%*d'],
      [4, 'double', '%.*f'],
      [5, 'object', '%@'],
    ]);
  });

  it('reads %#@name@ references of plural rules before the # flag', () => {
    expect(parsePrintf('%#@photos@ in %2$@')).toEqual({
      specifiers: [{ position: 2, kind: 'object', raw: '%2$@' }],
      references: [{ name: 'photos', position: 1, raw: '%#@photos@' }],
      invalid: [],
    });
    expect(parsePrintf('%1$#@files@').references).toEqual([
      { name: 'files', position: 1, raw: '%1$#@files@' },
    ]);
  });

  it('skips %% and a French percent sign with a space, and flags % before a letter', () => {
    expect(parsePrintf('100%% sure, 50 % de remise, 20 %').specifiers).toEqual([]);
    expect(parsePrintf('100%% sure, 50 % de remise').invalid).toEqual([]);
    expect(parsePrintf('Save 20%now').invalid).toEqual(['%n']);
    expect(parsePrintf('ratio %k').invalid).toEqual(['%k']);
  });

  it('maps a String Catalog formatSpecifier to the same kinds', () => {
    expect(kindOfSpecifierText('lld')).toBe('int64');
    expect(kindOfSpecifierText('@')).toBe('object');
    expect(kindOfSpecifierText('d')).toBe(specifierKind('', 'd'));
    expect(kindOfSpecifierText('bogus')).toBeUndefined();
  });
});

describe('parseIcu', () => {
  const icu = (text: string, apostropheQuoting = true) => parseIcu(text, { apostropheQuoting });

  it('collects plain, typed, plural and select arguments', () => {
    const parsed = icu(
      'Hi {name}, {count, plural, =0{no files} one{# file} other{# files in {folder}}} on {day, date, short}. {gender, select, female{She} other{They}}',
    );
    expect(parsed.error).toBeUndefined();
    expect(parsed.arguments).toEqual([
      { name: 'name', type: 'plain' },
      { name: 'count', type: 'plural' },
      { name: 'folder', type: 'plain' },
      { name: 'day', type: 'date' },
      { name: 'gender', type: 'select' },
    ]);
    expect(parsed.plurals).toEqual([
      { name: 'count', type: 'cardinal', categories: ['one', 'other'], hasOther: true },
    ]);
  });

  it('reads selectordinal and offset', () => {
    const parsed = icu(
      '{n, selectordinal, one{#st} two{#nd} few{#rd} other{#th}} {g, plural, offset:1 =0{none} other{# more}}',
    );
    expect(parsed.plurals).toEqual([
      { name: 'n', type: 'ordinal', categories: ['one', 'two', 'few', 'other'], hasOther: true },
      { name: 'g', type: 'cardinal', categories: ['other'], hasOther: true },
    ]);
  });

  it('reports a plural without other through hasOther, not as a syntax error', () => {
    const parsed = icu('{count, plural, one{# file}}');
    expect(parsed.error).toBeUndefined();
    expect(parsed.plurals[0]?.hasOther).toBe(false);
  });

  it.each([
    ['Hello {name', /Missing "}"/],
    ['Hello name}', /Unmatched "}"/],
    ['{count, plural, singular{x} other{y}}', /"singular" is not a plural category/],
    ['{count, plural, one{x} one{y} other{z}}', /"one" appears twice/],
    ['{count, plural, one x}', /Expected "\{" after a selector/],
    ['{g, select, male{he}}', /no "other" option/],
    ['{count, plural,}', /has no options/],
    ['{}', /Expected an argument name/],
    ['{a b}', /Expected "," or "}"/],
  ])('reports the syntax error in %j', (text, message) => {
    expect(icu(text).error).toMatch(message);
  });

  it('treats apostrophes as quotes only when asked (FormatJS yes, Flutter without use-escaping no)', () => {
    expect(icu("It's '{literal}' {name}").arguments).toEqual([{ name: 'name', type: 'plain' }]);
    expect(icu("It's '{literal}' {name}", false).arguments).toEqual([
      { name: 'literal', type: 'plain' },
      { name: 'name', type: 'plain' },
    ]);
    expect(icu("Don''t {x}").arguments).toEqual([{ name: 'x', type: 'plain' }]);
  });

  it('stops at the nesting limit', () => {
    const deep = `${'{a, select, other{'.repeat(MAX_ICU_DEPTH + 2)}x${'}}'.repeat(MAX_ICU_DEPTH + 2)}`;
    expect(icu(deep).error).toMatch(/Nested deeper than/);
  });
});

describe('interpolation placeholders', () => {
  it('reads i18next placeholders with formats, unescaped values and nesting', () => {
    expect(
      i18nextPlaceholders('{{count}} items for {{ name }} on {{date, datetime}} {{- html}}'),
    ).toEqual(['count', 'name', 'date', 'html']);
    expect(i18nextPlaceholders('{{ -  name }} {{-x}} {{ - }} {{ -, f}} {{  }}')).toEqual([
      'name',
      'x',
      '-',
      '-',
    ]);
    expect(i18nextNesting('See $t(common.ok) and $t(help, { "x": 1 })')).toEqual([
      'common.ok',
      'help',
    ]);
  });

  it('reads i18n-js %{name} and {{name}} placeholders', () => {
    expect(i18nJsPlaceholders('Hello %{name}, you have {{count}} new messages')).toEqual([
      'name',
      'count',
    ]);
  });
});
