"""Verify #213's layout changes against the fixed point, including frozen files."""
import hashlib
import json
import re
import subprocess
from pathlib import Path

from gdtoolkit.formatter.safety_checks import check_tree_invariant
from gdtoolkit.parser import parser

root = Path(__file__).parent
manifest = json.loads((root / 'manifest.json').read_text())
results = []
# Preserve quoted tokens exactly, removing only comments, whitespace and continuations.
tokens = re.compile(r'''"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|\#[^\n]*|\\\n|\s+|.''')
def executable(source):
    return [t for t in tokens.findall(source)
            if not t.startswith('#') and not t.isspace() and t != '\\\n']

def comments(source):
    return [(str(t).startswith('##'), word)
            for t in parser.parse_comments(source).children
            for word in str(t).lstrip('#').split()]

for record in manifest['files']:
    path = record['file']
    old = subprocess.check_output(['git', 'show', manifest['baseline'] + ':' + path], text=True)
    new = Path(path).read_text()
    check_tree_invariant(old, new)
    assert executable(old) == executable(new), path + ': executable tokens changed'
    assert comments(old) == comments(new), path + ': comment words/types changed'
    assert hashlib.sha256(old.encode()).hexdigest() == record['before_sha256'], path
    assert hashlib.sha256(new.encode()).hexdigest() == record['after_sha256'], path
    if path.endswith('playground_page/playground_page.gd'):
        assert len(new.splitlines()) <= 1000
    results.append({'file': path, 'tree_tokens_comments_hashes': 'PASS'})
assert len(results) == 9
print(json.dumps({'baseline': manifest['baseline'], 'files': results}, indent=2))
