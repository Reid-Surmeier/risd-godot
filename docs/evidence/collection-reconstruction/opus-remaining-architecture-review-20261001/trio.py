"""Side-by-side enlargements of chosen survey frames: trio.py OUT CLIP n n n ..."""
import sys
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
SRC = Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion/survey-2fps')
FONT = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf', 18)
out, clip, frames = sys.argv[1], sys.argv[2], [int(a) for a in sys.argv[3:]]
W, H = 480, 853
sheet = Image.new('RGB', (W * len(frames), H + 24), 'black')
d = ImageDraw.Draw(sheet)
for i, n in enumerate(frames):
    im = Image.open(SRC / clip / f'{n:06d}.jpg').rotate(-90, expand=True).resize((W, H), Image.LANCZOS)
    sheet.paste(im, (i * W, 24))
    d.text((i * W + 4, 2), f'{clip} {n:03d} {(n - 1) / 2:.1f}s', fill='yellow', font=FONT)
sheet.save(Path(__file__).parent / 'frames' / out, quality=88)
