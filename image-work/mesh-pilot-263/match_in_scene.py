"""Lift a colour texture so the object, as the game lights it, comes out as bright and as warm as the catalogue photograph.
usage: match_in_scene.py CATALOGUE_CUT.png RENDER_FRONT.png TEXTURE_IN.png TEXTURE_OUT.png
The game's light is dimmer and warmer than a studio flash, so a texture that matches the photograph still renders
darker and browner. One gain per channel (in linear light, capped at 1.8) is measured from the front render, over the brighter
half of the figure in each picture, and applied to the texture. Free. Run again after re-rendering if the first pass is not close."""
import sys, numpy as np, cv2
from PIL import Image
cat, render, tin, tout = sys.argv[1:5]
lin = lambda v: np.where(v <= 0.04045, v / 12.92, ((v + 0.055) / 1.055) ** 2.4); srgb = lambda v: np.where(v <= 0.0031308, v * 12.92, 1.055 * np.clip(v, 0, None) ** (1 / 2.4) - 0.055)
def lit(px):  # the lit half only: the photograph's average includes its own studio shadow, and matching that came out brown
    lum = px @ np.array([0.2126, 0.7152, 0.0722]); return px[lum >= np.median(lum)].mean(0)
c = np.array(Image.open(cat).convert("RGBA")); target = lit(lin(c[..., :3][c[..., 3] > 200] / 255.0))
r = np.array(Image.open(render).convert("RGB")); hsv = cv2.cvtColor(r, cv2.COLOR_RGB2HSV); h, w = hsv.shape[:2]
m = np.zeros((h, w), bool); m[int(h * .08):int(h * .62), int(w * .3):int(w * .7)] = True; m &= (hsv[..., 1] > 55) | (hsv[..., 2] < 150)  # the figure, not wall or plinth
got = lit(lin(r[m] / 255.0)); gain = np.clip(target / got, 0.6, 1.8)
t = np.array(Image.open(tin).convert("RGB")) / 255.0; Image.fromarray((srgb(lin(t) * gain).clip(0, 1) * 255).astype(np.uint8)).save(tout)
print("object pixels", int(m.sum()), "| photograph (linear)", np.round(target, 3), "render", np.round(got, 3), "gain", np.round(gain, 2))
