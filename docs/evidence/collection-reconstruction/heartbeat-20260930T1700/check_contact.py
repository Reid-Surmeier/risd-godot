"""Runnable replay check for frozen source contact and rejected acceptance."""
import hashlib
import json
from pathlib import Path

out = Path(__file__).parent
source = json.loads((out/'contact-source-result.json').read_text())
result = json.loads((out/'contact-result.json').read_text())
visual = json.loads((out/'contact-visual-check.json').read_text())
assert source['point_world'] == result['point_world']
assert source['training_errors_px'] == result['training_errors_px']
assert not set(result['selection']['training']) & set(result['selection']['reserved'])
assert result['positive_depth'] and max(result['training_errors_px'].values()) < 2
assert result['reserved']['pose_supported'] and result['reserved']['pose_test_below4px'] >= 20
assert result['perturbation_p95_fraction_camera_distance'] > .1
assert 0 < visual['error_px'] < 8 and not result['navigation_accepted']
for path, expected in result['inputs_sha256'].items():
    assert hashlib.sha256(Path(path).read_bytes()).hexdigest() == expected, path
automation = json.loads((out/'automation-disabled.json').read_text())
assert automation['ok'] and automation['result']['automation']['enabled'] is False
print('Frozen contact, reserved separation, live input hashes and disabled receipt pass; no physical acceptance.')
