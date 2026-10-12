# Faz 11 — UI Ekranları

**Durum:** ⬜ · **Ön koşul:** Faz 10

## 1. Kapsam

| # | Ekran | İçerik |
|---|---|---|
| 1 | **Annex** | Liste + form · 2 popup: *Add Product*, *Add Rule* |
| 2 | **Collateral Definition** | Cash/Security varyantlı form + 6 alt tablo grid'i |
| 3 | **Collateral Transaction** | Increase/Decrease formu + Limit paneli + Near Payment Instructions |
| 4 | **Transaction Detail** (sekme) | Aynı Definition'ın hareketleri + running balance |

## 2. 🔴 Grid kuralları (ev standardı — ölçülmüş)

- **Sabit yükseklik:** `height: calc(100vh - 340px); min-height: 380px` — ve yükseklik
  **`.dx-gridbase-container`'a** verilir, grid div'ine değil (dış div'e verilince pager grid'e gömülüyor)
- **Pager:** 10 / 20 / 50 / 100
- **Client-side grid** tercih edilir: kapsam tek istekte gelir, filtre/sıralama/sayfalama/huni
  DevExtreme'e bırakılır. 🔴 **Üç şartı var:** (a) sunucuda **tavan** (`Take`) olsun ve aşıldığında
  **yüksek sesle uyar** — sessiz eksik liste sunucu filtresinden **daha** tehlikeli; (b) özet/sayaç
  şeridi de **tarayıcıda** hesaplansın; (c) yazma yolu UI tazeliğine **dayanmasın**, sunucu her
  satırı yeniden doğrulayıp reddetsin
- **Tarih biçimi tek sabitte:** `dd.MM.yyyy`. 🔴 `DevExpress.localization.formatDate(d,"shortDate")`
  **ev standardı değil** — dile göre `8/26/2026` üretir
- 🔴 `columnFixing: { enabled: true }` — hiçbir kolon `fixed: true` değilken **başlıkları siler**
  (checkbox görünür, kolon adları görünmez, konsolda hata yok)
- 🔴 `int` alan `number` sayılıp **sağa yaslanır** (başlık dahil) → durum/müşteri no gibi
  tutar-olmayan sayısal kolonda `alignment` **açık yazılır**
- ⚠️ Grid'e **aynı turda birden çok davranış ayarı eklenmez** — hangisinin bozduğu anlaşılmıyor

## 3. 🔴 Diğer tuzaklar
- 🔴 **Top-level `const` adı iki kez tanımlanamaz** — çok dosyalı bileşende dosyalar ayrı
  `<script>` ile yükleniyor ama **module değil** → `SyntaxError` → **ikinci dosya hiç çalışmaz**,
  ekran boş gelir. Yeni global fonksiyon eklemeden **önce adını grep'le**
- 🔴 **`TagBox` + `ApplyValueMode.UseButtons`** = seçim OK'a basılmadan uygulanmaz. Çoklu **filtre**
  kutusunda beklenen `Instantly`
- 🔴 **Form içindeki editöre yalnız çalışma anında verilen `dataSource` kaybolur** — başlangıç
  listesini **Razor'dan** da ver
- 🔴 **Onay penceresi "kural" değil, o an yapılacak işi yazar** — seçimin kendi durumundan türetilir,
  kesilecek kayıtları **numaralı** listeler. ⚠️ Tarih **UI'de yeniden HESAPLANMAZ**; bilinmiyorsa `-`
- ⚠️ `export: { enabled: true }` grid'in **üstüne** toolbar satırı ekler, tablo aşağı kayar

## 4. Bitiş kriteri
1. ✅ 3 ekran + 2 popup + detay sekmesi çalışıyor
2. ✅ Maker-checker akışı UI'dan uçtan uca
3. ✅ Localization TR + EN tam (kör sözlük lookup'ı **yapılmaz** — çeviri kaynağı *(EN metni + KEY bağlamı)* çifti)
4. ✅ JS testleri yeşil

## 5. Çıktı
`../progress/11-ui-ekranlar.md`
