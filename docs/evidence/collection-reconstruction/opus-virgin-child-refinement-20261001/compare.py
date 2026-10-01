"""Lays the official photographs, the native renders and the Muse sheet side by side, all at one figure height."""
import sys
from pathlib import Path
from PIL import Image, ImageDraw
proj, out = Path(sys.argv[1]), Path(sys.argv[2])
R = Path('/home/reidsurmeier/orca/workspaces/risd-godot/collection-reconstruction')
P = R / 'docs/evidence/collection-reconstruction/opus-medieval-case-inventory-20261001/photos'
muse = Image.open(R / 'image-work/collection-room-remodel/artifacts/image-generation/runs/run-45b7430ae44f28051bb2b9a2/materialized/image-01.webp').convert('RGB')
H = 760
def fit(im, box):
    im = im.crop(box); return im.resize((round(im.width * H / im.height), H), Image.LANCZOS)
def native(name):
    im = Image.open(proj / (name + '.png')).convert('RGB'); return fit(im, (300, 40, 900, 960))
rear = Image.open(R / 'docs/evidence/collection-reconstruction/opus-medieval-case-inventory-20261001/frames/IMG_6382-105.70.jpg').convert('RGB')
rows = {
 'front': [('official photo 0', fit(Image.open(P / 'virgin-and-child-15108-zoom-0.jpg').convert('RGB'), (200, 150, 1100, 1590))), ('native, 12 deg down', native('front-high')), ('native, level', native('front')), ('Muse sheet FRONT', fit(muse, (0, 230, 530, 1210)))],
 'right': [('official photo 2 (her right side)', fit(Image.open(P / 'virgin-and-child-15108-zoom-2.jpg').convert('RGB'), (330, 180, 1000, 1630))), ('native, 12 deg down', native('right-high')), ('native, level', native('right')), ('Muse sheet RIGHT SIDE', fit(muse, (540, 230, 880, 1210)))],
 'left': [('official photo 3 (her left side)', fit(Image.open(P / 'virgin-and-child-15108-zoom-3.jpg').convert('RGB'), (330, 170, 1000, 1620))), ('native, 12 deg down', native('left-high')), ('native, level', native('left')), ('Muse sheet LEFT SIDE', fit(muse, (910, 230, 1250, 1210)))],
 'rear': [('video 105.70 s, blurred (only rear source)', fit(rear, (490, 520, 720, 880))), ('native, level', native('rear')), ('Muse sheet REAR (hair partly invented)', fit(muse, (1250, 230, 1760, 1210)))],
 'oblique': [('official photo 1', fit(Image.open(P / 'virgin-and-child-15108-zoom-1.jpg').convert('RGB'), (300, 170, 1050, 1620))), ('native oblique, her left', native('oblique')), ('native oblique, child side', native('oblique-child'))],
}
for name, cells in rows.items():
    sheet = Image.new('RGB', (sum(im.width for _, im in cells) + 12 * (len(cells) + 1), H + 44), (245, 245, 245))
    draw = ImageDraw.Draw(sheet); x = 12
    for label, im in cells:
        sheet.paste(im, (x, 32)); draw.text((x, 10), label, fill=(0, 0, 0)); x += im.width + 12
    sheet.save(out / ('compare-%s.jpg' % name), quality=90)
