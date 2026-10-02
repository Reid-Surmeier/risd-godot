"""Landing wall-order plan: authored geometry.json vs IMG_6387 wall order vs root's proposed refit.
Authored numbers are read from the built geometry.json; the source panel is ORDER ONLY (no metres from video)."""
import json, hashlib
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
HERE = Path(__file__).parent
GEO = Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion/main-build-rooms-v50b/collection_rooms/geometry.json')
g = json.loads(GEO.read_text())
rooms = {r['label']: r for r in g['rooms']}
L = rooms['lion stair landing']
assert L['bounds'] == [10.55, 16.15, 28.1, 35.9] and L['openings'] == {'west': [29.2, 30.9], 'east': [29.2, 30.9], 'south': [13.9, 15.9]}
B = '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'
R = '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
F, FS, FT = ImageFont.truetype(B, 14), ImageFont.truetype(R, 13), ImageFont.truetype(B, 18)
S, X0, Z0, PW, PH = 34, 8.6, 21.4, 600, 600          # px per metre, world origin of each panel
img = Image.new('RGB', (3 * PW, PH + 150), 'white'); d = ImageDraw.Draw(img)
def P(k, x, z): return (k * PW + (x - X0) * S, 44 + (z - Z0) * S)
def room(k, b, fill, text, tz=None):
    d.rectangle([P(k, b[0], b[2]), P(k, b[1], b[3])], fill=fill, outline='#333333', width=2)
    d.text(P(k, b[0] + .15, (tz if tz else b[2] + .15)), text, fill='#222222', font=FS)
def door(k, a, b, col, text, off=(6, -8)):
    d.line([P(k, *a), P(k, *b)], fill=col, width=9)
    m = P(k, (a[0] + b[0]) / 2, (a[1] + b[1]) / 2); d.text((m[0] + off[0], m[1] + off[1]), text, fill=col, font=F)
def lion(k, a, b, text, off=(6, -8)):
    d.line([P(k, *a), P(k, *b)], fill='#1a9c3c', width=7)
    m = P(k, (a[0] + b[0]) / 2, (a[1] + b[1]) / 2); d.text((m[0] + off[0], m[1] + off[1]), text, fill='#1a9c3c', font=F)
RED, BLU, ORA = '#d62d20', '#0077c8', '#d97400'
for k, title in enumerate(['1  AUTHORED (geometry.json rooms[5], v48b = v50b)', '2  SOURCE WALL ORDER (IMG_6387; order only)', "3  ROOT'S PROPOSED REFIT + flags"]):
    d.text((k * PW + 8, 10), title, fill='black', font=FT)
    room(k, [8.6, 10.55, 21.4, 28.1], '#c9d3e6', 'Main Hall', 22.0)
    room(k, [8.6, 10.55, 28.1, 34.2], '#b9bcc4', 'medieval', 31.9)
    room(k, L['bounds'], '#f3efe2', '')
    door(k, (10.55, 29.2), (10.55, 30.9), RED, 'M', (-22, -8))
# panel 1: authored
m = rooms['modern painting gallery']['bounds']; room(0, m, '#dfe9df', 'modern (authored)')
door(0, (16.15, 29.2), (16.15, 30.9), BLU, 'D modern', (8, -8))
lion(0, (16.1, 31.93), (16.1, 34.37), 'lion', (-42, -8))
door(0, (13.9, 35.9), (15.9, 35.9), ORA, 'S sculpture', (-40, 8))
d.rectangle([P(0, 10.55, 32.0), P(0, 13.55, 35.9)], outline='#777777', width=2); d.text(P(0, 10.7, 33.6), 'stair void', fill='#555555', font=FS)
d.text(P(0, 10.7, 28.3), 'lion landing', fill='#222222', font=FS)
d.text((8, PH + 2), 'M and D face each other; lion right of D on the EAST wall;\nS on the SOUTH wall. Comment in prepare_remodel.py:\n"modern door opposite medieval".', fill='#b00000', font=FS)
# panel 2: source order
door(1, (11.0, 28.1), (12.7, 28.1), BLU, 'D modern', (-20, -24))
lion(1, (13.5, 28.15), (15.6, 28.15), 'text panel, lion, label', (-70, 8))
door(1, (16.15, 29.6), (16.15, 31.3), ORA, 'S sculpture', (8, -8))
d.text(P(1, 10.7, 31.3), '"5" sign,\nrail down', fill='#7a2fb5', font=FS)
d.rectangle([P(1, 10.55, 32.6), P(1, 16.15, 35.9)], outline='#777777', width=2); d.text(P(1, 11.6, 33.9), 'stairwell: flight up on far wall,\nbalustrade, rail down by S', fill='#555555', font=FS)
d.text(P(1, 16.3, 31.6), 'alarms, text,\nrail starts', fill=ORA, font=FS)
cx, cz = P(1, 13.35, 30.6); d.arc([cx - 46, cz - 46, cx + 46, cz + 46], 200, 160, fill='#444444', width=3)
d.polygon([(cx - 50, cz + 10), (cx - 36, cz + 12), (cx - 44, cz + 26)], fill='#444444'); d.text((cx - 30, cz - 16), 'pan A\nturns\nright', fill='#444444', font=FS)
room(1, [10.55, 16.15, 23.2, 28.1], '#dfe9df', 'modern gallery is BEHIND\nthe lion wall (walk-in\n45.5-47.5 s). Large painting\non the LEFT wall = the\nwall shared with the Hall.', 23.6)
d.text((PW + 8, PH + 2), 'Grey wall M | inside corner | white wall: D, text panel, lion, label | inside corner |\ngrey wall: S | stairwell | "5" sign | back to M.\nPan A 1.0-11.0 s (right) and pan B 41.0-44.5 s (left) agree. 9.0, 9.5, 43.0, 43.5 s\nshow M and D on two walls meeting at one corner. 3.0 s shows lion | corner | S.\nUNKNOWN: every offset, S position along its wall, stair geometry.', fill='#004a80', font=FS)
# panel 3: root proposal
room(2, [10.70, 16.70, 22.30, 28.10], '#dfe9df', 'modern\n[10.70,16.70,22.30,28.10]\nW: Le Fauconnier\nN: Matisse, Cezanne, door\nE: window, case, window\nS: door, Braque, Villon', 22.6)
door(2, (11.0, 28.1), (12.7, 28.1), BLU, 'D [11.0,12.7]', (-34, 10))
lion(2, (13.807, 28.18), (16.093, 28.18), 'lion c=14.95', (-30, 10))
door(2, (16.15, 29.6), (16.15, 31.3), ORA, 'S (z open)', (8, -8))
d.ellipse([P(2, 15.75, 27.75)[0], P(2, 15.75, 27.75)[1], P(2, 16.55, 28.55)[0], P(2, 16.55, 28.55)[1]], outline='#d62d20', width=3)
d.text((2 * PW + 8, PH + 2), 'OK  door sequence and handedness: rotation (u,v)->(v,-u), no mirror.\nOK  entering north: Le Fauconnier left, Matisse then Cezanne ahead (47.5 s).\nFLAG lion right edge 16.093 is 0.06 m from the NE corner 16.15 (red ring);\n     41.0 s and 3.0 s show a label and a strip of white wall before the corner.\nFLAG S: north-to-middle of the east wall, alarms and stair rail south of it\n     (4.0-5.0 s). Its z is unmeasured.\nFLAG room now abuts the Hall east wall: keep it on its own space/render layer.', fill='#222222', font=FS)
img.save(HERE / 'landing-plan.png')
print('geometry.json', hashlib.sha256(GEO.read_bytes()).hexdigest())
