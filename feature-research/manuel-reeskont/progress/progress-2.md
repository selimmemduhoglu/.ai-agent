# progress-2 — Mimari v2 (Common çıkarıldı) · Web.UI MD katmanı · compact sistemi

**Tarih:** 2026-08-12 · **Önceki:** [progress-1.md](progress-1.md)
**Kural:** Bu dosya progress-1'in **güncellenmiş tam hali**dir. progress-1 **düzenlenmedi**.

---

## 🔴 Bu turun en kritik olayı — MİMARİ DEĞİŞTİ (v1 → v2)

Kullanıcı, v1'de (aynı gün) verdiği "Common'a git, oradan modüllere dağıt" kararını **iptal etti**.

**Yeni mimari (v2 — GEÇERLİ):**

```text
WebUI base component (3 ekran)
   → WebUI Controller (3 adet, yetki için)
   → IManuelReeskontModuleResolver (service)
   → modül Refit client'ları DİREKT:  IClientMMAPI · IClientFxAPI · IClientFiAPI · IClientFundsAPI
   → NetTrex.MM · NetTrex.Fx · FI · InvFund
```

**Kullanıcının sözleri:**

> *"WebUI'da base component'imiz olacak ve Controller'dan backend projelerine istekler gönderilecek…
> **bu mimaride Common projesine ihtiyacımız yok.** WebUI projesi ile backend projeleri (MM-Fx-FI-InvFund)
> üzerinden gidecek şimdilik. Sonrasında ise WebUI'daki base component'i Treasy.MicroUI.Packages projesine
> alacağız… **Common projesini hiçbir şekilde kullanmayacağız.** (…) **Common yok — MicroUI projeleri yok —
> package projesi yok şimdilik.** WebUI tarafıyla başlayacağız ve işimizi bitirince Package ve MicroUI
> projelerine de kodları ekleriz ama bunu en son yapacağız."*

**Faz sırası (kullanıcı kararı):**

| Faz | Kapsam | Durum |
|---|---|---|
| **Faz 1** | `NetTrex.Web.UI` base component + Treasury ekranı + **`NetTrex.MM`** 2 endpoint | 🔵 Sıradaki (sözleşmeye bağlı) |
| **Faz 2** | Diğer modüller (`NetTrex.Fx`, FI, InvFund) + Security/Investment ekranları | ⬜ |
| **Faz 3** | Base component → `Treasy.MicroUI.Packages`, MicroUI'ler **import eder** | ⬜ |

**Uygulanabilirlik ölçüldü:** 4 modülün Refit marker'ı Web.UI'de **zaten kayıtlı**
(`Trex.WebUI/Startup.cs:58-75`); `RegisterClientWebApiRefitClients<T>` AppDomain'i taradığı için
**yeni DI kaydı / config key gerekmiyor** — sadece marker'ı implemente eden interface yazmak yeterli.

---

## ✅ YAPILDI

### A. Doküman analizi ve ilk kurulum (progress-1'den devralındı, değişmedi)

- `Manuel Reeskont v1.docx` (416 satır düz metin + **7 görsel**) baştan sona okundu
- 5 üst katman analiz dosyası: `01-dokuman-analizi.md` (C-01…C-20) · `02-mimari-karar.md` ·
  `03-mm-backend-envanteri.md` (T-01…T-11, M-01…M-09) · `04-sorular.md` · `00-PANO.md`
- 5 ajan araştırması `analiz/analiz-1…5` altına **ham** yazıldı
- Workspace MD katmanı kuruldu: `repos/CLAUDE.md` + `repos/.ai-agent/{START-HERE,PROJECT_CONTEXT,MEMORY}.md`
  + `compacts/` `sessions/` `skills/` + `manuel-reeskont/` iş klasörü
- `manuel-reeskont` skill'i kuruldu (gövde workspace'te, wrapper MM'de)

### B. Bu turda yapılan — WebUI base component araştırması

**Yeni dosya:** [`analiz/analiz-6-webui-base-component-desenleri.md`](../analiz/analiz-6-webui-base-component-desenleri.md)
(ajanla değil doğrudan yapıldı; ham kaynak blokları aynen içinde)

Ölçülen kritik gerçekler:

