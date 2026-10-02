"""Source frame | delivery as built | same with the piano door's west leaf hidden. CPU captures from capture.gd."""
import sys
from pathlib import Path
from PIL import Image, ImageDraw
cap, out = Path(sys.argv[1]), Path(sys.argv[2])
R = Path('/home/reidsurmeier/orca/workspaces/risd-godot/collection-reconstruction/docs/evidence/collection-reconstruction')
fit = R / 'opus-grey-register-fit-20261001/frames'
survey = Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion/survey-2fps/IMG_6380')
H = 520
def fit_h(im): return im.resize((round(im.width * H / im.height), H), Image.LANCZOS)
def upright(n):
    im = Image.open(survey / ('%06d.jpg' % n)).convert('RGB')
    return im.rotate(-90, expand=True) if im.width > im.height else im
b1 = Image.open(fit / 'B1-6381-090.968.png').convert('RGB').rotate(180)
rows = [
 ('north-west-corner-from-east', 'source IMG_6380 38.9 s: Courbet, label, corner, then the piano door leaf in the wall plane', Image.open(fit / 'A2-6380-038.901.png').convert('RGB').crop((0, 820, 1080, 1620)), True),
 ('west-wall-from-north-east', 'source IMG_6380 38.3 s', Image.open(fit / 'A1-6380-038.300.png').convert('RGB').crop((0, 820, 1080, 1620)), True),
 ('west-wall-from-stair', 'source IMG_6381 91.0 s (held-out view, a different video)', b1.crop((0, 500, 1080, 1420)), True),
 ('from-connector-door-looking-east', 'source IMG_6380 248.0 s, from the connector doorway', upright(497), False),
]
for name, label, src, both in rows:
    cells = [(label, fit_h(src)), ('delivery as built (CPU, unbaked)', fit_h(Image.open(cap / (name + '.png')).convert('RGB')))]
    if both:
        cells.append(("same, piano door's west leaf hidden", fit_h(Image.open(cap / (name + '-without-piano-west-leaf.png')).convert('RGB'))))
    sheet = Image.new('RGB', (sum(im.width for _, im in cells) + 12 * (len(cells) + 1), H + 40), (245, 245, 245)); d = ImageDraw.Draw(sheet); x = 12
    for text, im in cells:
        sheet.paste(im, (x, 30)); d.text((x, 8), text, fill=(0, 0, 0)); x += im.width + 12
    sheet.save(out / ('capture-%s.jpg' % name), quality=90)
# The Hall door's two leaves in the source: west leaf beside the small painting, east leaf from the other side.
cells = [('100.0 s: Hall opening, WEST leaf, small painting, connector door', fit_h(upright(201))), ('101.0 s: west leaf, painting, corner, connector', fit_h(upright(203))),
         ('105.0 s: label, small painting, corner casing', fit_h(upright(211))), ('106.0 s: EAST leaf at the left jamb; placard and painting to the west', fit_h(upright(213))),
         ('103.0 s: through the connector, "5" on the north side', fit_h(upright(207)))]
sheet = Image.new('RGB', (sum(im.width for _, im in cells) + 12 * (len(cells) + 1), H + 40), (245, 245, 245)); d = ImageDraw.Draw(sheet); x = 12
for text, im in cells:
    sheet.paste(im, (x, 30)); d.text((x, 8), text[:int(im.width / 5.6)], fill=(0, 0, 0)); x += im.width + 12
sheet.save(out / 'source-hall-door-leaves-6380-100-106s.jpg', quality=90)
