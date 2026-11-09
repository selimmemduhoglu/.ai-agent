// AccountMap tutarlilik taramasi.  Kullanim:
//   cd <exceljs kurulu klasor>   (npm i exceljs)
//   node validate-accountmap.js "<workbook.xlsx>" [AccountMapSheetAdi]
// exceljs bazi workbook'larda table-xform.js satir 101'de "filterButton" hatasi verir ->
//   node_modules/exceljs/lib/xlsx/xform/table/table-xform.js icinde
//   "this.model.columns[index].filterButton = ..." satirini `if (this.model.columns[index])` ile sar.
// Okuma-yalnizdir; workbook'a yazmaz.
const ExcelJS = require('exceljs');
const file = process.argv[2];
const sheetName = process.argv[3] || 'AccountMap';
if (!file) { console.error('workbook yolu gerekli'); process.exit(1); }

const val = c => {
  const v = c.value;
  if (v == null) return '';
  if (typeof v === 'object') {
    if (v.richText) return v.richText.map(t => t.text).join('');
    if (v.result !== undefined) return String(v.result);
    if (v.text) return v.text;
  }
  return String(v).trim();
};

(async () => {
  const wb = new ExcelJS.Workbook();
  await wb.xlsx.readFile(file);
  const ws = wb.getWorksheet(sheetName);
  if (!ws) { console.error(`'${sheetName}' sayfasi yok. Sayfalar: ` + wb.worksheets.map(w => w.name).join(', ')); process.exit(1); }

  let hdrRow = -1, col = {};
  ws.eachRow((row, n) => {
    if (hdrRow > 0) return;
    const cells = []; row.eachCell({ includeEmpty: true }, (c, i) => cells[i] = val(c));
    if (cells.includes('IsEnabled') && cells.includes('Source')) {
      hdrRow = n; cells.forEach((h, i) => { if (h) col[h] = i; });
    }
  });
  if (hdrRow < 0) { console.error('baslik satiri (IsEnabled/Source) bulunamadi'); process.exit(1); }

  const rows = [];
  ws.eachRow((row, n) => {
    if (n <= hdrRow) return;
    const g = h => (col[h] ? val(row.getCell(col[h])) : '');
    const path = g('Path'), source = g('Source');
    if (!path || !source) return;
    rows.push({
      n, enabled: g('IsEnabled'), path, source, order: g('Order'),
      rules: Array.from({ length: 10 }, (_, i) => g('Rule' + (i + 1))),
      main: g('TargetMainGL'), target: g('Target'), calc: g('Target.CalculationRule'),
    });
  });

  const issues = [];
  const add = (sev, r, msg) => issues.push(`${sev} satir ${r.n} [${r.path} / ${r.source}] ${msg}`);

  for (const r of rows) {
    if (r.target && r.main && !r.target.startsWith(r.main)) add('UYUSMAZLIK', r, `Target '${r.target}' TargetMainGL '${r.main}' ile baslamiyor`);
    if (!r.target && !r.calc) add('HATA', r, 'Target ve Target.CalculationRule ikisi de bos');
    if (r.target && r.calc) add('UYARI', r, 'Target ve Target.CalculationRule birlikte dolu (motor hesaplama kuralini kullanir)');
    if (r.target && !/^\d+$/.test(r.target)) add('UYARI', r, `Target rakam degil: '${r.target}'`);
  }

  const lens = {};
  rows.filter(r => r.target).forEach(r => { lens[r.target.length] = (lens[r.target.length] || 0) + 1; });
  const dominant = Object.entries(lens).sort((a, b) => b[1] - a[1])[0];
  if (dominant) rows.filter(r => r.target && r.target.length !== +dominant[0]).forEach(r => add('UYARI', r, `Target uzunlugu ${r.target.length} (baskin ${dominant[0]})`));

  const seen = new Map();
  for (const r of rows) {
    const key = [r.path, r.source, r.order, r.rules.join('|')].join('#');
    if (seen.has(key)) add('HATA', r, `(Path,Source,Order,Rules) tekrar - ilk gorulen satir ${seen.get(key)}`);
    else seen.set(key, r.n);
  }

  const bySrc = new Map();
  for (const r of rows) { const k = r.path + '#' + r.source; (bySrc.get(k) || bySrc.set(k, []).get(k)).push(r); }
  for (const [k, list] of bySrc) {
    const orders = list.map(r => +r.order).filter(x => !isNaN(x));
    const hasCatchAll = list.some(r => r.rules.every(x => !x));
    const maxOrder = Math.max(...orders);
    const ca = list.filter(r => r.rules.every(x => !x));
    ca.forEach(r => { if (+r.order < maxOrder) add('UYARI', r, `kuralsiz (catch-all) satirin Order'i (${r.order}) en buyuk (${maxOrder}) degil - sonrakileri golgeler`); });
  }

  console.log(`${file} / ${sheetName}: ${rows.length} satir, ${issues.length} bulgu`);
  console.log('Target uzunluk dagilimi:', JSON.stringify(lens));
  issues.forEach(i => console.log(i));
})();
