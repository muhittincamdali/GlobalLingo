<!-- i18n-source: README.md@98baa23022eb886d07765d7448fd2e72ab1913e1 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/banner-light.svg" alt="GlobalLingo: Lints iOS, Flutter and React Native localization files and names the fix for each finding."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/GlobalLingo/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/GlobalLingo/actions/workflows/ci.yml/badge.svg" alt="CI durumu"></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-version-light.svg" alt="Son sürüm: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/blob/master/package.json"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-language-light.svg" alt="Dil sürümü: Node.js 22.12+"></picture></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/blob/master/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/badge-license-light.svg" alt="Lisans: MIT"></picture></a>
</p>

<p align="center">
<a href="#hızlı-başlangıç"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-start-tr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-start-tr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-start-tr-light.svg" alt="Başlayın"></picture></a>
<a href="https://muhittincamdali.github.io/GlobalLingo/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-docs-tr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-docs-tr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-docs-tr-light.svg" alt="Dokümantasyon"></picture></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/tree/master/docs/guides"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-guides-tr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-guides-tr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-guides-tr-light.svg" alt="Rehberler"></picture></a>
<a href="https://github.com/muhittincamdali/GlobalLingo/tree/master/examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-examples-tr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-examples-tr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/GlobalLingo/master/.github/brand/button-examples-tr-light.svg" alt="Örnekler"></picture></a>
</p>

> Bu belge İngilizce README'nin çevirisidir. İkisi arasında fark varsa güncel olan İngilizce sürümdür.

<!-- brand:end -->
GlobalLingo, bir iOS, Flutter veya React Native/Expo uygulamasının yerelleştirme dosyalarını
yayına çıkmadan önce denetler: Xcode String Catalogs, `.strings` ve `.stringsdict` dosyaları,
Flutter ARB dosyaları ve JSON çeviri dosyaları. Eksik, boş ve güncelliğini yitirmiş çevirileri,
diller arasında birbiriyle uyuşmayan placeholder'ları ve çoğul biçimlerini, yinelenen anahtarları,
kodun aradığı ama hiçbir dosyada tanımlı olmayan anahtarları, koda gömülmüş arayüz metinlerini ve
Türkçedeki noktalı ve noktasız I tuzaklarını bulur; her bulgu için çözümü söyler. Yalnızca dosya
okur ve Node.js dışında hiçbir şeye ihtiyaç duymaz.

<picture><source media="(prefers-color-scheme: dark)" srcset="docs/media/demo-flutter-dark.svg"><source media="(prefers-color-scheme: light)" srcset="docs/media/demo-flutter-light.svg"><img src="docs/media/demo-flutter-light.svg" alt="GlobalLingo bir Flutter uygulamasında çalıştırıldı: Almanca ARB dosyasında adı değişmiş bir placeholder (FMT001, FMT002), 2 ile 4 ve 5 ya da daha fazlası için çoğul biçimleri olmayan Lehçe (PLU001), kullanılmayan ve eksik bir mesaj, koda gömülmüş metin ve Türkçe metinde toUpperCase; her biri çözümüyle birlikte"></picture>

<sub>Gerçek CLI ile <a href="fixtures/flutter-arb">flutter-arb fixture</a>'ı üzerinde kaydedildi;
bu, Flutter 3.47.5 ile yapılmış bir uygulamadır (<code>npm run demo</code>).
<code>flutter gen-l10n</code> Almanca dosyayı kabul eder, ardından derleme bozulur; bkz.
<a href="docs/guides/placeholders-and-plurals.md">rehber</a>.</sub>

## Öne çıkanlar

- **Dört biçim, tek rapor.** String Catalogs, `.strings`/`.stringsdict`, ARB ve JSON (i18next,
  i18n-js, react-intl/FormatJS) aynı modele okunur ve aynı 19 kuralla denetlenir; böylece yerel
  uygulama, Flutter uygulaması ve Expo uygulaması barındıran bir monorepo tek rapor alır.
- **Placeholder'lar, her çalışma zamanının okuduğu biçimde.** Biçim belirleyiciler konuma ve türe
  göre (`%@` ile `%lld`, `%d` ile `%lld`, `%#@name@` yerine koymaları), ICU ve i18next
  placeholder'ları ada göre, her çoğul biçimi için ayrı ayrı denetlenir.
