"""The owner's Collection page picture (source.png, 2026-09-25) -> modules/shell/assets/collection_frame/page.png:
cut away the window edges along the picture's borders, crop to the frame and clock with a little air,
white ground made clear (the Page is white). No pixel inside the frame or clock is changed."""
from PIL import Image
import numpy as np
a = np.asarray(Image.open('image-work/collection-frame/source.png').convert('RGB')).astype(int)
H, W = a.shape[:2]
ink = (255 - a.min(2)) > 40
BAND = 90  # px along every border: window edges and screenshot lines, not content
ink[:BAND] = ink[-BAND:] = False; ink[:, :BAND] = ink[:, -BAND:] = False
ys, xs = np.nonzero(ink)
y0, y1, x0, x1 = ys.min(), ys.max(), xs.min(), xs.max()
pad = int(0.03 * (y1 - y0))
crop = a[max(0, y0 - pad): y1 + pad + 1, max(0, x0 - pad): x1 + pad + 1]
alpha = np.clip((255 - crop.min(2)) * 12, 0, 255)
out = Image.fromarray(np.dstack([crop, alpha]).astype(np.uint8), 'RGBA')
out.save('modules/shell/assets/collection_frame/page.png', optimize=True)
print('content', (x0, y0, x1, y1), '->', out.size)
