"""Contact sheets from the read-only 2 fps survey JPEGs (CPU only).
Frame N of survey-2fps is at (N-1)/2 s; frames were extracted with -noautorotate,
so they are rotated here by the MOV display-matrix angle and nothing else."""
import json, sys, hashlib
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
SRC = Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion/survey-2fps')
OUT = Path(__file__).parent / 'sheets'
FONT = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf', 15)
TW, TH, COLS, ROWS = 180, 320, 10, 3

def thumb(clip, n, rot):
    im = Image.open(SRC / clip / f'{n:06d}.jpg').rotate(rot, expand=True)
    return im.resize((TW, TH), Image.LANCZOS)

def sheets(clip, step, rot, first=1, last=None):
    frames = sorted(int(p.stem) for p in (SRC / clip).glob('*.jpg'))
    frames = [n for n in frames if n >= first and (last is None or n <= last)][::step]
    made = {}
    for i in range(0, len(frames), COLS * ROWS):
        part = frames[i:i + COLS * ROWS]
        sheet = Image.new('RGB', (COLS * TW, ROWS * (TH + 20)), 'black')
        d = ImageDraw.Draw(sheet)
        for k, n in enumerate(part):
            x, y = (k % COLS) * TW, (k // COLS) * (TH + 20)
            sheet.paste(thumb(clip, n, rot), (x, y + 20))
            d.text((x + 3, y + 2), f'{n:03d} {(n - 1) / 2:.1f}s', fill='yellow', font=FONT)
        name = f'{clip}-{part[0]:03d}-{part[-1]:03d}-step{step}.jpg'
        sheet.save(OUT / name, quality=82)
        made[name] = hashlib.sha256((OUT / name).read_bytes()).hexdigest()
    return made

if __name__ == '__main__':
    clip, step, rot = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
    extra = [int(a) for a in sys.argv[4:6]]
    print(json.dumps(sheets(clip, step, rot, *extra), indent=1))