| Bulgu | Kanıt |
|---|---|
| 🔴 **`settings.baseUrl` modül adresi DEĞİL** — `@Url.Content("~")`, uygulamanın kök yolu | `_ErrorLayout.cshtml:54-56` · `ajax.js:1-49` |
| → **Modül seçimi zorunlu olarak sunucuda** (UI'den modül API'sine gidilemez) | aynı |
| `post(url, data, baseUrl)` 3. parametresi **hiçbir yerde geçilmiyor** — kullanılmayan esneklik | `cashflow.component.js:508,571,992` · `cashflow.form.js:990` |
| ✅ **`moduleCode` house convention** — `settings.moduleCode`, request'e `Module` olarak basılıyor | `cashflow.component.js:112`, `:983` |
| ✅ **Config-driven endpoint override deseni mevcut** | `cashflow.component.js:990-992` |
| ✅ **Modül parametreli ViewComponent deseni mevcut** + framework parametresi hidden alana basılıyor | `LimitCheckViewComponent.cs` |
| "Parametre yoksa **AKTİF**" bilinçli platform tercihi | `LimitCheckViewComponent.IsEnabled` |
| 🔴 **`ajax.js` hatayı yutuyor** — `IsSuccess === false → null`, grid sessizce boşalır | `ajax.js:20`, `:45` |
| 🔴 Eski `Load` action'ı **iki farklı şekil** döndürüyor (hata → obje, başarı → liste) | `ManuelRevaluationController.cs:77-78` |
| 🔴 **Eski Fx ekranında `RediscountStatusTypes.All` VAR** ve controller default'u o | `ManuelRevaluationController.cs:44` → **C-01'de "All var" tarafına kanıt** |
| Eski ekranda `RediscountProducts.Split(',')` + `Enum.Parse` — **`TryParse` yok, geçersiz değerde fırlatır** | `:73-76` |
| Eski ekranda **mock data yorum satırı olarak duruyor** | `:70-71` |
| Klasör `ManuelReescont` (**yazım hatalı**), namespace `Trex.WebUI.Controllers.FX.Report` | `:22` |

**Desen nesli kararı:** Web.UI'de 3 nesil var — nesil 1 tek dosya + global `const`
(`paymentComponent.js` ve kardeşleri), nesil 2 çok dosya + prefix (`limit-check/`),
nesil 3 `class` + deep-merge config + JSDoc typedef (`cashFlow/`).
**İskelet nesil 3'ten, dosya bölümlemesi + prefix nesil 2'den** (`ADR-MR-016`).
Kullanıcı emsal olarak nesil 1'i (`paymentComponent.js`) ve Limit entegrasyonunu gösterdi; ikisi de
incelendi, gerekçesi yazılarak daha ilerisi seçildi.

### C. `02-mimari-karar.md` **v2** olarak yeniden yazıldı

