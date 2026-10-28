import { describe, expect, it } from 'vitest';
import { type CodeContext, checkSource, sourceLanguage } from '../../src/code/check-code.ts';
import { literalValue, parenPairs, stripComments } from '../../src/code/lexer.ts';

const context = (overrides: Partial<CodeContext> = {}): CodeContext => ({
  appleTables: new Map([
    ['Localizable', { keys: new Set(['settings.title', 'Hello', 'Delete']), stringCatalog: true }],
    ['Errors', { keys: new Set(['network']), stringCatalog: false }],
  ]),
  jsKeys: new Set(['home.title', 'items', 'common:ok', 'ok']),
  jsNamespaces: new Set(['common']),
  shipsTurkic: true,
  outputClasses: ['AppLocalizations'],
  ...overrides,
});

const found = (path: string, text: string, ctx = context()) =>
  checkSource({ path, text }, ctx).map(
    (draft) => `${draft.rule}:${draft.line} ${draft.key ?? draft.subject}`,
  );

describe('lexer', () => {
  it('blanks comments, keeps strings and line breaks', () => {
    const swift = 'let a = "// not a comment" // comment\n/* outer /* nested */ still */ let b = 1';
    const stripped = stripComments(swift, 'swift');
    expect(stripped).toContain('"// not a comment"');
    expect(stripped).not.toContain('comment\n');
    expect(stripped).not.toContain('nested');
    expect(stripped).toContain('let b = 1');
    expect(stripped.length).toBe(swift.length);
    expect(stripped.split('\n').length).toBe(2);
  });

  it('keeps JavaScript regular expressions and template literals intact', () => {
    const js = 'const r = /\\/\\/ not a comment/g; const t = `a // b`; // gone';
    const stripped = stripComments(js, 'js');
    expect(stripped).toContain('/\\/\\/ not a comment/g');
    expect(stripped).toContain('`a // b`');
    expect(stripped).not.toContain('gone');
  });

  it('finds the closing parenthesis outside strings', () => {
    const code = 'f(a, ")", g(b)) + 1';
    expect(parenPairs(code)(1)).toBe(14);
    expect(parenPairs(code)(11)).toBe(13);
    expect(parenPairs('f(never closed')(1)).toBe(-1);
  });

  it('decodes literals and refuses interpolated ones', () => {
    expect(literalValue('Say \\"hi\\"\\n\\u{1F600}', 'swift')).toBe('Say "hi"\n😀');
    expect(literalValue('Hello \\(name)', 'swift')).toBeUndefined();
    expect(literalValue('Hi $name', 'dart')).toBeUndefined();
    // biome-ignore lint/suspicious/noTemplateCurlyInString: the text of a template literal is the input.
    expect(literalValue('Hi ${a}', 'js')).toBeUndefined();
    expect(literalValue('Price \\$5', 'dart')).toBe('Price $5');
  });

  it('knows the languages it reads', () => {
    expect(['a.swift', 'a.m', 'a.dart', 'a.tsx', 'a.d.ts', 'a.kt'].map(sourceLanguage)).toEqual([
      'swift',
      'objc',
      'dart',
      'js',
      undefined,
      undefined,
    ]);
  });
});

describe('KEY001 and KEY002', () => {
  it('reports Swift lookups of keys their table does not have', () => {
    const swift = [
      'let a = NSLocalizedString("settings.title", comment: "")',
      'let b = NSLocalizedString("settings.missing", comment: "")',
      'let c = String(localized: "network", table: "Errors")',
      'let d = String(localized: "timeout", table: "Errors")',
      'let e = String(localized: "x", table: "ThirdParty")',
      'let f = String(localized: "Hello \\(name)")',
      'let g = NSLocalizedString(dynamicKey, comment: "")',
      '// let h = NSLocalizedString("commented.out", comment: "")',
    ].join('\n');
    expect(found('App/View.swift', swift)).toEqual([
      'KEY001:2 settings.missing',
      'KEY001:4 timeout',
    ]);
  });

  it('reports Objective-C lookups', () => {
    const objc =
      'NSString *a = NSLocalizedString(@"settings.title", nil);\nNSString *b = NSLocalizedString(@"nope", nil);';
    expect(found('App/View.m', objc)).toEqual(['KEY001:2 nope']);
  });

  it('reports SwiftUI literals missing from the String Catalog, not verbatim text', () => {
    const swift = [
      'Text("Hello")',
      'Text("Goodbye")',
      'Button("Delete") {}',
      'Text(verbatim: "Build 42")',
      '.navigationTitle("Inbox")',
      'Text("50%")',
      'Text("network", tableName: "Errors")',
    ].join('\n');
    expect(found('App/ContentView.swift', swift)).toEqual(['KEY002:2 Goodbye', 'KEY002:5 Inbox']);
  });

  it('reports JavaScript lookups of unknown keys, with namespaces and plural bases', () => {
    const js = [
      "t('home.title')",
      "t('home.subtitle')",
      "i18n.t('items', { count })",
      "t('common:ok')",
      "t('common:cancel')",
      // biome-ignore lint/suspicious/noTemplateCurlyInString: source code under test.
      't(`dynamic.${key}`)',
      "t('prefix.' + key)",
      '<Trans i18nKey="missing.trans" />',
      "intl.formatMessage({ id: 'gone' })",
    ].join('\n');
    expect(found('src/App.tsx', js)).toEqual([
      'KEY001:2 home.subtitle',
      'KEY001:5 common:cancel',
      'KEY001:8 missing.trans',
      'KEY001:9 gone',
    ]);
  });
});

