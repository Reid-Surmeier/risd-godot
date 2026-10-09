"""Annotated landing sequence from IMG_6387 survey frames + wall-order plan (CPU only).
Marker positions were placed by eye on 480x853 upright frames; they point at the feature, nothing is measured from them."""
import json, hashlib
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
SRC = Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion/survey-2fps/IMG_6387')
HERE = Path(__file__).parent
B = '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'
F, FS, FB = ImageFont.truetype(B, 15), ImageFont.truetype(B, 13), ImageFont.truetype(B, 20)
COL = {'M': '#ff3b30', 'D': '#00c2ff', 'C': '#ffd60a', 'L': '#34c759', 'S': '#ff9f0a', '5': '#bf5af2', 'T': '#ffffff', 'F': '#ff66cc'}
KEY = 'M medieval door (grey wall)   C inside corner   D modern door (white wall)   T grey text panel   L lion   S sculpture-gallery door (grey wall)   5 level sign / stair   F Le Fauconnier'
W, H, CAP = 360, 640, 58
# frame -> (caption, [(tag, x, y)]) with x,y in 480x853 space
PAN_A = [
 (3,  'lion wall | corner | sculpture door', [('L',45,200),('C',300,300),('S',410,330)]),
 (7,  'lion (white wall) | corner | grey wall | sculpture door', [('L',90,330),('C',236,330),('S',430,400)]),
 (9,  'sculpture door, grey wall both sides', [('S',300,420)]),
 (11, 'sculpture door | alarms | handrail down | stairwell', [('S',90,420),('5',330,520)]),
 (13, 'stairwell: flight up, balustrade, chair cart', [('5',250,300)]),
 (15, 'flight up | level sign 5 | medieval casing', [('5',330,410),('M',440,420)]),
 (17, 'level sign 5 + rail | medieval door (case, herringbone)', [('5',70,420),('M',270,440)]),
 (19, 'medieval door | text | CORNER | modern door', [('M',70,440),('C',350,330),('D',440,450)]),
 (20, 'grey wall text | CORNER | modern door (leaf, low grille)', [('C',228,330),('D',360,450)]),
 (23, 'modern door | grey text panel | lion', [('D',60,500),('T',175,470),('L',330,480)]),
]
PAN_B = [
 (83, 'lion | label | corner to grey (sculpture) wall', [('L',160,400),('C',440,330)]),
 (85, 'modern door | text panel | lion', [('D',40,450),('T',140,440),('L',330,410)]),
 (86, 'grey wall | CORNER | modern door | text panel | lion', [('C',66,330),('D',145,440),('T',270,420),('L',400,400)]),
 (87, 'medieval leaf | grey wall | CORNER | modern door | panel', [('M',20,440),('C',215,330),('D',300,440),('T',430,420)]),
 (88, 'medieval door | text | CORNER | modern door', [('M',90,430),('C',335,330),('D',430,450)]),
 (90, 'sign 5 + rail down | medieval door (tall case inside)', [('5',100,400),('M',310,430)]),
 (92, 'grey wall text | CORNER | modern door leaf', [('C',300,330),('D',400,450)]),
 (93, 'through modern door: low grille, large painting', [('D',240,420),('F',420,330)]),
 (94, 'walking in: Le Fauconnier on the LEFT wall', [('F',300,300)]),
 (96, 'inside modern gallery: left wall, far wall, bench', [('F',170,300)]),
]

def sheet(name, title, rows):
    out = Image.new('RGB', (5 * W, 2 * (H + CAP) + 62), '#101010')
    d = ImageDraw.Draw(out)
    d.text((8, 6), title, fill='white', font=FB)
    d.text((8, 34), KEY, fill='#d0d0d0', font=FS)
    used = {}
    for i, (n, cap, tags) in enumerate(rows):
        p = SRC / f'{n:06d}.jpg'
        used[p.name] = hashlib.sha256(p.read_bytes()).hexdigest()
        im = Image.open(p).rotate(-90, expand=True).resize((W, H), Image.LANCZOS)
        x0, y0 = (i % 5) * W, 62 + (i // 5) * (H + CAP)
        out.paste(im, (x0, y0))
        d.rectangle([x0, y0 + H, x0 + W - 1, y0 + H + CAP - 1], fill='#000000')
        d.text((x0 + 5, y0 + H + 4), f'{n:03d}  {(n - 1) / 2:.1f}s', fill='yellow', font=F)
        words, line, y = cap.split(' '), '', y0 + H + 22
        for w in words + ['']:
            if w == '' or d.textlength(line + ' ' + w, font=FS) > W - 10:
                d.text((x0 + 5, y), line.strip(), fill='white', font=FS); line, y = w, y + 15
            else:
                line += ' ' + w
        for tag, x, yy in tags:
            cx, cy = x0 + x * W / 480, y0 + yy * H / 853
            d.ellipse([cx - 13, cy - 13, cx + 13, cy + 13], fill=COL[tag], outline='black', width=2)
            d.text((cx - 6, cy - 9), tag, fill='black', font=F)
    out.save(HERE / name, quality=88)
    return used

if __name__ == '__main__':
    used = {}
    used.update(sheet('landing-pan-A-0.5-11s.jpg', 'IMG_6387 pan A, turning RIGHT (clockwise) 1.0-11.0 s: lion wall > sculpture door > stairwell > medieval door > modern door > lion', PAN_A))
    used.update(sheet('landing-pan-B-41-47.5s.jpg', 'IMG_6387 pan B, turning LEFT 41.0-44.5 s, then right and WALKING IN 45.5-47.5 s (continuous)', PAN_B))
    (HERE / 'landing-frames-sha256.json').write_text(json.dumps({'clip': 'IMG_6387.MOV', 'survey': 'survey-2fps, frame N = (N-1)/2 s, 1280x720 before upright rotation', 'frames': used}, indent=1) + '\n')
    print(len(used), 'frames')
