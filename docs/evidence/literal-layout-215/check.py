"""Check exact native String bytes and preserved code for #215's constant decomposition."""
import hashlib
import json
import subprocess
from pathlib import Path

from gdtoolkit.formatter.safety_checks import check_tree_invariant
from gdtoolkit.parser import parser

root = Path(__file__).parent
manifest = json.loads((root / 'manifest.json').read_text())
results = []
for record in manifest['files']:
    path = record['file']
    old = subprocess.check_output(['git', 'show', manifest['baseline'] + ':' + path], text=True)
    new = Path(path).read_text()
    collapsed = new
    for change in reversed(record['changes']):
        assert collapsed.count(change['expression']) == 1, path
        collapsed = collapsed.replace(change['expression'], change['literal'], 1)
    assert collapsed == old, path + ': changes outside named constant expressions'
    check_tree_invariant(old, collapsed)
    comments = lambda s: [(str(t).startswith('##'), word)
                         for t in parser.parse_comments(s).children
                         for word in str(t).lstrip('#').split()]
    assert comments(old) == comments(new), path + ': comments changed'
    assert hashlib.sha256(old.encode()).hexdigest() == record['before_sha256'], path
    assert hashlib.sha256(new.encode()).hexdigest() == record['after_sha256'], path
    results.append({'file': path, 'code_comments_hashes': 'PASS'})
native = subprocess.run(['godot', '--headless', '--path', '.', '--script',
                         str(root / 'strings_check.gd')], capture_output=True, text=True)
assert native.returncode == 0, native.stdout + native.stderr
assert native.stdout.count('STRING') == manifest['native_string_cases'] == 19
assert 'SCRIPT ERROR' not in native.stderr and 'ERROR:' not in native.stderr
assert len(results) == 17
print(json.dumps({'baseline': manifest['baseline'], 'files': results,
                  'native_strings': 19, 'native_output': native.stdout}, indent=2))
