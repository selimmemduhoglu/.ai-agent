# 03 — Modül Adı `ColManagement` + MD Faz Yapısı

**Tarih:** 2026-10-08 · **Faz:** 0 (kısmi) + altyapı
**Çıktı:** `ColManagement-Feature/` altında `00-YOL-HARITASI.md` · `01-KIMLIK.md` · `02-DURUM.md` ·
`fazlar/` (14 dosya) · `progress/` (4 dosya)

---

## Yöntem

Kullanıcının isteği iki parçalıydı:
1. *"bu modülün ismini ColManagement olarak belirledik **son kez**"*
2. *"ben her compact dediğim zaman içerdeki önemli detayların kaybolmasını istemiyorum"* →
   baştan sona fazlandırılmış, devir-teslim niteliğinde bir MD bütünü

---

## Kararlar

### 1. İşin ana evi: **workspace** `repos/.ai-agent/feature-research/ColManagement-Feature/`

| Aday | Değerlendirme |
|---|---|
| `NetTrex.Collateral/.ai-agent/` | ❌ İş **4 yere** dokunuyor: backend repo · UI repo · `NetTrexCommon` · `NetTrexAcc`. Backend reposuna koymak UI fazını yetim bırakır |
| ✅ **workspace `ColManagement-Feature/`** | Excel · docx · ses kaydı · DerivSwp script'leri **zaten orada**. Workspace `CLAUDE.md` *"birden fazla repoya dokunuyorsa panosu buraya"* diyor |

Repo-içi `.ai-agent/`'ler **ince pointer** oldu. `NetTrex.Collateral/.ai-agent/00-FAZ-PLANI.md`
(220 satır) stub'a indirildi — iki yerde faz planı tutmak tam da defalarca uyardığım
*"iki kopya ayrışır"* tuzağı.

### 2. Statik plan ↔ canlı durum ayrımı

| Dosya | Niteliği | Ne zaman değişir |
|---|---|---|
| `00-YOL-HARITASI.md` | **statik** — iş ne, faz listesi, değişmez kurallar | nadiren |
| `01-KIMLIK.md` | **statik** — adlandırma sözlüğü | Faz 0 kararlarında |
| `02-DURUM.md` | 🔴 **canlı** — nerede kaldık, açık uçlar, kullanıcı sözleri | **her turda** |
| `fazlar/faz-N-*.md` | **statik** — o fazın adımları ve tuzakları | faz başlarken |
| `progress/NN-*.md` | **append-only** — ne yaptık | iş bitince |

Faz **durum** sütunu yol haritasından çıkarıldı, `02-DURUM.md` §1'e taşındı.
Aynı durumu iki dosyada tutmak ayrışma üretiyordu (yol haritası *"Faz 2 BURADAYIZ"* derken
repo dosyası *"Faz 1 devam ediyor"* diyordu — fiilen yaşandı).

### 3. 🔴 Compact koruması

`02-DURUM.md` §3'te **kullanıcının birebir cümleleri** tablosu var. Gerekçe: özetleme bir cümleyi
yeniden ifade ettiğinde **niyet kayıyor** — *"son kez belirledik"* gibi bir vurgu özet turunda
*"modül adı ColManagement"* diye sadeleşiyor ve bir sonraki turda yeniden tartışmaya açılıyor.

§5'te compact protokolü: *"compact"* duyulunca **önce** `02-DURUM.md` güncellenir, sonra
`compacts/<chat-slug>/compact-<n>.md`. Ayrıca *"özete asla güvenilmeyecek şeyler"* listesi —
hata metinleri, ölçüm çıktıları, çürütülmüş hipotezler, bir kararın **neden** alındığı.

### 4. Tablo adlandırma: `Collateral` = domain, `ColManagement` = modül kimliği

🔑 **Kural:** tablo **ne tuttuğunu** anlatır, projenin adını değil.
DB adı zaten `NetTrexColManagement` — her tabloya modül adını yazmak tekrar.

Ev konvansiyonunda modül adını taşıyan **tek** yer değerleme tablosu
(`OptionsFXRevaluation`, `DerivativesRevaluation`). Dolayısıyla yalnız **iki** tablo değişiyor:

| Excel v5 | Nihai |
|---|---|
| `CollateralRevaluation` | 🔄 `ColManagementRevaluation` |
| `CollateralAuditLog` | 🔄 `ColManagementAuditLog` |

`CollateralDefinition` / `CollateralPosition` **kalıyor** — buradaki `Collateral` *teminat varlığı*
demek; `ColManagementDefinition` yazmak anlamı kaybettirirdi.
⬜ Kullanıcı onayı bekliyor; *"hepsi `ColManagement*` olsun"* denirse Excel v6.

### 5. Faz sayısı 10 → 13

Eskisi backend'e odaklıydı, UI tek satırdı (*"Faz 10 — UI, ayrı repo"*). Kullanıcı
*"Backend - UI - script ve Excel oluşturma ve editleme olarak öngörerek hazırla"* deyince:

- **Faz 0** eklendi (kimlik kararları) — bunlar script metninin **içine** giriyor, ayrı faz olmayı hak ediyor
- **UI 3 faza bölündü**: 10 iskelet · 11 ekranlar · 12 uçtan uca
- **Excel** tek seferlik bir iş değil → `faz-2-veri-modeli.md` içinde **v6'yı tetikleyecek şeyler**
  listesi ve sürümleme kuralı duruyor

---

## Değişiklikler

| Dosya | Durum |
|---|---|
| `00-YOL-HARITASI.md` | 🆕 statik plan + okuma protokolü + 9+1 değişmez kural |
| `01-KIMLIK.md` | 🆕 adlandırma sözlüğü: modül kimliği · 21 tablo · constraint kalıpları · `DefNumberGen` seed · yeniden adlandırma doğrulaması |
| `02-DURUM.md` | 🆕 canlı durum · açık uçlar · **kullanıcı sözleri** · compact protokolü |
| `fazlar/` | 🆕 `_index.md` + 13 faz dosyası |
| `progress/` | 🆕 `_index.md`; `NetTrex.Collateral/.ai-agent/progress/`'ten 2 dosya **taşındı** |
| `NetTrex.Collateral/.ai-agent/00-FAZ-PLANI.md` | 🔄 220 satır → pointer stub |
| `NetTrex.MM/.ai-agent/feature-research/ColManagement-Feature/` | 🗑️ **boş klasör silindi** (yanlış yerdeydi) |
| workspace `CLAUDE.md` | 🔄 Collateral bloğu `02-DURUM.md`'yi işaret ediyor |

---

## Doğrulama

- ✅ 13 faz dosyası + 4 kök dosya diskte, `_index.md`'lerden erişilebiliyor
- ✅ `grep` ile ölü link kontrolü yapıldı
- ✅ Faz durumu **tek** dosyada (`02-DURUM.md`) — yol haritasında durum sütunu yok
- ⚠️ Repo adları hâlâ `NetTrex.Collateral` / `Treasy.Collateral.UI` — **kullanıcı rename edecek**;
  MD'ler hedef adı (`ColManagement`) kullanıyor, bu bilinçli

---

## Açık kalanlar

| # | Ne |
|---|---|
| `A-08` | Modül kodu (`CM`?) — **Faz 3'ü bloke ediyor** |
| `A-09` | Sayaç öneki (iki haneli) — **Faz 3'ü bloke ediyor** |
| `A-10` | DB adı (`NetTrexColManagement`?) — **Faz 3'ü bloke ediyor** |
| — | Tablo adlandırma onayı (2 tablo mu, hepsi mi) |
| — | Repo rename sonrası MD'lerdeki yolların güncellenmesi |