- **CLDR'den çoğul biçimleri.** Her yerel ayar, dilinin kullandığı kategoriler için denetlenir
  (Lehçede `few` ve `many`, Arapçada altısı da); mesajda örnek sayılar verilir.
- **Kod da denetlenir.** Kodun aradığı ama hiçbir katalogda tanımlı olmayan anahtarlar, hiçbir
  kodda geçmeyen anahtarlar, String Catalog'da bulunmayan SwiftUI sabit metinleri, UIKit, Flutter
  ve React Native'deki sabit kodlanmış metinler ve Türkçe ile Azerice cihazlarda bozulan büyük/küçük
  harf dönüşümleri.
- **CI için tasarlandı.** 0/1/2 çıkış kodları, `--fail-on`, yalnızca yeni bulguların başarısızlık
  üretmesini sağlayan bir baseline dosyası ve çıktı olarak metin, Markdown, JSON, SARIF (code
  scanning) veya GitHub annotations.
- **Her depoda sınırlı.** Çalışma zamanı bağımlılığı yok, ağ erişimi yok, sembolik bağlantılar
  izlenmez; dosya boyutu, derinlik ve bulgu sayısı sınırlıdır ve projedeki metin terminale asla
  kontrol karakterleriyle ulaşmaz.

## Hızlı başlangıç

[Node.js](https://nodejs.org/) 22.12 veya üstü gerekir (`node --version` sürümü gösterir; Mac'te
`brew install node` kurar). Başka hiçbir şey gerekmez: Xcode, Flutter ya da React Native araç
zinciri de gerekmez.

**1. Uygulamanızın klasöründe bir terminal açın**; `.xcodeproj`, `pubspec.yaml` veya
`package.json` dosyasının bulunduğu klasör:

```sh
cd path/to/YourApp
```

**2. GlobalLingo'yu çalıştırın:**

```sh
npx @mcamdali/globallingo
```

npm paketinin adı `@mcamdali/globallingo`; kurduğu komut `globallingo`.

**3. Bulguları okuyun.** Her bulgu kuralını, dosyayı ve satırı, neyin yanlış olduğunu ve nasıl
düzeltileceğini, kuralın dokümantasyonuna bir bağlantıyla birlikte belirtir. **ERROR** bulguları
çıkış kodunu 1 yapar; son satır bunları sayar. Uyarılarda da başarısız olmak için
`--fail-on warning` ekleyin.

## GlobalLingo neleri denetler

| Kural  | Önem düzeyi | Bulgu                                                                                                       |
| ------ | ----------- | ----------------------------------------------------------------------------------------------------------- |
| MIS001 | error       | Bir çeviri eksik (veya bir String Catalog girdisi hâlâ "new" durumunda)                                     |
| MIS002 | error       | Bir çeviri boş                                                                                              |
| MIS003 | warning     | Bir String Catalog çevirisinin gözden geçirilmesi gerekiyor                                                 |
| MIS004 | info        | Bir çeviri kaynak metinle aynı                                                                              |
| STA001 | warning     | Xcode anahtarı güncelliğini yitirmiş (stale) olarak işaretlemiş                                             |
| STA002 | warning     | Bir çevirideki anahtar kaynak dilde yok                                                                     |
| FMT001 | error       | Kaynakta bulunmayan veya başka türden bir placeholder                                                       |
| FMT002 | warning     | Kaynaktaki bir placeholder atlanmış                                                                         |
| FMT003 | error       | Bir dosya ya da mesaj ayrıştırılamıyor (JSON, `.strings`, plist, ICU, `%` dizileri)                         |
| PLU001 | warning     | Dilin gerektirdiği (CLDR) bir çoğul biçimi eksik                                                            |
| PLU002 | error       | Bir çoğulda `other` biçimi yok                                                                              |
| DUP001 | error       | Bir anahtar aynı dosyada iki kez geçiyor                                                                    |
| KEY001 | error       | Kod, hiçbir katalogda tanımlı olmayan bir anahtarı arıyor                                                   |
| KEY002 | warning     | Bir SwiftUI sabit metni String Catalog'da yok                                                               |
| KEY003 | info        | Hiçbir kaynak dosya anahtardan söz etmiyor                                                                  |
| HCS001 | warning     | Kullanıcıya gösterilen metin koda gömülmüş                                                                  |
| TRI001 | warning     | Bir arama anahtarının büyük/küçük harfi cihaz yerel ayarına göre değiştiriliyor                             |
| TRI002 | warning     | Bir anahtar `İ` veya `ı` içeriyor                                                                           |
| TRI003 | warning     | Türkçe veya Azerice yayımlayan bir uygulamada çevrilmiş metnin büyük/küçük harfi yerel ayar verilmeden değiştiriliyor |

