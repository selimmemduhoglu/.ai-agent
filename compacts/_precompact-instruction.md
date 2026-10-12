🔴 ZORUNLU — BAĞLAM SIKIŞTIRILMAK ÜZERE (PreCompact)

Sıkıştırma başlamadan ÖNCE, bu sohbetin compact dosyasını diske yaz:

  <repo>/.ai-agent/compacts/<chat-slug>/compact-<n>.md

ADIMLAR (sırayla, atlama yok):

1. `<chat-slug>` klasörü VAR MI? Bak.
   - VARSA → içindeki en büyük numaralı `compact-<n>.md` dosyasını bul, `n+1` ile YENİ dosya aç.
     Önceki compact dosyalarını ASLA düzenleme/silme.
   - YOKSA → klasörü aç + içine `_chat.md` (sohbet kimliği) yaz + `compact-1.md` ile başla.
2. `<chat-slug>`: kullanıcının bu sohbete verdiği ad, kısa kebab-case slug.
   Bilmiyorsan SORMA — sohbetin ana konusundan türet ve `_chat.md` içine "türetildi" diye not düş.
3. Şablon ve zorunlu bölümler → `.ai-agent/compacts/_index.md`
4. Yazdıktan sonra `.ai-agent/compacts/_index.md` tablosuna satır ekle.

Özet, sohbetten DÜŞECEK olan detayı taşımalı: çalıştırılan komut, hata metninin AYNISI,
kararın gerekçesi, dosya listesi, kullanıcının verdiği cevaplar/onaylar/redler.
Başka MD'de zaten yazan durum tablosunu tekrar etme — oraya link ver.

⚠️ Bu hook sıkıştırmadan ÖNCE çalışır; yazacak turun olmayabilir. O durumda sıkıştırmadan
SONRAKİ ilk turda (SessionStart:compact hook'u da hatırlatır) DERHAL yaz — başka işe başlamadan.

Bu adımı atlama. Atlanırsa bu konuşmanın detayı KALICI olarak kaybolur.
