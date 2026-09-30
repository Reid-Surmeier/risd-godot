"""Prove #222 changes only the explicitly scoped identifier tokens."""
import hashlib
import json
import subprocess
from pathlib import Path

from gdtoolkit.parser import parser

root = Path(__file__).parent
manifest = json.loads((root / 'manifest.json').read_text())
for record in manifest['files']:
    path = record['file']
    before = subprocess.check_output(['git', 'show', manifest['baseline'] + ':' + path], text=True)
    after = Path(path).read_text()
    tokens = lambda source: list(parser.parse(source, gather_metadata=True).scan_values(
        lambda value: hasattr(value, 'type')))
    old, new = tokens(before), tokens(after)
    assert len(old) == len(new), path
    changed = []
    restored = after
    for previous, current in reversed(list(zip(old, new))):
        assert previous.type == current.type, path
        if str(previous) == str(current):
            continue
        assert previous.type == 'NAME', path
        assert record['mapping'][str(previous)] == str(current), path
        changed.append({'line': previous.line, 'column': previous.column,
                        'old': str(previous), 'new': str(current)})
        restored = restored[:current.start_pos] + str(previous) + restored[current.end_pos:]
    assert list(reversed(changed)) == record['tokens'], path
    assert restored == before, path + ': non-identifier bytes changed'
    for source, key in ((before, 'before_sha256'), (after, 'after_sha256')):
        assert hashlib.sha256(source.encode()).hexdigest() == record[key], path
    native = subprocess.run(['godot', '--headless', '--path', '.', '--check-only',
                             '--script', 'res://' + path], capture_output=True, text=True)
    assert native.returncode == 0 and 'ERROR' not in native.stdout + native.stderr, native
    print(path + ': exact token/byte preservation and native parse PASS')

protected = json.loads((root.parent / 'pure-values-219/source-integrity.json').read_text())
for asset in protected['assets']:
    assert hashlib.sha256(Path(asset['file']).read_bytes()).hexdigest() == asset['sha256']
for path in protected['museum_metadata_unchanged']:
    assert Path(path).read_bytes() == subprocess.check_output(
        ['git', 'show', manifest['baseline'] + ':' + path])
square = '/home/reidsurmeier/orca/workspaces/risd-godot/square-containment-173'
assert subprocess.check_output(['git', '-C', square, 'rev-parse', 'HEAD'], text=True).strip() == protected['square173_head']
assert subprocess.check_output(['git', '-C', square, 'status', '--porcelain'], text=True) == protected['square173_status']
print('IDENTIFIERS222 PASS: 11 native parses; 12 assets, museum records and square173 preserved')
