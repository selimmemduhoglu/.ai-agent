# 30 — Annex tek ekran düzeni, DB'den gelen lookup'lar, Product/SubProduct (Manuel Reeskont deseni)

**Tarih:** 2026-10-22 · **Faz:** 10/11 (UI) + 6 (backend) · **Önceki:** [`29`](29-ekran-duzeltmeleri-state-filtre.md)

Kullanıcı ekranları açıp 11 madde verdi (özet): referans veri script'i `Msg 447` verdi · Counterparty/Currency/Dispute Currency boş ·
Master Agreement / Collateral Document TextArea olmasın · ValidFrom'a varsayılan · Product/SubProduct Manuel Reeskont gibi ·
Direction / MarginType / Party / RoundingMethod **DB'den** · Included Yes/No dropdown + scope alanları required ·
*"Annex'te alanları tab'lerle ayırmayalım… tek ekran üzerinde"* (Dinamik-Ekran prototipi). Ayrıca:
*"Handler'lar içinde validator'ları da yazmışsın, onları ayrı class'ta yaz ve klasör ile ayır"* · *"en son projelerin rebuild'ini al"*.

## Yapılanlar

| # | Ne | Nasıl |
|---|---|---|
| 1 | Kopya script `Msg 447 Expression type int is invalid for COLLATE clause` | `COLLATE DATABASE_DEFAULT` int anahtara (`Customer.Id`, `Portfolio.Id`) da ekleniyordu. `@Map`'e `KeyCollate` kolonu: yalnız `Currency.Code`'da collate. Tek transaction → ilk koşuda Currency de geri alınmıştı. Ön kontrol: kesişen kolonlarda tip/uzunluk uyumlu, FK yok, kaynakta NULL yok (sql-log #19-#21) |
| 2-4 | Counterparty / Currency / Dispute Currency boş | Sebep madde 1 (tablolar boş). Script tekrar koşulunca dolar. Master Agreement / Collateral Document → `TextBox`. Dispute Currency `Disabled` → `ReadOnly` (değer formData'da kalsın) + Base Currency'yi `updateData` ile takip |
| 3 | ValidFrom varsayılanı | **Mantıksal tarihin (`Trex:ColManagementLogicalDate`) ayının ilk günü** — yılın ilk günü yıl sonunda girilen annex'i ~1 yıl geriye tarihlerdi. Yalnız Create; `GetFormDefaults` ucu, `updateData("ValidFrom")` |
| 5 | Product / SubProduct | Manuel Reeskont (`TreasuryRediscountController.GetProducts` + `MmManualRediscountModuleClient`) birebir: 5 ürün (MM, Interbank Loan, FX, DerivSwp, OptFX); MM alt ürünleri **MM API `POST /product-definition/select`** (aktif, `IsEnabled`, `Pass`/`Gil` hariç, IL'de `!IsSameDay && !IsZeroRate`, `Order`); FX/DerivSwp/OptFX `treasury.json`'daki statik listeler. IL görünürlüğü MM `GET /manual-rediscount/products` — uç yoksa/erişilemezse IL gizli (Manuel Reeskont davranışı). Grid'de cascading lookup (ürün değişince alt ürün sıfırlanır). `ProductScopeCatalog` (Business) + `IColManagementMmApi : IClientMmApi` + `MMApi` config (appsettings, launchSettings, docker-compose) |
| 6-8,10 | Direction / MarginType / Party / RoundingMethod DB'den | 4 lookup tablosu `CollateralDirection`, `CollateralMarginType`, `CollateralMarginParty`, `CollateralRoundingMethod`: **`Id` = enum değeri, `Code` = iş tablosunda saklanan enum adı, `Name` = görünen**. İş tablolarındaki kolonlar ve enum'lar değişmedi (veri göçü yok). Backend `api/collateral-*/select-f-key` (RateType deseni, `CollateralLookup` klasörü — enum adıyla namespace çakışmasın diye). UI: Annex (4'ü), Definition (EligibilityDirection), Txn (MarginType). Statik TS listeleri silindi |
| 9 | Included + required | Included `Yes/No` lookup (varsayılan Yes); Product / SubProduct / MarginType / Included ve margin rule'un tüm kolonları `validationRules: required` |
| 11 | Tek ekran | Tab'lar kaldırıldı → tek `Form` + `ColCountByScreen(Lg 2/Md 2/Sm 1/Xs 1)` + 4 kart grubu (Identity · Validity · Product Scope · Party Margin Terms). Popup 1280×90vh (maxWidth 98vw). Kart CSS `annex.css`. Grid başlıkları localize (13 yeni key en+tr) |
| — | Validator ayrımı | `Api.Services`: Annex, CollateralDefinition, JobCron, Transaction/Deal → `<Feature>/Handlers/` (`git mv`, 39 dosya) + `<Feature>/Validators/` (handler içindeki 16 validator kendi dosyasına, 3 ayrı validator taşındı). Namespace `.Handlers`/`.Validators` (MM `InterbankLoan` deseni). Kayıt assembly taramasıyla (`appsettings Assemblies:Validator`) — namespace'ten bağımsız. Yeni validator dosyaları **untracked** |
| — | Rebuild hatası (UI) | `--no-incremental`: `No file exists for the asset … wwwrootundleslocalizationen.json`. Paket `Clean` `wwwroot/bundles`'ı siliyor, bundler (`BeforeTargets=Build`) StaticWebAssets çözümünden **sonra** koşuyor. Paket değiştirilmedi; `Treasy.ColManagement.UI.Web.csproj`'a bundler'ı `ResolveProjectStaticWebAssets`'ten önce koşturan tek target eklendi (H-101) |
| — | Form/editor olay bağlama | `option("onValueChanged", …)` editörün Form senkron handler'ını ezebilir → Annex Base Currency ve Txn TransactionType `.on("valueChanged")`'e çevrildi |

## Script'ler
- `Treasy.ColManagement/.ai-agent/outputs/2026-10-22-ColManagement-ReferansVeri/1-…ReferansVeriKopyala.sql` — **düzeltildi**, tekrar koşulacak.
- `Treasy.ColManagement/.ai-agent/outputs/2026-10-22-ColManagement-LookupTablolari/1-NetTrexColManagement-CollateralLookup.sql` — 4 tablo + 12 seed. Kurulum seti `1-DDL` + `6-DML`'e de eklendi.

## Doğrulama
- UI sln **0 hata**, `tsc` yalnız önceden var olan 11 TS2581; localization taraması 3 ekranda eksik 0.
- **Rebuild (`--no-incremental`)**: backend `Treasy.ColManagement.sln` **0 hata** (1759 uyarı, önceden var); UI `Treasy.ColManagement.UI.sln` düzeltmeden sonra **2 kez arka arkaya 0 hata**. Unit test projelerinde kaynak dosya yok → koşulacak test yok.
- 🔴 **Doğrulanmayan:** MM API (lokal 5041 ve cluster 32466) bu turda **erişilemedi** → alt ürün listesi canlı denenmedi; tarayıcıda denenmedi; script'ler çalıştırılmadı.

## Açık
- H-101: aynı Rebuild sorunu **Treasy.MM.UI**'da da beklenir (csproj aynı, paket aynı) — paket (`Treasy.MicroUI.Packages`) düzeltilmeli.
- H-100: MM `GET /manual-rediscount/products` yalnız `main-manuel-reeskont-development` branch'inde → merge edilene kadar Interbank Loan ürünü Annex scope'ta **görünmez**.
- Annex Preview (Display) hâlâ tab'lı ve ProductCode'u ham kod (`FXTransactions`) gösteriyor.
