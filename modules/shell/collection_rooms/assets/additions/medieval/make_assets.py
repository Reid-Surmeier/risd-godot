"""Cut-out fronts and outlines for the medieval room additions (#238). No paid calls.

Run: /usr/bin/python3 make_assets.py ORIGINALS MASKS
  ORIGINALS  the six catalogue photographs named <accession digits>-0.jpg, fetched from the
             picturepark URLs in SOURCES.md
  MASKS      one white-on-black PNG per object (head, relief, cross, peter, anthony, angel),
             cut with OpenCV GrabCut or a colour threshold and checked by eye
Writes beside this file: <accession>-front.jpg (the catalogue photograph, for the detail view),
<key>-cut.jpg (the object alone on its own median colour) and shapes.json (outline, aspect).
"""
import json, sys
from pathlib import Path
import cv2, numpy as np
src, masks = Path(sys.argv[1]), Path(sys.argv[2]); out = Path(__file__).parent
rows = {'head': '59131', 'relief': '69196', 'cross': '43195', 'peter': '20254', 'anthony': '16243', 'angel': '37114'}
shapes = {}
for key, digits in rows.items():
    image = cv2.imread(str(src/f'{digits}-0.jpg')); mask = (cv2.imread(str(masks/f'{key}.png'), 0) > 127).astype('uint8')
    assert image.shape[:2] == mask.shape
    contour = max(cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE)[0], key=cv2.contourArea)
    x, y, w, h = cv2.boundingRect(contour)
    poly = cv2.approxPolyDP(contour, 0.004*max(w, h), True)[:, 0, :]
    assert 5 <= len(poly) <= 220, (key, len(poly))
    crop = image[y:y+h, x:x+w].copy(); inside = mask[y:y+h, x:x+w] > 0
    crop[~inside] = np.median(crop[inside], axis=0)   # no studio backdrop in the texture's margins
    scale = min(1.0, 1024/max(w, h))
    cv2.imwrite(str(out/f'{key}-cut.jpg'), cv2.resize(crop, None, fx=scale, fy=scale, interpolation=cv2.INTER_AREA), [cv2.IMWRITE_JPEG_QUALITY, 86])
    front = cv2.resize(image, None, fx=min(1.0, 1600/max(image.shape[:2])), fy=min(1.0, 1600/max(image.shape[:2])), interpolation=cv2.INTER_AREA)
    acc = {'59131': '59.131', '69196': '69.196', '43195': '43.195', '20254': '20.254', '16243': '16.243', '37114': '37.114'}[digits]
    cv2.imwrite(str(out/f'{acc}-front.jpg'), front, [cv2.IMWRITE_JPEG_QUALITY, 84])
    shapes[key] = {'accession': acc, 'aspect': round(w/h, 5), 'outline': [[round((px-x)/w, 4), round((py-y)/h, 4)] for px, py in poly.tolist()]}
(out/'shapes.json').write_text(json.dumps(shapes, indent=1) + '\n')
print({k: (v['aspect'], len(v['outline'])) for k, v in shapes.items()})
