"""
MM localization uygulayici.

Excel sozlugunu (Yatirim / Katilim sekmeleri) WebUI'nin MM ekran JSON'larina uygular.
FX PR 11994 (3de0ddaec) deseni: base -tr.json Yatirim ifadesiyle doldurulur,
ayrisan key'ler icin <modul>-katilim.tr.json + <modul>-yatirim.tr.json yazilir.

Satir bazli deger degistirir -> key sirasi, // yorumlari, BOM, girinti korunur.

Kullanim:  python apply-mm.py            (dry-run)
           python apply-mm.py --apply    (dosyalari yazar)
"""
import os
import sys
import csv
import re
import io
import contextlib
import collections

SP = os.path.join(os.environ['LOCALAPPDATA'], 'Temp', 'claude',
                  'c--Users-Treasy-70-source-repos--ai-agent',
                  'b20aba7c-6c26-434f-880c-ab47ad8c0df3', 'scratchpad')
ROOT = os.path.join('C:' + os.sep, 'Users', 'Treasy-70', 'source', 'repos', 'NetTrex.Web.UI',
                    'Code', 'Web', 'UI', 'Trex.WebUI', 'wwwroot', 'js', 'localization')
OUTDATA = os.path.join('C:' + os.sep, 'Users', 'Treasy-70', 'source', 'repos', '.ai-agent',
                       'outputs', '2026-09-10-Localization-Excel-Uyarlama', 'data')

sys.path.insert(0, SP)
with contextlib.redirect_stdout(io.StringIO()):
    from inv import loadj

DRY = '--apply' not in sys.argv


def tsv(name):
    return list(csv.reader(open(os.path.join(SP, name), encoding='utf-8'), delimiter='\t'))


Y = {r[0]: r[1] for r in tsv('Yat_r_m_Bankas_.tsv')[1:] if len(r) > 1 and r[0]}
K = {r[0]: r[1] for r in tsv('Kat_l_m_Bankas_.tsv')[1:] if len(r) > 1 and r[0]}

# repo-transactions BILEREK YOK: key'leri dgFiRepo* -> FI ekrani, MM work item'i degil.
TARGETS = [
    ('pages/treasury/money-market', 'money-market'),
    ('pages/treasury/interbank-loan', 'interbank-loan'),
    ('pages/treasury/issue-bond', 'issue-bond'),
    ('pages/treasury/issue-bond-revaluation', 'issue-bond-revaluation'),
    ('pages/treasury/tawarruq', 'tawarruq'),
    ('pages/definitions/product-types', 'mm-product'),
    ('pages/reports/money-market', 'money-market-revaluation-report'),
    ('pages/reports/interbank-loan', 'interbank-loan-revaluation-report'),
    ('pages/reconciliation/platform-reconciliation', 'external-mm-stp'),
]


def override(key, en):
    """Sozlukteki karsilik key baglamiyla celisen satirlar. (yatirim, katilim) dondurur."""
    # sozluk 'Rate' -> 'Kur' der (doviz kuru). Bu key'ler faiz orani.
    if en == 'Rate' and re.search(r'(InterestRate|-Rate)$', key):
        return ('Faiz Oranı', 'Getiri Oranı')
    # sozluk 'No' -> 'Hayır' der (boolean). Burada 'No' = numara.
    if en.lower() == 'no' and 'AccountNumber' in key:
        return ('Hesap Numarası', 'Hesap Numarası')
    return None


# "key": "value"[,]   -> deger grubu escape'li karakterleri de yakalar
VAL = re.compile(r'^(\s*")([^"]+)("\s*:\s*")((?:[^"\\]|\\.)*)("\s*,?\s*)$')


def esc(s):
    return s.replace('\\', '\\\\').replace('"', '\\"')


def main():
    rep = collections.Counter()
    log = []
    schemes = collections.defaultdict(dict)

    for d, m in TARGETS:
        dd = os.path.join(ROOT, *d.split('/'))
        pen = os.path.join(dd, m + '-en.json')
        ptr = os.path.join(dd, m + '-tr.json')
        en, err = loadj(pen)
        if err:
            print('PARSE ERROR', pen, err)
            return 1

        lines = open(ptr, encoding='utf-8').read().split('\n')
        out = []
        changed = 0
        for ln in lines:
            mo = VAL.match(ln)
            if not mo:
                out.append(ln)
                continue
            pre, key, mid, cur, post = mo.groups()
            ev = (en or {}).get(key)
            if ev is None:
                out.append(ln)
                rep['tr_only_key'] += 1
                continue
            ov = override(key, ev)
            if ov:
                ty, tk = ov
                src = 'OVERRIDE'
            else:
                ty, tk = Y.get(ev), K.get(ev)
                src = 'GLOSSARY'
                if ty is None:
                    out.append(ln)
                    rep['no_glossary'] += 1
                    continue
            if ty != tk:
                schemes[(d, m)][key] = (ty, tk)
            if cur == ty:
                out.append(ln)
                rep['already_ok'] += 1
                continue
            out.append(pre + key + mid + esc(ty) + post)
            rep['changed'] += 1
            changed += 1
            log.append(['%s/%s' % (d, m), key, ev, cur, ty, src])

        if not DRY:
            open(ptr, 'w', encoding='utf-8', newline='').write('\n'.join(out))
        print('%-38s %4d satir %s' % (m, changed, 'YAZILDI' if not DRY else '(dry)'))

    print()
    print(dict(rep))

    for (d, m), kv in sorted(schemes.items()):
        dd = os.path.join(ROOT, *d.split('/'))
        for scheme, idx in (('katilim', 1), ('yatirim', 0)):
            items = list(kv.items())
            body = ['﻿{',
                    '  //%s - %s scheme overrides----------------------------------------' % (m, scheme)]
            for i, (k, v) in enumerate(items):
                body.append('  "%s": "%s"%s' % (k, esc(v[idx]), ',' if i < len(items) - 1 else ''))
            body.append('}')
            p = os.path.join(dd, '%s-%s.tr.json' % (m, scheme))
            if not DRY:
                open(p, 'w', encoding='utf-8', newline='').write('\n'.join(body))
            print('  %-6s %-70s %2d key' % ('YAZDI' if not DRY else '(dry)',
                                            os.path.relpath(p, ROOT).replace(os.sep, '/'), len(kv)))

    with open(os.path.join(OUTDATA, 'mm-applied.tsv'), 'w', encoding='utf-8', newline='') as f:
        c = csv.writer(f, delimiter='\t')
        c.writerow(['module', 'key', 'en', 'old_tr', 'new_tr', 'source'])
        c.writerows(log)
    print('\nlog:', len(log), 'satir ->', os.path.join(OUTDATA, 'mm-applied.tsv'))
    return 0


if __name__ == '__main__':
    sys.exit(main())
