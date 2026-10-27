<!-- i18n-source: README.md@84f1e7dbc06d5e1ea738f083ad2b3be786b6aef2 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/banner-light.svg" alt="GlobalLingo: Lints iOS, Flutter and React Native localization files and names the fix for each finding."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/GlobalLingo/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/GlobalLingo/actions/workflows/ci.yml/badge.svg" alt="Estado de CI"></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-version-light.svg" alt="Última versión: v1.0.0 · older Swift package"></picture></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/blob/master/package.json"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-language-light.svg" alt="Versión del lenguaje: Node.js 22.12+"></picture></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/blob/master/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-license-light.svg" alt="Licencia: MIT"></picture></a>
</p>

<p align="center">
<a href="#inicio-rápido"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-start-es-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-start-es-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-start-es-light.svg" alt="Empezar"></picture></a>
<a href="https://muhittincamdali.github.io/GlobalLingo/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-docs-es-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-docs-es-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-docs-es-light.svg" alt="Documentación"></picture></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/tree/master/docs/guides"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-guides-es-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-guides-es-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-guides-es-light.svg" alt="Guías"></picture></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/tree/master/examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-examples-es-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-examples-es-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-examples-es-light.svg" alt="Ejemplos"></picture></a>
</p>

> Esta es una traducción del README en inglés. Si hay diferencias, la versión en inglés es la vigente.

<!-- brand:end -->
GlobalLingo revisa los archivos de localización de una app de iOS, Flutter o React Native/Expo antes de publicarla: Xcode String Catalogs, archivos `.strings` y `.stringsdict`, archivos ARB de Flutter y archivos de traducción JSON. Encuentra traducciones que faltan, vacías o desactualizadas, marcadores de posición y formas plurales que no coinciden entre idiomas, claves duplicadas, claves que el código busca pero ningún archivo define, texto de interfaz escrito directamente en el código y las trampas de la I turca con punto y sin punto, e indica cómo corregir cada hallazgo. Solo lee archivos y no necesita nada más que Node.js.

<picture><source media="(prefers-color-scheme: dark)" srcset="docs/media/demo-flutter-dark.svg"><source media="(prefers-color-scheme: light)" srcset="docs/media/demo-flutter-light.svg"><img src="docs/media/demo-flutter-light.svg" alt="GlobalLingo ejecutado en una app de Flutter: un marcador de posición renombrado en el archivo ARB alemán (FMT001, FMT002), polaco sin las formas plurales para 2 a 4 y para 5 o más (PLU001), un mensaje sin usar y otro que falta, texto escrito directamente en el código y toUpperCase sobre texto en turco, cada uno con su corrección"></picture>

<sub>Grabado con la CLI real sobre el <a href="fixtures/flutter-arb">fixture flutter-arb</a>, una app de Flutter 3.47.5 (<code>npm run demo</code>). <code>flutter gen-l10n</code> acepta el archivo alemán y después la compilación falla; consulta <a href="docs/guides/placeholders-and-plurals.md">la guía</a>.</sub>

## Lo más destacado

- **Cuatro formatos, un solo informe.** String Catalogs, `.strings`/`.stringsdict`, ARB y JSON (i18next, i18n-js, react-intl/FormatJS) se leen en el mismo modelo y se revisan con las mismas 19 reglas, de modo que un monorepo con una app nativa, una app de Flutter y una app de Expo obtiene un único informe.
- **Marcadores de posición tal como los lee cada entorno de ejecución.** Los especificadores de formato se revisan por posición y tipo (`%@` frente a `%lld`, `%d` frente a `%lld`, sustituciones `%#@name@`), y los marcadores de ICU e i18next por nombre, para cada forma plural.
- **Formas plurales de CLDR.** Cada configuración regional se revisa con las categorías que usa su idioma (`few` y `many` en polaco, las seis en árabe), con números de ejemplo en el mensaje.
- **También el código.** Claves que el código busca pero ningún catálogo define, claves que ningún código menciona, literales de SwiftUI que faltan en el String Catalog, texto escrito directamente en el código de UIKit, Flutter y React Native, y cambios de mayúsculas y minúsculas que fallan en dispositivos en turco y azerí.
- **Pensado para CI.** Códigos de salida 0/1/2, `--fail-on`, un archivo baseline para que solo fallen los hallazgos nuevos y salida en texto, Markdown, JSON, SARIF (code scanning) o GitHub annotations.
- **Con límites en cualquier repositorio.** Sin dependencias en tiempo de ejecución, sin red, sin seguir enlaces simbólicos, con límites en el tamaño de los archivos, la profundidad y el número de hallazgos, y el texto del proyecto nunca llega a la terminal con caracteres de control.

