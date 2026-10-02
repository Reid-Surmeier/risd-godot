"""Side-by-side comparison sheets: native IMG_6383 crops (left, timecoded) beside official RISD photographs (right)."""
from pathlib import Path
from PIL import Image, ImageDraw
here = Path(__file__).parent; H = 640
OBJ = {
 'R01-velvet-cover-23.307X': ([('6.10', (600, 400, 940, 1120))], ['velvet-cover-23307x-zoom-0', 'velvet-cover-23307x-zoom-1']),
 'R01-rejected-textile-length-52.110': ([('6.10', (600, 400, 940, 1120))], ['textile-length-52110-zoom-0']),
 'R02-tapestry-29.280': ([('11.50', (90, 240, 870, 1480))], ['woodcutters-29280-zoom-0', 'woodcutters-29280-zoom-1']),
 'R03-painting-58.196': ([('15.10', (270, 510, 1040, 1300))], ['madonna-and-child-saint-barbara-and-saint-catherine-58196-zoom-0']),
 'R04-saint-roch-21.398': ([('18.30', (300, 300, 900, 1400)), ('20.60', (300, 400, 820, 1380)), ('21.30', (250, 250, 850, 1300))], ['saint-roch-21398-zoom-0', 'saint-roch-21398-zoom-1', 'saint-roch-21398-zoom-2', 'saint-roch-21398-zoom-3']),
 'R05-pieta-59.128': ([('24.60', (240, 650, 760, 1340))], ['pieta-59128-zoom-0', 'pieta-59128-zoom-1', 'pieta-59128-zoom-2', 'pieta-59128-zoom-3']),
 'R06-triptych-2021.131': ([('30.20', (30, 500, 1080, 1480))], ['madonna-enthroned-saints-and-angels-2021131-zoom-0', 'madonna-enthroned-saints-and-angels-2021131-zoom-1', 'madonna-enthroned-saints-and-angels-2021131-zoom-2']),
 'R08-portrait-man-45.042': ([('41.20', (340, 700, 610, 1050)), ('49.80', (300, 550, 790, 1130))], ['portrait-cleric-45042-zoom-0']),
 'R09-portrait-woman-34.861': ([('41.20', (670, 660, 940, 1070)), ('46.40', (0, 0, 680, 800))], ['portrait-woman-34861-zoom-0', 'portrait-woman-34861-zoom-1']),
 'R10-diptych-22.201': ([('41.20', (220, 1090, 560, 1370)), ('49.80', (0, 1220, 620, 1790))], ['diptych-scenes-nativity-crucifixion-and-last-judgement-22201-zoom-0', 'diptych-scenes-nativity-crucifixion-and-last-judgement-22201-zoom-1']),
 'R11-book-cover-34.016': ([('41.20', (560, 980, 740, 1320)), ('49.80', (640, 1130, 960, 1760))], ['book-cover-34016-zoom-0', 'book-cover-34016-zoom-1']),
 'R12-emblem-book-label-only': ([('41.20', (700, 1050, 1040, 1310)), ('46.40', (0, 840, 500, 1300))], []),
 'R13-albarello-35.713': ([('46.40', (560, 760, 900, 1340))], ['drug-jar-albarello-35713-zoom-0', 'drug-jar-albarello-35713-zoom-1']),
 'R14-R15-bella-donna-plates': ([('56.00', (310, 500, 690, 940)), ('56.00', (780, 620, 1080, 970))], ['bella-donna-plate-57302-zoom-0', 'bella-donna-plate-46391-zoom-0']),
 'R16-death-of-the-virgin-51.105': ([('56.00', (280, 1230, 540, 1490))], ['death-virgin-51105-zoom-0', 'death-virgin-51105-zoom-1']),
 'R17-glass-roundel-2017.29': ([('56.00', (630, 1050, 970, 1440))], ['virgin-woman-apocalypse-201729-zoom-0', 'virgin-woman-apocalypse-201729-zoom-1']),
 'R18-enamel-plaque-34.024': ([('56.00', (940, 1090, 1080, 1300)), ('57.00', (0, 900, 1080, 1700))], ['virgin-and-child-clerics-and-donors-34024-zoom-0']),
}
def tile(im, label):
    im = im.convert('RGB').resize((max(1, round(im.width * H / im.height)), H), Image.LANCZOS)
    t = Image.new('RGB', (im.width, H + 22), 'white'); t.paste(im, (0, 22)); ImageDraw.Draw(t).text((3, 5), label, fill='black'); return t
