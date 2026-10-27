<!-- i18n-source: README.md@84f1e7dbc06d5e1ea738f083ad2b3be786b6aef2 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/banner-light.svg" alt="GlobalLingo: Lints iOS, Flutter and React Native localization files and names the fix for each finding."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/GlobalLingo/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/GlobalLingo/actions/workflows/ci.yml/badge.svg" alt="CI ステータス"></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-version-light.svg" alt="最新バージョン: v1.0.0 · older Swift package"></picture></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/blob/master/package.json"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-language-light.svg" alt="言語バージョン: Node.js 22.12+"></picture></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/blob/master/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-license-light.svg" alt="ライセンス: MIT"></picture></a>
</p>

<p align="center">
<a href="#クイックスタート"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-start-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-start-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-start-ja-light.svg" alt="はじめる"></picture></a>
<a href="https://muhittincamdali.github.io/GlobalLingo/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-docs-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-docs-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-docs-ja-light.svg" alt="ドキュメント"></picture></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/tree/master/docs/guides"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-guides-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-guides-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-guides-ja-light.svg" alt="ガイド"></picture></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/tree/master/examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-examples-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-examples-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-examples-ja-light.svg" alt="サンプル"></picture></a>
</p>

> このドキュメントは英語版 README の翻訳です。内容が異なる場合は英語版が最新です。

<!-- brand:end -->
GlobalLingo は、iOS、Flutter、React Native/Expo アプリのローカライズファイルをリリース前に検査します。対象は Xcode の String Catalogs、`.strings` と `.stringsdict` ファイル、Flutter の ARB ファイル、JSON の翻訳ファイルです。翻訳の欠落・空欄・古くなったもの、言語間で一致しないプレースホルダーや複数形、重複したキー、コードが参照しているのにどのファイルにも定義されていないキー、ハードコードされた UI テキスト、トルコ語のドット付き・ドットなし I の落とし穴を見つけ、それぞれの検出結果に対する修正方法を示します。ファイルを読み取るだけで、必要なのは Node.js だけです。

<picture><source media="(prefers-color-scheme: dark)" srcset="docs/media/demo-flutter-dark.svg"><source media="(prefers-color-scheme: light)" srcset="docs/media/demo-flutter-light.svg"><img src="docs/media/demo-flutter-light.svg" alt="Flutter アプリで実行した GlobalLingo。ドイツ語の ARB ファイルで名前が変わったプレースホルダー（FMT001、FMT002）、2〜4 用と 5 以上用の複数形がないポーランド語（PLU001）、未使用のメッセージと欠落したメッセージ、ハードコードされたテキスト、トルコ語テキストへの toUpperCase。それぞれに修正方法が付いています"></picture>

<sub>実際の CLI で <a href="fixtures/flutter-arb">flutter-arb fixture</a>（Flutter 3.47.5 のアプリ）を対象に記録しました（<code>npm run demo</code>）。<code>flutter gen-l10n</code> はこのドイツ語ファイルを受け付けますが、その後ビルドが失敗します。詳しくは<a href="docs/guides/placeholders-and-plurals.md">ガイド</a>を参照してください。</sub>

## 主な特長

