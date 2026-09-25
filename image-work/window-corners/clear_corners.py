"""Owner, 2026-09-25: many window pictures are square crops, the page's background still filling the area
outside their rounded corners, so the corners (and the drop shadows) read as rectangles. For each corner:
walk the diagonal in from the corner until the frame's outline starts (the corner radius follows from
that), then clear, within that corner's square only, the pixels connected to the corner that match its
colour; the rim is feathered. Pixels inside the frame are never touched; only alpha changes, plus
un-mixing the cleared colour out of the feathered rim. Writes a before/after sheet of the corners."""
import sys, collections
import numpy as np
from PIL import Image

TOL = 34  # colour distance still counted as background
FEATHER = 30  # beyond TOL, the rim fades over this much distance

M = np.array([255.0, 0.0, 255.0])

def magenta_key(a):
    """Sprite-key magenta and its bleed, flooded in from the border: alpha falls with how magenta a pixel
    is (min(r, b) - g), and the magenta is un-mixed out of the colour that is left."""
    h, w = a.shape[:2]
    m = np.minimum(a[..., 0], a[..., 2]) - a[..., 1]
    k = np.clip((m - 30) / 180, 0, 1) * (a[..., 3] > 0)
    clear_px = a[..., 3] < 16
    edge = np.zeros((h, w), bool); edge[0, :] = edge[-1, :] = edge[:, 0] = edge[:, -1] = True
    near_clear = np.zeros((h, w), bool)
    near_clear[1:, :] |= clear_px[:-1, :]; near_clear[:-1, :] |= clear_px[1:, :]
    near_clear[:, 1:] |= clear_px[:, :-1]; near_clear[:, :-1] |= clear_px[:, 1:]
    seen = (edge | near_clear) & (k > 0.15)
    q = collections.deque((x, y) for y, x in zip(*np.nonzero(seen)))
    while q:
        x, y = q.popleft()
        kk = k[y, x]
        a[y, x, :3] = np.clip((a[y, x, :3] - kk * M) / max(1 - kk, 0.05), 0, 255)
        a[y, x, 3] = min(a[y, x, 3], 255 * (1 - kk))
        for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
            if 0 <= nx < w and 0 <= ny < h and not seen[ny, nx] and k[ny, nx] > 0.15:
                seen[ny, nx] = True; q.append((nx, ny))
    return int(seen.sum())

def clear(path):
    im = Image.open(path).convert('RGBA'); a = np.asarray(im).astype(float)
    h, w = a.shape[:2]
    report = []
    alpha = a[..., 3].copy()
    for cx, cy, dx, dy in ((0, 0, 1, 1), (w - 1, 0, -1, 1), (0, h - 1, 1, -1), (w - 1, h - 1, -1, -1)):
        seed = a[cy, cx, :3]
        if a[cy, cx, 3] < 128:
            report.append('clear'); continue
        d = 0
        while d < min(w, h) // 3 and np.linalg.norm(a[cy + dy * d, cx + dx * d, :3] - seed) < TOL:
            d += 1
        if d == 0 or d >= min(w, h) // 3:
            report.append('square'); continue
        zone = int(d * 3.5) + 3  # the radius of a rounded corner is ~3.4 x its diagonal gap
        if zone > 0.15 * min(w, h):  # that large, it is the window's own flat chrome, not a corner
            report.append('square'); continue
        seen = np.zeros((zone, zone), bool); q = collections.deque([(0, 0)]); seen[0, 0] = True
        while q:
            i, j = q.popleft()
            x, y = cx + dx * i, cy + dy * j
            dist = np.linalg.norm(a[y, x, :3] - seed)
            if dist < TOL:
                alpha[y, x] = 0
                for ni, nj in ((i + 1, j), (i - 1, j), (i, j + 1), (i, j - 1)):
                    if 0 <= ni < zone and 0 <= nj < zone and not seen[nj, ni]:
                        seen[nj, ni] = True; q.append((ni, nj))
            elif dist < TOL + FEATHER:  # the rim: part background, part frame
                k = (dist - TOL) / FEATHER
                alpha[y, x] = min(alpha[y, x], 255 * k)
                a[y, x, :3] = np.clip((a[y, x, :3] - (1 - k) * seed) / max(k, 0.05), 0, 255)
        report.append(f'r~{int(d * 3.4)}')
    a[..., 3] = alpha
    keyed = magenta_key(a)  # sprite-key magenta (and its bleed), from the border and the cleared corners
    if keyed:
        report.append(f'magenta {keyed} px')
    return im, Image.fromarray(a.astype(np.uint8), 'RGBA'), report

if __name__ == '__main__':
    before_after = []
    for p in sys.argv[1:]:
        before, after, report = clear(p)
        print(p, report)
        if 'r~' in ' '.join(report) or 'magenta' in ' '.join(report):
            ext = p.rsplit('.', 1)[1].lower()
            after.save(p, **({'lossless': True} if ext == 'webp' else {}))
            before_after.append((before, after))
    T = 110
    sheet = Image.new('RGB', (len(before_after) * (T * 2 + 8), T * 2 + 8), (0, 150, 0))
    for i, (b, a) in enumerate(before_after):
        n = max(12, min(b.size) // 12)
        for row, im in enumerate((b, a)):
            g = Image.new('RGBA', im.size, (0, 150, 0, 255)); g.alpha_composite(im)
            sheet.paste(g.crop((0, 0, n, n)).resize((T, T), Image.NEAREST).convert('RGB'), (i * (T * 2 + 8), row * (T + 8)))
            sheet.paste(g.crop((im.width - n, im.height - n, im.width, im.height)).resize((T, T), Image.NEAREST).convert('RGB'), (i * (T * 2 + 8) + T, row * (T + 8)))
    sheet.save('image-work/window-corners/before-after.png')
