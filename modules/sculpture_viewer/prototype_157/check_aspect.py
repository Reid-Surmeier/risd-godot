"""Compare displayed object proportions to its actual rendered texture."""
import json
import sys
from pathlib import Path
from PIL import Image, ImageChops, ImageStat

before, after = map(Path, sys.argv[1:3])
rows = []

def ratio(image):
    mask = image.convert('RGB')
    points = [(x, y) for y in range(mask.height) for x in range(mask.width)
              if max(mask.getpixel((x, y))) < 235]
    assert points, 'object silhouette missing'
    xs, ys = zip(*points)
    return (max(xs) - min(xs) + 1) / (max(ys) - min(ys) + 1)

for width in (720, 1600):
    reference = ratio(Image.open(after / 'native' / f'{width}-reference.png'))
    art = tuple(round(n * width / 1080) for n in (56, 747, 331, 967))
    cards = tuple(round(n * width / 1080) for n in (468, 184, 1031, 860))
    for platform in ('native', 'browser'):
        original = Image.open(before / platform / f'{width}-03.png').convert('RGB')
        corrected = Image.open(after / platform / f'{width}-03.png').convert('RGB')
        old_ratio = ratio(original.crop(art)) / reference
        new_ratio = ratio(corrected.crop(art)) / reference
        assert abs(new_ratio - 1) < .03, (platform, width, new_ratio)
        assert abs(old_ratio - 1) > .20, 'baseline no longer reproduces distortion'
        assert max(ImageStat.Stat(ImageChops.difference(original.crop(cards), corrected.crop(cards))).mean) < .2
        for index in (6, 7, 8):
            a = Image.open(before / platform / f'{width}-{index:02d}.png').convert('RGB')
            b = Image.open(after / platform / f'{width}-{index:02d}.png').convert('RGB')
            assert max(ImageStat.Stat(ImageChops.difference(a, b)).mean) < .2, (platform, width, index)
        rows.append({'platform': platform, 'width': width, 'beforeRelativeAspect': old_ratio, 'afterRelativeAspect': new_ratio, 'heldStatesAndCardsUnchanged': True})
print(json.dumps(rows, indent=2))
