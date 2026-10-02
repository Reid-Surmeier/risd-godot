"""Pull the 2020 caption for each matched accession out of the root's export of the spring 2020 faculty planning document (read only).
Identity corroboration only: the document is from 2020 and is not evidence of where anything stands today."""
import hashlib, json
from pathlib import Path
here = Path(__file__).parent
F = Path('/tmp/collection-research-on-view.txt'); lines = F.read_text(encoding='utf-8-sig').splitlines()
out = {'source': 'RISD Museum faculty planning document, spring 2020, exported by the root to /tmp/collection-research-on-view.txt (read only)', 'sha256': hashlib.sha256(F.read_bytes()).hexdigest(),
       'use': 'Historical corroboration of identity only. It is from 2020 and says nothing about where an object stands today.', 'entries': {}, 'absent': []}
for o in json.loads((here / 'ledger.json').read_text())['objects']:
    a = o.get('accession')
    if not a: continue
    hit = [i for i, l in enumerate(lines) if l.strip() == a]
    if hit:
        i = hit[0]
        out['entries'][a] = {'slot': o['slot'], 'line': i + 1, 'location_2020': ' / '.join(dict.fromkeys(l.strip() for l in lines[max(0, i - 14):i] if l.strip() in ('5th floor', 'European galleries'))),
                             'caption': [l.strip() for l in lines[max(0, i - 6):i + 1] if l.strip()]}
    else: out['absent'].append({'slot': o['slot'], 'accession': a})
(here / 'historical-2020-captions.json').write_text(json.dumps(out, indent=1, ensure_ascii=False) + '\n')
print(len(out['entries']), 'found; absent', [x['accession'] for x in out['absent']])
