const fs = require("fs");
const http = require("http");
const SC = __dirname;
const URL_ = { host: "localhost", port: 5011, path: "/api/value-maturity-report/transactions", method: "POST", headers: { "Content-Type": "application/json" } };

function parse(file, swapType) {
  const lines = fs.readFileSync(`${SC}/${file}`, "utf8").split(/\r?\n/).filter(l => l && !l.startsWith("--"));
  const head = lines[0].split("|");
  return lines.slice(1).map(l => {
    const c = l.split("|"); const r = {};
    head.forEach((h, i) => r[h] = c[i]);
    return {
      swapType, id: +r.Id, ref: r.LogicalReference, pkg: +r.PkgNo, inst: +r.InstrumentId, cust: +r.CustomerId,
      pair: r.CcyPair, buyCcy: r.BuyCcy, buy: parseFloat(r.BuyAmount), sellCcy: r.SellCcy, sell: parseFloat(r.SellAmount),
      rate: parseFloat(r.DealRateNet), vd: r.ValueDate.slice(0, 10), state: +r.StateId
    };
  });
}
const all = [...parse("fx.txt", 1), ...parse("pm.txt", 2)];
const active = all.filter(l => (l.state & 7) === 2);
const instName = { 1068: "Swap (Near)", 1069: "Swap (Far)" };
const days = (a, b) => Math.round((Date.parse(b) - Date.parse(a)) / 86400000);
const r2 = v => Math.round((v + Number.EPSILON) * 100) / 100;

let L = process.argv[2]; // logical date
function expectedRow(l) {
  const other = l.inst === 1068 ? 1069 : 1068;
  const partner = active.filter(p => p.swapType === l.swapType && p.pkg === l.pkg && p.inst === other).sort((a, b) => b.id - a.id)[0];
  const base = (l.pair.split("/")[0]);
  const nonBase = (x) => x.buyCcy.toUpperCase() === base.toUpperCase() ? [x.sellCcy, x.sell] : [x.buyCcy, x.buy];
  const [tCcy, tAmt] = nonBase(l);
  const e = {
    key: `${l.swapType === 1 ? "FxSwap" : "PmSwap"}|${l.inst === 1068 ? "NEAR" : "FAR"}|${l.id}`,
    ref: l.ref, PackageNo: l.pkg, SubProductName: instName[l.inst], SwapType: l.swapType === 1 ? "FX Swap" : "PM Swap",
    TotalAmount: r2(tAmt), TotalAmountCcy: tCcy, ValueDate: l.vd, MaturityDate: l.vd,
    SoldCcy: l.sellCcy, SoldAmount: r2(l.sell), BoughtCcy: l.buyCcy, BoughtAmount: r2(l.buy), Counterparty: "Akbank A.Ş.",
    OriginalTenorDays: null, SwapRate: null, YieldAmount: null
  };
  if (partner) {
    const near = l.inst === 1068 ? l : partner, far = l.inst === 1068 ? partner : l;
    const t = days(near.vd, far.vd);
    const rate = t === 0 ? 0 : (far.rate / near.rate - 1) * 360 / t * 100;
    e.OriginalTenorDays = t; e.SwapRate = rate;
    e.YieldAmount = nonBase(near)[1] * rate / 100 * t / 360;
  }
  e.sortKey = [l.vd, l.swapType, l.pkg, l.inst, l.id];
  return e;
}
const cmpArr = (a, b) => { for (let i = 0; i < a.length; i++) { if (a[i] < b[i]) return -1; if (a[i] > b[i]) return 1; } return 0; };

function post(body) {
  return new Promise((res, rej) => {
    const rq = http.request(URL_, rs => { let s = ""; rs.on("data", d => s += d).on("end", () => { try { res(JSON.parse(s)); } catch (e) { res({ raw: s, status: rs.statusCode }); } }); });
    rq.on("error", rej); rq.write(JSON.stringify(body)); rq.end();
  });
}

const BASE = { moduleCode: "FX", product: "FxPmSwap", take: 0, currentUserId: "test" };
const inRange = (l, f) => {
  const d = l.vd;
  if (f.valueDateFrom && d < f.valueDateFrom) return false;
  if (f.valueDateTo && d > f.valueDateTo) return false;
  if (f.maturityDateFrom && d < f.maturityDateFrom) return false;
  if (f.maturityDateTo && d > f.maturityDateTo) return false;
  if (f.logicalReference && !l.ref.includes(f.logicalReference)) return false;
  return true;
};

