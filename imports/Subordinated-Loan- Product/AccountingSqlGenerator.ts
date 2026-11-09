/* =====================================================================================
 *  Accounting workbook  ->  NetTrexAcc MSSQL DML Generator   (workbook-agnostic)
 *  Office Scripts (Excel "Automate" tab)  |  paste this whole file into a new script
 * =====================================================================================
 *
 *  NE YAPAR
 *  --------
 *  Workbook icindeki TUM urun sayfalarini otomatik bulur (SKIP_SHEETS disindakiler),
 *  her biri icin calistirilabilir ve idempotent bir MSSQL DML scripti uretir ve
 *  hepsini TEK bir cikti sayfasina KOLON KOLON yazar.
 *
 *      SQL_ALL   -> A kolonu = 1. urun sayfasinin scripti
 *                   B kolonu = 2. urun sayfasinin scripti ... (1. satir = sayfa adi)
 *      GEN_LOG   -> ozet + uyari/hata listesi
 *
 *  IKI CIKTI MODU  (asagida OUTPUT_MODE)
 *      "debug"   -> girintili, yorumlu, okunabilir script
 *      "compact" -> yorum + bos satir + girinti temizlenmis, sikistirilmis script
 *
 *  URUN SAYFASI FORMATI
 *  --------------------
 *      A = Path                    -> B = TREX/.../LEAF                (yeni item)
 *      A = EventTypeCode           -> B = OnInsert | OnOpening | ...   (yeni event)
 *      A = GroupValidationRule     -> B = rule adi ya da bos           (yeni group)
 *      A = ComponentValidationRule -> baslik satiri (KOLON HARITASI buradan cikar)
 *      A = bos | rule adi          -> account rule satiri
 *
 *  CALISTIRMA SIRASI
 *      SQL_ALL'daki ILK kolon "PATH" -> item agacini kurar, ONCE calistirilir.
 *      Sonraki kolonlar urun scriptleridir; item'lari yalnizca ARAR, olusturmaz.
 *      SON kolon "ACCOUNTMAP" -> bagimsizdir, istenen sirada calistirilabilir.
 *
 *  ---------------------------------------------------------------------------------
 *  BU SURUMDEKI DEGISIKLIK
 *  ---------------------------------------------------------------------------------
 *  "CustomerAccountTypeCode" basligi artik TANINIR. Onceki surumde bu baslik hicbir
 *  dala dusmedigi icin "taninmayan kolon" UYARISI veriyordu. Artik kolon okunur;
 *  SQL'e yazilip yazilmayacagini ACCOUNT_MAP_EMIT_ACCOUNT_TYPE belirler.
 *  Ayrica GEN_LOG mesajlari daha kisa ve sade Turkce ile yazildi.
 * ===================================================================================== */


/* =====================================================================================
 * 1) CONFIG  --  tek duzenleme noktasi
 * ===================================================================================== */

/** "debug" = okunabilir script | "compact" = yorumsuz/girintisiz sikistirilmis script */
const OUTPUT_MODE: string = "compact";

/**
 * Cikti hucreye nasil yazilsin?
 *   "blocks" -> script ~30.000 karakterlik bloklara bolunup az sayida hucreye yazilir
 *   "lines"  -> her SQL satiri ayri bir hucreye (okumasi kolay, YAVAS)
 */
const WRITE_MODE: string = "lines";
const BLOCK_CHARS = 30000;

/** Tek setValues cagrisinda gonderilecek en fazla karakter / satir sayisi. */
const MAX_CHARS_PER_WRITE = 100000;
const MAX_ROWS_PER_WRITE = 5000;

/** compact modda birlestirilmis satir uzunlugu ust siniri. */
const COMPACT_LINE_CHARS = 4000;

/** Tek cikti sayfasi (her urun sayfasi ayri bir KOLON). */
const OUT_SHEET = "SQL_ALL";
const LOG_SHEET = "GEN_LOG";

/** Urun sayfasi SAYILMAYAN sayfalar (buyuk/kucuk harf duyarsiz). */
const SKIP_SHEETS: string[] = ["Shared", "Path", "PATH", "AccountMap", "Account Map", OUT_SHEET, LOG_SHEET];

/* ---------------------------------------------------------------------------------------
 * MOTOR VARSAYILANLARI
 * Shared sayfasina "Settings" bolumu ekleyip buradaki degerleri ezebilirsiniz.
 * ------------------------------------------------------------------------------------- */
const DEFAULTS: string[][] = [
  ["AppRoot", "TREX"],
  ["RootParentId", "0"],
  ["StateId", "18"],
  ["StateMaker", "SYSTEM"],
  ["TemplateId", "1"],
  ["TxnNoSource", "TxnNo"],
  ["TxnDateSource", "LogicalDate"],
  ["ValueDateSource", "LogicalDate"],
  ["ItemTypeApplicationCode", "TREX"],
  ["CalculationRuleTypeName", "Calculation"],
  ["ValidationRuleTypeValue", "0"],
  ["CalculationRuleTypeValue", "1"]
];

/** SQL Server degisken adi ust siniri (@ dahil 128 karakter). */
const MAX_SQL_VAR_LEN = 128;

/** Sembolik GL kodu -> gercek GL kodu esleme (opsiyonel). */
const SYMBOLIC_GL: string[][] = [];

/** Event'lere aciklama kurali baglansin mi? */
const LINK_EVENT_DESCRIPTION_RULES = true;
/** Shared!Event "Event Description" kolonu yoksa ada bakarak tahmin edilsin mi? */
const DESCRIPTION_RULE_FALLBACK = true;

/** Baslik satiri kolon adlari (buyuk/kucuk harf ve bosluk duyarsiz eslesir). */
const HEADER_COMPONENT: string[] = ["componentname", "component name", "component"];
const HEADER_GL: string[] = ["glcode", "gl code", "expected glcode", "expected gl code"];
const HEADER_DC: string[] = ["debit/credit", "debitcredit", "debit credit"];
const HEADER_AMOUNT: string[] = ["amount source", "amountsource"];
const HEADER_CCY: string[] = ["ccy source", "ccysource", "currency source", "currencysource"];
const HEADER_FCY: string[] = ["fcy source", "fcysource"];
const HEADER_ALIAS: string[] = ["alias"];


/* =====================================================================================
 * 2) Veri modeli
 * ===================================================================================== */

interface ColMap {
  comp: number; gl: number; dc: number; amt: number; ccy: number; fcy: number; alias: number;
  ok: boolean;
}

interface AccountRuleDef {
  excelRow: number;
  glCode: string;
  glCodeRaw: string;
  alias: string;
  debitCredit: string;
  amountSource: string;
  ccySource: string;
  fcySource: string;
  lcyEqvtSource: string;
  fcyAmtSource: string;
  valueDateSource: string;
}

interface ComponentDef {
  typeName: string;
  typeCode: string;
  typeVar: string;
  ruleName: string;
  order: number;
  varName: string;
  rules: AccountRuleDef[];
  excelRow: number;
}

interface GroupDef {
  ruleName: string;
  order: number;
  varName: string;
  varSuffix: string;
  components: ComponentDef[];
  excelRow: number;
}

interface EventDef {
  eventTypeCode: string;
  varName: string;
  descRuleVar: string;
  groups: GroupDef[];
  excelRow: number;
}

interface ItemDef {
  leafCode: string;
  path: string;
  segments: string[];
  varName: string;
  events: EventDef[];
  excelRow: number;
}

interface Message { level: string; sheet: string; text: string; }

interface SharedData {
  componentCodeByName: string[][];
  dynamicRuleByName: string[][];
  modelValueByDisplay: string[][];
  modelValues: string[];
  eventCodes: string[];
  eventDescRuleByCode: string[][];
  itemNameByCode: string[][];
  itemTypeByCode: string[][];
  modelSchemaByName: string[][];
  modelNameByPath: string[][];
  settings: string[][];
}

interface ParseResult {
  items: ItemDef[];
  modelName: string;
  usedComponentTypes: string[][];
  usedDynamicRules: string[][];
  usedEventTypes: string[];
  errors: Message[];
  warnings: Message[];
  warnKeys: string[];
  numericGlCount: number;
  varNames: string[];
}


/* =====================================================================================
 * 3) main
 * ===================================================================================== */

function main(workbook: ExcelScript.Workbook): void {
  const messages: Message[] = [];
  const summary: (string | number)[][] = [];

  const shared = readShared(workbook, messages);

  const sheets = workbook.getWorksheets();
  const outNames: string[] = [];
  const outScripts: string[][] = [];
  const allItemPaths: string[] = [];
  const pathOwner: string[][] = [];
  const allItemAliases: string[][] = [];

  for (let s = 0; s < sheets.length; s++) {
    const name = sheets[s].getName();
    if (isSkipped(name)) continue;

    const grid = readGrid(sheets[s]);
    const parsed = parseProductSheet(grid, name, shared);

    for (let i = 0; i < parsed.errors.length; i++) messages.push(parsed.errors[i]);
    for (let i = 0; i < parsed.warnings.length; i++) messages.push(parsed.warnings[i]);

    const counts = countTree(parsed.items);

    if (parsed.items.length === 0) {
      if (parsed.errors.length > 0) summary.push([name, "ERROR", 0, 0, 0, 0, 0, 0]);
      continue;
    }
    if (parsed.errors.length > 0) {
      summary.push([name, "ERROR - script uretilmedi", counts[0], counts[1], counts[2], counts[3], counts[4], 0]);
      continue;
    }

    let clash = false;
    for (let i = 0; i < parsed.items.length; i++) {
      const owner = lookup2(pathOwner, parsed.items[i].path);
      if (owner !== "" && owner !== name) {
        messages.push({
          level: "ERROR", sheet: name,
          text: "Satir " + parsed.items[i].excelRow + ": '" + parsed.items[i].path +
            "' ayni zamanda '" + owner + "' sayfasinda da var. Iki sayfa ayni item'i kullanamaz."
        });
        clash = true;
      } else if (owner === "") {
        pathOwner.push([parsed.items[i].path, name]);
      }
    }
    if (clash) {
      summary.push([name, "ERROR - path cakismasi", counts[0], counts[1], counts[2], counts[3], counts[4], 0]);
      continue;
    }

    for (let i = 0; i < parsed.items.length; i++) allItemPaths.push(parsed.items[i].path);
    collectAliases(parsed, allItemAliases);

    let lines = emitScript(name, parsed, shared);
    lines = postProcess(lines);
    outNames.push(name);
    outScripts.push(lines);
    summary.push([name, "OK (" + OUTPUT_MODE + ")", counts[0], counts[1], counts[2], counts[3], counts[4], lines.length]);
  }

  /* PATH scripti: urun sayfalarindaki yollardan kurulur, ILK KOLONA yazilir. */
  if (allItemPaths.length > 0) {
    const pathNodes = buildTreeFromPaths(allItemPaths, shared, messages);
    const modelNames: string[] = [];
    let missing = "";
    for (let i = 0; i < pathNodes.length; i++) {
      if (!pathNodes[i].isLeaf) continue;
      const mn = modelNameForPath(shared, pathNodes[i].path);
      if (mn === "") {
        missing += (missing === "" ? "" : ", ") + pathNodes[i].path;
      } else if (modelNames.indexOf(mn) < 0) {
        modelNames.push(mn);
      }
    }
    for (let i = 0; i < modelNames.length; i++) {
      if (modelSchemaForName(shared, modelNames[i]) === "") {
        messages.push({ level: "WARNING", sheet: "PATH", text: "'" + modelNames[i] + "' modelinin Shared!Model bolumunde semasi yok. Model olusturulmaz, sadece aranir; DB'de yoksa script hata verir." });
      }
    }
    if (missing !== "") {
      messages.push({ level: "ERROR", sheet: "PATH", text: "Su path'ler icin model yok. Shared!Path bolumune satir ekleyin -> " + missing });
    } else {
      const pathLines = postProcess(emitPathScript(pathNodes, modelNames, shared));
      outNames.unshift("PATH");
      outScripts.unshift(pathLines);
      let leaves = 0;
      for (let i = 0; i < pathNodes.length; i++) if (pathNodes[i].isLeaf) leaves++;
      summary.unshift(["PATH", "OK (" + OUTPUT_MODE + ")", pathNodes.length, leaves, 0, 0, 0, pathLines.length]);
    }
  }

  /* AccountMap scripti: en sona, ayri bir KOLON olarak. */
  const accMap = readAccountMapSheet(workbook, shared, messages, allItemPaths, allItemAliases);
  if (accMap.rows.length > 0 && accMap.ok) {
    const mapLines = postProcess(emitAccountMapScript(accMap, shared));
    outNames.push(ACCOUNT_MAP_OUT_NAME);
    outScripts.push(mapLines);
    summary.push([ACCOUNT_MAP_OUT_NAME, "OK (" + OUTPUT_MODE + ")", accMap.pathCount, 0, 0, 0, accMap.rows.length, mapLines.length]);
  } else if (accMap.rows.length > 0) {
    summary.push([ACCOUNT_MAP_OUT_NAME, "ERROR - script uretilmedi", accMap.pathCount, 0, 0, 0, accMap.rows.length, 0]);
  }

  writeAllSheet(workbook, outNames, outScripts);
  writeLogSheet(workbook, summary, messages, shared);
}

function isSkipped(name: string): boolean {
  const n = name.toLowerCase();
  for (let i = 0; i < SKIP_SHEETS.length; i++) if (SKIP_SHEETS[i].toLowerCase() === n) return true;
  if (n.indexOf("sql_") === 0) return true;
  return false;
}


/* =====================================================================================
 * 4) Okuma katmani
 * ===================================================================================== */

function readGrid(sheet: ExcelScript.Worksheet): string[][] {
  const used = sheet.getUsedRange();
  if (!used) return [];
  const values = used.getValues();
  const rowOffset = used.getRowIndex();
  const colOffset = used.getColumnIndex();
  const grid: string[][] = [];
  for (let r = 0; r < rowOffset; r++) grid.push([]);
  for (let r = 0; r < values.length; r++) {
    const row: string[] = [];
    for (let c = 0; c < colOffset; c++) row.push("");
    for (let c = 0; c < values[r].length; c++) row.push(cellText(values[r][c]));
    grid.push(row);
  }
  return grid;
}

function cellText(v: string | number | boolean): string {
  if (v === null || v === undefined) return "";
  return normalizeWs(String(v));
}

function normalizeWs(s: string): string {
  return s.replace(/\u00A0/g, " ").replace(/[\t\r\n]+/g, " ").replace(/ {2,}/g, " ").replace(/^ +| +$/g, "");
}

function gridCell(grid: string[][], row: number, col: number): string {
  if (col < 0) return "";
  if (row < 0 || row >= grid.length) return "";
  const r = grid[row];
  if (!r || col >= r.length) return "";
  return r[col] ? r[col] : "";
}

