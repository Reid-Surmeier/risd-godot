"""Recompute manual landmark ratios and draw evidence overlays; no game assets modified."""
import json
from pathlib import Path
from PIL import Image, ImageDraw

root = Path(__file__).parent
for name, row in json.loads((root / 'measurements.json').read_text()).items():
    im = Image.open(root / (name + '-viewport.png')).convert('RGB')
    w, h = im.size
    x0, y0, x1, y1 = row['character']
    assert 0 <= x0 < x1 <= w and 0 <= y0 < y1 <= h
    assert (w, h) == (row['crop'][2] - row['crop'][0], row['crop'][3] - row['crop'][1])
    print(f'{name}: height={(y1-y0)/h:.3%}, width={(x1-x0)/w:.3%}, feet_y={y1/h:.3%}, bbox_center_x={(x0+x1)/2/w:.3%}, floor_join={row["floor_join_y"]/h:.3%}')
    draw = ImageDraw.Draw(im)
    draw.rectangle(row['character'], outline='#ff2de0', width=max(2,w//500))
    draw.line((0,row['floor_join_y'],w,row['floor_join_y']),fill='#00ddff',width=max(2,w//500))
    im.thumbnail((1000,1000))
    im.save(root / (name + '-annotated.png'))
