<!-- i18n-source: README.md@98baa23022eb886d07765d7448fd2e72ab1913e1 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/banner-light.svg" alt="GlobalLingo: Lints iOS, Flutter and React Native localization files and names the fix for each finding."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/GlobalLingo/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/GlobalLingo/actions/workflows/ci.yml/badge.svg" alt="CI 상태"></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-version-light.svg" alt="최신 버전: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/blob/master/package.json"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-language-light.svg" alt="언어 버전: Node.js 22.12+"></picture></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/blob/master/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-license-light.svg" alt="라이선스: MIT"></picture></a>
</p>

<p align="center">
<a href="#빠른-시작"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-start-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-start-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-start-ko-light.svg" alt="시작하기"></picture></a>
<a href="https://muhittincamdali.github.io/GlobalLingo/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-docs-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-docs-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-docs-ko-light.svg" alt="문서"></picture></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/tree/master/docs/guides"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-guides-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-guides-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-guides-ko-light.svg" alt="가이드"></picture></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/tree/master/examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-examples-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-examples-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-examples-ko-light.svg" alt="예제"></picture></a>
</p>

> 이 문서는 영어 README의 번역본입니다. 내용이 다를 경우 영어 버전이 최신입니다.

<!-- brand:end -->
GlobalLingo는 iOS, Flutter 또는 React Native/Expo 앱의 현지화 파일을 배포하기 전에 검사합니다. 대상은 Xcode String Catalogs, `.strings`와 `.stringsdict` 파일, Flutter ARB 파일, JSON 번역 파일입니다. 누락되거나 비어 있거나 오래된 번역, 언어 간에 일치하지 않는 플레이스홀더와 복수형, 중복된 키, 코드에서 조회하지만 어떤 파일에도 정의되지 않은 키, 하드코딩된 UI 텍스트, 터키어의 점 있는 I와 점 없는 I 함정을 찾아내고, 각 결과에 대한 해결 방법을 알려 줍니다. 파일을 읽기만 하며 Node.js 외에는 아무것도 필요하지 않습니다.

<picture><source media="(prefers-color-scheme: dark)" srcset="docs/media/demo-flutter-dark.svg"><source media="(prefers-color-scheme: light)" srcset="docs/media/demo-flutter-light.svg"><img src="docs/media/demo-flutter-light.svg" alt="Flutter 앱에서 실행한 GlobalLingo: 독일어 ARB 파일에서 이름이 바뀐 플레이스홀더(FMT001, FMT002), 2~4개와 5개 이상의 복수형이 없는 폴란드어(PLU001), 사용되지 않는 메시지와 누락된 메시지, 하드코딩된 텍스트, 터키어 텍스트에 사용된 toUpperCase. 각각에 해결 방법이 함께 표시됩니다"></picture>

<sub>실제 CLI로 <a href="fixtures/flutter-arb">flutter-arb fixture</a>(Flutter 3.47.5 앱)를 대상으로 녹화했습니다(<code>npm run demo</code>). <code>flutter gen-l10n</code>은 이 독일어 파일을 받아들인 뒤 빌드를 실패시킵니다. 자세한 내용은 <a href="docs/guides/placeholders-and-plurals.md">가이드</a>를 참고하세요.</sub>

## 주요 기능

