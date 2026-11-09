# 25 — Permission script'i yazıldı (Annex / CollateralDefinition / TxnTransaction)

**Tarih:** 2026-10-15 · **Faz:** 4/11 · **Çıktı:** `Treasy.ColManagement/.ai-agent/outputs/2026-10-14-ColManagement-Kurulum/5-NetTrexCommon-Permission-DML.sql`

## Bulgu
Ekranlar açıldı ama "+" pasif, soldaki menü ağacı boş. Script 5 daha önce "bilerek boş" yazılmıştı
(gerekçe: Micro UI'de `CustomAuthorize` yok, erişim menüden). **Gerekçe yanlıştı:**
- `Pure.DevExtreme` grid toolbar'ı `HasPermissionAsync(Controller, Action)` çağırıyor; `+` = `hasInsertPermission && CanUserCreate`
  (`dataGrid-builder/index.ts:1214`).
- Common DB'de (`NetTrexCommon`, `192.168.10.211`) `Annex/`, `CollateralDefinition/`, `TxnTransaction/` için **0 satır**;
  emsal `ProductDefinition/*` `Trex.WebUI` altında `Controller/Action` ile kayıtlı (`sql-log/colmanagement-ui-permission` #2-#3).
- `GetModuleMenuHandler` `ControllerAction` menü düğümlerini kullanıcı permission'ına göre süzüyor.

## Yapılan
Script 5 dolduruldu: 9 rol (3 ekran × Maker/Checker/Displayer), 60 action, Super Admin bağlama (DerivSwp emsali),
sonda doğrulama SELECT'i. Idempotent.

## Doğrulama
🔴 Script **çalıştırılmadı** (DB'ye yazmak yasak, kullanıcı koşacak). Varsayım: docker'daki CommonApi (cluster 30825)
`192.168.10.211/NetTrexCommon`'a bakıyor — doğrulanmadı.

## Açık
- Super Admin dışındaki profillere `sp_FrameworkAddProfilePermission` elle.
- Redis kullanıcı permission + `ModuleMenu:*` cache temizliği, çıkış-giriş.
- Bu script `PROJECT_CONTEXT.md` §5'teki yanlış "Micro UI'de permission yok" notunu düzeltti.
