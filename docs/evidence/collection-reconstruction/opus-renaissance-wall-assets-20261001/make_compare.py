"""Comparison sheets: official RISD photographs and native IMG_6383 frames (accepted inventory, read only) beside the Godot views check.gd wrote.
python3 make_compare.py [root checkout]"""
import sys
from pathlib import Path
from PIL import Image, ImageDraw
here = Path(__file__).parent
review = Path(sys.argv[1] if len(sys.argv) > 1 else '/home/reidsurmeier/orca/workspaces/risd-godot/collection-reconstruction') / 'docs/evidence/collection-reconstruction/opus-renaissance-case-inventory-20261001'
H = 760
VIEWS = 'LOW POLYGON, Godot llvmpipe: front | quarter | rear (velvet: board lifted away) | from above'
SHEETS = {  # object: official photographs, [frame seconds, crop box] from the inventory's frames/, then this folder's rectified video references
    'velvet-23307x': (['velvet-cover-23307x-zoom-0'], [('006.10', (470, 360, 1060, 1200)), ('068.50', (0, 480, 470, 1280))], ['velvet-23307x-mount-rectified-06.10.jpg']),
    'woodcutters-29280': (['woodcutters-29280-zoom-0'], [('011.50', (80, 240, 880, 1480)), ('060.60', (60, 430, 360, 1060)), ('068.50', (590, 470, 1080, 1240))], ['woodcutters-29280-rectified-11.50.jpg']),
    'madonna-58196': (['madonna-and-child-saint-barbara-and-saint-catherine-58196-zoom-0', 'madonna-and-child-saint-barbara-and-saint-catherine-58196-zoom-1'],
        [('015.10', (260, 500, 1060, 1320)), ('060.60', (590, 600, 860, 890))], ['frame-58196-rectified-15.10.png']),
}
def tile(im, label):
    im = im.convert('RGB'); im = im.resize((max(1, round(im.width * H / im.height)), H), Image.LANCZOS)
    t = Image.new('RGB', (im.width, H + 22), 'white'); t.paste(im, (0, 22)); ImageDraw.Draw(t).text((3, 5), label, fill='black'); return t
for name, (photos, crops, refs) in SHEETS.items():
    ts = [tile(Image.open(review / 'photos' / f'{p}.jpg'), f'RISD official {p[-6:]}') for p in photos]
    if name == 'velvet-23307x':
        ts.append(tile(Image.open(here / 'live/carousel-velvet-cover-23307x-zoom-2.jpg'), 'RISD official zoom-2, the back'))
    ts.append(tile(Image.open(here / f'views-{name}.png'), VIEWS))
    ts += [tile(Image.open(review / 'frames' / f'IMG_6383-{t}.jpg').crop(b), f'SOURCE IMG_6383 {float(t):.1f}s') for t, b in crops]
    ts += [tile(Image.open(here / 'references' / r), 'SOURCE rectified to the photograph') for r in refs]
    s = Image.new('RGB', (sum(t.width for t in ts) + 6 * len(ts), H + 22), 'white'); x = 0
    for t in ts: s.paste(t, (x, 0)); x += t.width + 6
    s.save(here / f'compare-{name}.jpg', quality=88); print(name, s.size)