- **네 가지 형식, 하나의 보고서.** String Catalogs, `.strings`/`.stringsdict`, ARB, JSON(i18next, i18n-js, react-intl/FormatJS)을 같은 모델로 읽어 동일한 19개 규칙으로 검사하므로, 네이티브 앱, Flutter 앱, Expo 앱이 함께 있는 monorepo에서도 보고서는 하나만 나옵니다.
- **각 런타임이 읽는 방식 그대로 플레이스홀더를 검사합니다.** 형식 지정자는 위치와 타입 기준으로(`%@`와 `%lld`, `%d`와 `%lld`, `%#@name@` 치환), ICU와 i18next 플레이스홀더는 이름 기준으로, 복수형마다 검사합니다.
- **CLDR 기반 복수형.** 각 로캘이 해당 언어에서 쓰는 카테고리를 검사합니다(폴란드어의 `few`와 `many`, 아랍어의 여섯 가지 전부). 메시지에는 예시 숫자가 포함됩니다.
- **코드도 검사합니다.** 코드에서 조회하지만 어떤 카탈로그에도 정의되지 않은 키, 어떤 코드에서도 언급되지 않는 키, String Catalog에 없는 SwiftUI 리터럴, UIKit, Flutter, React Native의 하드코딩된 텍스트, 터키어와 아제르바이잔어 기기에서 깨지는 대소문자 변환을 찾습니다.
- **CI를 위해 만들었습니다.** 종료 코드 0/1/2, `--fail-on`, 새로운 결과만 실패로 처리하는 baseline 파일, 텍스트, Markdown, JSON, SARIF(code scanning), GitHub annotations 출력을 지원합니다.
- **어떤 저장소에서도 한도가 있습니다.** 런타임 의존성이 없고, 네트워크를 사용하지 않으며, 심볼릭 링크를 따라가지 않습니다. 파일 크기, 깊이, 결과 개수에 한도가 있고, 프로젝트의 텍스트가 제어 문자를 포함한 채 터미널에 출력되는 일은 없습니다.

## 빠른 시작

