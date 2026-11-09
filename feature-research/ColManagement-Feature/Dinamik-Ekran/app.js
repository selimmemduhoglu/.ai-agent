"use strict";

const app = document.getElementById("app");
const $ = (selector, root = document) => root.querySelector(selector);
const $$ = (selector, root = document) => [...root.querySelectorAll(selector)];
const annexSelect = document.getElementById('definition-annex');
const cashValidFrom = document.getElementById('cash-valid-from');
const cashValidTo = document.getElementById('cash-valid-to');

function syncAnnexDependencies() {
  const hasAnnex = Boolean(annexSelect && annexSelect.value && annexSelect.value.trim() !== '');

  // Annex doluysa Valid From ve Valid To disabled olur, boşsa aktifleşir
  if (cashValidFrom) {
    cashValidFrom.disabled = hasAnnex;
  }
  if (cashValidTo) {
    cashValidTo.disabled = hasAnnex;
  }

  // Eğer Developer Field Map tablosunu güncelleyen bir mantığınız varsa,
  // bu iki alanın data-entry / state değerlerini de tetikleyebilirsiniz.
}

// Annex değiştiğinde ve sayfa yüklendiğinde çalıştırın:
if (annexSelect) {
  annexSelect.addEventListener('change', syncAnnexDependencies);
  syncAnnexDependencies(); // İlk yükleme kontrolü
}

