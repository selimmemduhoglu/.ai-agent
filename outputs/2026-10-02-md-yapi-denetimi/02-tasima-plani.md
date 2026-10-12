# 02 — Taşıma Planı (SADECE PLAN — bu turda uygulanmadı)

> **Tarih:** 2026-10-02 · Girdi sayısı: **203** (workspace 74 · NetTrex.MM 79 · Treasy.MM.UI 50)
> **Kural:** hiçbir girdi silinmez · mükerrerler birleştirilir, iki metnin bilgisi de korunur ·
> uzun girdinin anlatısı (ölçüm, çürütülen hipotez, kanıt) detay dosyasına **birebir** taşınır,
> MEMORY'de yalnız **kural + link** kalır.

## Hedef kısaltmaları

| Kod | Dosya | Durum |
|---|---|---|
| `WS-MEM` | `repos/.ai-agent/MEMORY.md` | var |
| `MM-MEM` | `NetTrex.MM/.ai-agent/MEMORY.md` | var |
| `MMUI-MEM` | `Treasy.MM.UI/.ai-agent/MEMORY.md` | var |
| `WEBUI-MEM` | `NetTrex.Web.UI/.ai-agent/MEMORY.md` | 🆕 yeni |
| `COMMON-MEM` | `NetTrex.Common/.ai-agent/MEMORY.md` | 🆕 yeni |
| `REF-FIMPLE` | `repos/.ai-agent/reference/fimple.md` | 🆕 yeni, otomatik yüklenmez |
| `REF-ACC` | `repos/.ai-agent/reference/muhasebe-motoru.md` | 🆕 yeni, otomatik yüklenmez |
| `REF-DX` | `NetTrex.Web.UI/.ai-agent/reference/devextreme.md` | 🆕 yeni, otomatik yüklenmez |
| `MR-TUZAK` | `repos/.ai-agent/feature-research/manuel-reeskont/13-tuzaklar.md` | 🆕 yeni |
| `EXIM-TUZAK` | `NetTrex.MM/.ai-agent/feature-research/Eximbank-tuzaklar.md` | 🆕 yeni |
| `SKILL:<ad>` | ilgili skill dosyasının **Gotcha** bölümü | var |
| `HR:<dosya>` | o `CLAUDE.md`'nin Hard Rule listesi | var |
| `(kalır)` | girdi bulunduğu MEMORY'de kalır, yalnız kısaltılır | — |

---

# A. `repos/.ai-agent/MEMORY.md` — 74 girdi

