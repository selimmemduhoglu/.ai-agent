# Treasury Collateral Management UI Prototype

This package is a dependency-free developer reference for the three approved screens:

1. Collateral Annex Definition
2. Collateral Definition
3. Collateral Transaction and Transaction Detail

## Run

Open `index.html` directly in a modern browser. No build step, package manager, server, or external library is required.

For a local HTTP server, any static server can be used, for example:

```bash
python -m http.server 8080
```

Then open `http://localhost:8080`.

## Files

- `index.html`: semantic screen markup and all visible fields.
- `styles.css`: responsive 2x2 screen layout, state styles, modals and developer mode.
- `app.js`: field dependencies, calculations, modal actions, validation, history simulation and developer field map.

## Interaction coverage

- Annex Product Scope rows can be added and selected.
- Add Rule always uses the selected Product Scope context; `product_scope_id` is not re-entered by the user.
- Definition Annex selection locks or unlocks inherited Counterparty, Eligibility Direction and Valuation Currency fields.
- Collateral Type changes the Cash and Security panels.
- Security Scope changes between Eligibility Rule and Specific ISIN.
- Specific ISIN fills read-only Security Master attributes.
- Cash Rate Type enables only the relevant Floating, Fixed or Interest Free fields.
- Transaction Collateral Code changes the complete Cash or Security transaction form.
- Transaction Type changes payment or delivery direction.
- Cash amount and currency recalculate FX conversion and adjusted eligible value.
- Security nominal and ISIN recalculate market value and haircut-adjusted eligible value.
- Verify validates balances and appends a simulated immutable history record.
- Developer mode displays each field's control type, entry behavior and binding key.
- Field map lists the currently visible fields with editable/read-only/disabled state.

## Integration boundary

The prototype contains sample data and browser-side calculations only. Production implementation must call the authoritative Annex, Definition, market data, limit, SSI, ledger, settlement, messaging and audit services described in the technical analysis. The client must not be treated as the source of truth for Verify rules or balances.
