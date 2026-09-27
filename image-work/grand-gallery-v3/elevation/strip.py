"""One wall elevation -> game data: level it on the skirting, scale it by the camera height, find the paintings,
write a low-res wall strip and a sharp detail image per painting (from the best single frame).
usage: strip.py <name> <sparse model> <images dir> <out dir> <t0 s> <fps>"""
import sys, json, numpy as np, cv2, pycolmap

name, model, imgdir, out = sys.argv[1:5]
t0 = float(sys.argv[5]); fps = float(sys.argv[6])   # the model's image 0001 is video time t0, at fps
cam_h = 1.40
def full_frame(name):  # the same ffmpeg sampling as the model's frames, at full resolution
    return cv2.imread(f"{imgdir}-full/{name}")

im = cv2.imread(f"{name}-elevation.png"); meta = json.load(open(f"{name}-elevation.json"))
H, W = im.shape[:2]; ppm0 = meta["ppm"]

# 1. level: fit the skirting's top edge (first bright, unsaturated row per column, in the lower half)
hsv = cv2.cvtColor(im, cv2.COLOR_BGR2HSV)
white = (hsv[..., 1] < 50) & (hsv[..., 2] > 150)
xs, ys = [], []
for x in range(0, W, 8):
    col = np.where(white[H // 2:, x])[0]
    if len(col): xs.append(x); ys.append(H // 2 + col[0])
a, b = np.polyfit(xs, ys, 1) if len(xs) > 10 else (0.0, H * 0.8)
ang = np.degrees(np.arctan(a))
M = cv2.getRotationMatrix2D((W / 2, a * W / 2 + b), ang, 1.0)
im = cv2.warpAffine(im, M, (W, H), flags=cv2.INTER_LINEAR, borderValue=(0, 0, 0))
skirt_top = int(a * W / 2 + b)

# 2. floor line: first row below the skirting where most covered pixels are floor-coloured
hsv = cv2.cvtColor(im, cv2.COLOR_BGR2HSV)
cover = im.sum(2) > 0
floorish = (hsv[..., 0] < 28) & (hsv[..., 1] > 55) & cover
floor_row = next((r for r in range(skirt_top, H) if floorish[r].sum() > 0.5 * max(1, cover[r].sum())), min(H - 1, skirt_top + 30))
cam_row = meta["camera_row_median"]
mpp = cam_h / max(1.0, floor_row - cam_row)  # metres per elevation pixel
print(f"{name}: tilt {ang:.2f} deg, skirting {skirt_top}, floor {floor_row}, camera {cam_row:.0f} -> {1 / mpp:.0f} px/m")

# 3. paintings: textured blobs on the smooth wall, above the skirting
g = cv2.cvtColor(im, cv2.COLOR_BGR2GRAY).astype(np.float32)
mag = cv2.magnitude(cv2.Sobel(g, cv2.CV_32F, 1, 0), cv2.Sobel(g, cv2.CV_32F, 0, 1))
tex = cv2.blur(mag, (21, 21))
thr = float(np.clip(np.percentile(tex[:skirt_top][cover[:skirt_top]] if cover[:skirt_top].any() else tex, 62), 10, 30))
m = ((tex > thr) & cover).astype(np.uint8) * 255
m[skirt_top - 6:] = 0
m = cv2.morphologyEx(m, cv2.MORPH_CLOSE, np.ones((9, 9), np.uint8))
holes = m.copy(); ff = np.zeros((H + 2, W + 2), np.uint8); cv2.floodFill(holes, ff, (0, H - 1), 255)
m = m | cv2.bitwise_not(holes)                      # every closed frame outline filled solid
k = max(9, int(0.12 / mpp)) | 1                     # cut seams and hanging wires thinner than ~12 cm
m = cv2.morphologyEx(m, cv2.MORPH_OPEN, cv2.getStructuringElement(cv2.MORPH_RECT, (k, k)))
n, lab, st, _ = cv2.connectedComponentsWithStats(m)
rects = []
for i in range(1, n):
    x, y, w, h, area = st[i]
    if w * mpp < 0.35 or h * mpp < 0.35 or area / (w * h) < 0.55 or w * mpp > 4.5: continue
    if x <= 2 or x + w >= W - 2: continue  # cut off by the strip's end
    rects.append((int(x), int(y), int(w), int(h)))
import os
if os.path.exists(f"{name}-rects.json"):  # rectangles marked by eye (fractions of the levelled strip) replace detection
    rects = [(int(a * W), int(b * H), int((c - a) * W), int((d - b) * H)) for a, b, c, d in json.load(open(f"{name}-rects.json"))]
rects.sort()
merged = []  # one painting split into pieces (a shaped canvas): union boxes that share most of their width
for r in rects:
    if merged:
        x, y, w, h = merged[-1]
        ov = min(x + w, r[0] + r[2]) - max(x, r[0])
        if ov > 0.5 * min(w, r[2]):
            nx, ny = min(x, r[0]), min(y, r[1]); merged[-1] = (nx, ny, max(x + w, r[0] + r[2]) - nx, max(y + h, r[1] + r[3]) - ny); continue
    merged.append(r)
rects = merged

# 4. the wall strip, low-res: covered wall from the top of coverage to the floor, uncovered = wall colour
rows = np.where(cover[:floor_row].mean(1) > 0.3)[0]; top = int(rows.min()) if len(rows) else 0
wallcol = np.median(im[top:skirt_top - 10][cover[top:skirt_top - 10]], 0)
strip = im[top:floor_row].copy(); strip[~cover[top:floor_row]] = wallcol
len_m, h_m = W * mpp, (floor_row - top) * mpp
low = cv2.resize(strip, (max(8, int(len_m * 48)), max(8, int(h_m * 48))), interpolation=cv2.INTER_AREA)
cv2.imwrite(f"{out}/textures/{name}.png", low)

# 5. sharp detail images: re-project each painting from its single best frame at 700 px/m
rec = pycolmap.Reconstruction(model)
sc, (x0, x1) = meta["scale_m_per_unit"], meta["along_m"]; ytop = meta["top_m"]
# rebuild the wall frame exactly as ortho.py did
P = np.array([p.xyz for p in rec.points3D.values()]); ims = list(rec.images.values())
C = np.array([i.projection_center() for i in ims]); Rs = [i.cam_from_world().rotation.matrix() for i in ims]
basis = json.load(open(f"{name}-elevation.json")).get("basis")
paint = []
for k, (x, y, w, h) in enumerate(rects):
    pid = f"{name}-{k:02d}"
    crop = im[y:y + h, x:x + w]
    detail = crop
    if basis:
        ax, up, nw, o = (np.array(basis[s]) for s in ("ax", "up", "nw", "o"))
        # rect corners in the unrotated elevation, back to wall metres (ortho.py units), then to world
        Minv = cv2.invertAffineTransform(M)
        cs = cv2.transform(np.float32([[[x, y], [x + w, y], [x + w, y + h], [x, y + h]]]), Minv)[0]
        wx = x0 + cs[:, 0] / ppm0; wy = ytop - cs[:, 1] / ppm0
        world = [o + ax * (u / sc) + up * (v / sc) for u, v in zip(wx, wy)]
        cands = []; src = None
        cen = np.mean(world, 0)
        for im_, R_, c_ in zip(ims, Rs, C):
            vdir = cen - c_; dist = np.linalg.norm(vdir); s = (-(R_[2] @ nw)) ** 3 / dist
            proj = [im_.cam_from_world() * wp for wp in world]
            if min(p[2] for p in proj) <= 0: continue
            cam = rec.cameras[im_.camera_id]; K = cam.calibration_matrix()
            uv = np.array([(K @ (p / p[2]))[:2] for p in proj])
            if uv.min() < 0 or uv[:, 0].max() > cam.width or uv[:, 1].max() > cam.height: continue
            cands.append((s, im_, uv))
        best_sharp = -1
        for s, im_, uv in sorted(cands, key=lambda c: -c[0])[:8]:
            f = full_frame(im_.name)
            if f is None: continue
            fs = f.shape[1] / rec.cameras[im_.camera_id].width   # the model saw 720-wide frames
            Wd, Hd = int(w * mpp * 700), int(h * mpp * 700)
            Hm = cv2.getPerspectiveTransform(np.float32(uv * fs), np.float32([[0, 0], [Wd, 0], [Wd, Hd], [0, Hd]]))
            d = cv2.warpPerspective(f, Hm, (Wd, Hd), flags=cv2.INTER_CUBIC)
            sh = cv2.Laplacian(cv2.cvtColor(cv2.resize(d, (400, int(400 * Hd / Wd))), cv2.COLOR_BGR2GRAY), cv2.CV_64F).var()
            if sh > best_sharp: best_sharp, detail, src = sh, d, {"frame": im_.name, "quad": (uv * fs).tolist(), "size": [Wd, Hd]}
    cv2.imwrite(f"{out}/paintings/{pid}.jpg", detail, [cv2.IMWRITE_JPEG_QUALITY, 92])
    cv2.imwrite(f"{name}-ref-{k:02d}.png", crop)
    paint.append({"src": src if basis else None, "id": pid, "along_m": (x + w / 2) * mpp, "center_y": (floor_row - (y + h / 2)) * mpp,
                  "width": w * mpp, "height": h * mpp, "detail": pid})
json.dump({"name": name, "length_m": len_m, "height_m": h_m, "px_per_m": 1 / mpp, "tilt_deg": ang, "paintings": paint},
          open(f"{name}-strip.json", "w"), indent=1)
vis = im.copy()
for x, y, w, h in rects: cv2.rectangle(vis, (x, y), (x + w, y + h), (0, 0, 255), 3)
cv2.line(vis, (0, floor_row), (W, floor_row), (0, 255, 0), 2)
cv2.imwrite(f"{name}-level.jpg", im)
cv2.imwrite(f"{name}-strip-check.jpg", cv2.resize(vis, (1600, int(H * 1600 / W))))
print(f"{name}: {len(rects)} paintings, {len_m:.1f} m x {h_m:.1f} m")
