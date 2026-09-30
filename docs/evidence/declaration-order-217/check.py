"""Verify #217 moves declarations without changing bodies or initializer order."""
import hashlib
import json
import subprocess
from collections import Counter
from pathlib import Path

from gdtoolkit.parser import parser

root = Path(__file__).parent
manifest = json.loads((root / 'manifest.json').read_text())
results = []


def declarations(source):
    return [(str(node.data), repr(node),
             any(True for _ in node.find_data('expr')))
            for node in parser.parse(source, gather_metadata=True).children]


for record in manifest['files']:
    path = record['file']
    before = subprocess.check_output(['git', 'show', manifest['baseline'] + ':' + path], text=True)
    after = Path(path).read_text()
    old, new = declarations(before), declarations(after)
    assert Counter(old) == Counter(new), path + ': declaration or function body changed'
    for kind in ('const_stmt', 'signal_stmt', 'static_class_var_stmt',
                 'func_def', 'static_func_def'):
        assert [d for d in old if d[0] == kind] == [d for d in new if d[0] == kind], path
    initialized = lambda ds: [d for d in ds if d[0] == 'class_var_stmt' and d[2]]
    assert initialized(old) == initialized(new), path + ': instance initializer sequence changed'
    comments = lambda s: Counter((str(t).startswith('##'), str(t))
                                for t in parser.parse_comments(s).children)
    assert comments(before) == comments(after), path + ': comment text/type changed'
    for source, key in ((before, 'before_sha256'), (after, 'after_sha256')):
        assert hashlib.sha256(source.encode()).hexdigest() == record[key], path
    native = subprocess.run(['godot', '--headless', '--path', '.', '--check-only',
                             '--script', 'res://' + path], capture_output=True, text=True)
    assert native.returncode == 0 and 'ERROR' not in native.stdout + native.stderr, native
    results.append({'file': path, 'declarations_bodies_comments_values_order': 'PASS',
                    'native_parse': 'PASS'})
print(json.dumps({'baseline': manifest['baseline'], 'files': results}, indent=2))