- **4 つの形式を 1 つのレポートに。** String Catalogs、`.strings`/`.stringsdict`、ARB、JSON（i18next、i18n-js、react-intl/FormatJS）を同じモデルに読み込み、同じ 19 のルールで検査します。ネイティブアプリ、Flutter アプリ、Expo アプリを含む monorepo でも、レポートは 1 つで済みます。
- **各ランタイムの読み方に合わせたプレースホルダー検査。** フォーマット指定子は位置と型で（`%@` と `%lld`、`%d` と `%lld`、`%#@name@` の置換）、ICU と i18next のプレースホルダーは名前で、複数形ごとに検査します。
- **CLDR に基づく複数形。** 各ロケールについて、その言語が使うカテゴリを検査します（ポーランド語の `few` と `many`、アラビア語の 6 つすべて）。メッセージには例となる数値が付きます。
- **コードも対象。** コードが参照しているのにどのカタログにも定義されていないキー、どのコードにも出てこないキー、String Catalog にない SwiftUI のリテラル、UIKit・Flutter・React Native のハードコードされたテキスト、トルコ語やアゼルバイジャン語のデバイスで壊れる大文字・小文字変換を検出します。
- **CI 向けに設計。** 終了コード 0/1/2、`--fail-on`、新しい検出結果だけを失敗にする baseline ファイル、テキスト・Markdown・JSON・SARIF（code scanning）・GitHub annotations での出力に対応します。
- **どのリポジトリでも上限付き。** ランタイム依存なし、ネットワークなし、シンボリックリンクは辿らず、ファイルサイズ・深さ・検出数に上限があり、プロジェクト内のテキストが制御文字を含んだままターミナルに届くことはありません。

## クイックスタート

