# Progress #1 — Analiz Turu + MD Altyapısı

**Tarih:** 2026-08-12
**Tetikleyen istek:** *"yeni manuel reeskont ekranı için doküman atıldı, çok detaylı oku · analizini çıkar · mimariyi belirle · md dosyalarını (workspace md'si dahil) ayarla · skill yaz"*
**Genel ilerleme:** Analiz ✅ · Mimari karar ✅ · MD altyapısı ✅ · **Sözleşme ⬜** · Kod ⬜

---

## Yapılanlar (Done)

### 1. Doküman okundu — tam metin + 7 görsel
- `.ai-agent/imports/Manuel Reeskont v1.docx` (Base Component — Fonksiyonel & Teknik Tasarım, v1.0, 28 Temmuz 2026)
- docx unzip edilip `word/document.xml` python ile düz metne çevrildi (416 satır, 40 KB) → `imports/manuel-reeskont-v1-duz-metin.txt`
- 7 görselin **hepsi** görsel olarak incelendi → `imports/manuel-reeskont-gorseller/image1..7.png`
  - image1 Status Flow diyagramı · image2 genel görünüm (All + özet + Generate/Regenerate) · image3 karışık Revaluation Type → Generate pasif
  - image4 Ters Fiş Valörü popup (T+1/T+0) · image5 Generate onay · image6 Regenerate onay (durum bazlı) · image7 işlem sonucu (2 başarılı + 2 Error)

### 2. Analiz dosyaları yazıldı
| Dosya | İçerik |
|-------|--------|
| `01-dokuman-analizi.md` | Doküman kimliği · 3 seviyeli hiyerarşi · fazlama · **eski↔yeni 19 boyutlu karşılaştırma** · nihai fonksiyonel model (aksiyon×durum matrisi) · sözleşme (sabit kolonlar, filtreler, endpoint, request/response, kolon config) · **20 çelişki/eksik (C-01…C-20)** · görsel envanteri (hangi görsel hangi tasarım nesli) |
| `02-mimari-karar.md` | Karar + uçtan uca diyagram · **kanıt kod blokları** · Common'da hazır altyapı · **12 eksik/tuzak (F-01…F-12)** · fiziksel yerleşim (3 repo) · **14 ADR** · repo dağılımı · **10 risk** |
| `03-mm-backend-envanteri.md` | MM hesap zinciri · fiş modeli · **ters fiş pipeline'ı** · EOD batch · Fimple entegrasyonu · mevcut API'ler · ürün/alt-ürün temsili (4 paralel temsil) · hazır↔yazılacak · **11 tuzak (T-01…T-11)** · 9 MM sorusu (M-01…M-09) |
| `04-sorular.md` | **4 bloke eden** + iş birimine 16 soru + Selim'in 7 teknik kararı + 4 kapanmış |
| `00-PANO.md` | Ana pano — faz durumu, bloke edenler, sıradaki adımlar, karar kaydı, ölçülen gerçekler |

### 3. 5 ajan araştırması yapıldı, **hamı** `analiz/` altına dosyalandı
| # | Konu | Taranan | Kritik bulgu |
|---|------|---------|--------------|
| 1 | MicroUI: Shell · SharedDependency · ekran kurulumu · yetki | `Treasy.Shell` · `Treasy.MicroUI.Packages` · `Treasy.MM.UI` | ✅ Paketten **tam ekran** + 10 grid'li ortak bileşen çıkıyor (RCL) · 🔴 MM.UI'de sunucu yetkisi fiilen kapalı |
| 2 | MM'de reeskont/ters fiş altyapısı | `NetTrex.MM` | ✅ **T+0 + ters fiş deseni TAM KURULU**, %85 hazır · 🔴 Fimple idempotent değil |
| 3 | Web.UI ortak yapı · Refit marker'ları · runtime yönlendirme · yetki | `NetTrex.Web.UI` | 🔴 runtime base-URL resolver YOK · permission = Controller/Action · marker isimleri tutarsız |
| 4 | Common fan-out altyapısı | `NetTrex.Common` | ✅ **FAN-OUT VAR** — DailyFlow V2 = Strategy+Factory+`Task.WhenAll` · 🔴 InvFund yok · WhenAll kısmi hata toplamıyor · token taşınmıyor |
| 5 | DailyFlow UI tarafı (hipotez testi) | `NetTrex.Web.UI` | ✅ **HİPOTEZ DOĞRULANDI** — UI'de tek uç, modül switch'i yok · 🔴 server paging yok · union/LCD model |

