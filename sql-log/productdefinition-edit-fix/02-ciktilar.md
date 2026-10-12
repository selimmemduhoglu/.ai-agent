# SQL Log — productdefinition-edit-fix — Çıktılar

## Sorgu #1 sonucu

```
Order|Adet
-----|----
30|2
```

Order=30 gerçekten **2 satırda** çift — validator "self-exclude" hatası değil, gerçek veri çakışması.

## Sorgu #2 sonucu

```
Id|Code|Name|Order|StateId|IsEnabled
--|----|----|-----|-------|---------
11|Post-Financing|Post-Financing|55|18|1
10|Securitization|Securitization|45|18|1
9|Syndication|Syndication|40|18|1
8|Gil|Gil|35|26|1
7|Pass|Pas|30|18|1
6|TermDeposit|Term Deposit|30|18|0
5|Murabaha|Murabaha|25|26|1
4|Wakale|Wakale|20|26|1
3|Issue|Bond Issue|15|18|1
2|Loan|Interbank Loan|10|26|1
1|MoneyMarket|Money Market|5|26|1
```

**Bulgu:** Id=7 "Pass" (IsEnabled=1, aktif) ve Id=6 "TermDeposit" (IsEnabled=0, **disabled**) aynı Order=30'u
paylaşıyor. Kullanıcı "Pass" kaydını Order değiştirmeden Edit+Save yaptığında `IsOrderUniqueAsync` kendi
Id'sini (7) hariç tutuyor ama Id=6'yı (disabled olsa da) dahil ediyor → "30 already exists" hatası.
`IsOrderUniqueAsync`/`IsCodeUniqueAsync` sorguları `IsEnabled` filtresi içermiyor
(`ProductDefinitionDataManager.cs` satır 116-129, 90-103) — disabled (soft-delete) kayıtlar uniqueness
kontrolüne dahil oluyor.
