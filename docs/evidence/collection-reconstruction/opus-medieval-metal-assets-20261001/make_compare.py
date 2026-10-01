"""Comparison sheets: official RISD photographs and native IMG_6382 crops (accepted case review, read only) beside the Godot views check.gd wrote.
python3 make_compare.py [root checkout]"""
import sys
from pathlib import Path
from PIL import Image, ImageDraw
here = Path(__file__).parent
review = Path(sys.argv[1] if len(sys.argv) > 1 else '/home/reidsurmeier/orca/workspaces/risd-godot/collection-reconstruction') / 'docs/evidence/collection-reconstruction/opus-medieval-case-inventory-20261001'
H = 760
SHEETS = {  # object: official photographs, then [frame seconds, crop box] from the review's frames/
    'monstrance': (['monstrance-40002-zoom-0', 'monstrance-40002-zoom-2'], [('105.70', (195, 790, 335, 1250)), ('107.30', (455, 780, 635, 1315))]),
    'beaker': (['communion-beaker-1992051-zoom-0'], [('105.70', (510, 1150, 645, 1345)), ('107.30', (835, 1040, 950, 1215))]),
    'pyx': (['pyx-30011-zoom-1', 'pyx-30011-zoom-0'], [('105.70', (415, 1125, 525, 1240)), ('107.30', (650, 1095, 745, 1185))]),
    'pax': (['pax-52002-zoom-0', 'pax-52002-zoom-1'], [('102.20', (465, 940, 585, 1065)), ('107.30', (615, 755, 700, 840))]),
    'pax-on-stand': ([], [('102.20', (440, 900, 620, 1230)), ('103.70', (700, 880, 880, 1240)), ('105.70', (690, 780, 830, 1010))]),
}
def tile(im, label):
    im = im.convert('RGB'); im = im.resize((max(1, round(im.width * H / im.height)), H), Image.LANCZOS)
    t = Image.new('RGB', (im.width, H + 22), 'white'); t.paste(im, (0, 22)); ImageDraw.Draw(t).text((3, 5), label, fill='black'); return t
for name, (photos, crops) in SHEETS.items():
    ts = [tile(Image.open(review / 'photos' / f'{p}.jpg'), f'RISD official {p}') for p in photos]
    ts.append(tile(Image.open(here / f'views-{name}.png'), 'LOW POLYGON, Godot llvmpipe: front | object left side | rear | three-quarter'))
    ts += [tile(Image.open(review / 'frames' / f'IMG_6382-{t}.jpg').crop(b), f'SOURCE IMG_6382 {float(t):.2f}s') for t, b in crops]
    s = Image.new('RGB', (sum(t.width for t in ts) + 6 * len(ts), H + 22), 'white'); x = 0
    for t in ts: s.paste(t, (x, 0)); x += t.width + 6
    s.save(here / f'compare-{name}.jpg', quality=90); print(name, s.size)