Ayrıca ilk mimari taslak (fan-out'u UI'de varsayan 4-seçenekli analiz) → `analiz/analiz-0-ilk-mimari-taslak-SUPERSEDED.md` olarak arşivlendi.

### 4. Mimari kararlaştırıldı (kullanıcı kurgusu + kodda doğrulama)
**WebUI genel ekran → `NetTrex.Common` tek uç → Common'da Strategy Factory ile modüllere fan-out.**
- Kullanıcının kurgusuydu, **DailyFlow V2'de canlı çalıştığı doğrulandı** → mimari icat edilmiyor, olgun desen klonlanıyor
- Base component'i MicroUI'ler (Deriv/OptFX/MM) **Invoke** edecek; MicroUI'si olmayan modüller Web.UI'den kullanmaya devam
- `baseUrl` → `moduleCode` sözleşme değişikliği **onaylandı** (iş birimine bildirilecek)
- 14 ADR yazıldı (ADR-MR-001…014)

### 5. Workspace MD katmanı kuruldu
`ai-agent-context-kit` konvansiyonuna göre (`START-HERE` · `PROJECT_CONTEXT` · `MEMORY` + promotion rule · `progress/` · `compacts/` · `sessions/` · `skills/`):

```
repos/
├── CLAUDE.md                          ← YENİ · workspace Hard Rule'ları + repo haritası + aktif işler
└── .ai-agent/
    ├── START-HERE.md                  ← YENİ · 3 katmanlı okuma sırası (workspace→repo→iş)
    ├── PROJECT_CONTEXT.md             ← YENİ · GENEL MİMARİ: modül↔repo↔API haritası, topoloji, 2 ADR
    ├── MEMORY.md                      ← YENİ · cross-repo karar/tuzak/tercih + promotion rule
    ├── compacts/_index.md             ← YENİ · proaktif compact kuralı + 7 zorunlu bölüm şablonu
    ├── sessions/README.md             ← YENİ
    ├── skills/_index.md               ← YENİ · cross-repo + repo-özel skill yönlendirme tablosu
    ├── imports/                        ← docx + 7 görsel + düz metin kopyalandı
    ├── outputs/
    └── manuel-reeskont/
        ├── 00-PANO.md · 01…04 · analiz/ (6 dosya) · progress/ · faz-docs/
```

**Kritik nokta:** `repos/CLAUDE.md` üst dizin olduğu için cwd hangi repo olursa olsun **otomatik yükleniyor**;
repo-özel `CLAUDE.md`'ler kaldırılmadı — iki katman birlikte çalışıyor, çakışmada repo-özel kazanır.

---

## Yapılıyor (In Progress)

| İş | Durum |
|----|-------|
| `manuel-reeskont` skill'i (`NetTrex.MM/.claude/skills/` wrapper + `repos/.ai-agent/skills/manuel-reeskont.md` gövde) | 🟡 yazılıyor |

---

## Yapılacaklar (TODO)

### 🔴 Bloke edenler — kod öncesi
| # | İş |
|---|----|
| 1 | `04-sorular.md` **Bölüm A**'yı iş birimine gönder (16 soru, 4'ü bloke eden: C-01 · C-07 · C-08 · C-02) |
| 2 | `04-sorular.md` **Bölüm B**'yi Selim karara bağlasın (7 teknik madde: C-14 · C-15 · M-02 · M-05 · M-07 · M-08 · R-04) |
| 3 | **`06-sozlesme.md` yaz ve DONDUR** — nihai request/response modelleri + enum değerleri + kolon config şeması + `Data` sözlüğü kuralları |

