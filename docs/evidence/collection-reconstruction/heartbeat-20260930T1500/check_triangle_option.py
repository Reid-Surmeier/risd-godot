"""Run with ingestion .venv/bin/python from the repository root."""
import json
from pathlib import Path
import subprocess
import sys
import tempfile

root = Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
script = 'modules/shell/prototype/collection_reconstruction/floor_holdout.py'
with tempfile.TemporaryDirectory(prefix='triangle-option-check-', dir=root) as folder:
    folder = Path(folder)
    replay = folder/'replay'
    command = [sys.executable, script, '--output', str(replay), '--photometric']
    result = subprocess.run(command, capture_output=True, text=True)
    assert result.returncode == 0, result.stderr
    assert json.loads((replay/'result.json').read_text()) == json.loads(
        (root/'strict-floor-photometric-final/result.json').read_text())
    original = json.loads((root/'strict-floor-wide-tracks-v1/result.json').read_text())
    for name in ['wrong-source', 'query-in-training']:
        triangle = json.loads(json.dumps(original))
        if name == 'wrong-source':
            triangle['source_sha256']['images.bin'] = '0'*64
        else:
            triangle['selection']['training'].append('IMG_6380/000246.jpg')
        path = folder/(name+'.json')
        path.write_text(json.dumps(triangle))
        result = subprocess.run([sys.executable, script, '--output', str(folder/name),
            '--triangle', str(path)], capture_output=True, text=True)
        assert result.returncode != 0 and 'AssertionError' in result.stderr
        assert not (folder/name/'database.db').exists()
        assert not (folder/name/'result.json').exists()
    for name, options in [('training-query', ['--queries', 'IMG_6380/000244.jpg']),
            ('invalid-ceiling', ['--pose-ceiling', '0'])]:
        result = subprocess.run([sys.executable, script, '--output', str(folder/name)]+options,
            capture_output=True, text=True)
        assert result.returncode != 0 and 'AssertionError' in result.stderr
        assert not (folder/name/'database.db').exists()
        assert not (folder/name/'result.json').exists()
print('PASS: exact default replay; wrong model, query-trained triangle, training query and invalid mask rejected before database copy.')
