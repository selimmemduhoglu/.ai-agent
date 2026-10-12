# Faz 12 — Uçtan Uca Doğrulama ve Teslim

**Durum:** ⬜ · **Ön koşul:** Faz 11

## 1. Kapsam
| # | İş |
|---|---|
| 1 | Uçtan uca senaryo: Annex → Definition → Increase → Decrease → bakiye → muhasebe → mesaj |
| 2 | EOD / batch entegrasyonu (`BatchItem`, `BatchSet`, `DefJobCron`) |
| 3 | `General:AvailableModules`'a `COLMANAGEMENT` eklenmesi (🔴 script'te değil, **elle**) |
| 4 | Permission + menü doğrulaması (Redis `ModuleMenu:*` temizlenerek) |
| 5 | Release note → [`skills/release-note.md`](../../../skills/release-note.md) (DevOps form alanları, Markdown **değil**) |
| 6 | `PROJECT_CONTEXT.md` + `MEMORY.md` güncellemesi (yeni repo, port, modül kodu) |

## 2. Bitiş kriteri
1. ✅ Senaryo baştan sona hatasız
2. ✅ Her fazın `progress/` dosyası yazılmış
3. ✅ Workspace `PROJECT_CONTEXT.md`'de ColManagement modülü haritada
4. ✅ Release note teslim edildi

## 3. Çıktı
`../progress/12-uctan-uca.md` + `sessions/` arşivi
