# 35 — V2 revize: UI (Annex + CollateralDefinition + TxnTransaction)

**Tarih:** 2026-11-02 · **Faz:** V2 revize (devam — bkz. 34) · **Çıktı:** `Treasy.ColManagement.UI/src/*`

## Yöntem

34'te backend + DB script v2 tamamlanmıştı, UI güncellenmemişti. Kullanıcı onayıyla ("tamam eline
sağlık sırada ki adıma geç ve yap") sırayla Annex → CollateralDefinition → TxnTransaction UI'leri
backend'in yeni sözleşmesine ve yeni Demo'nun ekran davranışına göre yeniden yazıldı.

## Değişiklikler

**Annex:** Core model tek dosyada konsolide edildi (`AnnexModels.cs`), form 2 tab'dan tek sayfa
3 kart'a (`AddGroup` üç kez) çevrildi — yeni Demo tab istemiyor. Product/SubProduct artık DB'den
(`CollateralProduct`/`CollateralSubProduct` f-key), Status DB'den. `btnSave` en az 1 included
product + en az 1 rule kontrolü ekledi (`frmAnnex-NoIncludedProduct`/`-NoRule`, daha önce eksik
kalan localization key'leri de bu turda tamamlandı).

**CollateralDefinition:** `CashTerms` sarmalayıcısı kalktı, alanlar düzleşip `Cash*` önekiyle
üste taşındı. Yeni alanlar: `IsInterestCalculated` (kapalıyken bölüm pasif+boş —
`applyInterestCalculatedState`), `InterestSettlementType`, Rate Type Fixed/Floating aynı hücreyi
paylaşıyor (`applyRateTypeVisibility` — Fixed seçilince Floating alanı gizlenip temizleniyor ve
Interest Method varsayılanı SimpleLinear/DailyCompounded'a dönüyor). `CollateralTypeId` artık DB
lookup (backend'de bu uç yoktu, bu turda `CollateralTypeFKeyHandler`/`Controller` + UI tarafı
eklendi — Security `IsEnabled=0` olduğu için liste yalnız Cash döner).

**TxnTransaction (en büyük parça):** Backend'de başlık (`TxnTransaction`) ile hareket
(`TxnTransactionDetail`) ayrışmıştı; UI bunu hiç yansıtmıyordu. Core model `TxnMovementModel` +
`TxnTransactionBaseModel{CollateralDefinitionId,PortfolioId,Trader,Movement}` şeklinde yeniden
yazıldı. Form 2 tab: **Transaction** (General Information + Detail Information + Payment
Instructions — `IsSettlementRequired` kapalıyken ödeme alanları pasif+boş) ve **Transaction
Detail** (hareket geçmişi grid'i, satır tıklanınca **Movement Preview** popup'ı — paylaşılan
`Templates/_MovementPreview.cshtml` + `utils/movementHistory.ts`, Form ve Preview ekranlarının
ikisi de aynı popup'ı kullanıyor). Definition seçilince uygun para birimleri + değerleme para
birimi otomatik geliyor (`applyDefinitionSelection`); para birimi değerleme para biriminden
farklıysa FX Rate zorunlu gösteriliyor (`applyCurrencyFxGate`). Increase/Decrease muhabir alan
flip'i (We Send/They Receive ↔ We Receive/They Send) korundu.

**Backend'e bu turda eklenenler (UI ihtiyacından çıktı):** `CollateralType` f-key ucu (4 dosya +
controller) · UI tarafında `SettlementType`/`PaymentInstructionType` overview modelleri + Refit
metotları (backend'de zaten vardı, UI hiç bağlamamıştı — v1'den kalma TODO).

## Kararlar

- **Movement Preview popup = tek paylaşılan şablon**, Form'un Tab2'si ile Preview'ın Tab2'si
  aynı grid+popup kodunu kullanıyor (`utils/movementHistory.ts`). Kopya yazmak yerine ortak modül.
- **Correspondent banka alanları (Outgoing/Incoming/TheirBeneficiary/TheirSender) NumberBox
  (ham Id) olarak bırakıldı** — v1'de de lookup yoktu (`services/index.ts`'teki TODO), bu
  revizyon bunu çözmeyi istemedi; kapsam dışı bırakıldı, kullanıcıya bildirildi.
- **"Limit status" (Demo'da görünen) backend'de karşılığı yok** — v2 sözleşmesinde
  `MinimumAmount`/`AdjustedEligibleValue`/`TransactionValue` gibi limit alanları tamamen
  kaldırılmış. Yerine `CurrentBalance` salt-okunur gösterildi; gerçek bir limit kontrolü
  istenirse önce backend'e eklenmesi gerekir.
- **Date Basis'in Valuation Currency'den otomatik gelmesi (Demo §7.5.19) uygulanmadı** —
  `DateBasisSelectFKeyRequest` boş, para birimi→basis eşlemesi backend'de yok; düz liste
  bırakıldı.
- **Annex'in demo'daki özel "Add Product"/"Add Rule" popup'ları yerine mevcut DevExtreme
  inline-grid-popup-editing deseni korundu** (risk/efor dengesi) — işlevsel olarak aynı sonucu
  veriyor (satır ekle/düzenle/sil), yalnız görsel akış demo'dan farklı.

## Doğrulama

🔴 `dotnet build Treasy.ColManagement.UI.sln` → **0 hata** (her üç ekran tek tek ve toplu
doğrulandı). `dotnet build Treasy.ColManagement.sln` (backend) → **0 hata**. `npx tsc --noEmit`
çalıştırıldı: tüm hatalar (`Cannot find name '$'`) proje genelinde önceden var olan bir tsconfig
boşluğu (jQuery global type eksik, `annex/index.ts` gibi dokunulmamış dosyalarda da aynı hata
var) — bu turda yazılan koddan kaynaklanan **yeni bir hata yok**. Tarayıcıda denenmedi (DB henüz
kullanıcı tarafından v2 script'leriyle sıfırdan kurulmadı).

## Açık kalanlar

- Correspondent banka lookup'ı (gerçek isim/SWIFT gösterimi) — backend'de hiç yok, ayrı iş.
- Limit/threshold kontrolü ekranda yok çünkü backend'de yok — iş birimine sorulacak.
- Annex'in özel sub-form popup'ları (demo'daki UX) istenirse ayrı bir round'da yapılabilir.
- Kullanıcı DB'yi v2 script setiyle sıfırdan kurup üç ekranı tarayıcıda deneyecek; o turda
  çıkacak gerçek hatalar bir sonraki progress dosyasına yazılacak.
