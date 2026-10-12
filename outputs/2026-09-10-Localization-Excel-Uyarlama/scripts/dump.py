import zipfile, re, os, xml.etree.ElementTree as ET
p = r"C:\Users\Treasy-70\source\repos\.ai-agent\imports\localization-dictionary-en-tr 1.xlsx"
out = r"C:\Users\Treasy-70\AppData\Local\Temp\claude\c--Users-Treasy-70-source-repos--ai-agent\b20aba7c-6c26-434f-880c-ab47ad8c0df3\scratchpad"
z = zipfile.ZipFile(p)
N='{http://schemas.openxmlformats.org/spreadsheetml/2006/main}'
R='{http://schemas.openxmlformats.org/officeDocument/2006/relationships}'
ss=[]
for si in ET.fromstring(z.read('xl/sharedStrings.xml')):
    ss.append(''.join(t.text or '' for t in si.iter(N+'t')))
wb=ET.fromstring(z.read('xl/workbook.xml'))
rels={x.get('Id'):x.get('Target') for x in ET.fromstring(z.read('xl/_rels/workbook.xml.rels'))}
def colnum(ref):
    c=re.match(r'([A-Z]+)',ref).group(1); n=0
    for ch in c: n=n*26+ord(ch)-64
    return n-1
for sh in wb.find(N+'sheets'):
    name=sh.get('name'); tgt=rels[sh.get(R+'id')]
    ws=ET.fromstring(z.read('xl/'+tgt))
    rows=[]
    for row in ws.iter(N+'row'):
        cells={}
        for c in row.findall(N+'c'):
            v=c.find(N+'v'); t=c.get('t')
            if t=='inlineStr':
                isx=c.find(N+'is'); val=''.join(x.text or '' for x in isx.iter(N+'t')) if isx is not None else ''
            elif v is None: val=''
            elif t=='s': val=ss[int(v.text)]
            else: val=v.text or ''
            cells[colnum(c.get('r'))]=val.replace('\t',' ').replace('\n','\n')
        if cells:
            mx=max(cells)
            rows.append('\t'.join(cells.get(i,'') for i in range(mx+1)))
        else: rows.append('')
    fn=os.path.join(out, re.sub(r'[^A-Za-z0-9]','_',name)+'.tsv')
    open(fn,'w',encoding='utf-8').write('\n'.join(rows))
    print(name, '->', fn, 'rows=',len(rows))
