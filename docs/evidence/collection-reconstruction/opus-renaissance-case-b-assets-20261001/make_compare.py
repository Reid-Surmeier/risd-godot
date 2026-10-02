"""Comparison sheets: official RISD photographs and native IMG_6383 crops (accepted inventory, read only) beside the Godot views check.gd wrote.
python3 make_compare.py [root checkout]"""
import sys
from pathlib import Path
from PIL import Image, ImageDraw
here = Path(__file__).parent
review = Path(sys.argv[1] if len(sys.argv) > 1 else '/home/reidsurmeier/orca/workspaces/risd-godot/collection-reconstruction') / 'docs/evidence/collection-reconstruction/opus-renaissance-case-inventory-20261001'
H = 560
VIEWS = 'LOW POLYGON, Godot llvmpipe: front | quarter | rear | from above'
SHEETS = {  # object: official photographs, then [frame seconds, crop box] from the inventory's frames/
    'plate-46391': (['bella-donna-plate-46391-zoom-0'], [('055.60', (350, 540, 660, 900)), ('056.00', (330, 510, 720, 900)), ('057.00', (0, 540, 400, 960))]),
    'plate-57302': (['bella-donna-plate-57302-zoom-0', 'bella-donna-plate-57302-zoom-1'], [('055.60', (720, 640, 930, 920)), ('056.00', (790, 630, 1070, 950)), ('057.00', (550, 640, 880, 980))]),
    'roundel-51105': (['death-virgin-51105-zoom-0', 'death-virgin-51105-zoom-1'], [('055.60', (350, 1200, 540, 1400)), ('056.00', (300, 1240, 520, 1480))]),
    'glass-201729': (['virgin-woman-apocalypse-201729-zoom-0', 'virgin-woman-apocalypse-201729-zoom-1'], [('056.00', (640, 1060, 960, 1420)), ('057.00', (340, 1100, 670, 1460))]),
    'plaque-34024': (['virgin-and-child-clerics-and-donors-34024-zoom-0'], [('056.50', (900, 1170, 1080, 1370)), ('057.00', (760, 1170, 990, 1370))]),
    'group': ([], [('056.00', (0, 440, 1080, 1560)), ('057.00', (0, 440, 1080, 1560))]),
}
def tile(im, label):
    im = im.convert('RGB'); im = im.resize((max(1, round(im.width * H / im.height)), H), Image.LANCZOS)
    t = Image.new('RGB', (im.width, H + 22), 'white'); t.paste(im, (0, 22)); ImageDraw.Draw(t).text((3, 5), label, fill='black'); return t
for name, (photos, crops) in SHEETS.items():
    ts = [tile(Image.open(review / 'photos' / f'{p}.jpg'), f'RISD official {p}') for p in photos]
    ts.append(tile(Image.open(here / f'views-{name}.png'), VIEWS))
    ts += [tile(Image.open(review / 'frames' / f'IMG_6383-{t}.jpg').crop(b), f'SOURCE IMG_6383 {float(t):.1f}s') for t, b in crops]
    s = Image.new('RGB', (sum(t.width for t in ts) + 6 * len(ts), H + 22), 'white'); x = 0
    for t in ts: s.paste(t, (x, 0)); x += t.width + 6
    s.save(here / f'compare-{name}.jpg', quality=90); print(name, s.size)
