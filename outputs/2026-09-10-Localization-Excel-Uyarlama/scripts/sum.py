import csv,os,collections
OUT=os.path.join('C:'+os.sep,'Users','Treasy-70','source','repos','.ai-agent','outputs','2026-09-10-Localization-Excel-Uyarlama','data')
r=list(csv.reader(open(os.path.join(OUT,'gaps-live.tsv'),encoding='utf-8'),delimiter='\t'))[1:]
print("gap module count:",len(set(x[0] for x in r)))
print("status:",collections.Counter(x[4] for x in r))
print("fill:",collections.Counter(x[5] for x in r))
print("scheme rows:",sum(1 for x in r if x[8]=='YES'))
print("scheme modules:",len(set(x[0] for x in r if x[8]=='YES')))
print("\nTOP 20 modules by gap:")
for m,n in collections.Counter(x[0] for x in r).most_common(20):
    f=sum(1 for x in r if x[0]==m and x[5]=='GLOSSARY'); s=sum(1 for x in r if x[0]==m and x[8]=='YES')
    print(f"  {n:5d} fill={f:5d} scheme={s:3d}  {m}")
print("\nNO_TR_FILE modules:",sorted(set(x[0] for x in r if x[4]=='NO_TR_FILE')))
