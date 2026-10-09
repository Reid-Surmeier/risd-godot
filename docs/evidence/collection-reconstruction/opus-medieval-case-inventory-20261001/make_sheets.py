"""Side-by-side comparison sheets: native IMG_6382 crops (left, timecoded) beside official RISD photographs (right)."""
from pathlib import Path
from PIL import Image, ImageDraw
here = Path(__file__).parent; H = 640
OBJ = {
 'T1-virgin-and-child-15.108': ([('102.20',(540,510,715,930)),('105.70',(505,525,700,850)),('108.90',(390,480,550,900)),('110.50',(400,430,625,945)),('111.70',(455,430,660,790)),('112.90',(575,470,755,855))],
    ['virgin-and-child-15108-zoom-0','virgin-and-child-15108-zoom-1','virgin-and-child-15108-zoom-2','virgin-and-child-15108-zoom-3']),
 'T2-god-save-the-queens-2020.55': ([('102.20',(355,785,495,1035)),('105.70',(435,790,570,1055)),('108.90',(605,795,735,1070)),('110.50',(715,775,895,1135))],
    ['god-save-queens-202055-zoom-0','god-save-queens-202055-zoom-1','god-save-queens-202055-zoom-2']),
 'T3-monstrance-40.002': ([('102.20',(200,690,335,1010)),('105.70',(195,790,335,1250)),('107.30',(455,780,635,1315))], ['monstrance-40002-zoom-0','monstrance-40002-zoom-2']),
 'T4-communion-beaker-1992.051': ([('102.20',(30,970,150,1110)),('103.70',(160,1070,265,1240)),('105.70',(510,1150,645,1345)),('107.30',(835,1040,950,1215))],
    ['communion-beaker-1992051-zoom-0','communion-beaker-1992051-zoom-3','kiddush-cup-201617-zoom-0','beaker-1991033-zoom-0']),
 'T5-pyx-30.011': ([('102.20',(200,975,280,1045)),('103.70',(270,1050,350,1130)),('105.70',(415,1125,525,1240)),('107.30',(650,1095,745,1185)),('110.50',(905,955,985,1030))], ['pyx-30011-zoom-0','pyx-30011-zoom-1']),
 'T6-christ-in-majesty-2014.110': ([('102.20',(130,1030,250,1175)),('103.70',(380,1085,475,1250)),('105.70',(605,1070,790,1200)),('107.30',(735,995,875,1100))], ['christ-majesty-2014110-zoom-0']),
 'T7-pax-52.002': ([('102.20',(465,940,585,1065)),('103.70',(735,900,845,1045)),('105.70',(715,800,800,895)),('107.30',(615,755,700,840)),('111.70',(380,770,475,860))], ['pax-52002-zoom-0','pax-52002-zoom-1']),
 'L-low-case-prints-unidentified': ([('000.00',(0,1350,1080,1920)),('095.10',(440,640,1080,1160)),('096.94',(440,640,1080,1160)),('097.70',(540,560,1080,1000))], []),
}
def tile(im, label):
    im = im.resize((max(1, round(im.width * H / im.height)), H), Image.LANCZOS)
    t = Image.new('RGB', (im.width, H + 22), 'white'); t.paste(im, (0, 22)); ImageDraw.Draw(t).text((3, 5), label, fill='black'); return t
for name, (crops, photos) in OBJ.items():
    ts = [tile(Image.open(here / 'frames' / f'IMG_6382-{t}.jpg').crop(b), f'SOURCE IMG_6382 {float(t):.2f}s') for t, b in crops]
    ts += [tile(Image.open(here / 'photos' / f'{p}.jpg'), f'RISD {p}') for p in photos]
    s = Image.new('RGB', (sum(t.width for t in ts) + 6 * len(ts), H + 22), 'white'); x = 0
    for t in ts: s.paste(t, (x, 0)); x += t.width + 6
    s.save(here / 'sheets' / f'{name}.jpg', quality=90); print(name, s.size)
# Slot overview: whole frames with slot ids at the objects (ids only; no identification is drawn into the source).
SLOTS = {
 '102.20': {'T1':(625,505),'T2':(425,770),'T3':(265,672),'T4':(60,955),'T5':(240,962),'T6':(150,1180),'T7':(540,1070)},
 '105.70': {'T1':(600,515),'T2':(500,780),'T3':(215,775),'T4':(585,1345),'T5':(440,1240),'T6':(790,1130),'T7':(790,790)},
 '110.50': {'T1':(500,430),'T2':(790,760),'T4':(930,825),'T5':(960,1030)},
 '096.94': {'L1':(650,700),'L2':(900,700)},
 '000.00': {'L2':(60,1500),'L1':(480,1500)},
}
ts = []
for t, marks in SLOTS.items():
    im = Image.open(here / 'frames' / f'IMG_6382-{t}.jpg').convert('RGB').resize((720, 1280), Image.LANCZOS)
    fr = Image.new('RGB', (720, 1302), 'white'); fr.paste(im, (0, 22)); d = ImageDraw.Draw(fr); d.text((3, 5), f'SOURCE IMG_6382 {float(t):.2f}s', fill='black')
    for k, (x, y) in marks.items():
        x, y = x * 2 // 3, y * 2 // 3 + 22; d.rectangle([x - 3, y - 2, x + 16, y + 12], fill='yellow'); d.text((x, y), k, fill='black')
    ts.append(fr)
s = Image.new('RGB', (726 * len(ts), 1302), 'white')
for i, t in enumerate(ts): s.paste(t, (726 * i, 0))
s.save(here / 'sheets' / 'overview-slots.jpg', quality=88); print('overview', s.size)
