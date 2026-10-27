<!-- i18n-source: README.md@c66ef6076bb5586c3e05781155e2bfca9aa9e2be status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/banner-light.svg" alt="GlobalLingo: Lints iOS, Flutter and React Native localization files and names the fix for each finding."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/GlobalLingo/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/GlobalLingo/actions/workflows/ci.yml/badge.svg" alt="Status da CI"></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-version-light.svg" alt="Versão mais recente: v1.0.0 · older Swift package"></picture></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/blob/master/package.json"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-language-light.svg" alt="Versão da linguagem: Node.js 22.12+"></picture></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/blob/master/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-license-light.svg" alt="Licença: MIT"></picture></a>
</p>

<p align="center">
<a href="#início-rápido"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-start-pt-BR-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-start-pt-BR-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-start-pt-BR-light.svg" alt="Começar"></picture></a>
<a href="https://muhittincamdali.github.io/GlobalLingo/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-docs-pt-BR-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-docs-pt-BR-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-docs-pt-BR-light.svg" alt="Documentação"></picture></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/tree/master/docs/guides"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-guides-pt-BR-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-guides-pt-BR-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-guides-pt-BR-light.svg" alt="Guias"></picture></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/tree/master/examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-examples-pt-BR-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-examples-pt-BR-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-examples-pt-BR-light.svg" alt="Exemplos"></picture></a>
</p>

> Esta é uma tradução do README em inglês. Se houver diferença, vale a versão em inglês.

<!-- brand:end -->
O GlobalLingo verifica os arquivos de localização de um app iOS, Flutter ou React Native/Expo antes de ele ser publicado: Xcode String Catalogs, arquivos `.strings` e `.stringsdict`, arquivos ARB do Flutter e arquivos de tradução JSON. Ele encontra traduções ausentes, vazias e desatualizadas, placeholders e formas plurais que não correspondem entre os idiomas, chaves duplicadas, chaves que o código procura mas nenhum arquivo define, textos de interface escritos diretamente no código e as armadilhas do I turco com e sem ponto, e indica a correção de cada achado. Ele apenas lê arquivos e não precisa de nada além do Node.js.

<picture><source media="(prefers-color-scheme: dark)" srcset="docs/media/demo-flutter-dark.svg"><source media="(prefers-color-scheme: light)" srcset="docs/media/demo-flutter-light.svg"><img src="docs/media/demo-flutter-light.svg" alt="O GlobalLingo executado em um app Flutter: um placeholder renomeado no arquivo ARB em alemão (FMT001, FMT002), polonês sem as formas plurais para 2 a 4 e para 5 ou mais (PLU001), uma mensagem sem uso e outra ausente, texto escrito diretamente no código e toUpperCase em texto turco, cada um com sua correção"></picture>

<sub>Gravado com a CLI real no <a href="fixtures/flutter-arb">fixture flutter-arb</a>, um app Flutter 3.47.5 (<code>npm run demo</code>). O <code>flutter gen-l10n</code> aceita o arquivo em alemão e depois o build falha; veja <a href="docs/guides/placeholders-and-plurals.md">o guia</a>.</sub>

## Destaques

- **Quatro formatos, um único relatório.** String Catalogs, `.strings`/`.stringsdict`, ARB e JSON (i18next, i18n-js, react-intl/FormatJS) são lidos no mesmo modelo e verificados com as mesmas 19 regras; assim, um monorepo com um app nativo, um app Flutter e um app Expo recebe um único relatório.
- **Placeholders do jeito que cada ambiente de execução os lê.** Os especificadores de formato são verificados por posição e tipo (`%@` contra `%lld`, `%d` contra `%lld`, substituições `%#@name@`), e os placeholders do ICU e do i18next por nome, em cada forma plural.
- **Formas plurais do CLDR.** Cada localidade é verificada com as categorias que o seu idioma usa (`few` e `many` no polonês, todas as seis no árabe), com números de exemplo na mensagem.
- **O código também.** Chaves que o código procura mas nenhum catálogo define, chaves que nenhum código menciona, literais do SwiftUI ausentes do String Catalog, texto escrito diretamente no código do UIKit, do Flutter e do React Native, e conversões entre maiúsculas e minúsculas que falham em dispositivos em turco e azerbaijano.
- **Feito para CI.** Códigos de saída 0/1/2, `--fail-on`, um arquivo baseline para que apenas os novos achados falhem e saída em texto, Markdown, JSON, SARIF (code scanning) ou GitHub annotations.
- **Com limites em qualquer repositório.** Sem dependências em tempo de execução, sem rede, links simbólicos não são seguidos, há limites para o tamanho dos arquivos, a profundidade e o número de achados, e o texto do projeto nunca chega ao terminal com caracteres de controle.