/** Shared sayfasi: bolum basliklari (1. satir) ile kolonlar bulunur, sabit indeks yok. */
function readShared(workbook: ExcelScript.Workbook, messages: Message[]): SharedData {
  const result: SharedData = {
    componentCodeByName: [], dynamicRuleByName: [], modelValueByDisplay: [], modelValues: [], eventCodes: [], eventDescRuleByCode: [], itemNameByCode: [], itemTypeByCode: [],
    modelSchemaByName: [], modelNameByPath: [], settings: []
  };
  const sheet = workbook.getWorksheet("Shared");
  if (!sheet) {
    messages.push({ level: "ERROR", sheet: "Shared", text: "'Shared' sayfasi yok. Component, kural, model ve event tablolari okunamadi." });
    return result;
  }
  const grid = readGrid(sheet);

  const secStart: number[] = [];
  const secName: string[] = [];
  let maxCol = 0;
  for (let r = 0; r < grid.length && r < 3; r++) if (grid[r] && grid[r].length > maxCol) maxCol = grid[r].length;
  for (let c = 0; c < maxCol; c++) {
    const v = gridCell(grid, 0, c);
    if (v !== "") { secName.push(v.toLowerCase()); secStart.push(c); }
  }
  if (secStart.length === 0) {
    messages.push({ level: "ERROR", sheet: "Shared", text: "1. satirda bolum basligi yok." });
    return result;
  }

  const compCodeC = sharedCol(grid, secName, secStart, maxCol, "component", ["code"]);
  const compNameC = sharedCol(grid, secName, secStart, maxCol, "component", ["name"]);
  const mdlValueC = sharedCol(grid, secName, secStart, maxCol, "accounting model", ["value"]);
  const mdlDispC = sharedCol(grid, secName, secStart, maxCol, "accounting model", ["display name", "displayname"]);
  const ruleNameC = sharedCol(grid, secName, secStart, maxCol, "dynamic rule", ["rule name", "rulename"]);
  const ruleCodeC = sharedCol(grid, secName, secStart, maxCol, "dynamic rule", ["rule validation code", "rulevalidationcode", "rule"]);
  const ruleTypeC = sharedCol(grid, secName, secStart, maxCol, "dynamic rule", ["type"]);
  const evtCodeC = sharedCol(grid, secName, secStart, maxCol, "event", ["code"]);
  const mdlNameC = sharedCol(grid, secName, secStart, maxCol, "model", ["name"]);
  const mdlSchemaC = sharedCol(grid, secName, secStart, maxCol, "model", ["schema"]);
  const pthNameC = sharedCol(grid, secName, secStart, maxCol, "path", ["name", "path"]);
  const pthModelC = sharedCol(grid, secName, secStart, maxCol, "path", ["model", "model name", "modelname"]);
  const setKeyC = sharedCol(grid, secName, secStart, maxCol, "settings", ["key", "setting"]);
  const setValC = sharedCol(grid, secName, secStart, maxCol, "settings", ["value"]);
  const itmCodeC = sharedCol(grid, secName, secStart, maxCol, "item", ["code"]);
  const itmNameC = sharedCol(grid, secName, secStart, maxCol, "item", ["name"]);
  const itmTypeC = sharedCol(grid, secName, secStart, maxCol, "item", ["itemtype", "item type", "type"]);
  const evtDescC = sharedCol(grid, secName, secStart, maxCol, "event",
    ["event description", "eventdescription", "description rule", "descriptionrule", "description"]);

  if (compCodeC < 0 || compNameC < 0) messages.push({ level: "ERROR", sheet: "Shared", text: "'Component' bolumunde Code / Name kolonlari yok." });
  if (mdlValueC < 0 || mdlDispC < 0) messages.push({ level: "WARNING", sheet: "Shared", text: "'Accounting Model' bolumunde Value / Display Name kolonlari yok. Kaynak adlari cozulemeyebilir." });
  if (ruleNameC < 0 || ruleCodeC < 0) messages.push({ level: "WARNING", sheet: "Shared", text: "'Dynamic Rule' bolumunde Rule Name / Rule Validation Code kolonlari yok." });
  if (evtCodeC < 0) messages.push({ level: "WARNING", sheet: "Shared", text: "'Event' bolumunde Code kolonu yok. Event tipi kontrol edilemez." });
  if (pthNameC < 0 || pthModelC < 0) messages.push({ level: "ERROR", sheet: "Shared", text: "'Path' bolumu yok. 1. satira 'Path', 2. satira 'Name' ve 'Model' basliklarini ekleyin." });
  if (mdlNameC < 0 || mdlSchemaC < 0) messages.push({ level: "ERROR", sheet: "Shared", text: "'Model' bolumu yok. 1. satira 'Model', 2. satira 'Name' ve 'Schema' basliklarini ekleyin." });

  for (let r = 2; r < grid.length; r++) {
    const compCode = gridCell(grid, r, compCodeC);
    const compName = gridCell(grid, r, compNameC);
    if (compCode !== "" && compName !== "") result.componentCodeByName.push([compName, compCode]);

    const ruleName = gridCell(grid, r, ruleNameC);
    const ruleCode = gridCell(grid, r, ruleCodeC);
    const ruleType = gridCell(grid, r, ruleTypeC);
    if (ruleName !== "") result.dynamicRuleByName.push([ruleName, ruleCode, ruleType]);

    const mdlValue = gridCell(grid, r, mdlValueC);
    const mdlDisplay = gridCell(grid, r, mdlDispC);
    if (mdlValue !== "") result.modelValues.push(mdlValue);
    if (mdlValue !== "" && mdlDisplay !== "") result.modelValueByDisplay.push([mdlDisplay, mdlValue]);

    const evtCode = gridCell(grid, r, evtCodeC);
    if (evtCode !== "" && result.eventCodes.indexOf(evtCode) < 0) result.eventCodes.push(evtCode);
    const evtDesc = gridCell(grid, r, evtDescC);
    if (evtCode !== "" && evtDesc !== "") result.eventDescRuleByCode.push([evtCode, evtDesc]);

    const mdlName = gridCell(grid, r, mdlNameC);
    if (mdlName !== "") result.modelSchemaByName.push([mdlName, cleanNull(gridCell(grid, r, mdlSchemaC))]);

    const pthName = cleanNull(gridCell(grid, r, pthNameC));
    const pthModel = cleanNull(gridCell(grid, r, pthModelC));
    if (pthName !== "" && pthModel !== "") result.modelNameByPath.push([pthName, pthModel]);

    const setKey = gridCell(grid, r, setKeyC);
    if (setKey !== "") result.settings.push([setKey, gridCell(grid, r, setValC)]);

    const itmCode = gridCell(grid, r, itmCodeC);
    if (itmCode !== "") {
      const itmName = gridCell(grid, r, itmNameC);
      const itmType = gridCell(grid, r, itmTypeC);
      if (itmName !== "") result.itemNameByCode.push([itmCode, itmName]);
      if (itmType !== "") result.itemTypeByCode.push([itmCode, itmType]);
    }
  }
  return result;
}

/** Bir Shared bolumu icinde, 2. satirdaki kolon basligina gore kolon indeksi bulur. */
function sharedCol(grid: string[][], secName: string[], secStart: number[], maxCol: number, section: string, headers: string[]): number {
  let from = -1, to = maxCol;
  for (let i = 0; i < secName.length; i++) {
    if (secName[i] === section) { from = secStart[i]; to = (i + 1 < secStart.length) ? secStart[i + 1] : maxCol; break; }
  }
  if (from < 0) return -1;
  for (let c = from; c < to; c++) {
    const h = gridCell(grid, 1, c).toLowerCase();
    for (let i = 0; i < headers.length; i++) if (h === headers[i]) return c;
  }
  return -1;
}


/* =====================================================================================
 * 5) Parser
 * ===================================================================================== */

function parseProductSheet(grid: string[][], sheetName: string, shared: SharedData): ParseResult {
  const res: ParseResult = {
    items: [], modelName: "",
    usedComponentTypes: [], usedDynamicRules: [], usedEventTypes: [],
    errors: [], warnings: [], warnKeys: [], numericGlCount: 0, varNames: []
  };

  let item: ItemDef | null = null;
  let evt: EventDef | null = null;
  let grp: GroupDef | null = null;
  let comp: ComponentDef | null = null;
  let map: ColMap = emptyColMap();

  for (let r = 0; r < grid.length; r++) {
    const excelRow = r + 1;
    const a = gridCell(grid, r, 0);
    const b = gridCell(grid, r, 1);

    if (isBlankRow(grid, r)) continue;

    const key = labelKey(a);

    /* Blok metadata satiri (Urun / Market / Vade ...): SQL'e alinmaz. */
    if (a !== "" && !isStructuralKey(key) && !rowHasAccountData(grid, r, map)) {
      warnOnce(res, "META|" + key, msg("INFO", sheetName,
        "Satir " + excelRow + ": '" + a + "' aciklama satiri sayildi (GLCode ve Debit/Credit bos), SQL'e alinmadi."));
      continue;
    }

    /* ---- Path satiri: yeni item ---- */
    if (key === "path") {
      if (b === "") { res.errors.push(msg("ERROR", sheetName, "Satir " + excelRow + ": Path bos.")); continue; }
      const segs = pathSegments(b);
      if (segs.length < 2) {
        res.errors.push(msg("ERROR", sheetName, "Satir " + excelRow + ": Path en az 2 parcali olmali -> '" + b + "'"));
        continue;
      }
      const leaf = segs[segs.length - 1];
      const fullPath = segs.join("/") + "/";

      const mnHere = modelNameForPath(shared, fullPath);
      if (mnHere === "") {
        res.errors.push(msg("ERROR", sheetName, "Satir " + excelRow + ": '" + fullPath + "' icin model yok. Shared!Path bolumune bu path'i ya da onegini ('" + relPath(shared, fullPath).split("/").slice(0, 2).join("/") + "') ekleyin."));
      } else if (res.modelName === "") {
        res.modelName = mnHere;
      } else if (res.modelName !== mnHere) {
        warnOnce(res, "MODELNAME|" + mnHere, msg("WARNING", sheetName, "Satir " + excelRow + ": bu sayfadaki path'ler farkli modellere bagli ('" + res.modelName + "' ve '" + mnHere + "'). Her yaprak kendi modeline baglanir."));
      }

      item = {
        leafCode: leaf, path: fullPath, segments: segs,
        varName: registerVar(res, nodeVar(segs)), events: [], excelRow: excelRow
      };
      res.items.push(item);
      evt = null; grp = null; comp = null;
      continue;
    }

    /* ---- EventTypeCode satiri ---- */
    if (key === "eventtypecode") {
      if (!item) { res.errors.push(msg("ERROR", sheetName, "Satir " + excelRow + ": EventTypeCode'dan once Path satiri yok.")); continue; }
      if (b === "") { res.errors.push(msg("ERROR", sheetName, "Satir " + excelRow + ": EventTypeCode bos.")); continue; }
      if (shared.eventCodes.length > 0 && shared.eventCodes.indexOf(b) < 0) {
        const asDesc = isEventDescriptionText(shared, b);
        res.errors.push(msg("ERROR", sheetName, "Satir " + excelRow + ": EventTypeCode Shared!Event listesinde yok -> '" + b + "'" +
          (asDesc === "" ? "" : "  |  Bu deger '" + asDesc + "' event'inin 'Event Description' hucresinde yazili. Hucredeki formul yanlis kolonu okuyor olabilir.")));
        continue;
      }
      const descVar = LINK_EVENT_DESCRIPTION_RULES
        ? linkDescriptionRule(res, shared, b, sheetName, excelRow) : "";
      evt = { eventTypeCode: b, varName: registerVar(res, item.varName + slug(b) + "Event"), descRuleVar: descVar, groups: [], excelRow: excelRow };
      item.events.push(evt);
      if (res.usedEventTypes.indexOf(b) < 0) res.usedEventTypes.push(b);
      grp = null; comp = null;
      continue;
    }

    /* ---- GroupValidationRule satiri ---- */
    if (key === "groupvalidationrule") {
      if (!item || !evt) { res.errors.push(msg("ERROR", sheetName, "Satir " + excelRow + ": GroupValidationRule'dan once EventTypeCode satiri yok.")); continue; }
      const index = evt.groups.length;
      const order = index + 1;
      if (b !== "") {
        const ruleVar = registerDynamicRule(res, shared, b, sheetName, excelRow);
        if (ruleVar === "") continue;
      }
      const groupVarSuffix = index === 0 ? "" : (b !== "" ? slug(b) : String(index + 1));
      grp = {
        ruleName: b, order: order,
        varName: registerVar(res, evt.varName + "Group" + groupVarSuffix),
        varSuffix: groupVarSuffix, components: [], excelRow: excelRow
      };
      evt.groups.push(grp);
      comp = null;
      continue;
    }

    /* ---- Baslik satiri: KOLON HARITASI ---- */
    if (key === "componentvalidationrule") {
      const m = buildColMap(grid, r);
      if (!m.ok) {
        const unk = unknownHeaders(grid, r);
        res.errors.push(msg("ERROR", sheetName, "Satir " + excelRow + ": baslik satirinda su kolon(lar) eksik -> " + missingColumns(m) +
          (unk !== "" ? ". Taninmayan baslik(lar): " + unk + " - yazim hatasi olabilir." : "")));
      } else {
        map = m;
      }
      continue;
    }

    /* ---- Account rule satiri ---- */
    if (!item || !evt) { res.errors.push(msg("ERROR", sheetName, "Satir " + excelRow + ": bu satir bir event'e bagli degil.")); continue; }
    if (!map.ok) { res.errors.push(msg("ERROR", sheetName, "Satir " + excelRow + ": bu satirdan once gecerli bir 'ComponentValidationRule' baslik satiri yok.")); continue; }

    if (!grp) {
      grp = { ruleName: "", order: evt.groups.length + 1, varName: registerVar(res, evt.varName + "Group"), varSuffix: "", components: [], excelRow: excelRow };
      evt.groups.push(grp);
      res.warnings.push(msg("WARNING", sheetName, "Satir " + excelRow + ": GroupValidationRule satiri yok, kuralsiz group varsayildi."));
    }

    const compName = gridCell(grid, r, map.comp);
    if (compName !== "") {
      const typeCode = lookup2(shared.componentCodeByName, compName);
      if (typeCode === "") {
        res.errors.push(msg("ERROR", sheetName, "Satir " + excelRow + ": ComponentName Shared!Component listesinde yok -> '" + compName + "'"));
        comp = null;
        continue;
      }
      if (a !== "") {
        const compRuleVar = registerDynamicRule(res, shared, a, sheetName, excelRow);
        if (compRuleVar === "") { comp = null; continue; }
      }
      const typeVar = registerComponentType(res, compName, typeCode);
      const sameTypeCount = countSameType(grp, compName);
      const compSlug = slug(compName) + (sameTypeCount === 0 ? "" : String(sameTypeCount + 1));
      comp = {
        typeName: compName, typeCode: typeCode, typeVar: typeVar,
        ruleName: a, order: grp.components.length + 1,
        varName: registerVar(res, grp.varName + "Comp" + compSlug),
        rules: [], excelRow: excelRow
      };
      grp.components.push(comp);
    }

    if (!comp) {
      res.errors.push(msg("ERROR", sheetName, "Satir " + excelRow + ": bu satir bir component'e bagli degil (ComponentName bos ve oncesinde component yok)."));
      continue;
    }

    /* GL kodu: Alias kolonu varsa GLCode = Alias. */
    const aliasVal = gridCell(grid, r, map.alias);
    const glRaw = gridCell(grid, r, map.gl);
    let glCode = aliasVal !== "" ? aliasVal : glRaw;
    if (glCode === "") { res.errors.push(msg("ERROR", sheetName, "Satir " + excelRow + ": GL Code / Alias bos.")); continue; }
    const mapped = lookup2(SYMBOLIC_GL, glCode);
    if (mapped !== "") {
      glCode = mapped;
    } else if (/^[0-9]+$/.test(glCode)) {
      res.numericGlCount++;
    }

    /* Debit / Credit */
    const dc = titleCase(gridCell(grid, r, map.dc));
    if (dc !== "Debit" && dc !== "Credit") {
      res.errors.push(msg("ERROR", sheetName, "Satir " + excelRow + ": Debit/Credit degeri hatali -> '" + gridCell(grid, r, map.dc) + "'"));
      continue;
    }

    /* Kaynaklar */
    const amountSource = resolveToken(res, shared, gridCell(grid, r, map.amt), sheetName, excelRow, "Amount Source");
    const ccySource = resolveToken(res, shared, gridCell(grid, r, map.ccy), sheetName, excelRow, "Ccy Source");
    if (amountSource === "" || ccySource === "") continue;

    let fcySource = ccySource;
    const fcyRaw = gridCell(grid, r, map.fcy);
    if (fcyRaw !== "") {
      const t = resolveToken(res, shared, fcyRaw, sheetName, excelRow, "FCY Source");
      if (t === "") continue;
      fcySource = t;
    }

    const valueDateSource = setting(shared, "ValueDateSource");

    comp.rules.push({
      excelRow: excelRow,
      glCode: glCode,
      glCodeRaw: glRaw,
      alias: glRaw,
      debitCredit: dc,
      amountSource: amountSource,
      ccySource: ccySource,
      fcySource: fcySource,
      lcyEqvtSource: amountSource,
      fcyAmtSource: amountSource,
      valueDateSource: valueDateSource
    });
  }

  /* Son gecis: ayirt edilebilirlik kontrolleri */
  for (let ii = 0; ii < res.items.length; ii++) {
    const it = res.items[ii];
    for (let ei = 0; ei < it.events.length; ei++) {
      const ee = it.events[ei];

      const seenGroupRules: string[] = [];
      for (let gi = 0; gi < ee.groups.length; gi++) {
        const key = ee.groups[gi].ruleName === "" ? "<NULL>" : ee.groups[gi].ruleName;
        if (seenGroupRules.indexOf(key) >= 0) {
          res.errors.push(msg("ERROR", sheetName, "Satir " + ee.groups[gi].excelRow + ": '" + it.leafCode + " " + ee.eventTypeCode + "' event'inde ayni GroupValidationRule (" + key + ") ikinci kez var. Iki group ayirt edilemiyor."));
        } else {
          seenGroupRules.push(key);
        }
      }

      for (let gi = 0; gi < ee.groups.length; gi++) {
        const gg = ee.groups[gi];
        for (let ci = 0; ci < gg.components.length; ci++) {
          const cc = gg.components[ci];
          const seenRules: string[] = [];
          for (let ri = 0; ri < cc.rules.length; ri++) {
            const rr = cc.rules[ri];
            const key = rr.glCode + "|" + rr.debitCredit + "|" + rr.amountSource + "|" + rr.ccySource;
            if (seenRules.indexOf(key) >= 0) {
              res.errors.push(msg("ERROR", sheetName, "Satir " + rr.excelRow + ": '" + cc.typeName + "' icinde ayni satir tekrar ediyor (GL " + rr.glCode + " / " + rr.debitCredit + " / " + rr.amountSource + " / " + rr.ccySource + "). Fazla satiri silin."));
            } else {
              seenRules.push(key);
            }
          }
          if (cc.rules.length === 0) {
            res.warnings.push(msg("WARNING", sheetName, "Satir " + cc.excelRow + ": '" + cc.typeName + "' component'inin hic satiri yok."));
          }
        }
      }
    }
  }

  if (res.numericGlCount > 0) {
    res.warnings.push(msg("INFO", sheetName, res.numericGlCount + " satirda GLCode dogrudan hesap numarasi olarak yazildi (Alias kolonu yok ya da bos). Motor sembolik ad bekliyorsa 'Alias' kolonu ekleyin."));
  }
  return res;
}

/** Verilen metin Shared!Event'in "Event Description" kolonunda geciyor mu? */
function isEventDescriptionText(shared: SharedData, text: string): string {
  const k = text.toLowerCase();
  for (let i = 0; i < shared.eventDescRuleByCode.length; i++) {
    if (String(shared.eventDescRuleByCode[i][1]).toLowerCase() === k) {
      return String(shared.eventDescRuleByCode[i][0]);
    }
  }
  return "";
}

function isBlankRow(grid: string[][], r: number): boolean {
  const row = grid[r];
  if (!row) return true;
  for (let c = 0; c < row.length && c < 12; c++) if (row[c] !== "") return false;
  return true;
}

function emptyColMap(): ColMap {
  return { comp: 1, gl: -1, dc: -1, amt: -1, ccy: -1, fcy: -1, alias: -1, ok: false };
}

