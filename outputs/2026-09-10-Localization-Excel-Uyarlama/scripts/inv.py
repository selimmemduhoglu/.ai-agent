import os,re,json,glob,csv,collections
BS=chr(92)
SP=os.path.join(os.environ['LOCALAPPDATA'],'Temp','claude','c--Users-Treasy-70-source-repos--ai-agent','b20aba7c-6c26-434f-880c-ab47ad8c0df3','scratchpad')
ROOT=os.path.join('C:'+os.sep,'Users','Treasy-70','source','repos','NetTrex.Web.UI','Code','Web','UI','Trex.WebUI','wwwroot','js','localization')

def strip_comments(s):
    out=[];i=0;n=len(s);instr=False;esc=False
    while i<n:
        c=s[i]
        if instr:
            out.append(c)
            if esc: esc=False
            elif c==BS: esc=True
            elif c=='"': instr=False
            i+=1; continue
        if c=='"': instr=True; out.append(c); i+=1; continue
        if c=='/' and i+1<n and s[i+1]=='/':
            while i<n and s[i] not in '\r\n': i+=1
            continue
        if c=='/' and i+1<n and s[i+1]=='*':
            i+=2
            while i+1<n and not (s[i]=='*' and s[i+1]=='/'): i+=1
            i+=2; continue
        out.append(c); i+=1
    return ''.join(out)

def rmtrail(s):
    return re.sub(r',(\s*[}\]])',r'\1',s)

def loadj(p):
    raw=open(p,encoding='utf-8-sig').read()
    try: return json.loads(raw),None
    except Exception: pass
    t=rmtrail(strip_comments(raw))
    try: return json.loads(t),None
    except Exception as e: return None,str(e)

groups=collections.defaultdict(dict)
for p in glob.glob(os.path.join(ROOT,'**','*.json'),recursive=True):
    rel=os.path.relpath(p,ROOT).replace(BS,'/'); base=rel[:-5]
    m=re.match(r'^(.*?)(?:[-.](en|tr))$',base)
    if m: groups[m.group(1)][m.group(2)]=p
    else: groups[base]['raw']=p

bad=[]; data={}
for g,v in groups.items():
    d={}
    for lang,p in v.items():
        o,err=loadj(p)
        if err: bad.append((p,err))
        d[lang]=o or {}
    data[g]=d
print("PARSE ERRORS:",len(bad))
for p,e in bad: print("  ",p,"|",e[:90])

rows=[]
for g in sorted(data):
    d=data[g]
    if 'en' not in d and 'tr' not in d: continue
    en=d.get('en',{}); tr=d.get('tr',{})
    hasTR = 'tr' in d
    for k,v in en.items():
        if not hasTR: rows.append((g,k,v,'','NO_TR_FILE'))
        elif k not in tr: rows.append((g,k,v,'','NO_TR_KEY'))
        elif isinstance(tr[k],str) and isinstance(v,str) and tr[k].strip()==v.strip(): rows.append((g,k,v,tr[k],'UNTRANSLATED'))
        elif not str(tr[k]).strip(): rows.append((g,k,v,tr[k],'EMPTY_TR'))
    for k,v in tr.items():
        if k not in en: rows.append((g,k,'',v,'NO_EN_KEY'))
tot=sum(len(data[g].get('en',{})) for g in data)
print("\nEN keys total:",tot,"| TR keys total:",sum(len(data[g].get('tr',{})) for g in data))
print("modules:",len([g for g in data if 'en' in data[g] or 'tr' in data[g]]))
print("\nSTATUS COUNTS:",collections.Counter(r[4] for r in rows))
with open(os.path.join(SP,'gaps.tsv'),'w',encoding='utf-8',newline='') as f:
    w=csv.writer(f,delimiter='\t'); w.writerow(['module','key','en','tr','status']); w.writerows(rows)
print("wrote gaps.tsv rows",len(rows))
