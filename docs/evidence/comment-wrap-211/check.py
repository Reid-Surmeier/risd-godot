"""Check #211's unchanged code and ordered comment words against the fixed point."""
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
    # Entire executable line sequence must stay byte-identical.
    code = lambda s: [line for line in s.splitlines() if not line.lstrip().startswith('#')]
    assert code(old) == code(new), path + ': executable lines changed'
    check_tree_invariant(old, new)
    words = lambda s: [word for token in parser.parse_comments(s).children
                       for word in str(token).lstrip('#').split()]
    assert words(old) == words(new), path + ': ordered comment words changed'
    assert hashlib.sha256(old.encode()).hexdigest() == record['before_sha256'], path
    assert hashlib.sha256(new.encode()).hexdigest() == record['after_sha256'], path
    results.append({'file': path, 'code_tree': 'PASS', 'code_lines': 'PASS',
                    'ordered_comment_words': 'PASS', 'hashes': 'PASS'})
print(json.dumps({'baseline': manifest['baseline'], 'files': results}, indent=2))
