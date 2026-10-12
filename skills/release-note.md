# Skill — release-note (DevOps board Release Note alanları)

**Ne zaman tetiklenir:** Kullanıcı *"release note yaz"* / *"şunun release note'unu hazırla"* dediğinde.
Tetikleyici kelimeler: *release note yaz · release note hazırla · RN yaz*

**Tür:** Yazım şablonu · **Kapsam:** cross-repo (Project alanı MM/FX/Common/… hangi modülse onu taşır)

---

## 🔴 Bu skill NE ÜRETİR

Kullanıcı release note'u **DevOps board'daki bir work item formuna** yapıştırıyor (ekran görüntüsü
2026-09-09, board: Treasy release note tracker). Form **Markdown dosyası değil** — düz metin alanlarının
toplamı. Bu yüzden çıktı **iki biçimde** birlikte teslim edilir:

1. **Sohbette, alan alan, kopyala-yapıştıra hazır düz metin** — kullanıcı doğrudan forma taşıyacak.
2. **Dosyaya da yaz** (`<repo>/.ai-agent/outputs/<tarih>-<iş-adı>/…-Release-Note-Board.md`) — kayıt için,
   aynı içerik.

Önceki tur bir prose/Markdown "release note dokümanı" üretmişti (başlıklı, madde işaretli, pazarlama
diliyle) — **o biçim artık kullanılmıyor.** Board'un kendi alan yapısına uyulur.

---

## Form alanları — sırayla

Board şu alanları taşıyor (soldan sağa, yukarıdan aşağı):

| Alan | Dil | Kim doldurur | Not |
|---|:-:|---|---|
| `Title` | TR | **ben yazarım** | Kısa iş başlığı |
| `Title EN` | EN | **ben yazarım** | |
| `Jira Id` | — | **kullanıcı** | Ticket sistemi kimliği, ben bilmiyorum |
| `DevOps Item Id` | — | **kullanıcı** | Board work item no, ben bilmiyorum |
| `RN Added` | — | **kullanıcı/board** | |
| `RN ID` | — | **kullanıcı/board** | |
| `Used in Release Note` | — | **kullanıcı** | Checkbox |
| `Is Profession Services?` | — | **kullanıcı** | Checkbox — müşteriye özel PS işi mi, genel ürün mü |
| `Version No` | — | ben **önerim**, kullanıcı onaylar | Repo'daki gerçek sürümden (`git branch` / `.csproj`) |
| `Project` | — | ben **önerim** | Modül kodu: `MM` · `FX` · `Common` · … |
| `Customer` | — | **kullanıcı** | Hangi müşteri için — kod/commit'ten çıkarılamaz, sorulmadan uydurulmaz |
| `Summary` / `Summary EN` | TR+EN | **ben yazarım** | Ne değişti — üst düzey, 3-5 cümle |
| `Testing Information` / `…EN` | TR+EN | **ben yazarım** | Kaç test, hangi senaryolar korunuyor, manuel doğrulama |
| `Impact Analysis` / `…EN` | TR+EN | **ben yazarım** | Hangi ekran/akış/kolon etkileniyor, paylaşılan yüzey var mı |
| `How To?` / `…EN` | TR+EN | **ben yazarım** | Özelliği nasıl kullanacak — adım adım, kısa |
| `Definition and configuration` / `…EN` | TR+EN | **ben yazarım** | Parametre/kurulum listesi |
| `Scopekey Information` / `…EN` | TR+EN | **ben yazarım**, ⚠️ anlamı **doğrulanmadı** | Bkz. Gotcha G-01 |
| `Process Changes` / `…EN` | TR+EN | **ben yazarım** | Kullanıcının (hazine/operasyon) günlük sürecinde ne değişiyor |
| `Customer Action Required` / `…EN` | TR+EN | **ben yazarım** | Müşterinin kendi tarafında yapması gereken |
| `Ekler` | — | **kullanıcı** | Ekran görüntüsü vb. — ben dosya ekleyemem |

🔑 **8 çift (16 alan) + Title/Title EN = 18 alan benim yazdığım.** Geri kalanı board metadata'sı;
bilmediğim değeri **uydurmam**, `❓ kullanıcı dolduracak` diye işaretlerim.

---

## Yazım kuralı — YAPAY ZEKA YAZDIĞI BELLİ OLMAYACAK

