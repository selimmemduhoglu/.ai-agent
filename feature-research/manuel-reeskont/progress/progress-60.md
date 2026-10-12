# progress-60 — Açık madde temizliği: A/B/C turu + Acc. kolonu (2026-09-22)

> Önceki tur: [progress-59](progress-59.md). PO "açık olan her şeyi yap (10. madde hariç)" dedi;
> bu tur o listenin B ve C kısımlarını kapatıyor. A zaten progress-59'da bitmişti.

## Durum

🟡 **Kod hazır, build'ler yeşil, tarayıcı testi yok.**

---

## B-1 — Regenerate onayında MessageKey gösterimi

Mevcut ters fişin `MessageKey`'i artık onay penceresinde satırın yanında yazıyor
(`mrCommonReverseMessageKey`, `mrCommonReverseValueDate`'in birebir eşi).

**Zincir (MM + InterbankLoan):**
`TransactionDataManager` / `TransactionLoanDataManager` → `TDMRediscountEligibleResult.ReverseMessageKey`
(yeni alan, **kayıt sonuna eklendi**, pozisyonel record'da mevcut alanları kaydırmamak için) →
`EligibleTransactionsHandler.MapItem` → `ManualRediscountItem.ReverseMessageKey` (MM + WebUI mirror +
Common.UI mirror) → `actions.js`/`actions.ts` `mirrorReverse` metnine ekleniyor.

Yalnız **MM** modülünde dolduruldu — DerivSwp/OptFX/Fx'te bu alan yok, satırlarda sessizce boş kalır
(mevcut satır bazlı özellik, zaten modüle özel).

## B-2 — Acc. kolonu (Common.UI)

progress-59'da "altyapı yok" denip kapatılmıştı; bu tur yeniden incelendi ve **kapatılmasına gerek
olmadığı** görüldü:

- `Treasy.Pure.Client` paketinde (`1.0.0-dev08`) hazır bir `IClientAccountingApi : IClientBaseApi`
  marker interface'i **zaten var** — MM/Fx/DerivSwp/OptFX'in kullandığı conventionun aynısı.
  `AccountingApi` config key'i de docker-compose/appsettings'te zaten duruyordu.
- WebUI'nin `Views/Shared/_AccountingDisplay.cshtml`'i Framework.WebUI'ye bağlı olsa da, kendi
  partial'ımızı `Html.DevExtreme()` (Common.UI'de zaten var) ile yazmak mümkün.
- "Module Accounting" sekmesi WebUI'de her ürünün **kendi** transaction API'sine (`IMmTransactionApi`,
  `IFxTransactionApi`, ...) `SelectAcc`/`AccountingReport` ile gidiyor — bu route'lar zaten
  `IClientMmApi`/`IClientFxApi`/... base'lerini paylaşıyor, ayrı bir client gerekmedi.

**Eklenenler:**
- `IManualRediscountAccountingApi : IClientAccountingApi` — Core Banking + Local sekmeleri
  (`/AccountingFimple/select/{txnId}`).
- `IManualRediscountMmApi`/`Fx`/`OptFX`/`DerivSwp`'e birer `SelectAcc`/`AccountingReport` metodu —
  Module Accounting sekmesi (WebUI'deki route'larla birebir).
- Core'da yalın DTO'lar (`ExternalDetailResponse`, `ExternalAccountingDetails`,
  `AccountingDetailLine`, `AccountingEntryMainListItem`, `AccountingEntryListItem`) — WebUI'nin
  `MakerCheckerListItem` bağımlılığı olmadan, yalnız ekranın kullandığı alanlarla.
- `RediscountControllerBase`'e `Accounting(int txnId)` (PartialView) + `SelectAcc(int txnId, string
  product)` (JSON, `.CoreData`) action'ları; 3 ekran controller'ı `accountingApi`'yi geçiriyor.
- `Views/Shared/Components/ManualRediscount/_AccountingDisplay.cshtml` — 3 sekmeli TabPanel + 2
  master-detail grid (WebUI'nin `.AddFor`/`.MasterDetail` desenini birebir kullanıyor).
- `mrOpenAccounting` artık `#popupAcc`'a (yok) değil, kendi kurduğu kalıcı bir `dxPopup`'a açılıyor.
- `coreAccLoad` (Module Accounting sekmesinin `onInitialized`'ı) `manual-rediscount.ts`'e eklendi,
  `ManualRediscount.coreAccLoad` olarak dışa açıldı.
- `columns.ts`'teki hazır ama diziye eklenmemiş `mrAccountingCellTemplate` artık `mrBuildFixedColumns`
  içinde — kolon görünür.
- Lokalizasyon: `accounting-*`/`extAcc-*`/`localAcc-*` anahtarları Common.UI'nin manual-rediscount
  EN/TR dosyalarına eklendi (WebUI'nin global bundle'ındaki değerlerle birebir).

⚠️ **Doğrulanmadı:** tarayıcıda hiç açılmadı. `IManualRediscountAccountingApi`/modül `SelectAcc`
route'larının gerçek backend'de var olduğu WebUI'nin ÇALIŞAN koduna bakılarak varsayıldı, canlı
istek atılmadı.

## C-1 — `ReverseType` alanı (WebUI'deki kırık JS testinin kök sebebi)

`ManualRediscountValueDatePreview`'da `ReverseType` alanı hiç yoktu ama JS testi
(`mrSetValueDateInfo … reverseType`) bekliyordu — dosyada yarım kalmış, kapatılmamış bir
`/// <summary>` bloğu vardı (özellik hiç yazılmamış). MM'in `IHelper.GetRevaluationReverseType()`si
(`Eod`/`Bod`/`Atomic`, mevcut framework parametresi) okunup alan dolduruldu; WebUI/Common.UI
mirror'larına ve iki reponun JS/TS `mrSetValueDateInfo`'suna eklendi.

**Doğrulama:** WebUI JS testleri artık **144/144** (önceden 143/144, kalan tek hata buydu).

## C-2 — Menü + permission kaydı (Common.UI)

DB'ye canlı bağlantı kurulamadı (connection string bu repoda yok, muhtemelen deploy-time
enjeksiyon). İki script `.ai-agent/outputs/`'a yazıldı, **çalıştırılmadı**:

