"""Comparison sheets: official RISD photographs and native IMG_6382 crops (accepted case review, read only) beside the Godot views check.gd wrote.
python3 make_compare.py [root checkout]"""
import sys
from pathlib import Path
from PIL import Image, ImageDraw
here = Path(__file__).parent
review = Path(sys.argv[1] if len(sys.argv) > 1 else '/home/reidsurmeier/orca/workspaces/risd-godot/collection-reconstruction') / 'docs/evidence/collection-reconstruction/opus-medieval-case-inventory-20261001'
H = 760
SHEETS = {  # object: official photographs, then [frame seconds, crop box] from the review's frames/
    'queens': (['god-save-queens-202055-zoom-0', 'god-save-queens-202055-zoom-1'], [('102.20', (355, 785, 495, 1035)), ('105.70', (435, 790, 570, 1055)), ('110.50', (715, 775, 895, 1135))]),
    'queens-decals': (['god-save-queens-202055-zoom-0', 'god-save-queens-202055-zoom-1'], [('102.20', (355, 785, 495, 1035)), ('105.70', (435, 790, 570, 1055)), ('110.50', (715, 775, 895, 1135))]),
    'christ': (['christ-majesty-2014110-zoom-0'], [('103.70', (380, 1085, 475, 1250))]),
    'christ-on-wedge': ([], [('102.20', (100, 1000, 290, 1200)), ('103.70', (340, 1060, 520, 1280)), ('105.70', (580, 1040, 820, 1230))]),
}
def tile(im, label):
    im = im.convert('RGB'); im = im.resize((max(1, round(im.width * H / im.height)), H), Image.LANCZOS)
    t = Image.new('RGB', (im.width, H + 22), 'white'); t.paste(im, (0, 22)); ImageDraw.Draw(t).text((3, 5), label, fill='black'); return t
for name, (photos, crops) in SHEETS.items():
    ts = [tile(Image.open(review / 'photos' / f'{p}.jpg'), f'RISD official {p}') for p in photos]
    ts.append(tile(Image.open(here / f'views-{name}.png'), 'LOW POLYGON, Godot llvmpipe: front (+Z) | left side (+X) | rear (-Z) | right side (-X) | three-quarter'))
    ts += [tile(Image.open(review / 'frames' / f'IMG_6382-{t}.jpg').crop(b), f'SOURCE IMG_6382 {float(t):.2f}s') for t, b in crops]
    s = Image.new('RGB', (sum(t.width for t in ts) + 6 * len(ts), H + 22), 'white'); x = 0
    for t in ts: s.paste(t, (x, 0)); x += t.width + 6
    s.save(here / f'compare-{name}.jpg', quality=90); print(name, s.size)