def row(name, ts):
    s = Image.new('RGB', (sum(t.width for t in ts) + 6 * len(ts), H + 22), 'white'); x = 0
    for t in ts: s.paste(t, (x, 0)); x += t.width + 6
    s.save(here / 'sheets' / f'{name}.jpg', quality=90); print(name, s.size)
if __name__ == '__main__':
    for name, (crops, photos) in OBJ.items():
        row(name, [tile(Image.open(here / 'frames' / f'IMG_6383-{float(t):06.2f}.jpg').crop(b), f'SOURCE IMG_6383 {float(t):.2f}s') for t, b in crops]
            + [tile(Image.open(here / 'photos' / f'{p}.jpg'), f'RISD {p}'[:70]) for p in photos])
    # Case and wall labels at 2x: the text that was actually read.
    LABELS = [('24.60', (250, 1400, 800, 1700)), ('30.00', (500, 1480, 1080, 1680)), ('41.10', (150, 1380, 1080, 1560)), ('45.70', (0, 1380, 1000, 1680)),
              ('46.40', (0, 1380, 1000, 1680)), ('55.60', (150, 1500, 1080, 1800)), ('56.00', (60, 1650, 1080, 1920)), ('56.50', (0, 1500, 1080, 1800))]
    ts = []
    for t, b in LABELS:
        c = Image.open(here / 'frames' / f'IMG_6383-{float(t):06.2f}.jpg').crop(b); c = c.resize((c.width * 2, c.height * 2), Image.LANCZOS)
        ImageDraw.Draw(c).text((4, 4), f'SOURCE IMG_6383 {float(t):.2f}s', fill='red'); ts.append(c)
    s = Image.new('RGB', (max(t.width for t in ts), sum(t.height for t in ts)), 'white'); y = 0
    for t in ts: s.paste(t, (0, y)); y += t.height
    s.save(here / 'sheets' / 'labels-read.jpg', quality=92); print('labels', s.size)
    # Wall order: whole frames with slot ids only (no identification is drawn into the source).
    SLOTS = {'68.50': {'R01': (60, 500), 'R02': (640, 500)}, '60.60': {'R02': (120, 460), 'R03': (620, 620), 'R04': (940, 700)},
             '62.00': {'R04': (190, 700), 'R05': (450, 700), 'R06': (760, 680)}, '63.90': {'R06': (30, 760), 'R07 built': (800, 640)},
             '64.90': {'R07 built': (300, 640), 'case A': (640, 610)}, '66.30': {'case A': (20, 680), 'case B': (850, 650)},
             '41.20': {'R08': (400, 640), 'R09': (700, 600), 'R10': (300, 1040), 'R11': (600, 940), 'R12': (800, 1010), 'R13': (980, 960)},
             '56.00': {'R14': (360, 470), 'R15': (850, 600), 'R16': (300, 1200), 'R17': (700, 1040), 'R18': (980, 1060)}}
    ts = []
    for t, marks in SLOTS.items():
        im = Image.open(here / 'frames' / f'IMG_6383-{float(t):06.2f}.jpg').convert('RGB').resize((540, 960), Image.LANCZOS)
        fr = Image.new('RGB', (540, 982), 'white'); fr.paste(im, (0, 22)); d = ImageDraw.Draw(fr); d.text((3, 5), f'SOURCE IMG_6383 {float(t):.2f}s', fill='black')
        for k, (x, y) in marks.items():
            x, y = x // 2, y // 2 + 22; d.rectangle([x - 3, y - 2, x + 6 * len(k) + 3, y + 12], fill='yellow'); d.text((x, y), k, fill='black')
        ts.append(fr)
    s = Image.new('RGB', (546 * 4, 988 * 2), 'white')
    for i, t in enumerate(ts): s.paste(t, (546 * (i % 4), 988 * (i // 4)))
    s.save(here / 'sheets' / 'overview-wall-order.jpg', quality=88); print('overview', s.size)