## Inicio rápido

Necesitas [Node.js](https://nodejs.org/) 22.12 o posterior (`node --version` muestra la versión; en un Mac, `brew install node` lo instala). Nada más: ni Xcode, ni la cadena de herramientas de Flutter o React Native.

**1. Abre una terminal en la carpeta de tu app**, la que contiene el `.xcodeproj`, el `pubspec.yaml` o el `package.json`:

```sh
cd path/to/YourApp
```

**2. Ejecuta GlobalLingo:**

```sh
npx @mcamdali/globallingo
```

El paquete de npm es `@mcamdali/globallingo`; el comando que instala es `globallingo`.

**3. Lee los hallazgos.** Cada uno indica su regla, el archivo y la línea, qué está mal y cómo corregirlo, con un enlace a la documentación de la regla. Los hallazgos **ERROR** hacen que el código de salida sea 1; la última línea los cuenta. Para que también fallen las advertencias, añade `--fail-on warning`.

## Qué comprueba GlobalLingo

| Regla  | Gravedad | Hallazgo                                                                                       |
| ------ | -------- | ---------------------------------------------------------------------------------------------- |
| MIS001 | error    | Falta una traducción (o una entrada del String Catalog sigue en estado "new")                  |
| MIS002 | error    | Una traducción está vacía                                                                      |
| MIS003 | warning  | Una traducción del String Catalog necesita revisión                                            |
| MIS004 | info     | Una traducción es igual al texto original                                                      |
| STA001 | warning  | Xcode marca la clave como obsoleta (stale)                                                     |
| STA002 | warning  | Una traducción tiene una clave que el idioma de origen no tiene                                |
| FMT001 | error    | Un marcador de posición que el original no tiene, o de otro tipo                               |
| FMT002 | warning  | Se omite un marcador de posición del original                                                  |
| FMT003 | error    | Un archivo o mensaje no se puede analizar (JSON, `.strings`, plist, ICU, secuencias `%`)       |
| PLU001 | warning  | Falta una forma plural que el idioma necesita (CLDR)                                           |
| PLU002 | error    | Un plural no tiene la forma `other`                                                            |
| DUP001 | error    | Una clave aparece dos veces en un archivo                                                      |
| KEY001 | error    | El código busca una clave que ningún catálogo define                                           |
| KEY002 | warning  | Un literal de SwiftUI no está en el String Catalog                                             |
| KEY003 | info     | Ningún archivo fuente menciona la clave                                                        |
| HCS001 | warning  | El texto que se muestra al usuario está escrito directamente en el código                      |
| TRI001 | warning  | Una clave de búsqueda cambia entre mayúsculas y minúsculas según la configuración regional del dispositivo |
| TRI002 | warning  | Una clave contiene `İ` o `ı`                                                                   |
| TRI003 | warning  | El texto traducido cambia entre mayúsculas y minúsculas sin indicar la configuración regional, en una app que incluye turco o azerí |

[docs/rules.md](docs/rules.md) describe cada regla con ejemplos, la corrección para cada ecosistema y los documentos de Apple, Flutter, Unicode, ICU y de las bibliotecas en los que se basa.

## Instalación

Ejecútalo sin instalar, como arriba, o instala el comando `globallingo`:

```sh
npm i -g @mcamdali/globallingo
globallingo
```

En un proyecto de JavaScript, `npm install --save-dev @mcamdali/globallingo` fija una versión y `npx globallingo` ejecuta esa copia. Cada [GitHub release](https://github.com/muhittincamdali/GlobalLingo/releases) también incluye el paquete como `globallingo-<version>.tgz` con un archivo `SHA256SUMS`, y el workflow de release abre una fórmula de Homebrew para `brew install muhittincamdali/tap/globallingo`.

Desde un clon:

```sh
git clone https://github.com/muhittincamdali/GlobalLingo.git
cd GlobalLingo && npm ci && npm run build
node dist/cli/main.js path/to/YourApp
```

## Uso

```text
globallingo [path] [options]
```

| Opción                    | Qué hace                                                                           |
| ------------------------- | ---------------------------------------------------------------------------------- |
| `path`                    | La carpeta de la app; por defecto, la carpeta actual                               |
| `-f, --format <format>`   | `tty` (por defecto), `markdown`, `json`, `sarif` o `github`                        |
| `-o, --output <file>`     | Escribe el informe en un archivo en lugar de la terminal                           |
| `--fail-on <severity>`    | `error` (por defecto), `warning`, `info` o `none`: qué hace que el código de salida sea 1 |
| `-c, --config <file>`     | Archivo de configuración; por defecto, `<path>/.globallingo.json` si existe        |
| `--source <locale>`       | El idioma de origen, cuando los archivos no lo indican                             |
| `--locales <list>`        | Revisa solo estas configuraciones regionales, p. ej. `de,tr,pl`                    |
| `--baseline <file>`       | Los hallazgos de este archivo se informan pero no hacen fallar la ejecución        |
| `--write-baseline <file>` | Escribe todos los hallazgos de esta ejecución en un archivo baseline               |
| `--no-code`               | Revisa solo los archivos de localización, no el código fuente                      |
| `--no-color`              | Texto sin formato incluso en una terminal (se respetan `NO_COLOR` y `FORCE_COLOR`) |

Códigos de salida: `0` ningún hallazgo igual o superior a `--fail-on`, `1` hallazgos iguales o superiores, `2` argumentos o configuración incorrectos, no se encontraron archivos de localización o un error inesperado. Con `--write-baseline`, el código es `0` una vez escrito el archivo. Una carpeta sin archivos de localización es un error, así que una ruta equivocada en CI no pasa en silencio.

### Ejecútalo en CI

[examples/github-actions/globallingo.yml](examples/github-actions/globallingo.yml) anota el pull request, escribe la cobertura y los hallazgos en el resumen del job, sube SARIF para code scanning y hace fallar el job si hay errores. [Ejecutar GlobalLingo en CI](docs/guides/ci.md) explica cada parte.

### Empieza con un baseline

```sh
npx @mcamdali/globallingo --write-baseline .globallingo-baseline.json
npx @mcamdali/globallingo --baseline .globallingo-baseline.json
```

El primer comando acepta los hallazgos de hoy; el segundo falla solo con los nuevos. Las huellas no incluyen números de línea, así que mover código no invalida el archivo.

### Configuración

Un `.globallingo.json` en la carpeta de la app define el idioma de origen, las configuraciones regionales obligatorias, las rutas y claves que se ignoran y una gravedad (o `off`) por regla:

```json
{
  "locales": ["de", "pl", "tr"],
  "ignore": { "paths": ["**/__tests__/**"], "keys": ["legacy.*"] },
  "rules": { "HCS001": "error", "MIS004": "off" }
}
```

[docs/configuration.md](docs/configuration.md) enumera cada campo, lo que GlobalLingo encuentra por sí mismo y los límites. En el código, una línea que termine en `// globallingo-ignore` no se informa.

### Usa el informe JSON o la API

```sh
npx @mcamdali/globallingo --format json > globallingo.json
```

El informe incluye los catálogos con la cobertura por configuración regional y, de cada hallazgo, `rule`, `severity`, `file`, `line`, `key`, `locale`, `message`, `fix`, `docs` y `fingerprint` (`schemaVersion` 1). [examples/shell/errors-by-locale.sh](examples/shell/errors-by-locale.sh) cuenta los errores por configuración regional con `jq`. Las mismas comprobaciones se pueden ejecutar desde JavaScript:

```js
import { render, scan } from '@mcamdali/globallingo';

const report = await scan('path/to/app', { locales: ['de', 'tr'] });
console.log(report.summary);
console.log(render(report, 'markdown'));
```

[examples/api/coverage.mjs](examples/api/coverage.mjs) muestra la cobertura de cada catálogo.

## Demo

Las grabaciones de la terminal proceden de la CLI sobre los [fixtures](fixtures/README.md), pequeñas apps hechas con cada cadena de herramientas:

| Proyecto                                                                | Grabación                                                                              |
| ----------------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| App de Flutter 3.47.5 con archivos ARB                                  | arriba en esta página                                                                  |
| App de Expo SDK 58 con i18next                                          | [claro](docs/media/demo-expo-light.svg) · [oscuro](docs/media/demo-expo-dark.svg)      |
| Paquete SwiftUI cuyas claves de String Catalog extrajo Xcode 27.1       | [claro](docs/media/demo-swiftui-light.svg) · [oscuro](docs/media/demo-swiftui-dark.svg) |
| App UIKit con `.strings` y `.stringsdict` (XcodeGen)                    | [claro](docs/media/demo-uikit-light.svg) · [oscuro](docs/media/demo-uikit-dark.svg)    |

Medido el 28 de octubre de 2026 en un Mac (Apple silicon, M5 Max) con Node.js 26.12 mientras otros procesos mantenían la carga media por encima de 40: tres series de 100 ejecuciones de `node dist/cli/main.js` sobre los cuatro fixtures, incluido el arranque de Node.js. Las medianas de las tres series fueron 0.12, 0.13 y 0.14 segundos; la ejecución más lenta tardó 0.54 segundos.

### Lo que ven los usuarios

El fixture de UIKit en el simulador de iOS 27.0 (iPhone 17, compilado con Xcode 27.1), en inglés a la izquierda y en turco a la derecha. Foundation muestra la propia clave cuando falta una traducción (`archive.confirm.message` en turco, MIS001) y cuando ninguna tabla tiene la clave (`archive.confirm.ok`, KEY001). `scripts/simulator-shots.sh` toma ambas capturas.

<p align="center"><img src="docs/media/simulator/inbox-en.png" width="300" alt="La app Inbox en inglés: la alerta pregunta 'Archive all messages?' con el texto del mensaje, y el botón muestra la clave sin procesar archive.confirm.ok"> <img src="docs/media/simulator/inbox-tr.png" width="300" alt="La app Inbox en turco: el título de la alerta está traducido, pero el mensaje muestra la clave sin procesar archive.confirm.message y el botón la clave sin procesar archive.confirm.ok"></p>

## Estado

| Función                                                                                                                      | Estado        |
| ---------------------------------------------------------------------------------------------------------------------------- | ------------- |
| String Catalogs, `.strings` (UTF-8, UTF-16, XML) y `.stringsdict`, ARB con l10n.yaml, i18next, i18n-js y JSON de ICU          | funciona      |
| 19 reglas: traducciones, claves obsoletas y huérfanas, marcadores de posición, plurales, duplicados, claves en el código, texto escrito directamente en el código, I turca | funciona      |
| Salida en terminal, Markdown, JSON, SARIF y GitHub annotations; `--fail-on`; baselines; `.globallingo.json`                    | funciona      |
| API programática con declaraciones de tipos                                                                                  | funciona      |
| Archivos de traducción YAML (i18n al estilo Rails, YAML de i18next)                                                          | planificado   |
| `strings.xml` de Android para Android nativo y la parte Android de las apps multiplataforma                                  | planificado   |
| Un wrapper de GitHub Action (`uses: muhittincamdali/GlobalLingo@v2`) y comentarios en pull requests                          | planificado   |
| Comentarios para traductores: informar de las claves sin comentario ni descripción `@key`                                    | planificado   |

## Límites

- **Patrones, no un compilador.** Las reglas de código leen Swift, Objective-C, Dart y JavaScript/TypeScript con los comentarios en blanco y buscan las formas habituales en que cada ecosistema busca y muestra texto. No se ven las claves construidas en tiempo de ejecución, los wrappers de las funciones de búsqueda ni el texto que se asigna mediante variables.
- **Solo claves literales.** KEY001 comprueba las claves escritas como literales. KEY003 cuenta como uso cualquier literal, prefijo o miembro de Dart con el nombre de la clave y aun así informa de una clave cuyo uso no puede ver, por eso es un hallazgo info.
- **Interpolación en SwiftUI.** Xcode convierte `Text("\(count) books")` en la clave `%lld books` usando la información de tipos del compilador. GlobalLingo no la tiene, así que KEY002 omite los literales con interpolación o `%`.
- **Versión de CLDR.** Las categorías plurales proceden de los datos de CLDR del Node.js que ejecuta GlobalLingo (CLDR 49 en Node.js 26.12). Un CLDR más reciente puede añadir una categoría a un idioma.
- **Solo archivos.** GlobalLingo no compila, ejecuta ni cambia nada; solo escribe el informe o el baseline que le pidas.

## Documentación

Referencia de la API, reglas, configuración y guías: [muhittincamdali.github.io/GlobalLingo](https://muhittincamdali.github.io/GlobalLingo/).

## Guías

- [Ejecutar GlobalLingo en CI](docs/guides/ci.md)
- [Marcadores de posición y plurales en Apple, Flutter y JavaScript](docs/guides/placeholders-and-plurals.md)
- [La I turca](docs/guides/turkish-i.md)
- Referencia: [reglas](docs/rules.md) y [configuración](docs/configuration.md)

## Herramientas relacionadas

Otros proyectos revisan algunos de los mismos archivos; cuál te conviene depende de lo que uses:

- [xcstrings-lint](https://github.com/thatswiftguy/xcstrings-lint) es una GitHub Action para String Catalogs y archivos `.strings`, con un modo ratchet que bloquea solo los problemas que introduce un pull request y un comentario en el pull request.
- [i18n-check](https://github.com/lingualdev/i18n-check) valida los archivos de traducción JSON y YAML de apps de JavaScript (ICU e i18next), incluidas las claves sin usar y sin definir mediante i18next-parser.
- [BartyCrouch](https://github.com/FlineDev/BartyCrouch) mantiene los archivos `.strings` sincronizados con el código Swift y los storyboards, puede traducir mediante una API y revisa las claves duplicadas y los valores vacíos.
- [StringsLint](https://github.com/dral3x/StringsLint) informa de las claves `.strings` que faltan o no se usan en proyectos de Swift y Objective-C.
- El editor de String Catalog de Xcode muestra el progreso de traducción de cada idioma, y `gen-l10n` de Flutter enumera los mensajes sin traducir con `untranslated-messages-file`.

GlobalLingo lee los cuatro formatos en una sola ejecución y añade tipos de marcadores de posición, formas plurales de CLDR, las comprobaciones del código y las reglas de la I turca. Las descripciones anteriores proceden del README de cada proyecto del 28 de octubre de 2026.

## Requisitos

| Herramientas | Versión mínima |
| ------------ | -------------- |
| Node.js      | 22.12          |

GlobalLingo no necesita Xcode, Flutter ni React Native: lee archivos, así que también funciona en Linux. CI ejecuta las pruebas en Node.js 22 y 24 (Linux); en local, las 192 pasan en Node.js 22.23, 24.22 y 26.12 en un Mac (Apple silicon).

## Arquitectura

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

- Cada hallazgo es un ID de regla, una gravedad (la predeterminada de la regla o la de la configuración), un archivo y una línea, un mensaje, la corrección de la regla para el ecosistema del hallazgo, un enlace a la documentación y una huella para los baselines.
- Cada lector se detiene en un límite de anidamiento y cada patrón está acotado, de modo que archivos manipulados no pueden agotar la pila ni el tiempo; las pruebas le dan 100,000 niveles de JSON y archivos de código de 2 MB.
- La CLI (`src/cli/`) solo analiza los argumentos, elige colores y anchos y establece el código de salida.

## Hoja de ruta

Consulta la tabla de [Estado](#estado): archivos YAML, `strings.xml` de Android, un wrapper de GitHub Action y comentarios para traductores están planificados. [CHANGELOG.md](CHANGELOG.md) enumera lo que cambió en cada versión.

## Preguntas frecuentes

**¿GlobalLingo cambia mis archivos?** No. Los lee y solo escribe el informe o el baseline que le pidas.

**¿Por qué el polaco necesita cuatro formas si el inglés tiene dos?** El polaco usa una forma para 1, otra para 2–4 (y 22–24, 32–34…), otra para 0 y 5–21 (y 25–31…), y una cuarta para las fracciones. CLDR registra estas reglas por idioma; [la guía de plurales](docs/guides/placeholders-and-plurals.md) incluye la tabla.

**Mi app no tiene traducción al turco. ¿Puede importar TRI001?** Sí. Tiene que ver con el idioma del dispositivo, no con el de la app: una clave pasada a minúsculas con `toLocaleLowerCase()` convierte `I` en `ı` en cualquier dispositivo en turco. [La I turca](docs/guides/turkish-i.md) lo muestra.

**Un hallazgo es incorrecto para mi proyecto. ¿Qué hago?** Baja la gravedad de la regla o desactívala en `.globallingo.json`, ignora la clave o la ruta, o marca la línea con `globallingo-ignore`, y abre un issue con el ejemplo más pequeño que lo muestre.

## Contribuir

Las contribuciones son bienvenidas: lee [CONTRIBUTING.md](CONTRIBUTING.md) y el [código de conducta](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md) antes de abrir un pull request, y informa de los problemas de seguridad como se describe en [SECURITY.md](SECURITY.md).

## Licencia

Publicado bajo la licencia MIT. Consulta [LICENSE](LICENSE).
