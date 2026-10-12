import csv,os,collections,glob,re,json
SP=os.path.join(os.environ['LOCALAPPDATA'],'Temp','claude','c--Users-Treasy-70-source-repos--ai-agent','b20aba7c-6c26-434f-880c-ab47ad8c0df3','scratchpad')
L=lambda f:list(csv.reader(open(os.path.join(SP,f),encoding='utf-8'),delimiter='\t'))
g=[r for r in L('gaps.tsv')[1:] if any(r)]
y={r[0]:r[1] for r in L('Yat_r_m_Bankas_.tsv')[1:] if len(r)>1 and r[0]}
k={r[0]:r[1] for r in L('Kat_l_m_Bankas_.tsv')[1:] if len(r)>1 and r[0]}
diffk={e for e in y if y.get(e)!=k.get(e)}
MM=['pages/treasury/money-market/money-market',
    'pages/treasury/money-market/repo-transactions',
    'pages/treasury/interbank-loan/interbank-loan',
    'pages/treasury/issue-bond/issue-bond',
    'pages/treasury/issue-bond-revaluation/issue-bond-revaluation',
    'pages/treasury/tawarruq/tawarruq',
    'pages/definitions/product-types/mm-product',
    'pages/reports/money-market/money-market-revaluation-report',
    'pages/reports/interbank-loan/interbank-loan-revaluation-report',
    'pages/reconciliation/platform-reconciliation/external-mm-stp',
    'pages/manuel-reescont/manuel-reescont']
print(f"{'module':60s} {'gap':>5s} {'fill':>5s} {'nogl':>5s} {'y!=k':>5s}")
T=collections.Counter()
for m in MM:
    rs=[r for r in g if r[0]==m]
    fill=sum(1 for r in rs if r[2] in y); nogl=sum(1 for r in rs if r[2] not in y and r[4]!='NO_EN_KEY')
    dk=sum(1 for r in rs if r[2] in diffk)
    print(f"{m:60s} {len(rs):5d} {fill:5d} {nogl:5d} {dk:5d}")
    T['gap']+=len(rs);T['fill']+=fill;T['nogl']+=nogl;T['dk']+=dk
print(f"{'TOTAL MM':60s} {T['gap']:5d} {T['fill']:5d} {T['nogl']:5d} {T['dk']:5d}")
print("\n== MM rows needing scheme split (y!=k) ==")
for r in g:
    if r[0] in MM and r[2] in diffk:
        print(f"  {r[0].split('/')[-1]:32s} {r[1]:52s} EN={r[2]!r}")
        print(f"      Y={y[r[2]]!r}   K={k[r[2]]!r}")
