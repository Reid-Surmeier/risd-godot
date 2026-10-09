#!/usr/bin/env python3
"""Review evidence only: footage beside unbaked native camera captures, never game textures."""
import argparse
from pathlib import Path
from PIL import Image, ImageDraw, ImageOps

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--footage', required=True, type=Path)
parser.add_argument('--draft', required=True, type=Path)
parser.add_argument('--out', required=True, type=Path)
args = parser.parse_args()
args.out.mkdir(parents=True, exist_ok=True)

sheets = {
    'A': [('North: Manet / Carolus-Duran', [131, 139], 'A-north'),
          ('West: three Monet canvases', [98, 104], 'A-west'),
          ('South: Le Repos; empty bronze case', [147], 'A-south'),
          ('East: Cezanne / Degas between windows', [143, 122], 'A-east')],
    'B': [('North: unfilmed face; opposite side of shared door shown', [154], 'B-north'),
          ('West: Pissarro / Gauguin', [180, 186], 'B-west'),
          ('South: Cezanne / Monet', [191, 214], 'B-south'),
          ('East, north span: Bracquemond / Morisot / van Gogh', [201, 206, 211], 'B-east-north'),
          ('East, south span: Cassatt between windows', [216, 221], 'B-east-south')]
}
for gallery, rows in sheets.items():
    sheet = Image.new('RGB', (1200, 88 + len(rows) * 330), '#eeede8')
    draw = ImageDraw.Draw(sheet)
    draw.text((16, 12), f'Gallery {gallery} / #277 twelve catalogue photographs / 8 October 2026', fill='#222222')
    draw.text((16, 34), 'LEFT: IMG_6343, ordinary SDR. RIGHT: unbaked GL Compatibility draft, review fill .55.', fill='#222222')
    draw.text((16, 56), 'Catalogue canvas dimensions. Fitted positions and borrowed frame carving remain unaccepted; lighting awaits the bake.', fill='#222222')
    for i, (label, seconds, name) in enumerate(rows):
        y = 88 + i * 330
        draw.line((8, y, 1192, y), fill='#c8c7c2')
        draw.text((16, y + 8), label, fill='#222222')
        cell = 430 // len(seconds)
        for j, sec in enumerate(seconds):
            pic = ImageOps.contain(Image.open(args.footage / f'{sec}.jpg'), (cell - 10, 287))
            sheet.paste(pic, (12 + j * cell + (cell - pic.width) // 2, y + 27))
            draw.text((16 + j * cell, y + 315), f'{sec}s', fill='#222222')
        pic = ImageOps.contain(Image.open(args.draft / f'{name}-close.png'), (738, 297))
        sheet.paste(pic, (450 + (738 - pic.width) // 2, y + 28 + (297 - pic.height) // 2))
    path = args.out / f'6-gallery-{gallery}-catalogue-before-after.jpg'
    sheet.save(path, quality=86, optimize=True, subsampling=0)
    if path.stat().st_size >= 300_000:
        sheet.save(path, quality=79, optimize=True)
    assert path.stat().st_size < 300_000, path
    print(path, sheet.size, path.stat().st_size)
