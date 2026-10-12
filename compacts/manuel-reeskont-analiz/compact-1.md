# Compact — Manuel Reeskont · analiz & mimari · #1

**Sohbet:** Manuel Reeskont — analiz & mimari · **Session id:** `22f06b9a-b65d-49d1-96cb-c4ed06d26fe4`
**Tarih:** 2026-08-12 · **Sıra:** bu sohbetin 1. compact'i
**Kapsanan aralık:** İlk istekten MD katmanı + skill kurulumunun bitişine kadar
**Aktif iş dosyası:** [manuel-reeskont/progress/progress-1.md](../../manuel-reeskont/progress/progress-1.md)
**⚠️ Geriye dönük yazıldı** — bkz. [_chat.md](_chat.md)

---

## 1. Kullanıcının istekleri (sırayla, kendi kelimeleriyle)

1. **Dokümanı ÇOK detaylı oku:** `NetTrex.MM/.ai-agent/imports/Manuel Reeskont v1.docx`.
   *"biz çok güzel bir ekran yapmamız lazım"*
2. **Okuduktan sonra sorunu bana sor** — *"ben de ona göre sana data sağlayacağım ve bu dataları üzerinden gideceğiz"*
3. **Önce dokümanın detaylı analizi çıkacak**, geliştirme o analiz üzerinden gidecek.
4. **Eskiyi ve yeniyi karşılaştırarak anlat:** *"Ben dökümanı anlamadım sen bana detaylı bir şekilde anlat
   önceki nasıl yazılmış ve şimdi benden nasıl yazılması isteniyor"*
5. **Mimariyi araştırmayla belirle**, sonra başla. Ekran generic olacak: MM, Fx, Option, Fund, FI.
   3 ekran olacak; kendisi **yalnız Fx/Treasury olanı** yapacak (FI ve Fund kendi ekranlarını yapacak)
   ama **base component** şeklinde.
6. **Geliştirmeye başlamadan ÖNCE MD dosyaları düzenlensin** — *"analiz ve md dosyası düzenleme işimiz
   çok çok önemli"*. Model olarak `Treasy.MM.UI/.ai-agent/mm-microui-phase-docs/TODO-In Progress-Done/`
   yapısını beğeniyor: *"geliştirme çok uzun sürünce ben context'in compact'ını alıyorum ya da yeni
   session'a geçiyorum ama bu şekilde benim tam olarak neler yaptığım hangi aşamada kaldığım ve
   gerçekten ne istediğim belirgin olduğu için ilerlemem kolay oluyor"*
7. **WORKSPACE seviyesinde MD katmanı** kur: `C:\Users\Treasy-70\source\repos` altına genel `CLAUDE.md`,
   her istekte okunsun, genel mimari orada yazsın → *"hangi modülü nasıl kullanacağını anlar"*.
   MEMORY.md + session + skill de olsun.
8. **Manuel reeskont için skill** yazılsın.

### Kullanıcının verdiği kararlar (AskUserQuestion cevapları)

| Soru | Cevap |
|---|---|
| Mimari | *"WebUI'da ekranım olacak ve Common'a gidecek ve o backend için modüllere istek atacak gibi düşünüyorum. **DailyFlow ekranına bak orada ki mantık gibi olacak**. Genel base component'im olacak ve bu componenti microUI olanlar mesela **Deriv, option ve MM Invoke edecek**, diğer modüller zaten WebUI üzerinden ilerlediği için hâlâ direkt o yapıyı kullanabilecek."* ⚠️ **Bu karar compact-2'de İPTAL edildi** |
| Doküman `baseUrl` alanı | **`moduleCode`'a çevir, iş birimine bildir** |
| MD yapısı | *"Tam kur"* — START-HERE + pano sürümleme + faz-docs + compacts, **ve workspace MD'si** |
| Skill nereye | **`NetTrex.MM`'de cross-repo skill** |

### Mid-turn eklenen kalıcı kural

*"analiz sonuçlarını agent dosyanın içinde sürekli yeni file oluşturup her response'dan sonra
analizlerini yazmanı istiyorum... manuel reeskont dosyası içinde **analiz folder**'ı altına,
her seferinde yeni file oluşturup"*

---

## 2. Yapılanlar

### .docx okuma (binary → metin)

```bash
# scratchpad'e özel converter yazıldı (docx XML → Markdown; tablo/görsel/heading/liste korur)
PYTHONIOENCODING=utf-8 python docx2txt.py "Manuel Reeskont v1.docx"
```

Çıktı: `NetTrex.MM/.ai-agent/imports/manuel-reeskont-v1-duz-metin.txt` (416 satır)
+ gömülü **7 görsel** `imports/manuel-reeskont-gorseller/image1..7.png` olarak çıkarıldı ve **görsel olarak okundu**.

