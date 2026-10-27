// Turns a recorded terminal session (commands plus the ANSI-coloured output they printed) into an
// animated SVG: the command is typed, then the output appears line by line and stays. No external
// fonts, scripts or images, so GitHub renders it inside <img>, and it respects reduced motion.

import { stripVTControlCharacters } from 'node:util';

type AnsiColor = 'blue' | 'cyan' | 'yellow' | 'magenta' | 'green' | 'red';

export interface Span {
  text: string;
  bold: boolean;
  dim: boolean;
  color: AnsiColor | null;
}

const COLORS: Record<number, AnsiColor> = {
  31: 'red',
  32: 'green',
  33: 'yellow',
  34: 'blue',
  35: 'magenta',
  36: 'cyan',
};

/** Splits one line at its SGR escape codes; other escape sequences are dropped. */
export function parseAnsi(line: string): Span[] {
  const spans: Span[] = [];
  let state: Omit<Span, 'text'> = { bold: false, dim: false, color: null };
  // biome-ignore lint/suspicious/noControlCharactersInRegex: SGR codes start with ESC.
  const pattern = /\u001b\[([\d;]*)m/g;
  let last = 0;
  for (let match = pattern.exec(line); match; match = pattern.exec(line)) {
    if (match.index > last) spans.push({ text: line.slice(last, match.index), ...state });
    for (const code of (match[1] || '0').split(';').map(Number)) {
      if (code === 0) state = { bold: false, dim: false, color: null };
      else if (code === 1) state = { ...state, bold: true };
      else if (code === 2) state = { ...state, dim: true };
      else if (code === 22) state = { ...state, bold: false, dim: false };
      else if (code === 39) state = { ...state, color: null };
      else if (COLORS[code]) state = { ...state, color: COLORS[code] };
    }
    last = pattern.lastIndex;
  }
  if (last < line.length) spans.push({ text: line.slice(last), ...state });
  return spans;
}

interface Theme {
  page: string;
  window: string;
  border: string;
  bar: string;
  dots: [string, string, string];
  title: string;
  text: string;
  dim: string;
  bold: string;
  prompt: string;
  colors: Record<AnsiColor, string>;
}

// Blues from the repository kit palette (brand/assets/palette.json); the labels in the table
// carry the meaning, so every status colour is a shade of blue.
export const THEMES: Record<'light' | 'dark', Theme> = {
  light: {
    page: '#FFFFFF',
    window: '#F5F9FF',
    border: '#D0E2F7',
    bar: '#EAF4FF',
    dots: ['#0071E3', '#5AC8FA', '#D0E2F7'],
    title: '#5A6B80',
    text: '#0B1F33',
    dim: '#5A6B80',
    bold: '#00285C',
    prompt: '#0071E3',
    colors: {
      blue: '#0058D4',
      cyan: '#0071E3',
      yellow: '#0058D4',
      magenta: '#003A85',
      green: '#0071E3',
      red: '#00285C',
    },
  },
  dark: {
    page: '#0D1117',
    window: '#04111F',
    border: '#1C3557',
    bar: '#0B1626',
    dots: ['#0A84FF', '#64D2FF', '#1C3557'],
    title: '#8FA3BC',
    text: '#D0E2F7',
    dim: '#8FA3BC',
    bold: '#FFFFFF',
    prompt: '#0A84FF',
    colors: {
      blue: '#4DA3FF',
      cyan: '#64D2FF',
      yellow: '#8CC4FF',
      magenta: '#64D2FF',
      green: '#5AC8FA',
      red: '#FFFFFF',
    },
  },
};

export interface Session {
  /** Shown in the title bar. */
  title: string;
  /** A comment line printed before the command, e.g. where the data comes from. */
  comment?: string;
  command: string;
  /** What the command printed, ANSI codes included. */
  output: string;
}

const FONT_SIZE = 13;
const LINE_HEIGHT = 19;
const CHAR_WIDTH = 7.83; // 0.6 em: the advance of common monospace fonts at 13 px
const PADDING = 20;
const BAR_HEIGHT = 34;
const TYPE_SECONDS = 0.045;
const LINE_SECONDS = 0.035;

const escapeXml = (text: string) =>
  text.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

function spanStyle(span: Span, theme: Theme): string {
  const fill = span.color
    ? theme.colors[span.color]
    : span.bold
      ? theme.bold
      : span.dim
        ? theme.dim
        : theme.text;
  const weight = span.bold ? ' font-weight="700"' : '';
  return `fill="${fill}"${weight}`;
}

const delay = (seconds: number) => `animation-delay:${seconds.toFixed(2)}s`;

/** The whole session as one SVG document in the given theme. */
export function terminalSvg(session: Session, themeName: 'light' | 'dark'): string {
  const theme = THEMES[themeName];
  const output = session.output.replace(/\n+$/, '').split('\n');
  const prompt = '$ ';
  const columns = Math.max(
    ...output.map((line) => stripVTControlCharacters(line).length),
    prompt.length + session.command.length,
    session.comment?.length ?? 0,
  );
  const rows = (session.comment ? 1 : 0) + 1 + output.length + 1;
  const width = Math.ceil(PADDING * 2 + columns * CHAR_WIDTH);
  const height = BAR_HEIGHT + PADDING * 2 + rows * LINE_HEIGHT;
  const x = PADDING;
  let y = BAR_HEIGHT + PADDING + FONT_SIZE;
  const lines: string[] = [];

  if (session.comment) {
    lines.push(`<text x="${x}" y="${y}" fill="${theme.dim}">${escapeXml(session.comment)}</text>`);
    y += LINE_HEIGHT;
  }
  const typed = [...session.command]
    .map(
      (char, index) =>
        `<tspan class="t" style="${delay(0.4 + index * TYPE_SECONDS)}">${escapeXml(char)}</tspan>`,
    )
    .join('');
  lines.push(
    `<text x="${x}" y="${y}"><tspan fill="${theme.prompt}" font-weight="700">${prompt}</tspan><tspan fill="${theme.text}">${typed}</tspan></text>`,
  );
  y += LINE_HEIGHT;
  const start = 0.4 + session.command.length * TYPE_SECONDS + 0.5;
  output.forEach((line, index) => {
    const spans = parseAnsi(line)
      .map((span) => `<tspan ${spanStyle(span, theme)}>${escapeXml(span.text)}</tspan>`)
      .join('');
    lines.push(
      `<text class="t" x="${x}" y="${y}" style="${delay(start + index * LINE_SECONDS)}">${spans}</text>`,
    );
    y += LINE_HEIGHT;
  });
  const end = start + output.length * LINE_SECONDS + 0.2;
  lines.push(
    `<text class="t" x="${x}" y="${y}" style="${delay(end)}"><tspan fill="${theme.prompt}" font-weight="700">${prompt}</tspan></text>`,
    `<rect class="caret" x="${x + prompt.length * CHAR_WIDTH}" y="${y - FONT_SIZE + 1}" width="${CHAR_WIDTH.toFixed(2)}" height="${FONT_SIZE + 3}" fill="${theme.prompt}" style="${delay(end)}"/>`,
  );

  const [first, second, third] = theme.dots;
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}" role="img" aria-label="${escapeXml(`${session.command}: terminal output`)}">
<title>${escapeXml(session.title)}</title>
<style>
text{font-family:ui-monospace,SFMono-Regular,Menlo,Consolas,"Liberation Mono",monospace;font-size:${FONT_SIZE}px;white-space:pre}
.t{opacity:0;animation:show 0.01s linear forwards}
.caret{opacity:0;animation:blink 1.1s step-end infinite}
@keyframes show{to{opacity:1}}
@keyframes blink{0%,100%{opacity:1}50%{opacity:0}}
@media (prefers-reduced-motion:reduce){.t{animation:none;opacity:1}.caret{animation:none;opacity:1}}
</style>
<rect width="${width}" height="${height}" fill="${theme.page}"/>
<rect x="0.5" y="0.5" width="${width - 1}" height="${height - 1}" rx="10" fill="${theme.window}" stroke="${theme.border}"/>
<path d="M0.5 ${BAR_HEIGHT}V10.5a10 10 0 0 1 10-10h${width - 21}a10 10 0 0 1 10 10V${BAR_HEIGHT}z" fill="${theme.bar}"/>
<line x1="0.5" y1="${BAR_HEIGHT}" x2="${width - 0.5}" y2="${BAR_HEIGHT}" stroke="${theme.border}"/>
<circle cx="20" cy="17" r="6" fill="${first}"/><circle cx="40" cy="17" r="6" fill="${second}"/><circle cx="60" cy="17" r="6" fill="${third}"/>
<text x="${width / 2}" y="22" text-anchor="middle" fill="${theme.title}" style="font-size:12px">${escapeXml(session.title)}</text>
${lines.join('\n')}
</svg>
`;
}
