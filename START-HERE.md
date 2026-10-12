# START-HERE — Workspace Session Açılış Protokolü

> **Yeni bir sohbete girildiğinde okunacak ilk şey.**
> Amacı: token dolup session değiştiğinde, yeni session'ın **hiçbir şey sormadan**
> "ne yapıldı, nerede kalındı, sırada ne var" sorusunu cevaplayabilmesi.
>
> Kullanıcının tek yapması gereken: **"`.ai-agent/START-HERE.md` oku ve devam et"**

---

## 1. Okuma sırası

### Katman A — Workspace (her zaman)

| # | Dosya                                       | Ne verir                                                                   |  Zorunlu?  |
| - | ------------------------------------------- | -------------------------------------------------------------------------- | :---------: |
| 1 | [`../CLAUDE.md`](../CLAUDE.md)             | Cross-repo Hard Rule'lar, repo haritası, aktif işler                     | ✅ otomatik |
| 2 | [`PROJECT_CONTEXT.md`](PROJECT_CONTEXT.md) | Genel mimari: topoloji, portlar, hangi modül nasıl kullanılır, ADR'ler | ✅ otomatik |
| 3 | [`MEMORY.md`](MEMORY.md)                   | Cross-repo karar / tuzak / tercih                                          | ✅ otomatik |

### Katman B — Aktif repo (cwd hangi repoysa)

| # | Dosya                                                   |      Zorunlu?      |
| - | ------------------------------------------------------- | :-----------------: |
| 4 | `<repo>/CLAUDE.md`                                    | ✅ otomatik (varsa) |
| 5 | `<repo>/.ai-agent/PROJECT_CONTEXT.md` + `MEMORY.md` | ✅ otomatik (varsa) |

### Katman C — Aktif iş (elle oku)

| # | Dosya                                                      | Ne verir                                                                                        |       Zorunlu?       |
| - | ---------------------------------------------------------- | ----------------------------------------------------------------------------------------------- | :------------------: |
| 6 | `<is>/00-PANO.md`                                        | **Şu anki** durum: faz, sıradaki adım, bloke eden sorular                              | ✅**elle oku** |
| 7 | `<is>/progress/` → **en büyük numaralı** dosya | Yapılanlar / Yapılıyor / Yapılacaklar — tarihsel, en zengin liste                          | ✅**elle oku** |
| 8 | `compacts/` → en son dosya                              | Önceki session'da**neden öyle yapıldı** + **kullanıcının verdiği cevaplar** |     ✅ varsa oku     |
| 9 | `sessions/` → en son `session-*.md`                   | Kapanan oturumun arşivi                                                                        |     ⬜ gerekirse     |

**Kritik ayrım:**

| Dosya          | Davranış                           | Cevapladığı soru                            |
| -------------- | ------------------------------------ | ---------------------------------------------- |
| `00-PANO.md` | **üzerine yazılır**         | *Şu an neredeyiz?*                          |
| `progress/`  | **hiç değişmez**, numaralı | *Geçmişten bugüne ne değişti?*          |
| `compacts/`  | append                               | *Ne konuşuldu, neden böyle karar verildi?* |
| `sessions/`  | oturum başına 1 dosya              | *Bu oturum nasıl kapandı?*                 |

---

## 2. Session ömrü

```
Yeni session açılır
   │
   ├─ START-HERE.md → Katman A → B → C sırayla yüklenir
   │
   ├─ İş yapılır ──────────► her anlamlı iş sonrası:
   │                          • <is>/00-PANO.md güncellenir (üzerine yazılır)
   │                          • <is>/progress/ altına YENİ NUMARALI dosya
   │                          • karar/tuzak çıktıysa MEMORY.md
   │                          • mimari değiştiyse PROJECT_CONTEXT.md
   │
   ├─ Bağlam ~%70
   │     └─ 🔴 compact dosyası KENDİLİĞİNDEN açılır (CLAUDE.md Hard Rule 10)
   │        compacts/<YYYY-MM-DD>-<slug>-compact-<n>.md
   │        Sonra iş ilerledikçe AYNI dosya güncellenir. /compact'i BEKLEME.
   │
   └─ Session kapanır
         └─ sessions/session-YYYY-MM-DD-NNN.md
```

---

## 3. İlk turda verilecek cevap

Okuma bitince kullanıcı sormasa bile şunu **kısaca** özetle:

1. **Hangi iş aktif** ve genel ilerleme
2. **Hangi fazda / hangi adımda** kalındı
3. **Sıradaki somut iş** (dosya adı seviyesinde)
4. **Kullanıcı kararı bekleyen açık sorular** (varsa — numaralı kodlarıyla)

Kaynak: aktif işin `00-PANO.md`'si + en büyük numaralı `progress/` dosyası bu dördünü zaten içerir.

---

## 4. Cross-repo iş mi, tek repo işi mi?

| Durum                                   | Panosu nerede                                    |
| --------------------------------------- | ------------------------------------------------ |
| **Birden fazla** repoya dokunuyor | `repos/.ai-agent/<is-adi>/` (**burada**) |
| **Tek** repoya dokunuyor          | O reponun kendi`.ai-agent/`'ında              |

Emin değilsen: değişiklik **bir sözleşmeye** (endpoint / model / enum / paket sürümü) dokunuyorsa
**cross-repo'dur** — buraya aç.

---

## 5. Aktif İşler

| İş                                                | Repolar                                                                       | Pano                                                        |
| --------------------------------------------------- | ----------------------------------------------------------------------------- | ----------------------------------------------------------- |
| **Manuel Reeskont — generic base component** | `NetTrex.Web.UI` · `NetTrex.Common` · `NetTrex.MM` · (+ MicroUI'ler) | [`manuel-reeskont/00-PANO.md`](manuel-reeskont/00-PANO.md) |

---

## 6. Hızlı komut kartı

```powershell
# MM backend
dotnet build C:\Users\Treasy-70\source\repos\NetTrex.MM\Code\NetTrex.MM.sln
# ⚠️ MM'de `dotnet test` ÇALIŞMAZ (xUnit v3 = Microsoft.Testing.Platform).
#    Build sonrası bin'deki test exe'sini native runner argümanlarıyla çalıştır:
#    X.Tests.exe -class "*XTests"   (-class / -namespace / -method, wildcard '*')

# MM Micro UI
dotnet build C:\Users\Treasy-70\source\repos\Treasy.MM.UI\Treasy.MM.UI.slnx
dotnet run --project C:\Users\Treasy-70\source\repos\Treasy.MM.UI\src\Treasy.MM.UI.Web --launch-profile UI-Dev-Cluster
```

Portlar ve adresler → [`PROJECT_CONTEXT.md`](PROJECT_CONTEXT.md) § Topoloji.
