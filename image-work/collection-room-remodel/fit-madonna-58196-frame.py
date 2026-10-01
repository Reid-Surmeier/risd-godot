"""Fit the one Muse frame's three colour bands to the existing closed source-read frame.
Generated texture only; no artwork pixels enter these strips. Replay is byte-checked.
"""
from pathlib import Path
import hashlib, json
import cv2
import numpy as np
from PIL import Image

app = Path(__file__).resolve().parent
native = app / 'trial/madonna-58196-frame-original.webp'
assert hashlib.sha256(native.read_bytes()).hexdigest() == 'ace672e922caa71f86c4c9b2b3429b3c0ffa6a2f67128a10c2bcaf68db7e541d'
image = np.array(Image.open(native).convert('RGB'))
assert image.shape == (1600, 1600, 3)
u = (np.arange(880) + .5) / 880
v = (np.arange(64) + .5) / 64
# Same inner-to-outer band convention and 880x64 strip UVs as the existing wall helper.
stops = np.cumsum([0, .018, .029, .030]) / .077
edges = {'left': (375, 318, 180, 112), 'right': (1224, 1280, 1418, 1489),
         'top': (376, 319, 181, 108), 'bottom': (1235, 1293, 1431, 1502)}
output = app / 'trial/madonna-58196-frame-strips'
output.mkdir(exist_ok=True)
hashes = {}
for side, points in edges.items():
    inward = 1 if side in ['right', 'bottom'] else -1
    reach = np.interp(v, stops, [points[0]+inward*2, *points[1:3], points[3]-inward*3])
    if side == 'bottom': mx, my = np.meshgrid(112 + u*1377, reach)
    elif side == 'top': mx, my = np.meshgrid(1489 - u*1377, reach)
    elif side == 'right': my, mx = np.meshgrid(1502 - u*1394, reach)
    else: my, mx = np.meshgrid(108 + u*1394, reach)
    strip = cv2.remap(image, mx.astype(np.float32), my.astype(np.float32), cv2.INTER_LINEAR)
    path = output / f'frame-58196-{side}.png'
    Image.fromarray(strip).save(path)
    hashes[path.name] = hashlib.sha256(path.read_bytes()).hexdigest()
ledger = app / 'madonna-58196-frame-strip-hashes.json'
if ledger.exists(): assert json.loads(ledger.read_text()) == hashes, 'Texture replay changed bytes'
ledger.write_text(json.dumps(hashes, indent=2)+'\n')
print('MUSE_FRAME_STRIPS_OK', len(hashes), 'generated frame only; fidelity unaccepted')
