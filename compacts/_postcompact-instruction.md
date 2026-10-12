🔴 ZORUNLU — BAĞLAM AZ ÖNCE SIKIŞTIRILDI (SessionStart:compact)

Sıkıştırma özeti ŞU AN context'inde. Bu en son fırsat — özet ilerledikçe o da düşer.

**BAŞKA HİÇBİR İŞE BAŞLAMADAN ÖNCE** bu sohbetin compact dosyasını diske yaz:

  <repo>/.ai-agent/compacts/<chat-slug>/compact-<n>.md

ADIMLAR:

1. `<chat-slug>` klasörünü kontrol et (`Glob: .ai-agent/compacts/**`).
   - VARSA → en büyük `compact-<n>.md`'yi bul, `n+1` ile YENİ dosya aç. Öncekilere DOKUNMA.
   - YOKSA → klasör + `_chat.md` + `compact-1.md`.
2. İçeriği **context'teki sıkıştırma özetinden** doldur — özeti kopyalamak DEĞİL, şablona oturt:
   kullanıcının istekleri / verdiği kararlar ve gerekçeleri / yapılanlar / hata metinleri / açık kalanlar.
3. `_index.md` tablosuna satır ekle.
4. Sonra kullanıcının asıl işine dön.

Şablon → `.ai-agent/compacts/_index.md`

Bu, cross-repo Hard Rule 10'un otomatik tetikleyicisidir. Atlama.