[Node.js](https://nodejs.org/) 22.12 이상이 필요합니다(`node --version`으로 버전을 확인할 수 있고, Mac에서는 `brew install node`로 설치합니다). 그 외에는 아무것도 필요하지 않습니다. Xcode, Flutter, React Native 툴체인도 필요 없습니다.

**1. 앱 폴더에서 터미널을 엽니다.** `.xcodeproj`, `pubspec.yaml` 또는 `package.json`이 있는 폴더입니다.

```sh
cd path/to/YourApp
```

**2. GlobalLingo를 실행합니다.**

```sh
npx @mcamdali/globallingo
```

npm 패키지 이름은 `@mcamdali/globallingo`이고, 설치되는 명령은 `globallingo`입니다.

**3. 결과를 확인합니다.** 각 결과에는 규칙, 파일과 줄, 무엇이 잘못되었는지, 어떻게 고치는지가 나오고, 해당 규칙 문서로 가는 링크가 함께 표시됩니다. **ERROR** 결과가 있으면 종료 코드가 1이 되며, 마지막 줄에 그 개수가 표시됩니다. 경고에서도 실패하게 하려면 `--fail-on warning`을 추가하세요.

## GlobalLingo가 검사하는 항목

| 규칙   | 심각도  | 결과                                                                                           |
| ------ | ------- | ---------------------------------------------------------------------------------------------- |
| MIS001 | error   | 번역이 누락됨(또는 String Catalog 항목이 아직 "new" 상태)                                      |
| MIS002 | error   | 번역이 비어 있음                                                                               |
| MIS003 | warning | String Catalog 번역에 검토가 필요함                                                            |
| MIS004 | info    | 번역이 원본 텍스트와 같음                                                                      |
| STA001 | warning | Xcode가 해당 키를 stale(오래됨)로 표시함                                                       |
| STA002 | warning | 번역에 원본 언어에는 없는 키가 있음                                                            |
| FMT001 | error   | 원본에 없거나 타입이 다른 플레이스홀더                                                         |
| FMT002 | warning | 원본의 플레이스홀더가 빠져 있음                                                                |
| FMT003 | error   | 파일 또는 메시지를 파싱할 수 없음(JSON, `.strings`, plist, ICU, `%` 시퀀스)                    |
| PLU001 | warning | 해당 언어에 필요한 복수형(CLDR)이 누락됨                                                       |
| PLU002 | error   | 복수형에 `other` 형태가 없음                                                                   |
| DUP001 | error   | 한 파일에 같은 키가 두 번 나옴                                                                 |
| KEY001 | error   | 코드가 어떤 카탈로그에도 정의되지 않은 키를 조회함                                             |
| KEY002 | warning | SwiftUI 리터럴이 String Catalog에 없음                                                         |
| KEY003 | info    | 어떤 소스 파일도 해당 키를 언급하지 않음                                                       |
| HCS001 | warning | 사용자에게 표시되는 텍스트가 하드코딩됨                                                        |
| TRI001 | warning | 조회 키의 대소문자가 기기 로캘에 따라 변환됨                                                   |
| TRI002 | warning | 키에 `İ` 또는 `ı`가 포함됨                                                                    |
| TRI003 | warning | 터키어 또는 아제르바이잔어를 제공하는 앱에서 번역된 텍스트의 대소문자를 로캘 없이 변환함       |

[docs/rules.md](docs/rules.md)는 각 규칙을 예시와 함께 설명하고, 생태계별 해결 방법과 근거가 되는 Apple, Flutter, Unicode, ICU 및 라이브러리 문서를 안내합니다.

## 설치

위와 같이 설치 없이 실행하거나, `globallingo` 명령을 설치하세요.

```sh
npm i -g @mcamdali/globallingo
globallingo
```

JavaScript 프로젝트에서는 `npm install --save-dev @mcamdali/globallingo`로 버전을 고정할 수 있고, `npx globallingo`는 그 사본을 실행합니다. 각 [GitHub release](https://github.com/muhittincamdali/GlobalLingo/releases)에는 패키지도 `globallingo-<version>.tgz`로 `SHA256SUMS` 파일과 함께 첨부되며, release 워크플로는 `brew install muhittincamdali/tap/globallingo`를 위한 Homebrew formula를 엽니다.

클론에서 실행하려면:

```sh
git clone https://github.com/muhittincamdali/GlobalLingo.git
cd GlobalLingo && npm ci && npm run build
node dist/cli/main.js path/to/YourApp
```

## 사용법

```text
globallingo [path] [options]
```

| 옵션                      | 동작                                                                       |
| ------------------------- | -------------------------------------------------------------------------- |
| `path`                    | 앱의 폴더. 기본값은 현재 폴더                                              |
| `-f, --format <format>`   | `tty`(기본값), `markdown`, `json`, `sarif`, `github`                       |
| `-o, --output <file>`     | 보고서를 터미널 대신 파일에 기록                                           |
| `--fail-on <severity>`    | `error`(기본값), `warning`, `info`, `none`: 종료 코드를 1로 만드는 기준    |
| `-c, --config <file>`     | 설정 파일. 기본값은 파일이 있을 때 `<path>/.globallingo.json`              |
| `--source <locale>`       | 파일에서 알 수 없을 때 사용할 원본 언어                                    |
| `--locales <list>`        | 지정한 로캘만 검사(예: `de,tr,pl`)                                         |
| `--baseline <file>`       | 이 파일에 있는 결과는 보고되지만 실행을 실패시키지 않음                    |
| `--write-baseline <file>` | 이번 실행의 모든 결과를 baseline 파일에 기록                               |
| `--no-code`               | 현지화 파일만 검사하고 소스 코드는 검사하지 않음                           |
| `--no-color`              | 터미널에서도 일반 텍스트로 출력(`NO_COLOR`와 `FORCE_COLOR`를 따름)         |

종료 코드: `0`은 `--fail-on` 이상의 결과가 없음, `1`은 그 이상의 결과가 있음, `2`는 잘못된 인수나 설정, 현지화 파일을 찾지 못함, 또는 예기치 않은 오류입니다. `--write-baseline`을 지정하면 파일을 쓴 뒤 `0`으로 종료합니다. 현지화 파일이 없는 폴더는 오류로 처리되므로, CI에서 경로가 잘못되어도 조용히 통과하지 않습니다.

### CI에서 실행하기

[examples/github-actions/globallingo.yml](examples/github-actions/globallingo.yml)은 pull request에 주석을 달고, 커버리지와 결과를 작업 요약에 기록하고, code scanning용 SARIF를 업로드하며, 오류가 있으면 작업을 실패시킵니다. 각 부분은 [CI에서 GlobalLingo 실행하기](docs/guides/ci.md)에서 설명합니다.

### baseline으로 시작하기

```sh
npx @mcamdali/globallingo --write-baseline .globallingo-baseline.json
npx @mcamdali/globallingo --baseline .globallingo-baseline.json
```

첫 번째 명령은 현재의 결과를 수용하고, 두 번째 명령은 새로운 결과에서만 실패합니다. 핑거프린트에는 줄 번호가 포함되지 않으므로 코드를 옮겨도 파일이 무효화되지 않습니다.

### 설정하기

앱 폴더의 `.globallingo.json`에서 원본 언어, 필수 로캘, 무시할 경로와 키, 규칙별 심각도(또는 `off`)를 설정합니다.

```json
{
  "locales": ["de", "pl", "tr"],
  "ignore": { "paths": ["**/__tests__/**"], "keys": ["legacy.*"] },
  "rules": { "HCS001": "error", "MIS004": "off" }
}
```

[docs/configuration.md](docs/configuration.md)에는 모든 필드, GlobalLingo가 스스로 찾아내는 항목, 한도가 정리되어 있습니다. 코드에서 `// globallingo-ignore`로 끝나는 줄은 보고되지 않습니다.

### JSON 보고서 또는 API 사용하기

```sh
npx @mcamdali/globallingo --format json > globallingo.json
```

보고서에는 로캘별 커버리지를 포함한 카탈로그와 각 결과의 `rule`, `severity`, `file`, `line`, `key`, `locale`, `message`, `fix`, `docs`, `fingerprint`가 들어 있습니다(`schemaVersion` 1). [examples/shell/errors-by-locale.sh](examples/shell/errors-by-locale.sh)는 `jq`로 로캘별 오류 수를 셉니다. 같은 검사를 JavaScript에서도 실행할 수 있습니다.

```js
import { render, scan } from '@mcamdali/globallingo';

const report = await scan('path/to/app', { locales: ['de', 'tr'] });
console.log(report.summary);
console.log(render(report, 'markdown'));
```

[examples/api/coverage.mjs](examples/api/coverage.mjs)는 모든 카탈로그의 커버리지를 출력합니다.

## 데모

터미널 녹화는 각 툴체인으로 만든 작은 앱인 [fixtures](fixtures/README.md)에서 CLI를 실행한 것입니다.

| 프로젝트                                                            | 녹화                                                                                   |
| ------------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| ARB 파일을 사용하는 Flutter 3.47.5 앱                               | 이 페이지 상단                                                                         |
| i18next를 사용하는 Expo SDK 58 앱                                   | [라이트](docs/media/demo-expo-light.svg) · [다크](docs/media/demo-expo-dark.svg)       |
| Xcode 27.1이 String Catalog 키를 추출한 SwiftUI 패키지              | [라이트](docs/media/demo-swiftui-light.svg) · [다크](docs/media/demo-swiftui-dark.svg) |
| `.strings`와 `.stringsdict`를 사용하는 UIKit 앱(XcodeGen)           | [라이트](docs/media/demo-uikit-light.svg) · [다크](docs/media/demo-uikit-dark.svg)     |

측정은 2026년 10월 28일에 Mac(Apple silicon, M5 Max)에서 Node.js 26.12로, 다른 작업들 때문에 로드 평균이 40을 넘는 상태에서 진행했습니다. 네 개의 fixture에 대해 `node dist/cli/main.js`를 100회씩 3세트 실행했으며 Node.js 시작 시간을 포함합니다. 세 세트의 중앙값은 0.12초, 0.13초, 0.14초였고, 가장 느린 실행은 0.54초였습니다.

### 사용자에게 보이는 모습

iOS 27.0 시뮬레이터(iPhone 17, Xcode 27.1로 빌드)에서 실행한 UIKit fixture입니다. 왼쪽이 영어, 오른쪽이 터키어입니다. Foundation은 번역이 없을 때(터키어의 `archive.confirm.message`, MIS001)와 어떤 테이블에도 키가 없을 때(`archive.confirm.ok`, KEY001) 키 자체를 표시합니다. 두 스크린샷은 `scripts/simulator-shots.sh`로 찍습니다.

<p align="center"><img src="docs/media/simulator/inbox-en.png" width="300" alt="영어로 표시된 Inbox 앱: 경고창이 메시지 텍스트와 함께 'Archive all messages?'라고 묻고, 버튼에는 원시 키 archive.confirm.ok가 표시됨"> <img src="docs/media/simulator/inbox-tr.png" width="300" alt="터키어로 표시된 Inbox 앱: 경고창 제목은 번역되었지만 메시지에는 원시 키 archive.confirm.message, 버튼에는 원시 키 archive.confirm.ok가 표시됨"></p>

## 상태

| 기능                                                                                                            | 상태      |
| --------------------------------------------------------------------------------------------------------------- | --------- |
| String Catalogs, `.strings`(UTF-8, UTF-16, XML)와 `.stringsdict`, l10n.yaml이 있는 ARB, i18next, i18n-js, ICU JSON | 동작함    |
| 19개 규칙: 번역, 오래된 키와 고아 키, 플레이스홀더, 복수형, 중복, 코드 속 키, 하드코딩된 텍스트, 터키어 I          | 동작함    |
| 터미널, Markdown, JSON, SARIF, GitHub annotation 출력, `--fail-on`, baseline, `.globallingo.json`               | 동작함    |
| 타입 선언을 갖춘 프로그래밍 방식 API                                                                            | 동작함    |
| YAML 번역 파일(Rails 방식 i18n, i18next YAML)                                                                   | 계획 중   |
| 네이티브 Android와 크로스 플랫폼 앱의 Android 쪽을 위한 `strings.xml`                                           | 계획 중   |
| GitHub Action 래퍼(`uses: muhittincamdali/GlobalLingo@v2`)와 pull request 댓글                                  | 계획 중   |
| 번역가용 주석: 주석이나 `@key` 설명이 없는 키를 보고                                                            | 계획 중   |

## 한계

- **컴파일러가 아니라 패턴입니다.** 코드 규칙은 주석을 비운 Swift, Objective-C, Dart, JavaScript/TypeScript를 읽고, 각 생태계에서 텍스트를 조회하고 표시하는 일반적인 방식을 찾습니다. 실행 중에 만들어지는 키, 조회 함수를 감싼 래퍼, 변수를 통해 설정되는 텍스트는 감지하지 못합니다.
- **리터럴 키만 검사합니다.** KEY001은 리터럴로 쓰인 키를 검사합니다. KEY003은 키와 이름이 같은 리터럴, 접두사, Dart 멤버를 모두 사용으로 간주하며, 사용 여부를 확인할 수 없는 키는 여전히 보고하기 때문에 info 결과입니다.
- **SwiftUI 보간.** Xcode는 컴파일러의 타입 정보를 이용해 `Text("\(count) books")`를 키 `%lld books`로 바꿉니다. GlobalLingo에는 그 정보가 없으므로 KEY002는 보간이나 `%`가 있는 리터럴을 건너뜁니다.
- **CLDR 버전.** 복수형 카테고리는 GlobalLingo를 실행하는 Node.js의 CLDR 데이터에서 가져옵니다(Node.js 26.12에서는 CLDR 49). 더 새로운 CLDR에서는 언어에 카테고리가 추가될 수 있습니다.
- **파일만 다룹니다.** GlobalLingo는 아무것도 빌드하거나 실행하거나 변경하지 않으며, 요청한 보고서나 baseline만 기록합니다.

## 문서

API 레퍼런스, 규칙, 설정, 가이드: [muhittincamdali.github.io/GlobalLingo](https://muhittincamdali.github.io/GlobalLingo/).

## 가이드

- [CI에서 GlobalLingo 실행하기](docs/guides/ci.md)
- [Apple, Flutter, JavaScript의 플레이스홀더와 복수형](docs/guides/placeholders-and-plurals.md)
- [터키어 I](docs/guides/turkish-i.md)
- 레퍼런스: [규칙](docs/rules.md) 및 [설정](docs/configuration.md)

## 관련 도구

같은 파일의 일부를 검사하는 다른 프로젝트도 있습니다. 어느 쪽이 맞는지는 무엇을 사용하는지에 따라 달라집니다.

- [xcstrings-lint](https://github.com/thatswiftguy/xcstrings-lint)는 String Catalogs와 `.strings` 파일을 위한 GitHub Action으로, pull request가 새로 도입한 문제만 막는 ratchet 모드와 pull request 댓글 기능이 있습니다.
- [i18n-check](https://github.com/lingualdev/i18n-check)는 JavaScript 앱의 JSON 및 YAML 번역 파일(ICU와 i18next)을 검증하며, i18next-parser를 통해 사용되지 않는 키와 정의되지 않은 키도 검사합니다.
- [BartyCrouch](https://github.com/FlineDev/BartyCrouch)는 `.strings` 파일을 Swift 코드 및 스토리보드와 동기화하고, API를 통해 번역할 수 있으며, 중복 키와 빈 값을 lint합니다.
- [StringsLint](https://github.com/dral3x/StringsLint)는 Swift 및 Objective-C 프로젝트에서 누락되거나 사용되지 않는 `.strings` 키를 보고합니다.
- Xcode의 String Catalog 편집기는 각 언어의 번역 진행 상황을 보여 주고, Flutter의 `gen-l10n`은 `untranslated-messages-file`로 번역되지 않은 메시지를 나열합니다.

GlobalLingo는 네 가지 형식을 한 번에 읽고, 플레이스홀더 타입, CLDR 복수형, 코드 검사, 터키어 I 규칙을 더합니다. 위 설명은 2026년 10월 28일 기준 각 프로젝트의 README를 바탕으로 합니다.

## 요구 사항

| 툴체인  | 최소 버전 |
| ------- | --------- |
| Node.js | 22.12     |

GlobalLingo에는 Xcode, Flutter, React Native가 필요하지 않습니다. 파일을 읽기만 하므로 Linux에서도 실행됩니다. CI는 Node.js 22와 24(Linux)에서 테스트를 실행하며, 로컬에서는 Mac(Apple silicon)의 Node.js 22.23, 24.22, 26.12에서 256개 테스트가 모두 통과합니다.

## 아키텍처

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

- 각 결과는 규칙 ID, 심각도(규칙의 기본값 또는 설정에서 지정한 값), 파일과 줄, 메시지, 해당 결과의 생태계에 맞는 규칙의 해결 방법, 문서 링크, baseline용 핑거프린트로 구성됩니다.
- 모든 리더는 중첩 한도에서 멈추고 입력 크기에 비례하는 시간 안에 처리하므로, 악의적으로 만든 파일이 스택이나 시간을 소진시킬 수 없습니다. 테스트에서는 100,000단계 깊이의 JSON을 입력으로 주고, 악의적으로 만든 카탈로그, 설정 파일, 소스 파일을 128 KB에서 2 MB로 키울 때 시간이 어떻게 늘어나는지 측정합니다.
- CLI(`src/cli/`)는 인수를 파싱하고, 색상과 너비를 고르고, 종료 코드를 설정하는 일만 합니다.

## 로드맵

[상태](#상태) 표를 참고하세요. YAML 파일, Android `strings.xml`, GitHub Action 래퍼, 번역가용 주석이 계획되어 있습니다. [CHANGELOG.md](CHANGELOG.md)에는 릴리스마다 바뀐 내용이 정리되어 있습니다.

## FAQ

**GlobalLingo가 내 파일을 변경하나요?** 아니요. 파일을 읽기만 하며, 요청한 보고서나 baseline만 기록합니다.

**영어는 두 가지 형태인데 폴란드어는 왜 네 가지가 필요한가요?** 폴란드어는 1에는 한 가지 형태, 2~4(그리고 22~24, 32~34…)에는 다른 형태, 0과 5~21(그리고 25~31…)에는 또 다른 형태, 소수에는 네 번째 형태를 사용합니다. CLDR은 이 규칙을 언어별로 기록하며, 표는 [복수형 가이드](docs/guides/placeholders-and-plurals.md)에 있습니다.

**내 앱에는 터키어 번역이 없습니다. 그래도 TRI001이 중요할 수 있나요?** 네. 이것은 앱의 언어가 아니라 기기의 언어에 관한 문제입니다. `toLocaleLowerCase()`로 소문자로 바꾼 키는 어떤 터키어 기기에서든 `I`가 `ı`가 됩니다. [터키어 I](docs/guides/turkish-i.md)에서 확인할 수 있습니다.

**내 프로젝트에서는 결과가 잘못되었습니다. 어떻게 해야 하나요?** `.globallingo.json`에서 규칙의 심각도를 낮추거나 `off`로 하고, 키나 경로를 무시하거나, 해당 줄에 `globallingo-ignore`를 표시하세요. 그리고 문제를 보여 주는 가장 작은 예시와 함께 issue를 열어 주세요.

## 기여하기

기여를 환영합니다. pull request를 열기 전에 [CONTRIBUTING.md](CONTRIBUTING.md)와 [행동 강령](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md)을 읽어 주세요. 보안 문제는 [SECURITY.md](SECURITY.md)에 설명된 대로 보고해 주세요.

## 라이선스

MIT 라이선스로 배포됩니다. 자세한 내용은 [LICENSE](LICENSE)를 참고하세요.