Kullanıcının açık talimatı (2026-09-09): *"yapay zekanın yazdığın belli olmayacak şekilde yaz"*.
Örnek alan metni (board'dan, gerçek bir iş öğesinden — üslup emsali):

> "Money Market İşlemlerinde Referans Numaralarının Farklı Yapılması Gerekliliği, MM in productlarinin
> kontrol edildigi ProductDefinition tablosuna LogicalReferance lar ile ilgili ara bir tablo yapıldı ve
> bu tablodan bir foreign key in buradaki prdProductDefinition tablosuna verildi. Aynı işlem history
> tablosu içinde yapıldı ve ekranlara ilgili alan eklendi."

Bu örnekten çıkan üslup:

| Yap | Yapma |
|---|---|
| Düz paragraf, **markdown yok** (`**`, `-`, `#` hiçbiri) | Başlık/madde işareti/kalın yazı — form alanı düz metin |
| Kısa, teknik, geçmiş zaman eylem cümleleri ("… tablosu yapıldı", "… alan eklendi") | Pazarlama dili ("artık çok daha kolay!", "kesintisiz deneyim") |
| Türkçe teknik terim + İngilizce ad karışık (`ProductDefinition tablosu`, `foreign key`) | Her terimi zorla Türkçeleştirmek |
| "ve" ile bağlanan art arda cümleler, doğal akış | "İlk olarak… Ayrıca… Son olarak…" gibi yapay zeka sıralaması |
| Cümle uzunluğu **düzensiz** — bazen 6 kelime bazen 30 | Her cümle aynı kalıpta, simetrik |
| Doğrudan ne yapıldığını söylemek | Neden yapıldığını uzun uzun gerekçelendirmek — board bunu istemiyor |
| Küçük kusur kabul edilebilir (yazım hatası zorlanmaz ama aşırı cilalı da olmaz) | Her cümlede virgülden önce em dash (—) kullanmak — bu belirgin bir AI imzası |
| Emoji **yok**, tik/madde ikonu **yok** | 🔴✅⚠️ gibi işaretler — bunlar bu MD dosyalarında kullanılır, **board alanında değil** |

🔑 **Pratik kural:** yazdıktan sonra kendine sor — *"bunu bir mühendis 5 dakikada, düşünmeden mi yazdı,
yoksa bir sunum mu hazırladı?"* İkincisiyse tekrar yaz.

---

## Akış

1. Geliştirmenin **son hali**ni kaynaktan doğrula (kod, test sayısı, commit) — önceki
   `.ai-agent/outputs/` dosyalarından kopyalama, güncel olmayabilir.
2. `Version No` ve `Project`'i repo'dan çıkar (`git branch --show-current`, `.csproj`), **öner**.
3. `Customer`, `Jira Id`, `DevOps Item Id` bende **yok** — alanı `❓` ile işaretle, kullanıcı doldursun.
4. 8 çift + Title'ı yukarıdaki üslup kuralına göre yaz — TR önce, EN hemen altında.
5. Sohbette **alan adı: değer** biçiminde, kopyalanabilir düz metin olarak göster.
6. Aynı içeriği `<repo>/.ai-agent/outputs/<tarih>-<iş>/…-Release-Note-Board.md`'ye de yaz.

---

## Gotcha

| # | Tuzak |
|---|---|
| **G-01** | `Scopekey Information` alanının tam anlamı **doğrulanmadı** — yetkilendirme scope'u mu, arama/etiket
  anahtar kelimeleri mi, kesin değil. Bu skill onu "aramada bulunacak anahtar kelimeler" olarak yorumluyor
  (en güvenli varsayım); kullanıcı ilk kullanımda **doğru anlamı söylerse** burası güncellenir. |
| **G-02** | Önceki tur (2026-09-09'dan önce) prose/Markdown release note dosyaları üretildi
  (`outputs/2026-08-31-Eximbank-Teslim/2-Release-Note-Is-Birimi.md`). O biçim **artık kullanılmıyor** —
  yeni bir "release note yaz" isteğinde eski dosyaya bakıp o üslubu **taklit etme**, bu skill'i uygula. |
| **G-03** | `Customer` alanını asla uydurma — kod/commit'ten hangi müşteri için olduğu çıkarılamaz
  (bir geliştirme birden fazla müşteride aktif olabilir). Bilinmiyorsa `❓` bırak, kullanıcıya sor ya da
  kullanıcı kendisi doldursun. |
| **G-04** | Board alanları **düz metin** — bu MD dosyalarında kullanılan `🔴`/`✅`/tablo/kalın yazı
  **board içeriğine sızmaz**. Yalnız skill dosyasının kendisinde (bu dosya, MEMORY.md) kullanılır. |