const HELP = {
  "Annex Code": "Annex kaydını sistem genelinde benzersiz tanımlar. İşlem görmüş kod değiştirilemez.",
  "Annex Name": "Sözleşme ilişkisini operasyon ekibinin anlayacağı adla tanımlar.",
  Counterparty: "Teminat ilişkisinin karşı tarafıdır. Annex seçildiğinde alt ekranlara otomatik aktarılır ve kilitlenir.",
  Status: "Kaydın taslak, aktif veya pasif durumda olup olmadığını belirler.",
  "Master Agreement": "ISDA, GMRA, GMSLA veya kullanılan diğer ana sözleşmenin adı ve sürümü serbest metin olarak yazılır.",
  "Collateral Document": "CSA, CSD veya kullanılan diğer teminat dokümanının adı ve sürümü serbest metin olarak yazılır.",
  "Base Currency": "Maruziyet ve teminatın ortak raporlama/değerleme para birimidir; işlem para birimi olmak zorunda değildir.",
  Direction: "Teminatın banka tarafından verilebileceğini, alınabileceğini veya her iki yönde kullanılabileceğini belirler.",
  "Valid From": "Kuralın kullanılmaya başlayacağı iş tarihidir.",
  "Valid To": "Boşsa açık uçlu geçerlilik anlamına gelir; doluysa bu tarihten sonra yeni kullanım engellenir.",
  "Dispute Tolerance": "Taraf hesapları arasındaki fark bu tutarı aşarsa uyuşmazlık sürecini tetikler; transfer eşiği değildir.",
  "Collateral Code": "Transaction ekranında seçilecek benzersiz teminat tanım kodudur. Seçim, işlem ekranındaki uygun seçenekleri belirler.",
  "Collateral Name": "Teminat tanımını iş kullanıcıları için açıklar.",
  Annex: "Seçilirse karşı taraf, yön ve değerleme para birimi Annex'ten gelir ve kilitlenir; boşsa standalone tanımdır.",
  "Collateral Type": "Cash veya Security seçimine göre ekranın 2–4 numaralı panellerini ve işlem hesaplamasını değiştirir.",
  "Eligible Currencies": "Transaction ekranında seçilebilecek nakit para birimlerini sınırlar.",
  "Eligibility Direction": "Teminatın post/receive yönünde uygunluğunu belirler; Transaction ekranında ikinci bir yön alanı açılmaz.",
  "Valuation Currency": "Teminat değerinin ortak olarak hesaplanacağı para birimidir.",
  "Settlement Instrument": "Nakit için Account Transfer, menkul için Securities Transfer yöntemini gösterir.",
  "Settlement Account Mapping": "Para birimi için kullanılacak nostro, vostro veya dahili hesap eşlemesini seçer.",
  "Interest Account Mapping": "Nakit teminat faizi için kullanılacak tahakkuk veya ödeme hesabı eşlemesidir.",
  "Default SSI Mapping": "Karşı taraf ve para birimi için varsayılan ödeme talimatı eşlemesidir.",
  "Rate Type": "Nakit teminat faizinin Floating, Fixed veya Interest Free olduğunu belirler.",
  "Reference Rate": "Floating faiz için kullanılacak €STR, SOFR, SONIA veya TLREF gibi endekstir.",
  Spread: "Referans orana eklenecek veya çıkarılacak baz puan farkıdır.",
  "Fixed Rate": "Rate Type Fixed olduğunda uygulanacak yıllık sabit orandır.",
  "Compounding Method": "Faizin günlük bileşik, basit veya uygulanmaz olarak hesaplanma biçimidir.",
  "Day Count": "Faiz gün sayım yöntemidir.",
  "Payment Frequency": "Tahakkuk eden faizin ne sıklıkta ödeneceğini belirler.",
  "Business Day Rule": "Ödeme tarihi tatil gününe gelirse uygulanacak tarih kaydırma kuralıdır.",
  "Negative Rate Allowed": "Negatif referans oranının faiz hesabına yansıtılıp yansıtılmayacağını gösterir.",
  "Security Scope": "Eligibility Rule bir menkul kümesini, Specific ISIN tek bir kıymeti tanımlar.",
  "Security Type": "Kabul edilen devlet tahvili, şirket tahvili, sukuk veya pay gibi varlık sınıfıdır.",
  "Issuer Type": "İhraççının devlet, uluslarüstü kuruluş, banka veya şirket olma kriteridir.",
  "Country of Risk": "Kabul edilecek ihraççı risk ülkesini sınırlar.",
  "Eligible Currency": "Menkulün ihraç para birimini sınırlar.",
  "Minimum Rating": "Kabul edilebilir en düşük kredi kalitesi eşiğidir.",
  "Maximum Remaining Maturity": "Kalan vadeye göre uygunluk sınırı koyar.",
  "Security / ISIN": "Tanımda veya işlemde kullanılacak menkul kıymeti benzersiz belirler.",
  Issuer: "ISIN seçildiğinde Security Master üzerinden gelir ve değiştirilemez.",
  Currency: "Cash işlemde Definition içindeki uygun para birimlerinden seçilir; ISIN detayında Security Master'dan gelir.",
  "Maturity Date": "Menkul kıymetin itfa tarihidir ve Security Master'dan gelir.",
  "Credit Rating": "En güncel onaylı kredi notudur; işlem anında snapshot alınır.",
  "Price Source": "Teminat değerlemesinde kullanılacak onaylı fiyat kaynağıdır.",
  "Price Type": "Kuponlu kıymette tahakkuk etmiş faizin fiyata dahil olup olmadığını gösterir.",
  "Haircut Method": "Menkul haircut oranının sabit, matris veya dış takvimden gelmesini belirler.",
  "Asset Haircut Rate": "Menkulün fiyat, likidite, kredi ve vade riski için piyasa değerinden indirilecek orandır.",
  "FX Haircut Rate": "Menkul para birimi ile değerleme para birimi farklıysa uygulanacak ek kur riski indirimidir.",
  "Minimum Nominal": "Operasyonel olarak kabul edilecek en düşük menkul nominalidir.",
  "Settlement Location": "Menkul transferinin Takasbank, Euroclear veya Clearstream gibi hangi CSD/ICSD üzerinde yapılacağını belirler.",
  "Custody Account": "Menkul teminatın teslim edileceği veya alınacağı saklama hesabıdır.",
  "Default SSI": "Menkul transferi için varsayılan teslimat talimatıdır.",
  "Income Treatment": "Kupon ve benzeri gelirlerin sağlayana aktarılma biçimini belirler.",
  "Corporate Action Handling": "İtfa ve diğer kurumsal aksiyonların otomatik mi talimatla mı işleneceğini belirler.",
  Portfolio: "İşlemin muhasebe ve raporlama portföyünü belirler.",
  Trader: "Kaydı oluşturan oturum kullanıcısından otomatik gelir ve değiştirilemez.",
  "Input Date": "Kaydın sisteme girildiği tarihtir ve sistem tarafından oluşturulur.",
  "Logical Reference": "Harici margin hesaplama, operasyon veya custody referansını saklar; ayrı bir Margin Call alanı değildir.",
  "Transaction Type": "Increase bakiyeyi artırır, Decrease bakiyeyi azaltır. İzinli değerler Annex Direction'a göre sınırlandırılır.",
  "Margin Type": "Hareketin VM, IM, IA veya Other teminat amacına ait olduğunu gösterir.",
  "Trade Date": "Teminat hareketinin taraflarca kararlaştırıldığı tarihtir.",
  "Value Date": "Nakit transferi veya menkul teslimatının gerçekleşeceği tarihtir.",
  Amount: "Transfer edilecek nakit tutarıdır; nakitte ayrıca asset haircut uygulanmaz.",
  Nominal: "Transfer edilecek menkul kıymetin nominal/adet miktarıdır.",
  "Current Balance": "Seçilen Collateral Code, Margin Type ve Currency/ISIN için işlem öncesi ledger bakiyesidir.",
  "Minimum Amount": "Definition veya operasyonel kuraldan gelen en düşük işlem tutarıdır.",
  "FX Conversion Required": "İşlem para birimi ile değerleme para birimi farklıysa Yes olur.",
  "FX Rate": "İşlem tutarını değerleme para birimine çevirmek için kullanılan onaylı kurdur.",
  "FX Adjustment": "Varsa para birimi uyumsuzluğu indirimidir; cash asset haircut değildir.",
  "Transaction Value": "Amount × FX Rate ile hesaplanan değerleme para birimi karşılığıdır.",
  "Adjusted Eligible Value": "Döviz dönüşümü ve ilgili ayarlama/haircutlar sonrası kabul edilen teminat değeridir.",
  Price: "Onaylı fiyat kaynağından gelen işlem anı menkul fiyatı ve fiyat tarihidir.",
  "Market Value": "Nominal ve fiyat üzerinden hesaplanan haircut öncesi menkul piyasa değeridir.",
  "Settlement Type": "Dış nakit settlement varsa brüt/net yöntemini belirler.",
  "Payment Instr. Type": "Ödeme talimatının Bank to Bank veya yapılandırılmış başka bir kanal türünde olacağını belirler.",
  "We Send": "Decrease işleminde bankanın gönderim hesabı veya kurumudur.",
  "They Receive": "Decrease işleminde karşı tarafın alım hesabı veya kurumudur.",
  "We Receive": "Increase işleminde bankanın tahsilat hesabı veya kurumudur.",
  "They Send": "Increase işleminde karşı tarafın gönderim hesabı veya kurumudur.",
  Instructions: "Operasyon ekibine iletilecek serbest açıklamadır; dış mesaj alanına aktarılmadan önce doğrulanmalıdır.",
  "Settlement Instruction": "Menkul hareketi için kullanılacak nihai teslimat talimatıdır.",
  "Delivery Type": "Increase için Receive, Decrease için Deliver olarak işlem türünden türetilir."
};

