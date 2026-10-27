// The placeholders of one message text, in a form that compares across languages: argument
// positions and their types for printf, names for ICU, i18next and i18n-js.
import type { MessageSyntax, MessageText } from '../model.js';
import { parseIcu } from '../messages/icu.js';
import { i18nextPlaceholders, i18nJsPlaceholders } from '../messages/interpolation.js';
import { ARG_TOKEN, kindOfSpecifierText, parsePrintf } from '../messages/printf.js';

export interface Slot {
  /** Argument position (printf) or name. */
  id: string;
  /** printf argument type (`object`, `int64`...); empty for named placeholders. */
  kind: string;
  /** As written in the text. */
  raw: string;
}

export interface Signature {
  slots: Map<string, Slot>;
  /** printf: `%` sequences that are not format specifiers. */
  invalid: string[];
}

/** For a String Catalog substitution variant, the substitution it belongs to. */
const substitutionOf = (path: string): string | undefined =>
  /^substitutions\.([^.]+)\./.exec(path)?.[1];

function printfSignature(text: MessageText): Signature {
  let value = text.text;
  const sub = substitutionOf(text.path);
  const resolved = sub ? text.substitutions?.[sub] : undefined;
  if (resolved) {
    const position = resolved.argNum > 0 ? `${resolved.argNum}$` : '';
    value = value.replace(ARG_TOKEN, `%${position}${resolved.specifier}`);
  }
  const parsed = parsePrintf(value);
  const slots = new Map<string, Slot>();
  for (const specifier of parsed.specifiers) {
    const id = String(specifier.position);
    if (!slots.has(id)) slots.set(id, { id, kind: specifier.kind, raw: specifier.raw });
  }
  for (const reference of parsed.references) {
    const target = text.substitutions?.[reference.name];
    const position = target && target.argNum > 0 ? target.argNum : reference.position;
    const kind = (target && kindOfSpecifierText(target.specifier)) ?? 'object';
    const id = String(position);
    if (!slots.has(id)) slots.set(id, { id, kind, raw: reference.raw });
  }
  return { slots, invalid: parsed.invalid };
}

function namedSignature(names: string[], raw: (name: string) => string): Signature {
  const slots = new Map<string, Slot>();
  for (const name of names)
    if (!slots.has(name)) slots.set(name, { id: name, kind: '', raw: raw(name) });
  return { slots, invalid: [] };
}

export function signature(
  text: MessageText,
  syntax: MessageSyntax,
  apostropheQuoting = true,
): Signature {
  switch (syntax) {
    case 'printf':
      return printfSignature(text);
    case 'icu': {
      const names = parseIcu(text.text, { apostropheQuoting }).arguments.map(
        (argument) => argument.name,
      );
      return namedSignature(names, (name) => `{${name}}`);
    }
    case 'i18next':
      return namedSignature(i18nextPlaceholders(text.text), (name) => `{{${name}}}`);
    case 'i18n-js':
      return namedSignature(i18nJsPlaceholders(text.text), (name) => `%{${name}}`);
  }
}

/** Human-readable name of a printf kind, for messages. */
export const KIND_NAMES: Record<string, string> = {
  object: 'an object',
  int8: 'an 8-bit integer',
  int16: 'a 16-bit integer',
  int32: 'a 32-bit integer',
  int64: 'a 64-bit integer',
  double: 'a floating-point number',
  'long double': 'a long double',
  char: 'a character',
  cstring: 'a C string',
  pointer: 'a pointer',
};