/** "ComponentValidationRule" baslik satirindan kolon indekslerini cikarir. */
function buildColMap(grid: string[][], row: number): ColMap {
  const m = emptyColMap();
  const r = grid[row];
  const width = r ? r.length : 0;
  for (let c = 1; c < width; c++) {
    const h = gridCell(grid, row, c).toLowerCase();
    if (h === "") continue;
    if (inList(HEADER_COMPONENT, h)) m.comp = c;
    else if (inList(HEADER_GL, h)) m.gl = c;
    else if (inList(HEADER_DC, h)) m.dc = c;
    else if (inList(HEADER_AMOUNT, h)) m.amt = c;
    else if (inList(HEADER_CCY, h)) m.ccy = c;
    else if (inList(HEADER_FCY, h)) m.fcy = c;
    else if (inList(HEADER_ALIAS, h)) m.alias = c;
  }
  m.ok = (m.gl >= 0 && m.dc >= 0 && m.amt >= 0 && m.ccy >= 0);
  return m;
}

/** Eksik zorunlu kolonlari okunur sekilde dondurur. */
function missingColumns(m: ColMap): string {
  let s = "";
  if (m.gl < 0) s += (s === "" ? "" : ", ") + "GLCode";
  if (m.dc < 0) s += (s === "" ? "" : ", ") + "DebitCredit";
  if (m.amt < 0) s += (s === "" ? "" : ", ") + "AmountSource";
  if (m.ccy < 0) s += (s === "" ? "" : ", ") + "CCY Source";
  return s;
}

/** Baslik satirinda taninmayan kolon adlarini listeler. */
function unknownHeaders(grid: string[][], row: number): string {
  const r = grid[row];
  const width = r ? r.length : 0;
  let s = "";
  for (let c = 1; c < width; c++) {
    const h = gridCell(grid, row, c).toLowerCase();
    if (h === "") continue;
    if (inList(HEADER_COMPONENT, h) || inList(HEADER_GL, h) || inList(HEADER_DC, h) ||
      inList(HEADER_AMOUNT, h) || inList(HEADER_CCY, h) || inList(HEADER_FCY, h) ||
      inList(HEADER_ALIAS, h)) continue;
    s += (s === "" ? "" : ", ") + "'" + gridCell(grid, row, c) + "'";
  }
  return s;
}

function inList(list: string[], value: string): boolean {
  for (let i = 0; i < list.length; i++) if (list[i] === value) return true;
  return false;
}

/** A kolonundaki yapisal anahtari normalize eder. */
function labelKey(a: string): string {
  let s = a.trim().toLowerCase();
  s = s.replace(/[:：]+$/, "").trim();
  return trNormalize(s);
}

/** Turkce karakterleri sadelestirir: "Hayır" -> "hayir", "Ürün" -> "urun". */
function trNormalize(s: string): string {
  let out = "";
  for (let i = 0; i < s.length; i++) {
    const ch = s.charAt(i);
    if (ch === "ü") out += "u";
    else if (ch === "ö") out += "o";
    else if (ch === "ı" || ch === "İ") out += "i";
    else if (ch === "ş") out += "s";
    else if (ch === "ğ") out += "g";
    else if (ch === "ç") out += "c";
    else out += ch;
  }
  return out;
}

/** A kolonundaki deger yapisal bir anahtar mi? */
function isStructuralKey(key: string): boolean {
  return key === "path" || key === "eventtypecode" ||
    key === "groupvalidationrule" || key === "componentvalidationrule";
}

/** Satirda gercek account rule verisi var mi? */
function rowHasAccountData(grid: string[][], row: number, map: ColMap): boolean {
  if (!map.ok) return false;
  if (map.gl >= 0 && gridCell(grid, row, map.gl) !== "") return true;
  if (map.dc >= 0 && gridCell(grid, row, map.dc) !== "") return true;
  return false;
}

/** Path'i segmentlere ayirir. */
function pathSegments(path: string): string[] {
  const raw = path.replace(/^\/+/, "").replace(/\/+$/, "").split("/");
  const out: string[] = [];
  for (let i = 0; i < raw.length; i++) {
    const s = raw[i].replace(/[^A-Za-z0-9]/g, "");
    if (s !== "") out.push(s);
  }
  return out;
}

function nodeVar(segs: string[]): string {
  let s = "@n";
  for (let i = 1; i < segs.length; i++) s += segs[i];
  if (s.length > 100) s = s.substring(0, 100);
  return s + "Id";
}

function countSameType(grp: GroupDef, typeName: string): number {
  let n = 0;
  for (let i = 0; i < grp.components.length; i++) if (grp.components[i].typeName === typeName) n++;
  return n;
}

/** SQL degisken adini kaydeder; 128 karakteri asiyorsa deterministik kisaltir. */
function registerVar(res: ParseResult, desired: string): string {
  let name = desired;
  if (name.length > MAX_SQL_VAR_LEN) {
    const stem = desired.substring(0, MAX_SQL_VAR_LEN - 6);
    let n = 1;
    name = stem + "_" + n;
    while (res.varNames.indexOf(name) >= 0) { n++; name = stem + "_" + n; }
  } else if (res.varNames.indexOf(name) >= 0) {
    const stem = desired.substring(0, Math.min(desired.length, MAX_SQL_VAR_LEN - 6));
    let n = 2;
    name = stem + "_" + n;
    while (res.varNames.indexOf(name) >= 0) { n++; name = stem + "_" + n; }
  }
  res.varNames.push(name);
  return name;
}

function registerComponentType(res: ParseResult, name: string, code: string): string {
  const varName = "@ct" + slug(name);
  for (let i = 0; i < res.usedComponentTypes.length; i++) {
    if (res.usedComponentTypes[i][0] === name) return res.usedComponentTypes[i][2];
  }
  res.usedComponentTypes.push([name, code, varName]);
  return varName;
}

function registerDynamicRule(res: ParseResult, shared: SharedData, name: string, sheetName: string, excelRow: number): string {
  for (let i = 0; i < res.usedDynamicRules.length; i++) {
    if (res.usedDynamicRules[i][0] === name) return res.usedDynamicRules[i][2];
  }
  if (!hasRule(shared, name)) {
    res.errors.push(msg("ERROR", sheetName, "Satir " + excelRow + ": kural Shared!Dynamic Rule listesinde yok -> '" + name + "'"));
    return "";
  }
  const rule = lookup2(shared.dynamicRuleByName, name);
  const rType = lookupN(shared.dynamicRuleByName, name, 2);
  if (rule === "" && !isCalcRule(shared, rType)) {
    res.errors.push(msg("ERROR", sheetName, "Satir " + excelRow + ": '" + name + "' kuralinin Shared'deki 'Rule Validation Code' hucresi bos. Bos govdeli validation kurali olusturulamaz."));
    return "";
  }
  const varName = "@dr" + slug(name);
  res.usedDynamicRules.push([name, rule, varName, rType]);
  return varName;
}

/** Event'in aciklama kuralini bulur (once Shared!Event kolonu, sonra tahmin). */
function linkDescriptionRule(res: ParseResult, shared: SharedData, eventCode: string, sheetName: string, excelRow: number): string {
  const explicit = lookup2(shared.eventDescRuleByCode, eventCode);
  if (explicit !== "") {
    warnIfEmptyDescription(res, shared, explicit, sheetName);
    return registerDynamicRule(res, shared, explicit, sheetName, excelRow);
  }
  if (!DESCRIPTION_RULE_FALLBACK) return "";

  const keyword = eventKeyword(eventCode);
  if (keyword === "") return "";
  const matches: string[] = [];
  for (let i = 0; i < shared.dynamicRuleByName.length; i++) {
    const row = shared.dynamicRuleByName[i];
    const type = row.length > 2 ? String(row[2]) : "";
    if (!isCalcRule(shared, type)) continue;
    if (String(row[0]).toLowerCase().indexOf(keyword.toLowerCase()) >= 0) matches.push(String(row[0]));
  }
  if (matches.length === 0) return "";
  if (matches.length > 1) {
    warnOnce(res, "DESCAMB|" + eventCode, msg("WARNING", sheetName, "'" + eventCode + "' icin birden fazla aciklama kurali eslesti (" + matches.join(" | ") + "). Aciklama bagi bos birakildi."));
    return "";
  }
  const name = matches[0];
  warnOnce(res, "DESCGUESS|" + eventCode, msg("WARNING", sheetName, "'" + eventCode + "' aciklama kurali tahminle bulundu -> '" + name + "'. Kesinlestirmek icin Shared!Event tablosuna 'Event Description' kolonu ekleyin."));
  warnIfEmptyDescription(res, shared, name, sheetName);
  return registerDynamicRule(res, shared, name, sheetName, excelRow);
}

/** Aciklama kuralinin metni bos ya da 'None' ise uyarir. */
function warnIfEmptyDescription(res: ParseResult, shared: SharedData, name: string, sheetName: string): void {
  const body = lookup2(shared.dynamicRuleByName, name);
  if (body === "" || body.toLowerCase() === "none") {
    warnOnce(res, "DESCEMPTY|" + name, msg("WARNING", sheetName, "'" + name + "' aciklama kuralinin metni bos. Kural olusturulur ama fis aciklamasi uretmez; sablonu Shared'e yazin."));
  }
}

/** "OnPremiumSettlement" -> "Premium" | "OnEOD" -> "EOD" */
function eventKeyword(eventCode: string): string {
  let s = eventCode;
  if (s.substring(0, 2) === "On") s = s.substring(2);
  let word = "";
  for (let i = 0; i < s.length; i++) {
    const ch = s.charAt(i);
    if (i > 0 && ch >= "A" && ch <= "Z") break;
    word += ch;
  }
  if (word.length < 3) return s;
  return word;
}

/** Display adi -> motor token'i. Tek kaynak: Shared!Accounting Model. */
function resolveToken(res: ParseResult, shared: SharedData, display: string, sheetName: string, excelRow: number, what: string): string {
  if (display === "") {
    res.errors.push(msg("ERROR", sheetName, "Satir " + excelRow + ": " + what + " bos."));
    return "";
  }
  const fromShared = lookup2(shared.modelValueByDisplay, display);
  if (fromShared !== "") return fromShared;

  const k = display.toLowerCase();
  for (let i = 0; i < shared.modelValues.length; i++) {
    if (shared.modelValues[i].toLowerCase() === k) {
      warnOnce(res, "RAWTOKEN|" + display, msg("WARNING", sheetName, "'" + display + "' Display Name yerine dogrudan Value olarak yazilmis (ilk satir: " + excelRow + "). Oldugu gibi kullanildi."));
      return shared.modelValues[i];
    }
  }
  res.errors.push(msg("ERROR", sheetName, "Satir " + excelRow + ": " + what + " Shared!Accounting Model listesinde yok -> '" + display + "'"));
  return "";
}


/* =====================================================================================
 * 6) SQL uretimi
 * ===================================================================================== */

