# Sessions — Oturum Kapanış Arşivleri

> Cross-repo oturumların kapanış arşivi. Tek repoya özel oturumlar o reponun kendi `.ai-agent/sessions/`'ında.

**Dosya adı:** `session-<YYYY-MM-DD>-<NNN>.md` (NNN = o günün kaçıncı oturumu, `001`'den başlar)
İsteğe bağlı konu eki: `session-<konu>-<YYYY-MM-DD>-<NNN>.md`

**Ne zaman yazılır:** kullanıcı "bitti / kaydet / özet / arşivle" dediğinde **veya** bağlam dolmak üzereyken —
**onay beklemeden**.

**Silme yok** — kullanıcı kendisi siler.

---

## Şablon

```markdown
# Session <YYYY-MM-DD>-<NNN> — <Konu>

**Repolar:** <dokunulan repolar>  ·  **Süre/tur:** <kabaca>

## Ne istendi
[Kullanıcının hedefi, kendi kelimeleriyle 2-3 madde.]

## Ne yapıldı
[Dosya seviyesinde. Doğrulama çıktısı varsa yaz (build 0 error, N test geçti, HTTP 200).]

## Alınan kararlar
| Karar | Gerekçe | Kalıcı evi |
|---|---|---|
[Kalıcıysa PROJECT_CONTEXT.md (ADR) veya MEMORY.md'ye taşındı mı — işaretle.]

## Bulunan tuzaklar
[MEMORY.md'ye yazıldı mı?]

## Açık kalanlar
[Sonraki oturumun ilk işi.]

## İlgili dosyalar
[progress/ numarası, compact dosyası, üretilen doküman yolları.]
```

---

## Arşiv

| Dosya | Tarih | Konu | Repolar |
|-------|-------|------|---------|
| — | — | — | *(henüz yok)* |
