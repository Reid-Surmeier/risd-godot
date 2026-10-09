"""Two decal crops from the root's one paid Muse sheet (read only; nothing is generated or paid here).
Each crop is one whole view of the ceramic body: full silhouette width, top border to bottom border.
python3 make_decals.py [root checkout]"""
import hashlib, json, sys
from pathlib import Path
from PIL import Image
here = Path(__file__).parent
root = Path(sys.argv[1] if len(sys.argv) > 1 else '/home/reidsurmeier/orca/workspaces/risd-godot/collection-reconstruction')
sheet = root / 'image-work/collection-room-remodel/artifacts/image-generation/runs/run-2ee4b0d0613d42f31ef80703/materialized/image-01.webp'
SHEET_SHA256 = '1e3cd72922649181dc3620f6f0160182cc0c04f01628ba97e056e132958ec8ab'
# Left, top, right, bottom in the 1760 x 1440 sheet: body edges against the grey ground at mid height, lattice borders on the centre line.
BOXES = {'roundel': ('FRONT view', (58, 522, 430, 994)), 'boat': ('RIGHT SIDE view', (488, 519, 850, 994))}
sha = lambda p: hashlib.sha256(Path(p).read_bytes()).hexdigest()
assert sha(sheet) == SHEET_SHA256, 'Muse sheet changed'
image = Image.open(sheet).convert('RGB'); assert image.size == (1760, 1440)
out = {'source': str(sheet.relative_to(root)), 'source_sha256': SHEET_SHA256, 'paid_by': 'root, one Muse request, 0.01 USD; none by this worker', 'crops': {}}
for name, (view, box) in BOXES.items():
    path = here / f'decal-queens-{name}.png'
    image.crop(box).save(path)
    out['crops'][name] = {'file': path.name, 'view': view, 'box_ltrb': box, 'size': [box[2] - box[0], box[3] - box[1]], 'sha256': sha(path)}
    print(name, out['crops'][name])
(here / 'decals.json').write_text(json.dumps(out, indent=1) + '\n')