const DEFINITIONS = {
  "CASH-MULTI-001": {
    type: "Cash",
    name: "Eligible Cash Collateral",
    counterparty: "Barclays Bank",
    annex: "CSA-BRCL-VM-001",
    direction: "Both",
    valuationCurrency: "TRY",
    currencies: ["EUR", "USD", "GBP", "TRY"],
    marginTypes: ["VM", "IM", "IA", "Other"],
    minimumAmount: 0,
    fxAdjustment: 0,
    balances: { EUR: 20930000, USD: 8450000, GBP: 3100000, TRY: 125000000 },
    rates: { EUR: 49.82, USD: 42.3, GBP: 56.1, TRY: 1 }
  },
  "SEC-GOV-TRY-001": {
    type: "Security",
    name: "TRY Government Bond Rule",
    counterparty: "Barclays Bank",
    annex: "CSA-BRCL-VM-001",
    direction: "Both",
    valuationCurrency: "TRY",
    marginTypes: ["VM", "IM", "IA", "Other"],
    minimumNominal: 1000000,
    settlementLocation: "Takasbank",
    balances: { TRT240728T15: 15000000, XS0000000001: 6000000 }
  }
};

const SECURITIES = {
  TRT240728T15: {
    issuer: "Republic of Türkiye",
    currency: "TRY",
    maturity: "2028-07-24",
    rating: "Internal Grade 1",
    type: "Government Bond",
    price: 97.25,
    priceDate: "2026-10-12",
    assetHaircut: 2,
    fxHaircut: 0,
    fxRate: 1
  },
  XS0000000001: {
    issuer: "Example Corporate Issuer",
    currency: "EUR",
    maturity: "2030-06-15",
    rating: "Internal Grade 3",
    type: "Corporate Bond",
    price: 101.4,
    priceDate: "2026-10-12",
    assetHaircut: 5,
    fxHaircut: 8,
    fxRate: 49.82
  }
};

const history = {
  cash: {
    EUR: [
      { date: "2026-09-02", ref: "COL-CASH-00391", type: "Increase", amount: 20000000, rate: 49.1 },
      { date: "2026-09-10", ref: "COL-CASH-00416", type: "Increase", amount: 3000000, rate: 49.36 },
      { date: "2026-09-18", ref: "COL-CASH-00445", type: "Decrease", amount: 2070000, rate: 49.62 }
    ],
    USD: [{ date: "2026-09-05", ref: "COL-CASH-00402", type: "Increase", amount: 8450000, rate: 42.02 }],
    GBP: [{ date: "2026-09-07", ref: "COL-CASH-00408", type: "Increase", amount: 3100000, rate: 55.75 }],
    TRY: [{ date: "2026-09-01", ref: "COL-CASH-00385", type: "Increase", amount: 125000000, rate: 1 }]
  },
  security: {
    TRT240728T15: [
      { date: "2026-09-04", ref: "COL-SEC-00182", type: "Increase", nominal: 20000000, price: 96.85 },
      { date: "2026-09-22", ref: "COL-SEC-00206", type: "Decrease", nominal: 5000000, price: 97.05 }
    ],
    XS0000000001: [{ date: "2026-09-11", ref: "COL-SEC-00194", type: "Increase", nominal: 6000000, price: 100.95 }]
  }
};

const definitionDrafts = {
  Cash: { code: "CASH-MULTI-001", name: "Eligible Cash Collateral" },
  Security: { code: "SEC-GOV-TRY-001", name: "TRY Government Bond Rule" }
};

let activeScreen = "annex";
let activeTxView = "entry";
let selectedProductRow = $("#product-table tbody tr.selected");
let toastTimer;
let referenceSequence = 500;

const number = (value) => Number(value || 0);
const formatNumber = (value, decimals = 2) => Number(value).toLocaleString("en-US", { minimumFractionDigits: decimals, maximumFractionDigits: decimals });
const formatMoney = (value, currency) => `${formatNumber(value)} ${currency}`;
const signed = (value, positive) => `${positive ? "+" : "−"}${formatNumber(Math.abs(value))}`;
const isoToDisplay = (value) => {
  if (!value) return "";
  const [year, month, day] = value.split("-");
  return `${day}.${month}.${year}`;
};

