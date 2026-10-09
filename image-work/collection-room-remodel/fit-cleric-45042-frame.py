"""Fit the saved Muse moulding to revised video bands; no generation or artwork editing."""
from pathlib import Path
import hashlib
import cv2
import numpy as np

app = Path(__file__).resolve().parent
native = app / 'trial/cleric-45042-frame-original.webp'
assert hashlib.sha256(native.read_bytes()).hexdigest() == '06fd8563acabbecaf05704c5c1348d1ff05db36410f9faeeadc251b133efde2c'
image = cv2.imread(str(native))[118:1550, 101:1178]
x = np.interp(np.linspace(0, 1, 960), [0, .044/.234, 1-.044/.234, 1], [0, 225/1077, 856/1077, 1])
y = np.interp(np.linspace(0, 1, 1321), [0, .05/.322, 1-.05/.322, 1], [0, 232/1432, 1178/1432, 1])
mx, my = np.meshgrid(x * (image.shape[1]-1), y * (image.shape[0]-1))
fitted = cv2.remap(image, mx.astype('float32'), my.astype('float32'), cv2.INTER_LINEAR)
assert fitted.shape == (1321, 960, 3) and np.isfinite(fitted).all()
output = app / 'trial/cleric-45042-frame-fitted.png'
assert cv2.imwrite(str(output), fitted)
print(hashlib.sha256(output.read_bytes()).hexdigest())
