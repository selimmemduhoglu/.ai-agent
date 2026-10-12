import csv,os,collections
SP=os.path.join(os.environ['LOCALAPPDATA'],'Temp','claude','c--Users-Treasy-70-source-repos--ai-agent','b20aba7c-6c26-434f-880c-ab47ad8c0df3','scratchpad')
OUT=os.path.join('C:'+os.sep,'Users','Treasy-70','source','repos','.ai-agent','outputs','2026-09-10-Localization-Excel-Uyarlama','data')
L=lambda f:list(csv.reader(open(os.path.join(SP,f),encoding='utf-8'),delimiter='\t'))
g=[r for r in L('gaps.tsv')[1:] if any(r)]
y={r[0]:r[1] for r in L('Yat_r_m_Bankas_.tsv')[1:] if len(r)>1 and r[0]}
k={r[0]:r[1] for r in L('Kat_l_m_Bankas_.tsv')[1:] if len(r)>1 and r[0]}
diffk={e for e in y if y.get(e)!=k.get(e)}
MM={'pages/treasury/money-market/money-market','pages/treasury/money-market/repo-transactions',
 'pages/treasury/interbank-loan/interbank-loan','pages/treasury/issue-bond/issue-bond',
 'pages/treasury/issue-bond-revaluation/issue-bond-revaluation','pages/treasury/tawarruq/tawarruq',
 'pages/definitions/product-types/mm-product','pages/reports/money-market/money-market-revaluation-report',
 'pages/reports/interbank-loan/interbank-loan-revaluation-report',
 'pages/reconciliation/platform-reconciliation/external-mm-stp','pages/manuel-reescont/manuel-reescont'}
def w(fn,rows,hdr):
    with open(os.path.join(OUT,fn),'w',encoding='utf-8',newline='') as f:
        c=csv.writer(f,delimiter='\t');c.writerow(hdr);c.writerows(rows)
    print(fn,len(rows))
all_rows=[];mm_rows=[]
for r in g:
    mod,key,en,tr,st=r
    ty=y.get(en,'');tk=k.get(en,'')
    src='GLOSSARY' if en in y else ('-' if st=='NO_EN_KEY' else 'MISSING')
    sch='YES' if en in diffk else ''
    row=[mod,key,en,tr,st,src,ty,tk,sch,'MM' if mod in MM else '']
    all_rows.append(row)
    if mod in MM: mm_rows.append(row)
H=['module','key','en','current_tr','status','fill_source','tr_yatirim','tr_katilim','scheme_split','scope']
w('gaps-live.tsv',all_rows,H); w('mm-gaps.tsv',mm_rows,H)
w('glossary-diff-yatirim-katilim.tsv',[[e,y[e],k[e]] for e in sorted(diffk)],['english','tr_yatirim','tr_katilim'])
w('not-in-glossary.tsv',[r for r in all_rows if r[5]=='MISSING'],H)