## Início rápido

Você precisa do [Node.js](https://nodejs.org/) 22.12 ou posterior (`node --version` mostra a versão; em um Mac, `brew install node` o instala). Nada mais: nem Xcode, nem a toolchain do Flutter ou do React Native.

**1. Abra um terminal na pasta do seu app**, a que contém o `.xcodeproj`, o `pubspec.yaml` ou o `package.json`:

```sh
cd path/to/YourApp
```

**2. Execute o GlobalLingo:**

```sh
npx @mcamdali/globallingo
```

O pacote npm é `@mcamdali/globallingo`; o comando que ele instala é `globallingo`.

**3. Leia os achados.** Cada um indica a regra, o arquivo e a linha, o que está errado e como corrigir, com um link para a documentação da regra. Os achados **ERROR** fazem o código de saída ser 1; a última linha os conta. Para falhar também com avisos, adicione `--fail-on warning`.

## O que o GlobalLingo verifica

| Regra  | Gravidade | Achado                                                                                         |
| ------ | --------- | ---------------------------------------------------------------------------------------------- |
| MIS001 | error     | Uma tradução está ausente (ou uma entrada do String Catalog ainda está no estado "new")        |
| MIS002 | error     | Uma tradução está vazia                                                                        |
| MIS003 | warning   | Uma tradução do String Catalog precisa de revisão                                              |
| MIS004 | info      | Uma tradução é igual ao texto de origem                                                        |
| STA001 | warning   | O Xcode marca a chave como desatualizada (stale)                                               |
| STA002 | warning   | Uma tradução tem uma chave que o idioma de origem não tem                                      |
| FMT001 | error     | Um placeholder que a origem não tem, ou de outro tipo                                          |
| FMT002 | warning   | Um placeholder da origem foi omitido                                                           |
| FMT003 | error     | Um arquivo ou mensagem não pode ser analisado (JSON, `.strings`, plist, ICU, sequências `%`)   |
| PLU001 | warning   | Falta uma forma plural de que o idioma precisa (CLDR)                                          |
| PLU002 | error     | Um plural não tem a forma `other`                                                              |
| DUP001 | error     | Uma chave aparece duas vezes em um arquivo                                                     |
| KEY001 | error     | O código procura uma chave que nenhum catálogo define                                          |
| KEY002 | warning   | Um literal do SwiftUI não está no String Catalog                                               |
| KEY003 | info      | Nenhum arquivo de código-fonte menciona a chave                                                |
| HCS001 | warning   | O texto exibido ao usuário está escrito diretamente no código                                  |
| TRI001 | warning   | Uma chave de busca tem as maiúsculas/minúsculas alteradas conforme a localidade do dispositivo |
| TRI002 | warning   | Uma chave contém `İ` ou `ı`                                                                    |
| TRI003 | warning   | O texto traduzido tem as maiúsculas/minúsculas alteradas sem a localidade, em um app que inclui turco ou azerbaijano |

O [docs/rules.md](docs/rules.md) descreve cada regra com exemplos, a correção para cada ecossistema e os documentos da Apple, do Flutter, do Unicode, do ICU e das bibliotecas em que ela se baseia.

## Instalação

Execute sem instalar, como acima, ou instale o comando `globallingo`:

```sh
npm i -g @mcamdali/globallingo
globallingo
```

Em um projeto JavaScript, `npm install --save-dev @mcamdali/globallingo` fixa uma versão e `npx globallingo` executa essa cópia. Cada [GitHub release](https://github.com/muhittincamdali/GlobalLingo/releases) também traz o pacote como `globallingo-<version>.tgz` com um arquivo `SHA256SUMS`, e o workflow de release abre uma fórmula do Homebrew para `brew install muhittincamdali/tap/globallingo`.

A partir de um clone:

```sh
git clone https://github.com/muhittincamdali/GlobalLingo.git
cd GlobalLingo && npm ci && npm run build
node dist/cli/main.js path/to/YourApp
```

## Uso

```text
globallingo [path] [options]
```

| Opção                     | O que faz                                                                          |
| ------------------------- | ---------------------------------------------------------------------------------- |
| `path`                    | A pasta do app; o padrão é a pasta atual                                           |
| `-f, --format <format>`   | `tty` (padrão), `markdown`, `json`, `sarif` ou `github`                            |
| `-o, --output <file>`     | Grava o relatório em um arquivo em vez de no terminal                              |
| `--fail-on <severity>`    | `error` (padrão), `warning`, `info` ou `none`: o que faz o código de saída ser 1   |
| `-c, --config <file>`     | Arquivo de configurações; o padrão é `<path>/.globallingo.json`, quando existe     |
| `--source <locale>`       | O idioma de origem, quando os arquivos não o indicam                               |
| `--locales <list>`        | Verifica apenas estas localidades, p. ex. `de,tr,pl`                               |
| `--baseline <file>`       | Os achados deste arquivo são relatados, mas não fazem a execução falhar            |
| `--write-baseline <file>` | Grava todos os achados desta execução em um arquivo baseline                       |
| `--no-code`               | Verifica apenas os arquivos de localização, não o código-fonte                     |
| `--no-color`              | Texto simples mesmo em um terminal (`NO_COLOR` e `FORCE_COLOR` são respeitados)    |

Códigos de saída: `0` nenhum achado no nível de `--fail-on` ou acima, `1` achados nesse nível ou acima, `2` argumentos ou configurações inválidos, nenhum arquivo de localização encontrado ou um erro inesperado. Uma pasta sem arquivos de localização é um erro, para que um caminho errado no CI não passe em silêncio.

### Execute no CI

O [examples/github-actions/globallingo.yml](examples/github-actions/globallingo.yml) anota o pull request, grava a cobertura e os achados no resumo do job, envia o SARIF para o code scanning e faz o job falhar em caso de erros. [Executar o GlobalLingo no CI](docs/guides/ci.md) explica cada parte.

### Comece com um baseline

```sh
npx @mcamdali/globallingo --write-baseline .globallingo-baseline.json
npx @mcamdali/globallingo --baseline .globallingo-baseline.json
```

O primeiro comando aceita os achados de hoje; o segundo falha apenas nos novos. As impressões digitais não incluem números de linha, então mover o código não invalida o arquivo.

### Configure

Um `.globallingo.json` na pasta do app define o idioma de origem, as localidades obrigatórias, os caminhos e as chaves ignorados e uma gravidade (ou `off`) por regra:

```json
{
  "locales": ["de", "pl", "tr"],
  "ignore": { "paths": ["**/__tests__/**"], "keys": ["legacy.*"] },
  "rules": { "HCS001": "error", "MIS004": "off" }
}
```

O [docs/configuration.md](docs/configuration.md) lista cada campo, o que o GlobalLingo encontra sozinho e os limites. No código, uma linha que termina em `// globallingo-ignore` não é relatada.

### Use o relatório JSON ou a API

```sh
npx @mcamdali/globallingo --format json > globallingo.json
```

O relatório traz os catálogos com a cobertura por localidade e, de cada achado, `rule`, `severity`, `file`, `line`, `key`, `locale`, `message`, `fix`, `docs` e `fingerprint` (`schemaVersion` 1). O [examples/shell/errors-by-locale.sh](examples/shell/errors-by-locale.sh) conta os erros por localidade com `jq`. As mesmas verificações rodam a partir do JavaScript:

```js
import { render, scan } from '@mcamdali/globallingo';

const report = await scan('path/to/app', { locales: ['de', 'tr'] });
console.log(report.summary);
console.log(render(report, 'markdown'));
```

O [examples/api/coverage.mjs](examples/api/coverage.mjs) exibe a cobertura de cada catálogo.

## Demonstração

As gravações do terminal vêm da CLI executada nos [fixtures](fixtures/README.md), pequenos apps feitos com cada toolchain:

| Projeto                                                                 | Gravação                                                                               |
| ----------------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| App Flutter 3.47.5 com arquivos ARB                                     | no topo desta página                                                                   |
| App Expo SDK 58 com i18next                                             | [claro](docs/media/demo-expo-light.svg) · [escuro](docs/media/demo-expo-dark.svg)      |
| Pacote SwiftUI cujas chaves do String Catalog o Xcode 27.1 extraiu      | [claro](docs/media/demo-swiftui-light.svg) · [escuro](docs/media/demo-swiftui-dark.svg) |
| App UIKit com `.strings` e `.stringsdict` (XcodeGen)                    | [claro](docs/media/demo-uikit-light.svg) · [escuro](docs/media/demo-uikit-dark.svg)    |

Medido em 28 de outubro de 2026 em um Mac (Apple silicon, M5 Max) com Node.js 26.12, enquanto outros processos mantinham a carga média acima de 40: três séries de 100 execuções de `node dist/cli/main.js` nos quatro fixtures, incluindo a inicialização do Node.js. As medianas das três séries foram 0.12, 0.13 e 0.14 segundo; a execução mais lenta levou 0.54 segundo.

### O que os usuários veem

O fixture UIKit no simulador do iOS 27.0 (iPhone 17, compilado com o Xcode 27.1), com inglês à esquerda e turco à direita. O Foundation mostra a própria chave quando falta uma tradução (`archive.confirm.message` em turco, MIS001) e quando nenhuma tabela tem a chave (`archive.confirm.ok`, KEY001). O `scripts/simulator-shots.sh` tira as duas capturas de tela.

<p align="center"><img src="docs/media/simulator/inbox-en.png" width="300" alt="O app Inbox em inglês: o alerta pergunta 'Archive all messages?' com o texto da mensagem, e o botão mostra a chave bruta archive.confirm.ok"> <img src="docs/media/simulator/inbox-tr.png" width="300" alt="O app Inbox em turco: o título do alerta está traduzido, mas a mensagem mostra a chave bruta archive.confirm.message e o botão a chave bruta archive.confirm.ok"></p>

## Status

| Recurso                                                                                                                    | Status      |
| -------------------------------------------------------------------------------------------------------------------------- | ----------- |
| String Catalogs, `.strings` (UTF-8, UTF-16, XML) e `.stringsdict`, ARB com l10n.yaml, i18next, i18n-js e JSON do ICU        | funciona    |
| 19 regras: traduções, chaves desatualizadas e órfãs, placeholders, plurais, duplicatas, chaves no código, texto escrito diretamente no código, I turco | funciona    |
| Saída em terminal, Markdown, JSON, SARIF e GitHub annotations; `--fail-on`; baselines; `.globallingo.json`                   | funciona    |
| API programática com declarações de tipos                                                                                  | funciona    |
| Arquivos de tradução YAML (i18n no estilo Rails, YAML do i18next)                                                          | planejado   |
| `strings.xml` do Android para Android nativo e para o lado Android de apps multiplataforma                                 | planejado   |
| Um wrapper de GitHub Action (`uses: muhittincamdali/GlobalLingo@v2`) e comentários em pull requests                        | planejado   |
| Comentários para tradutores: relatar chaves sem comentário ou descrição `@key`                                             | planejado   |

## Limites

- **Padrões, não um compilador.** As regras de código leem Swift, Objective-C, Dart e JavaScript/TypeScript com os comentários em branco e procuram as formas comuns pelas quais cada ecossistema busca e exibe texto. Chaves montadas em tempo de execução, wrappers em torno das funções de busca e texto definido por meio de variáveis não são vistos.
- **Somente chaves literais.** O KEY001 verifica chaves escritas como literais. O KEY003 conta como uso qualquer literal, prefixo ou membro Dart com o nome da chave e ainda relata uma chave cujo uso não consegue ver, por isso é um achado info.
- **Interpolação no SwiftUI.** O Xcode transforma `Text("\(count) books")` na chave `%lld books` usando as informações de tipo do compilador. O GlobalLingo não as tem, então o KEY002 ignora literais com interpolação ou `%`.
- **Versão do CLDR.** As categorias plurais vêm dos dados do CLDR do Node.js que executa o GlobalLingo (CLDR 49 no Node.js 26.12). Um CLDR mais novo pode acrescentar uma categoria a um idioma.
- **Somente arquivos.** O GlobalLingo não compila, não executa nem altera nada; ele grava apenas o relatório ou o baseline que você pedir.

## Documentação

Referência da API, regras, configuração e guias: [muhittincamdali.github.io/GlobalLingo](https://muhittincamdali.github.io/GlobalLingo/).

## Guias

- [Executar o GlobalLingo no CI](docs/guides/ci.md)
- [Placeholders e plurais na Apple, no Flutter e no JavaScript](docs/guides/placeholders-and-plurals.md)
- [O I turco](docs/guides/turkish-i.md)
- Referência: [regras](docs/rules.md) e [configuração](docs/configuration.md)

## Ferramentas relacionadas

Outros projetos verificam alguns dos mesmos arquivos; qual deles serve depende do que você usa:

- O [xcstrings-lint](https://github.com/thatswiftguy/xcstrings-lint) é uma GitHub Action para String Catalogs e arquivos `.strings`, com um modo ratchet que bloqueia apenas os problemas que um pull request introduz e um comentário no pull request.
- O [i18n-check](https://github.com/lingualdev/i18n-check) valida arquivos de tradução JSON e YAML de apps JavaScript (ICU e i18next), incluindo chaves sem uso e indefinidas por meio do i18next-parser.
- O [BartyCrouch](https://github.com/FlineDev/BartyCrouch) mantém os arquivos `.strings` sincronizados com o código Swift e os storyboards, pode traduzir por meio de uma API e verifica chaves duplicadas e valores vazios.
- O [StringsLint](https://github.com/dral3x/StringsLint) relata chaves `.strings` ausentes e sem uso em projetos Swift e Objective-C.
- O editor de String Catalog do Xcode mostra o progresso da tradução de cada idioma, e o `gen-l10n` do Flutter lista as mensagens não traduzidas com `untranslated-messages-file`.

O GlobalLingo lê os quatro formatos em uma única execução e acrescenta tipos de placeholders, formas plurais do CLDR, as verificações do código e as regras do I turco. As descrições acima vêm do README de cada projeto em 28 de outubro de 2026.

## Requisitos

| Ferramentas | Versão mínima |
| ----------- | ------------- |
| Node.js     | 22.12         |

O GlobalLingo não precisa do Xcode, do Flutter nem do React Native: ele lê arquivos, portanto também roda no Linux. O CI executa os testes no Node.js 22 e 24 (Linux); localmente, todos os 192 passam no Node.js 22.23, 24.22 e 26.12 em um Mac (Apple silicon).

## Arquitetura

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

- Cada achado é um ID de regra, uma gravidade (o padrão da regra ou o da configuração), um arquivo e uma linha, uma mensagem, a correção da regra para o ecossistema do achado, um link para a documentação e uma impressão digital para os baselines.
- Cada leitor para em um limite de aninhamento e cada padrão é limitado, de modo que arquivos forjados não consigam esgotar a pilha nem o tempo; os testes alimentam o leitor com 100,000 níveis de JSON e arquivos de código-fonte de 2 MB.
- A CLI (`src/cli/`) apenas analisa os argumentos, escolhe cores e larguras e define o código de saída.

## Roteiro

Veja a tabela de [Status](#status): arquivos YAML, o `strings.xml` do Android, um wrapper de GitHub Action e comentários para tradutores estão planejados. O [CHANGELOG.md](CHANGELOG.md) lista o que cada versão mudou.

## Perguntas frequentes

**O GlobalLingo altera meus arquivos?** Não. Ele os lê e grava apenas o relatório ou o baseline que você pedir.

**Por que o polonês precisa de quatro formas se o inglês tem duas?** O polonês usa uma forma para 1, outra para 2–4 (e 22–24, 32–34…), outra para 0 e 5–21 (e 25–31…) e uma quarta para frações. O CLDR registra essas regras por idioma; [o guia de plurais](docs/guides/placeholders-and-plurals.md) traz a tabela.

**Meu app não tem tradução para turco. O TRI001 ainda pode importar?** Sim. Ele trata do idioma do dispositivo, não do app: uma chave convertida para minúsculas com `toLocaleLowerCase()` transforma `I` em `ı` em qualquer dispositivo em turco. [O I turco](docs/guides/turkish-i.md) mostra isso.

**Um achado está errado para o meu projeto. O que faço?** Reduza a gravidade da regra ou desative-a no `.globallingo.json`, ignore a chave ou o caminho, ou marque a linha com `globallingo-ignore`, e abra um issue com o menor exemplo que o demonstre.

## Como contribuir

Contribuições são bem-vindas: leia o [CONTRIBUTING.md](CONTRIBUTING.md) e o [código de conduta](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md) antes de abrir um pull request e relate problemas de segurança conforme descrito no [SECURITY.md](SECURITY.md).

## Licença

Publicado sob a licença MIT. Veja [LICENSE](LICENSE).