function setHidden(element, hidden) {
  element.hidden = hidden;
  if (hidden) element.setAttribute("aria-hidden", "true");
  else element.removeAttribute("aria-hidden");
}

function setControlDisabled(control, disabled, reason = "") {
  control.disabled = disabled;
  const field = control.closest(".field");
  if (!field) return;
  field.classList.toggle("state-conditional-disabled", disabled && Boolean(reason));
  if (reason) field.dataset.disabledReason = reason;
  else delete field.dataset.disabledReason;
}

function showToast(message, error = false) {
  const toast = $("#toast");
  toast.textContent = message;
  toast.classList.toggle("error", error);
  toast.hidden = false;
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => { toast.hidden = true; }, 4200);
}

function labelText(field) {
  const label = $("label", field);
  if (!label) return "";
  const clone = label.cloneNode(true);
  $$("button, b", clone).forEach((node) => node.remove());
  return clone.textContent.trim();
}

function controlState(field) {
  const control = $("input, select, textarea", field);
  if (!control) return "Action / table";
  if (control.disabled) return "Disabled";
  if (control.readOnly) return "Read-only";
  return "Editable";
}

function renderFieldMap() {
  const body = $("#field-map-body");
  const screen = $(`[data-screen-panel="${activeScreen}"]`);
  const fields = $$(".field", screen).filter((field) => !field.hidden && field.offsetParent !== null);
  body.innerHTML = "";
  fields.forEach((field) => {
    const row = document.createElement("tr");
    [
      labelText(field),
      field.dataset.key || "—",
      field.dataset.entry || "—",
      field.dataset.control || "—",
      field.dataset.required || "—",
      controlState(field)
    ].forEach((value) => {
      const cell = document.createElement("td");
      cell.textContent = value;
      row.appendChild(cell);
    });
    body.appendChild(row);
  });
}

function showScreen(name) {
  activeScreen = name;
  const titles = {
    annex: "Collateral Annex Definition",
    definition: "Collateral Definition",
    transaction: "Collateral Transaction"
  };
  $$(".main-tab").forEach((tab) => tab.classList.toggle("active", tab.dataset.screen === name));
  $$('[data-screen-panel]').forEach((panel) => setHidden(panel, panel.dataset.screenPanel !== name));
  $("#screen-title").innerHTML = `${titles[name]} <span>[ New ]</span>`;
  renderFieldMap();
}

function showTxView(view) {
  activeTxView = view;
  $$(".sub-tab").forEach((tab) => tab.classList.toggle("active", tab.dataset.txView === view));
  $$('[data-tx-panel]').forEach((panel) => setHidden(panel, panel.dataset.txPanel !== view));
  $("#screen-title").innerHTML = view === "entry"
    ? "Collateral Transaction <span>[ New ]</span>"
    : "Collateral Transaction <span>[ Detail ]</span>";
  if (view === "detail") renderHistory();
  renderFieldMap();
}

function updateHelp(key) {
  $("#help-title").textContent = key;
  $("#help-text").textContent = HELP[key] || "Bu alanın kaynağı, kontrol tipi ve düzenlenebilirlik kuralı Developer mode ve Field map görünümünde gösterilir.";
}

function openModal(id) {
  const modal = document.getElementById(id);
  modal.hidden = false;
  const first = $("input, select, button", modal);
  if (first) first.focus();
}

function closeModal(id) {
  document.getElementById(id).hidden = true;
}

function productContext(row = selectedProductRow) {
  if (!row) return null;
  return {
    id: row.dataset.scopeId,
    product: row.cells[0].textContent.trim(),
    subProduct: row.cells[1].textContent.trim(),
    marginType: row.cells[2].textContent.trim()
  };
}

function selectProductRow(row) {
  $$("#product-table tbody tr").forEach((item) => item.classList.remove("selected"));
  row.classList.add("selected");
  selectedProductRow = row;
  const context = productContext();
  const label = `${context.product} · ${context.subProduct} · ${context.marginType}`;
  $("#rule-context").textContent = label;
  $("#modal-rule-context").textContent = label;
  $$("#margin-rule-table tbody tr").forEach((ruleRow) => {
    ruleRow.hidden = ruleRow.dataset.scopeId !== context.id;
  });
}

function addProductScope() {
  const product = $("#modal-product").value;
  const subProduct = $("#modal-sub-product").value;
  const marginType = $("#modal-margin-type").value;
  const included = $("#modal-included").value;
  if (!product) {
    showToast("Product seçilmelidir.", true);
    $("#modal-product").focus();
    return;
  }
  const duplicate = $$("#product-table tbody tr").some((row) =>
    row.cells[0].textContent.trim() === product &&
    row.cells[1].textContent.trim() === subProduct &&
    row.cells[2].textContent.trim() === marginType
  );
  if (duplicate) {
    showToast("Aynı Product, Sub Product ve Margin Type kombinasyonu zaten mevcut.", true);
    return;
  }
  const row = document.createElement("tr");
  row.dataset.scopeId = `PS-${String(Date.now()).slice(-6)}`;
  row.innerHTML = `<td>${product}</td><td>${subProduct}</td><td>${marginType}</td><td><span class="status ${included === "Yes" ? "positive" : ""}">${included}</span></td>`;
  row.addEventListener("click", () => selectProductRow(row));
  $("#product-table tbody").appendChild(row);
  selectProductRow(row);
  closeModal("product-modal");
  showToast("Product Scope satırı eklendi. Add Rule bu satırın product_scope_id bağlamını kullanır.");
}

