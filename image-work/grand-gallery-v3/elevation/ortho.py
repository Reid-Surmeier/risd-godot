"""Orthographic wall elevation from a COLMAP model: fit the wall and floor planes, scale by camera height,
project every posed frame onto the wall. usage: ortho.py <sparse model dir> <images dir> <out prefix> [cam_height_m]"""
import sys, json, numpy as np, cv2, pycolmap
model, imgdir, out = sys.argv[1:4]; cam_h = float(sys.argv[4]) if len(sys.argv) > 4 else 1.45
m = pycolmap.Reconstruction(model)
import os
imax = int(os.environ.get("IMAX", "999999"))  # use only frames up to this index (drop the turn to a wide view)
ims = [im for im in m.images.values() if int(im.name[:4]) <= imax]
keep = {im.image_id for im in ims}
P = np.array([p.xyz for p in m.points3D.values() if sum(e.image_id in keep for e in p.track.elements) >= 2])
C = np.array([im.projection_center() for im in ims])
R = [im.cam_from_world().rotation.matrix() for im in ims]
view = np.mean([r[2] for r in R], 0); view /= np.linalg.norm(view)   # camera +z in world
imgup = -np.mean([r[1] for r in R], 0); imgup /= np.linalg.norm(imgup)  # camera -y (image up) in world
rng = np.random.default_rng(0)
def ransac_plane(pts, want, tol):
    best = None
    for _ in range(3000):
        s = pts[rng.choice(len(pts), 3, replace=False)]
        n = np.cross(s[1]-s[0], s[2]-s[0]); nn = np.linalg.norm(n)
        if nn < 1e-9: continue
        n /= nn
        if abs(n @ want) < 0.85: continue
        d = -n @ s[0]; inl = np.abs(pts @ n + d) < tol
        if best is None or inl.sum() > best[2].sum(): best = (n, d, inl)
    n, d, inl = best
    # refine with least squares on inliers
    c = pts[inl].mean(0); u, s, vt = np.linalg.svd(pts[inl] - c); n = vt[2] * np.sign(vt[2] @ best[0]); return n, -n @ c, inl
spread = np.median(np.linalg.norm(P - np.median(P, 0), axis=1)); tol = spread * 0.02
nw, dw, inw = ransac_plane(P, view, tol)                 # the wall faces the cameras
if (C.mean(0) @ nw + dw) < 0: nw, dw = -nw, -dw          # normal points toward the cameras
up = imgup - (imgup @ nw) * nw; up /= np.linalg.norm(up)   # vertical, in the wall plane (cameras are held upright)
below = P[~inw][(P[~inw] - C.mean(0)) @ up < -0.3 * spread]  # floor candidates: well below the cameras
nf, df, inf_ = ransac_plane(below, up, tol)
if nf @ up < 0: nf, df = -nf, -df
h_cam = np.median(C @ nf + df); scale = cam_h / h_cam    # metres per model unit
ax = np.cross(up, nw); ax /= np.linalg.norm(ax)          # along the wall, left->right as seen from the room
o = -dw * nw                                              # a point on the wall plane
o = o - ((o @ nf + df) / (up @ nf)) * up                  # slide it down to the floor line
def to_wall(X): Y = X - o; return np.stack([Y @ ax, Y @ up], -1) * scale   # metres (along, height)
wp = to_wall(P[inw]); x0, x1 = np.percentile(wp[:, 0], [0.5, 99.5]); ylo, ytop = np.percentile(wp[:, 1], [0.2, 99.8]); ylo -= 0.6; ytop += 0.3
ppm = 200  # pixels per metre
import os
basis = {"ax": ax.tolist(), "up": up.tolist(), "nw": nw.tolist(), "o": o.tolist()}
if os.environ.get("BASIS_ONLY"):
    j = json.load(open(out + "-elevation.json")); j["basis"] = basis; json.dump(j, open(out + "-elevation.json", "w"), indent=1)
    print("basis saved"); sys.exit(0)
Wc, Hc = int((x1 - x0) * ppm), int((ytop - ylo) * ppm)
acc = np.zeros((Hc, Wc, 3), np.float32); ws = np.zeros((Hc, Wc), np.float32)
cam = m.cameras[ims[0].camera_id]
for im in ims:
    f = cv2.imread(f"{imgdir}/{im.name}")
    if f is None: continue
    K = cam.calibration_matrix(); dist = np.array([cam.params[3], 0, 0, 0]) if len(cam.params) > 3 else None
    if dist is not None: f = cv2.undistort(f, K, dist)
    rt = im.cam_from_world(); Rm = rt.rotation.matrix(); t = rt.translation
    # canvas pixel (u,v) -> wall metres -> world -> image
    Aw = np.column_stack([ax / (ppm * scale), -up / (ppm * scale), o + ax * (x0 / scale) + up * (ytop / scale)])
    Hm = K @ np.column_stack([Rm @ Aw[:, 0], Rm @ Aw[:, 1], Rm @ Aw[:, 2] + t])
    # weight: prefer frames looking square-on at the wall
    wgt = max(0.05, float(-(Rm[2] @ nw))) ** 4
    warped = cv2.warpPerspective(f, Hm, (Wc, Hc), flags=cv2.WARP_INVERSE_MAP | cv2.INTER_LINEAR)
    mk = cv2.warpPerspective(np.ones(f.shape[:2], np.float32), Hm, (Wc, Hc), flags=cv2.WARP_INVERSE_MAP) * wgt
    acc += warped * mk[..., None]; ws += mk
out_img = (acc / np.maximum(ws, 1e-6)[..., None]).clip(0, 255).astype(np.uint8); out_img[ws < 1e-4] = 0
cv2.imwrite(out + "-elevation.png", out_img)
# the skirting board: the brightest, least saturated long horizontal band in the lower part
hsv = cv2.cvtColor(out_img, cv2.COLOR_BGR2HSV); white = ((hsv[..., 1] < 45) & (hsv[..., 2] > 150)).mean(1)
rows = np.arange(Hc); cand = rows[(white > 0.5) & (rows > Hc * 0.5)]
skirt_top_row = int(cand.min()) if len(cand) else None
cam_rows = [(ytop - to_wall(c[None])[0, 1]) * ppm for c in C]
json.dump({"basis": basis, "ppm": ppm, "along_m": [float(x0), float(x1)], "top_m": float(ytop), "bottom_m": float(ylo), "skirting_top_row": skirt_top_row,
           "camera_row_median": float(np.median(cam_rows)), "scale_m_per_unit": float(scale),
           "cam_height_units": float(h_cam), "wall_inliers": int(inw.sum()), "floor_inliers": int(inf_.sum())},
          open(out + "-elevation.json", "w"), indent=1)
print(Wc, Hc, "wall", (x1 - x0), "m long visible, height shown", ytop, "m")
