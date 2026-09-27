"""Verify the real HTTP probe's captured result; never substitute fixtures for paintings."""
import json
import sys
from pathlib import Path
report = json.loads(Path(sys.argv[1]).read_text())
report = report.get('result', report)
assert report['search']['ok'], report
items = report['search']['value']['items']
assert len([item for item in items if item['category'] == 'Painting' and item['image']]) >= 2
assert len(report['rendered_hashes']) >= 2
print('two verified RISD paintings rendered through the data seam')
