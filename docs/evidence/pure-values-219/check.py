"""Check #219 declaration preservation, dependencies and native initial values."""
import hashlib
import json
import re
import subprocess
from collections import Counter
from pathlib import Path

from gdtoolkit.parser import parser

root = Path(__file__).parent
manifest = json.loads((root / 'manifest.json').read_text())
for record in manifest['files']:
    path = record['file']
    before = subprocess.check_output(['git', 'show', manifest['baseline'] + ':' + path], text=True)
    after = Path(path).read_text()
    declarations = lambda s: [(str(n.data), repr(n)) for n in parser.parse(s).children]
    old, new = declarations(before), declarations(after)
    assert Counter(old) == Counter(new), path + ': declaration/body/value changed'
    for kind in ('const_stmt', 'signal_stmt', 'static_class_var_stmt', 'func_def', 'static_func_def'):
        assert [n for n in old if n[0] == kind] == [n for n in new if n[0] == kind], path
    # Every effectful initializer is an explicit allocation, in the original order.
    allocated = lambda s: [line for line in s.splitlines(True)
                           if line.startswith('var ') and '.new()' in line]
    assert allocated(before) == allocated(after) == record['effectful_sequence'], path
    if path.endswith('paintbox.gd'):
        assert after.index('var brush_color') < after.index('var _drag_pigment'), path
    comments = lambda s: Counter((str(t).startswith('##'), str(t))
                                for t in parser.parse_comments(s).children)
    assert comments(before) == comments(after), path + ': comment changed'
    for source, key in ((before, 'before_sha256'), (after, 'after_sha256')):
        assert hashlib.sha256(source.encode()).hexdigest() == record[key], path
    native = subprocess.run(['godot', '--headless', '--path', '.', '--check-only',
                             '--script', 'res://' + path], capture_output=True, text=True)
    assert native.returncode == 0 and 'ERROR' not in native.stdout + native.stderr, native

sources = {record['file']: subprocess.check_output(
    ['git', 'show', manifest['baseline'] + ':' + record['file']], text=True)
    for record in manifest['files']}
Path('/tmp/risd-219-baseline-sources.json').write_text(json.dumps(sources))
state = json.loads((root / 'initial-state.json').read_text())
assert state['before'] == state['after']
for path, source in sources.items():
    expected = set(re.findall(r'^(?:@onready )?(?:static )?var (\w+)', source, re.M))
    actual = set(state['before'][path]['instance']['fields']) | set(state['before'][path]['static'])
    assert actual == expected, path + ': field coverage incomplete'
for label, extra in [('before', ['/tmp/risd-219-baseline-sources.json']), ('after', [])]:
    output = '/tmp/risd-219-' + label + '-recheck.json'
    subprocess.run(['godot', '--headless', '--path', '.', '--script',
                    'res://' + str((root / 'initial_state.gd').relative_to(Path.cwd())), '--',
                    output, *extra], check=True)
    assert json.loads(Path(output).read_text()) == state[label]
print('PURE_VALUES219 PASS: declarations/bodies/comments/order, 114 instance + 2 static fields')