### Üretilen dosyalar

**Workspace MD katmanı (YENİ):**

```
repos/CLAUDE.md                          ← 10 cross-repo Hard Rule + repo haritası + aktif işler
repos/.ai-agent/START-HERE.md            ← 3 katmanlı okuma sırası
repos/.ai-agent/PROJECT_CONTEXT.md       ← genel mimari + ADR-WS-001/002
repos/.ai-agent/MEMORY.md                ← cross-repo karar/tuzak (5 tuzak)
repos/.ai-agent/compacts/_index.md
repos/.ai-agent/sessions/README.md
repos/.ai-agent/skills/_index.md
repos/.ai-agent/skills/manuel-reeskont.md      ← skill gövdesi
```

**Manuel Reeskont iş klasörü (YENİ):**

```
repos/.ai-agent/manuel-reeskont/00-PANO.md                 ← pano (üzerine yazılır)
                               /01-dokuman-analizi.md      ← 19 boyutlu eski↔yeni karşılaştırma, C-01..C-20
                               /02-mimari-karar.md         ← ADR-MR-001..014
                               /03-mm-backend-envanteri.md ← T-01..T-11 tuzak, M-01..M-09
                               /04-sorular.md              ← A: 16 iş birimi sorusu, B: 7 teknik karar, C: 4 kapalı
                               /analiz/_index.md + analiz-0..5
                               /progress/_index.md + progress-1.md
                               /faz-docs/                  ← boş
```

**Skill wrapper:** `NetTrex.MM/.claude/skills/manuel-reeskont/SKILL.md`

**Düzenlenen:** `NetTrex.MM/CLAUDE.md` (workspace katmanı notu), `NetTrex.MM/.ai-agent/skills/_index.md` (satır eklendi)

### 5 ajan araştırması (hepsi `analiz/` altına ham yazıldı)

| Dosya | Konu |
|---|---|
| analiz-1 | MicroUI / Shell / paketler |
| analiz-2 | MM revaluation backend |
| analiz-3 | WebUI + Common yapısı |
| analiz-4 | Common fan-out backend |
| analiz-5 | DailyFlow UI |

---

## 3. Kararlar ve gerekçeleri

| Karar | Alternatif | Neden bu seçildi |
|---|---|---|
| Fan-out **Common**'da (DailyFlow V2 kopyası) | Fan-out WebUI controller'da (benim önerim: per-modül Refit + `IServiceProvider` switch, `EodController` deseni) | Kullanıcı kendi kurgusunu dayattı, kodda doğrulandı: DailyFlow V2 aynen böyle. **Benim önerim yanlıştı.** ⚠️ compact-2'de bu karar TERSİNE döndü |
| `baseUrl` → `moduleCode` | Dokümanda kaldığı gibi | `baseUrl` UI'ye modül adresi sızdırır; `moduleCode` house convention (DailyFlow'da da böyle) |
| Skill `NetTrex.MM`'de, gövdesi workspace'te | Her repoda kopya skill | Tek gerçek kaynak; wrapper sadece "şu dosyayı oku" der |
| Benim ilk mimari taslağım **silinmedi**, `analiz-0-...-SUPERSEDED.md` olarak arşivlendi | Sil | Neden reddedildiği bilgisi değerli |
| Ajan çıktıları **ham** yazılıyor | Özetleyip yaz | Kullanıcının açık talebi — özet bilgi kaybı |

---

## 4. Karşılaşılan hatalar

| Hata (AYNEN) | Kök neden | Çözüm / durum |
|---|---|---|
| `UnicodeEncodeError: 'charmap' codec can't encode character '\u2192'` | Windows stdout cp1254, docx metninde `→` var | `PYTHONIOENCODING=utf-8` ile çalıştırıldı ✅ |
| `json.decoder.JSONDecodeError: Invalid control character` | Web.UI `appsettings.json` içinde ham kontrol karakteri, Python `json` katı | Python bırakıldı, **Grep tool** ile 18 API key adı regex'le arandı ✅ (daha temiz) |
| `Write` reddedildi: **"File has not been read yet"** (`02-mimari-karar.md`) | Dosyayı bu oturumda ben oluşturdum, sonra `bash mv` ile taşıdım → harness'in read-state'i düştü | `mv 02-mimari-karar.md analiz/analiz-0-ilk-mimari-taslak-SUPERSEDED.md` → yol boşaldı, yeni içerik yazıldı ✅ (hem sorun çözüldü hem arşiv oluştu) |
| markdownlint MD060 / MD028 uyarıları | Tablo pipe boşlukları, blockquote içi boş satır | Kozmetik — düzeltilmedi |

