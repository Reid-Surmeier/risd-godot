"""Build the four comparison pictures for #263 from the renders in SHOTS and the footage frames in FOOTAGE.
usage: compare.py SHOTS FOOTAGE TODAY_FIREPLACE.jpg TODAY_NEPTUNE.jpg OUT_DIR   (run from the worktree root)"""
import sys, io
from PIL import Image, ImageDraw, ImageFont
shots, footage, today_fp, today_nep, out = sys.argv[1:6]
A = 'modules/shell/collection_rooms/assets/additions/'
font = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 17)

def panel(path, label, h, box=None):
    im = Image.open(path).convert('RGB')
    if box: im = im.crop(tuple(round(v * s) for v, s in zip(box, (im.width, im.height, im.width, im.height))))
    im = im.resize((round(im.width * h / im.height), h), Image.LANCZOS)
    p = Image.new('RGB', (im.width, h + 30), 'white'); p.paste(im, (0, 30)); ImageDraw.Draw(p).text((4, 5), label, fill='black', font=font)
    return p

def save(rows, name):
    w = max(sum(p.width for p in r) + 8 * (len(r) - 1) for r in rows)
    sheet = Image.new('RGB', (w, sum(r[0].height for r in rows) + 8 * (len(rows) - 1)), 'white'); y = 0
    for r in rows:
        x = 0
        for p in r: sheet.paste(p, (x, y)); x += p.width + 8
        y += r[0].height + 8
    q = 88
    while True:
        b = io.BytesIO(); sheet.save(b, 'JPEG', quality=q, optimize=True)
        if b.tell() < 390_000 or q <= 50: break
        q -= 4
    open(f'{out}/{name}', 'wb').write(b.getvalue()); print(name, sheet.size, 'q', q, b.tell() // 1024, 'KB')

H = 640
save([[panel(f'{footage}/full-65.jpg', 'Footage (IMG_6380 65 s)', H, (.0, .12, 1, .95)),
       panel(A + 'marble-hall/fireplace-83.152.jpg', 'Catalogue photograph', H),
       panel(today_fp, 'Build today: photo, extruded', H, (.13, .12, .52, .82)),
       panel(f'{shots}/fireplace-game.png', 'Trellis mesh, game camera (6k tri)', H, (.05, .05, .62, .90))]], '01-fireplace-four-panels.jpg')
h = 520; box = (.25, .02, .75, .98)
save([[panel(f'{shots}/fireplace-{v}.png', f'6,175 triangles, 212 KB: {n}', h, box) for v, n in (('front', 'front'), ('threequarter', 'three-quarter'), ('side', 'side'))] +
      [panel(f'{shots}/fireplace-detail-{v}.png', f'26,141 triangles, 523 KB: {n}', h, box) for v, n in (('front', 'front'), ('threequarter', 'three-quarter'), ('side', 'side'))]], '02-fireplace-side-views.jpg')
H = 560
save([[panel(f'{footage}/full-225.5.jpg', 'Footage (IMG_6380 225.5 s)', H, (.55, .36, 1, .70)),
       panel(A + 'rockefeller/neptune-2017.74.31.1.jpg', 'Catalogue photograph', H),
       panel(today_nep, 'Build today: lumps on a box', H),
       panel(f'{shots}/neptune-game.png', 'Trellis mesh, game camera (19k tri)', H, (.22, .22, .78, .98))]], '03-neptune-four-panels.jpg')
h = 430; box = (.2, .08, .8, .92)
save([[panel(f'{shots}/neptune-{v}.png', f'19,312 triangles, 461 KB: {n}', h, box) for v, n in (('front', 'front'), ('threequarter', 'three-quarter'), ('side', 'side'))],
      [panel(f'{shots}/neptune-detail-{v}.png', f'100,639 triangles, 1.58 MB: {n}', h, box) for v, n in (('front', 'front'), ('threequarter', 'three-quarter'), ('side', 'side'))]], '04-neptune-side-views.jpg')
