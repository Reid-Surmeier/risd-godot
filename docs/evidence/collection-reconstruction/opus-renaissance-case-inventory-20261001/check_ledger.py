"""Verify ledger.json against the files beside it: counts, identity flags, built-versus-missing, catalogue fields and every hash.
python3 check_ledger.py            exit 0 when everything holds, 1 otherwise
python3 check_ledger.py --self-test   also proves five tampered ledgers are caught"""
import copy, hashlib, json, sys
from pathlib import Path
here = Path(__file__).parent
sha = lambda p: hashlib.sha256(Path(p).read_bytes()).hexdigest()
VIDEO = Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion/verified/IMG_6383.MOV')

def problems(ledger, hashes=True):
    out = []; bad = lambda ok, what: None if ok else out.append(what)
    objects = ledger['objects']; by = {o['slot']: o for o in objects}
    bad(len(objects) == 18 and len(by) == 18, 'expected 18 distinct slots')
    count = lambda s: sum(o['status'] == s for o in objects)
    bad((count('confirmed'), count('probable'), count('unmatched'), count('already-built')) == (15, 1, 1, 1), 'status counts must be 15 confirmed, 1 probable, 1 unmatched, 1 already built')
    bad(by['R18']['status'] == 'probable' and by['R12']['status'] == 'unmatched' and by['R07']['status'] == 'already-built', 'R18 probable, R12 unmatched, R07 already built')
    bad([o['slot'] for o in objects if o['built_in_root']] == ['R07'], 'only R07 is built in the root')
    bad(not any(c['built_in_root'] for c in ledger['cases']) and len(ledger['cases']) == 5, 'five cases, none built')
    holds = {c['id']: c['holds'] for c in ledger['cases']}
    bad(len(holds['case A']) == 6 and len(holds['case B']) == 5, 'case A holds 6, case B holds 5')
    bad(sorted(s for c in ledger['cases'] for s in c['holds']) == sorted(o['slot'] for o in objects if o['group'] in ('case A', 'case B') or o['slot'] in ('R04', 'R05', 'R06')), 'case contents must agree with object groups')
    walls = {w: [o['slot'] for o in objects if o['wall'] == w] for w in ('south', 'west', 'north', 'east')}
    bad({w: len(v) for w, v in walls.items()} == {'south': 2, 'west': 3, 'north': 2, 'east': 11}, 'wall counts must be south 2, west 3, north 2, east 11')
    bad(not ledger['all_objects_complete'] and not ledger['geometry_installed'] and not ledger['metric_calibration'], 'no completion, installation or calibration claim')
    bad(all(not o['placement_accepted'] and not o['unlisted_dimensions_accepted'] for o in objects), 'no placement or unlisted dimension is accepted')
    frames = {'frames/' + f['kept_file']: f for f in json.loads((here / 'frames/manifest.json').read_text())['frames']}
    for o in objects:
        s = o['slot']
        bad(o['seen_seconds'] and len(o['source_frames']) == len(o['seen_seconds']), f'{s}: source frames')
        for f in o['source_frames']:
            bad(f['kept_file'] in frames and frames[f['kept_file']]['png_sha256'] == f['png_sha256'], f"{s}: frame {f['kept_file']} not in the decode manifest")
            if hashes: bad((here / f['kept_file']).exists() and sha(here / f['kept_file']) == frames[f['kept_file']]['kept_sha256'], f"{s}: frame {f['kept_file']} hash")
        if o['status'] in ('confirmed', 'probable'):
            bad(o.get('accession') and o.get('dimensions') is not None and o.get('photos'), f'{s}: a matched object needs accession, catalogue dimensions and photographs')
            rows = [x for x in json.loads((here / o['api_json']).read_text()) if x['objectNumber'] == o['accession']]
            bad(len(rows) == 1 and rows[0]['id'] == o['catalogue_id'] and rows[0]['dimensions'] == o['dimensions'] and rows[0]['url'] == o['link'], f'{s}: catalogue fields differ from {o["api_json"]}')
            bad((here / o['comparison_sheet']).exists(), f'{s}: comparison sheet missing')
            if hashes:
                bad(sha(here / o['api_json']) == o['api_json_sha256'], f'{s}: api json hash')
                for p in o['photos']: bad(sha(here / 'photos' / p['file']) == p['sha256'], f"{s}: photo {p['file']} hash")
        else:
            bad('accession' not in o and 'dimensions' not in o and 'title' not in o, f'{s}: an unmatched or root-built object must not carry catalogue fields')
    bad(by['R12']['label_read'] and by['R12']['basis'] == 'label only', 'R12 rests on its label only')
    bad(ledger['next_asset']['slot'] == 'R04' and all((here / f).exists() for f in ledger['next_asset']['muse_references'] + ledger['next_asset']['source_frames']), 'next asset files')
    if hashes:
        bad(not VIDEO.exists() or sha(VIDEO) == ledger['video_sha256'], 'source video hash')
        manifest = here / 'SHA256.json'
        if manifest.exists():
            for name, value in json.loads(manifest.read_text()).items(): bad((here / name).exists() and sha(here / name) == value, f'SHA256.json: {name}')
    return out

ledger = json.loads((here / 'ledger.json').read_text())
found = problems(ledger)
print('ledger:', 'ok' if not found else found)
status = 1 if found else 0
if '--self-test' in sys.argv:
    def tamper(change):
        t = copy.deepcopy(ledger); change(t); return problems(t, hashes=False)
    tests = {
        'probable promoted': lambda t: t['objects'][17].update(status='confirmed'),
        'label-only book given an accession': lambda t: t['objects'][11].update(accession='00.000', title='x', dimensions='1 cm'),
        'wrong catalogue dimension': lambda t: t['objects'][3].update(dimensions='Height: 150 cm'),
        'object dropped from case A': lambda t: t['cases'][3]['holds'].pop(),
        'room marked complete': lambda t: t.update(all_objects_complete=True),
    }
    for name, change in tests.items():
        caught = tamper(change); print(f'self-test {name}:', 'caught' if caught else 'MISSED')
        if not caught: status = 1
sys.exit(status)