function emitScript(sheetName: string, parsed: ParseResult, shared: SharedData): string[] {
  const out: string[] = [];
  const L = (s: string) => { out.push(s); };

  const modelName = parsed.modelName;
  const modelSchema = modelSchemaForName(shared, modelName);
  const modelVar = "@accModelDefinitionId";

  /* ---------------- baslik ---------------- */
  L("/***************************************************************************************************");
  L("* This script adds " + sheetName + " accounting rules");
  L("* GENERATED - do not edit by hand.");
  L("*   source workbook sheet : " + sheetName);
  L("*   output mode           : " + OUTPUT_MODE);
  L("*   generated at          : " + isoStamp());
  L("***************************************************************************************************/");
  L("");
  L("USE NetTrexAcc;");
  L("GO");
  L("");
  L("SET XACT_ABORT ON;");
  L("");
  L("BEGIN TRANSACTION;");
  L("");
  L("BEGIN TRY");
  L("");

  /* ---------------- 1. STEP ---------------- */
  L("    /********** 1. STEP: DEGISKEN TANIMLARI *********************************/");
  L("    BEGIN");
  L("        DECLARE");
  L("            @tempTable TABLE");
  L("                       (");
  L("                           Id INT");
  L("                       );");
  L("        DECLARE");
  L("            @StateId INT = " + setting(shared, "StateId") + ",");
  L("            @stateDate datetime = GETDATE(),");
  L("            @stateMaker nvarchar(80) = N'" + setting(shared, "StateMaker") + "';");
  L("");
  L("        /* Acc Columns */");
  L("        DECLARE");
  L("            @lastAccEngineDynamicRuleId INT = 0,");
  L("            @accEngineDynamicRuleColumnTypeId INT = 1,");
  L("            @lastAccEngineAccountRuleId INT = 0,");
  L("            @accEngineAccountRuleColumnTypeId INT = 2,");
  L("            @lastAccEngineComponentId INT = 0,");
  L("            @accEngineComponentColumnTypeId INT = 3,");
  L("            @lastAccEngineGroupId INT = 0,");
  L("            @accEngineGroupColumnTypeId INT = 4,");
  L("            @lastAccEngineEventId INT = 0,");
  L("            @accEngineEventColumnTypeId INT = 5,");
  L("            @lastAccEngineItemId INT = 0,");
  L("            @accEngineItemColumnTypeId INT = 7,");
  L("            @lastAccEngineModelDefinitionId INT = 0,");
  L("            @accEngineModelDefinitionColumnTypeId INT = 10;");
  L("");

  if (parsed.usedComponentTypes.length > 0) {
    L("        /* Component Types */");
    L("        DECLARE");
    for (let i = 0; i < parsed.usedComponentTypes.length; i++) {
      const t = parsed.usedComponentTypes[i];
      L("            -- " + t[0]);
      L("            " + t[2] + " NVARCHAR(50) = N'" + q(t[1]) + "'" + (i === parsed.usedComponentTypes.length - 1 ? ";" : ","));
    }
    L("");
  }

  if (parsed.usedDynamicRules.length > 0) {
    L("        /* Dynamic Rules */");
    L("        DECLARE");
    for (let i = 0; i < parsed.usedDynamicRules.length; i++) {
      const r = parsed.usedDynamicRules[i];
      L("            -- " + r[0]);
      L("            " + r[2] + " INT = 0" + (i === parsed.usedDynamicRules.length - 1 ? ";" : ","));
    }
    L("");
  }

  /* item agaci degiskenleri */
  L("        /* Item Tree */");
  L("        DECLARE");
  const itemVars: string[] = [];
  for (let i = 0; i < parsed.items.length; i++) itemVars.push(parsed.items[i].varName);
  emitDeclareList(out, itemVars);
  L("");

  L("        /* Item Events */");
  L("        DECLARE");
  const eventVars: string[] = [];
  const groupVars: string[] = [];
  const compVars: string[] = [];
  for (let i = 0; i < parsed.items.length; i++) {
    const it = parsed.items[i];
    for (let e = 0; e < it.events.length; e++) {
      eventVars.push(it.events[e].varName);
      for (let g = 0; g < it.events[e].groups.length; g++) {
        groupVars.push(it.events[e].groups[g].varName);
        for (let c = 0; c < it.events[e].groups[g].components.length; c++) {
          compVars.push(it.events[e].groups[g].components[c].varName);
        }
      }
    }
  }
  emitDeclareList(out, eventVars);
  L("");
  L("        /* Event Groups */");
  L("        DECLARE");
  emitDeclareList(out, groupVars);
  L("");
  L("        /* Event Group Components */");
  L("        DECLARE");
  emitDeclareList(out, compVars);
  L("");
  L("        /* Model and New Item Code */");
  L("        DECLARE");
  L("            " + modelVar + " INT;");
  L("");

  L("        ------------------------------------------------------------------------------------------------------------------------");
  L("        -- Definition Number Generation");
  L("        ------------------------------------------------------------------------------------------------------------------------");
  L("        --#region DefNumberGen");
  emitDefNumberGenSelect(out, "AccEngineAccountRule", "@lastAccEngineAccountRuleId", "@accEngineAccountRuleColumnTypeId");
  emitDefNumberGenSelect(out, "AccEngineDynamicRule", "@lastAccEngineDynamicRuleId", "@accEngineDynamicRuleColumnTypeId");
  emitDefNumberGenSelect(out, "AccEngineComponent", "@lastAccEngineComponentId", "@accEngineComponentColumnTypeId");
  emitDefNumberGenSelect(out, "AccEngineGroup", "@lastAccEngineGroupId", "@accEngineGroupColumnTypeId");
  emitDefNumberGenSelect(out, "AccEngineEvent", "@lastAccEngineEventId", "@accEngineEventColumnTypeId");
  emitDefNumberGenSelect(out, "AccEngineModelDefinition", "@lastAccEngineModelDefinitionId", "@accEngineModelDefinitionColumnTypeId");
  emitDefNumberGenSelect(out, "AccEngineItem", "@lastAccEngineItemId", "@accEngineItemColumnTypeId");
  L("        --#endregion");
  L("        ------------------------------------------------------------------------------------------------------------------------");
  L("    END");
  L("");

  /* ---------------- 2. STEP ---------------- */
  L("    /********** 2. STEP: GENEL TANIMLAR *************************************/");
  L("    BEGIN");

  if (parsed.usedDynamicRules.length > 0) {
    L("        ------------------------------------------------------------------------------------------------------------------------");
    L("        -- Accounting Engine Dynamic Rule");
    L("        ------------------------------------------------------------------------------------------------------------------------");
    L("        --#region AccEngineDynamicRule");
    for (let i = 0; i < parsed.usedDynamicRules.length; i++) {
      const name = parsed.usedDynamicRules[i][0];
      const rule = parsed.usedDynamicRules[i][1];
      const v = parsed.usedDynamicRules[i][2];
      const rType = parsed.usedDynamicRules[i].length > 3 ? parsed.usedDynamicRules[i][3] : "";
      const isCalc = isCalcRule(shared, rType);
      const predicate = isCalc
        ? "Name = N'" + q(name) + "'"
        : "[Rule] = N'" + q(rule) + "' AND Name = N'" + q(name) + "'";
      const typeValue = isCalc ? setting(shared, "CalculationRuleTypeValue") : setting(shared, "ValidationRuleTypeValue");
      L("        ------------------------------------------------------------------------------------------------------------------------");
      L("        -- " + name + (isCalc ? "  [" + setting(shared, "CalculationRuleTypeName") + "]" : ", " + rule));
      L("        ------------------------------------------------------------------------------------------------------------------------");
      L("        IF NOT EXISTS (SELECT 1");
      L("                       FROM dbo.AccEngineDynamicRule");
      L("                       WHERE " + predicate + ")");
      L("            BEGIN");
      L("                INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)");
      L("                OUTPUT inserted.Id INTO @tempTable");
      L("                VALUES (@lastAccEngineDynamicRuleId, N'" + q(name) + "', N'" + q(rule) + "',");
      L("                        " + typeValue + ", N'', @StateId, @stateDate, @stateMaker);");
      L("                SELECT " + v + " = Id FROM @tempTable;");
      L("                DELETE FROM @tempTable");
      L("                SELECT @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1");
      L("            END;");
      L("        ELSE");
      L("            BEGIN");
      L("                SELECT " + v + " = Id");
      L("                FROM dbo.AccEngineDynamicRule");
      L("                WHERE " + predicate);
      L("            END");
    }
    L("        --#endregion");
    L("        ------------------------------------------------------------------------------------------------------------------------");
    L("");
  }

  /* model definition */
  L("        ------------------------------------------------------------------------------------------------------------------------");
  L("        -- Accounting Engine Model Definition");
  L("        ------------------------------------------------------------------------------------------------------------------------");
  L("        --#region AccEngineModelDefinition");
  if (modelSchema !== "") {
    L("        IF NOT EXISTS(SELECT 1");
    L("                      FROM dbo.AccEngineModelDefinition");
    L("                      WHERE Name = N'" + q(modelName) + "')");
    L("            BEGIN");
    L("                INSERT INTO dbo.AccEngineModelDefinition (Id, [Schema], Name, StateId, StateDate, StateMaker)");
    L("                VALUES (@lastAccEngineModelDefinitionId,");
    L("                        N'" + q(modelSchema) + "',");
    L("                        N'" + q(modelName) + "', @StateId, @stateDate, @stateMaker);");
    L("                SELECT @lastAccEngineModelDefinitionId = @lastAccEngineModelDefinitionId + 1");
    L("            END");
    L("");
  }
  L("        SELECT " + modelVar + " = Id FROM dbo.AccEngineModelDefinition WHERE Name = N'" + q(modelName) + "';");
  L("        IF (" + modelVar + " IS NULL) THROW 500001, '" + q(modelName) + " Not Found - Shared!Model bolumune (Name | Schema) ekleyin ya da model DML''ini once calistirin', 1;");
  L("        --#endregion");
  L("        ------------------------------------------------------------------------------------------------------------------------");
  L("");

  /* event types */
  L("        ------------------------------------------------------------------------------------------------------------------------");
  L("        -- Accounting Engine Event Type");
  L("        ------------------------------------------------------------------------------------------------------------------------");
  L("        --#region AccEngineEventType");
  for (let i = 0; i < parsed.usedEventTypes.length; i++) {
    const code = parsed.usedEventTypes[i];
    L("        -- " + code);
    L("        IF NOT EXISTS (SELECT 1 FROM dbo.AccEngineEventType WHERE Code = N'" + q(code) + "')");
    L("            BEGIN");
    L("                INSERT INTO dbo.AccEngineEventType (Name, Code)");
    L("                VALUES (N'" + q(code) + "', N'" + q(code) + "');");
    L("            END;");
    L("");
  }
  L("        --#endregion");
  L("        ------------------------------------------------------------------------------------------------------------------------");
  L("");

  /* component types */
  L("        ------------------------------------------------------------------------------------------------------------------------");
  L("        -- Accounting Engine Component Type");
  L("        ------------------------------------------------------------------------------------------------------------------------");
  L("        --#region AccEngineComponentType");
  for (let i = 0; i < parsed.usedComponentTypes.length; i++) {
    const name = parsed.usedComponentTypes[i][0];
    const code = parsed.usedComponentTypes[i][1];
    L("        -- " + name);
    L("        IF NOT EXISTS (SELECT 1");
    L("                       FROM dbo.AccEngineComponentType");
    L("                       WHERE Code = N'" + q(code) + "')");
    L("        BEGIN");
    L("            INSERT INTO dbo.AccEngineComponentType (Name, Code, StateId, StateDate, StateMaker)");
    L("            VALUES (N'" + q(name) + "', N'" + q(code) + "', @StateId, @stateDate, @stateMaker);");
    L("        END;");
    L("");
  }
  L("        --#endregion");
  L("        ------------------------------------------------------------------------------------------------------------------------");
  L("");

  /* item agaci: SADECE ARAMA */
  L("        ------------------------------------------------------------------------------------------------------------------------");
  L("        -- Engine Items (PATH scripti ile onceden kurulmus olmali)");
  L("        ------------------------------------------------------------------------------------------------------------------------");
  L("        --#region AccEngineItems");
  for (let i = 0; i < parsed.items.length; i++) {
    const it = parsed.items[i];
    L("        SET " + it.varName + " = (SELECT Id FROM dbo.AccEngineItem WHERE Path = N'" + it.path + "');");
    L("        IF (" + it.varName + " IS NULL) THROW 500001, 'Item " + it.path + " Not Found - once PATH scriptini calistirin', 1;");
  }
  L("        --#endregion");
  L("        ------------------------------------------------------------------------------------------------------------------------");
  L("    END");
  L("");

  /* ---------------- 3..N. STEP ---------------- */
  let step = 3;
  for (let i = 0; i < parsed.items.length; i++) {
    const it = parsed.items[i];
    for (let e = 0; e < it.events.length; e++) {
      emitEventStep(out, it, it.events[e], step, shared);
      step++;
    }
  }

  /* ---------------- son STEP ---------------- */
  L("    /********** " + step + ". STEP: NUMBER GENERATION UPDATE **************************/");
  L("    BEGIN");
  L("        --#region DefNumberGen");
  emitDefNumberGenUpdate(out, "@lastAccEngineDynamicRuleId", "@accEngineDynamicRuleColumnTypeId");
  emitDefNumberGenUpdate(out, "@lastAccEngineAccountRuleId", "@accEngineAccountRuleColumnTypeId");
  emitDefNumberGenUpdate(out, "@lastAccEngineComponentId", "@accEngineComponentColumnTypeId");
  emitDefNumberGenUpdate(out, "@lastAccEngineGroupId", "@accEngineGroupColumnTypeId");
  emitDefNumberGenUpdate(out, "@lastAccEngineEventId", "@accEngineEventColumnTypeId");
  emitDefNumberGenUpdate(out, "@lastAccEngineModelDefinitionId", "@accEngineModelDefinitionColumnTypeId");
  emitDefNumberGenUpdate(out, "@lastAccEngineItemId", "@accEngineItemColumnTypeId");
  L("        --#endregion");
  L("    END");
  L("");
  L("    COMMIT TRANSACTION");
  L("END TRY");
  L("");
  L("BEGIN CATCH");
  L("    IF @@TRANCOUNT > 0");
  L("        ROLLBACK TRANSACTION;");
  L("");
  L("    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();");
  L("    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();");
  L("    DECLARE @ErrorState INT = ERROR_STATE();");
  L("    DECLARE @ErrorLine INT = ERROR_LINE();");
  L("");
  L("    RAISERROR ('Error on line %d: %s', @ErrorSeverity, @ErrorState, @ErrorLine, @ErrorMessage);");
  L("END CATCH");
  L("GO");

  return out;
}

/** "None" / "null" / "#N/A" gibi bos hucre sizintilarini gercek bos degere cevirir. */
function cleanNull(v: string): string {
  const t = v.trim();
  const lo = t.toLowerCase();
  if (lo === "none" || lo === "null" || lo === "#n/a" || lo === "#yok") return "";
  return t;
}

/** 'TREX/FX/SPOT/LCYBFCYS/' -> 'FX/SPOT/LCYBFCYS' */
function relPath(shared: SharedData, p: string): string {
  const segs = pathSegments(p);
  if (segs.length > 0 && segs[0] === setting(shared, "AppRoot")) segs.shift();
  return segs.join("/");
}

/** Bir yaprak path'i icin model adi. Tek kaynak: Shared!Path bolumu. */
function modelNameForPath(shared: SharedData, path: string): string {
  const rel = relPath(shared, path);
  let best = "", bestLen = -1;
  for (let i = 0; i < shared.modelNameByPath.length; i++) {
    const k = relPath(shared, shared.modelNameByPath[i][0]);
    if (k === "") continue;
    if (k === rel || rel.indexOf(k + "/") === 0) {
      if (k.length > bestLen) { bestLen = k.length; best = shared.modelNameByPath[i][1]; }
    }
  }
  return best;
}

/** Model semasi: Shared!Model "Schema" kolonu. */
function modelSchemaForName(shared: SharedData, name: string): string {
  return lookup2(shared.modelSchemaByName, name);
}

/** Model adi -> T-SQL degisken adi. */
function modelVarByName(name: string): string {
  return "@model" + slug(name) + "Id";
}

function emitEventStep(out: string[], item: ItemDef, evt: EventDef, step: number, shared: SharedData): void {
  const L = (s: string) => { out.push(s); };
  const label = item.leafCode + " " + evt.eventTypeCode;

  L("    /********** " + step + ". STEP: " + label + " **************************/");
  L("    BEGIN");
  L("        PRINT '" + q(label) + " Event Started...';");
  L("");

  L("        --#region AccEngineEvent");
  L("        ------------------------------------------------------------------------------------------------------------------------");
  L("        -- Event " + label);
  L("        ------------------------------------------------------------------------------------------------------------------------");
  L("        IF NOT EXISTS(SELECT 1");
  L("                      FROM dbo.AccEngineEvent");
  L("                      WHERE ItemId = " + item.varName);
  L("                        AND EventTypeCode = N'" + q(evt.eventTypeCode) + "')");
  L("            BEGIN");
  L("                INSERT INTO dbo.AccEngineEvent (Id, ItemId, EventTypeCode, ModifiedBy, ModifiedDate,");
  L("                                                EventDescriptionDynamicRuleId)");
  L("                OUTPUT inserted.Id INTO @tempTable");
  L("                VALUES (@lastAccEngineEventId, " + item.varName + ", N'" + q(evt.eventTypeCode) + "', @stateMaker, @stateDate, " + (evt.descRuleVar === "" ? "null" : evt.descRuleVar) + ");");
  L("");
  L("                SELECT " + evt.varName + " = Id FROM @tempTable;");
  L("                DELETE FROM @tempTable");
  L("                SELECT @lastAccEngineEventId = @lastAccEngineEventId + 1");
  L("            END");
  L("        ELSE");
  L("            BEGIN");
  L("                SELECT " + evt.varName + " = Id");
  L("                FROM dbo.AccEngineEvent");
  L("                WHERE ItemId = " + item.varName);
  L("                  AND EventTypeCode = N'" + q(evt.eventTypeCode) + "'");
  L("            END");
  L("        --#endregion");
  L("        ------------------------------------------------------------------------------------------------------------------------");
  L("");

  for (let g = 0; g < evt.groups.length; g++) {
    const grp = evt.groups[g];
    const grpRuleVar = grp.ruleName === "" ? "" : "@dr" + slug(grp.ruleName);
    const grpRulePredicate = grp.ruleName === "" ? "ValidationRuleId IS NULL" : "ValidationRuleId = " + grpRuleVar;
    const grpRuleValue = grp.ruleName === "" ? "null" : grpRuleVar;

    L("        ------------------------------------------------------------------------------------------------------------------------");
    L("        --#region AccEngineGroup");
    L("        -- Group " + evt.eventTypeCode + (grp.ruleName === "" ? "" : " [" + grp.ruleName + "]"));
    L("        ------------------------------------------------------------------------------------------------------------------------");
    L("        IF NOT EXISTS(SELECT 1");
    L("                        FROM dbo.AccEngineGroup");
    L("                        WHERE EventId = " + evt.varName);
    L("                        AND " + grpRulePredicate + ")");
    L("            BEGIN");
    L("                INSERT INTO dbo.AccEngineGroup (Id, EventId, ValidationRuleId, [Order],");
    L("                                                ModifiedBy,");
    L("                                                ModifiedDate,");
    L("                                                StateId,");
    L("                                                StateDate,");
    L("                                                StateMaker)");
    L("                OUTPUT inserted.Id INTO @tempTable");
    L("                VALUES (@lastAccEngineGroupId, " + evt.varName + ",");
    L("                        " + grpRuleValue + ", " + grp.order + ",");
    L("                        @stateMaker,");
    L("                        @stateDate,");
    L("                        @StateId,");
    L("                        @stateDate,");
    L("                        @stateMaker);");
    L("                SELECT " + grp.varName + " = Id FROM @tempTable;");
    L("                DELETE FROM @tempTable");
    L("                SELECT @lastAccEngineGroupId = @lastAccEngineGroupId + 1");
    L("            END");
    L("        ELSE");
    L("            BEGIN");
    L("                SELECT " + grp.varName + " = Id");
    L("                FROM dbo.AccEngineGroup");
    L("                WHERE EventId = " + evt.varName);
    L("                    AND " + grpRulePredicate);
    L("            END");
    L("        --#endregion");
    L("        ------------------------------------------------------------------------------------------------------------------------");
    L("");

    /* -- Components -- */
    L("        ------------------------------------------------------------------------------------------------------------------------");
    L("        --#region AccEngineComponent");
    for (let c = 0; c < grp.components.length; c++) {
      const comp = grp.components[c];
      const compRuleVar = comp.ruleName === "" ? "" : "@dr" + slug(comp.ruleName);
      const compRulePredicate = comp.ruleName === "" ? "ValidationRuleId IS NULL" : "ValidationRuleId = " + compRuleVar;
      const compRuleValue = comp.ruleName === "" ? "NULL" : compRuleVar;

      L("        ------------------------------------------------------------------------------------------------------------------------");
      L("        -- Component " + comp.typeName + (comp.ruleName === "" ? "" : " [" + comp.ruleName + "]"));
      L("        ------------------------------------------------------------------------------------------------------------------------");
      L("        IF NOT EXISTS (SELECT 1");
      L("                        FROM dbo.AccEngineComponent");
      L("                        WHERE GroupId = " + grp.varName);
      L("                            AND " + compRulePredicate);
      L("                            AND ComponentTypeCode = " + comp.typeVar);
      L("                            AND [Order] = " + comp.order + ")");
      L("            BEGIN");
      L("                INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order],");
      L("                                                    ModifiedBy,");
      L("                                                    ModifiedDate)");
      L("                OUTPUT inserted.Id INTO @tempTable");
      L("                VALUES (@lastAccEngineComponentId, " + grp.varName + ", " + comp.typeVar + ",");
      L("                        " + compRuleValue + ",");
      L("                        " + comp.order + ",");
      L("                        @stateMaker,");
      L("                        @stateDate);");
      L("                SELECT " + comp.varName + " = Id FROM @tempTable;");
      L("                DELETE FROM @tempTable");
      L("                SELECT @lastAccEngineComponentId = @lastAccEngineComponentId + 1");
      L("            END");
      L("        ELSE");
      L("            BEGIN");
      L("                SELECT " + comp.varName + " = Id");
      L("                FROM dbo.AccEngineComponent");
      L("                WHERE GroupId = " + grp.varName);
      L("                    AND " + compRulePredicate);
      L("                    AND ComponentTypeCode = " + comp.typeVar);
      L("                    AND [Order] = " + comp.order);
      L("            END");
      L("");
    }
    L("        --#endregion");
    L("        ------------------------------------------------------------------------------------------------------------------------");
    L("");

    /* -- Account rules -- */
    L("        ------------------------------------------------------------------------------------------------------------------------");
    L("        --#region AccEngineAccountRule");
    for (let c = 0; c < grp.components.length; c++) {
      const comp = grp.components[c];
      const glList: string[] = [];
      for (let r = 0; r < comp.rules.length; r++) glList.push(comp.rules[r].glCode);
      L("        ------------------------------------------------------------------------------------------------------------------------");
      L("        -- " + comp.typeName + ", " + glList.join(" - "));
      L("        ------------------------------------------------------------------------------------------------------------------------");
      for (let r = 0; r < comp.rules.length; r++) {
        emitAccountRule(out, comp, comp.rules[r], shared);
      }
    }
    L("        --#endregion");
    L("        ------------------------------------------------------------------------------------------------------------------------");
  }

  L("    END");
  L("");
}

function emitAccountRule(out: string[], comp: ComponentDef, rule: AccountRuleDef, shared: SharedData): void {
  const L = (s: string) => { out.push(s); };
  if (rule.alias !== "" && rule.alias !== rule.glCode) L("        -- beklenen GL hesabi: " + rule.alias);
  L("        IF NOT EXISTS(SELECT 1");
  L("                        FROM dbo.AccEngineAccountRule");
  L("                        WHERE ComponentId = " + comp.varName);
  L("                        AND GLCode = N'" + q(rule.glCode) + "'");
  L("                        AND DebitCredit = N'" + rule.debitCredit + "'");
  L("                        AND AmountSource = N'" + q(rule.amountSource) + "'");
  L("                        AND CcySource = N'" + q(rule.ccySource) + "')");
  L("        BEGIN");
  L("            INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,");
  L("                                                    DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,");
  L("                                                    ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,");
  L("                                                    FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,");
  L("                                                    ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)");
  L("            VALUES (@lastAccEngineAccountRuleId, " + comp.varName + ", N'" + q(rule.glCode) + "',");
  L("                    null,");
  L("                    null,");
  L("                    N'" + rule.debitCredit + "', null, N'" + q(rule.amountSource) + "', N'" + setting(shared, "TxnNoSource") + "', N'" + q(rule.valueDateSource) + "', N'" + setting(shared, "TxnDateSource") + "', N'" + q(rule.ccySource) + "',");
  L("                    N'" + q(rule.fcySource) + "', N'" + q(rule.lcyEqvtSource) + "', N'" + q(rule.fcyAmtSource) + "', 0, null, null, @stateMaker,");
  L("                    @stateDate, null, null);");
  L("");
  L("            SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1");
  L("        END");
  L("");
}

