"""Verify that only the byte-preserved upstream SDK leaves authored-style lint."""
import hashlib
import json
import re
import shlex
import subprocess
from pathlib import Path

old = subprocess.check_output(['git', 'show', '244be7e2:scripts/check.sh'], text=True)
new = Path('scripts/check.sh').read_text()
def targets(script):
    command = re.search(r'^  gdlint \$\((find [^\n]+)\)$', script, re.M).group(1)
    return set(subprocess.check_output(shlex.split(command), text=True).splitlines())
before, after = targets(old), targets(new)
sdk = './modules/sketchbook/mixbox/mixbox.gd'
assert before - after == {sdk} and not after - before
records = []
for name, expected in [
    ('mixbox.gd', '5d10a98ffb8fab237fea7dbd03e2bb0bf95edca5357fa75429097776a8eb0a14'),
    ('mixbox.res', '930c0ee996d7a4aaecbfd53476573a3a0f95947a672e4897132b8883066763bb'),
    ('LICENSE', '4e4b6a193eee2fce7429988137b143b3be38cdd1e6fb9cfdca4507aa182254f3'),
]:
    path = 'modules/sketchbook/mixbox/' + name
    data = Path(path).read_bytes()
    assert data == subprocess.check_output(['git', 'show', '55e7c3b7:' + path])
    assert hashlib.sha256(data).hexdigest() == expected
    records.append({'file': path, 'sha256': expected, 'main_provenance_match': True})
native = subprocess.run(['godot', '--headless', '--path', '.', '--check-only',
                         '--script', 'res://modules/sketchbook/mixbox/mixbox.gd'],
                        capture_output=True, text=True)
assert native.returncode == 0 and 'ERROR' not in native.stdout + native.stderr
print(json.dumps({'before_targets': len(before), 'after_targets': len(after),
                  'only_removed': sorted(before - after), 'sdk_records': records,
                  'native_sdk': 'PASS', 'native_output': native.stdout}, indent=2))