describe('HCS001', () => {
  it('reports UIKit text set from literals', () => {
    const swift = [
      'label.text = "Welcome back"',
      'button.setTitle("Sign in", for: .normal)',
      'let alert = UIAlertController(title: "Error", message: "Try again later", preferredStyle: .alert)',
      'label.text = ""',
      'view.accessibilityIdentifier = "login_button"',
      'label.text = NSLocalizedString("settings.title", comment: "")',
    ].join('\n');
    expect(found('App/Login.swift', swift)).toEqual([
      'HCS001:1 Welcome back',
      'HCS001:2 Sign in',
      'HCS001:3 Error',
      'HCS001:3 Try again later',
    ]);
  });

  it('reports Flutter Text widgets and text parameters, not interpolations or identifiers', () => {
    const dart = [
      "Text('You have pushed the button this many times:')",
      "TextField(decoration: InputDecoration(hintText: 'Search'))",
      "Text('$count')",
      'Text(AppLocalizations.of(context)!.title)',
      "Navigator.pushNamed(context, '/settings')",
      "Text('ok_button')",
      "MaterialApp(title: 'Flutter Demo')",
    ].join('\n');
    expect(found('lib/main.dart', dart)).toEqual([
      'HCS001:1 You have pushed the button this many times:',
      'HCS001:2 Search',
      'HCS001:7 Flutter Demo',
    ]);
  });

  it('reports React Native text and props', () => {
    const tsx = [
      '<Text style={styles.title}>Welcome to the app</Text>',
      "<TextInput placeholder='Email address' />",
      '<Text>{t("home.title")}</Text>',
      "Alert.alert('Saved', 'Your changes are saved')",
      "navigation.setOptions({ headerTitle: 'Profile' })",
      '<Button title="OK" onPress={save} />',
    ].join('\n');
    expect(found('src/Home.tsx', tsx)).toEqual([
      'HCS001:1 Welcome to the app',
      'HCS001:2 Email address',
      'HCS001:4 Saved',
      'HCS001:5 Profile',
    ]);
  });

  it('skips tests, stories, generated files and suppressed lines', () => {
    const dart = "Text('Hello there')";
    expect(found('test/widget_test.dart', dart)).toEqual([]);
    expect(found('lib/l10n/app_localizations_en.dart', dart)).toEqual([]);
    expect(found('src/Card.stories.tsx', '<Text>Hello there</Text>')).toEqual([]);
    expect(found('AppTests/LoginTests.swift', 'label.text = "Hello there"')).toEqual([]);
    expect(found('lib/a.dart', `${dart} // globallingo-ignore`)).toEqual([]);
    expect(found('lib/a.dart', `// globallingo-ignore-next-line\n${dart}`)).toEqual([]);
    expect(found('lib/a.dart', `// globallingo-ignore-next-line\n\n${dart}`)).toEqual([
      'HCS001:3 Hello there',
    ]);
  });
});

describe('TRI001 and TRI003', () => {
  it('reports locale-dependent case changes inside lookups', () => {
    expect(
      found(
        'a.ts',
        "t(key.toLocaleLowerCase())\nt(key.toLowerCase())\nt(key.toLocaleLowerCase('en'))",
      ),
    ).toEqual(['TRI001:1 .toLocaleLowerCase()']);
    expect(
      found(
        'a.swift',
        'NSLocalizedString(name.localizedLowercase, comment: "")\nString(localized: String.LocalizationValue(k.lowercased(with: .current)))',
      ),
    ).toEqual(['TRI001:1 .localizedLowercase', 'TRI001:2 .lowercased(with:.current']);
    expect(
      found(
        'a.m',
        'NSLocalizedString([key lowercaseStringWithLocale:[NSLocale currentLocale]], nil);',
      ),
    ).toEqual(['TRI001:1 lowercaseStringWithLocale:[NSLocalecurrentLocale]']);
  });

  it('reports translated text cased without the locale when the app ships Turkish', () => {
    expect(
      found(
        'a.tsx',
        "t('home.title').toUpperCase()\nt('home.title').toLocaleUpperCase(i18n.language)",
      ),
    ).toEqual(['TRI003:1 .toUpperCase()']);
    expect(
      found(
        'a.swift',
        'let t = String(localized: "Hello").uppercased()\nlet c = NSLocalizedString("Hello", comment: "").capitalized',
      ),
    ).toEqual(['TRI003:1 .uppercased()', 'TRI003:2 .capitalized']);
    expect(
      found(
        'lib/a.dart',
        'Text(AppLocalizations.of(context)!.city.toUpperCase())\nText(l10n.city.toLowerCase())\nText(name.toUpperCase())',
      ),
    ).toEqual([
      'TRI003:1 AppLocalizations.of(context)!.city.toUpperCase()',
      'TRI003:2 l10n.city.toLowerCase()',
    ]);
  });

  it('does not report display casing when no catalog has Turkish or Azerbaijani', () => {
    const ctx = context({ shipsTurkic: false });
    expect(found('a.tsx', "t('home.title').toUpperCase()", ctx)).toEqual([]);
    expect(found('lib/a.dart', 'Text(l10n.city.toUpperCase())', ctx)).toEqual([]);
  });
});