function addMarginRule() {
  const context = productContext();
  if (!context) {
    closeModal("rule-modal");
    showToast("Önce Product Scope tablosundan bir satır seçilmelidir.", true);
    return;
  }
  const party = $("#modal-party").value;
  const currency = $("#modal-rule-currency").value;
  const values = [
    party,
    `${formatNumber(number($("#modal-threshold").value))} ${currency}`,
    `${formatNumber(number($("#modal-mta").value), 0)} ${currency}`,
    `${formatNumber(number($("#modal-rounding").value), 0)} ${currency}`,
    $("#modal-rounding-method").value
  ];
  let row = $$("#margin-rule-table tbody tr").find((item) => item.dataset.scopeId === context.id && item.cells[0].textContent.trim() === party);
  if (!row) {
    row = document.createElement("tr");
    row.dataset.scopeId = context.id;
    $("#margin-rule-table tbody").appendChild(row);
  }
  row.innerHTML = values.map((value) => `<td>${value}</td>`).join("");
  selectProductRow(selectedProductRow);
  closeModal("rule-modal");
  showToast(`${party} margin rule ${context.marginType} kapsamına kaydedildi.`);
}

function updateDefinitionAnnex() {
  const linked = Boolean($("#definition-annex").value);
  const inheritedControls = [
    $("#definition-counterparty"),
    $("#cash-direction"),
    $("#cash-valuation-currency"),
    $("#security-direction"),
    $("#security-valuation-currency")
  ];
  if (linked) {
    $("#definition-counterparty").value = "Barclays Bank";
    $("#cash-direction").value = "Both";
    $("#security-direction").value = "Both";
    $("#cash-valuation-currency").value = "TRY";
    $("#security-valuation-currency").value = "TRY";
  }
  inheritedControls.forEach((control) => setControlDisabled(control, linked, linked ? "Inherited from Annex" : ""));
  renderFieldMap();
}

function setDefinitionType(type, initial = false) {
  const previousType = type === "Cash" ? "Security" : "Cash";
  if (!initial) {
    definitionDrafts[previousType] = {
      code: $("#definition-code").value,
      name: $("#definition-name").value
    };
  }
  $("#definition-type").value = type;
  $$(".cash-panel, .cash-only").forEach((element) => setHidden(element, type !== "Cash"));
  $$(".security-panel, .security-only").forEach((element) => setHidden(element, type !== "Security"));
  $("#definition-code").value = definitionDrafts[type].code;
  $("#definition-name").value = definitionDrafts[type].name;
  updateDefinitionAnnex();
  if (type === "Security") updateSecurityScope();
  renderFieldMap();
}

function populateSpecificSecurity() {
  const security = SECURITIES[$("#specific-isin").value];
  $("#security-issuer").value = security.issuer;
  $("#security-currency").value = security.currency;
  $("#security-maturity").value = security.maturity;
  $("#security-rating").value = security.rating;
  $("#security-type-derived").value = security.type;
}

function updateSecurityScope() {
  const isRule = $("#security-scope").value === "rule";
  $("#security-scope-title").textContent = isRule ? "Rule-based Security Eligibility" : "Specific Security Details";
  setHidden($(".security-rule-fields"), !isRule);
  setHidden($(".security-isin-fields"), isRule);
  if (!isRule) populateSpecificSecurity();
  renderFieldMap();
}

function updateInterestTerms() {
  const rateType = $("#rate-type").value;
  const floating = rateType === "Floating";
  const fixed = rateType === "Fixed";
  const interestFree = rateType === "Interest Free";
  setControlDisabled($("#reference-rate"), !floating, floating ? "" : "Only for Floating");
  setControlDisabled($("#spread"), !floating, floating ? "" : "Only for Floating");
  setControlDisabled($("#fixed-rate"), !fixed, fixed ? "" : "Only for Fixed");
  [$("#compounding"), $("#day-count"), $("#payment-frequency"), $("#business-day-rule"), $("#negative-rate")]
    .forEach((control) => setControlDisabled(control, interestFree, interestFree ? "Not applicable for Interest Free" : ""));
  renderFieldMap();
}

function allowedTransactionTypes(direction) {
  if (direction === "Post Only") return ["Decrease"];
  if (direction === "Receive Only") return ["Increase"];
  return ["Increase", "Decrease"];
}

function setSelectOptions(select, values, selected = values[0]) {
  select.innerHTML = "";
  values.forEach((value) => {
    const option = document.createElement("option");
    option.value = value;
    option.textContent = value;
    option.selected = value === selected;
    select.appendChild(option);
  });
}

function currentDefinition() {
  return DEFINITIONS[$("#tx-collateral-code").value];
}

