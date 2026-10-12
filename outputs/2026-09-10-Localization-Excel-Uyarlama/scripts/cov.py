import csv,os,collections
SP=os.path.join(os.environ['LOCALAPPDATA'],'Temp','claude','c--Users-Treasy-70-source-repos--ai-agent','b20aba7c-6c26-434f-880c-ab47ad8c0df3','scratchpad')
L=lambda f:list(csv.reader(open(os.path.join(SP,f),encoding='utf-8'),delimiter='\t'))
g=[r for r in L('gaps.tsv')[1:] if any(r)]
y={r[0]:r[1] for r in L('Yat_r_m_Bankas_.tsv')[1:] if len(r)>1 and r[0]}
k={r[0]:r[1] for r in L('Kat_l_m_Bankas_.tsv')[1:] if len(r)>1 and r[0]}
diffk={e for e in y if y.get(e)!=k.get(e)}
c=collections.Counter(); nocov=[]
for r in g:
    en=r[2]
    if r[4]=='NO_EN_KEY': c['skip_no_en']+=1; continue
    if en in y: c['fillable']+=1
    else: c['NOT_in_glossary']+=1; nocov.append(r)
print("gap rows:",len(g)); print(c)
print("\nfillable rows needing SCHEME split (y!=k):",sum(1 for r in g if r[2] in diffk))
print("all live keys whose EN differs y/k: n/a")
print("\n-- NOT in glossary, by module (top 25) --")
for m,n in collections.Counter(r[0] for r in nocov).most_common(25): print(f"  {n:5d} {m}")
print("\n-- sample NOT in glossary (40) --")
for r in nocov[:40]: print("  ",r[0],"|",r[1],"|",repr(r[2]),"|",r[4])