### Faz 1 — Treasury ekranı
| # | Repo | İş |
|---|------|----|
| 4 | `NetTrex.MM` | `eligible-transactions` sorgusunu tasarla — 4 durumu türeten (`NotRediscounted`/`NotReversed`/`Rediscounted`/`All`) + **sayfalamalı** + `Data` sözlüğünü dolduran tek-sorgu projeksiyon. Mevcut `GetPendingRevaluationTransactions` yetmiyor (yalnız NotRediscounted veriyor). "En son aktif hareket" tanımı netleşmeli (M-08) |
| 5 | `NetTrex.MM` | 2 endpoint + handler + validator. `executions` → `IRevaluationAccountingService` / `IRevaluationReverseAccountingService` tetikler, **yeni motor yazılmaz**. `ProductSourceType` ile MM↔IL dallanması + `GetIsEnabledInterbankLoanModule()` guard'ı |
| 6 | `NetTrex.MM` | Satır bazlı hata toplama (`Succeeded[]`/`Failed[]`) · çift-tıklama koruması (Fimple idempotent değil, T-02) · audit (`CurrentUserId` → `StateMaker`, T-01 hardcoded `"SYSTEM"` yerine) · ters fiş valörü T+0/T+1 → `RevaluationReverseAccountingServiceContext.LogicalDate` |
| 7 | `NetTrex.Common` | DailyFlow V2 üçlüsünü klonla: `ManualRediscountController` + 2 Handler + `ManualRediscountOperation` + `ManualRediscountStrategyFactory` + 6-7 Strategy + **tek ortak sözleşme DTO'ları** (`General/` altında, modül başına DTO **yapma**) |
| 8 | `NetTrex.Common` | `Task.WhenAll` + **modül-başına `try/catch`** (F-03) · `.ToContentGeneral()` yerine `result.Error is not null → throw` (F-04) · mevcut 5 `IClientXxxAPI`'ye 2 metot ekle |
| 9 | `NetTrex.Web.UI` | 3 controller (`Treasury`/`Security`/`Investment` — permission ayrımı için, F-11) + 1 ViewComponent + `Views/Shared/Components/ManualRediscount/` + 5 JS dosyası + kolon config JSON'ları + localization + CSS + 1 Refit interface (`: IClientCommonAPI`) |
| 10 | `NetTrex.Web.UI` | `AdvanceAndStateFilter` ViewComponent'ini yeniden kullan (20+ view kullanıyor) · toplu seçim (Select All/100/50/25/Custom, indeterminate) · onay pencereleri (Generate/Regenerate/T+0-T+1) · durum bazlı özet satırı |
| 11 | `NetTrex.Fx` | 2 endpoint — mevcut `RediscountController` sözleşmeye uyarlanacak mı, yeni uç mu? **Kim yazacak?** (soru) |
| 12 | — | **Faz 1 doğrulama:** Treasury ekranı MM + FX ile uçtan uca çalışıyor mu |

### Faz 2+
| # | İş |
|---|----|
| 13 | `NetTrex.Common`: **`IClientInvFundAPI` + `InvFundApi` config key'i + appsettings/helm girdileri** — sıfırdan (F-01). `DailyFlowV2Operation.cs:41` `INVFUND`'ı dışlıyor |
| 14 | `NetTrex.Common`: helm `values-*.yaml`'da eksik `OptFXApi` (F-02) |
| 15 | Security + Investment ekranları (ürün ekipleri kendi endpoint'lerini yazacak) |
| 16 | Regenerate'te geçmiş tarihli yeniden değerleme (`RegenerateToToday`) |
| 17 | **Base component'i pakete taşı** — Razor+ViewComponent → `Treasy.MicroUI.SharedDependency`, JS→TS → `@treasy/components`; MicroUI'ler Invoke etsin (ADR-MR-014, §2.4-a) |
| 18 | Faz 3: Generate/Regenerate öncesi değerleme tutarı önizlemesi |

### Keşfedilen yan işler (bu işten doğdu, ayrı karar)
| # | İş |
|---|----|
| 19 | `Treasy.MM.UI` dokümanları **bayat**: `PROJECT_CONTEXT.md:14` + `inventory/shareddependency-yuzey.md:1` **1.0.3** diyor, gerçek **1.0.4-dev12** |
| 20 | `PROJECT_CONTEXT.md` § 9 — **doğrulanacaklar**: FI/Warrant/Limit modüllerinin backend repoları tespit edilmedi (config key'leri var, repo yok) |
| 21 | Mevcut FX Manuel Reeskont ekranının bilinen 13 kusuru (`FxManuelRevaluation-Reeskont-research.md` § 13) — yeni ekranda tekrarlanmaması için sözleşmeye/koda yansıtıldı; **eski ekran düzeltilecek mi?** (C-20 ile bağlantılı) |
