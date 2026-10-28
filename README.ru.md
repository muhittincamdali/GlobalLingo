<!-- i18n-source: README.md@c32cc2ce311b4ffeda8e8efb2155f9b2654cfba5 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/banner-light.svg" alt="GlobalLingo: Lints iOS, Flutter and React Native localization files and names the fix for each finding."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/GlobalLingo/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/GlobalLingo/actions/workflows/ci.yml/badge.svg" alt="Статус CI"></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-version-light.svg" alt="Последняя версия: v1.0.0 · older Swift package"></picture></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/blob/master/package.json"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-language-light.svg" alt="Версия языка: Node.js 22.12+"></picture></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/blob/master/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-license-light.svg" alt="Лицензия: MIT"></picture></a>
</p>

<p align="center">
<a href="#быстрый-старт"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-start-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-start-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-start-ru-light.svg" alt="Начать"></picture></a>
<a href="https://muhittincamdali.github.io/GlobalLingo/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-docs-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-docs-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-docs-ru-light.svg" alt="Документация"></picture></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/tree/master/docs/guides"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-guides-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-guides-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-guides-ru-light.svg" alt="Руководства"></picture></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/tree/master/examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-examples-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-examples-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-examples-ru-light.svg" alt="Примеры"></picture></a>
</p>

> Это перевод README на английском языке. Если они расходятся, актуальна английская версия.

<!-- brand:end -->
GlobalLingo проверяет файлы локализации приложения для iOS, Flutter или React Native/Expo до выпуска: Xcode String Catalogs, файлы `.strings` и `.stringsdict`, файлы ARB для Flutter и JSON-файлы переводов. Он находит отсутствующие, пустые и устаревшие переводы, плейсхолдеры и формы множественного числа, которые не совпадают в разных языках, дублирующиеся ключи, ключи, которые код запрашивает, но ни один файл не определяет, жёстко прописанный в коде текст интерфейса и ловушки турецкой буквы I с точкой и без точки — и для каждой находки подсказывает исправление. Он только читает файлы и не требует ничего, кроме Node.js.

<picture><source media="(prefers-color-scheme: dark)" srcset="docs/media/demo-flutter-dark.svg"><source media="(prefers-color-scheme: light)" srcset="docs/media/demo-flutter-light.svg"><img src="docs/media/demo-flutter-light.svg" alt="GlobalLingo, запущенный на приложении Flutter: переименованный плейсхолдер в немецком ARB-файле (FMT001, FMT002), польский без форм множественного числа для 2–4 и для 5 и более (PLU001), неиспользуемое и отсутствующее сообщения, жёстко прописанный текст и toUpperCase для турецкого текста, и у каждой находки есть исправление"></picture>

<sub>Записано настоящим CLI на <a href="fixtures/flutter-arb">фикстуре flutter-arb</a> — приложении на Flutter 3.47.5 (<code>npm run demo</code>). <code>flutter gen-l10n</code> принимает немецкий файл, а затем сборка падает; см. <a href="docs/guides/placeholders-and-plurals.md">руководство</a>.</sub>

## Основные возможности

- **Четыре формата — один отчёт.** String Catalogs, `.strings`/`.stringsdict`, ARB и JSON (i18next, i18n-js, react-intl/FormatJS) читаются в одну модель и проверяются одними и теми же 19 правилами, поэтому для монорепозитория с нативным приложением, приложением на Flutter и приложением на Expo получается один отчёт.
- **Плейсхолдеры — так, как их читает каждая среда выполнения.** Спецификаторы формата проверяются по позиции и типу (`%@` против `%lld`, `%d` против `%lld`, подстановки `%#@name@`), плейсхолдеры ICU и i18next — по имени, для каждой формы множественного числа отдельно.
- **Формы множественного числа из CLDR.** Каждая локаль проверяется по категориям, которые использует её язык (`few` и `many` в польском, все шесть в арабском), а в сообщении приведены примеры чисел.
- **И код тоже.** Ключи, которые код запрашивает, но ни один каталог не определяет, ключи, которые не упоминаются ни в одном коде, литералы SwiftUI, отсутствующие в String Catalog, жёстко прописанный текст в UIKit, Flutter и React Native, а также преобразования регистра, которые ломаются на устройствах с турецким и азербайджанским языками.
- **Создан для CI.** Коды выхода 0/1/2, `--fail-on`, файл baseline, чтобы падали только новые находки, и вывод в виде текста, Markdown, JSON, SARIF (code scanning) или GitHub annotations.
- **Ограничен в любом репозитории.** Нет зависимостей времени выполнения, нет сети, символические ссылки не обрабатываются, размер файлов, глубина и число находок ограничены, а текст из проекта никогда не попадает в терминал с управляющими символами.