function emitDefNumberGenSelect(out: string[], entity: string, lastVar: string, colTypeVar: string): void {
  out.push("        ------------------------------------------------------------------------------------------------------------------------");
  out.push("        -- " + entity + " Last Number");
  out.push("        ------------------------------------------------------------------------------------------------------------------------");
  out.push("        SELECT " + lastVar + " = LastNumber + 1");
  out.push("        FROM dbo.DefNumberGen");
  out.push("        WHERE EntityColumnType = " + colTypeVar);
  out.push("          AND Definition = N'" + entity + " Id'");
  out.push("");
  out.push("        IF (" + lastVar + " = 0)");
  out.push("            THROW 500001, '" + entity + " Last Id Not Found', 1");
}

function emitDefNumberGenUpdate(out: string[], lastVar: string, colTypeVar: string): void {
  out.push("        UPDATE dbo.DefNumberGen");
  out.push("        SET LastNumber     = " + lastVar + ",");
  out.push("            LastUpdateDate = @stateDate");
  out.push("        WHERE EntityColumnType = " + colTypeVar);
  out.push("");
}

function emitDeclareList(out: string[], vars: string[]): void {
  if (vars.length === 0) { out.push("            @noopUnusedVar INT = 0;"); return; }
  for (let i = 0; i < vars.length; i++) {
    out.push("            " + vars[i] + " INT = 0" + (i === vars.length - 1 ? ";" : ","));
  }
}


/* =====================================================================================
 * 6c) PATH scripti  --  urun sayfalarindaki Path satirlarindan item agaci
 * ===================================================================================== */

interface PathNode {
  code: string;
  name: string;
  itemType: string;
  path: string;
  parentPath: string;
  depth: number;
  isLeaf: boolean;
}

/** Urun sayfalarindaki tam Path degerlerinden item agacini kurar. */
function buildTreeFromPaths(paths: string[], shared: SharedData, messages: Message[]): PathNode[] {
  const nodes: PathNode[] = [];
  for (let i = 0; i < paths.length; i++) {
    const segs = pathSegments(paths[i]);
    if (segs.length < 2) continue;
    for (let d = 1; d < segs.length; d++) {
      const path = segs.slice(0, d + 1).join("/") + "/";
      let exists = false;
      for (let k = 0; k < nodes.length; k++) if (nodes[k].path === path) { exists = true; break; }
      if (exists) continue;
      nodes.push({
        code: segs[d],
        name: "",
        itemType: "",
        path: path,
        parentPath: d === 1 ? "" : segs.slice(0, d).join("/") + "/",
        depth: d,
        isLeaf: false
      });
    }
  }
  nodes.sort((a, b) => a.depth - b.depth);

  for (let i = 0; i < nodes.length; i++) {
    let hasChild = false;
    for (let k = 0; k < nodes.length; k++) if (nodes[k].parentPath === nodes[i].path) { hasChild = true; break; }
    nodes[i].isLeaf = !hasChild;
    const nm = lookup2(shared.itemNameByCode, nodes[i].code);
    const tp = lookup2(shared.itemTypeByCode, nodes[i].code);
    nodes[i].name = nm !== "" ? nm : nodes[i].code;
    nodes[i].itemType = tp;
  }

  let noName = "";
  const listed: string[] = [];
  for (let i = 0; i < nodes.length; i++) {
    const c = nodes[i].code;
    if (listed.indexOf(c) >= 0) continue;
    listed.push(c);
    if (lookup2(shared.itemNameByCode, c) === "") noName += (noName === "" ? "" : ", ") + c;
  }
  if (noName !== "") {
    messages.push({ level: "ERROR", sheet: "Shared", text: "Su kodlar Shared!Item bolumunde yok (Code | Name | ItemType): " + noName });
  }
  let noType = "";
  const listed2: string[] = [];
  for (let i = 0; i < nodes.length; i++) {
    const c = nodes[i].code;
    if (listed2.indexOf(c) >= 0) continue;
    listed2.push(c);
    if (nodes[i].itemType === "") noType += (noType === "" ? "" : ", ") + c;
  }
  if (noType !== "") {
    messages.push({ level: "ERROR", sheet: "Shared", text: "Shared!Item bolumunde ItemType'i bos olan kodlar: " + noType });
  }
  return nodes;
}

/** Path agacini kuran bagimsiz script (AccEngineItemType / ItemCode / Item). */
function emitPathScript(nodes: PathNode[], modelNames: string[], shared: SharedData): string[] {
  const out: string[] = [];
  const L = (s: string) => { out.push(s); };

  L("/***************************************************************************************************");
  L("* Accounting Engine item tree (Path satirlarindan uretildi)");
  L("* GENERATED - do not edit by hand.");
  L("* Bu script urun scriptlerinden ONCE calistirilmalidir.");
  L("*   generated at : " + isoStamp());
  L("***************************************************************************************************/");
  L("");
  L("USE NetTrexAcc;");
  L("GO");
  L("");
  L("SET XACT_ABORT ON;");
  L("");
  L("BEGIN TRANSACTION;");
  L("");
  L("BEGIN TRY");
  L("    DECLARE");
  L("        @StateId INT = " + setting(shared, "StateId") + ",");
  L("        @stateDate datetime = GETDATE(),");
  L("        @stateMaker nvarchar(80) = N'" + setting(shared, "StateMaker") + "',");
  L("        @number INT = 0;");
  L("");
  L("    DECLARE");
  for (let i = 0; i < modelNames.length; i++) {
    L("        " + modelVarByName(modelNames[i]) + " INT = NULL" + (i === modelNames.length - 1 ? ";" : ","));
  }
  L("");
  L("    DECLARE");
  L("        @lastAccEngineItemId INT = 0,");
  L("        @accEngineItemColumnTypeId INT = 7,");
  L("        @lastAccEngineItemCodeId INT = 0,");
  L("        @accEngineItemCodeColumnTypeId INT = 8,");
  L("        @lastAccEngineItemTypeId INT = 0,");
  L("        @accEngineItemTypeColumnTypeId INT = 9,");
  L("        @lastAccEngineModelDefinitionId INT = 0,");
  L("        @accEngineModelDefinitionColumnTypeId INT = 10;");
  L("");
  L("    --#region DefNumberGen");
  emitDefNumberGenSelect(out, "AccEngineItem", "@lastAccEngineItemId", "@accEngineItemColumnTypeId");
  emitDefNumberGenSelect(out, "AccEngineItemCode", "@lastAccEngineItemCodeId", "@accEngineItemCodeColumnTypeId");
  emitDefNumberGenSelect(out, "AccEngineItemType", "@lastAccEngineItemTypeId", "@accEngineItemTypeColumnTypeId");
  emitDefNumberGenSelect(out, "AccEngineModelDefinition", "@lastAccEngineModelDefinitionId", "@accEngineModelDefinitionColumnTypeId");
  L("    --#endregion");
  L("");
  L("    -- Modeller (yalnizca yaprak item'lara baglanir)");
  for (let i = 0; i < modelNames.length; i++) {
    const mn = modelNames[i];
    const ms = modelSchemaForName(shared, mn);
    const mv = modelVarByName(mn);
    if (ms !== "") {
      L("    IF NOT EXISTS(SELECT 1 FROM dbo.AccEngineModelDefinition WHERE Name = N'" + q(mn) + "')");
      L("        BEGIN");
      L("            INSERT INTO dbo.AccEngineModelDefinition (Id, [Schema], Name, StateId, StateDate, StateMaker)");
      L("            VALUES (@lastAccEngineModelDefinitionId,");
      L("                    N'" + q(ms) + "',");
      L("                    N'" + q(mn) + "', @StateId, @stateDate, @stateMaker);");
      L("            SELECT @lastAccEngineModelDefinitionId = @lastAccEngineModelDefinitionId + 1");
      L("        END");
    }
    L("    SELECT " + mv + " = Id FROM dbo.AccEngineModelDefinition WHERE Name = N'" + q(mn) + "';");
    L("    IF (" + mv + " IS NULL) THROW 500001, '" + q(mn) + " Not Found - Shared!Model bolumune (Name | Schema) ekleyin ya da model DML''ini once calistirin', 1;");
  }
  L("");

  /* Item Types */
  L("    ------------------------------------------------------------------------------------------------------------------------");
  L("    -- Accounting Engine Item Type");
  L("    ------------------------------------------------------------------------------------------------------------------------");
  L("    --#region AccEngineItemType");
  const usedTypes: string[] = [];
  for (let i = 0; i < nodes.length; i++) if (usedTypes.indexOf(nodes[i].itemType) < 0) usedTypes.push(nodes[i].itemType);
  for (let i = 0; i < usedTypes.length; i++) {
    const code = usedTypes[i];
    L("    -- " + code);
    L("    IF NOT EXISTS(SELECT 1 FROM dbo.AccEngineItemType WHERE Code = N'" + q(code) + "')");
    L("        BEGIN");
    L("            INSERT INTO dbo.AccEngineItemType (Id, Code, Name, IsLocked, IsRoot, ApplicationCode, StateId, StateDate, StateMaker)");
    L("            VALUES (@lastAccEngineItemTypeId, N'" + q(code) + "', N'" + q(code) + "', 0, null, '" + setting(shared, "ItemTypeApplicationCode") + "', @StateId, @stateDate, @stateMaker);");
    L("            SELECT @lastAccEngineItemTypeId = @lastAccEngineItemTypeId + 1");
    L("        END");
  }
  L("    --#endregion");
  L("");

  /* Item Codes */
  L("    ------------------------------------------------------------------------------------------------------------------------");
  L("    -- Accounting Engine Item Code");
  L("    ------------------------------------------------------------------------------------------------------------------------");
  L("    --#region AccEngineItemCode");
  const seenCodes: string[] = [];
  for (let i = 0; i < nodes.length; i++) {
    const nd = nodes[i];
    if (seenCodes.indexOf(nd.code) >= 0) continue;
    seenCodes.push(nd.code);
    L("    -- " + nd.name + " => " + nd.code + " => " + nd.itemType);
    L("    IF NOT EXISTS(SELECT 1 FROM dbo.AccEngineItemCode WHERE Code = N'" + q(nd.code) + "')");
    L("        BEGIN");
    L("            INSERT INTO dbo.AccEngineItemCode (Id, Code, Name, ItemTypeCode, StateId, StateDate, StateMaker)");
    L("            VALUES (@lastAccEngineItemCodeId, N'" + q(nd.code) + "', N'" + q(nd.name) + "', N'" + q(nd.itemType) + "', @StateId, @stateDate, @stateMaker);");
    L("            SELECT @lastAccEngineItemCodeId = @lastAccEngineItemCodeId + 1");
    L("        END");
  }
  L("    --#endregion");
  L("");

  /* Items */
  L("    ------------------------------------------------------------------------------------------------------------------------");
  L("    -- Accounting Engine Item (agac)");
  L("    ------------------------------------------------------------------------------------------------------------------------");
  L("    --#region AccEngineItem");
  for (let i = 0; i < nodes.length; i++) {
    const nd = nodes[i];
    const modelExpr = nd.isLeaf ? modelVarByName(modelNameForPath(shared, nd.path)) : "NULL";
    L("    -- " + nd.path);
    L("    IF NOT EXISTS(SELECT 1 FROM dbo.AccEngineItem WHERE Path = N'" + nd.path + "')");
    L("        BEGIN");
    if (nd.parentPath === "") {
      L("            SET @number = " + setting(shared, "RootParentId") + ";");
    } else {
      L("            SELECT @number = Id FROM dbo.AccEngineItem WHERE Path = N'" + nd.parentPath + "';");
      L("            IF (@number IS NULL) THROW 500001, 'Parent " + nd.parentPath + " Not Found', 1;");
    }
    L("            INSERT INTO dbo.AccEngineItem (Id, ItemCode, ParentId, Path, ModelDefinitionId, StateId, StateDate, StateMaker, TemplateId)");
    L("            VALUES (@lastAccEngineItemId, N'" + q(nd.code) + "', @number, N'" + nd.path + "', " + modelExpr + ", @StateId, @stateDate, @stateMaker, " + setting(shared, "TemplateId") + ");");
    L("            SELECT @lastAccEngineItemId = @lastAccEngineItemId + 1");
    L("        END");
    if (nd.isLeaf) {
      L("    ELSE");
      L("        UPDATE dbo.AccEngineItem");
      L("        SET ModelDefinitionId = " + modelExpr + ", StateDate = @stateDate, StateMaker = @stateMaker");
      L("        WHERE Path = N'" + nd.path + "'");
      L("          AND (ModelDefinitionId IS NULL OR ModelDefinitionId <> " + modelExpr + ");");
    }
  }
  L("    --#endregion");
  L("");
  L("    --#region DefNumberGen Update");
  emitDefNumberGenUpdate(out, "@lastAccEngineItemId", "@accEngineItemColumnTypeId");
  emitDefNumberGenUpdate(out, "@lastAccEngineItemCodeId", "@accEngineItemCodeColumnTypeId");
  emitDefNumberGenUpdate(out, "@lastAccEngineItemTypeId", "@accEngineItemTypeColumnTypeId");
  emitDefNumberGenUpdate(out, "@lastAccEngineModelDefinitionId", "@accEngineModelDefinitionColumnTypeId");
  L("    --#endregion");
  L("");
  L("    COMMIT TRANSACTION");
  L("END TRY");
  L("BEGIN CATCH");
  L("    IF @@TRANCOUNT > 0");
  L("        ROLLBACK TRANSACTION;");
  L("");
  L("    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();");
  L("    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();");
  L("    DECLARE @ErrorState INT = ERROR_STATE();");
  L("    DECLARE @ErrorLine INT = ERROR_LINE();");
  L("");
  L("    RAISERROR ('Error on line %d: %s', @ErrorSeverity, @ErrorState, @ErrorLine, @ErrorMessage);");
  L("END CATCH");
  L("GO");
  return out;
}


/* =====================================================================================
 * 6b) Cikti modu: debug / compact
 * ===================================================================================== */

function postProcess(lines: string[]): string[] {
  if (OUTPUT_MODE !== "compact") return lines;

  /* 1) temizle */
  const kept: string[] = [];
  let inBlock = false;
  for (let i = 0; i < lines.length; i++) {
    let t = lines[i].replace(/^ +| +$/g, "");
    if (t === "") continue;
    if (inBlock) {
      if (t.indexOf("*/") >= 0) inBlock = false;
      continue;
    }
    if (t.indexOf("/*") === 0) {
      if (t.indexOf("*/") < 0) inBlock = true;
      continue;
    }
    if (t.indexOf("--") === 0) continue;
    if (t.indexOf("*") === 0) continue;
    t = t.replace(/ {2,}/g, " ");
    kept.push(t);
  }

  /* 2) birlestir */
  const out: string[] = [];
  let buf = "";
  for (let i = 0; i < kept.length; i++) {
    const t = kept[i];
    if (t.toUpperCase() === "GO") {
      if (buf !== "") { out.push(buf); buf = ""; }
      out.push("GO");
      continue;
    }
    if (t.indexOf("--") >= 0) {
      if (buf !== "") { out.push(buf); buf = ""; }
      out.push(t);
      continue;
    }
    if (buf === "") { buf = t; continue; }
    if (buf.length + 1 + t.length > COMPACT_LINE_CHARS) { out.push(buf); buf = t; continue; }
    buf += " " + t;
  }
  if (buf !== "") out.push(buf);
  return out;
}


/* =====================================================================================
 * 7) Cikti yazimi  --  TEK SAYFA, KOLON KOLON
 * ===================================================================================== */

function writeAllSheet(workbook: ExcelScript.Workbook, names: string[], scripts: string[][]): void {
  let sheet = workbook.getWorksheet(OUT_SHEET);
  if (!sheet) {
    sheet = workbook.addWorksheet(OUT_SHEET);
  } else {
    const used = sheet.getUsedRange();
    if (used) used.clear(ExcelScript.ClearApplyTo.all);
  }
  if (names.length === 0) {
    sheet.getRange("A1").setValue("Script uretilmedi - GEN_LOG sayfasina bakin.");
    return;
  }

  const cols = names.length;

  let blockSize = Math.floor(MAX_CHARS_PER_WRITE / cols);
  if (blockSize > BLOCK_CHARS) blockSize = BLOCK_CHARS;
  if (blockSize < 2000) blockSize = 2000;

  const cells: string[][] = [];
  let maxRows = 0;
  for (let i = 0; i < cols; i++) {
    const col = (WRITE_MODE === "lines") ? scripts[i] : toBlocks(scripts[i], blockSize);
    cells.push(col);
    if (col.length > maxRows) maxRows = col.length;
  }

  sheet.getRangeByIndexes(0, 0, maxRows + 1, cols).setNumberFormat("@");

  const header: string[][] = [[]];
  for (let i = 0; i < cols; i++) header[0].push(names[i] + "  (" + scripts[i].length + " satir)");
  const hRange = sheet.getRangeByIndexes(0, 0, 1, cols);
  hRange.setValues(header);
  hRange.getFormat().getFont().setBold(true);

  let start = 0;
  while (start < maxRows) {
    const values: string[][] = [];
    let budget = 0;
    let r = start;
    while (r < maxRows) {
      const row: string[] = [];
      let rowChars = 0;
      for (let c = 0; c < cols; c++) {
        const v = r < cells[c].length ? cells[c][r] : "";
        row.push(v);
        rowChars += v.length;
      }
      if (values.length > 0 && budget + rowChars > MAX_CHARS_PER_WRITE) break;
      if (values.length >= MAX_ROWS_PER_WRITE) break;
      values.push(row);
      budget += rowChars;
      r++;
    }
    sheet.getRangeByIndexes(start + 1, 0, values.length, cols).setValues(values);
    start = r;
  }

  for (let c = 0; c < cols; c++) {
    sheet.getRangeByIndexes(0, c, 1, 1).getFormat().setColumnWidth(520);
  }
}