- **§ 0 = sürüm tablosu** (v0 arşiv / v1 iptal / v2 geçerli) + kullanıcının kararı kendi sözleriyle
- Yeni uçtan uca diyagram + "neden çalışır" kanıt tablosu + **Common'ın kaybedilen 4 şeyi ve telafisi**
- **§ 2 Base Component Tasarımı** — referans desen, config sözleşmesi taslağı, tam fiziksel yerleşim
- **§ 2.5** Faz 3'ü ucuzlatacak **4 taşınabilirlik kuralı**
- **§ 3 → 18 ADR:** ADR-MR-001 ❌ İPTAL · 004/008/012/013/014 ♻️ REVİZE ·
  **ADR-MR-015** (Common kullanılmaz) · **-016** (nesil 3 deseni) · **-017** (faz sırası) ·
  **-018** (resolver service, controller'da değil) ⭐ YENİ
- **§ 5 Riskler:** R-05 ✅ kapandı (`IClientFundsAPI` WebUI'de hazır) · **R-11** (sözleşme sürüm sapması) ·
  **R-12** (pakete taşıma bağımlılık riski) ⭐ YENİ
- **§ 6 = F-13…F-18** v2 ile açılan doğrulama boşlukları

⚠️ v1'in ölçümleri **silinmedi** — DailyFlow fan-out kanıtları emsal olarak duruyor,
`analiz-5` satırına "artık kullanılmıyor" notu düşüldü.

### D. `NetTrex.Web.UI`'ye MD yapısı kuruldu (repoda **hiçbir şey yoktu**)

Kullanıcının sorusu: *"genel tüm projeler için kullandığımız md işimizi görür mü, görmezse Web.UI'ye de kur"*
→ **Cevap: görmez.** Workspace katmanı **kısa ve cross-repo** kalmak zorunda; Web.UI'nin repo-özel
gerçekleri oraya konsa **her repodaki her oturumu** şişirirdi.

```text
NetTrex.Web.UI/CLAUDE.md                       ← 12 Hard Rule + build komutu + workspace katmanı notu
NetTrex.Web.UI/.ai-agent/PROJECT_CONTEXT.md    ← 9 bölüm: dikey akış · Refit tablosu (19 marker) ·
                                                  shared component 3 nesli · yetki modeli · grid deseni ·
                                                  js/shared haritası · doğrulanacaklar
NetTrex.Web.UI/.ai-agent/MEMORY.md             ← 5 tuzak + base component kararı + v2 mimari notu
NetTrex.Web.UI/.ai-agent/compacts/_index.md
NetTrex.Web.UI/.ai-agent/sessions/README.md
NetTrex.Web.UI/.ai-agent/skills/_index.md
NetTrex.Web.UI/.ai-agent/imports/README.md
NetTrex.Web.UI/.ai-agent/outputs/README.md
NetTrex.Web.UI/.claude/settings.local.json     ← compact hook'ları
NetTrex.Web.UI/.claude/skills/manuel-reeskont/SKILL.md   ← skill artık BURADA da tetikleniyor
```

### E. 🔴 Compact sistemi — kullanıcı eksiği fark etti, kökten kuruldu

**Kullanıcının uyarısı:** *"her compact yaptığım zaman compact çıktısını da bu md dosyasına yaz demiştim
sana, bunu yaptın mı… geriye dönük bu dosyalarda görmek istiyorum… her compact yaptığım zaman bak bakalım
klasörü var mı, varsa yeni compact file olarak yazmanı istiyorum, bunu titizlikle md dosyalarında her
seferinde çalışacak şekilde entegre et"*

**Dürüst durum tespiti:** Kural MD'de yazılıydı **ama tetiklenmedi** — `NetTrex.MM/.claude/settings.local.json`
içinde **`hooks` bloğu hiç yoktu**. `Treasy.MM.UI`'de vardı, oradaki compact'ler diske yazılmış.
Bu oturumun 2 compact'i **yazılmamıştı**.

**Kök neden analizi:** `PreCompact` hook'u tek başına **yetersiz** — sıkıştırmadan **önce** tetikleniyor,
modelin yazacak turu kalmıyor. Asıl yazma anı **`SessionStart` matcher `compact`**: sıkıştırmadan hemen
sonra, özet **context'te**, tur **var**.

**Yapılanlar:**

| İş | Durum |
|---|---|
| Format **sohbet başına klasöre** çevrildi: `compacts/<chat-slug>/{_chat.md, compact-1.md, …}` | ✅ |
| `repos/.ai-agent/compacts/_index.md` yeniden yazıldı (klasör yapısı + 3 tetikleyici + şablon + hook durum tablosu) | ✅ |
| `_precompact-instruction.md` + `_postcompact-instruction.md` yazıldı | ✅ |
| `NetTrex.MM/.claude/settings.local.json` → `PreCompact` (manual+auto) + `SessionStart:compact` | ✅ **yeni** |
| `NetTrex.Web.UI/.claude/settings.local.json` → aynısı | ✅ **yeni** |
| `Treasy.MM.UI/.claude/settings.local.json` → `SessionStart:compact` eklenmesi | ⚠️ **classifier engelledi** — kullanıcıya JSON verildi, elle ekleyecek. Mevcut `PreCompact`'i çalışıyor |
| `Treasy.MM.UI/.ai-agent/compacts/_precompact-instruction.md` yeni formata çekildi | ✅ |
| `NetTrex.MM/.ai-agent/compacts/_index.md` oluşturuldu (repoda yoktu) | ✅ |
| Workspace `CLAUDE.md` **Hard Rule 10** yeniden yazıldı (klasör akışı + 3 tetikleyici) | ✅ |
| **Bu oturumun 2 compact'i geriye dönük yazıldı** | ✅ `compacts/manuel-reeskont-analiz/{_chat,compact-1,compact-2}.md` |

⚠️ Geriye dönük yazılan compact'ler **sıkıştırma özetlerinden rekonstrüksiyon** — anlık fotoğraf kadar
zengin değil, kaybolan komut çıktıları geri getirilemedi. `_chat.md` bunu açıkça not ediyor.

### F. Skill v2'ye çekildi

- Gövde (`repos/.ai-agent/skills/manuel-reeskont.md`) yeniden yazıldı:
  başa **🔴 MİMARİ v2** bloğu · ADIM 2'de Common satırı **❌ İŞ YOK** · **ADIM 3.A = Web.UI** (7 alt bölüm,
  27 madde: fan-out / controller-yetki / JS / ViewComponent-Razor / Faz 3 hazırlığı) · 3.B MM · 3.C Faz 2 · 3.D Faz 3
- Gotcha 12 → **17**: G-02/G-04/G-05 revize · **G-13** (Common'a kod yazma) · **G-14** (klasör/namespace tuzağı) ·
  **G-15** (`const` çakışması) · **G-16** (paymentComponent nesil 1) · **G-17** (`Load` iki şekil)
- Wrapper **iki repoda**: `NetTrex.MM/.claude/skills/…` (güncellendi) + `NetTrex.Web.UI/.claude/skills/…` (**yeni**)

### G. Workspace MD'leri v2'ye hizalandı

- `repos/CLAUDE.md`: Web.UI satırı **✅** · Aktif İşler faz bazlı + 🔴 "Common kullanılmıyor" uyarısı ·
  Hard Rule 10 yeni compact akışı · MD Görevleri tablosu
- `repos/.ai-agent/PROJECT_CONTEXT.md`: çağrı yolu tablosu **2 → 3 yol** (üçüncüsü: Web.UI → çok modül doğrudan) ·
  ADR-WS-001'e **istisna notu** + ödünleşme
- `repos/.ai-agent/MEMORY.md`: v1→v2 kararı gerekçeleriyle · `baseUrl→moduleCode`'un **teknik** gerekçesi ·
  base component desen kararı · **compact hook tuzağı** · Açık İşler satırı güncel

---

## 🔵 YAPILIYOR

Yok — bu tur bitti. Sıradaki adım kullanıcı kararına bağlı.

---

## ⬜ YAPILACAK

### 🔴 BLOKE EDENLER (sözleşme kapısı — `06-sozlesme.md` DONDURULMADAN kod yazılmaz)

| # | İş | Kime |
|---|---|---|
| 1 | **C-01** Execute Selected mi Generate+Regenerate mi · `All` var mı (⚠️ eski ekranda `All` **VAR**) | İş birimi |
| 2 | **C-07** `executions` senkron mu asenkron mu (doküman ToC'unda var, gövdede **yok**) | İş birimi |
| 3 | **C-08** nihai `ExecutionsRequest` · `ReverseValueDate` nerede | İş birimi |
| 4 | **C-02** Product tekli/çoklu · Sub Product filtresi var mı | İş birimi |
| 5 | `04-sorular.md` § A'nın kalan 12 sorusu | İş birimi |
| 6 | `04-sorular.md` § B — **7 teknik karar** (C-14, C-15, M-02, M-05, M-07, M-08, R-04) | **Selim** |
| 7 | **`06-sozlesme.md` yazılıp DONDURULACAK** | Selim + iş birimi |

### Sözleşmeden BAĞIMSIZ başlanabilir

| # | İş | Repo |
|---|---|---|
| 8 | MM `eligible-transactions` **durum türetme sorgusu** tasarımı (M-08 "son aktif hareket" tanımı) | `NetTrex.MM` |
| 9 | **F-13** WebUI → modül Refit çağrısında **token taşınıyor mu?** | `NetTrex.Web.UI` |
| 10 | **F-14** WebUI'den `General:AvailableModules` okunabiliyor mu (`IFrameworkParameterHelper`) | `NetTrex.Web.UI` |
| 11 | **F-15** WebUI'de `ModuleConstants` karşılığı var mı | `NetTrex.Web.UI` |
| 12 | **F-16** WebUI Refit **timeout** değeri (C-07 senkron çıkarsa kritik) | `NetTrex.Web.UI` |
| 13 | **F-17** `Views/Shared/Components/{CashFlow,LimitCheck}/Default.cshtml` oku | `NetTrex.Web.UI` |
| 14 | **F-18** `ManuelReescontApi` wrapper'ının içi (hangi marker, hangi endpoint'ler) | `NetTrex.Web.UI` |

### Faz 1 — kod (sözleşme sonrası)

| # | İş | Repo |
|---|---|---|
| 15 | 4 Refit interface (`IManuelReeskont{Mm,Fx,Fi,InvFund}Api`) + `IManuelReeskontModuleResolver` | `NetTrex.Web.UI` |
| 16 | 3 controller (`Treasury`/`Security`/`Investment`) + `Task.WhenAll` + modül-başına `try/catch` | `NetTrex.Web.UI` |
| 17 | ViewComponent + 5 Razor view + sözleşme DTO'ları | `NetTrex.Web.UI` |
| 18 | 6 JS dosyası (`MR_` prefix, nesil 3 class deseni) + kolon config JSON'ları | `NetTrex.Web.UI` |
| 19 | Localization (tr/en) + CSS | `NetTrex.Web.UI` |
| 20 | 2 endpoint + sayfalı durum-türetmeli sorgu + satır bazlı hata + audit + çift-tıklama guard'ı | `NetTrex.MM` |
| 21 | `StateMaker` hardcoded `"SYSTEM"`/`18` düzeltmesi (T-01) | `NetTrex.MM` |
| 22 | Faz 1 uçtan uca doğrulama (Treasury ekranı + MM verisi) | ikisi |

### Faz 2 / Faz 3

| # | İş |
|---|---|
| 23 | `NetTrex.Fx` 2 endpoint — **kim yazacak? açık soru** |
| 24 | FI + InvFund endpoint'leri (ürün ekipleri) + Security/Investment ekranları |
| 25 | `RegenerateToToday` |
| 26 | Base component → `Treasy.MicroUI.SharedDependency` + `@treasy/components`; MicroUI import (`ADR-MR-017`) |

### Keşfedilen yan işler

| # | İş |
|---|---|
| 27 | ⚠️ `Treasy.MM.UI/.claude/settings.local.json`'a **`SessionStart:compact` hook'unu kullanıcı elle ekleyecek** (classifier engelledi) |
| 28 | `Treasy.MM.UI` dokümanları bayat: SharedDependency **1.0.3** yazıyor, gerçek **1.0.4-dev12** |
| 29 | `FIApi` / `WarrantApi` / `LimitApi` config key'leri var ama **backend repo'ları `repos/` altında yok** — doğrulanacak |
| 30 | Eski Fx ekranının **10 kusuru** (analiz-6 § 7) — düzeltilecek mi silinecek mi, **C-20**'ye bağlı |
| 31 | `Treasy.Shell` ile `NetTrex.Web.UI` ilişkisi net değil (Shell bu repoyu proxy'liyor mu) |

---

## Kararlar bu turda (özet)

| Karar | Gerekçe |
|---|---|
| **`NetTrex.Common` kullanılmayacak** | Kullanıcı kararı; teknik olarak da uygulanabilir (marker'lar Web.UI'de hazır) |
| Faz sırası: Web.UI+MM → diğer modüller → paket/MicroUI | Kullanıcı kararı |
| Base component iskeleti **`cashFlow/`** (nesil 3) | Platformdaki en olgun yeniden kullanılabilir bileşen; `moduleCode` + endpoint override zaten orada |
| Web.UI'ye **ayrı MD katmanı** kuruldu | Workspace katmanı cross-repo ve kısa kalmalı; repo-özel gerçekler her oturumu şişirirdi |
| Compact → **sohbet başına klasör** + `SessionStart:compact` hook'u | `PreCompact` tek başına yetmiyor (yazacak tur kalmıyor) |
| v1 ölçümleri **silinmedi**, "artık kullanılmıyor" diye işaretlendi | Neden reddedildiği bilgisi değerli; DailyFlow hâlâ platformun geçerli deseni |
