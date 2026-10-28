<!-- i18n-source: README.md@0c55770dc8c04ee1fabfd61d1e4bb1e66b9e8190 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/banner-light.svg" alt="GlobalLingo: Lints iOS, Flutter and React Native localization files and names the fix for each finding."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/GlobalLingo/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/GlobalLingo/actions/workflows/ci.yml/badge.svg" alt="État de la CI"></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-version-light.svg" alt="Dernière version: v1.0.0 · older Swift package"></picture></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/blob/master/package.json"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-language-light.svg" alt="Version du langage: Node.js 22.12+"></picture></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/blob/master/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-license-light.svg" alt="Licence: MIT"></picture></a>
</p>

<p align="center">
<a href="#démarrage-rapide"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-start-fr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-start-fr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-start-fr-light.svg" alt="Commencer"></picture></a>
<a href="https://muhittincamdali.github.io/GlobalLingo/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-docs-fr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-docs-fr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-docs-fr-light.svg" alt="Documentation"></picture></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/tree/master/docs/guides"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-guides-fr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-guides-fr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-guides-fr-light.svg" alt="Guides"></picture></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/tree/master/examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-examples-fr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-examples-fr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-examples-fr-light.svg" alt="Exemples"></picture></a>
</p>

> Ceci est une traduction du README anglais. En cas de différence, la version anglaise fait foi.

<!-- brand:end -->
GlobalLingo vérifie les fichiers de localisation d’une application iOS, Flutter ou React Native/Expo avant sa publication : Xcode String Catalogs, fichiers `.strings` et `.stringsdict`, fichiers ARB de Flutter et fichiers de traduction JSON. Il repère les traductions manquantes, vides ou obsolètes, les placeholders et les formes plurielles qui ne correspondent pas d’une langue à l’autre, les clés en double, les clés que le code recherche mais qu’aucun fichier ne définit, les textes d’interface écrits en dur et les pièges du I turc avec et sans point, et indique le correctif de chaque résultat. Il ne fait que lire des fichiers et n’a besoin que de Node.js.

<picture><source media="(prefers-color-scheme: dark)" srcset="docs/media/demo-flutter-dark.svg"><source media="(prefers-color-scheme: light)" srcset="docs/media/demo-flutter-light.svg"><img src="docs/media/demo-flutter-light.svg" alt="GlobalLingo exécuté sur une application Flutter : un placeholder renommé dans le fichier ARB allemand (FMT001, FMT002), du polonais sans les formes plurielles pour 2 à 4 et pour 5 ou plus (PLU001), un message inutilisé et un message manquant, du texte écrit en dur et toUpperCase sur du texte turc, chacun avec son correctif"></picture>

<sub>Enregistré avec la vraie CLI sur le <a href="fixtures/flutter-arb">fixture flutter-arb</a>, une application Flutter 3.47.5 (<code>npm run demo</code>). <code>flutter gen-l10n</code> accepte le fichier allemand, puis la compilation échoue ; voir <a href="docs/guides/placeholders-and-plurals.md">le guide</a>.</sub>

## Points forts

- **Quatre formats, un seul rapport.** String Catalogs, `.strings`/`.stringsdict`, ARB et JSON (i18next, i18n-js, react-intl/FormatJS) sont lus dans le même modèle et vérifiés avec les mêmes 19 règles : un monorepo qui contient une application native, une application Flutter et une application Expo obtient donc un seul rapport.
- **Des placeholders lus comme le fait chaque environnement d’exécution.** Les spécificateurs de format sont vérifiés par position et par type (`%@` contre `%lld`, `%d` contre `%lld`, substitutions `%#@name@`), les placeholders ICU et i18next par nom, pour chaque forme plurielle.
- **Des formes plurielles issues de CLDR.** Chaque locale est vérifiée pour les catégories que sa langue utilise (`few` et `many` en polonais, les six en arabe), avec des exemples de nombres dans le message.
- **Le code aussi.** Les clés que le code recherche mais qu’aucun catalogue ne définit, les clés qu’aucun code ne mentionne, les littéraux SwiftUI absents du String Catalog, le texte écrit en dur dans UIKit, Flutter et React Native, et les changements de casse qui échouent sur les appareils en turc et en azéri.
- **Conçu pour la CI.** Codes de sortie 0/1/2, `--fail-on`, un fichier baseline pour que seuls les nouveaux résultats fassent échouer l’exécution, et une sortie au format texte, Markdown, JSON, SARIF (code scanning) ou GitHub annotations.
- **Borné sur n’importe quel dépôt.** Aucune dépendance d’exécution, aucun accès réseau, les liens symboliques ne sont pas suivis, la taille des fichiers, la profondeur et le nombre de résultats sont limités, et le texte du projet n’atteint jamais le terminal avec des caractères de contrôle.