[docs/rules.md](docs/rules.md), her kuralı örneklerle, ekosisteme göre çözümüyle ve dayandığı
Apple, Flutter, Unicode, ICU ve kütüphane belgeleriyle anlatır.

## Kurulum

Yukarıdaki gibi kurmadan çalıştırın ya da `globallingo` komutunu kurun:

```sh
npm i -g @mcamdali/globallingo
globallingo
```

Bir JavaScript projesinde `npm install --save-dev @mcamdali/globallingo` sürümü sabitler ve
`npx globallingo` o kopyayı çalıştırır. Her
[GitHub release](https://github.com/muhittincamdali/GlobalLingo/releases) paketi ayrıca
`globallingo-<version>.tgz` olarak bir `SHA256SUMS` dosyasıyla birlikte sunar ve release iş akışı
`brew install muhittincamdali/tap/globallingo` için bir Homebrew formülü açar.

Bir klondan:

```sh
git clone https://github.com/muhittincamdali/GlobalLingo.git
cd GlobalLingo && npm ci && npm run build
node dist/cli/main.js path/to/YourApp
```

## Kullanım

```text
globallingo [path] [options]
```

| Seçenek                   | Ne yapar                                                                                     |
| ------------------------- | -------------------------------------------------------------------------------------------- |
| `path`                    | Uygulamanın klasörü; varsayılan geçerli klasördür                                            |
| `-f, --format <format>`   | `tty` (varsayılan), `markdown`, `json`, `sarif` veya `github`                                |
| `-o, --output <file>`     | Raporu terminal yerine bir dosyaya yazar                                                     |
| `--fail-on <severity>`    | `error` (varsayılan), `warning`, `info` veya `none`: çıkış kodunu neyin 1 yapacağı           |
| `-c, --config <file>`     | Ayar dosyası; varsayılan, varsa `<path>/.globallingo.json`                                   |
| `--source <locale>`       | Dosyalar belirtmiyorsa kaynak dil                                                            |
| `--locales <list>`        | Yalnızca bu yerel ayarları denetler, örn. `de,tr,pl`                                         |
| `--baseline <file>`       | Bu dosyadaki bulgular raporlanır ama çalıştırmayı başarısız kılmaz                           |
| `--write-baseline <file>` | Bu çalıştırmanın tüm bulgularını bir baseline dosyasına yazar                                |
| `--no-code`               | Yalnızca yerelleştirme dosyalarını denetler, kaynak kodu denetlemez                          |
| `--no-color`              | Terminalde bile düz metin (`NO_COLOR` ve `FORCE_COLOR` dikkate alınır)                       |

Çıkış kodları: `0` `--fail-on` düzeyinde veya üstünde bulgu yok, `1` bu düzeyde veya üstünde bulgu
var, `2` hatalı argümanlar ya da ayarlar, yerelleştirme dosyası bulunamadı veya beklenmeyen bir
hata. Yerelleştirme dosyası olmayan bir klasör hata sayılır; böylece CI'da yanlış bir yol sessizce
geçmez. `--write-baseline` ile dosya yazıldığında çıkış kodu `0` olur.

### CI'da çalıştırma

[examples/github-actions/globallingo.yml](examples/github-actions/globallingo.yml) pull request'i
işaretler, kapsamı ve bulguları iş özetine yazar, code scanning için SARIF yükler ve hata varsa işi
başarısız kılar. [GlobalLingo'yu CI'da çalıştırma](docs/guides/ci.md) her bölümü açıklar.

### Baseline ile başlama

```sh
npx @mcamdali/globallingo --write-baseline .globallingo-baseline.json
npx @mcamdali/globallingo --baseline .globallingo-baseline.json
```

İlk komut bugünkü bulguları kabul eder; ikincisi yalnızca yeni olanlarda başarısız olur. Parmak
izleri satır numarası içermez; bu yüzden kodu taşımak dosyayı geçersiz kılmaz.

### Yapılandırma

Uygulamanın klasöründeki bir `.globallingo.json`; kaynak dili, zorunlu yerel ayarları, yok sayılan
yolları ve anahtarları ve her kural için bir önem düzeyini (veya `off`) belirler:

```json
{
  "locales": ["de", "pl", "tr"],
  "ignore": { "paths": ["**/__tests__/**"], "keys": ["legacy.*"] },
  "rules": { "HCS001": "error", "MIS004": "off" }
}
```

[docs/configuration.md](docs/configuration.md) her alanı, GlobalLingo'nun kendi bulduklarını ve
sınırları listeler. Kodda `// globallingo-ignore` ile biten bir satır raporlanmaz.

### JSON raporunu veya API'yi kullanma

```sh
npx @mcamdali/globallingo --format json > globallingo.json
```

Raporda, yerel ayar başına kapsamla birlikte kataloglar ve her bulgunun `rule`, `severity`,
`file`, `line`, `key`, `locale`, `message`, `fix`, `docs` ve `fingerprint` alanları bulunur
(`schemaVersion` 1). [examples/shell/errors-by-locale.sh](examples/shell/errors-by-locale.sh),
`jq` ile yerel ayar başına hata sayısını hesaplar. Aynı denetimler JavaScript'ten de çalışır:

```js
import { render, scan } from '@mcamdali/globallingo';

const report = await scan('path/to/app', { locales: ['de', 'tr'] });
console.log(report.summary);
console.log(render(report, 'markdown'));
```

[examples/api/coverage.mjs](examples/api/coverage.mjs) her kataloğun kapsamını yazdırır.

## Demo

Terminal kayıtları, her araç zinciriyle yapılmış küçük uygulamalar olan
[fixture'lar](fixtures/README.md) üzerinde CLI'dan alınmıştır:

| Proje                                                                  | Kayıt                                                                                  |
| ---------------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| ARB dosyalı Flutter 3.47.5 uygulaması                                  | bu sayfanın başında                                                                    |
| i18next kullanan Expo SDK 58 uygulaması                                | [açık](docs/media/demo-expo-light.svg) · [koyu](docs/media/demo-expo-dark.svg)         |
| Xcode 27.1'in String Catalog anahtarlarını çıkardığı SwiftUI paketi    | [açık](docs/media/demo-swiftui-light.svg) · [koyu](docs/media/demo-swiftui-dark.svg)   |
| `.strings` ve `.stringsdict` kullanan UIKit uygulaması (XcodeGen)      | [açık](docs/media/demo-uikit-light.svg) · [koyu](docs/media/demo-uikit-dark.svg)       |

Ölçüm, 28 Ekim 2026'da bir Mac'te (Apple silicon, M5 Max) Node.js 26.12 ile, başka işler yük
ortalamasını 40'ın üzerinde tutarken yapıldı: dört fixture üzerinde `node dist/cli/main.js` için
üç set hâlinde 100'er çalıştırma; Node.js'in başlangıç süresi dahil. Üç setin medyanları 0.12, 0.13
ve 0.14 saniye oldu; en yavaş çalıştırma 0.54 saniye sürdü.

### Kullanıcıların gördüğü

iOS 27.0 simülatöründe (iPhone 17, Xcode 27.1 ile derlendi) UIKit fixture'ı; solda İngilizce,
sağda Türkçe. Foundation, çeviri eksik olduğunda (Türkçede `archive.confirm.message`, MIS001) ve
hiçbir tabloda anahtar bulunmadığında (`archive.confirm.ok`, KEY001) anahtarın kendisini gösterir.
`scripts/simulator-shots.sh` iki ekran görüntüsünü de alır.

<p align="center"><img src="docs/media/simulator/inbox-en.png" width="300" alt="Gelen kutusu uygulaması İngilizce: uyarı, mesaj metniyle birlikte 'Archive all messages?' diye soruyor ve düğmede archive.confirm.ok ham anahtarı görünüyor"> <img src="docs/media/simulator/inbox-tr.png" width="300" alt="Gelen kutusu uygulaması Türkçe: uyarı başlığı çevrilmiş, ancak mesajda archive.confirm.message ham anahtarı, düğmede ise archive.confirm.ok ham anahtarı görünüyor"></p>

## Durum

| Özellik                                                                                                                      | Durum       |
| ---------------------------------------------------------------------------------------------------------------------------- | ----------- |
| String Catalogs, `.strings` (UTF-8, UTF-16, XML) ve `.stringsdict`, l10n.yaml'lı ARB, i18next, i18n-js ve ICU JSON            | çalışıyor   |
| 19 kural: çeviriler, güncelliğini yitirmiş ve sahipsiz anahtarlar, placeholder'lar, çoğullar, yinelenenler, koddaki anahtarlar, sabit kodlanmış metin, Türkçe I | çalışıyor   |
| Terminal, Markdown, JSON, SARIF ve GitHub annotation çıktısı; `--fail-on`; baseline'lar; `.globallingo.json`                  | çalışıyor   |
| Tip bildirimli programatik API                                                                                               | çalışıyor   |
| YAML çeviri dosyaları (Rails tarzı i18n, i18next YAML)                                                                        | planlanıyor |
| Yerel Android ve çapraz platform uygulamaların Android tarafı için `strings.xml`                                              | planlanıyor |
| Bir GitHub Action sarmalayıcı (`uses: muhittincamdali/GlobalLingo@v2`) ve pull request yorumları                              | planlanıyor |
| Çevirmen yorumları: yorumu veya `@key` açıklaması olmayan anahtarları raporlama                                               | planlanıyor |

## Sınırlar

- **Derleyici değil, kalıplar.** Kod kuralları Swift, Objective-C, Dart ve
  JavaScript/TypeScript'i yorumlar boşaltılmış hâlde okur ve her ekosistemin metni aradığı ve
  gösterdiği yaygın yolları arar. Çalışma zamanında oluşturulan anahtarlar, arama fonksiyonlarını
  saran sarmalayıcılar ve değişkenler üzerinden atanan metinler görülmez.
- **Yalnızca sabit anahtarlar.** KEY001, sabit (literal) olarak yazılmış anahtarları denetler.
  KEY003, anahtarın adını taşıyan her sabiti, öneki veya Dart üyesini kullanım sayar ve
  kullanımını göremediği bir anahtarı yine de raporlar; bu yüzden bir info bulgusudur.
- **SwiftUI enterpolasyonu.** Xcode, derleyicinin tip bilgisini kullanarak `Text("\(count) books")`
  ifadesini `%lld books` anahtarına çevirir. GlobalLingo'da bu bilgi yoktur; bu yüzden KEY002,
  enterpolasyonlu veya `%` içeren sabitleri atlar.
- **CLDR sürümü.** Çoğul kategorileri, GlobalLingo'yu çalıştıran Node.js'in CLDR verisinden gelir
  (Node.js 26.12'de CLDR 49). Daha yeni bir CLDR bir dile kategori ekleyebilir.
- **Yalnızca dosyalar.** GlobalLingo hiçbir şeyi derlemez, çalıştırmaz veya değiştirmez; yalnızca
  istediğiniz raporu ya da baseline'ı yazar.

## Dokümantasyon

API başvurusu, kurallar, yapılandırma ve rehberler:
[muhittincamdali.github.io/GlobalLingo](https://muhittincamdali.github.io/GlobalLingo/).

## Rehberler

- [GlobalLingo'yu CI'da çalıştırma](docs/guides/ci.md)
- [Apple, Flutter ve JavaScript'te placeholder'lar ve çoğullar](docs/guides/placeholders-and-plurals.md)
- [Türkçe I](docs/guides/turkish-i.md)
- Başvuru: [kurallar](docs/rules.md) ve [yapılandırma](docs/configuration.md)

## İlgili araçlar

Başka projeler de aynı dosyaların bir kısmını denetler; hangisinin uygun olduğu neyi
kullandığınıza bağlıdır:

- [xcstrings-lint](https://github.com/thatswiftguy/xcstrings-lint), String Catalogs ve `.strings`
  dosyaları için bir GitHub Action'dır; yalnızca bir pull request'in getirdiği sorunları engelleyen
  bir ratchet moduna ve pull request yorumuna sahiptir.
- [i18n-check](https://github.com/lingualdev/i18n-check), JavaScript uygulamalarının JSON ve YAML
  çeviri dosyalarını (ICU ve i18next) doğrular; i18next-parser aracılığıyla kullanılmayan ve
  tanımsız anahtarları da kapsar.
- [BartyCrouch](https://github.com/FlineDev/BartyCrouch), `.strings` dosyalarını Swift koduyla ve
  storyboard'larla eşitler, bir API üzerinden çeviri yapabilir, yinelenen anahtarları ve boş
  değerleri denetler.
- [StringsLint](https://github.com/dral3x/StringsLint), Swift ve Objective-C projelerinde eksik ve
  kullanılmayan `.strings` anahtarlarını raporlar.
- Xcode'un String Catalog düzenleyicisi her dilin çeviri ilerlemesini gösterir; Flutter'ın
  `gen-l10n` aracı da `untranslated-messages-file` ile çevrilmemiş mesajları listeler.

GlobalLingo dört biçimi tek çalıştırmada okur ve placeholder türlerini, CLDR çoğul biçimlerini,
kod denetimlerini ve Türkçe I kurallarını ekler. Yukarıdaki açıklamalar, her projenin 28 Ekim
2026 tarihli README'sine dayanır.

## Gereksinimler

| Araç zinciri | En düşük sürüm |
| ------------ | -------------- |
| Node.js      | 22.12          |

GlobalLingo'nun Xcode, Flutter veya React Native'e ihtiyacı yoktur: dosya okur, bu yüzden Linux'ta
da çalışır. CI testleri Node.js 22 ve 24 ile (Linux) çalıştırır; yerelde, bir Mac'te (Apple
silicon) Node.js 22.23, 24.22 ve 26.12 ile 256 testin tamamı geçer.

## Mimari

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

- Her bulgu; bir kural kimliği, bir önem düzeyi (kuralın varsayılanı veya yapılandırmadaki),
  bir dosya ve satır, bir mesaj, bulgunun ekosistemi için kuralın çözümü, bir dokümantasyon
  bağlantısı ve baseline'lar için bir parmak izinden oluşur.
- Her okuyucu bir iç içe geçme sınırında durur ve girdisiyle orantılı sürede çalışır; bu yüzden
  özel hazırlanmış dosyalar yığını ya da zamanı tüketemez. Testler 100.000 düzeyli JSON verir ve
  özel hazırlanmış kataloglar, ayarlar ve kaynak dosyalar 128 KB'tan 2 MB'a büyürken sürenin nasıl
  arttığını ölçer.
- CLI (`src/cli/`) yalnızca argümanları ayrıştırır, renkleri ve genişlikleri seçer ve çıkış kodunu
  belirler.

## Yol haritası

[Durum](#durum) tablosuna bakın: YAML dosyaları, Android `strings.xml`, bir GitHub Action
sarmalayıcı ve çevirmen yorumları planlanıyor. [CHANGELOG.md](CHANGELOG.md) her sürümün neyi
değiştirdiğini listeler.

## SSS

**GlobalLingo dosyalarımı değiştirir mi?** Hayır. Onları okur ve yalnızca istediğiniz raporu ya da
baseline'ı yazar.

**İngilizcede iki biçim varken Lehçe neden dört biçim gerektirir?** Lehçe 1 için bir biçim, 2–4
(ve 22–24, 32–34…) için başka bir biçim, 0 ile 5–21 (ve 25–31…) için bir diğerini ve kesirler için
dördüncüsünü kullanır. CLDR bu kuralları dil başına kaydeder; tablo [çoğul rehberinde](docs/guides/placeholders-and-plurals.md)
var.

**Uygulamamın Türkçe çevirisi yok. TRI001 yine de önemli olabilir mi?** Evet. Konu uygulamanın
değil, cihazın diliyle ilgilidir: `toLocaleLowerCase()` ile küçük harfe çevrilen bir anahtarda
`I`, herhangi bir Türkçe cihazda `ı` olur. [Türkçe I](docs/guides/turkish-i.md) bunu gösterir.

**Bir bulgu projem için yanlış. Ne yapmalıyım?** Kuralın önem düzeyini `.globallingo.json` içinde
düşürün ya da kapatın, anahtarı veya yolu yok sayın ya da satırı `globallingo-ignore` ile
işaretleyin; ayrıca bunu gösteren en küçük örnekle bir issue açın.

## Katkıda bulunma

Katkılarınızı bekliyoruz: pull request açmadan önce [CONTRIBUTING.md](CONTRIBUTING.md) dosyasını ve
[davranış kurallarını](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md)
okuyun; güvenlik sorunlarını [SECURITY.md](SECURITY.md) dosyasında anlatıldığı gibi bildirin.

## Lisans

MIT lisansıyla yayımlanmıştır. Ayrıntılar için [LICENSE](LICENSE) dosyasına bakın.
