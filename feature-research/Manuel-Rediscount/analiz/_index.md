# Analiz Kayıtları — Ham Ajan Çıktıları

> **Bu klasörün amacı:** Her araştırma (Explore/general-purpose ajanı) çıktısının **ham hali** burada durur.
> Sohbet sıkışsa, session değişse, `/compact` olsa bile **ölçülmüş gerçekler** diskte kalır.
>
> **Kural:**
> 1. Her ajan cevabından **sonra** bu klasöre **yeni numaralı dosya** açılır: `analiz-<N>-<kisa-konu>.md`
> 2. Ajanın çıktısı **kısaltılmadan** yazılır — özet üst katman dosyalarının (01/02/03…) işi.
> 3. **Önceki dosyalar asla düzenlenmez/silinmez.** Kayıt tarihseldir.
> 4. Her dosyanın başına: tarih · hangi soruya cevap arandı · hangi repo(lar) tarandı · ⚠️ bulgu özeti.
> 5. Bu index tablosuna satır eklenir.
>
> **Neden ham saklıyoruz:** Ajan çıktısındaki dosya yolu + satır numarası referansları **kanıttır**.
> Üst katman dosyalarında özetlenirken kaybolan detay (imza, alan adı, satır no) kod yazarken gerekiyor.

---

## Kayıtlar

| # | Dosya | Tarih | Konu | Taranan repo | Kritik bulgu |
|---|-------|-------|------|--------------|--------------|
| 1 | [analiz-1-microui-shell-paketler.md](analiz-1-microui-shell-paketler.md) | 2026-08-12 | MicroUI mimarisi: Shell · SharedDependency paketi · ekran kurulumu · yetki | `Treasy.Shell` · `Treasy.MicroUI.Packages` · `Treasy.MM.UI` | ✅ Paketten **tam ekran** + **10 DevExtreme grid'li ortak bileşen** çıkıyor (RCL) · 🔴 MM.UI'de sunucu yetkisi fiilen kapalı |
| 2 | [analiz-2-mm-revaluation-backend.md](analiz-2-mm-revaluation-backend.md) | 2026-08-12 | MM'de reeskont/ters fiş altyapısı var mı | `NetTrex.MM` | ✅ **T+0 fiş + ters fiş deseni TAM KURULU** · altyapının %85'i hazır · 🔴 Fimple idempotent değil |
| 3 | [analiz-3-webui-common-yapi.md](analiz-3-webui-common-yapi.md) | 2026-08-12 | Web.UI'de ortak yapı · Refit marker'ları · runtime modül yönlendirme · yetki | `NetTrex.Web.UI` | 🔴 **Runtime base-URL resolver YOK** · permission = ControllerAdı/ActionAdı · marker isimleri tutarsız |
| 4 | [analiz-4-common-fanout-backend.md](analiz-4-common-fanout-backend.md) | 2026-08-12 | Common modüllere fan-out yapıyor mu | `NetTrex.Common` | ✅ **FAN-OUT ALTYAPISI VAR** — DailyFlow V2 = Strategy+Factory+`Task.WhenAll` · 🔴 InvFund client'ı yok · 🔴 `Task.WhenAll` kısmi hata toplamıyor · 🔴 token taşınmıyor |
| 5 | [analiz-5-dailyflow-ui.md](analiz-5-dailyflow-ui.md) | 2026-08-12 | DailyFlow UI tarafı — fan-out UI'de mi Common'da mı | `NetTrex.Web.UI` | ✅ **HİPOTEZ DOĞRULANDI** — UI'de tek uç (`: IClientCommonAPI`), modül switch'i YOK · 🔴 server-side paging YOK · union/LCD model · ⚠️ **artık kullanılmıyor** (Common iptal, ADR-MR-015) |
| 6 | [analiz-6-webui-base-component-desenleri.md](analiz-6-webui-base-component-desenleri.md) | 2026-08-12 | WebUI base component desenleri: `paymentComponent` / `LimitCheck` / `CashFlow` · modüle Refit ile erişim · eski Fx ekranının kusurları | `NetTrex.Web.UI` | 🔴 **`settings.baseUrl` modül adresi DEĞİL** (`@Url.Content("~")`) → modül seçimi zorunlu olarak sunucuda · ✅ **`moduleCode` + `dataSource.url` override CashFlow'da ZATEN var** (house convention) · ✅ `LimitCheck` = modül-parametreli ViewComponent + hidden alan deseni · 🔴 eski Fx ekranında **`RediscountStatusTypes.All` VAR** → C-01'de "All var" tarafına kanıt · 🔴 `ajax.js` hatayı yutuyor |

> ⚠️ **analiz-6 ajanla değil doğrudan yapıldı** — kullanıcı bu turda ajan istemedi. Kural gereği
> çıktı yine ham haliyle dosyalandı (kaynak kod blokları aynen).

---

## Bulgu kodlarının evi

Ham analizlerden çıkarılan **numaralı bulgular** üst katman dosyalarında yaşar:

| Kod | Ne | Dosya |
|-----|----|-------|
| `C-01` … `C-20` | Doküman çelişkileri / eksikleri | [`../01-dokuman-analizi.md`](../01-dokuman-analizi.md) § 6 · [`../04-sorular.md`](../04-sorular.md) |
| `M-01` … `M-09` | MM'e özel açık konular | [`../03-mm-backend-envanteri.md`](../03-mm-backend-envanteri.md) § 10 |
| `F-01` … `F-10` | Common/Web.UI altyapı eksikleri | [`../02-mimari-karar.md`](../02-mimari-karar.md) § 1.3 |
| `T-01` … `T-11` | MM kod tuzakları | [`../03-mm-backend-envanteri.md`](../03-mm-backend-envanteri.md) § 9 |
| `ADR-MR-001` … | Mimari kararlar | [`../02-mimari-karar.md`](../02-mimari-karar.md) § 3 |
| `R-01` … `R-10` | Riskler | [`../02-mimari-karar.md`](../02-mimari-karar.md) § 5 |
