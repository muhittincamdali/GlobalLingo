<!-- i18n-source: README.md@98baa23022eb886d07765d7448fd2e72ab1913e1 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/banner-light.svg" alt="GlobalLingo: Lints iOS, Flutter and React Native localization files and names the fix for each finding."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/GlobalLingo/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/GlobalLingo/actions/workflows/ci.yml/badge.svg" alt="CI 状态"></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-version-light.svg" alt="最新版本: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/blob/master/package.json"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-language-light.svg" alt="语言版本: Node.js 22.12+"></picture></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/blob/master/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-license-light.svg" alt="许可证: MIT"></picture></a>
</p>

<p align="center">
<a href="#快速开始"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-start-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-start-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-start-zh-CN-light.svg" alt="开始使用"></picture></a>
<a href="https://muhittincamdali.github.io/GlobalLingo/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-docs-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-docs-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-docs-zh-CN-light.svg" alt="文档"></picture></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/tree/master/docs/guides"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-guides-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-guides-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-guides-zh-CN-light.svg" alt="指南"></picture></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/tree/master/examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-examples-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-examples-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-examples-zh-CN-light.svg" alt="示例"></picture></a>
</p>

> 本文是英文 README 的译文。如两者内容不一致，以英文版为准。

<!-- brand:end -->
GlobalLingo 会在 iOS、Flutter 或 React Native/Expo 应用发布之前检查它的本地化文件：Xcode String
Catalogs、`.strings` 和 `.stringsdict` 文件、Flutter ARB 文件以及 JSON 翻译文件。它能找出缺失、为空和已过时的翻译，各语言之间不一致的占位符和复数形式，重复的键，代码中查找但没有任何文件定义的键，硬编码的界面文本，以及土耳其语带点和不带点 I 的陷阱，并为每个问题给出修复方法。它只读取文件，除 Node.js 之外无需任何其他依赖。

<picture><source media="(prefers-color-scheme: dark)" srcset="docs/media/demo-flutter-dark.svg"><source media="(prefers-color-scheme: light)" srcset="docs/media/demo-flutter-light.svg"><img src="docs/media/demo-flutter-light.svg" alt="在 Flutter 应用上运行 GlobalLingo：德语 ARB 文件中被改名的占位符（FMT001、FMT002），缺少 2 到 4 和 5 及以上复数形式的波兰语（PLU001），一条未使用和一条缺失的消息，硬编码文本，以及土耳其语文本上的 toUpperCase，每一项都附有修复方法"></picture>

<sub>录制自真实的 CLI，对象是 <a href="fixtures/flutter-arb">flutter-arb fixture</a>，一个
Flutter 3.47.5 应用（<code>npm run demo</code>）。<code>flutter gen-l10n</code> 会接受这份德语文件，随后构建失败；
参见<a href="docs/guides/placeholders-and-plurals.md">该指南</a>。</sub>

## 亮点

- **四种格式，一份报告。** String Catalogs、`.strings`/`.stringsdict`、ARB 和 JSON（i18next、
  i18n-js、react-intl/FormatJS）会被读入同一个模型，并用同样的 19 条规则检查，因此同时包含原生应用、
  Flutter 应用和 Expo 应用的 monorepo 只会得到一份报告。
- **按各运行时的读取方式检查占位符。** 格式说明符按位置和类型检查（`%@` 对 `%lld`、`%d` 对
  `%lld`、`%#@name@` 替换），ICU 和 i18next 占位符按名称检查，并且逐个复数形式检查。
- **来自 CLDR 的复数形式。** 每个语言环境都会按其语言使用的类别检查（波兰语的 `few` 和
  `many`，阿拉伯语的全部六种），消息中附有示例数字。
- **代码也在检查之列。** 代码中查找但没有任何目录定义的键，没有任何代码提到的键，String Catalog
  中缺少的 SwiftUI 字面量，UIKit、Flutter 和 React Native 中的硬编码文本，以及在土耳其语和阿塞拜疆语设备上会出错的大小写转换。
- **为 CI 而生。** 退出码 0/1/2、`--fail-on`、只让新增问题导致失败的 baseline 文件，以及文本、
  Markdown、JSON、SARIF（code scanning）或 GitHub annotations 格式的输出。