function updateTransactionDefinition() {
  const definition = currentDefinition();
  $("#tx-counterparty").value = definition.counterparty;
  $("#tx-collateral-name").value = definition.name;
  $("#tx-collateral-type").value = definition.type;
  $("#tx-annex").value = definition.annex || "No Annex / Standalone";
  $("#limit-counterparty").textContent = definition.counterparty;
  const cash = definition.type === "Cash";
  setHidden($("#cash-transaction-section"), !cash);
  setHidden($("#cash-payment-section"), !cash);
  setHidden($("#security-transaction-section"), cash);
  setHidden($("#security-settlement-section"), cash);

  if (cash) {
    setSelectOptions($("#cash-currency"), definition.currencies, definition.currencies[0]);
    setSelectOptions($("#cash-margin-type"), definition.marginTypes, "VM");
    setSelectOptions($("#cash-tx-type"), allowedTransactionTypes(definition.direction), allowedTransactionTypes(definition.direction)[0]);
    $("#cash-tx-valuation-currency").value = definition.valuationCurrency;
    $("#cash-minimum-amount").value = formatMoney(definition.minimumAmount, $("#cash-currency").value);
    updateCashCalculation();
    updateCashPaymentDirection();
  } else {
    setSelectOptions($("#security-margin-type"), definition.marginTypes, "VM");
    setSelectOptions($("#security-tx-type"), allowedTransactionTypes(definition.direction), allowedTransactionTypes(definition.direction)[0]);
    $("#security-tx-valuation-currency").value = definition.valuationCurrency;
    $("#security-minimum-nominal").value = formatNumber(definition.minimumNominal);
    $("#tx-settlement-location").value = definition.settlementLocation;
    updateSecurityCalculation();
    updateSecuritySettlementDirection();
  }
  renderHistory();
  renderFieldMap();
}

function updateCashCalculation() {
  const definition = currentDefinition();
  if (definition.type !== "Cash") return;
  const currency = $("#cash-currency").value;
  const amount = number($("#cash-amount").value);
  const rate = definition.rates[currency];
  const valuation = definition.valuationCurrency;
  const adjustment = definition.fxAdjustment;
  const transactionValue = amount * rate;
  const eligibleValue = transactionValue * (1 - adjustment / 100);
  $("#cash-current-balance").value = formatMoney(definition.balances[currency], currency);
  $("#cash-minimum-amount").value = formatMoney(definition.minimumAmount, currency);
  $("#fx-required").value = currency === valuation ? "No" : `Yes — ${currency} / ${valuation}`;
  $("#cash-fx-rate").value = `${rate.toFixed(6)} ${valuation}/${currency}`;
  $("#cash-fx-adjustment").value = `${adjustment.toFixed(2)} %`;
  $("#cash-transaction-value").value = formatMoney(transactionValue, valuation);
  $("#cash-eligible-value").value = formatMoney(eligibleValue, valuation);
  renderHistory();
}

function updateSecurityCalculation() {
  const definition = currentDefinition();
  if (definition.type !== "Security") return;
  const isin = $("#tx-security-isin").value;
  const security = SECURITIES[isin];
  const nominal = number($("#security-nominal").value);
  const marketValueLocal = nominal * security.price / 100;
  const marketValue = marketValueLocal * security.fxRate;
  const eligible = marketValue * (1 - security.assetHaircut / 100) * (1 - security.fxHaircut / 100);
  $("#security-current-balance").value = formatNumber(definition.balances[isin] || 0);
  $("#security-price").value = `${security.price.toFixed(4)} · ${isoToDisplay(security.priceDate)}`;
  $("#security-market-value").value = formatMoney(marketValue, definition.valuationCurrency);
  $("#tx-asset-haircut").value = `${security.assetHaircut.toFixed(2)} %`;
  $("#tx-fx-haircut").value = `${security.fxHaircut.toFixed(2)} %`;
  $("#security-eligible-value").value = formatMoney(eligible, definition.valuationCurrency);
  renderHistory();
}

function updateCashPaymentDirection() {
  const increase = $("#cash-tx-type").value === "Increase";
  $("#payment-direction-note").textContent = increase
    ? "Increase: They Send + We Receive are editable"
    : "Decrease: We Send + They Receive are editable";
  setControlDisabled($("#we-send"), increase, increase ? "Inactive SSI direction" : "");
  setControlDisabled($("#they-receive"), increase, increase ? "Inactive SSI direction" : "");
  setControlDisabled($("#we-receive"), !increase, !increase ? "Inactive SSI direction" : "");
  setControlDisabled($("#they-send"), !increase, !increase ? "Inactive SSI direction" : "");
  $("#send-payment").checked = false;
  setControlDisabled($("#send-payment"), increase, increase ? "Only for cash outflow" : "");
  $("#send-notice").checked = false;
  setControlDisabled($("#send-notice"), !increase, !increase ? "Only for expected cash inflow" : "");
  renderFieldMap();
}

function updateSecuritySettlementDirection() {
  const increase = $("#security-tx-type").value === "Increase";
  $("#delivery-type").value = increase ? "Receive" : "Deliver";
  $("#security-direction-note").textContent = increase ? "Increase: Receive instruction" : "Decrease: Deliver instruction";
}

function cashHistoryRows() {
  const currency = $("#cash-currency").value;
  return history.cash[currency] || [];
}

