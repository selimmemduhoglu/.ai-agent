# fazlar/ — ColManagement İş Planı

> Her faz **tek** dosya. Bir işe başlamadan önce o fazın dosyası okunur.
> Faz durumları [`../00-YOL-HARITASI.md`](../00-YOL-HARITASI.md) §4'te — **durum oradan okunur**,
> burada tekrarlanmaz (iki kopya ayrışır).

| Faz | Dosya | Tek cümleyle |
|---|---|---|
| 0 | [`faz-0-kimlik-kararlari.md`](faz-0-kimlik-kararlari.md) | Modül adı, modül kodu, sayaç öneki, DB adı — script'in içine gömülenler |
| 1 | [`faz-1-repo-iskeleti.md`](faz-1-repo-iskeleti.md) | Repo dosyaları + MD omurgası |
| 2 | [`faz-2-veri-modeli.md`](faz-2-veri-modeli.md) | Excel v5 — DDL'in tek kaynağı |
| 3 | [`faz-3-backend-iskelet.md`](faz-3-backend-iskelet.md) | OptionsFX/MM yapısına göre çözüm ağacı |
| 4 | [`faz-4-db-kurulum-scriptleri.md`](faz-4-db-kurulum-scriptleri.md) | 🔴 **0-9 sıralı kurulum script'leri** |
| 5 | [`faz-5-backend-altyapi.md`](faz-5-backend-altyapi.md) | DbContext, CoreDataSlice, DI, entity base, pipeline |
| 6 | [`faz-6-annex.md`](faz-6-annex.md) | Annex ucu — ilk dikey dilim |
| 7 | [`faz-7-definition.md`](faz-7-definition.md) | CollateralDefinition + 6 alt tablo |
| 8 | [`faz-8-transaction.md`](faz-8-transaction.md) | TxnTransaction + bakiye kilidi |
| 9 | [`faz-9-muhasebe-mesaj-limit.md`](faz-9-muhasebe-mesaj-limit.md) | Değerleme · Limit · Muhasebe · Ödeme mesajı |
| 10 | [`faz-10-ui-iskelet.md`](faz-10-ui-iskelet.md) | Treasy.ColManagement.UI iskeleti + Shell kaydı |
| 11 | [`faz-11-ui-ekranlar.md`](faz-11-ui-ekranlar.md) | 3 ekran + 2 popup + detay sekmesi |
| 12 | [`faz-12-uctan-uca.md`](faz-12-uctan-uca.md) | Uçtan uca doğrulama, EOD, release note |

---

## Her faz dosyasının biçimi

```
## 1. Amaç            — tek paragraf, bu faz bitince NE olmuş olacak
## 2. Önce oku        — bu faz için gereken bilgi dosyaları (hepsi değil!)
## 3. Adımlar         — numaralı, sırayla uygulanabilir
## 4. Bitiş kriteri   — ölçülebilir; "nasıl doğrulandı" sorusunun cevabı
## 5. Tuzaklar        — bu fazda ölçülmüş, tekrarlanmaması gerekenler
## 6. Çıktı           — hangi dosyalar üretilecek, nereye
```
