# 01 — Sorgular (colmanagement-entity-revizyon)

| # | Amaç | DB | Sorgu |
|---|---|---|---|
| 1 | TxnPaymentInstruction ayrı tablo mu yoksa TxnTransaction'a gömülü kolonlar mı olmalı — kararı Excel varsayımı yerine OptionsFX'in canlı şemasına bakarak ver (kullanıcı talebi) | `NetTrexOptFX` | `SET NOCOUNT ON; SELECT TOP (20) * FROM dbo.TxnTransaction ORDER BY Id DESC;` |
| 2 | Aynı karar için MM'in canlı TxnMM şeması — MM'de payment alanları ana tabloya gömülü (koddan biliniyordu), kolon adları/tipleri canlıdan teyit | `NetTrexMM` | `SET NOCOUNT ON; SELECT TOP (20) * FROM dbo.TxnMM ORDER BY Id DESC;` |