- **在任何仓库上都有边界。** 没有运行时依赖，不访问网络，不跟随符号链接，对文件大小、深度和问题数量设有上限，
  项目中的文本也绝不会带着控制字符输出到终端。

## 快速开始

需要 [Node.js](https://nodejs.org/) 22.12 或更高版本（`node --version` 会显示版本；在 Mac 上，
`brew install node` 即可安装）。除此之外不需要任何东西：不需要 Xcode，也不需要 Flutter 或 React Native 工具链。

**1. 在应用所在文件夹打开终端**，也就是包含 `.xcodeproj`、`pubspec.yaml` 或 `package.json` 的文件夹：

```sh
cd path/to/YourApp
```

**2. 运行 GlobalLingo：**

```sh
npx @mcamdali/globallingo
```

npm 包名为 `@mcamdali/globallingo`；它安装的命令是 `globallingo`。

**3. 阅读检查结果。** 每条结果都会给出规则、文件和行号、问题所在以及修复方法，并附上该规则文档的链接。**ERROR**
级别的结果会使退出码变为 1；最后一行会统计它们的数量。如果警告也要导致失败，请添加 `--fail-on warning`。

## GlobalLingo 检查什么

| 规则   | 严重程度 | 问题                                                                                    |
| ------ | -------- | --------------------------------------------------------------------------------------- |
| MIS001 | error    | 缺少翻译（或 String Catalog 条目仍处于 "new" 状态）                                      |
| MIS002 | error    | 翻译为空                                                                                |
| MIS003 | warning  | String Catalog 中的翻译需要审阅                                                          |
| MIS004 | info     | 翻译与源文本相同                                                                        |
| STA001 | warning  | Xcode 将该键标记为已过时（stale）                                                        |
| STA002 | warning  | 翻译中有一个源语言里没有的键                                                            |
| FMT001 | error    | 源文本中没有的占位符，或类型不同的占位符                                                |
| FMT002 | warning  | 源文本中的占位符被遗漏                                                                  |
| FMT003 | error    | 文件或消息无法解析（JSON、`.strings`、plist、ICU、`%` 序列）                             |
| PLU001 | warning  | 缺少该语言所需的复数形式（CLDR）                                                        |
| PLU002 | error    | 复数缺少 `other` 形式                                                                   |
| DUP001 | error    | 同一文件中键出现了两次                                                                  |
| KEY001 | error    | 代码查找的键没有任何目录定义                                                            |
| KEY002 | warning  | SwiftUI 字面量不在 String Catalog 中                                                    |
| KEY003 | info     | 没有任何源文件提到该键                                                                  |
| HCS001 | warning  | 展示给用户的文本是硬编码的                                                              |
| TRI001 | warning  | 查找键的大小写会随设备语言环境而变化                                                    |
| TRI002 | warning  | 键中包含 `İ` 或 `ı`                                                                     |
| TRI003 | warning  | 在提供土耳其语或阿塞拜疆语的应用中，翻译文本的大小写转换没有指定语言环境                |

[docs/rules.md](docs/rules.md) 用示例说明每条规则，给出各生态系统下的修复方法，以及规则所依据的
Apple、Flutter、Unicode、ICU 和各库的文档。

## 安装

可以像上面那样无需安装直接运行，也可以安装 `globallingo` 命令：

```sh
npm i -g @mcamdali/globallingo
globallingo
```

在 JavaScript 项目中，`npm install --save-dev @mcamdali/globallingo` 会锁定版本，
`npx globallingo` 运行的就是这个副本。每个
[GitHub release](https://github.com/muhittincamdali/GlobalLingo/releases) 也附带
`globallingo-<version>.tgz` 形式的包和一个 `SHA256SUMS` 文件，并且 release 工作流会为
`brew install muhittincamdali/tap/globallingo` 创建一个 Homebrew formula。

从克隆的仓库安装：

```sh
git clone https://github.com/muhittincamdali/GlobalLingo.git
cd GlobalLingo && npm ci && npm run build
node dist/cli/main.js path/to/YourApp
```

## 使用方法

```text
globallingo [path] [options]
```

| 选项                      | 作用                                                                     |
| ------------------------- | ------------------------------------------------------------------------ |
| `path`                    | 应用所在文件夹；默认为当前文件夹                                         |
| `-f, --format <format>`   | `tty`（默认）、`markdown`、`json`、`sarif` 或 `github`                   |
| `-o, --output <file>`     | 将报告写入文件，而不是输出到终端                                         |
| `--fail-on <severity>`    | `error`（默认）、`warning`、`info` 或 `none`：达到什么级别时退出码为 1   |
| `-c, --config <file>`     | 设置文件；若存在，默认为 `<path>/.globallingo.json`                      |
| `--source <locale>`       | 当文件中没有指明时，指定源语言                                           |
| `--locales <list>`        | 仅检查这些语言环境，例如 `de,tr,pl`                                      |
| `--baseline <file>`       | 此文件中的问题会被报告，但不会导致运行失败                               |
| `--write-baseline <file>` | 将本次运行的所有问题写入 baseline 文件                                   |
| `--no-code`               | 只检查本地化文件，不检查源代码                                           |
| `--no-color`              | 即使在终端中也输出纯文本（遵循 `NO_COLOR` 和 `FORCE_COLOR`）            |

退出码：`0` 表示没有达到或超过 `--fail-on` 级别的问题，`1` 表示有达到或超过该级别的问题，`2`
表示参数或设置有误、没有找到本地化文件，或发生意外错误。使用 `--write-baseline` 时，写入文件后退出码为 `0`。没有本地化文件的文件夹会被视为错误，因此 CI 中写错路径不会悄无声息地通过。

### 在 CI 中运行

[examples/github-actions/globallingo.yml](examples/github-actions/globallingo.yml) 会在 pull request
上添加注释，将覆盖率和检查结果写入作业摘要，上传 SARIF 供 code scanning 使用，并在出现错误时使作业失败。
[在 CI 中运行 GlobalLingo](docs/guides/ci.md)逐一说明了各个部分。

### 从 baseline 开始

```sh
npx @mcamdali/globallingo --write-baseline .globallingo-baseline.json
npx @mcamdali/globallingo --baseline .globallingo-baseline.json
```

第一条命令接受当前已有的问题；第二条只对新增的问题报错。指纹中不包含行号，因此移动代码不会使该文件失效。

### 配置

应用文件夹中的 `.globallingo.json` 可以设置源语言、必需的语言环境、忽略的路径和键，以及每条规则的严重程度（或 `off`）：

```json
{
  "locales": ["de", "pl", "tr"],
  "ignore": { "paths": ["**/__tests__/**"], "keys": ["legacy.*"] },
  "rules": { "HCS001": "error", "MIS004": "off" }
}
```

[docs/configuration.md](docs/configuration.md) 列出了每个字段、GlobalLingo 自行发现的内容以及各项限制。在代码中，以
`// globallingo-ignore` 结尾的行不会被报告。

### 使用 JSON 报告或 API

```sh
npx @mcamdali/globallingo --format json > globallingo.json
```

报告包含各目录及每个语言环境的覆盖率，以及每条问题的 `rule`、`severity`、`file`、`line`、`key`、`locale`、
`message`、`fix`、`docs` 和 `fingerprint`（`schemaVersion` 为 1）。
[examples/shell/errors-by-locale.sh](examples/shell/errors-by-locale.sh) 用 `jq` 统计每个语言环境的错误数。
同样的检查也可以在 JavaScript 中运行：

```js
import { render, scan } from '@mcamdali/globallingo';

const report = await scan('path/to/app', { locales: ['de', 'tr'] });
console.log(report.summary);
console.log(render(report, 'markdown'));
```

[examples/api/coverage.mjs](examples/api/coverage.mjs) 会输出每个目录的覆盖率。

## 演示

终端录像来自 CLI 在 [fixtures](fixtures/README.md) 上的运行，这些是用各个工具链制作的小型应用：

| 项目                                                    | 录像                                                                                  |
| ------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| 带有 ARB 文件的 Flutter 3.47.5 应用                      | 本页顶部                                                                              |
| 使用 i18next 的 Expo SDK 58 应用                         | [浅色](docs/media/demo-expo-light.svg) · [深色](docs/media/demo-expo-dark.svg)       |
| Xcode 27.1 已提取 String Catalog 键的 SwiftUI 包         | [浅色](docs/media/demo-swiftui-light.svg) · [深色](docs/media/demo-swiftui-dark.svg) |
| 使用 `.strings` 和 `.stringsdict` 的 UIKit 应用（XcodeGen） | [浅色](docs/media/demo-uikit-light.svg) · [深色](docs/media/demo-uikit-dark.svg)     |

测量于 2026 年 10 月 28 日，在一台 Mac（Apple silicon，M5 Max）上使用 Node.js 26.12，同时其他任务使平均负载保持在 40
以上：在四个 fixture 上对 `node dist/cli/main.js` 进行三组、每组 100 次运行，包含 Node.js 启动时间。三组的中位数分别为
0.12、0.13 和 0.14 秒；最慢的一次耗时 0.54 秒。

### 用户看到的内容

iOS 27.0 模拟器（iPhone 17，使用 Xcode 27.1 构建）中的 UIKit fixture，左侧为英语，右侧为土耳其语。当缺少翻译（土耳其语中的
`archive.confirm.message`，MIS001）以及没有任何表包含该键时（`archive.confirm.ok`，KEY001），Foundation 会直接显示键本身。
`scripts/simulator-shots.sh` 会截取这两张截图。

<p align="center"><img src="docs/media/simulator/inbox-en.png" width="300" alt="英语的 Inbox 应用：弹窗询问 "Archive all messages?" 并附有消息文本，按钮上显示原始键 archive.confirm.ok"> <img src="docs/media/simulator/inbox-tr.png" width="300" alt="土耳其语的 Inbox 应用：弹窗标题已翻译，但消息中显示原始键 archive.confirm.message，按钮上显示原始键 archive.confirm.ok"></p>

## 状态

| 功能                                                                                                          | 状态   |
| ------------------------------------------------------------------------------------------------------------- | ------ |
| String Catalogs、`.strings`（UTF-8、UTF-16、XML）和 `.stringsdict`、带 l10n.yaml 的 ARB、i18next、i18n-js 以及 ICU JSON | 可用   |
| 19 条规则：翻译、过时键和孤立键、占位符、复数、重复项、代码中的键、硬编码文本、土耳其语 I                        | 可用   |
| 终端、Markdown、JSON、SARIF 和 GitHub annotation 输出；`--fail-on`；baseline；`.globallingo.json`              | 可用   |
| 带类型声明的编程 API                                                                                            | 可用   |
| YAML 翻译文件（Rails 风格的 i18n、i18next YAML）                                                                | 计划中 |
| 面向原生 Android 以及跨平台应用 Android 端的 `strings.xml`                                                      | 计划中 |
| GitHub Action 封装（`uses: muhittincamdali/GlobalLingo@v2`）和 pull request 评论                               | 计划中 |
| 翻译人员注释：报告没有注释或 `@key` 说明的键                                                                    | 计划中 |

## 局限

- **是模式匹配，而不是编译器。** 代码规则会在清除注释后读取 Swift、Objective-C、Dart 和
  JavaScript/TypeScript，并查找各生态系统中查找和显示文本的常见写法。运行时拼出的键、对查找函数的封装，
  以及通过变量设置的文本都无法识别。
- **只支持字面量键。** KEY001 只检查以字面量写出的键。KEY003 把任何与该键同名的字面量、前缀或 Dart
  成员都算作一次使用，对于无法看出其用途的键仍会报告，因此它只是 info 级别的结果。
- **SwiftUI 插值。** Xcode 借助编译器的类型信息，将 `Text("\(count) books")` 转换为键 `%lld books`。
  GlobalLingo 没有这些信息，所以 KEY002 会跳过含有插值或 `%` 的字面量。
- **CLDR 版本。** 复数类别来自运行 GlobalLingo 的 Node.js 所带的 CLDR 数据（Node.js 26.12 中为 CLDR
  49）。更新的 CLDR 可能会为某种语言增加类别。
- **只读文件。** GlobalLingo 不会构建、运行或更改任何内容；它只会写入你要求的报告或 baseline。

## 文档

API 参考、规则、配置和指南：
[muhittincamdali.github.io/GlobalLingo](https://muhittincamdali.github.io/GlobalLingo/)。

## 指南

- [在 CI 中运行 GlobalLingo](docs/guides/ci.md)
- [Apple、Flutter 和 JavaScript 中的占位符与复数](docs/guides/placeholders-and-plurals.md)
- [土耳其语的 I](docs/guides/turkish-i.md)
- 参考：[规则](docs/rules.md)和[配置](docs/configuration.md)

## 相关工具

还有其他项目会检查部分相同的文件；哪一个更合适，取决于你使用的技术：

- [xcstrings-lint](https://github.com/thatswiftguy/xcstrings-lint) 是用于 String Catalogs 和 `.strings`
  文件的 GitHub Action，带有 ratchet 模式（只拦截某个 pull request 新引入的问题）和 pull request 评论。
- [i18n-check](https://github.com/lingualdev/i18n-check) 用于验证 JavaScript 应用的 JSON 和 YAML
  翻译文件（ICU 和 i18next），并通过 i18next-parser 检查未使用和未定义的键。
- [BartyCrouch](https://github.com/FlineDev/BartyCrouch) 让 `.strings` 文件与 Swift 代码和
  storyboard 保持同步，可以通过 API 进行翻译，并检查重复的键和空值。
- [StringsLint](https://github.com/dral3x/StringsLint) 报告 Swift 和 Objective-C 项目中缺失和未使用的
  `.strings` 键。
- Xcode 的 String Catalog 编辑器会显示各语言的翻译进度，Flutter 的 `gen-l10n` 可通过
  `untranslated-messages-file` 列出未翻译的消息。

GlobalLingo 一次运行即可读取全部四种格式，并增加了占位符类型、CLDR 复数形式、代码检查和土耳其语 I 规则。
以上描述来自各项目 2026 年 10 月 28 日的 README。

## 系统要求

| 工具链  | 最低版本 |
| ------- | -------- |
| Node.js | 22.12    |

GlobalLingo 不需要 Xcode、Flutter 或 React Native：它只读取文件，因此也可以在 Linux 上运行。CI 在 Node.js 22 和 24（Linux）上运行测试；在本地，全部 256 个测试已在 Mac（Apple silicon）上的 Node.js 22.23、24.22 和 26.12 中通过。

## 架构

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

- 每条结果包含规则 ID、严重程度（规则的默认值，或配置中指定的值）、文件和行号、消息、规则针对该结果所属生态系统的修复方法、文档链接，
  以及用于 baseline 的指纹。
- 每个读取器都在嵌套深度上限处停止，耗时与输入大小成正比，因此精心构造的文件无法耗尽栈或时间；测试会输入 100,000
  层的 JSON，并测量精心构造的目录、设置文件和源文件从 128 KB 增长到 2 MB 时耗时如何增长。
- CLI（`src/cli/`）只负责解析参数、选择颜色和宽度，并设置退出码。

## 路线图

参见[状态](#状态)表：YAML 文件、Android `strings.xml`、GitHub Action 封装和翻译人员注释均在计划中。
[CHANGELOG.md](CHANGELOG.md) 列出了每个版本的变更。

## 常见问题

**GlobalLingo 会修改我的文件吗？** 不会。它只读取文件，只写入你要求的报告或 baseline。

**英语只有两种形式，为什么波兰语需要四种？** 波兰语用一种形式表示 1，另一种表示 2–4（以及 22–24、32–34……），
再一种表示 0 和 5–21（以及 25–31……），第四种用于小数。CLDR 按语言记录这些规则；
[复数指南](docs/guides/placeholders-and-plurals.md)中有对应的表格。

**我的应用没有土耳其语翻译，TRI001 还有意义吗？** 有。它关乎设备的语言，而不是应用的语言：在任何土耳其语设备上，用
`toLocaleLowerCase()` 转为小写的键会把 `I` 变成 `ı`。[土耳其语的 I](docs/guides/turkish-i.md) 演示了这一点。

**某条检查结果对我的项目来说是错的，该怎么办？** 在 `.globallingo.json` 中调低或关闭该规则，忽略该键或路径，或者用
`globallingo-ignore` 标记该行，并请提交一个 issue，附上能说明问题的最小示例。

## 参与贡献

欢迎贡献：提交 pull request 之前，请阅读 [CONTRIBUTING.md](CONTRIBUTING.md) 和
[行为准则](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md)，并按照 [SECURITY.md](SECURITY.md)
中的说明报告安全问题。

## 许可证

基于 MIT 许可证发布。详见 [LICENSE](LICENSE)。