## Démarrage rapide

Il vous faut [Node.js](https://nodejs.org/) 22.12 ou plus récent (`node --version` affiche la version ; sur un Mac, `brew install node` l’installe). Rien d’autre : ni Xcode, ni chaîne d’outils Flutter ou React Native.

**1. Ouvrez un terminal dans le dossier de votre application**, celui qui contient le `.xcodeproj`, le `pubspec.yaml` ou le `package.json` :

```sh
cd path/to/YourApp
```

**2. Lancez GlobalLingo :**

```sh
npx @mcamdali/globallingo
```

Le paquet npm s’appelle `@mcamdali/globallingo` ; la commande qu’il installe est `globallingo`.

**3. Lisez les résultats.** Chacun indique sa règle, le fichier et la ligne, ce qui ne va pas et comment le corriger, avec un lien vers la documentation de la règle. Les résultats **ERROR** font passer le code de sortie à 1 ; la dernière ligne les compte. Pour que les avertissements fassent aussi échouer l’exécution, ajoutez `--fail-on warning`.

## Ce que GlobalLingo vérifie

| Règle  | Gravité | Résultat                                                                                       |
| ------ | ------- | ---------------------------------------------------------------------------------------------- |
| MIS001 | error   | Une traduction est manquante (ou une entrée du String Catalog est encore à l’état "new")       |
| MIS002 | error   | Une traduction est vide                                                                        |
| MIS003 | warning | Une traduction du String Catalog doit être relue                                               |
| MIS004 | info    | Une traduction est identique au texte source                                                   |
| STA001 | warning | Xcode marque la clé comme obsolète (stale)                                                     |
| STA002 | warning | Une traduction contient une clé que la langue source n’a pas                                   |
| FMT001 | error   | Un placeholder que la source n’a pas, ou d’un autre type                                       |
| FMT002 | warning | Un placeholder de la source est omis                                                           |
| FMT003 | error   | Un fichier ou un message ne s’analyse pas (JSON, `.strings`, plist, ICU, séquences `%`)        |
| PLU001 | warning | Une forme plurielle dont la langue a besoin (CLDR) est manquante                               |
| PLU002 | error   | Un pluriel n’a pas de forme `other`                                                            |
| DUP001 | error   | Une clé apparaît deux fois dans un même fichier                                                |
| KEY001 | error   | Le code recherche une clé qu’aucun catalogue ne définit                                        |
| KEY002 | warning | Un littéral SwiftUI n’est pas dans le String Catalog                                           |
| KEY003 | info    | Aucun fichier source ne mentionne la clé                                                       |
| HCS001 | warning | Un texte affiché à l’utilisateur est écrit en dur                                              |
| TRI001 | warning | La casse d’une clé de recherche est modifiée selon la locale de l’appareil                     |
| TRI002 | warning | Une clé contient `İ` ou `ı`                                                                    |
| TRI003 | warning | La casse d’un texte traduit est modifiée sans locale dans une application qui propose le turc ou l’azéri |

[docs/rules.md](docs/rules.md) décrit chaque règle avec des exemples, le correctif par écosystème et les documents d’Apple, de Flutter, d’Unicode, d’ICU et des bibliothèques sur lesquels elle repose.

## Installation

Exécutez-le sans l’installer, comme ci-dessus, ou installez la commande `globallingo` :

```sh
npm i -g @mcamdali/globallingo
globallingo
```

Dans un projet JavaScript, `npm install --save-dev @mcamdali/globallingo` fixe une version et `npx globallingo` exécute cette copie. Chaque [GitHub release](https://github.com/muhittincamdali/GlobalLingo/releases) fournit aussi le paquet sous la forme `globallingo-<version>.tgz` avec un fichier `SHA256SUMS`, et le workflow de release ouvre une formule Homebrew pour `brew install muhittincamdali/tap/globallingo`.

À partir d’un clone :

```sh
git clone https://github.com/muhittincamdali/GlobalLingo.git
cd GlobalLingo && npm ci && npm run build
node dist/cli/main.js path/to/YourApp
```

## Utilisation

```text
globallingo [path] [options]
```

| Option                    | Ce qu’elle fait                                                                    |
| ------------------------- | ---------------------------------------------------------------------------------- |
| `path`                    | Le dossier de l’application ; par défaut, le dossier courant                       |
| `-f, --format <format>`   | `tty` (par défaut), `markdown`, `json`, `sarif` ou `github`                        |
| `-o, --output <file>`     | Écrit le rapport dans un fichier au lieu du terminal                               |
| `--fail-on <severity>`    | `error` (par défaut), `warning`, `info` ou `none` : ce qui fait passer le code de sortie à 1 |
| `-c, --config <file>`     | Fichier de configuration ; par défaut, `<path>/.globallingo.json` s’il existe      |
| `--source <locale>`       | La langue source, lorsque les fichiers ne l’indiquent pas                          |
| `--locales <list>`        | Ne vérifie que ces locales, p. ex. `de,tr,pl`                                      |
| `--baseline <file>`       | Les résultats de ce fichier sont signalés mais ne font pas échouer l’exécution     |
| `--write-baseline <file>` | Écrit tous les résultats de cette exécution dans un fichier baseline               |
| `--no-code`               | Ne vérifie que les fichiers de localisation, pas le code source                    |
| `--no-color`              | Texte brut même dans un terminal (`NO_COLOR` et `FORCE_COLOR` sont respectés)      |

Codes de sortie : `0` aucun résultat au niveau de `--fail-on` ou au-dessus, `1` des résultats à ce niveau ou au-dessus, `2` arguments ou paramètres incorrects, aucun fichier de localisation trouvé, ou erreur inattendue. Avec `--write-baseline`, le code est `0` une fois le fichier écrit. Un dossier sans fichiers de localisation est une erreur, afin qu’un mauvais chemin en CI ne passe pas en silence.

### L’exécuter en CI

[examples/github-actions/globallingo.yml](examples/github-actions/globallingo.yml) annote la pull request, écrit la couverture et les résultats dans le résumé du job, envoie le SARIF pour le code scanning et fait échouer le job en cas d’erreurs. [Exécuter GlobalLingo en CI](docs/guides/ci.md) explique chaque partie.

### Commencer avec une baseline

```sh
npx @mcamdali/globallingo --write-baseline .globallingo-baseline.json
npx @mcamdali/globallingo --baseline .globallingo-baseline.json
```

La première commande accepte les résultats d’aujourd’hui ; la seconde n’échoue que sur les nouveaux. Les empreintes ne contiennent pas de numéros de ligne : déplacer du code n’invalide donc pas le fichier.

### Configurer

Un fichier `.globallingo.json` dans le dossier de l’application définit la langue source, les locales requises, les chemins et les clés ignorés, ainsi qu’une gravité (ou `off`) par règle :

```json
{
  "locales": ["de", "pl", "tr"],
  "ignore": { "paths": ["**/__tests__/**"], "keys": ["legacy.*"] },
  "rules": { "HCS001": "error", "MIS004": "off" }
}
```

[docs/configuration.md](docs/configuration.md) liste chaque champ, ce que GlobalLingo trouve par lui-même, et les limites. Dans le code, une ligne qui se termine par `// globallingo-ignore` n’est pas signalée.

### Utiliser le rapport JSON ou l’API

```sh
npx @mcamdali/globallingo --format json > globallingo.json
```

Le rapport contient les catalogues avec la couverture par locale, et, pour chaque résultat, `rule`, `severity`, `file`, `line`, `key`, `locale`, `message`, `fix`, `docs` et `fingerprint` (`schemaVersion` 1). [examples/shell/errors-by-locale.sh](examples/shell/errors-by-locale.sh) compte les erreurs par locale avec `jq`. Les mêmes vérifications s’exécutent depuis JavaScript :

```js
import { render, scan } from '@mcamdali/globallingo';

const report = await scan('path/to/app', { locales: ['de', 'tr'] });
console.log(report.summary);
console.log(render(report, 'markdown'));
```

[examples/api/coverage.mjs](examples/api/coverage.mjs) affiche la couverture de chaque catalogue.

## Démo

Les enregistrements du terminal proviennent de la CLI exécutée sur les [fixtures](fixtures/README.md), de petites applications réalisées avec chaque chaîne d’outils :

| Projet                                                                  | Enregistrement                                                                         |
| ----------------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| Application Flutter 3.47.5 avec des fichiers ARB                        | en haut de cette page                                                                  |
| Application Expo SDK 58 avec i18next                                    | [clair](docs/media/demo-expo-light.svg) · [sombre](docs/media/demo-expo-dark.svg)      |
| Paquet SwiftUI dont Xcode 27.1 a extrait les clés du String Catalog     | [clair](docs/media/demo-swiftui-light.svg) · [sombre](docs/media/demo-swiftui-dark.svg) |
| Application UIKit avec `.strings` et `.stringsdict` (XcodeGen)          | [clair](docs/media/demo-uikit-light.svg) · [sombre](docs/media/demo-uikit-dark.svg)    |

Mesuré le 28 octobre 2026 sur un Mac (Apple silicon, M5 Max) avec Node.js 26.12, alors que d’autres tâches maintenaient la charge moyenne au-dessus de 40 : trois séries de 100 exécutions de `node dist/cli/main.js` sur les quatre fixtures, démarrage de Node.js compris. Les médianes des trois séries étaient de 0.12, 0.13 et 0.14 seconde ; l’exécution la plus lente a pris 0.54 seconde.

### Ce que voient les utilisateurs

Le fixture UIKit dans le simulateur iOS 27.0 (iPhone 17, compilé avec Xcode 27.1), en anglais à gauche et en turc à droite. Foundation affiche la clé elle-même lorsqu’une traduction est manquante (`archive.confirm.message` en turc, MIS001) et lorsqu’aucune table ne contient la clé (`archive.confirm.ok`, KEY001). `scripts/simulator-shots.sh` prend les deux captures d’écran.

<p align="center"><img src="docs/media/simulator/inbox-en.png" width="300" alt="L’application Inbox en anglais : l’alerte demande 'Archive all messages?' avec le texte du message, et le bouton affiche la clé brute archive.confirm.ok"> <img src="docs/media/simulator/inbox-tr.png" width="300" alt="L’application Inbox en turc : le titre de l’alerte est traduit, mais le message affiche la clé brute archive.confirm.message et le bouton la clé brute archive.confirm.ok"></p>

## État

| Fonctionnalité                                                                                                             | État        |
| -------------------------------------------------------------------------------------------------------------------------- | ----------- |
| String Catalogs, `.strings` (UTF-8, UTF-16, XML) et `.stringsdict`, ARB avec l10n.yaml, i18next, i18n-js et JSON ICU        | fonctionne  |
| 19 règles : traductions, clés obsolètes et orphelines, placeholders, pluriels, doublons, clés dans le code, texte écrit en dur, I turc | fonctionne  |
| Sortie terminal, Markdown, JSON, SARIF et GitHub annotations ; `--fail-on` ; baselines ; `.globallingo.json`                | fonctionne  |
| API programmatique avec déclarations de types                                                                              | fonctionne  |
| Fichiers de traduction YAML (i18n à la Rails, YAML i18next)                                                                | prévu       |
| `strings.xml` d’Android pour Android natif et la partie Android des applications multiplateformes                          | prévu       |
| Un wrapper GitHub Action (`uses: muhittincamdali/GlobalLingo@v2`) et des commentaires de pull request                      | prévu       |
| Commentaires pour les traducteurs : signaler les clés sans commentaire ni description `@key`                               | prévu       |

## Limites

- **Des motifs, pas un compilateur.** Les règles du code lisent Swift, Objective-C, Dart et JavaScript/TypeScript avec les commentaires effacés, et cherchent les façons courantes dont chaque écosystème recherche et affiche du texte. Les clés construites à l’exécution, les wrappers autour des fonctions de recherche et le texte défini via des variables ne sont pas vus.
- **Uniquement des clés littérales.** KEY001 vérifie les clés écrites sous forme de littéraux. KEY003 compte comme une utilisation tout littéral, préfixe ou membre Dart portant le nom de la clé, et signale quand même une clé dont il ne peut pas voir l’utilisation, ce qui en fait un résultat info.
- **Interpolation SwiftUI.** Xcode transforme `Text("\(count) books")` en la clé `%lld books` grâce aux informations de type du compilateur. GlobalLingo ne les a pas ; KEY002 ignore donc les littéraux avec interpolation ou `%`.
- **Version de CLDR.** Les catégories plurielles proviennent des données CLDR du Node.js qui exécute GlobalLingo (CLDR 49 dans Node.js 26.12). Un CLDR plus récent peut ajouter une catégorie à une langue.
- **Uniquement des fichiers.** GlobalLingo ne compile, n’exécute et ne modifie rien ; il n’écrit que le rapport ou la baseline que vous demandez.

## Documentation

Référence de l’API, règles, configuration et guides : [muhittincamdali.github.io/GlobalLingo](https://muhittincamdali.github.io/GlobalLingo/).

## Guides

- [Exécuter GlobalLingo en CI](docs/guides/ci.md)
- [Placeholders et pluriels chez Apple, Flutter et JavaScript](docs/guides/placeholders-and-plurals.md)
- [Le I turc](docs/guides/turkish-i.md)
- Référence : [règles](docs/rules.md) et [configuration](docs/configuration.md)

## Outils apparentés

D’autres projets vérifient une partie des mêmes fichiers ; le bon choix dépend de ce que vous utilisez :

- [xcstrings-lint](https://github.com/thatswiftguy/xcstrings-lint) est une GitHub Action pour les String Catalogs et les fichiers `.strings`, avec un mode ratchet qui ne bloque que les problèmes qu’introduit une pull request et un commentaire de pull request.
- [i18n-check](https://github.com/lingualdev/i18n-check) valide les fichiers de traduction JSON et YAML des applications JavaScript (ICU et i18next), y compris les clés inutilisées et non définies via i18next-parser.
- [BartyCrouch](https://github.com/FlineDev/BartyCrouch) synchronise les fichiers `.strings` avec le code Swift et les storyboards, peut traduire via une API, et signale les clés en double et les valeurs vides.
- [StringsLint](https://github.com/dral3x/StringsLint) signale les clés `.strings` manquantes et inutilisées dans les projets Swift et Objective-C.
- L’éditeur de String Catalog de Xcode affiche l’avancement de la traduction de chaque langue, et `gen-l10n` de Flutter liste les messages non traduits avec `untranslated-messages-file`.

GlobalLingo lit les quatre formats en une seule exécution et ajoute les types de placeholders, les formes plurielles CLDR, les vérifications du code et les règles du I turc. Les descriptions ci-dessus proviennent du README de chaque projet au 28 octobre 2026.

## Prérequis

| Chaîne d’outils | Version minimale |
| --------------- | ---------------- |
| Node.js         | 22.12            |

GlobalLingo n’a besoin ni de Xcode, ni de Flutter, ni de React Native : il lit des fichiers, il fonctionne donc aussi sous Linux. La CI exécute les tests sur Node.js 22 et 24 (Linux) ; en local, les 192 passent sur Node.js 22.23, 24.22 et 26.12 sur un Mac (Apple silicon).

## Architecture

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

- Chaque résultat se compose d’un identifiant de règle, d’une gravité (celle par défaut de la règle, ou celle de la configuration), d’un fichier et d’une ligne, d’un message, du correctif de la règle pour l’écosystème du résultat, d’un lien vers la documentation et d’une empreinte pour les baselines.
- Chaque lecteur s’arrête à une limite d’imbrication et prend un temps proportionnel à son entrée ; des fichiers piégés ne peuvent donc pas épuiser la pile ni le temps. Les tests lui fournissent du JSON sur 100 000 niveaux et mesurent comment le temps de catalogues, réglages et fichiers source piégés augmente de 128 Ko à 2 Mo.
- La CLI (`src/cli/`) se contente d’analyser les arguments, de choisir les couleurs et les largeurs et de définir le code de sortie.

## Feuille de route

Voir le tableau [État](#état) : les fichiers YAML, le `strings.xml` d’Android, un wrapper GitHub Action et les commentaires pour les traducteurs sont prévus. [CHANGELOG.md](CHANGELOG.md) liste ce que chaque version a changé.

## FAQ

**GlobalLingo modifie-t-il mes fichiers ?** Non. Il les lit et n’écrit que le rapport ou la baseline que vous demandez.

**Pourquoi le polonais a-t-il besoin de quatre formes alors que l’anglais en a deux ?** Le polonais utilise une forme pour 1, une autre pour 2–4 (et 22–24, 32–34…), une autre pour 0 et 5–21 (et 25–31…), et une quatrième pour les fractions. CLDR enregistre ces règles par langue ; [le guide des pluriels](docs/guides/placeholders-and-plurals.md) contient le tableau.

**Mon application n’a pas de traduction turque. TRI001 peut-il quand même compter ?** Oui. Il s’agit de la langue de l’appareil, pas de celle de l’application : une clé passée en minuscules avec `toLocaleLowerCase()` transforme `I` en `ı` sur n’importe quel appareil turc. [Le I turc](docs/guides/turkish-i.md) le montre.

**Un résultat est faux pour mon projet. Que faire ?** Baissez la gravité de la règle ou désactivez-la dans `.globallingo.json`, ignorez la clé ou le chemin, ou marquez la ligne avec `globallingo-ignore`, et ouvrez une issue avec le plus petit exemple qui le montre.

## Contribuer

Les contributions sont les bienvenues : lisez [CONTRIBUTING.md](CONTRIBUTING.md) et le [code de conduite](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md) avant d’ouvrir une pull request, et signalez les problèmes de sécurité comme décrit dans [SECURITY.md](SECURITY.md).

## Licence

Publié sous licence MIT. Voir [LICENSE](LICENSE).