const cases = [];
const SUBS = [["1068", "1069"], ["1068"], ["1069"]];
const RANGES = [
  { valueDateTo: "2027-02-20" },
  { valueDateFrom: "2026-10-01", valueDateTo: "2026-10-01" },
  { valueDateFrom: "2026-10-02", valueDateTo: "2026-10-02" },
  { valueDateFrom: "2026-10-02" },
  { valueDateFrom: "2026-10-07" },
  { valueDateFrom: "2026-10-08" },
  { valueDateTo: "2026-09-30" },
  { valueDateFrom: "2026-10-01", valueDateTo: "2026-10-06" },
  { maturityDateFrom: "2026-10-02", maturityDateTo: "2026-10-07" },
  { maturityDateTo: "2026-10-01" },
  { valueDateFrom: "2026-10-01", maturityDateTo: "2026-10-02" },
  { valueDateFrom: "2026-10-02", maturityDateFrom: "2026-10-07" },
  { valueDateFrom: "2026-10-07", valueDateTo: "2026-10-01" },
  { valueDateTo: "2027-02-20", logicalReference: "TPMSW" },
  { valueDateTo: "2027-02-20", logicalReference: "TFXSW" },
  { valueDateTo: "2027-02-20", logicalReference: "TFXSW26100100009" },
  { valueDateTo: "2027-02-20", logicalReference: "XYZ" },
  { valueDateTo: "2027-02-20", logicalReference: "26100100" }
];
for (const subs of SUBS) for (const r of RANGES) cases.push({ ...BASE, subProducts: subs, ...r });
for (const r of RANGES.slice(0, 4)) cases.push({ ...BASE, ...r }); // subProducts yok

(async () => {
  let pass = 0, fail = 0; const fails = []; const logicalDates = new Set(); let rowChecks = 0;
  for (const c of cases) {
    const resp = await post(c);
    const v = resp.items ? resp : (resp.value || resp);
    if (!v.items) { fails.push({ c, why: "no items", resp: JSON.stringify(resp).slice(0, 300) }); fail++; continue; }
    const insts = (c.subProducts && c.subProducts.length ? c.subProducts.map(Number) : [1068, 1069]);
    const exp = active.filter(l => insts.includes(l.inst) && inRange(l, c)).map(expectedRow)
      .sort((a, b) => cmpArr(a.sortKey, b.sortKey));
    const errs = [];
    if (v.totalCount !== exp.length) errs.push(`totalCount ${v.totalCount} != ${exp.length}`);
    if (v.items.length !== exp.length) errs.push(`items ${v.items.length} != ${exp.length}`);
    if (v.isTruncated) errs.push("isTruncated true");
    const n = Math.min(exp.length, v.items.length);
    for (let i = 0; i < n; i++) {
      const a = v.items[i], d = a.data, e = exp[i]; rowChecks++;
      const chk = (name, got, want, tol) => {
        const ok = tol != null && got != null && want != null ? Math.abs(got - want) <= tol : (got === want);
        if (!ok) errs.push(`row ${i} ${e.ref} ${name}: got ${JSON.stringify(got)} want ${JSON.stringify(want)}`);
      };
      chk("key", a.key, e.key); chk("ref", a.logicalReference, e.ref);
      chk("Counterparty", d.CounterpartyName, e.Counterparty);
      chk("PackageNo", d.PackageNo, e.PackageNo); chk("SubProductName", d.SubProductName, e.SubProductName);
      chk("SwapType", d.SwapType, e.SwapType);
      chk("TotalAmount", d.TotalAmount, e.TotalAmount, 0.006); chk("TotalAmountCcy", d.TotalAmountCcy, e.TotalAmountCcy);
      chk("ValueDate", d.ValueDate.slice(0, 10), e.ValueDate); chk("MaturityDate", d.MaturityDate.slice(0, 10), e.MaturityDate);
      chk("SoldCcy", d.SoldCcy, e.SoldCcy); chk("SoldAmount", d.SoldAmount, e.SoldAmount, 0.006);
      chk("BoughtCcy", d.BoughtCcy, e.BoughtCcy); chk("BoughtAmount", d.BoughtAmount, e.BoughtAmount, 0.006);
      chk("OriginalTenorDays", d.OriginalTenorDays, e.OriginalTenorDays);
      if (e.SwapRate == null) { chk("SwapRate(null)", d.SwapRate, null); chk("Yield(null)", d.YieldAmount, null); }
      else { chk("SwapRate", d.SwapRate, e.SwapRate, 1e-5); chk("YieldAmount", d.YieldAmount, e.YieldAmount, 0.0061); }
      const dtm = Math.max(0, days(e.ValueDate, e.ValueDate) + (Date.parse(e.ValueDate) - Date.parse(L)) / 86400000);
      chk("DaysToMaturity", d.DaysToMaturity, dtm);
    }
    if (errs.length) { fail++; fails.push({ c, errs: errs.slice(0, 6) }); } else pass++;
  }
  console.log(`logicalDate used: ${L}`);
  console.log(`cases ${cases.length} pass ${pass} fail ${fail}, rows compared ${rowChecks}, active legs in DB ${active.length} (FX ${active.filter(l => l.swapType === 1).length} / PM ${active.filter(l => l.swapType === 2).length})`);
  for (const f of fails.slice(0, 12)) console.log(JSON.stringify(f));
})();
