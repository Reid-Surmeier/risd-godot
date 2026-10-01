"""Review tool: what changed between two scene dumps (dump_scene.gd), node by node.

    python3 followup_diff.py <before dump> <after dump> <out.json>

Nodes are matched on kind, look, tag and world box (1 mm). Everything unmatched is listed as removed or added.
It judges only what can be judged without a source: rooms, floors, Hall, walk regressions. The rest is a list to read.
Exit 1 if rooms differ, a floor triangle faces down, the Hall counts differ, or a walk trial that passed now fails.
"""
import json, sys
from collections import Counter

before, after = (json.load(open(p)) for p in sys.argv[1:3])
key = lambda n: (n['kind'], n['look'], n['tag'], tuple(round(v, 3) for v in n['box']))
a, b = Counter(map(key, before['nodes'])), Counter(map(key, after['nodes']))
removed, added = sorted((a - b).elements()), sorted((b - a).elements())
show = lambda k: {'kind': k[0], 'look': k[1], 'tag': k[2], 'box': list(k[3])}
walk_a, walk_b = before['walk'].get('results', {}), after['walk'].get('results', {})
regress = sorted(t for t in walk_a if walk_a[t] and not walk_b.get(t, False))
floors = after['floors']
checks = {
    'rooms equal': before['rooms'] == after['rooms'],
    'floor triangles all face up': floors['front_faces_down'] == 0 and floors['stored_normal_down'] == 0 and floors['no_normals'] == 0,
    'Hall retained meshes, work tags and files equal': all(before['hall'][k] == after['hall'][k] for k in ['retained_meshes', 'retained_work_tags', 'files_listed', 'non_import_files_hash_equal', 'position']),
    'no walk trial regressed': not regress,
    'same walk trials': sorted(walk_a) == sorted(walk_b),
}
out = {'checks': checks, 'walk_regressions': regress, 'walk_passed': [sum(map(bool, walk_a.values())), sum(map(bool, walk_b.values())), len(walk_b)],
       'floors': {k: floors[k] for k in ['meshes', 'triangles', 'front_faces_down', 'stored_normal_down', 'no_normals']}, 'hall': after['hall'],
       'unchanged_nodes': sum((a & b).values()), 'removed': [show(k) for k in removed], 'added': [show(k) for k in added]}
json.dump(out, open(sys.argv[3], 'w'), indent=1)
for name, ok in checks.items():
    print('PASS' if ok else 'FAIL', name)
print('walk', out['walk_passed'], 'regressions', regress)
print('unchanged', out['unchanged_nodes'], 'removed', len(removed), 'added', len(added))
for label, rows in [('-', removed), ('+', added)]:
    for k in rows:
        print(label, k[0], [round(v, 2) for v in k[3]], k[1][:44], k[2])
sys.exit(0 if all(checks.values()) else 1)