function securityHistoryRows() {
  const isin = $("#tx-security-isin").value;
  return history.security[isin] || [];
}

function renderHistory() {
  const definition = currentDefinition();
  const cash = definition.type === "Cash";
  const thead = $("#history-table thead");
  const tbody = $("#history-table tbody");
  tbody.innerHTML = "";
  $("#history-code").value = $("#tx-collateral-code").value;
  $("#history-title").textContent = cash ? "Cash Transaction History" : "Security Transaction History";

  if (cash) {
    const currency = $("#cash-currency").value;
    const rows = cashHistoryRows();
    $("#history-asset").value = currency;
    thead.innerHTML = "<tr><th>Trade Date</th><th>Transaction Reference</th><th>Transaction Type</th><th>Cash Flow</th><th>Amount</th><th>FX Rate</th><th>Transaction Value (TRY)</th><th>Running Balance</th></tr>";
    let balance = 0;
    rows.forEach((item) => {
      const positive = item.type === "Increase";
      const movement = positive ? item.amount : -item.amount;
      balance += movement;
      const row = document.createElement("tr");
      row.innerHTML = `<td>${isoToDisplay(item.date)}</td><td>${item.ref}</td><td>${item.type}</td><td>${positive ? "Inflow" : "Outflow"}</td><td>${signed(movement, positive)} ${currency}</td><td>${item.rate.toFixed(6)}</td><td>${signed(movement * item.rate, positive)}</td><td>${formatMoney(balance, currency)}</td>`;
      tbody.appendChild(row);
    });
    $("#history-start").value = rows.length ? isoToDisplay(rows[0].date) : "";
    $("#history-balance").value = formatMoney(balance, currency);
    setHidden($("#history-empty"), rows.length > 0);
    setHidden($("#history-table"), rows.length === 0);
  } else {
    const isin = $("#tx-security-isin").value;
    const security = SECURITIES[isin];
    const rows = securityHistoryRows();
    $("#history-asset").value = isin;
    thead.innerHTML = "<tr><th>Trade Date</th><th>Transaction Reference</th><th>Transaction Type</th><th>Security Flow</th><th>Nominal</th><th>Price</th><th>Market Value</th><th>Running Nominal</th></tr>";
    let balance = 0;
    rows.forEach((item) => {
      const positive = item.type === "Increase";
      const movement = positive ? item.nominal : -item.nominal;
      balance += movement;
      const marketValue = Math.abs(movement) * item.price / 100 * security.fxRate;
      const row = document.createElement("tr");
      row.innerHTML = `<td>${isoToDisplay(item.date)}</td><td>${item.ref}</td><td>${item.type}</td><td>${positive ? "Receive" : "Deliver"}</td><td>${signed(movement, positive)}</td><td>${item.price.toFixed(4)}</td><td>${signed(marketValue, positive)} ${definition.valuationCurrency}</td><td>${formatNumber(balance)}</td>`;
      tbody.appendChild(row);
    });
    $("#history-start").value = rows.length ? isoToDisplay(rows[0].date) : "";
    $("#history-balance").value = formatNumber(balance);
    setHidden($("#history-empty"), rows.length > 0);
    setHidden($("#history-table"), rows.length === 0);
  }
}

function visibleRequiredControls() {
  const entry = $("#transaction-entry");
  return $$(".field[data-required='Yes'] input, .field[data-required='Yes'] select, .field[data-required='Conditional'] input, .field[data-required='Conditional'] select", entry)
    .filter((control) => control.offsetParent !== null && !control.disabled);
}

function validateTransaction() {
  const empty = visibleRequiredControls().filter((control) => control.value.trim() === "");
  if (empty.length) {
    empty[0].focus();
    showToast(`${labelText(empty[0].closest(".field"))} alanı doldurulmalıdır.`, true);
    return false;
  }
  const definition = currentDefinition();
  if (definition.type === "Cash") {
    const amount = number($("#cash-amount").value);
    const currency = $("#cash-currency").value;
    if (amount <= 0) {
      showToast("Amount sıfırdan büyük olmalıdır.", true);
      return false;
    }
    if ($("#cash-tx-type").value === "Decrease" && amount > definition.balances[currency]) {
      showToast("Decrease tutarı Current Balance değerini aşamaz.", true);
      return false;
    }
  } else {
    const nominal = number($("#security-nominal").value);
    const isin = $("#tx-security-isin").value;
    if (nominal < definition.minimumNominal) {
      showToast("Nominal, Minimum Nominal değerinden küçük olamaz.", true);
      return false;
    }
    if ($("#security-tx-type").value === "Decrease" && nominal > (definition.balances[isin] || 0)) {
      showToast("Decrease nominali Current Balance değerini aşamaz.", true);
      return false;
    }
  }
  return true;
}

