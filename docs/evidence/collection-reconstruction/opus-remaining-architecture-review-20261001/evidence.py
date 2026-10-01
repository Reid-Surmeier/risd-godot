"""Annotated contact sheet for defects D2-D5 and a to-scale authored plan with the defect callouts.
Frames are the read-only 2 fps survey JPEGs, rotated upright; markers were placed by eye and measure nothing."""
import json, hashlib
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
ING = Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
SRC, HERE = ING / 'survey-2fps', Path(__file__).parent
B, R = '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf', '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
F, FS, FB = ImageFont.truetype(B, 14), ImageFont.truetype(R, 12), ImageFont.truetype(B, 18)
COL = {'X': '#ff3b30', 'C': '#ffd60a', 'A': '#34c759', 'B': '#34c759', 'G': '#00c2ff', 'P': '#bf5af2'}
KEY = 'X shared door axis   C room corner   A/B apostle reliefs   G Grand Gallery doorway or its leaf   P purple-connector doorway'
W, H, CAP, N = 257, 457, 78, 7
ROWS = [
 ('IMG_6387', 27,  'D2  from the landing: stair door, tall case and the lit tracery doorway on one axis; painted figure left, gold panels right', [('X', 200, 560)]),
 ('IMG_6387', 89,  'D2  same axis again on the second pan', [('X', 215, 410)]),
 ('IMG_6383', 134, 'D2  from the Renaissance room through the tracery doorway: stair door and EXIT sign straight beyond the low case', [('X', 190, 410)]),
 ('IMG_6382', 157, 'medieval wide: apostle A, stair door with tall case, corner, then Christ head and relief on the south wall', []),
 ('IMG_6382', 29,  'D4  grille, vent | NE corner | apostle A | stair-door casing at the right edge', [('C', 185, 300), ('A', 340, 400)]),
 ('IMG_6382', 49,  'D4  stair-door jamb, thermostat | apostle B | SE corner | Christ head pedestal', [('B', 215, 380), ('C', 275, 300)]),
 ('IMG_6384', 25,  'D5  far end wall facing south: Previtali, bronze figure case, doorway', []),
 ('IMG_6380', 77,  'D3  Grand Gallery doorway, small painting | SW corner | connector doorway | barn, forest paintings', [('G', 25, 560), ('C', 145, 470), ('P', 205, 600)]),
 ('IMG_6380', 203, 'D3  Grand Gallery leaf, small painting | corner | connector casing starts at the corner', [('G', 50, 300), ('C', 255, 420), ('P', 380, 350)]),
 ('IMG_6379', 344, 'D3  from the piano-stair door: Grand Gallery doorway on axis, connector doorway at the far end of the right wall', [('G', 205, 530), ('P', 330, 560)]),
 ('IMG_6381', 181, 'D3  from the marble stair looking west: Grand Gallery leaf, connector doorway, two paintings', [('G', 108, 185), ('P', 180, 190)]),
 ('IMG_6380', 497, 'D3  from the connector doorway: Grand Gallery leaf at the right edge; bust and Ionic opening on the connector axis', [('G', 430, 330)]),
 ('IMG_6384', 29,  'D5  doorway | tabernacle on plinth | corner | west wall with the bronze relief case', []),
 ('IMG_6383', 123, 'Renaissance west wall: painting, shuttered window, bronze figure case, Pieta wall case; bench', []),
]
def contact():
    out = Image.new('RGB', (N * W, 2 * (H + CAP) + 60), '#101010'); d = ImageDraw.Draw(out); used = []
    d.text((8, 6), 'Source frames for defects D2-D5 (D1, the landing, has its own two sheets)', fill='white', font=FB)
    d.text((8, 34), KEY, fill='#d0d0d0', font=FS)
    for i, (clip, n, cap, tags) in enumerate(ROWS):
        p = SRC / clip / f'{n:06d}.jpg'
        used.append({'clip': clip + '.MOV', 'frame': n, 'seconds': (n - 1) / 2, 'sha256': hashlib.sha256(p.read_bytes()).hexdigest()})
        x0, y0 = (i % N) * W, 60 + (i // N) * (H + CAP)
        out.paste(Image.open(p).rotate(-90, expand=True).resize((W, H), Image.LANCZOS), (x0, y0))
        d.rectangle([x0, y0 + H, x0 + W - 1, y0 + H + CAP - 1], fill='black')
        d.text((x0 + 4, y0 + H + 3), f'{clip[4:]}  {n:03d}  {(n - 1) / 2:.1f}s', fill='yellow', font=F)
        line, y = '', y0 + H + 21
        for w in cap.split(' ') + ['']:
            if w == '' or d.textlength(line + ' ' + w, font=FS) > W - 8:
                d.text((x0 + 4, y), line.strip(), fill='white', font=FS); line, y = w, y + 14
            else:
                line += ' ' + w
        for tag, x, yy in tags:
            cx, cy = x0 + x * W / 480, y0 + yy * H / 853
            d.ellipse([cx - 11, cy - 11, cx + 11, cy + 11], fill=COL[tag], outline='black', width=2); d.text((cx - 5, cy - 8), tag, fill='black', font=F)
    out.save(HERE / 'evidence-sheet.jpg', quality=88)
    (HERE / 'evidence-frames-sha256.json').write_text(json.dumps(used, indent=1) + '\n')

def plan():
    g = json.loads((ING / 'main-build-rooms-v50b/collection_rooms/geometry.json').read_text())
    S, X0, Z0 = 15, -7.0, -9.0
    img = Image.new('RGB', (1120, 740), 'white'); d = ImageDraw.Draw(img)
    P = lambda x, z: ((x - X0) * S + 10, (z - Z0) * S + 34)
    d.text((10, 8), 'Authored rooms, geometry.json 7e0c504d (v48b = v50b), to scale. x east, z south: prototype axes, not compass.', fill='black', font=F)
    tint = {'Grand Gallery': '#c9d3e6', 'dark medieval room': '#b9bcc4', 'lion stair landing': '#f3efe2', 'modern painting gallery': '#dfe9df', 'grey French gallery': '#dcdcd6', 'purple elevator-5 connector': '#d9c7ea'}
    short = {'Rockefeller': 'Rockefeller', 'adjacent gallery': 'European\ngallery', 'light Renaissance room': 'Renaissance', 'dark medieval room': 'medieval', 'Grand Gallery': 'Main Hall\n(live build,\npreserved)', 'lion stair landing': 'lion\nlanding', 'grey French gallery': 'grey French', 'modern painting gallery': 'modern'}
    for r in g['rooms']:
        b = r['bounds']; d.rectangle([P(b[0], b[2]), P(b[1], b[3])], fill=tint.get(r['label'], '#eeeeea'), outline='#444444', width=1)
        if r['label'] in short: d.text(P(b[0] + .3, b[2] + .3), short[r['label']], fill='#222222', font=FS)
    for r in g['rooms']:
        b = r['bounds']
        for side, o in r['openings'].items():
            a, c = {'west': ((b[0], o[0]), (b[0], o[1])), 'east': ((b[1], o[0]), (b[1], o[1])), 'north': ((o[0], b[2]), (o[1], b[2])), 'south': ((o[0], b[3]), (o[1], b[3]))}[side]
            d.line([P(*a), P(*c)], fill='#0a7d2c', width=4)
    red = '#d62d20'
    def call(tag, x, z):
        cx, cy = P(x, z); d.ellipse([cx - 12, cy - 12, cx + 12, cy + 12], fill=red, outline='black'); d.text((cx - 9, cy - 8), tag, fill='white', font=F)
    for z in (31.765, 30.05): d.line([P(.55, z), P(10.55, z)], fill=red, width=1)
    call('D1', 16.9, 31.9); call('D2', 5.5, 30.9); call('D3', 3.2, .2); call('D4', 9.7, 33.2); call('D5', -2.5, 27.2)
    notes = [
     ('D1', 'Landing. Authored: modern door and lion on the east wall, facing the medieval door; sculpture door on the south wall. Source: modern door, text panel and lion on the NORTH wall, sharing a corner with the medieval-door wall; sculpture door on the EAST wall; stairwell south. IMG_6387 9.0, 9.5, 42.5, 43.0 s.'),
     ('D2', 'Medieval. Authored tracery doorway centre z 31.765, stair door centre z 30.05 (red lines, 1.715 m apart). Source: one axis through stair door, tall case and tracery doorway. IMG_6387 13.0, 44.0 s; IMG_6383 66.5 s.'),
     ('D3', 'Grey gallery. Authored connector doorway is centred on the west wall, 3.0 m from each corner. Source: it starts at the SW corner beside the Grand Gallery doorway, with two paintings between it and the piano-stair corner. IMG_6380 38.0, 101.0, 248.0 s; IMG_6379 171.5 s; IMG_6381 90.0 s.'),
     ('D4', 'Medieval east wall. Authored: 3.3 m of wall south of the stair door, apostle B 2.7 m from the SE corner. Source: corner about one backplate beyond apostle B. IMG_6382 14.0, 24.0, 26.0 s. Room depth unmeasured.'),
     ('D5', 'Inventory only. european-gallery-inventory.json has the far-wall tabernacle east of the doorway and the bronze figure case west. Source: bronze case and Previtali east, tabernacle west at the corner. IMG_6384 12.0-18.0 s.'),
    ]
    y = 44
    for tag, text in notes:
        d.ellipse([500, y, 524, y + 24], fill=red, outline='black'); d.text((503, y + 4), tag, fill='white', font=F)
        line, yy = '', y
        for w in text.split(' ') + ['']:
            if w == '' or d.textlength(line + ' ' + w, font=FS) > 570:
                d.text((534, yy), line.strip(), fill='#111111', font=FS); line, yy = w, yy + 16
            else:
                line += ' ' + w
        y = yy + 14
    d.text((500, y + 6), 'Green = authored openings. Rooms left blank are threshold stubs.\nNothing on this plan is a measured room size; every authored\nmetre is still marked provisional by the root.', fill='#444444', font=FS)
    img.save(HERE / 'rooms-plan.png')

if __name__ == '__main__':
    contact(); plan(); print('ok')