- `2026-09-22-manuel-reeskont-commonui-permission-script.sql` — 2026-08-24'te WebUI için yazılan
  script'in birebir aynı deseni (`sp_FrameworkAddPermission`/`...Action`, idempotent), Common.UI'nin
  gerçek action listesine (Index/Load/Execute/Accounting/SelectAcc) uyarlandı. **Hazır, güvenle
  çalıştırılabilir.**
- `2026-09-22-manuel-reeskont-commonui-menu-script.sql` — `FrameworkMenu` INSERT'i, ama
  `@ParentMenuKey` **TODO** olarak bırakıldı: Common.UI'nin kendi menü ağacında (JobCron/TaxRule
  gibi ekranların altına mı, yoksa yeni bir üst gruba mı) nereye oturacağını DB'ye bakmadan
  bilemedim. Script içinde bunu bulacak SELECT sorgusu var.

## C-3 — FI / InvFund modül uçları

**Yapılamadı — engel gerçek, kapsam değil.** FI ve InvFund backend repoları bu workspace'te hiç
klonlu değil (`NetTrex.FI`/`NetTrex.InvFund` yok). Servisler gerçekten çalışıyor (appsettings'te
port 5011/5082 tanımlı, gateway'de proxy var) ama kaynak kodu burada olmadığı için Manuel
Reeskont'un o modüllere ait `IRevaluationAccountingService`-eşiti bir servisi olup olmadığı
görülemedi. `.ai-agent/manuel-reeskont/12-modul-yayilim-rehberi.md`'de de FI/InvFund hiç
geçmiyor — MM→DerivSwp→OptFX→FX sırası tamamlanmış, FI/InvFund planlanmamış bile.

## Doğrulama

- NetTrex.MM (`NetTrex.MM.Api.Services.csproj`): ✅ 0 hata (ReverseType + ReverseMessageKey).
- Treasy.Common.UI (`Treasy.Common.UI.slnx`): ✅ 0 hata (Acc. kolonu tüm katmanlarıyla).
- Treasy.Common.UI TS (`npm run typecheck`): ✅ temiz.
- WebUI JS testleri: ✅ **144/144** (önceki tur 143/144'tü, `reverseType` testi artık geçiyor).
- ⬜ WebUI (`Trex.WebUI.csproj`) ve WebUI JS testleri (MessageKey metni sonrası) — bu turun sonunda
  ayrıca doğrulandı, sonuç aşağıda commit notuna eklenecek.
- ⬜ Tarayıcı testi hiç yapılmadı (Acc. kolonu dahil hiçbir yeni parça).

## Commit durumu

⬜ **Commit/push YAPILMADI** — kullanıcı kendisi atacak.
