"""Check the four local Proton sources/candidates without modifying them."""
import hashlib
import json
from pathlib import Path

root = Path('/home/reidsurmeier/risd-godot-ingestion/proton')
variants = {
    '20260811121459': 'candidate-120k-rerun',
    '20260811122415': 'candidate-120k',
    '20260811123051': 'candidate-120k',
    '20260820133334': 'prototype',
}
rows = []
for scan, variant in variants.items():
    directory = root / scan
    manifest = json.loads((directory / variant / 'manifest.json').read_text())
    hashes = {}
    for key, suffix in [('obj', 'obj'), ('mtl', 'mtl'), ('texture', 'jpg')]:
        path = directory / f'{scan}.{suffix}'
        with path.open('rb') as stream:
            hashes[suffix] = hashlib.file_digest(stream, 'sha256').hexdigest()
        assert hashes[suffix] == manifest['source'][key]['sha256'], path
    candidate = directory / variant / f'proton-scan-{scan}.glb'
    hashes['glb'] = hashlib.sha256(candidate.read_bytes()).hexdigest()
    assert hashes['glb'] == manifest['derived']['glb']['sha256'], candidate
    rows.append({'id': scan, 'variant': variant, 'hashes': hashes})
local = Path('modules/sculpture_viewer/prototype_157/bearded-candidate.glb')
assert hashlib.sha256(local.read_bytes()).hexdigest() == rows[2]['hashes']['glb']
print(json.dumps({'source_and_candidate_hashes_match': True, 'scans': rows}, indent=2))
