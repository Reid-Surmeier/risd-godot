"""Review tool: static, read-only checks of root's full app against my own scratch build of the same sources.

    python3 full_app_static.py <full app folder> <my prepared retained-Hall project> <out.json>

Hashes only. It runs nothing, so it says nothing about how the app looks or behaves.
Exit 1 if a Hall file differs from the main-build reference or the room scripts differ beyond the path prefix and the bake file's extension.
"""
import difflib, hashlib, json, sys
from pathlib import Path

app, mine, out = Path(sys.argv[1]), Path(sys.argv[2]), Path(sys.argv[3])
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
main = json.loads((mine / 'main-build-source.json').read_text())
bad = [p for p, h in main['source_sha256'].items() if not (app / p).exists() or sha(app / p) != h]
rooms = app / 'collection_rooms'
report = {'full_app': str(app), 'hall_source_tip': main['source_tip'], 'hall_files_listed': len(main['source_sha256']),
          'hall_files_hash_equal': len(main['source_sha256']) - len(bad), 'changed_or_missing': bad,
          'geometry_equals_my_build': sha(rooms / 'geometry.json') == sha(mine / 'geometry.json'), 'scripts': {}, 'bake': {}}
for name in ['remodel_room.gd', 'remodel_review.gd', 'remodel_bake.gd', 'retained_hall_room.gd']:
    theirs = (rooms / name).read_text().replace('res://collection_rooms/', 'res://').replace('addition_baked/room.tres', 'addition_baked/room.lmbake').splitlines()
    ours = (mine / name).read_text().splitlines()
    delta = [l for l in difflib.unified_diff(ours, theirs, lineterm='', n=0) if l[:1] in '+-' and l[:3] not in ('+++', '---')]
    report['scripts'][name] = {'sha256': sha(rooms / name), 'lines_differing_after_prefix': len(delta), 'sample': delta[:8]}
for f in sorted((rooms / 'addition_baked').glob('*')):
    report['bake'][f.name] = {'bytes': f.stat().st_size, 'sha256': sha(f)}
evidence = app / 'native-evidence'
report['native_evidence'] = {f.name: sha(f) for f in sorted(evidence.glob('*'))} if evidence.exists() else {}
out.write_text(json.dumps(report, indent=1) + '\n')
ok = not bad and report['geometry_equals_my_build'] and all(v['lines_differing_after_prefix'] == 0 for v in report['scripts'].values())
print(json.dumps({k: report[k] for k in ['hall_files_listed', 'hall_files_hash_equal', 'geometry_equals_my_build']}), {k: v['lines_differing_after_prefix'] for k, v in report['scripts'].items()}, sorted(report['bake']))
sys.exit(0 if ok else 1)