/** Script satirlarini ~BLOCK_CHARS karakterlik bloklara boler. */
function toBlocks(lines: string[], blockSize: number): string[] {
  const out: string[] = [];
  let buf = "";
  for (let i = 0; i < lines.length; i++) {
    let line = lines[i];
    while (line.length > blockSize) {
      if (buf !== "") { out.push(buf); buf = ""; }
      out.push(line.substring(0, blockSize));
      line = line.substring(blockSize);
    }
    if (buf !== "" && buf.length + line.length + 2 > blockSize) {
      out.push(buf);
      buf = "";
    }
    buf += (buf === "" ? "" : "\r\n") + line;
  }
  if (buf !== "") out.push(buf);
  return out;
}

function writeLogSheet(workbook: ExcelScript.Workbook, summary: (string | number)[][], messages: Message[], shared: SharedData): void {
  let sheet = workbook.getWorksheet(LOG_SHEET);
  if (!sheet) {
    sheet = workbook.addWorksheet(LOG_SHEET);
  } else {
    const used = sheet.getUsedRange();
    if (used) used.clear(ExcelScript.ClearApplyTo.all);
  }

  const rows: (string | number)[][] = [];
  rows.push(["AccountingSqlGenerator", isoStamp(), "mode: " + OUTPUT_MODE, "", "", "", "", ""]);
  rows.push(["", "", "", "", "", "", "", ""]);
  rows.push(["Sheet", "Status", "Items", "Events", "Groups", "Components", "AccountRules", "SQL Lines"]);
  for (let i = 0; i < summary.length; i++) rows.push(summary[i]);
  rows.push(["", "", "", "", "", "", "", ""]);
  rows.push(["Uygulanan kurallar", "", "", "", "", "", "", ""]);
  rows.push(["INFO", "", "Cikti tek sayfada: '" + OUT_SHEET + "'. Her urun sayfasi ayri bir kolon, 1. satir sayfa adi.", "", "", "", "", ""]);
  rows.push(["INFO", "", "OUTPUT_MODE = '" + OUTPUT_MODE + "'  (debug = yorumlu, compact = sikistirilmis)", "", "", "", "", ""]);
  rows.push(["INFO", "", "WRITE_MODE = '" + WRITE_MODE + "'  (blocks = ~" + BLOCK_CHARS + " karakterlik parcalar, hizli; lines = satir basina bir hucre, yavas)", "", "", "", "", ""]);
  rows.push(["INFO", "", "Kolon sirasi her group'un 'ComponentValidationRule' baslik satirindan okunur.", "", "", "", "", ""]);
  rows.push(["INFO", "", "Event tipleri ve Amount / Ccy Source adlari Shared sayfasindan okunur.", "", "", "", "", ""]);
  rows.push(["INFO", "", "Event aciklamasi: Shared!Event 'Event Description' kolonundan alinir. Kolon yoksa Type='" + setting(shared, "CalculationRuleTypeName") + "' kurallari arasindan tahmin edilir.", "", "", "", "", ""]);
  rows.push(["INFO", "", "Path derinligi serbest; ara seviye item'lar otomatik olusturulur.", "", "", "", "", ""]);
  rows.push(["INFO", "", "FcySource: 'FCY Source' kolonundan alinir; kolon yoksa CcySource ile ayni olur.", "", "", "", "", ""]);
  rows.push(["INFO", "", "ValueDateSource = " + setting(shared, "ValueDateSource") + " (tum satirlarda ayni; Shared!Settings ile degistirilebilir)", "", "", "", "", ""]);
  rows.push(["INFO", "", "Group [Order] = event icindeki sira (sayfadaki sira, 1'den baslar)", "", "", "", "", ""]);
  rows.push(["INFO", "", "Model listesi: Shared!Model (" + shared.modelSchemaByName.length + " kayit) | Model baglama: Shared!Path (" + shared.modelNameByPath.length + " kayit) | Item ad/tip: Shared!Item (" + shared.itemNameByCode.length + " kayit)", "", "", "", "", ""]);
  rows.push(["INFO", "", "Motor sabitleri: Shared!Settings (" + shared.settings.length + " ezme) - AppRoot=" + setting(shared, "AppRoot") + ", StateId=" + setting(shared, "StateId") + ", TemplateId=" + setting(shared, "TemplateId"), "", "", "", "", ""]);
  rows.push(["INFO", "", "Tekrar calistirma guvenligi: component = GroupId+ComponentTypeCode+ValidationRuleId+[Order], account rule = ComponentId+GLCode+DebitCredit+AmountSource+CcySource", "", "", "", "", ""]);
  rows.push(["INFO", "", "AccountMap baslik satiri: 'Path' ve 'Source' basliklarinin ikisini de tasiyan ilk satir. Kolon sirasi serbest.", "", "", "", "", ""]);
  rows.push(["INFO", "", "AccountMap mukerrerlik: Path + Source + Rule1..Rule10 + Ccy + CustomerSource + AccountSource + Order. Ayni alias'in urune gore farkli GL'e gitmesi normaldir.", "", "", "", "", ""]);
  rows.push(["INFO", "", "AccountMap Target: sabit GL (Target) ya da hesaplama (Target.CalculationRule); en az biri dolu olmali.", "", "", "", "", ""]);
  rows.push(["INFO", "", "AccountMap: '" + ACCOUNT_MAP_SHEET + "' sayfasi -> " + ACCOUNT_MAP_TABLE + " (Source = urun sayfasindaki Alias, Target = gercek GL).", "", "", "", "", ""]);
  rows.push(["INFO", "", "AccountMap Path: motor Contains ile eslestirir; sondaki slash " + (ACCOUNT_MAP_PATH_TRAILING_SLASH ? "EKLENIR" : "EKLENMEZ") + " (ACCOUNT_MAP_PATH_TRAILING_SLASH)", "", "", "", "", ""]);
  rows.push(["INFO", "", "AccountMap CustomerAccountTypeCode kolonu: " + (ACCOUNT_MAP_EMIT_ACCOUNT_TYPE ? "SQL'e yazilir ('" + ACCOUNT_MAP_ACCTYPE_COLUMN + "')" : "taninir ama SQL'e yazilmaz (ACCOUNT_MAP_EMIT_ACCOUNT_TYPE = false)"), "", "", "", "", ""]);
  rows.push(["", "", "", "", "", "", "", ""]);
  rows.push(["Level", "Sheet", "Message", "", "", "", "", ""]);
  if (messages.length === 0) {
    rows.push(["INFO", "", "Uyari veya hata yok.", "", "", "", "", ""]);
  } else {
    for (let i = 0; i < messages.length; i++) {
      rows.push([messages[i].level, messages[i].sheet, messages[i].text, "", "", "", "", ""]);
    }
  }

  sheet.getRangeByIndexes(0, 0, rows.length, 8).setValues(rows);
  sheet.getRange("A3:H3").getFormat().getFont().setBold(true);
  sheet.getRange("A1").getFormat().getFont().setBold(true);
  sheet.getRange("A:A").getFormat().setColumnWidth(110);
  sheet.getRange("B:B").getFormat().setColumnWidth(180);
  sheet.getRange("C:C").getFormat().setColumnWidth(700);
  sheet.activate();
}


/* =====================================================================================
 * 8) Yardimcilar
 * ===================================================================================== */

