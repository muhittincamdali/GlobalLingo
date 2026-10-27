// Turns the bytes of a localization file into text. Xcode writes .strings files as UTF-16 (with a
// byte order mark) or UTF-8; everything else GlobalLingo reads is UTF-8.

export type Encoding = 'utf-8' | 'utf-16le' | 'utf-16be';

export interface Decoded {
  text: string;
  encoding: Encoding;
}

export function decode(bytes: Uint8Array): Decoded {
  if (bytes[0] === 0xff && bytes[1] === 0xfe) {
    return { text: new TextDecoder('utf-16le').decode(bytes.subarray(2)), encoding: 'utf-16le' };
  }
  if (bytes[0] === 0xfe && bytes[1] === 0xff) {
    return { text: new TextDecoder('utf-16be').decode(bytes.subarray(2)), encoding: 'utf-16be' };
  }
  // UTF-16 without a byte order mark: ASCII text then has a zero byte in every other position.
  if (bytes.length >= 4 && bytes.length % 2 === 0) {
    if (bytes[0] !== 0 && bytes[1] === 0 && bytes[2] !== 0 && bytes[3] === 0) {
      return { text: new TextDecoder('utf-16le').decode(bytes), encoding: 'utf-16le' };
    }
    if (bytes[0] === 0 && bytes[1] !== 0 && bytes[2] === 0 && bytes[3] !== 0) {
      return { text: new TextDecoder('utf-16be').decode(bytes), encoding: 'utf-16be' };
    }
  }
  const text = new TextDecoder('utf-8').decode(bytes);
  return { text: text.charCodeAt(0) === 0xfeff ? text.slice(1) : text, encoding: 'utf-8' };
}

/** A binary property list (`bplist00`), which only a build writes. */
export const isBinaryPlist = (bytes: Uint8Array): boolean =>
  bytes.length >= 8 && new TextDecoder('latin1').decode(bytes.subarray(0, 6)) === 'bplist';