| Kaynak | Kısa ad | Hedef | MEMORY'de kalacak sıkıştırılmış hali | Detay nereye |
|---|---|---|---|---|
| WS:20 | Solo geliştirici | `WS-MEM` §Tercihler (kalır) | 1 satır: solo geliştirici, `.ai-agent/`+`CLAUDE.md` git'e gitmez | — |
| WS:22 | Türkçe iletişim | `WS-MEM` §Tercihler (kalır) | 1 satır, olduğu gibi | — |
| WS:23 | Claude ASLA commit/push/PR | `HR:repos/.ai-agent/CLAUDE.md` yeni HR | HR'ye taşınır; MEMORY'de 1 satır + `→ HR 5` | — |
| WS:26 | MM işi `InterbankLoan:Enabled` | `MM-MEM` §Mimari + zaten `HR:Treasy.MM.UI` 13 | WS'den **çıkar**; MM-MEM'de 2 satır + `→ MMUI HR 13` | — |
| WS:29 | Büyük çıktıyı sohbete basma | `HR:repos/.ai-agent/CLAUDE.md` | HR'ye; MEMORY'den çıkar | — |
| WS:30 | Kod yorumu kısa, `<remarks>` yok | `HR:repos/.ai-agent/CLAUDE.md` | HR'ye; MEMORY'de 1 satır + link | — |
| WS:37 | Release note → skill | `SKILL:release-note` §Gotcha | 1 satır: "release note → `skills/release-note.md`" | `skills/release-note.md` |
| WS:47 | SQL script konvansiyonu → skill | `SKILL:db-script` §Gotcha | 1 satır + link | `skills/db-script.md` |
| WS:52 | MD metodolojisi kit'ten | `WS-MEM` §Kararlar (kalır) | 1 satır + kit yolu | — |
| WS:57 | Workspace md katmanı istendi | `WS-MEM` §Kararlar (kalır) | 1 satır | — |
| WS:66 | Paylaşılan framework'e davranış dokunuşu yok | `HR:repos/.ai-agent/CLAUDE.md` | HR'ye; MEMORY'den çıkar | — |
| WS:77 | Manuel Reeskont: Common kullanılmıyor | `MR-TUZAK` §Mimari kararlar | 2 satır (ADR-MR-015) + link | `MR-TUZAK` |
| WS:93 | `baseUrl` → `moduleCode` | `MR-TUZAK` §Sözleşme | 🔁 **s.105 ile BİRLEŞTİR** → 2 satır + link | `MR-TUZAK` |
| WS:99 | Base component deseni `cashFlow/` | `WEBUI-MEM` §Desenler | 2 satır + link | `WEBUI-MEM` |
| WS:105 | `baseUrl` → `moduleCode` (kopya) | 🔁 **s.93 ile birleşir** | — (ayrı girdi kalmaz) | `MR-TUZAK` |
| WS:114 | Dış uca sınır koymazsan process düşer | `EXIM-TUZAK` §Ölçümler | 3 satır: kök sebep decimal scale 28 hane; sınır kaldırıldı (kullanıcı kararı) + link | `EXIM-TUZAK` (36 satırlık anlatı birebir) |
| WS:149 | API geçidi zarfı `IsSuccess`'i eziyor | `REF-FIMPLE` §Gateway | 3 satır: `isSuccess`'e güvenme, `errorCode`+`actionRequired`+`transactionId` + link | `REF-FIMPLE` (25 satır birebir) |
| WS:174 | STJ `DateTime` yalnız ISO 8601 | `HR:repos/.ai-agent/CLAUDE.md` (HR 12 ile birleşir) | HR 12 "dış sözleşmede `DateOnly`" maddesine katılır | `WS-MEM` §Tuzaklar'da ölçüm matrisi kalır |
| WS:199 | Fimple bir fişi bir kez tersler | `REF-FIMPLE` §Fiş | 2 satır + link | `REF-FIMPLE` |
| WS:220 | Toplu yazma: `Added` artığı sonraki Commit'e karışır | `WS-MEM` §Tuzaklar (kalır, kısalır) | 3 satır: UoW tek scope, satır başına `ChangeTracker.Clear()` | `REF-ACC` (emsal akış) |
| WS:257 | Reeskont ters fişi T+1 zorunlu değil | `MR-TUZAK` §Statü | 2 satır + link | `MR-TUZAK` |
| WS:284 | "Tarih kaynağı HR12'ye taşındı" (boş kabuk) | `HR:repos/.ai-agent/CLAUDE.md` — **HR 12 YENİDEN YAZILACAK** | HR 12: kayıt damgası `IDateTimeProvider`, iş günü `GetLogicalDateAsync()`, dış sözleşme `DateOnly`; MEMORY'de yalnız ölçüm | ⚠️ kural metni kayıp — kaynak: `NetTrex.MM/.ai-agent/outputs/2026-08-31-Eximbank-Teslim/3-Senior-Kod-Incelemesi.md:1757` |
| WS:290 | CSS eşit specificity → kaynak sırası | `WEBUI-MEM` §CSS | 2 satır + link | `WEBUI-MEM` |
| WS:299 | Çok dosyalı JS top-level `const` | `HR:NetTrex.Web.UI` (yeni HR 4) | 🔁 **MM:820 ile BİRLEŞTİR**; HR'ye taşınır | `WEBUI-MEM` |
| WS:315 | `formatDate("shortDate")` ev standardı değil | `WEBUI-MEM` §Biçimleme | 2 satır | `WEBUI-MEM` |
| WS:329 | Onay penceresi "kural" yazarsa anlaşılmıyor | `MR-TUZAK` §UX | 2 satır | `MR-TUZAK` |
| WS:344 | Mutlak konumlu rozet `position` | `REF-DX` | 1 satır + link | `REF-DX` |
| WS:353 | Sistem parametresine Id değil `Code` | `SKILL:db-script` §Gotcha | 2 satır + link | `skills/db-script.md` |
| WS:368 | "Dokümanı okudum" yetmez | `SKILL:feature-researcher` §Gotcha | 2 satır | MM `skills/feature-researcher.md` |
| WS:381 | Tahakkuk motoru mutlak tutar → çift kayıt | `REF-ACC` §Tahakkuk | 3 satır + link | `REF-ACC` (23 satır birebir) |
| WS:404 | Ekran şartları = servisin ön koşulu | `MR-TUZAK` §Veri seçimi | 2 satır | `MR-TUZAK` |
| WS:414 | Yokluğu üretilebildiği ortamda test et | `SKILL:test-writer` §Gotcha | 2 satır | MM `skills/test-writer.md` |
| WS:424 | DX `Form` runtime `dataSource` kayboluyor | `REF-DX` | 2 satır + link | `REF-DX` |
| WS:439 | DX `noDataText` konumu | `REF-DX` | 1 satır | `REF-DX` |
| WS:450 | Sözleşmeye alan: Web.UI DTO kopyası unutuluyor | `HR:repos/.ai-agent/CLAUDE.md` HR 9 (etki zinciri) ile birleşir | HR 9'a bir cümle; MEMORY'den çıkar | — |
| WS:463 | `TagBox` + `ApplyValueMode.UseButtons` | `REF-DX` | 1 satır | `REF-DX` |
| WS:473 | `PrdProductDefinition` `Pass`/`Pas` | `MM-MEM` §Tuzaklar | 2 satır | `MM-MEM` |
| WS:485 | Python `open(p,'w')` dosyayı yok eder | `SKILL:db-script` §Gotcha (araç notu) | 2 satır | `skills/db-script.md` |
| WS:499 | Sunucu taraflı grid'de DX filtresi | `WEBUI-MEM` §Grid | 3 satır + link | `WEBUI-MEM` |
| WS:523 | Manuel Reeskont T+1 = +1 takvim günü | `MR-TUZAK` §Statü | 2 satır | `MR-TUZAK` |
| WS:546 | Platform plumbing'i önce ÖLÇ | `HR:repos/.ai-agent/CLAUDE.md` HR 2 ile birleşir | HR 2'ye bir cümle; MEMORY'de 1 satır emsal | `MR-TUZAK` (550 satırlık geri alma anlatısı) |
| WS:558 | DX `export` toolbar ekler | `REF-DX` | 1 satır | `REF-DX` |
| WS:566 | Grid'i sayfa boyunca uzatma house pattern | `WEBUI-MEM` §Grid | 2 satır + link | `WEBUI-MEM` |
| WS:572 | Fimple defter hesabı `ReferenceType` (3058) | `REF-FIMPLE` §Hesap | 2 satır + link | `REF-FIMPLE` |
| WS:588 | DX dialog iki tema | `REF-DX` | 2 satır | `REF-DX` |
| WS:599 | `columnFixing` başlıkları siler | `REF-DX` | 1 satır | `REF-DX` |
| WS:611 | `GetFimpleContentOrThrowAsync` hata gövdesi | `REF-FIMPLE` §Refit | 🔁 **MM:788 ile BİRLEŞTİR** → 3 satır + link | `REF-FIMPLE` |
| WS:625 | Log handler JSON varsayıyor | `WEBUI-MEM` §Log | 2 satır | `WEBUI-MEM` |
| WS:640 | DX `int` kolonu sağa yaslıyor | `REF-DX` | 1 satır | `REF-DX` |
| WS:648 | Web.UI → modül Refit timeout yok | `WEBUI-MEM` §Refit | 3 satır + link | `WEBUI-MEM` |
| WS:676 | `dotnet test` VSTest xunit.v3 bulamıyor | `HR:NetTrex.MM` (zaten HR 12'de var) | WS'den **çıkar** — MM HR 12 + Komutlar bölümünde zaten yazılı | — |
| WS:685 | EF `IsRequired()` navigation projeksiyonda | `WS-MEM` §Tuzaklar (kalır) | 🔁 **MM:614 ile BİRLEŞTİR** → 3 satır + link | `REF-ACC`? hayır → `WS-MEM` detay bloğu |
| WS:706 | `WidgetFactory` reflection `IHtmlHelper` | `WEBUI-MEM` §DevExtreme uzantısı | 2 satır | `WEBUI-MEM` |
| WS:718 | Deploy edilmiş modül API'si geride kalabilir | `WS-MEM` §Tuzaklar (kalır) | 2 satır | — |
| WS:727 | `FrameworkMenu` + Redis menü cache | `COMMON-MEM` §Cache | 3 satır + link; `SKILL:db-script` §Gotcha'ya da 1 satır | `COMMON-MEM` |
| WS:740 | Refit marker adları tutarsız | `HR:NetTrex.Web.UI` (yeni HR 5) | HR'ye; MEMORY'den çıkar | `WEBUI-MEM` |
| WS:746 | Web.UI'de runtime base-URL resolver yok | `WEBUI-MEM` §Refit | 2 satır | `WEBUI-MEM` |
| WS:751 | Web.UI permission = Controller/Action | `HR:NetTrex.Web.UI` (yeni HR 6) | HR'ye + `WEBUI-MEM` detay | `WEBUI-MEM` |
| WS:755 | MMUI'de ekran bazlı sunucu yetkisi kapalı | `MMUI-MEM` §Tuzaklar | 2 satır | `MMUI-MEM` |
| WS:759 | Compact hook'ları repo başına | `WS-MEM` §Tuzaklar (kalır, güncellenir) | 2 satır — **2026-10-02 onarımı eklenecek** (`CLAUDE_PROJECT_DIR`) | `02-onarim-ve-plan.md` |
| WS:770 | `ManualRediscount` adı Web.UI'de dolu | `MR-TUZAK` §İsimlendirme | 2 satır | `MR-TUZAK` |
| WS:781 | Doküman ↔ eski ekran çelişkisi | `SKILL:feature-researcher` §Gotcha | 2 satır | `MR-TUZAK` |
| WS:787 | Web.UI JS birim testi altyapısı kurulu değil | `WEBUI-MEM` §Test | 2 satır | `WEBUI-MEM` |
| WS:795 | `Html.DevExtreme().X()` `WidgetFactory<TModel>` | `REF-DX` | 1 satır | `REF-DX` |
| WS:801 | Web.UI JSON PascalCase | `HR:NetTrex.Web.UI` (yeni HR 7) | HR'ye | `WEBUI-MEM` |
| WS:806 | MMUI SharedDependency sürüm bayatlığı | `MMUI-MEM` §Tuzaklar | 2 satır | `MMUI-MEM` |
| WS:813 | "Base component" iddiasını global bozar | `MR-TUZAK` §Bileşen | 2 satır | `MR-TUZAK` |
| WS:817 | Seq LOCAL/CLUSTER ayırt edilemiyor | `WS-MEM` §Tuzaklar (kalır) | 3 satır + link | `WS-MEM` detay bloğu |
| WS:833 | `AccEntryEntity tracked` — çürütülen teşhis | `REF-ACC` §Tracking | 🔁 **s.940 ile BİRLEŞTİR** — çürütülen hipotez **korunur** | `REF-ACC` (her iki anlatı birebir) |
| WS:847 | Muhasebe silme: FK yok → orphan | `REF-ACC` §Silme | 3 satır + link | `REF-ACC` (22 satır birebir) |
| WS:869 | Localization sözlüğü kör uygulanmaz | `SKILL:localization-extractor` §Gotcha | 3 satır + link | MMUI `skills/localization-extractor.md` |
| WS:890 | Localization bundler şema sızdırıyor | `WEBUI-MEM` §Localization | 3 satır + link | `WEBUI-MEM` |
| WS:920 | `AddScoped<IDataContext>` + `AddTreasyDbContext` | `WS-MEM` §Tuzaklar (kalır) | 3 satır + link | `REF-ACC` |
| WS:940 | `AccEntryEntity tracked` — temiz context | 🔁 **s.833 ile birleşir** | — | `REF-ACC` |

---

# B. `NetTrex.MM/.ai-agent/MEMORY.md` — 79 girdi

| Kaynak | Kısa ad | Hedef | MEMORY'de kalacak | Detay nereye |
|---|---|---|---|---|
| MM:13 | MM↔IL izolasyonu `TxnId` ayrıklığıyla | `MM-MEM` §Mimari (kalır) | 3 satır + link | `MM-MEM` detay |
| MM:38 | `RevaluationReverse...Mapper` sabit yazıyor | `MM-MEM` (kalır) | 2 satır | — |
| MM:48 | `accEntryMain` veri anomalileri | `REF-ACC` §Anomali | 2 satır + link | `REF-ACC` |
| MM:67 | Playwright testleri `repos\Playwrite` | `MM-MEM` §Tercihler (kalır) | 1 satır — ⚠️ **hedef klasör hâlâ yok**, doğrulanmalı | — |
| MM:73 | Solo geliştirici | 🔁 WS:20 ile aynı → `WS-MEM`'e tek kopya | MM'den çıkar, `→ WS-MEM` | — |
| MM:75 | Türkçe iletişim | 🔁 WS:22 → `WS-MEM` | MM'den çıkar | — |
| MM:76 | Commit'i kendisi yapar | 🔁 WS:23 → `HR` | MM'den çıkar | — |
| MM:77 | Büyük çıktı dosyaya | 🔁 WS:29 → `HR` | MM'den çıkar | — |
| MM:83 | Eximbank tahakkuk orandan | `EXIM-TUZAK` | 2 satır + link | `EXIM-TUZAK` |
| MM:99 | Eximbank auto-verify parametreye bağlandı | `EXIM-TUZAK` | 2 satır | `EXIM-TUZAK` |
| MM:107 | Eximbank sabit alan karşılıkları | `EXIM-TUZAK` | 1 satır + link (20 satırlık tablo taşınır) | `EXIM-TUZAK` |
| MM:127 | `Instructions` 1000 değil 250 | `EXIM-TUZAK` | 2 satır | `EXIM-TUZAK` |
| MM:138 | `*CorrespondentGLCode` B2B'de boş | `EXIM-TUZAK` | 2 satır | `EXIM-TUZAK` |
| MM:147 | `TheirBeneficiary` validator'da zorunlu | `EXIM-TUZAK` | 2 satır | `EXIM-TUZAK` |
| MM:159 | `ActionId`/`FlowId` üretilmez | `EXIM-TUZAK` | 2 satır | `EXIM-TUZAK` |
| MM:173 | Yuvarlama calculator çıkışlarında | `MM-MEM` §Mimari (kalır) | 2 satır | — |
| MM:184 | Portföy `Code` değil `Path` | `MM-MEM` (kalır) | 2 satır | — |
| MM:197 | Parametre DB'de yokken uç çalışabilir (cache) | `MM-MEM` (kalır) | 2 satır | — |
| MM:204 | `UseSubFundSource` `UseFundSource`'a bağlı | `MM-MEM` (kalır) | 1 satır | — |
| MM:211 | 2 ondalık kuralı kolonda değil kodda | `REF-FIMPLE` §Hassasiyet | 🔁 **MM:514 ile BİRLEŞTİR** → 3 satır + link | `REF-FIMPLE` |
| MM:226 | `FlowId=0` otomatik yolların normali | `MM-MEM` (kalır) | 1 satır | — |
| MM:235 | `TxnMMDetail` satır sırası → para hatası | `MM-MEM` (kalır) | 3 satır + link | `REF-ACC` |
| MM:249 | `ExternalSourceId=160` tanım tablosunda yok | `EXIM-TUZAK` | 2 satır | `EXIM-TUZAK` |
| MM:257 | Eximbank ucu token'sız çağrılabiliyor | `EXIM-TUZAK` + ⚠️ **açık güvenlik bulgusu** | 2 satır, açık işaretli | `EXIM-TUZAK` |
| MM:264 | Kök portföy kullanımı anormal değil | `MM-MEM` (kalır) | 1 satır | — |
| MM:270 | `MaturityAmount` ↔ `InterestRate` denetlenmiyor | `MM-MEM` (kalır) | 2 satır | — |
| MM:284 | `SubFundSourceCode` Fimple havuzu | `REF-FIMPLE` §Havuz | 3 satır + link | `REF-FIMPLE` |
| MM:302 | Fimple muhabirde üç satır da `IsDefault` | `REF-FIMPLE` §Muhabir | 2 satır | `REF-FIMPLE` |
| MM:318 | `DoVerify` idempotent değil → çift fiş | `REF-ACC` §İdempotans | 3 satır + link | `REF-ACC` |
| MM:331 | `SyncMessage` üzerine yazılıyor | `MM-MEM` (kalır) | 2 satır | — |
| MM:339 | `CreateMmFileHandler` ilk hatada iptal | `MM-MEM` (kalır) | 2 satır | — |
| MM:348 | `.claude/skills` 13 klasörün 10'u boş | `MM-MEM` (kalır, **güncellenir**) | 1 satır — 2026-10-02: 15 klasörün 9'u boş | `02-onarim-ve-plan.md` |
| MM:356 | Kanonik işlem açma `NetTrex.MM.Common`'da | `MM-MEM` §Mimari (kalır) | 2 satır | — |
| MM:372 | Eximbank: ara tablo yok, istek tekli | `EXIM-TUZAK` | 2 satır | `EXIM-TUZAK` |
| MM:387 | Log tablosu ayrı DbContext | `MM-MEM` (kalır) | 2 satır | — |
| MM:396 | Dış sistemde iş alanına göre tekilleştirme yok | `EXIM-TUZAK` | 2 satır | `EXIM-TUZAK` |
| MM:408 | `ValueDate != LogicalDate` guard'ı yazma | `MM-MEM` (kalır) | 2 satır | — |
| MM:415 | Validator bypass → `TradeDate` şartı kaybolur | `MM-MEM` (kalır) | 2 satır | — |
| MM:421 | Eximbank 3. tur kararları | `EXIM-TUZAK` | 1 satır + link (zaten tasarım dokümanına link veriyor) | tasarım dok. § 11 |
| MM:442 | Eximbank servis kararları (40 satır) | `EXIM-TUZAK` | 2 satır + link | `EXIM-TUZAK` (40 satır birebir) |
| MM:482 | ADR-001 `ProductSourceType` | `MM-MEM` §Mimari (kalır) | 1 satır, zaten kısa | — |
| MM:483 | Tawarruq cross-module | `MM-MEM` (kalır) | 2 satır | — |
| MM:488 | InterbankLoan modülü opsiyonel | `HR:NetTrex.MM` yeni HR | HR'ye; MEMORY'de 1 satır + `→ HR` | — |
| MM:489 | IL Havuz entegrasyonu | `MM-MEM` (kalır) | 2 satır | — |
| MM:493 | Tawarruq lisans flag'i appsettings | `MM-MEM` (kalır) | 2 satır | — |
| MM:496 | `AGENT.md` kaldırıldı | `MM-MEM` (kalır, tarihsel) | 1 satır | — |
| MM:503 | MM/IL default portfolio system parameter | `MM-MEM` (kalır) | 2 satır | — |
| MM:507 | Eximbank sözleşmesi bizim | `EXIM-TUZAK` | 1 satır | `EXIM-TUZAK` |
| MM:514 | Fimple 2 ondalık: command factory'ye | 🔁 **MM:211 ile birleşir** → `REF-FIMPLE` | — | `REF-FIMPLE` |
| MM:534 | İdempotans `SELECT` ile kurulmaz | `HR:NetTrex.MM` yeni HR + detay | 3 satır + link | `MM-MEM` detay |
| MM:556 | `Code`/`Name`/`ExternalCode` üç ayrı şey | 🔁 **WS:353 ile BİRLEŞTİR** → `SKILL:db-script` §Gotcha | 2 satır + link | `skills/db-script.md` |
| MM:595 | `TxnLoan`'da `ProductDefinitionId` | `MM-MEM` (kalır) | 2 satır | `reference/tablo-rehberi.md` |
| MM:606 | `TxnLoan`'da `Valuations` karşılığı yok | `MM-MEM` (kalır) | 2 satır | `reference/tablo-rehberi.md` |
| MM:614 | EF `IsRequired()` navigation | 🔁 **WS:685 ile birleşir** → `WS-MEM` | MM'den çıkar, `→ WS-MEM` | `WS-MEM` detay |
| MM:641 | `AccEntryMain` paylaşılan, `ProductCode` ayırmıyor | `REF-ACC` §Tablo | 3 satır + link | `REF-ACC` (38 satır birebir) |
| MM:680 | `TxnLoan` faiz dönemi yapısal farklı | `MM-MEM` (kalır) | 2 satır | `reference/tablo-rehberi.md` |
| MM:690 | Mapster unflatten phantom entity — FIXED | `MM-MEM` §Tuzaklar (kalır) | 3 satır + link | `MM-MEM` detay (32 satır) |
| MM:722 | Kafka entity + `ValueGeneratedNever()` — FIXED | `MM-MEM` (kalır) | 2 satır | — |
| MM:748 | Kafka consumer tek handler hatası — FIX'lenmedi | `MM-MEM` §Açık İşler | 2 satır, **açık** işaretli | — |
| MM:757 | ProductDefinition uniqueness — FIXED | `MM-MEM` (kalır) | 2 satır | — |
| MM:769 | ProductDefinition Insert kapalı | `MM-MEM` (kalır) | 1 satır | — |
| MM:778 | `JobCronBase.Id` convention sapması | `MM-MEM` (kalır) | 2 satır | — |
| MM:788 | Non-generic `FimpleResponseBase` yutuyor | 🔁 **WS:611 ile birleşir** → `REF-FIMPLE` | MM'den çıkar, `→ REF-FIMPLE` | `REF-FIMPLE` |
| MM:798 | `MathExtension.Pow` OverflowException | `MM-MEM` (kalır) | 2 satır | — |
| MM:806 | `TxnLoan`/`History` trigger senkron | `MM-MEM` (kalır) | 2 satır | `reference/tablo-rehberi.md` |
| MM:812 | Accounting mapper `Map`/`MapLoan` ikilisi | `REF-ACC` §Mapper | 2 satır + link | `REF-ACC` |
| MM:817 | EF Core migrations altyapısı yok | `HR:NetTrex.MM` Komutlar bölümü | 1 satır | — |
| MM:820 | WebUI shared-script `const` çakışması | 🔁 **WS:299 ile birleşir** → `HR:NetTrex.Web.UI` | MM'den çıkar | `WEBUI-MEM` |
| MM:822 | `TxnMM` Update sistem alanlarını NULL'a — FIXED | `MM-MEM` (kalır) | 2 satır | — |
| MM:831 | `IsVerifiedState` silinmiş işlemi onaylı sayar | `MM-MEM` (kalır) | 2 satır | — |
| MM:843 | `switch` kol sırası iş kuralını eziyor | `MM-MEM` (kalır) | 2 satır | — |
| MM:850 | `*PaymentAccountingGL` yalnız `ValueDate==LogicalDate` | `REF-ACC` §GL | 3 satır + link | `REF-ACC` (17 satır) |
| MM:867 | Preview "We"/"They" ayrı kaynaklar | `EXIM-TUZAK` | 2 satır | `EXIM-TUZAK` |
| MM:880 | `isSuccess` semantiği + idempotent retry | `REF-FIMPLE` §Sözleşme | 3 satır + link | `REF-FIMPLE` |
| MM:900 | `ResponseBase.Message` türetilmiş, suppress edilemez | `REF-FIMPLE` §Sözleşme | 2 satır | `REF-FIMPLE` |
| MM:922 | `stage` alanını başarıda taşıma | `MM-MEM` (kalır) | 2 satır | — |
| MM:930 | `isVerified` = `state=="Verified"` | `MM-MEM` (kalır) | 1 satır | — |
| MM:936 | 1.35→1.33 backport: opening accounting farklı | `REF-ACC` §Sürüm | 3 satır + link | `REF-ACC` (24 satır) |
| MM:960 | 1.34 `Accounting/Opening` test klasörü ölü | `MM-MEM` §Açık İşler | 2 satır, **açık** işaretli | — |

---

# C. `Treasy.MM.UI/.ai-agent/MEMORY.md` — 50 girdi

| Kaynak | Kısa ad | Hedef | MEMORY'de kalacak | Detay nereye |
|---|---|---|---|---|
| UI:15 | Solo geliştirici | 🔁 WS:20 → `WS-MEM` | çıkar | — |
| UI:17 | Türkçe iletişim | 🔁 WS:22 → `WS-MEM` | çıkar | — |
| UI:18 | Commit'i kendisi yapar | 🔁 WS:23 → `HR` | çıkar | — |
| UI:19 | Büyük çıktı dosyaya | 🔁 WS:29 → `HR` | çıkar | — |
| UI:20 | MD ile ilerleme ister | `MMUI-MEM` §Tercihler (kalır) | 2 satır | — |
| UI:22 | Playwright testi YAZMA | `HR:Treasy.MM.UI` yeni HR | HR'ye; MEMORY'de 1 satır | — |
| UI:32 | ADR-001 proje adı | `MMUI-MEM` (kalır) | 1 satır, zaten link | — |
| UI:33 | ADR-002 Web.UI ekranları paralel | `MMUI-MEM` (kalır) | 1 satır | — |
| UI:34 | ADR-003 JS→TS birebir port | `MMUI-MEM` (kalır) | 1 satır | — |
| UI:38 | Docker compose `src/` + `.yaml` | `MMUI-MEM` (kalır) | 2 satır | — |
| UI:53 | Localization `tr` gerçekten Türkçe | `SKILL:localization-extractor` §Gotcha | 2 satır | MMUI skill |
| UI:62 | Paket-dışı 3 bileşen MM'e taşındı | `MMUI-MEM` (kalır) | 2 satır + link | `inventory/shareddependency-yuzey.md` |
| UI:69 | IL ekranı `InterbankLoan:Enabled` guard'lı | 🔁 WS:26 + `HR:Treasy.MM.UI` 13 ile birleşir | 1 satır + `→ HR 13` | — |
| UI:74 | `bundles/localization/*.json` git'e girer | `MMUI-MEM` (kalır) | 1 satır | — |
| UI:83 | Onaylı sapma — `TransactionNote` | `screens/mm-transaction.md` | 1 satır + link | `screens/` |
| UI:91 | Onaylı sapma — Swift butonu | `screens/mm-transaction.md` | 1 satır + link | `screens/` |
| UI:100 | Onaylı sapma — Tawarruq null guard | `screens/tawarruq.md` | 1 satır + link | `screens/` |
| UI:112 | Sihirli state → `FlowState` sabitleri | `MMUI-MEM` (kalır) | 1 satır | — |
| UI:118 | PreCompact hook MM'e kopyalanmadı | `MMUI-MEM` (kalır, **güncellenir**) | 1 satır — 2026-10-02: tüm repolarda onarıldı | `02-onarim-ve-plan.md` |
| UI:129 | Razor inline `new JS(...)` bridge zorunlu | `SKILL:razor-view-migrator` §Gotcha | 3 satır + link | MMUI skill |
| UI:144 | `$.post` → paket `post()` content-type | `SKILL:js-to-ts-porter` §Gotcha | 3 satır + link | MMUI skill |
| UI:156 | `groupItems.AddGroup()` ≠ `items.AddGroup()` | `SKILL:razor-view-migrator` §Gotcha | 2 satır | MMUI skill |
| UI:166 | `bridge-audit.js` iki biçimi kaçırıyordu | `tools/` yanına README notu | 1 satır | `tools/bridge-audit.js` başlık yorumu |
| UI:177 | Web.UI Verify/Reject `SecurityId` NULL | `WEBUI-MEM` §MM ekranları | 2 satır + link | `WEBUI-MEM` |
| UI:191 | Paket 1.0.3 `IClientLimitApi` DI yok | `MMUI-MEM` (kalır) | 2 satır | — |
| UI:203 | `dotnet run --launch-profile` env ezer | `HR:Treasy.MM.UI` Komutlar | 1 satır | — |
| UI:210 | Parite regex'ini önce gözle doğrula | `SKILL:parity-reviewer` §Gotcha | 2 satır | MMUI skill |
| UI:219 | Vitest testleri `wwwroot/js` içine koyma | `MMUI-MEM` (kalır) | 1 satır | — |
| UI:227 | Port edilenin beklenen davranışı = kaynağınki | 🔁 UI:34 (ADR-003) ile birleşir | 1 satır + `→ ADR-003` | — |
| UI:236 | Göreli `<partial>` controller adına göre | `SKILL:razor-view-migrator` §Gotcha | 2 satır | MMUI skill |
| UI:245 | Paket `/Health` ucu sağlamıyor | `MMUI-MEM` (kalır) | 1 satır | — |
| UI:248 | `[AllowAnonymous]` paket pipeline'ında yetmiyor | `MMUI-MEM` (kalır) | 2 satır | — |
| UI:255 | helm `values-katilim`/`yatirim` takas gelmiş | `MMUI-MEM` (kalır) | 2 satır | — |
| UI:262 | Shared bileşen listesi kullanımla doğrulanmalı | `SKILL:shared-component-porter` §Gotcha | 2 satır | MMUI skill |
| UI:268 | `bridge-audit.js` bundle başına tek bridge | 🔁 **UI:166 ile BİRLEŞTİR** | 1 satır | `tools/` |
| UI:274 | `module.bridge` + `export const` = `undefined` | `SKILL:js-to-ts-porter` §Gotcha | 2 satır | MMUI skill |
| UI:287 | Localization key diff'inde iki tuzak | `SKILL:localization-extractor` §Gotcha | 3 satır + link | MMUI skill |
| UI:301 | Paket JS'siz bileşenin localization'ını veriyor | `SKILL:localization-extractor` §Gotcha | 2 satır | MMUI skill |
| UI:309 | Modül-özel global `local-globals.d.ts` | `MMUI-MEM` (kalır) | 1 satır | — |
| UI:317 | `UIConstants` için `@using` şart | `SKILL:razor-view-migrator` §Gotcha | 1 satır | MMUI skill |
| UI:322 | `MicroUI.Base` `package-lock.json` kırık | `MMUI-MEM` §Paket (kalır) | 2 satır | — |
| UI:328 | Rehberdeki `BaseController` namespace'e bağımlı | `MMUI-MEM` §Paket (kalır) | 1 satır | — |
| UI:334 | `GlobalSettingsService` CommonApi'siz açılmaz | `MMUI-MEM` (kalır) | 2 satır | — |
| UI:340 | `MicroUI.Base` azure-pipelines yol hatası | `MMUI-MEM` §Paket (kalır) | 1 satır | — |
| UI:344 | Micro UI View'da yalnız `<ShellContent>` | `SKILL:razor-view-migrator` §Gotcha | 2 satır | MMUI skill |
| UI:351 | `TS2456 MessageBundle` döngüsel | `MMUI-MEM` (kalır) | 2 satır | — |
| UI:357 | `ToTreasyDataGrid` CRUD popup üretmez | `SKILL:razor-view-migrator` §Gotcha | 2 satır | MMUI skill |
| UI:361 | helm `AccountingApi` rename edilmemeli | `MMUI-MEM` (kalır) | 1 satır | — |
| UI:373 | Taşıma bitince Web.UI ekranlarının kaderi | `MMUI-MEM` §Açık İşler (kalır) | 1 satır | — |
| UI:374 | Test paketi `repos\PlayWright` | `MMUI-MEM` §Açık İşler (kalır) | 1 satır — ⚠️ **klasör hâlâ yok** | — |

---

# D. Sayım kontrolü

## D.1 Kaynak başına: girdi sayısı = hedeflere dağıtılan toplam

### `repos/.ai-agent/MEMORY.md` — 74

| Hedef | Adet |
|---|---:|
| `WS-MEM` (kalır) | 9 |
| `WEBUI-MEM` | 12 |
| `REF-DX` | 9 |
| `MR-TUZAK` | 9 |
| `REF-FIMPLE` | 4 |
| `REF-ACC` | 4 |
| `HR:*` (Hard Rule'a terfi) | 11 |
| `SKILL:*` §Gotcha | 7 |
| `MM-MEM` | 2 |
| `MMUI-MEM` | 2 |
| `COMMON-MEM` | 1 |
| `EXIM-TUZAK` | 1 |
| 🔁 başka girdiyle birleşir (ayrı satır kalmaz) | 3 |
| **TOPLAM** | **74** ✅ |

### `NetTrex.MM/.ai-agent/MEMORY.md` — 79

| Hedef | Adet |
|---|---:|
| `MM-MEM` (kalır) | 37 |
| `EXIM-TUZAK` | 17 |
| `REF-ACC` | 7 |
| `REF-FIMPLE` | 5 |
| `HR:NetTrex.MM` | 3 |
| 🔁 `WS-MEM`/`HR`'ye birleşir (4 tercih girdisi) | 4 |
| 🔁 başka girdiyle birleşir | 5 |
| `SKILL:db-script` | 1 |
| `WEBUI-MEM` | 0 (MM:820 birleşmede) |
| **TOPLAM** | **79** ✅ |

### `Treasy.MM.UI/.ai-agent/MEMORY.md` — 50

| Hedef | Adet |
|---|---:|
| `MMUI-MEM` (kalır) | 24 |
| `SKILL:*` §Gotcha | 13 |
| `screens/*` | 3 |
| `HR:Treasy.MM.UI` | 2 |
| `WEBUI-MEM` | 1 |
| `tools/` | 1 |
| 🔁 birleşir / `WS-MEM`'e gider | 6 |
| **TOPLAM** | **50** ✅ |

**Genel toplam: 74 + 79 + 50 = 203** ✅

## D.2 Birleştirilecek mükerrer kümeler (hiçbir bilgi silinmez)

| # | Küme | Birleşme yeri | Korunacak |
|---|---|---|---|
| 1 | WS:93 + WS:105 (`baseUrl`→`moduleCode`, birebir aynı) | `MR-TUZAK` | tek metin yeterli; tarih ve onay notu korunur |
| 2 | WS:685 + MM:614 (EF `IsRequired()` navigation) | `WS-MEM` | WS'deki mekanizma + MM'deki **canlı veri emsali** birlikte |
| 3 | WS:833 + WS:940 (`AccEntryEntity tracked`) | `REF-ACC` | **çürütülen hipotez (833) silinmez** — "neden bu değil" kaydı değerli |
| 4 | WS:299 + MM:820 (shared-script `const`) | `HR:NetTrex.Web.UI` + `WEBUI-MEM` | WS'deki "sayfa hiç açılmaz" + MM'deki prefix önerisi |
| 5 | WS:611 + MM:788 (`GetFimpleContentOrThrowAsync`) | `REF-FIMPLE` | WS'deki "JSON sanıyordu" + MM'deki overload ayrımı |
| 6 | WS:353 + MM:556 (`Code`/`Name`/`ExternalCode`) | `SKILL:db-script` | ikisinin de örnekleri |
| 7 | MM:211 + MM:514 (Fimple 2 ondalık) | `REF-FIMPLE` | "kolonda değil kodda" + "command factory'ye" |
| 8 | UI:166 + UI:268 (`bridge-audit.js` sayım hataları) | `tools/` README | iki ayrı hata biçimi de |
| 9 | UI:227 + UI:34 (port davranışı = kaynağınki) | `MMUI-MEM` ADR-003 | — |
| 10 | Solo/Türkçe/commit/çıktı dörtlüsü (WS:20,22,23,29 · MM:73,75,76,77 · UI:15,17,18,19) | `WS-MEM` + `HR` tek kopya | 12 girdi → 4 kalır |

## D.3 Taşıma sonrası tahmini boyutlar

| Dosya | Şimdi (satır / ~token) | Tahmin (satır / ~token) | Değişim |
|---|---|---|---|
| `repos/.ai-agent/MEMORY.md` | 967 / 20 386 | **~190 / ~4 100** | −80% |
| `NetTrex.MM/.ai-agent/MEMORY.md` | 987 / 22 534 | **~250 / ~5 600** | −75% |
| `Treasy.MM.UI/.ai-agent/MEMORY.md` | 375 / 7 392 | **~150 / ~3 000** | −59% |
| `NetTrex.Web.UI/.ai-agent/MEMORY.md` | — | **~90 / ~2 000** | 🆕 |
| `NetTrex.Common/.ai-agent/MEMORY.md` | — | **~20 / ~450** | 🆕 |
| `repos/.ai-agent/CLAUDE.md` | 156 / 2 292 | **~185 / ~2 800** | +11 Hard Rule |
| `reference/fimple.md` | — | ~330 / ~8 000 | 🆕 **yüklenmez** |
| `reference/muhasebe-motoru.md` | — | ~300 / ~7 300 | 🆕 **yüklenmez** |
| `NetTrex.Web.UI/.ai-agent/reference/devextreme.md` | — | ~160 / ~3 500 | 🆕 **yüklenmez** |
| `feature-research/manuel-reeskont/13-tuzaklar.md` | — | ~220 / ~5 500 | 🆕 **yüklenmez** |
| `NetTrex.MM/.ai-agent/feature-research/Eximbank-tuzaklar.md` | — | ~420 / ~10 500 | 🆕 **yüklenmez** |

### Taşıma sonrası oturum başı yük tahmini

| Başlatma dizini | Şimdi | Taşıma sonrası | Bütçe 15k |
|---|---:|---:|:--:|
| `repos\` | ~25 994 | **~10 300** | ✅ |
| `repos\NetTrex.MM` | ~54 930 | **~20 000** | ❌ +5 000 |
| `repos\Treasy.MM.UI` | ~42 971 | **~20 400** | ❌ +5 400 |
| `repos\NetTrex.Web.UI` | ~25 994 | **~12 400** | ✅ |
| `repos\NetTrex.Common` | ~25 994 | **~10 800** | ✅ |

> MM ve MMUI'de kalan aşımın kaynağı `PROJECT_CONTEXT.md` (4 287 / 2 295 tok) ve
> MMUI'de `MIGRATION.md` (4 725 tok). Bu dosyalar bu planın kapsamında **değil** —
> ayrı bir aşamada ele alınmalı.

---

# E. `feature-research/sql-log/` mükerrer ağacı — birleştirme planı

**Durum:** `repos/.ai-agent/sql-log/` (13 iş) ile `repos/.ai-agent/feature-research/sql-log/` (10 iş)
aynı ağacın iki kopyası. 10 iş klasörü (20 md) **birebir aynı**; 3 iş yalnız yeni konumda;
`_index.md` iki yerde **farklı**.

## E.1 Klasör eşlemesi

| İş klasörü | `sql-log/` | `feature-research/sql-log/` | Karar |
|---|:--:|:--:|---|
| `accengine-policy-silme` | ✅ | ✅ birebir aynı | eski kopya **arşive**, yeni kalır |
| `eximbank-fundsource-flag` | ✅ | ✅ birebir aynı | aynı |
| `manuel-reeskont-analiz` | ✅ | ✅ birebir aynı | aynı |
| `manuel-reeskont-commonui-parity` | ✅ | ✅ birebir aynı | aynı |
| `manuel-reeskont-kodlama` | ✅ | ✅ birebir aynı | aynı |
| `mm-fimple-sync-gl-null` | ✅ | ✅ birebir aynı | aynı |
| `mm-kafka-notification-fix` | ✅ | ✅ birebir aynı | aynı |
| `productdefinition-edit-fix` | ✅ | ✅ birebir aynı | aynı |
| `swap-mm-rapor` | ✅ | ✅ birebir aynı | aynı |
| `txnmmdetail-int64-cast` | ✅ | ✅ birebir aynı | aynı |
| `collateral-db-isimlendirme` | ✅ | ❌ | dokunulmaz |
| `collateral-db-nesne-envanteri` | ✅ | ❌ | dokunulmaz |
| `db-mimarisi-tanim-islem-akisi` | ✅ | ❌ | dokunulmaz |

## E.2 `_index.md` birleştirmesi

İki `_index.md` **farklı**. Birleştirme kuralı:

1. `sql-log/_index.md` (70 satır) **taban** alınır — 13 işi kapsıyor.
2. `feature-research/sql-log/_index.md` (67 satır) satır satır karşılaştırılır.
3. Yalnız eski dosyada bulunan her satır (açıklama farkı, ek not, farklı tarih)
   taban dosyaya **eklenir** — üzerine yazılmaz.
4. Çakışan satırlarda **her iki metin de** korunur: yeni metin ana satır,
   eski metin alt satırda `(önceki kayıt: …)` olarak.
5. Birleşme sonrası `sql-log/_index.md`'nin başına şu not düşülür:
   `> 2026-10-02: feature-research/sql-log/_index.md ile birleştirildi.`

## E.3 Eski ağacın akıbeti — **silme yok**

| Adım | İşlem |
|---|---|
| 1 | `_index.md` birleştirmesi yapılır (E.2) |
| 2 | 10 mükerrer klasörün yeni konumdaki kopyalarının byte-birebir olduğu `diff -rq` ile **yeniden doğrulanır** |
| 3 | `feature-research/sql-log/` → `repos/.ai-agent/_arsiv/2026-10-02-sql-log-eski-konum/` altına **taşınır** (silinmez) |
| 4 | Taşınan klasörün içine `OKU-BENI.md`: neden taşındı, hangi klasörler birebir aynı, güncel konum neresi |
| 5 | `sql-log/_index.md`'ye bir satır: eski konumun arşiv yolu |

**Kazanç:** 21 md · 745 295 char · ~186 300 token workspace `.ai-agent` ağacından çıkar
(dosyalar diskte kalır, otomatik yüklenen hiçbir şeyi etkilemez — bu ağaç zaten yüklenmiyordu,
kazanç **arama gürültüsü** ve `.ai-agent` git deposunun boyutu).

---

# F. Uygulama sırası (önerilen)

| # | Adım | Risk | Geri alınabilir mi |
|---|---|---|---|
| 1 | `REF-FIMPLE`, `REF-ACC`, `REF-DX` dosyalarını **oluştur** (içerik kopyala, MEMORY'den silme) | yok | evet |
| 2 | `WEBUI-MEM`, `COMMON-MEM` + `.ai-agent/` iskeletlerini kur | yok | evet |
| 3 | `MR-TUZAK`, `EXIM-TUZAK` oluştur (içerik kopyala) | yok | evet |
| 4 | Skill `Gotcha` bölümlerine ekle | düşük | evet |
| 5 | Hard Rule terfilerini `CLAUDE.md`'lere yaz (⚠️ WS:284 → **HR 12 yeniden inşa, kullanıcı onayı gerekir**) | orta | evet |
| 6 | Mükerrer kümeleri birleştir (D.2) | orta | evet |
| 7 | **Ancak 1–6 doğrulandıktan sonra** MEMORY'lerden kısalt | yüksek | git ile |
| 8 | `sql-log` birleştirmesi (E) | düşük | evet |

> Her adımdan sonra `.ai-agent` git deposunda ayrı commit önerilir; 7. adım öncesi
> `02-tasima-plani.md` ile satır satır karşılaştırma yapılmalı.