function q(s: string): string {
  return s.replace(/'/g, "''");
}

function slug(s: string): string {
  let t = " " + s + " ";
  t = t.replace(/>=/g, " Gte ").replace(/<=/g, " Lte ").replace(/!=/g, " Ne ");
  t = t.replace(/=/g, " Eq ").replace(/>/g, " Gt ").replace(/</g, " Lt ");
  t = t.replace(/[^A-Za-z0-9 ]/g, " ");
  const parts = t.split(" ");
  let outStr = "";
  for (let i = 0; i < parts.length; i++) {
    if (parts[i] === "") continue;
    outStr += parts[i];
  }
  if (outStr === "") outStr = "X";
  if (/^[0-9]/.test(outStr)) outStr = "N" + outStr;
  if (outStr.length > 60) outStr = outStr.substring(0, 60);
  return outStr;
}

function titleCase(s: string): string {
  if (s === "") return s;
  return s.substring(0, 1).toUpperCase() + s.substring(1).toLowerCase();
}

/** [key, value] listesinde buyuk/kucuk harf duyarsiz arama; bulunamazsa "". */
function lookup2(table: string[][], key: string): string {
  const k = key.toLowerCase();
  for (let i = 0; i < table.length; i++) {
    if (String(table[i][0]).toLowerCase() === k) return String(table[i][1]);
  }
  return "";
}

/** Shared!Settings > DEFAULTS sirasiyla ayar degeri dondurur. */
function setting(shared: SharedData, key: string): string {
  const v = lookup2(shared.settings, key);
  if (v !== "") return v;
  return lookup2(DEFAULTS, key);
}

/** Kural adi Shared!Dynamic Rule icinde tanimli mi? */
function hasRule(shared: SharedData, name: string): boolean {
  const k = name.toLowerCase();
  for (let i = 0; i < shared.dynamicRuleByName.length; i++) {
    if (String(shared.dynamicRuleByName[i][0]).toLowerCase() === k) return true;
  }
  return false;
}

/** [key, ...] listesinde n. kolonu dondurur; bulunamazsa "". */
function lookupN(table: string[][], key: string, col: number): string {
  const k = key.toLowerCase();
  for (let i = 0; i < table.length; i++) {
    if (String(table[i][0]).toLowerCase() === k) {
      return table[i].length > col ? String(table[i][col]) : "";
    }
  }
  return "";
}

function isCalcRule(shared: SharedData, type: string): boolean {
  return type.toLowerCase() === setting(shared, "CalculationRuleTypeName").toLowerCase();
}

function countTree(items: ItemDef[]): number[] {
  let ev = 0, gr = 0, co = 0, ar = 0;
  for (let i = 0; i < items.length; i++) {
    ev += items[i].events.length;
    for (let e = 0; e < items[i].events.length; e++) {
      gr += items[i].events[e].groups.length;
      for (let g = 0; g < items[i].events[e].groups.length; g++) {
        co += items[i].events[e].groups[g].components.length;
        for (let c = 0; c < items[i].events[e].groups[g].components.length; c++) {
          ar += items[i].events[e].groups[g].components[c].rules.length;
        }
      }
    }
  }
  return [items.length, ev, gr, co, ar];
}

function msg(level: string, sheet: string, text: string): Message {
  return { level: level, sheet: sheet, text: text };
}

function warnOnce(res: ParseResult, key: string, message: Message): void {
  if (res.warnKeys.indexOf(key) >= 0) return;
  res.warnKeys.push(key);
  res.warnings.push(message);
}

function isoStamp(): string {
  const d = new Date();
  return d.toISOString().replace("T", " ").substring(0, 19) + " UTC";
}

/* =====================================================================================
 *  EK BOLUM: AccountMap  ->  dbo.AccAccountMap DML uretimi
 * =====================================================================================
 *  MOTOR DAVRANISI
 *    x.Source == rule.GLCode  &&  x.IsEnabled  &&  EventPath.Contains(x.Path)
 *      -> Source, urun sayfasindaki ALIAS ile eslesir
 *      -> IsEnabled = 1 olmali, yoksa satir hic secilmez
 *      -> Path substring olarak aranir
 *    Nihai GL: TargetRule varsa onun sonucu, yoksa Target
 *
 *  BASLIK SATIRI SERBEST
 *    Baslik satiri, icinde 'Path' ve 'Source' basliklarini birlikte tasiyan ILK satirdir.
 *    Kolon sirasi serbesttir; basliklarin uzerinde gruplama satiri olabilir.
 *    Taninmayan basliklar GEN_LOG'a uyari olarak yazilir.
 * ===================================================================================== */


/* =====================================================================================
 * A) CONFIG
 * ===================================================================================== */

/** AccountMap verisinin okunacagi sayfa. */
const ACCOUNT_MAP_SHEET = "AccountMap";

/** SQL_ALL'da bu scriptin kolon basligi. */
const ACCOUNT_MAP_OUT_NAME = "ACCOUNTMAP";

/** Hedef tablo adi. */
const ACCOUNT_MAP_TABLE = "dbo.AccAccountMap";

/** Baslik satiri aranacak en fazla satir sayisi. */
const ACCOUNT_MAP_HEADER_SCAN_ROWS = 50;

/**
 * Path'in sonuna "/" eklensin mi?
 *   false -> referans DML ile ayni ('TREX/OPT1/FX/BUY/CALL/LCYFCY')
 *   true  -> AccEngineItem.Path ile ayni ('.../LCYFCY/')
 */
const ACCOUNT_MAP_PATH_TRAILING_SLASH = false;

/**
 * CustomerAccountTypeCode kolonu SQL'e yazilsin mi?
 *   false -> kolon TANINIR (uyari verilmez) ama SQL'e girmez.
 *            dbo.AccAccountMap'te karsiligi yoksa bu deger kullanilir.
 *   true  -> asagidaki DB kolon adiyla IF NOT EXISTS ve INSERT'e eklenir.
 */
const ACCOUNT_MAP_EMIT_ACCOUNT_TYPE = true;
/** ACCOUNT_MAP_EMIT_ACCOUNT_TYPE = true iken kullanilacak DB kolon adi. */
const ACCOUNT_MAP_ACCTYPE_COLUMN = "CustomerAccountTypeCodeSourceRuleId";

/** AccountMap motor sabitleri (Shared!Settings ile ezilebilir). */
const ACCOUNT_MAP_DEFAULTS: string[][] = [
  ["AccountMapColumnTypeId", "11"],
  ["AccountMapDefinitionName", "AccAccountMap Id"],
  ["AccountMapDefaultOrder", "10"],
  ["AccountMapIsEnabled", "1"]
];

/** "bos say" kabul edilen hucre metinleri. */
const ACCOUNT_MAP_NULL_TOKENS: string[] = ["null", "none", "-", "yok", "bos", "n/a", "na"];

/** IsEnabled = 0 sayilan metinler. */
const ACCOUNT_MAP_FALSE_TOKENS: string[] = ["0", "false", "hayir", "no", "kapali", "pasif", "h"];
/** IsEnabled = 1 sayilan metinler. */
const ACCOUNT_MAP_TRUE_TOKENS: string[] = ["1", "true", "evet", "yes", "acik", "aktif", "e"];

/** AccountMap baslik satiri kolon adlari. */
const HEADER_MAP_PATH: string[] = ["path", "item path", "itempath"];
const HEADER_MAP_SOURCE: string[] = ["source", "alias", "sourcealias", "source alias"];
const HEADER_MAP_ORDER: string[] = ["order", "sira"];
const HEADER_MAP_CCY: string[] = ["ccy", "currency"];
const HEADER_MAP_MAINGL: string[] = ["targetmaingl", "target main gl", "main gl", "maingl"];
const HEADER_MAP_TARGET: string[] = ["target", "target gl", "targetgl"];
const HEADER_MAP_TARGETRULE: string[] = ["target.calculationrule", "target calculationrule", "targetcalculationrule", "target rule", "targetrule"];
const HEADER_MAP_CUSTSRC: string[] = ["customersource", "customer source", "customercodesource", "customercodesourcerule"];
const HEADER_MAP_ACCSRC: string[] = ["accountsource", "account source", "customeraccountsource", "customer account source", "customeraccountcodesource", "customer account code source"];
/** CustomerAccountWorkGroupCodeSourceRuleId */
const HEADER_MAP_WORKGROUP: string[] = ["customeraccountworkgroupcodesource", "customer account work group code source", "customeraccountworkgroupsource", "workgroupsource", "work group source", "workgroup"];
/** CustomerAccountBranchCodeSourceRuleId */
const HEADER_MAP_BRANCH: string[] = ["customeraccountbranchcodesource", "customer account branch code source", "customeraccountbranchsource", "branchsource", "branch source", "branch"];
/** CustomerAccountTypeCode - ACCOUNT_MAP_EMIT_ACCOUNT_TYPE ile SQL'e girer. */
const HEADER_MAP_ACCTYPE: string[] = ["customeraccounttypecode", "customer account type code"];

const HEADER_MAP_DESC: string[] = ["description", "aciklama"];
/** Bilincli yok sayilan basliklar (SQL'e girmez, uyari da verilmez). */
const HEADER_MAP_IGNORE: string[] = ["not", "notlar", "kontrol"];
const HEADER_MAP_ENABLED: string[] = ["isenabled", "enabled", "aktif"];


/* =====================================================================================
 * B) Veri modeli
 * ===================================================================================== */

interface AccountMapColMap {
  path: number; source: number; order: number; ccy: number;
  mainGl: number; target: number; targetRule: number;
  custSrc: number; accSrc: number; workGroup: number; branch: number; accType: number;
  desc: number; enabled: number;
  rules: number[];
  headerRow: number;
  unknown: string;
  ignored: string;
  ok: boolean;
}

interface AccountMapRow {
  excelRow: number;
  path: string;
  source: string;
  order: string;
  ccy: string;
  mainGl: string;
  target: string;
  targetRuleVar: string;
  custSrcVar: string;
  accSrcVar: string;
  workGroupVar: string;
  branchVar: string;
  accTypeVar: string;         // "" => NULL
  ruleVars: string[];
  description: string;
  isEnabled: string;
}

interface AccountMapParse {
  rows: AccountMapRow[];
  usedDynamicRules: string[][];
  pathCount: number;
  headerRow: number;
  hasWorkGroup: boolean;
  hasBranch: boolean;
  hasAccType: boolean;        // kolon var VE emit ediliyor mu
  ok: boolean;
}


/* =====================================================================================
 * C) Okuma + dogrulama
 * ===================================================================================== */

function readAccountMapSheet(
  workbook: ExcelScript.Workbook,
  shared: SharedData,
  messages: Message[],
  knownPaths: string[],
  knownAliases: string[][]
): AccountMapParse {

  const res: AccountMapParse = {
    rows: [], usedDynamicRules: [], pathCount: 0, headerRow: 0,
    hasWorkGroup: false, hasBranch: false, hasAccType: false, ok: true
  };

  const sheet = workbook.getWorksheet(ACCOUNT_MAP_SHEET);
  if (!sheet) {
    return res;
  }
  const grid = readGrid(sheet);
  if (grid.length === 0) return res;

  const map = buildAccountMapColMap(grid);
  if (!map.ok) {
    messages.push(msg("ERROR", ACCOUNT_MAP_SHEET,
      "Baslik satiri bulunamadi ya da eksik. Bir satirda 'Path' ve 'Source' basliklari birlikte, ayrica 'Target' ve 'TargetMainGL' bulunmali. Kolon sirasi serbest." +
      (map.headerRow >= 0
        ? " Baslik satiri: " + (map.headerRow + 1) + ". satir. Eksik olan(lar): " + missingAccountMapColumns(map) +
        (map.unknown !== "" ? ". Taninmayan baslik(lar): " + map.unknown : "")
        : "")));
    res.ok = false;
    return res;
  }
  res.headerRow = map.headerRow + 1;
  res.hasWorkGroup = map.workGroup >= 0;
  res.hasBranch = map.branch >= 0;
  res.hasAccType = map.accType >= 0 && ACCOUNT_MAP_EMIT_ACCOUNT_TYPE;
  if (map.accType >= 0 && !ACCOUNT_MAP_EMIT_ACCOUNT_TYPE) {
    messages.push(msg("INFO", ACCOUNT_MAP_SHEET,
      "'CustomerAccountTypeCode' kolonu taninmistir ancak SQL'e yazilmamistir " +
      "(ACCOUNT_MAP_EMIT_ACCOUNT_TYPE = false). dbo.AccAccountMap'te '" +
      ACCOUNT_MAP_ACCTYPE_COLUMN + "' kolonu varsa bu sabiti true yapin."));
  }

  messages.push(msg("INFO", ACCOUNT_MAP_SHEET,
    "Baslik satiri: " + (map.headerRow + 1) + ". satir. Taninan kolonlar: " + recognizedAccountMapColumns(map) + "."));
  if (map.ignored !== "") {
    messages.push(msg("INFO", ACCOUNT_MAP_SHEET,
      "Yok sayilan kolon(lar): " + map.ignored + " - dbo.AccAccountMap'te karsiligi yok, SQL'e yazilmadi."));
  }
  if (map.unknown !== "") {
    messages.push(msg("WARNING", ACCOUNT_MAP_SHEET,
      "Taninmayan kolon(lar) SQL'e alinmadi: " + map.unknown +
      ". Bu kolonlari uretime katmak icin scriptteki HEADER_MAP_* listelerine adini ekleyin."));
  }

  const ruleBag: ParseResult = {
    items: [], modelName: "",
    usedComponentTypes: [], usedDynamicRules: [], usedEventTypes: [],
    errors: [], warnings: [], warnKeys: [], numericGlCount: 0, varNames: []
  };

  const seenKeys: string[] = [];
  const seenBaseKeys: string[] = [];
  const seenPaths: string[] = [];
  const covered: string[][] = [];

  for (let r = map.headerRow + 1; r < grid.length; r++) {
    const excelRow = r + 1;
    if (isBlankRow(grid, r)) continue;

    const rawPath = gridCell(grid, r, map.path);
    const source = mapCell(grid, r, map.source);
    const target = mapCell(grid, r, map.target);
    const mainGl = mapCell(grid, r, map.mainGl);

    if (rawPath === "" && source === "" && target === "") continue;
    if (inList(HEADER_MAP_PATH, rawPath.toLowerCase())) continue;

    /* Kalinti satir: yalnizca Source dolu, diger tum kolonlar bos. */
    if (rawPath === "" && source !== "" && isAccountMapLeftoverRow(grid, r, map)) {
      messages.push(msg("WARNING", ACCOUNT_MAP_SHEET,
        "Satir " + excelRow + ": sadece Source dolu ('" + source + "'), digerleri bos. Satir atlandi; silin ya da eksikleri doldurun."));
      continue;
    }

    if (rawPath === "") {
      messages.push(msg("ERROR", ACCOUNT_MAP_SHEET, "Satir " + excelRow + ": Path bos."));
      res.ok = false;
      continue;
    }
    if (source === "") {
      messages.push(msg("ERROR", ACCOUNT_MAP_SHEET, "Satir " + excelRow + ": Source bos. Urun sayfasindaki Alias ile ayni olmali."));
      res.ok = false;
      continue;
    }

    const segs = pathSegments(rawPath);
    if (segs.length < 2) {
      messages.push(msg("ERROR", ACCOUNT_MAP_SHEET, "Satir " + excelRow + ": Path en az 2 parcali olmali -> '" + rawPath + "'"));
      res.ok = false;
      continue;
    }
    const canonical = segs.join("/") + "/";
    const emitPath = ACCOUNT_MAP_PATH_TRAILING_SLASH ? canonical : segs.join("/");

    if (knownPaths.length > 0 && !isKnownOrPrefix(knownPaths, canonical)) {
      warnOnceMsg(messages, seenPaths, "AMPATH|" + canonical, msg("WARNING", ACCOUNT_MAP_SHEET,
        "Satir " + excelRow + ": '" + rawPath + "' hicbir urun sayfasinda yok. Bu satir hicbir kayda eslesmeyebilir."));
    }
    if (indexOfStr(seenPaths, canonical) < 0) seenPaths.push(canonical);

    const ccyText = mapCell(grid, r, map.ccy);

    /* Order */
    let order = mapCell(grid, r, map.order);
    if (order === "") order = accountMapSetting(shared, "AccountMapDefaultOrder");
    if (!/^[0-9]+$/.test(order)) {
      messages.push(msg("ERROR", ACCOUNT_MAP_SHEET, "Satir " + excelRow + ": Order sayi olmali -> '" + order + "'"));
      res.ok = false;
      continue;
    }

    /* IsEnabled */
    let enabled = accountMapSetting(shared, "AccountMapIsEnabled");
    const rawEnabled = gridCell(grid, r, map.enabled);
    if (rawEnabled !== "") {
      const e = trNormalize(rawEnabled.toLowerCase());
      if (inList(ACCOUNT_MAP_FALSE_TOKENS, e)) enabled = "0";
      else if (inList(ACCOUNT_MAP_TRUE_TOKENS, e)) enabled = "1";
      else {
        messages.push(msg("ERROR", ACCOUNT_MAP_SHEET, "Satir " + excelRow +
          ": IsEnabled degeri anlasilmadi -> '" + rawEnabled + "'. Evet/Hayir, 1/0 ya da true/false yazin."));
        res.ok = false;
        continue;
      }
    }
    if (enabled === "0") {
      messages.push(msg("WARNING", ACCOUNT_MAP_SHEET,
        "Satir " + excelRow + ": IsEnabled = 0. Motor bu satiri hic kullanmaz."));
    }

    /* Kural referanslari */
    const targetRuleVar = resolveMapRule(ruleBag, shared, mapCell(grid, r, map.targetRule), excelRow, "Target.CalculationRule", messages, res);
    const custSrcVar = resolveMapRule(ruleBag, shared, mapCell(grid, r, map.custSrc), excelRow, "CustomerSource", messages, res);
    const accSrcVar = resolveMapRule(ruleBag, shared, mapCell(grid, r, map.accSrc), excelRow, "CustomerAccountSource", messages, res);
    const workGroupVar = resolveMapRule(ruleBag, shared, mapCell(grid, r, map.workGroup), excelRow, "CustomerAccountWorkGroupCodeSource", messages, res);
    const branchVar = resolveMapRule(ruleBag, shared, mapCell(grid, r, map.branch), excelRow, "CustomerAccountBranchCodeSource", messages, res);
    const accTypeVar = ACCOUNT_MAP_EMIT_ACCOUNT_TYPE
      ? resolveMapRule(ruleBag, shared, mapCell(grid, r, map.accType), excelRow, "CustomerAccountTypeCode", messages, res)
      : "";

    const ruleVars: string[] = [];
    for (let i = 0; i < 10; i++) {
      const cell = mapCell(grid, r, map.rules[i]);
      ruleVars.push(resolveMapRule(ruleBag, shared, cell, excelRow, "Rule" + (i + 1), messages, res));
    }

    if (target === "" && targetRuleVar === "") {
      messages.push(msg("ERROR", ACCOUNT_MAP_SHEET, "Satir " + excelRow +
        ": Target ve Target.CalculationRule ikisi de bos. Ya sabit GL hesabini Target'a yazin ya da bir hesaplama kurali verin."));
      res.ok = false;
      continue;
    }
    if (mainGl === "" && targetRuleVar === "") {
      messages.push(msg("ERROR", ACCOUNT_MAP_SHEET, "Satir " + excelRow +
        ": TargetMainGL ve Target.CalculationRule bos. Ana GL belirlenemiyor."));
      res.ok = false;
      continue;
    }
    if (target !== "" && targetRuleVar !== "") {
      messages.push(msg("WARNING", ACCOUNT_MAP_SHEET, "Satir " + excelRow +
        ": Target ('" + target + "') ve Target.CalculationRule birlikte dolu. Motor hesaplama kuralini kullanir, sabit Target islemeyebilir."));
    }

    /* Ayirt edilebilirlik */
    const ruleSig = ruleVars.join(",") + "|" + ccyText.toLowerCase() + "|" + custSrcVar + "|" + accSrcVar + "|" + workGroupVar + "|" + branchVar + "|" + accTypeVar;
    const baseKey = emitPath + "|" + source.toLowerCase() + "|" + ruleSig;
    const fullKey = baseKey + "|" + order;

    if (indexOfStr(seenKeys, fullKey) >= 0) {
      messages.push(msg("ERROR", ACCOUNT_MAP_SHEET,
        "Satir " + excelRow + ": ayni Path + Source + Order ve ayni kurallar ikinci kez var ('" + source + "' @ " + rawPath + ", Order " + order +
        "). Fazla satiri silin ya da Rule1..Rule10'dan birini degistirin."));
      res.ok = false;
      continue;
    }
    if (indexOfStr(seenBaseKeys, baseKey) >= 0) {
      messages.push(msg("WARNING", ACCOUNT_MAP_SHEET,
        "Satir " + excelRow + ": ayni Path + Source + ayni kurallar daha once de var, sadece Order farkli ('" + source + "' @ " + rawPath +
        "). Motor kucuk Order'i secer, bu satir calismayabilir."));
    }
    seenKeys.push(fullKey);
    seenBaseKeys.push(baseKey);

    covered.push([canonical, source.toLowerCase()]);

    res.rows.push({
      excelRow: excelRow,
      path: emitPath,
      source: source,
      order: order,
      ccy: ccyText,
      mainGl: mainGl,
      target: target,
      targetRuleVar: targetRuleVar,
      custSrcVar: custSrcVar,
      accSrcVar: accSrcVar,
      workGroupVar: workGroupVar,
      branchVar: branchVar,
      accTypeVar: accTypeVar,
      ruleVars: ruleVars,
      description: mapCell(grid, r, map.desc),
      isEnabled: enabled
    });
  }

  res.usedDynamicRules = ruleBag.usedDynamicRules;
  res.pathCount = seenPaths.length;

  /* Kapsam kontrolu */
  let uncovered = "";
  const listed: string[] = [];
  for (let i = 0; i < knownAliases.length; i++) {
    const pth = knownAliases[i][0];
    const al = knownAliases[i][1];
    const k = pth + "|" + al.toLowerCase();
    if (indexOfStr(listed, k) >= 0) continue;
    listed.push(k);
    let found = false;
    for (let j = 0; j < covered.length; j++) {
      if (covered[j][1] !== al.toLowerCase()) continue;
      if (covered[j][0] === pth || pth.indexOf(covered[j][0]) === 0) { found = true; break; }
    }
    if (!found) uncovered += (uncovered === "" ? "" : ", ") + al + " (" + pth + ")";
  }
  if (uncovered !== "") {
    messages.push(msg("WARNING", ACCOUNT_MAP_SHEET,
      "Urun sayfalarinda kullanilan ama AccountMap'te satiri olmayan alias'lar - bu satirlarda gercek GL hesabi bulunamaz: " + uncovered));
  }

  return res;
}

/** Baslik satirini bulur ve kolon haritasini cikarir. */
function buildAccountMapColMap(grid: string[][]): AccountMapColMap {
  const m: AccountMapColMap = {
    path: -1, source: -1, order: -1, ccy: -1, mainGl: -1, target: -1, targetRule: -1,
    custSrc: -1, accSrc: -1, workGroup: -1, branch: -1, accType: -1, desc: -1, enabled: -1,
    rules: [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
    headerRow: -1, unknown: "", ignored: "", ok: false
  };

  /* Baslik satiri: 'Path' ve 'Source' basliklarinin ikisini de tasiyan ILK satir. */
  let hr = -1;
  for (let r = 0; r < grid.length && r < ACCOUNT_MAP_HEADER_SCAN_ROWS; r++) {
    const row = grid[r];
    const width = row ? row.length : 0;
    let hasPath = false, hasSource = false;
    for (let c = 0; c < width; c++) {
      const h = gridCell(grid, r, c).toLowerCase();
      if (h === "") continue;
      if (inList(HEADER_MAP_PATH, h)) hasPath = true;
      else if (inList(HEADER_MAP_SOURCE, h)) hasSource = true;
    }
    if (hasPath && hasSource) { hr = r; break; }
  }
  if (hr < 0) return m;
  m.headerRow = hr;

  const row = grid[hr];
  const width = row ? row.length : 0;
  for (let c = 0; c < width; c++) {
    const raw = gridCell(grid, hr, c);
    const h = raw.toLowerCase();
    if (h === "") continue;

    /* Rule1..Rule10 */
    let isRule = false;
    for (let i = 1; i <= 10; i++) {
      if (h === "rule" + i || h === "rule " + i) { m.rules[i - 1] = c; isRule = true; break; }
    }
    if (isRule) continue;

    /* 'target' ve 'targetmaingl' cakismasin: once uzun/ozel olanlar denenir. */
    if (inList(HEADER_MAP_MAINGL, h)) m.mainGl = c;
    else if (inList(HEADER_MAP_TARGETRULE, h)) m.targetRule = c;
    else if (inList(HEADER_MAP_TARGET, h)) m.target = c;
    else if (inList(HEADER_MAP_PATH, h)) m.path = c;
    else if (inList(HEADER_MAP_SOURCE, h)) m.source = c;
    else if (inList(HEADER_MAP_ORDER, h)) m.order = c;
    else if (inList(HEADER_MAP_CCY, h)) m.ccy = c;
    else if (inList(HEADER_MAP_WORKGROUP, h)) m.workGroup = c;
    else if (inList(HEADER_MAP_BRANCH, h)) m.branch = c;
    else if (inList(HEADER_MAP_ACCTYPE, h)) m.accType = c;
    else if (inList(HEADER_MAP_ACCSRC, h)) m.accSrc = c;
    else if (inList(HEADER_MAP_CUSTSRC, h)) m.custSrc = c;
    else if (inList(HEADER_MAP_DESC, h)) m.desc = c;
    else if (inList(HEADER_MAP_ENABLED, h)) m.enabled = c;
    else if (inList(HEADER_MAP_IGNORE, h)) m.ignored += (m.ignored === "" ? "" : ", ") + "'" + raw + "'";
    else m.unknown += (m.unknown === "" ? "" : ", ") + "'" + raw + "'";
  }

  m.ok = (m.path >= 0 && m.source >= 0 && m.target >= 0 && m.mainGl >= 0);
  return m;
}

/** Eksik zorunlu AccountMap kolonlarini dondurur. */
function missingAccountMapColumns(m: AccountMapColMap): string {
  let s = "";
  if (m.path < 0) s += (s === "" ? "" : ", ") + "Path";
  if (m.source < 0) s += (s === "" ? "" : ", ") + "Source";
  if (m.mainGl < 0) s += (s === "" ? "" : ", ") + "TargetMainGL";
  if (m.target < 0) s += (s === "" ? "" : ", ") + "Target";
  if (s === "") s = "(yok)";
  return s;
}

/** Taninan AccountMap kolonlarini dondurur (GEN_LOG icin). */
function recognizedAccountMapColumns(m: AccountMapColMap): string {
  let s = "Path, Source, TargetMainGL, Target";
  if (m.targetRule >= 0) s += ", Target.CalculationRule";
  if (m.order >= 0) s += ", Order";
  if (m.ccy >= 0) s += ", Ccy";
  if (m.enabled >= 0) s += ", IsEnabled";
  if (m.custSrc >= 0) s += ", CustomerSource";
  if (m.accSrc >= 0) s += ", CustomerAccountSource";
  if (m.workGroup >= 0) s += ", CustomerAccountWorkGroupCodeSource";
  if (m.branch >= 0) s += ", CustomerAccountBranchCodeSource";
  if (m.accType >= 0) s += ", CustomerAccountTypeCode" + (ACCOUNT_MAP_EMIT_ACCOUNT_TYPE ? "" : " (yazilmiyor)");
  if (m.desc >= 0) s += ", Description";
  let ruleCount = 0;
  for (let i = 0; i < 10; i++) if (m.rules[i] >= 0) ruleCount++;
  if (ruleCount > 0) s += ", Rule1..Rule10 (" + ruleCount + " kolon)";
  return s;
}

/** Hucreyi okur; 'Null' / '-' gibi bos-esdegeri metinleri "" yapar. */
function mapCell(grid: string[][], row: number, col: number): string {
  const v = gridCell(grid, row, col);
  if (v === "") return "";
  const k = v.toLowerCase();
  for (let i = 0; i < ACCOUNT_MAP_NULL_TOKENS.length; i++) {
    if (ACCOUNT_MAP_NULL_TOKENS[i] === k) return "";
  }
  return v;
}

/** Kural adini cozer; bos ise "" doner, tanimsiz ise hata yazar. */
function resolveMapRule(
  bag: ParseResult, shared: SharedData, name: string, excelRow: number, what: string,
  messages: Message[], res: AccountMapParse
): string {
  if (name === "") return "";
  const v = registerDynamicRule(bag, shared, name, ACCOUNT_MAP_SHEET, excelRow);
  if (v === "") {
    for (let i = 0; i < bag.errors.length; i++) {
      if (indexOfMessage(messages, bag.errors[i]) < 0) messages.push(bag.errors[i]);
    }
    messages.push(msg("ERROR", ACCOUNT_MAP_SHEET,
      "Satir " + excelRow + ": " + what + " kurali bulunamadi -> '" + name + "'"));
    res.ok = false;
  }
  return v;
}

/** Urun sayfasindaki alias'lari [path, alias] olarak toplar. */
function collectAliases(parsed: ParseResult, sink: string[][]): void {
  for (let i = 0; i < parsed.items.length; i++) {
    const it = parsed.items[i];
    for (let e = 0; e < it.events.length; e++) {
      const ev = it.events[e];
      for (let g = 0; g < ev.groups.length; g++) {
        const gr = ev.groups[g];
        for (let c = 0; c < gr.components.length; c++) {
          const cp = gr.components[c];
          for (let n = 0; n < cp.rules.length; n++) {
            sink.push([it.path, cp.rules[n].glCode]);
          }
        }
      }
    }
  }
}

/** Satirda Source disinda hicbir alan dolu degil mi? */
function isAccountMapLeftoverRow(grid: string[][], row: number, map: AccountMapColMap): boolean {
  const cols: number[] = [map.path, map.order, map.ccy, map.mainGl, map.target, map.targetRule,
  map.custSrc, map.accSrc, map.workGroup, map.branch, map.accType, map.desc, map.enabled];
  for (let i = 0; i < cols.length; i++) {
    if (cols[i] >= 0 && mapCell(grid, row, cols[i]) !== "") return false;
  }
  for (let i = 0; i < 10; i++) {
    if (map.rules[i] >= 0 && mapCell(grid, row, map.rules[i]) !== "") return false;
  }
  return true;
}

/** path listesinde tam eslesme ya da onek eslesmesi var mi? */
function isKnownOrPrefix(knownPaths: string[], candidate: string): boolean {
  for (let i = 0; i < knownPaths.length; i++) {
    if (knownPaths[i] === candidate) return true;
    if (knownPaths[i].indexOf(candidate) === 0) return true;
  }
  return false;
}


/* =====================================================================================
 * D) SQL uretimi
 * ===================================================================================== */

function emitAccountMapScript(parse: AccountMapParse, shared: SharedData): string[] {
  const out: string[] = [];
  const L = (s: string) => { out.push(s); };

  const colTypeId = accountMapSetting(shared, "AccountMapColumnTypeId");
  const defName = accountMapSetting(shared, "AccountMapDefinitionName");

  L("/***************************************************************************************************");
  L("* This script adds AccAccountMap rows (Source -> gercek GL hesabi eslemesi)");
  L("* GENERATED - do not edit by hand.");
  L("*   source workbook sheet : " + ACCOUNT_MAP_SHEET + "  (baslik satiri: " + parse.headerRow + ")");
  L("*   rows                  : " + parse.rows.length);
  L("*   work group column     : " + (parse.hasWorkGroup ? "VAR" : "yok"));
  L("*   branch column         : " + (parse.hasBranch ? "VAR" : "yok"));
  L("*   account type column   : " + (parse.hasAccType ? "VAR" : "yok"));
  L("*   output mode           : " + OUTPUT_MODE);
  L("*   generated at          : " + isoStamp());
  L("*");
  L("* Bu script digerlerinden BAGIMSIZDIR: item Id'si kullanmaz, Path metniyle eslesir.");
  L("***************************************************************************************************/");
  L("");
  L("USE NetTrexAcc;");
  L("GO");
  L("");
  L("SET XACT_ABORT ON;");
  L("");
  L("BEGIN TRANSACTION;");
  L("");
  L("BEGIN TRY");
  L("    DECLARE");
  L("        @StateId INT = " + setting(shared, "StateId") + ",");
  L("        @stateDate datetime = GETDATE(),");
  L("        @stateMaker nvarchar(80) = N'" + setting(shared, "StateMaker") + "';");
  L("");
  L("    DECLARE");
  L("        @tempTable TABLE");
  L("                   (");
  L("                       Id INT");
  L("                   );");
  L("");
  L("    DECLARE");
  L("        @lastAccEngineDynamicRuleId INT = 0,");
  L("        @accEngineDynamicRuleColumnTypeId INT = 1,");
  L("        @lastAccAccountMapId INT = 0,");
  L("        @accAccountMapColumnTypeId INT = " + colTypeId + ";");
  L("");

  if (parse.usedDynamicRules.length > 0) {
    L("    /* Dynamic Rules */");
    L("    DECLARE");
    for (let i = 0; i < parse.usedDynamicRules.length; i++) {
      const r = parse.usedDynamicRules[i];
      L("        -- " + r[0]);
      L("        " + r[2] + " INT = 0" + (i === parse.usedDynamicRules.length - 1 ? ";" : ","));
    }
    L("");
  }

  L("    ------------------------------------------------------------------------------------------------------------------------");
  L("    -- Definition Number Generation");
  L("    ------------------------------------------------------------------------------------------------------------------------");
  L("    --#region DefNumberGen");
  L("    ------------------------------------------------------------------------------------------------------------------------");
  L("    -- Accounting Engine Dynamic Rule Last Number");
  L("    ------------------------------------------------------------------------------------------------------------------------");
  L("    SELECT @lastAccEngineDynamicRuleId = LastNumber + 1");
  L("    FROM dbo.DefNumberGen");
  L("    WHERE EntityColumnType = @accEngineDynamicRuleColumnTypeId");
  L("      AND Definition = N'AccEngineDynamicRule Id'");
  L("");
  L("    IF (@lastAccEngineDynamicRuleId = 0)");
  L("        THROW 500001, 'AccEngineDynamicRule Last Id Not Found', 1");
  L("    ------------------------------------------------------------------------------------------------------------------------");
  L("    -- Accounting Account Map Last Number");
  L("    ------------------------------------------------------------------------------------------------------------------------");
  L("    SELECT @lastAccAccountMapId = LastNumber + 1");
  L("    FROM dbo.DefNumberGen");
  L("    WHERE EntityColumnType = @accAccountMapColumnTypeId");
  L("      AND Definition = N'" + q(defName) + "'");
  L("");
  L("    IF (@lastAccAccountMapId = 0)");
  L("        THROW 500001, '" + q(defName) + " Not Found', 1");
  L("    --#endregion");
  L("    ------------------------------------------------------------------------------------------------------------------------");
  L("");

  L("    ------------------------------------------------------------------------------------------------------------------------");
  L("    -- Accounting Engine Dynamic Rule");
  L("    ------------------------------------------------------------------------------------------------------------------------");
  L("    --#region AccEngineDynamicRule");
  for (let i = 0; i < parse.usedDynamicRules.length; i++) {
    const name = parse.usedDynamicRules[i][0];
    const rule = parse.usedDynamicRules[i][1];
    const v = parse.usedDynamicRules[i][2];
    const rType = parse.usedDynamicRules[i].length > 3 ? parse.usedDynamicRules[i][3] : "";
    const isCalc = isCalcRule(shared, rType);
    const predicate = isCalc
      ? "Name = N'" + q(name) + "'"
      : "[Rule] = N'" + q(rule) + "' AND Name = N'" + q(name) + "'";
    const typeValue = isCalc ? setting(shared, "CalculationRuleTypeValue") : setting(shared, "ValidationRuleTypeValue");
    L("    ------------------------------------------------------------------------------------------------------------------------");
    L("    -- " + name + (isCalc ? "  [" + setting(shared, "CalculationRuleTypeName") + "]" : ", " + rule));
    L("    ------------------------------------------------------------------------------------------------------------------------");
    L("    IF NOT EXISTS (SELECT 1");
    L("                   FROM dbo.AccEngineDynamicRule");
    L("                   WHERE " + predicate + ")");
    L("        BEGIN");
    L("            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)");
    L("            OUTPUT inserted.Id INTO @tempTable");
    L("            VALUES (@lastAccEngineDynamicRuleId, N'" + q(name) + "', N'" + q(rule) + "',");
    L("                    " + typeValue + ", N'', @StateId, @stateDate, @stateMaker);");
    L("            SELECT " + v + " = Id FROM @tempTable;");
    L("            DELETE FROM @tempTable");
    L("            SELECT @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1");
    L("        END;");
    L("    ELSE");
    L("        BEGIN");
    L("            SELECT " + v + " = Id");
    L("            FROM dbo.AccEngineDynamicRule");
    L("            WHERE " + predicate);
    L("        END");
  }
  L("    --#endregion");
  L("    ------------------------------------------------------------------------------------------------------------------------");
  L("");

  /* AccAccountMap satirlari */
  L("    ------------------------------------------------------------------------------------------------------------------------");
  L("    -- Accounting Account Map");
  L("    ------------------------------------------------------------------------------------------------------------------------");
  L("    --#region AccAccountMap");
  let lastPath = "";
  for (let i = 0; i < parse.rows.length; i++) {
    const row = parse.rows[i];
    if (row.path !== lastPath) {
      L("");
      L("    ------------------------------------------------------------------------------------------------------------------------");
      L("    -- " + row.path);
      L("    ------------------------------------------------------------------------------------------------------------------------");
      lastPath = row.path;
    }
    emitAccountMapRow(out, row, parse.hasWorkGroup, parse.hasBranch, parse.hasAccType);
  }
  L("    --#endregion");
  L("    ------------------------------------------------------------------------------------------------------------------------");
  L("");
  L("    ------------------------------------------------------------------------------------------------------------------------");
  L("    -- Definition Number Generation Update");
  L("    ------------------------------------------------------------------------------------------------------------------------");
  L("    --#region DefNumberGen");
  L("    UPDATE dbo.DefNumberGen");
  L("    SET LastNumber     = @lastAccEngineDynamicRuleId,");
  L("        LastUpdateDate = @stateDate");
  L("    WHERE EntityColumnType = @accEngineDynamicRuleColumnTypeId");
  L("");
  L("    UPDATE dbo.DefNumberGen");
  L("    SET LastNumber     = @lastAccAccountMapId,");
  L("        LastUpdateDate = @stateDate");
  L("    WHERE EntityColumnType = @accAccountMapColumnTypeId");
  L("    --#endregion");
  L("");
  L("    COMMIT TRANSACTION");
  L("END TRY");
  L("BEGIN CATCH");
  L("    IF @@TRANCOUNT > 0");
  L("        ROLLBACK TRANSACTION;");
  L("");
  L("    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();");
  L("    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();");
  L("    DECLARE @ErrorState INT = ERROR_STATE();");
  L("    DECLARE @ErrorLine INT = ERROR_LINE();");
  L("");
  L("    RAISERROR ('Error on line %d: %s', @ErrorSeverity, @ErrorState, @ErrorLine, @ErrorMessage);");
  L("END CATCH");
  L("GO");

  return out;
}

/**
 * Tek AccAccountMap satiri. Ayirt edici anahtar:
 *   Rule1..Rule10 + Source + Path + TargetMainGL + Target + TargetRuleId
 *   + CustomerCodeSourceRuleId + CustomerAccountCodeSourceRuleId
 *   (+ WorkGroup / Branch / AccountType : sadece ilgili kolon varsa)
 */
function emitAccountMapRow(out: string[], row: AccountMapRow, hasWorkGroup: boolean, hasBranch: boolean, hasAccType: boolean): void {
  const L = (s: string) => { out.push(s); };

  const ruleCols: string[] = ["RuleId", "Rule2Id", "Rule3Id", "Rule4Id", "Rule5Id",
    "Rule6Id", "Rule7Id", "Rule8Id", "Rule9Id", "Rule10Id"];

  L("    IF NOT EXISTS(SELECT 1");
  L("                  FROM " + ACCOUNT_MAP_TABLE);
  L("                  WHERE " + nullPredicate(ruleCols[0], row.ruleVars[0]));
  for (let i = 1; i < 10; i++) {
    L("                    AND " + nullPredicate(ruleCols[i], row.ruleVars[i]));
  }
  L("                    AND Source = N'" + q(row.source) + "'");
  L("                    AND Path = N'" + q(row.path) + "'");
  L("                    AND TargetMainGL = N'" + q(row.mainGl) + "'");
  L("                    AND Target = N'" + q(row.target) + "'");
  L("                    AND " + nullPredicate("TargetRuleId", row.targetRuleVar));
  L("                    AND " + nullPredicate("CustomerCodeSourceRuleId", row.custSrcVar));
  if (hasWorkGroup) L("                    AND " + nullPredicate("CustomerAccountWorkGroupCodeSourceRuleId", row.workGroupVar));
  if (hasBranch) L("                    AND " + nullPredicate("CustomerAccountBranchCodeSourceRuleId", row.branchVar));
  if (hasAccType) L("                    AND " + nullPredicate(ACCOUNT_MAP_ACCTYPE_COLUMN, row.accTypeVar));
  L("                    AND " + nullPredicate("CustomerAccountCodeSourceRuleId", row.accSrcVar) + ")");
  L("        BEGIN");
  L("            INSERT INTO " + ACCOUNT_MAP_TABLE + " (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,");
  L("                                            Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,");
  L("                                            TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,");
  L("                                            CustomerAccountCodeSourceRuleId" +
    (hasWorkGroup ? ", CustomerAccountWorkGroupCodeSourceRuleId" : "") +
    (hasBranch ? ", CustomerAccountBranchCodeSourceRuleId" : "") +
    (hasAccType ? ", " + ACCOUNT_MAP_ACCTYPE_COLUMN : "") + ",");
  L("                                            StateId, StateMaker, StateDate)");
  L("            VALUES (@lastAccAccountMapId, " + nullOrText(row.ccy) + ", NULL,");
  L("                    " + nullOrVar(row.ruleVars[0]) + ", " + nullOrVar(row.ruleVars[1]) + ", " + nullOrVar(row.ruleVars[2]) + ", " + nullOrVar(row.ruleVars[3]) + ", " + nullOrVar(row.ruleVars[4]) + ",");
  L("                    " + nullOrVar(row.ruleVars[5]) + ", " + nullOrVar(row.ruleVars[6]) + ", " + nullOrVar(row.ruleVars[7]) + ", " + nullOrVar(row.ruleVars[8]) + ", " + nullOrVar(row.ruleVars[9]) + ",");
  L("                    N'" + q(row.source) + "', N'" + q(row.path) + "', N'" + q(row.mainGl) + "', N'" + q(row.target) + "',");
  L("                    " + nullOrVar(row.targetRuleVar) + ", " + row.isEnabled + ", " + row.order + ", N'" + q(row.description) + "',");
  L("                    " + nullOrVar(row.custSrcVar) + ", " + nullOrVar(row.accSrcVar) +
    (hasWorkGroup ? ", " + nullOrVar(row.workGroupVar) : "") +
    (hasBranch ? ", " + nullOrVar(row.branchVar) : "") +
    (hasAccType ? ", " + nullOrVar(row.accTypeVar) : "") + ",");
  L("                    @StateId, @stateMaker, @stateDate);");
  L("");
  L("            SELECT @lastAccAccountMapId = @lastAccAccountMapId + 1");
  L("        END;");
  L("");
}

/** 'X IS NULL' ya da 'X = @drFoo' */
function nullPredicate(column: string, varName: string): string {
  return varName === "" ? (column + " IS NULL") : (column + " = " + varName);
}

function nullOrVar(varName: string): string {
  return varName === "" ? "NULL" : varName;
}

function nullOrText(value: string): string {
  return value === "" ? "NULL" : ("N'" + q(value) + "'");
}


/* =====================================================================================
 * E) Yardimcilar
 * ===================================================================================== */

/** Shared!Settings > ACCOUNT_MAP_DEFAULTS sirasiyla ayar degeri. */
function accountMapSetting(shared: SharedData, key: string): string {
  const v = lookup2(shared.settings, key);
  if (v !== "") return v;
  return lookup2(ACCOUNT_MAP_DEFAULTS, key);
}

function indexOfStr(list: string[], value: string): number {
  for (let i = 0; i < list.length; i++) if (list[i] === value) return i;
  return -1;
}

function indexOfMessage(list: Message[], m: Message): number {
  for (let i = 0; i < list.length; i++) {
    if (list[i].level === m.level && list[i].sheet === m.sheet && list[i].text === m.text) return i;
  }
  return -1;
}

/** Ayni uyariyi bir kez yazar. */
function warnOnceMsg(messages: Message[], seen: string[], key: string, m: Message): void {
  if (indexOfStr(seen, "W|" + key) >= 0) return;
  seen.push("W|" + key);
  messages.push(m);
}