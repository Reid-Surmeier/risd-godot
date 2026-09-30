"""Pinned visual regression signal; use matched frontal entry captures."""
from pathlib import Path
from PIL import Image

root = Path(__file__).parent
paths = [root.parent / 'pure-values-219/browser-integrated/tab-4.png',
         root / 'browser-integrated/tab-4.png']
fractions = []
for path in paths:
    crop = Image.open(path).convert('RGB').crop((516, 542, 559, 578))
    pixels = list(crop.getdata())
    fractions.append(sum(g-r > 8 and g-b > 5 for r, g, b in pixels) / len(pixels))
print('Pinned torso green coverage:', fractions)
assert abs(fractions[0] - fractions[1]) < .05, 'visitor torso consistency FAIL'