## Быстрый старт

Вам нужен [Node.js](https://nodejs.org/) версии 22.12 или новее (`node --version` покажет версию; на Mac его устанавливает `brew install node`). Больше ничего: ни Xcode, ни инструментов Flutter или React Native.

**1. Откройте терминал в папке вашего приложения** — там, где лежит `.xcodeproj`, `pubspec.yaml` или `package.json`:

```sh
cd path/to/YourApp
```

**2. Запустите GlobalLingo:**

```sh
npx @mcamdali/globallingo
```

npm-пакет называется `@mcamdali/globallingo`; команда, которую он устанавливает, — `globallingo`.

**3. Прочитайте находки.** Каждая указывает правило, файл и строку, что не так и как это исправить, со ссылкой на документацию правила. Находки **ERROR** делают код выхода равным 1; последняя строка их подсчитывает. Чтобы падать и на предупреждениях, добавьте `--fail-on warning`.

## Что проверяет GlobalLingo

| Правило | Серьёзность | Находка                                                                                        |
| ------- | ----------- | ---------------------------------------------------------------------------------------------- |
| MIS001  | error       | Перевод отсутствует (или запись String Catalog всё ещё в состоянии «new»)                      |
| MIS002  | error       | Перевод пустой                                                                                 |
| MIS003  | warning     | Перевод в String Catalog требует проверки                                                      |
| MIS004  | info        | Перевод совпадает с исходным текстом                                                           |
| STA001  | warning     | Xcode помечает ключ как устаревший (stale)                                                     |
| STA002  | warning     | В переводе есть ключ, которого нет в исходном языке                                            |
| FMT001  | error       | Плейсхолдер, которого нет в оригинале, или другого типа                                        |
| FMT002  | warning     | Плейсхолдер оригинала пропущен                                                                 |
| FMT003  | error       | Файл или сообщение не разбирается (JSON, `.strings`, plist, ICU, последовательности `%`)       |
| PLU001  | warning     | Отсутствует форма множественного числа, нужная языку (CLDR)                                    |
| PLU002  | error       | У множественного числа нет формы `other`                                                       |
| DUP001  | error       | Ключ встречается в одном файле дважды                                                          |
| KEY001  | error       | Код запрашивает ключ, который не определён ни в одном каталоге                                 |
| KEY002  | warning     | Литерал SwiftUI отсутствует в String Catalog                                                   |
| KEY003  | info        | Ни один исходный файл не упоминает ключ                                                        |
| HCS001  | warning     | Текст, показываемый пользователю, жёстко прописан в коде                                       |
| TRI001  | warning     | Регистр ключа поиска меняется в зависимости от локали устройства                               |
| TRI002  | warning     | Ключ содержит `İ` или `ı`                                                                      |
| TRI003  | warning     | Регистр переведённого текста меняется без указания локали в приложении, которое поставляется с турецким или азербайджанским языком |

[docs/rules.md](docs/rules.md) описывает каждое правило с примерами, исправлением для каждой экосистемы и документами Apple, Flutter, Unicode, ICU и библиотек, на которых оно основано.

## Установка

Запускайте без установки, как показано выше, или установите команду `globallingo`:

```sh
npm i -g @mcamdali/globallingo
globallingo
```

В JavaScript-проекте `npm install --save-dev @mcamdali/globallingo` фиксирует версию, а `npx globallingo` запускает именно эту копию. К каждому [GitHub release](https://github.com/muhittincamdali/GlobalLingo/releases) также прилагается пакет в виде `globallingo-<version>.tgz` с файлом `SHA256SUMS`, а workflow релиза открывает формулу Homebrew для `brew install muhittincamdali/tap/globallingo`.

Из клона:

```sh
git clone https://github.com/muhittincamdali/GlobalLingo.git
cd GlobalLingo && npm ci && npm run build
node dist/cli/main.js path/to/YourApp
```

## Использование

```text
globallingo [path] [options]
```

| Параметр                  | Что делает                                                                         |
| ------------------------- | ---------------------------------------------------------------------------------- |
| `path`                    | Папка приложения; по умолчанию — текущая папка                                     |
| `-f, --format <format>`   | `tty` (по умолчанию), `markdown`, `json`, `sarif` или `github`                     |
| `-o, --output <file>`     | Записывает отчёт в файл вместо вывода в терминал                                   |
| `--fail-on <severity>`    | `error` (по умолчанию), `warning`, `info` или `none`: что делает код выхода равным 1   |
| `-c, --config <file>`     | Файл настроек; по умолчанию — `<path>/.globallingo.json`, если он существует       |
| `--source <locale>`       | Исходный язык, если файлы его не указывают                                         |
| `--locales <list>`        | Проверять только эти локали, например `de,tr,pl`                                   |
| `--baseline <file>`       | Находки из этого файла сообщаются, но не приводят к падению запуска                |
| `--write-baseline <file>` | Записывает все находки этого запуска в файл baseline                               |
| `--no-code`               | Проверять только файлы локализации, не исходный код                                |
| `--no-color`              | Обычный текст даже в терминале (`NO_COLOR` и `FORCE_COLOR` учитываются)            |

Коды выхода: `0` — нет находок уровня `--fail-on` и выше, `1` — есть находки этого уровня или выше, `2` — неверные аргументы или настройки, файлы локализации не найдены или произошла непредвиденная ошибка. С `--write-baseline` код выхода — `0`, если файл записан. Папка без файлов локализации считается ошибкой, чтобы неверный путь в CI не проходил молча.

### Запуск в CI

[examples/github-actions/globallingo.yml](examples/github-actions/globallingo.yml) добавляет аннотации к pull request, записывает покрытие и находки в сводку задания, загружает SARIF для code scanning и завершает задание с ошибкой, если есть ошибки. [Запуск GlobalLingo в CI](docs/guides/ci.md) объясняет каждую часть.

### Начните с baseline

```sh
npx @mcamdali/globallingo --write-baseline .globallingo-baseline.json
npx @mcamdali/globallingo --baseline .globallingo-baseline.json
```

Первая команда принимает сегодняшние находки; вторая падает только на новых. Отпечатки не содержат номеров строк, поэтому перенос кода не делает файл недействительным.

### Настройка

Файл `.globallingo.json` в папке приложения задаёт исходный язык, обязательные локали, игнорируемые пути и ключи, а также серьёзность (или `off`) для каждого правила:

```json
{
  "locales": ["de", "pl", "tr"],
  "ignore": { "paths": ["**/__tests__/**"], "keys": ["legacy.*"] },
  "rules": { "HCS001": "error", "MIS004": "off" }
}
```

[docs/configuration.md](docs/configuration.md) перечисляет все поля, то, что GlobalLingo находит сам, и ограничения. В коде строка, заканчивающаяся на `// globallingo-ignore`, не попадает в отчёт.

### JSON-отчёт и API

```sh
npx @mcamdali/globallingo --format json > globallingo.json
```

В отчёте есть каталоги с покрытием по локалям, а у каждой находки — `rule`, `severity`, `file`, `line`, `key`, `locale`, `message`, `fix`, `docs` и `fingerprint` (`schemaVersion` 1). [examples/shell/errors-by-locale.sh](examples/shell/errors-by-locale.sh) считает ошибки по локалям с помощью `jq`. Те же проверки можно запускать из JavaScript:

```js
import { render, scan } from '@mcamdali/globallingo';

const report = await scan('path/to/app', { locales: ['de', 'tr'] });
console.log(report.summary);
console.log(render(report, 'markdown'));
```

[examples/api/coverage.mjs](examples/api/coverage.mjs) выводит покрытие каждого каталога.

## Демо

Записи терминала сделаны запуском CLI на [фикстурах](fixtures/README.md) — небольших приложениях, созданных каждым из инструментов:

| Проект                                                                  | Запись                                                                                 |
| ----------------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| Приложение на Flutter 3.47.5 с файлами ARB                              | в начале этой страницы                                                                 |
| Приложение на Expo SDK 58 с i18next                                     | [светлая](docs/media/demo-expo-light.svg) · [тёмная](docs/media/demo-expo-dark.svg)    |
| Пакет SwiftUI, ключи String Catalog которого извлёк Xcode 27.1          | [светлая](docs/media/demo-swiftui-light.svg) · [тёмная](docs/media/demo-swiftui-dark.svg) |
| Приложение UIKit с `.strings` и `.stringsdict` (XcodeGen)               | [светлая](docs/media/demo-uikit-light.svg) · [тёмная](docs/media/demo-uikit-dark.svg)  |

Измерено 28 октября 2026 года на Mac (Apple silicon, M5 Max) с Node.js 26.12, пока другие задачи держали среднюю нагрузку выше 40: три серии по 100 запусков `node dist/cli/main.js` на четырёх фикстурах, включая запуск Node.js. Медианы трёх серий составили 0.12, 0.13 и 0.14 секунды; самый медленный запуск занял 0.54 секунды.

### Что видят пользователи

Фикстура UIKit в симуляторе iOS 27.0 (iPhone 17, сборка в Xcode 27.1): слева — английский, справа — турецкий. Foundation показывает сам ключ, если перевод отсутствует (`archive.confirm.message` в турецком, MIS001) и если ни одна таблица не содержит ключ (`archive.confirm.ok`, KEY001). `scripts/simulator-shots.sh` делает оба скриншота.

<p align="center"><img src="docs/media/simulator/inbox-en.png" width="300" alt="Приложение Inbox на английском: в диалоге спрашивается 'Archive all messages?' и показан текст сообщения, а на кнопке виден необработанный ключ archive.confirm.ok"> <img src="docs/media/simulator/inbox-tr.png" width="300" alt="Приложение Inbox на турецком: заголовок диалога переведён, но в сообщении виден необработанный ключ archive.confirm.message, а на кнопке — необработанный ключ archive.confirm.ok"></p>

## Статус

| Возможность                                                                                                                | Статус          |
| -------------------------------------------------------------------------------------------------------------------------- | --------------- |
| String Catalogs, `.strings` (UTF-8, UTF-16, XML) и `.stringsdict`, ARB с l10n.yaml, i18next, i18n-js и ICU JSON              | работает        |
| 19 правил: переводы, устаревшие и осиротевшие ключи, плейсхолдеры, множественное число, дубликаты, ключи в коде, жёстко прописанный текст, турецкая I | работает        |
| Вывод в терминал, Markdown, JSON, SARIF и GitHub annotation; `--fail-on`; baseline; `.globallingo.json`                      | работает        |
| Программный API с объявлениями типов                                                                                       | работает        |
| Файлы переводов YAML (i18n в стиле Rails, YAML для i18next)                                                                | запланировано   |
| `strings.xml` для Android — нативного и для Android-части кроссплатформенных приложений                                    | запланировано   |
| Обёртка GitHub Action (`uses: muhittincamdali/GlobalLingo@v2`) и комментарии в pull request                                | запланировано   |
| Комментарии для переводчиков: сообщать о ключах без комментария или описания `@key`                                        | запланировано   |

## Ограничения

- **Шаблоны, а не компилятор.** Правила для кода читают Swift, Objective-C, Dart и JavaScript/TypeScript с замазанными комментариями и ищут типичные способы, которыми каждая экосистема запрашивает и показывает текст. Ключи, составляемые во время выполнения, обёртки вокруг функций поиска и текст, задаваемый через переменные, не видны.
- **Только литеральные ключи.** KEY001 проверяет ключи, записанные литералами. KEY003 считает использованием любой литерал, префикс или член Dart с именем ключа и всё равно сообщает о ключе, использование которого он не видит, поэтому это находка уровня info.
- **Интерполяция в SwiftUI.** Xcode превращает `Text("\(count) books")` в ключ `%lld books`, используя информацию о типах от компилятора. У GlobalLingo её нет, поэтому KEY002 пропускает литералы с интерполяцией или `%`.
- **Версия CLDR.** Категории множественного числа берутся из данных CLDR того Node.js, который запускает GlobalLingo (CLDR 49 в Node.js 26.12). Более новый CLDR может добавить категорию языку.
- **Только файлы.** GlobalLingo ничего не собирает, не запускает и не изменяет; он записывает только отчёт или baseline, которые вы запросили.

## Документация

Справочник по API, правила, конфигурация и руководства: [muhittincamdali.github.io/GlobalLingo](https://muhittincamdali.github.io/GlobalLingo/).

## Руководства

- [Запуск GlobalLingo в CI](docs/guides/ci.md)
- [Плейсхолдеры и множественное число в Apple, Flutter и JavaScript](docs/guides/placeholders-and-plurals.md)
- [Турецкая I](docs/guides/turkish-i.md)
- Справка: [правила](docs/rules.md) и [конфигурация](docs/configuration.md)

## Похожие инструменты

Другие проекты проверяют часть тех же файлов; что подойдёт, зависит от того, чем вы пользуетесь:

- [xcstrings-lint](https://github.com/thatswiftguy/xcstrings-lint) — GitHub Action для String Catalogs и файлов `.strings` с режимом ratchet, который блокирует только проблемы, добавленные pull request, и с комментарием в pull request.
- [i18n-check](https://github.com/lingualdev/i18n-check) проверяет JSON- и YAML-файлы переводов JavaScript-приложений (ICU и i18next), включая неиспользуемые и неопределённые ключи через i18next-parser.
- [BartyCrouch](https://github.com/FlineDev/BartyCrouch) синхронизирует файлы `.strings` с кодом Swift и storyboard, умеет переводить через API и проверяет дублирующиеся ключи и пустые значения.
- [StringsLint](https://github.com/dral3x/StringsLint) сообщает об отсутствующих и неиспользуемых ключах `.strings` в проектах на Swift и Objective-C.
- Редактор String Catalog в Xcode показывает ход перевода для каждого языка, а `gen-l10n` во Flutter перечисляет непереведённые сообщения с помощью `untranslated-messages-file`.

GlobalLingo читает все четыре формата за один запуск и добавляет типы плейсхолдеров, формы множественного числа из CLDR, проверки кода и правила для турецкой I. Описания выше взяты из README каждого проекта на 28 октября 2026 года.

## Требования

| Инструменты | Минимальная версия |
| ----------- | ------------------ |
| Node.js     | 22.12              |

GlobalLingo не нужны Xcode, Flutter и React Native: он читает файлы, поэтому работает и в Linux. CI запускает тесты на Node.js 22 и 24 (Linux); локально все 256 проходят на Node.js 22.23, 24.22 и 26.12 на Mac (Apple silicon).

## Архитектура

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

- Каждая находка — это идентификатор правила, серьёзность (по умолчанию из правила или из конфигурации), файл и строка, сообщение, исправление правила для экосистемы находки, ссылка на документацию и отпечаток для baseline.
- Каждый парсер останавливается на пределе вложенности и работает время, пропорциональное размеру входных данных, поэтому специально подготовленные файлы не могут исчерпать стек или время; тесты подают ему JSON в 100 000 уровней вложенности и измеряют, как растёт время на специально подготовленных каталогах, настройках и исходных файлах от 128 КБ до 2 МБ.
- CLI (`src/cli/`) только разбирает аргументы, выбирает цвета и ширину и задаёт код выхода.

## План развития

См. таблицу [Статус](#статус): файлы YAML, Android `strings.xml`, обёртка GitHub Action и комментарии для переводчиков запланированы. [CHANGELOG.md](CHANGELOG.md) перечисляет, что изменилось в каждом выпуске.

## Частые вопросы

**Изменяет ли GlobalLingo мои файлы?** Нет. Он читает их и записывает только отчёт или baseline, которые вы запросили.

**Почему в польском нужно четыре формы, если в английском две?** В польском одна форма для 1, другая для 2–4 (и 22–24, 32–34…), третья для 0 и 5–21 (и 25–31…) и четвёртая для дробей. CLDR хранит эти правила для каждого языка; таблица есть в [руководстве по множественному числу](docs/guides/placeholders-and-plurals.md).

**В моём приложении нет турецкого перевода. Может ли TRI001 всё равно иметь значение?** Да. Речь идёт о языке устройства, а не приложения: ключ, переведённый в нижний регистр через `toLocaleLowerCase()`, превращает `I` в `ı` на любом турецком устройстве. [Турецкая I](docs/guides/turkish-i.md) показывает это.

**Находка неверна для моего проекта. Что делать?** Понизьте серьёзность правила или отключите его в `.globallingo.json`, проигнорируйте ключ или путь либо пометьте строку `globallingo-ignore` — и, пожалуйста, откройте issue с минимальным примером, который это показывает.

## Участие в разработке

Мы рады вашему участию: прежде чем открывать pull request, прочитайте [CONTRIBUTING.md](CONTRIBUTING.md) и [кодекс поведения](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md), а о проблемах безопасности сообщайте так, как описано в [SECURITY.md](SECURITY.md).

## Лицензия

Распространяется по лицензии MIT. Подробнее — в файле [LICENSE](LICENSE).