function verifyTransaction() {
  if (!validateTransaction()) return;
  const definition = currentDefinition();
  referenceSequence += 1;
  if (definition.type === "Cash") {
    const currency = $("#cash-currency").value;
    const type = $("#cash-tx-type").value;
    const amount = number($("#cash-amount").value);
    const rate = definition.rates[currency];
    history.cash[currency] ??= [];
    history.cash[currency].push({
      date: $("#cash-trade-date").value,
      ref: `COL-CASH-${String(referenceSequence).padStart(5, "0")}`,
      type,
      amount,
      rate
    });
    definition.balances[currency] += type === "Increase" ? amount : -amount;
    updateCashCalculation();
    const message = type === "Decrease" && $("#send-payment").checked
      ? "Verify tamamlandı; uygun CBPR+ rota için pacs.009 ödeme mesajı işleme alındı."
      : "Verify tamamlandı; hareket history görünümüne eklendi.";
    showToast(message);
  } else {
    const isin = $("#tx-security-isin").value;
    const type = $("#security-tx-type").value;
    const nominal = number($("#security-nominal").value);
    history.security[isin] ??= [];
    history.security[isin].push({
      date: $("#security-trade-date").value,
      ref: `COL-SEC-${String(referenceSequence).padStart(5, "0")}`,
      type,
      nominal,
      price: SECURITIES[isin].price
    });
    definition.balances[isin] = (definition.balances[isin] || 0) + (type === "Increase" ? nominal : -nominal);
    updateSecurityCalculation();
    showToast("Verify tamamlandı; menkul teslimat talimatı ve history satırı oluşturuldu.");
  }
}

function refreshLimit() {
  const button = $("#refresh-limit");
  button.textContent = "…";
  setTimeout(() => {
    button.textContent = "↻";
    showToast("Limit servisi güncel işlem verisiyle yeniden sorgulandı.");
  }, 500);
}

// Main navigation and help
$$(".main-tab").forEach((tab) => tab.addEventListener("click", () => showScreen(tab.dataset.screen)));
$$(".sub-tab").forEach((tab) => tab.addEventListener("click", () => showTxView(tab.dataset.txView)));
$$(".help-button").forEach((button) => button.addEventListener("click", () => updateHelp(button.dataset.help)));

// Developer helpers
$("#developer-mode").addEventListener("change", (event) => {
  app.classList.toggle("dev-mode", event.target.checked);
  renderFieldMap();
});
$("#open-field-map").addEventListener("click", () => {
  renderFieldMap();
  $("#field-map").hidden = false;
  $("#drawer-backdrop").hidden = false;
});
const closeFieldMap = () => { $("#field-map").hidden = true; $("#drawer-backdrop").hidden = true; };
$("#close-field-map").addEventListener("click", closeFieldMap);
$("#drawer-backdrop").addEventListener("click", closeFieldMap);

// Annex Product Scope and Party Margin Rule
$$("#product-table tbody tr").forEach((row) => row.addEventListener("click", () => selectProductRow(row)));
$("#open-product-modal").addEventListener("click", () => openModal("product-modal"));
$("#open-rule-modal").addEventListener("click", () => {
  if (!selectedProductRow) { showToast("Önce Product Scope satırı seçilmelidir.", true); return; }
  $("#modal-rule-context").textContent = $("#rule-context").textContent;
  openModal("rule-modal");
});
$("#add-product").addEventListener("click", addProductScope);
$("#add-rule").addEventListener("click", addMarginRule);
$$('[data-close-modal]').forEach((button) => button.addEventListener("click", () => closeModal(button.dataset.closeModal)));
$$('.modal-backdrop').forEach((backdrop) => backdrop.addEventListener("click", (event) => {
  if (event.target === backdrop) closeModal(backdrop.id);
}));

// Definition dependencies
$("#definition-annex").addEventListener("change", updateDefinitionAnnex);
$("#definition-type").addEventListener("change", (event) => setDefinitionType(event.target.value));
$("#security-scope").addEventListener("change", updateSecurityScope);
$("#specific-isin").addEventListener("change", populateSpecificSecurity);
$("#rate-type").addEventListener("change", updateInterestTerms);

// Transaction dependencies and calculation
$("#tx-collateral-code").addEventListener("change", updateTransactionDefinition);
$("#cash-currency").addEventListener("change", updateCashCalculation);
$("#cash-amount").addEventListener("input", updateCashCalculation);
$("#cash-tx-type").addEventListener("change", updateCashPaymentDirection);
$("#tx-security-isin").addEventListener("change", updateSecurityCalculation);
$("#security-nominal").addEventListener("input", updateSecurityCalculation);
$("#security-tx-type").addEventListener("change", updateSecuritySettlementDirection);
$("#verify-transaction").addEventListener("click", verifyTransaction);
$("#save-draft").addEventListener("click", () => showToast("Taslak kaydedildi; bakiye ve mesaj üretimi yapılmadı."));
$("#refresh-limit").addEventListener("click", refreshLimit);
$$('[data-action="save"]').forEach((button) => button.addEventListener("click", () => showToast("Prototype save completed. Production API integration is intentionally not included.")));

document.addEventListener("keydown", (event) => {
  if (event.key !== "Escape") return;
  $$(".modal-backdrop").forEach((modal) => { if (!modal.hidden) closeModal(modal.id); });
  if (!$("#field-map").hidden) closeFieldMap();
});

// Initial state
selectProductRow(selectedProductRow);
setDefinitionType("Cash", true);
updateInterestTerms();
populateSpecificSecurity();
updateTransactionDefinition();
showScreen("annex");