---

## 5. Ölçülen gerçekler

### Dokümanın en büyük kusuru — İKİ TASARIM NESLİ birbiriyle çelişiyor

| Nesil A | Nesil B |
|---|---|
| **"Execute Selected"** tek aksiyon | **"Generate" + "Regenerate"** iki aksiyon |
| Status *"tek seçim, **All yok**"* | *"**All** seçeneği eklenir"* |
| §3.5, §4.4, §5.4, §8.2, §8.3 + image1/4/7 | §4.6, §4.7, §5.3, §8.1 + image2/3/5/6 |

- `ExecutionsRequest` **iki kez** tanımlı, alan setleri uyumsuz: §6.4.3'te `Status` + `ReverseValueDate` var / `Operation` yok;
  §6.4.4 genişletmesinde `Operation` + `ExecutionDate` + `RegenerateToToday` var ama **`ReverseValueDate` KAYIP** —
  oysa §4.2 hâlâ T+0/T+1 istiyor.
- İçindekiler'de **"6.1 Asenkron İşlem Mimarisi"** yazıyor ama **gövdede o bölüm YOK** (§6.1 "Teknoloji ve Yapı" olmuş)
  → senkron/asenkron **belirsiz**. 248 satır × senkron Fimple çağrısı = **timeout kesin**.
- Product filtresi: metin *"tekli + zorunlu"* diyor; **tüm görsellerde** `Product: Murabaha, FX Spot +1` = çoklu,
  grid'de ürünler karışık, **Sub Product filtresi hiç yok**.

### MM tarafı — ters fiş deseni ZATEN VAR (M-01 kapandı)

- FX ile **aynı** `accEntryMain` / `accEntry` şeması (`MessageKey`, `BusinessKey`, `IsReverse`, `ReverseId`, `ExternalState`, `ProductCode`, `Type`)
- `RevaluationAccountingPipeline` (6 step) + ayrı `RevaluationReverse` pipeline + `AccountingReverseFactory`
- `RevaluationReverseType { Eod=1, Bod=2, Atomic=3 }` — parametrik
- `TxnMMDailyCalculationEntity` / `LoanRevaluationEntity` günlük tahakkuku tutuyor
- → MM'de **iş yeniden tasarımı gerekmiyor**, sadece **2 endpoint** lazım

### Enum drift (3 assembly'de kopya)

`AccountingType { Opening=1, Revaluation=2, Payment=3, Maturation=4, Manuel=5, Amortization=6, Fee=7 }`
`FimpleAccountingType { None=0, Rediscount=1, Coupon=2, Closing=3, Deleting=4, Opening=5 }`
`ProductAccountingCodeType` → explicit `WAKALE=4`, `MURABAHA=5`
`DailyFlowProductType` → en zengin liste, SubProduct dropdown için en iyi aday

### Altyapı boşlukları

- `Task.WhenAll` **kısmi hata toplamıyor** → bir modül patlarsa tüm istek düşer
- `.ToContentGeneral()` **hatayı yutuyor**
- Common → modül çağrısında **token taşınmıyor** → kimlik `CurrentUserId` ile body'de gitmeli
- Fimple çağrıları **idempotent değil**
- `IFimpleAccountingService` **`internal`**
- WebUI yetki granülaritesi = **ControllerName/ActionName** → ekran başına ayrı controller şart (3 controller)

---

## 6. Açık kalanlar

🔴 **4 BLOKE EDEN** (iş birimine gidecek): C-01 (Execute Selected mi Generate/Regenerate mi + `All` var mı),
C-07 (senkron/asenkron), C-08 (nihai `ExecutionsRequest` + `ReverseValueDate` nerede), C-02 (Product tekli/çoklu + SubProduct filtresi)

**Selim'in kararı bekleyen 7 teknik madde** (`04-sorular.md` § B): C-14 `Data` yerleşimi, C-15 kolon config fiziksel yeri,
M-02 SubProduct eşlemesi, M-05 Fimple yuvarlama, M-07 manuel fiş `AccountingType`, M-08 "son aktif hareket" tanımı,
R-04 `moduleCode` reddedilirse fallback

**`06-sozlesme.md` yazılıp DONDURULACAK** — skill bunu **kod yazma kapısı** olarak kullanıyor.

---

## 7. Sonraki session'a devir

Mimari raporunu sohbete sun + 4 bloke eden soruyu iş birimine iletilecek şekilde ver.
(→ compact-2'de bu yapıldı ve **mimari kullanıcı tarafından değiştirildi**)
