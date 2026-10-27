// What GlobalLingo must find in each fixture (fixtures/README.md says why each mistake is there),
// and the terminal report it prints, recorded in test/__snapshots__/fixtures/*.out. Change the lists
// deliberately, never to make a run pass.
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';
import { render } from '../../src/report/index.ts';
import { scan } from '../../src/scan.ts';

const FIXTURES = fileURLToPath(new URL('../../fixtures/', import.meta.url));

const EXPECTED: Record<string, string[]> = {
  'swiftui-catalog': [
    'KEY001 Sources/Shelf/Messages.swift:10 sync.retry',
    'TRI001 Sources/Shelf/Messages.swift:15',
    'PLU001 Sources/Shelf/Resources/Localizable.xcstrings:42 %lld books on %@ fr',
    'FMT001 Sources/Shelf/Resources/Localizable.xcstrings:45 %lld books on %@ fr',
    'FMT001 Sources/Shelf/Resources/Localizable.xcstrings:45 %lld books on %@ fr',
    'PLU001 Sources/Shelf/Resources/Localizable.xcstrings:50 %lld books on %@ pl',
    'MIS001 Sources/Shelf/Resources/Localizable.xcstrings:114 Delete all pl',
    'MIS003 Sources/Shelf/Resources/Localizable.xcstrings:122 Delete all fr',
    'STA001 Sources/Shelf/Resources/Localizable.xcstrings:136 Old banner',
    'MIS001 Sources/Shelf/Resources/Localizable.xcstrings:213 Shelf tr',
    'MIS002 Sources/Shelf/Resources/Localizable.xcstrings:243 sync.failed pl',
    'KEY002 Sources/Shelf/ShelfView.swift:21 Pull to refresh',
    'TRI003 Sources/Shelf/ShelfView.swift:29',
  ],
  'uikit-strings': [
    'DUP001 Inbox/de.lproj/Localizable.strings:7 archive.confirm.message',
    'HCS001 Inbox/InboxViewController.swift:17',
    'KEY001 Inbox/InboxViewController.swift:37 archive.confirm.ok',
    'PLU001 Inbox/ru.lproj/Localizable.stringsdict:9 inbox.count ru',
    'MIS001 Inbox/tr.lproj/Localizable.strings:0 archive.confirm.message tr',
    'STA002 Inbox/tr.lproj/Localizable.strings:7 inbox.legacy tr',
    'FMT001 Inbox/tr.lproj/Localizable.stringsdict:17 inbox.count tr',
  ],
  'flutter-arb': [
    'FMT001 lib/l10n/app_de.arb:4 booksOnShelf de',
    'FMT002 lib/l10n/app_de.arb:4 booksOnShelf de',
    'KEY003 lib/l10n/app_en.arb:28 syncFailed',
    'PLU001 lib/l10n/app_pl.arb:4 booksOnShelf pl',
    'MIS004 lib/l10n/app_pl.arb:6 deleteAll pl',
    'MIS001 lib/l10n/app_tr.arb:0 syncFailed tr',
    'HCS001 lib/main.dart:16',
    'TRI003 lib/main.dart:49',
    'HCS001 lib/main.dart:51',
  ],
  'expo-i18next': [
    'TRI003 App.tsx:13',
    'TRI001 App.tsx:17',
    'HCS001 App.tsx:18',
    'KEY001 App.tsx:20 checkout.terms',
    'MIS001 src/locales/de.json:0 checkout.total de',
    'FMT001 src/locales/de.json:2 greeting de',
    'FMT002 src/locales/de.json:2 greeting de',
    'DUP001 src/locales/de.json:13 checkout',
    'KEY003 src/locales/en.json:5 cart.empty',
    'PLU001 src/locales/pl.json:6 cart.items pl',
    'MIS001 src/locales/tr.json:0 checkout.button tr',
    'MIS002 src/locales/tr.json:5 cart.empty tr',
    'STA002 src/locales/tr.json:13 legacy.banner tr',
  ],
};

describe.each(Object.keys(EXPECTED))('fixture %s', (name) => {
  it('has exactly the expected findings', async () => {
    const report = await scan(`${FIXTURES}${name}`);
    const found = report.findings.map(
      (finding) =>
        `${finding.rule} ${finding.file}:${finding.line}${finding.key ? ` ${finding.key}` : ''}${finding.locale ? ` ${finding.locale}` : ''}`,
    );
    expect(found).toEqual(EXPECTED[name]);
    expect(report.notes).toEqual([]);
  });

  it('prints the recorded terminal report', async () => {
    const report = await scan(`${FIXTURES}${name}`);
    report.path = `fixtures/${name}`;
    await expect(render(report, 'tty', { color: false, width: 100 })).toMatchFileSnapshot(
      `../__snapshots__/fixtures/${name}.out`,
    );
  });
});
