# compact-4.md — Manuel Reeskont Kodlama

**Tarih:** 2026-08-17
**Önceki:** [compact-3.md](compact-3.md)

## Bu turda kullanıcı istekleri (verbatim özet)

1. (3 gün sonra) "En son nerede kaldık, ne yapmam gerekiyor, sen test edebiliyorsan test et."
2. Ben Docker ortamının (`ui-nettrex`) tamamen yanıtsız kaldığını raporladım (empty reply, boş log,
   `docker exec` "broken pipe" hatası) — Docker Desktop/WSL2 network katmanı bozulmuş olabilir dedim,
   kullanıcıya Docker Desktop restart önerdim.
3. Kullanıcı cevabı: "sen docker compose dosyalarına bakıp bağlantı saplamaya çalışıyosun galiba değil mi?
   bağlantıyı şimdi ayarladım 191 endpointlerine bağladım, buradan bağlanabiliriz." — yani DB bağlantısı
   sorunu benim şüphelendiğim network/Docker sorunu değilmiş, kullanıcı k8s cluster endpoint'ini (191) aktif etti.
4. Kullanıcı `NetTrexCommon.FrameworkMenu` sorgusu paylaştı: `TreasuryReeskontKey`/`SecurityReeskontKey`/
   `InvestmentReeskontKey` satırları DB'de **var** (Id 2551/2552/2553, IsActive=1, ParentId=129) ama
   **ekranda menüde görünmüyor**. Sordu: cache mi, yoksa ben script yazarken bazı kolonları boş bıraktığım
   (`ModuleName`, Translation* kolonları hepsi NULL) için mi menü gelmiyor?
5. Kanıt olarak MM'in çalışan menü satırlarını gösterdi (`Description like '%Mm%'`) — bunlarda
   `ModuleName` DOLU (`GENERAL`) ve Translation kolonları da çoğunlukla dolu, benim yazdığım script'te
   bu kolonlar NULL bırakılmış.
6. İstek: "senin sql skillerin var, FrameworkMenu tablosunun yapısına bak, kolon eksikliği mi menüyü
   engelliyor tespit et. Bunun dışında da testlerini yap."

## Bulgu / hipotez (doğrulanmadı — sıradaki adım)

Script 1 (`2026-08-13-ManualRediscount-Menu-Script.sql`) `ModuleName` kolonunu **INSERT listesine hiç
almamış** → NULL kalmış. Çalışan MM menü satırlarında `ModuleName = 'GENERAL'` dolu. Eğer menü render
mantığı `ModuleName` bazlı gruplama/filtreleme yapıyorsa (örn. kullanıcı profilinin gördüğü modül listesi)
NULL satır listeye hiç girmeyebilir — sessiz filtre, hata yok. **mssql-read ile şema + render kodunu
doğrulamadan bu kesin değil**, sıradaki adım bu.

## Yapılacaklar (bu turda)

- `mssql-read` skill ile `NetTrexCommon.FrameworkMenu` şemasını çek (`sys.columns`), `ModuleName`/Translation
  kolonlarının NULL olup olamayacağını (nullable mı, default var mı) gör.
- WebUI tarafında menü render/permission kodunu ara (`ModuleName` kullanılıyor mu, cache var mı — Redis).
- Kullanıcının bağlantısını değiştirdiği `docker-compose.override.yml`'i oku (artık 191 endpoint mi).
- Root-cause'u netleştir → varsa UPDATE script'i `.ai-agent/outputs/`'a yaz (kullanıcı uygular, ben
  UPDATE çalıştırmam — Hard Rule: yalnız SELECT).

## Açık kalanlar (compact-3'ten devam)

- DevExtreme reflection fix hâlâ uncommitted, build temiz, **live doğrulanmadı**.
- Login/Common-API deploy-skew sorunu hâlâ çözülmedi (kullanıcı kararı bekleniyor).
- Tier-2/Tier-3 test yazımı kararı bekleniyor.
