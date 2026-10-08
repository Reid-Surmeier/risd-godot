"""Pass 2 sheets for #263: one column per route, rows front / three-quarter / side / game camera.
usage: compare_routes.py SHOTS OUT_DIR   (SHOTS holds <key>-<view>.png from pilot.tscn)"""
import sys, io
from PIL import Image, ImageDraw, ImageFont
shots, out = sys.argv[1:3]
font = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 15)
def sheet(name, cols, box, game_box, w=380):
    rows = [('front', box), ('threequarter', box), ('side', box), ('game', game_box)]
    cells = [[Image.open(f'{shots}/{k}-{v}.png').convert('RGB').crop(tuple(round(a * b) for a, b in zip(bx, (960, 642, 960, 642)))) for k, _ in cols] for v, bx in rows]
    cells = [[c.resize((w, round(c.height * w / c.width)), Image.LANCZOS) for c in r] for r in cells]
    H = 44 + sum(r[0].height + 4 for r in cells); s = Image.new('RGB', ((w + 6) * len(cols) - 6, H), 'white'); d = ImageDraw.Draw(s)
    for i, (_, label) in enumerate(cols):
        for j, line in enumerate(label.split('\n')): d.text((i * (w + 6) + 3, 3 + 19 * j), line, fill='black', font=font)
    y = 44
    for r in cells:
        for i, c in enumerate(r): s.paste(c, (i * (w + 6), y))
        y += r[0].height + 4
    q = 88
    while True:
        b = io.BytesIO(); s.save(b, 'JPEG', quality=q, optimize=True)
        if b.tell() < 390_000 or q <= 50: break
        q -= 4
    open(f'{out}/{name}', 'wb').write(b.getvalue()); print(name, s.size, 'q', q, b.tell() // 1024, 'KB')
sheet('05-fireplace-routes.jpg', [('fp-trellis', 'Trellis\n6k tri, 212 KB, 0.024 USD'), ('fp-trellis-photo', 'Trellis + photograph\n6k tri, 511 KB, 0.024 USD'), ('fp-trellis26-photo', 'Trellis detailed + photograph\n26k tri, 881 KB, 0.024 USD'),
                                  ('fp-tripo', 'Tripo H3.1\n18k tri, 792 KB, 0.72 USD'), ('fp-tripo-photo', 'Tripo H3.1 + photograph\n18k tri, 884 KB, 0.72 USD')], (.25, 0, .75, 1), (.05, .05, .62, .90))
sheet('06-neptune-routes.jpg', [('nep-trellis', 'Trellis\n19k tri, 461 KB, 0.024 USD'), ('nep-trellis-photo', 'Trellis + photograph\n19k tri, 489 KB, 0.024 USD'),
                                ('nep-tripo', 'Tripo H3.1\n12k tri, 229 KB, 0.60 USD'), ('nep-tripo-photo', 'Tripo H3.1 + photograph\n12k tri, 257 KB, 0.60 USD')], (.2, .08, .8, .92), (.22, .22, .78, .98), w=470)