[Node.js](https://nodejs.org/) 22.12 以降が必要です（`node --version` でバージョンを確認できます。Mac では `brew install node` でインストールできます）。ほかに必要なものはありません。Xcode、Flutter、React Native のツールチェーンも不要です。

**1. アプリのフォルダでターミナルを開きます。** `.xcodeproj`、`pubspec.yaml`、`package.json` があるフォルダです。

```sh
cd path/to/YourApp
```

**2. GlobalLingo を実行します。**

```sh
npx @mcamdali/globallingo
```

npm パッケージ名は `@mcamdali/globallingo` で、インストールされるコマンドは `globallingo` です。

**3. 検出結果を読みます。** それぞれの検出結果には、ルール、ファイルと行、問題点、修正方法が示され、ルールのドキュメントへのリンクが付きます。**ERROR** の検出結果があると終了コードは 1 になり、最後の行にその件数が表示されます。警告でも失敗させるには、`--fail-on warning` を追加してください。

## GlobalLingo が検査する内容

| ルール | 重大度  | 検出内容                                                                                       |
| ------ | ------- | ---------------------------------------------------------------------------------------------- |
| MIS001 | error   | 翻訳が欠けている（または String Catalog のエントリがまだ "new" 状態）                          |
| MIS002 | error   | 翻訳が空                                                                                       |
| MIS003 | warning | String Catalog の翻訳にレビューが必要                                                          |
| MIS004 | info    | 翻訳が元のテキストと同じ                                                                       |
| STA001 | warning | Xcode がキーを stale（古い）としてマークしている                                               |
| STA002 | warning | 翻訳に、ソース言語にないキーがある                                                             |
| FMT001 | error   | ソースにない、または型が異なるプレースホルダー                                                 |
| FMT002 | warning | ソースのプレースホルダーが抜けている                                                           |
| FMT003 | error   | ファイルまたはメッセージを解析できない（JSON、`.strings`、plist、ICU、`%` シーケンス）         |
| PLU001 | warning | その言語に必要な複数形（CLDR）が欠けている                                                     |
| PLU002 | error   | 複数形に `other` がない                                                                        |
| DUP001 | error   | 1 つのファイルで同じキーが 2 回現れる                                                          |
| KEY001 | error   | コードが、どのカタログにも定義されていないキーを参照している                                   |
| KEY002 | warning | SwiftUI のリテラルが String Catalog にない                                                     |
| KEY003 | info    | どのソースファイルにもそのキーが出てこない                                                     |
| HCS001 | warning | ユーザーに表示されるテキストがハードコードされている                                           |
| TRI001 | warning | 参照キーの大文字・小文字がデバイスのロケールによって変換される                                 |
| TRI002 | warning | キーに `İ` または `ı` が含まれている                                                           |
| TRI003 | warning | トルコ語またはアゼルバイジャン語を提供するアプリで、翻訳テキストの大文字・小文字をロケール指定なしで変換している |

[docs/rules.md](docs/rules.md) では、各ルールを例とともに説明し、エコシステムごとの修正方法と、根拠となる Apple、Flutter、Unicode、ICU、各ライブラリのドキュメントを紹介しています。

## インストール

上記のようにインストールせずに実行するか、`globallingo` コマンドをインストールします。

```sh
npm i -g @mcamdali/globallingo
globallingo
```

JavaScript プロジェクトでは、`npm install --save-dev @mcamdali/globallingo` でバージョンを固定でき、`npx globallingo` でそのコピーを実行できます。各 [GitHub release](https://github.com/muhittincamdali/GlobalLingo/releases) には、パッケージも `globallingo-<version>.tgz` として `SHA256SUMS` ファイルとともに添付され、release ワークフローは `brew install muhittincamdali/tap/globallingo` 用の Homebrew formula を開きます。

クローンから使う場合：

```sh
git clone https://github.com/muhittincamdali/GlobalLingo.git
cd GlobalLingo && npm ci && npm run build
node dist/cli/main.js path/to/YourApp
```

## 使い方

```text
globallingo [path] [options]
```

| オプション                | 動作                                                                          |
| ------------------------- | ----------------------------------------------------------------------------- |
| `path`                    | アプリのフォルダ。デフォルトはカレントフォルダ                                |
| `-f, --format <format>`   | `tty`（デフォルト）、`markdown`、`json`、`sarif`、`github`                    |
| `-o, --output <file>`     | レポートをターミナルではなくファイルに書き出す                                |
| `--fail-on <severity>`    | `error`（デフォルト）、`warning`、`info`、`none`：終了コードを 1 にする条件   |
| `-c, --config <file>`     | 設定ファイル。デフォルトは、存在する場合の `<path>/.globallingo.json`         |
| `--source <locale>`       | ファイルから分からない場合のソース言語                                        |
| `--locales <list>`        | 指定したロケールのみ検査する（例：`de,tr,pl`）                                |
| `--baseline <file>`       | このファイルにある検出結果は報告されるが、実行は失敗にならない                |
| `--write-baseline <file>` | 今回の実行のすべての検出結果を baseline ファイルに書き出す                    |
| `--no-code`               | ローカライズファイルのみ検査し、ソースコードは検査しない                      |
| `--no-color`              | ターミナルでもプレーンテキストにする（`NO_COLOR` と `FORCE_COLOR` に従います）|

終了コード：`0` は `--fail-on` 以上の検出結果がないこと、`1` は `--fail-on` 以上の検出結果があること、`2` は引数や設定が不正、ローカライズファイルが見つからない、または予期しないエラーを表します。`--write-baseline` を指定した場合は、ファイルを書き込めば `0` になります。ローカライズファイルのないフォルダはエラーになるため、CI でパスを間違えても黙って通ることはありません。

### CI で実行する

[examples/github-actions/globallingo.yml](examples/github-actions/globallingo.yml) は、pull request にアノテーションを付け、カバレッジと検出結果をジョブのサマリーに書き込み、code scanning 用に SARIF をアップロードし、エラーがあればジョブを失敗させます。各部分の説明は [CI で GlobalLingo を実行する](docs/guides/ci.md)にあります。

### baseline から始める

```sh
npx @mcamdali/globallingo --write-baseline .globallingo-baseline.json
npx @mcamdali/globallingo --baseline .globallingo-baseline.json
```

最初のコマンドは現時点の検出結果を受け入れ、2 つ目のコマンドは新しい検出結果だけを失敗にします。フィンガープリントに行番号は含まれないため、コードを移動してもファイルは無効になりません。

### 設定する

アプリのフォルダに置いた `.globallingo.json` で、ソース言語、必須のロケール、無視するパスとキー、ルールごとの重大度（または `off`）を設定できます。

```json
{
  "locales": ["de", "pl", "tr"],
  "ignore": { "paths": ["**/__tests__/**"], "keys": ["legacy.*"] },
  "rules": { "HCS001": "error", "MIS004": "off" }
}
```

[docs/configuration.md](docs/configuration.md) には、すべてのフィールド、GlobalLingo が自動で見つけるもの、上限が載っています。コードでは、行末が `// globallingo-ignore` の行は報告されません。

### JSON レポートまたは API を使う

```sh
npx @mcamdali/globallingo --format json > globallingo.json
```

レポートには、ロケールごとのカバレッジを含むカタログと、各検出結果の `rule`、`severity`、`file`、`line`、`key`、`locale`、`message`、`fix`、`docs`、`fingerprint` が含まれます（`schemaVersion` は 1）。[examples/shell/errors-by-locale.sh](examples/shell/errors-by-locale.sh) は `jq` でロケールごとのエラー数を数えます。同じ検査は JavaScript からも実行できます。

```js
import { render, scan } from '@mcamdali/globallingo';

const report = await scan('path/to/app', { locales: ['de', 'tr'] });
console.log(report.summary);
console.log(render(report, 'markdown'));
```

[examples/api/coverage.mjs](examples/api/coverage.mjs) は、すべてのカタログのカバレッジを出力します。

## デモ

ターミナルの録画は、各ツールチェーンで作った小さなアプリである[fixtures](fixtures/README.md)に対して CLI を実行したものです。

| プロジェクト                                                         | 録画                                                                                   |
| -------------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| ARB ファイルを使う Flutter 3.47.5 アプリ                             | このページの冒頭                                                                       |
| i18next を使う Expo SDK 58 アプリ                                    | [ライト](docs/media/demo-expo-light.svg) · [ダーク](docs/media/demo-expo-dark.svg)     |
| Xcode 27.1 が String Catalog のキーを抽出した SwiftUI パッケージ     | [ライト](docs/media/demo-swiftui-light.svg) · [ダーク](docs/media/demo-swiftui-dark.svg) |
| `.strings` と `.stringsdict` を使う UIKit アプリ（XcodeGen）         | [ライト](docs/media/demo-uikit-light.svg) · [ダーク](docs/media/demo-uikit-dark.svg)   |

計測は 2026 年 10 月 28 日、Mac（Apple silicon、M5 Max）上で Node.js 26.12 を使い、ほかのジョブによってロード平均が 40 を超えている状態で行いました。4 つの fixture に対する `node dist/cli/main.js` の 100 回実行を 3 セット、Node.js の起動時間を含めて測定しています。3 セットの中央値は 0.12、0.13、0.14 秒で、最も遅い実行は 0.54 秒でした。

### ユーザーに見えるもの

iOS 27.0 シミュレーター（iPhone 17、Xcode 27.1 でビルド）上の UIKit fixture です。左が英語、右がトルコ語です。Foundation は、翻訳がない場合（トルコ語の `archive.confirm.message`、MIS001）や、どのテーブルにもキーがない場合（`archive.confirm.ok`、KEY001）に、キーそのものを表示します。2 枚のスクリーンショットは `scripts/simulator-shots.sh` で撮影します。

<p align="center"><img src="docs/media/simulator/inbox-en.png" width="300" alt="英語の Inbox アプリ：アラートはメッセージ本文とともに「Archive all messages?」と尋ね、ボタンには生のキー archive.confirm.ok が表示されている"> <img src="docs/media/simulator/inbox-tr.png" width="300" alt="トルコ語の Inbox アプリ：アラートのタイトルは翻訳されているが、メッセージには生のキー archive.confirm.message、ボタンには生のキー archive.confirm.ok が表示されている"></p>

## ステータス

| 機能                                                                                                         | 状態   |
| ------------------------------------------------------------------------------------------------------------ | ------ |
| String Catalogs、`.strings`（UTF-8、UTF-16、XML）と `.stringsdict`、l10n.yaml 付き ARB、i18next、i18n-js、ICU JSON | 対応済み |
| 19 のルール：翻訳、古いキーと孤立キー、プレースホルダー、複数形、重複、コード内のキー、ハードコードされたテキスト、トルコ語の I | 対応済み |
| ターミナル、Markdown、JSON、SARIF、GitHub annotation 出力、`--fail-on`、baseline、`.globallingo.json`        | 対応済み |
| 型宣言付きのプログラム用 API                                                                                 | 対応済み |
| YAML 翻訳ファイル（Rails 形式の i18n、i18next YAML）                                                         | 計画中 |
| ネイティブ Android とクロスプラットフォームアプリの Android 側向けの `strings.xml`                           | 計画中 |
| GitHub Action ラッパー（`uses: muhittincamdali/GlobalLingo@v2`）と pull request コメント                    | 計画中 |
| 翻訳者向けコメント：コメントまたは `@key` の説明がないキーを報告                                             | 計画中 |

## 制限事項

- **コンパイラではなくパターンです。** コード用のルールは、コメントを空白にした Swift、Objective-C、Dart、JavaScript/TypeScript を読み、各エコシステムで文字列を参照・表示する一般的な書き方を探します。実行時に組み立てられるキー、参照関数のラッパー、変数経由で設定されるテキストは検出できません。
- **リテラルのキーのみ。** KEY001 は、リテラルで書かれたキーを検査します。KEY003 は、そのキーと同じ名前のリテラル、プレフィックス、Dart のメンバーを使用とみなし、使われ方が分からないキーはそれでも報告するため、info の検出結果になっています。
- **SwiftUI の補間。** Xcode はコンパイラの型情報を使って、`Text("\(count) books")` をキー `%lld books` に変換します。GlobalLingo にはその情報がないため、KEY002 は補間や `%` を含むリテラルをスキップします。
- **CLDR のバージョン。** 複数形のカテゴリは、GlobalLingo を実行する Node.js の CLDR データから取得します（Node.js 26.12 では CLDR 49）。新しい CLDR では、言語にカテゴリが追加されることがあります。
- **ファイルのみ。** GlobalLingo はビルド、実行、変更を一切行いません。書き込むのは、指定されたレポートまたは baseline だけです。

## ドキュメント

API リファレンス、ルール、設定、ガイド：[muhittincamdali.github.io/GlobalLingo](https://muhittincamdali.github.io/GlobalLingo/)。

## ガイド

- [CI で GlobalLingo を実行する](docs/guides/ci.md)
- [Apple、Flutter、JavaScript におけるプレースホルダーと複数形](docs/guides/placeholders-and-plurals.md)
- [トルコ語の I](docs/guides/turkish-i.md)
- リファレンス：[ルール](docs/rules.md)と[設定](docs/configuration.md)

## 関連ツール

同じファイルの一部を検査するプロジェクトは、ほかにもあります。どれが合うかは、使っているものによって変わります。

- [xcstrings-lint](https://github.com/thatswiftguy/xcstrings-lint) は、String Catalogs と `.strings` ファイル向けの GitHub Action です。pull request が新たに持ち込む問題だけをブロックする ratchet モードと、pull request コメントを備えています。
- [i18n-check](https://github.com/lingualdev/i18n-check) は、JavaScript アプリの JSON と YAML の翻訳ファイル（ICU と i18next）を検証します。i18next-parser を通じて、未使用および未定義のキーも対象です。
- [BartyCrouch](https://github.com/FlineDev/BartyCrouch) は、`.strings` ファイルを Swift コードやストーリーボードと同期し、API を通じた翻訳も可能で、重複キーと空の値を lint します。
- [StringsLint](https://github.com/dral3x/StringsLint) は、Swift と Objective-C のプロジェクトで、欠落している `.strings` キーと未使用の `.strings` キーを報告します。
- Xcode の String Catalog エディタは各言語の翻訳の進捗を表示し、Flutter の `gen-l10n` は `untranslated-messages-file` で未翻訳のメッセージを一覧にします。

GlobalLingo は 4 つの形式を 1 回の実行で読み込み、プレースホルダーの型、CLDR の複数形、コードの検査、トルコ語の I のルールを加えています。上記の説明は、2026 年 10 月 28 日時点の各プロジェクトの README に基づきます。

## 動作要件

| ツールチェーン | 最小バージョン |
| -------------- | -------------- |
| Node.js        | 22.12          |

GlobalLingo に Xcode、Flutter、React Native は不要です。ファイルを読むだけなので、Linux でも動作します。CI では Node.js 22 と 24（Linux）でテストを実行し、ローカルでは Mac（Apple silicon）上の Node.js 22.23、24.22、26.12 で 192 件すべてが成功しています。

## アーキテクチャ

```text
path ─► walk                 files of the folder (no symbolic links, no dependency folders, limits)
     ─► discoverCatalogs     String Catalogs, .lproj tables, ARB folders (l10n.yaml), JSON locale folders
          parse/             JSON, .strings, plist readers with line numbers and duplicate keys
          catalogs/          one model: catalog → key → translation per locale (texts, plurals, state)
     ─► checkCatalog         MIS, STA, FMT, PLU, DUP, TRI002 rules
          messages/          printf, ICU, i18next and i18n-js placeholder parsers; CLDR via Intl
     ─► checkSource          KEY001, KEY002, HCS001, TRI001, TRI003 on comment-blanked source code
     ─► unusedKeys           KEY003 from the literals and members of all source files
     ─► render               tty | markdown | json | sarif | github
```

- 各検出結果は、ルール ID、重大度（ルールのデフォルト、または設定で指定した値）、ファイルと行、メッセージ、その検出結果のエコシステムに対するルールの修正方法、ドキュメントへのリンク、baseline 用のフィンガープリントで構成されます。
- すべてのリーダーはネストの上限で停止し、すべてのパターンには上限があるため、細工されたファイルでスタックや時間を使い果たすことはできません。テストでは、100,000 階層の JSON と 2 MB のソースファイルを与えています。
- CLI（`src/cli/`）は、引数の解析、色と幅の選択、終了コードの設定だけを行います。

## ロードマップ

[ステータス](#ステータス)の表を参照してください。YAML ファイル、Android の `strings.xml`、GitHub Action ラッパー、翻訳者向けコメントが計画中です。各リリースの変更点は [CHANGELOG.md](CHANGELOG.md) にまとまっています。

## FAQ

**GlobalLingo は私のファイルを変更しますか？** いいえ。ファイルを読み取るだけで、書き込むのは指定したレポートまたは baseline だけです。

**英語は 2 つの形なのに、なぜポーランド語は 4 つ必要なのですか？** ポーランド語では、1 には 1 つの形、2〜4（および 22〜24、32〜34…）には別の形、0 と 5〜21（および 25〜31…）にはさらに別の形、小数には 4 つ目の形を使います。CLDR はこれらの規則を言語ごとに記録しています。表は[複数形のガイド](docs/guides/placeholders-and-plurals.md)にあります。

**自分のアプリにはトルコ語の翻訳がありません。それでも TRI001 は関係しますか？** はい。これはアプリの言語ではなく、デバイスの言語に関する問題です。`toLocaleLowerCase()` で小文字にしたキーは、トルコ語のデバイスでは `I` が `ı` になります。[トルコ語の I](docs/guides/turkish-i.md) で確認できます。

**検出結果が自分のプロジェクトでは間違っています。どうすればよいですか？** `.globallingo.json` でそのルールの重大度を下げるか `off` にする、キーやパスを無視する、または該当行に `globallingo-ignore` を付けてください。また、問題を再現できる最小の例を添えて issue を作成してください。

## コントリビューション

コントリビューションを歓迎します。pull request を作成する前に、[CONTRIBUTING.md](CONTRIBUTING.md) と[行動規範](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md)をお読みください。セキュリティ上の問題は、[SECURITY.md](SECURITY.md) の手順に従って報告してください。

## ライセンス

MIT ライセンスで公開しています。詳細は [LICENSE](LICENSE) を参照してください。
