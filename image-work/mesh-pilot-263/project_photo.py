"""Lay the catalogue photograph over the front of a generated mesh. Free: no generation.

    python3 project_photo.py RAW.glb CUTOUT.png OUT_TEXTURE.png [--size 2048] [--no-flow] [--debug PREFIX]

RAW.glb is the generator's file as downloaded (Flora Trellis or Tripo); CUTOUT.png is the RGBA picture it was made
from. The mesh was made from that picture, seen from that side, so:
1. find the view: of four turns about the vertical axis and a few camera distances, the one whose silhouette best
   covers the cut-out's;
2. see what that view sees: a depth picture of the mesh from there;
3. (unless --no-flow) nudge: render the mesh's own texture from that view and measure, by optical flow, how far each
   part sits from the same part of the photograph, so the photograph's carving lands on the mesh's carving;
4. repaint: every texel of the mesh's own texture that faces the view and is not hidden takes the photograph's
   colour, faded out towards the edges of what the view sees. Sides and back keep the generator's texture.
The UVs are not touched, so prepare_mesh.py takes the result with --texture-image.
Prints the silhouette overlap (IoU); under about 0.9 the mesh is not the photograph's shape and the result is suspect."""
import sys, io, json, struct, argparse
import numpy as np, cv2
from PIL import Image

p = argparse.ArgumentParser(); p.add_argument("glb"); p.add_argument("cutout"); p.add_argument("out")
p.add_argument("--size", type=int, default=2048); p.add_argument("--turns", default="0,90,180,270"); p.add_argument("--atlas"); p.add_argument("--view-only", action="store_true"); p.add_argument("--layer"); p.add_argument("--ramp", default="0.15,0.35"); p.add_argument("--no-flow", action="store_true"); p.add_argument("--debug"); p.add_argument("--pose")
a = p.parse_args()

# --- the mesh: positions, UVs, triangles, texture
raw = open(a.glb, "rb").read(); n = struct.unpack("<I", raw[12:16])[0]; g = json.loads(raw[20:20 + n]); blob = raw[20 + n + 8:]
def view(i):
    acc = g["accessors"][i]; bv = g["bufferViews"][acc["bufferView"]]
    kind = {5126: np.float32, 5125: np.uint32, 5123: np.uint16, 5121: np.uint8}[acc["componentType"]]
    width = {"SCALAR": 1, "VEC2": 2, "VEC3": 3, "VEC4": 4}[acc["type"]]
    start = bv.get("byteOffset", 0) + acc.get("byteOffset", 0); stride = bv.get("byteStride", 0)
    if stride and stride != np.dtype(kind).itemsize * width:
        rows = np.frombuffer(blob, np.uint8, stride * acc["count"], start).reshape(acc["count"], stride)
        return np.ascontiguousarray(rows[:, :np.dtype(kind).itemsize * width]).view(kind).reshape(acc["count"], width)
    return np.frombuffer(blob, kind, acc["count"] * width, start).reshape(acc["count"], width)
P, UV, F = [], [], []; base = 0; ZERO = lambda n: np.zeros((n, 2))
for node in g["nodes"]:
    if "mesh" not in node: continue
    assert not any(k in node for k in ("rotation", "scale", "matrix")), "the mesh node is transformed; bake that first"
    for prim in g["meshes"][node["mesh"]]["primitives"]:
        pos = view(prim["attributes"]["POSITION"]).astype(np.float64) + np.array(node.get("translation", [0, 0, 0]))
        P.append(pos); UV.append(view(prim["attributes"]["TEXCOORD_0"]).astype(np.float64) if "TEXCOORD_0" in prim["attributes"] else ZERO(len(pos))); F.append(view(prim["indices"]).reshape(-1, 3).astype(np.int64) + base); base += len(pos)
P, UV, F = np.vstack(P), np.vstack(UV), np.vstack(F)
if a.pose:  # WIDTH,DEPTH,LEAN from clay_mesh.py's record: undo its sizing and its --upright, so the mesh stands as the
    # generator made it from this very view. A deep relief drawn looking 15 degrees down does not register otherwise.
    wx, dz, lean = [float(x) for x in a.pose.split(",")]; P = P - (P.max(0) + P.min(0)) / 2; P[:, 0] /= wx; P[:, 2] /= dz
    c, s = np.cos(np.radians(-lean)), np.sin(np.radians(-lean)); P = np.stack([P[:, 0], c * P[:, 1] - s * P[:, 2], s * P[:, 1] + c * P[:, 2]], 1)
if a.atlas:  # paint over an earlier result: this is how several views are laid on one after another
    atlas = np.array(Image.open(a.atlas).convert("RGB"))
elif g.get("images"):
    mat0 = g["materials"][0]["pbrMetallicRoughness"]; im0 = g["textures"][mat0["baseColorTexture"]["index"]]["source"]
    bv = g["bufferViews"][g["images"][im0]["bufferView"]]
    atlas = np.array(Image.open(io.BytesIO(blob[bv.get("byteOffset", 0):bv.get("byteOffset", 0) + bv["byteLength"]])).convert("RGB"))
else:
    atlas = np.full((8, 8, 3), 180, np.uint8)
atlas = cv2.resize(atlas, (a.size, a.size), interpolation=cv2.INTER_CUBIC)
cut = np.array(Image.open(a.cutout).convert("RGBA")); photo = cut[..., :3]; alpha = cut[..., 3] > 127
ys, xs = np.where(alpha); box = np.array([xs.min(), ys.min(), xs.max() + 1, ys.max() + 1], float)
centre = (P.max(0) + P.min(0)) / 2; span = (P.max(0) - P.min(0)).max(); P0 = (P - centre) / span  # glTF: Y up

def mask_of(px, shape, small):
    """The silhouette. One triangle at a time: filled together, overlapping triangles cancel (even-odd rule)."""
    m = np.zeros(shape, np.uint8); step = max(1, len(F) // 30000)
    for t in (px[F[::step]] * small).astype(np.int32): cv2.fillConvexPoly(m, t, 1)
    return cv2.morphologyEx(m, cv2.MORPH_CLOSE, np.ones((3, 3), np.uint8)) if step > 1 else m

def seen(turn, dist):
    """Mesh points in the view's frame (x right, y up, z towards the eye) and where they fall on the cut-out.
    The picture is fitted by the two silhouettes' centres and spreads, not their extremes, so a stray scrap of mesh
    does not throw it."""
    c, s = np.cos(np.radians(turn)), np.sin(np.radians(turn))
    V = np.stack([c * P0[:, 0] - s * P0[:, 2], P0[:, 1], s * P0[:, 0] + c * P0[:, 2]], 1)
    k = 1.0 / (1.0 - V[:, 2] / dist) if dist else np.ones(len(V))
    flat = np.stack([V[:, 0] * k, -V[:, 1] * k], 1)
    m = mask_of((flat + 1.5) * 128, (384, 384), 1.0); my, mx = np.where(m > 0)
    mesh = [(mx.mean() / 128 - 1.5, mx.std() / 128), (my.mean() / 128 - 1.5, my.std() / 128)]
    return V, np.stack([REF[i][0] + (flat[:, i] - mesh[i][0]) * REF[i][1] / mesh[i][1] for i in (0, 1)], 1)

def overlap(px):
    small = 384.0 / max(alpha.shape); shape = (int(alpha.shape[0] * small) + 1, int(alpha.shape[1] * small) + 1)
    m = mask_of(px, shape, small); ref = cv2.resize(alpha.astype(np.uint8), (shape[1], shape[0]), interpolation=cv2.INTER_NEAREST)
    return (m & ref).sum() / max(1, (m | ref).sum())

REF = [(xs.mean(), xs.std()), (ys.mean(), ys.std())]
def look(turn, dist):
    """What the view sees: face ids painted far to near, then exact depth per pixel and the mesh's own texture."""
    V, px = seen(turn, dist); ids = np.full((H, W), -1, np.int32); tri = px[F].astype(np.int32)
    for f in np.argsort(V[F][:, :, 2].mean(1)): cv2.fillConvexPoly(ids, tri[f], int(f))
    yy, xx = np.where(ids >= 0); fid = ids[yy, xx]; w = weights(np.stack([xx + .5, yy + .5], 1), px[F[fid]])
    depth = np.full((H, W), -9.0); depth[yy, xx] = (w * V[F[fid]][:, :, 2]).sum(1)
    uv = (w[:, :, None] * UV[F[fid]]).sum(1); own = np.zeros((H, W, 3), np.uint8)
    own[yy, xx] = atlas[np.clip((uv[:, 1] * a.size).astype(int), 0, a.size - 1), np.clip((uv[:, 0] * a.size).astype(int), 0, a.size - 1)]
    return V, px, ids, depth, own

def weights(pts, corners):
    """Barycentric weights of pts (N,2) in triangles corners (N,3,2)."""
    v0, v1, v2 = corners[:, 1] - corners[:, 0], corners[:, 2] - corners[:, 0], pts - corners[:, 0]
    den = v0[:, 0] * v1[:, 1] - v1[:, 0] * v0[:, 1]; den[np.abs(den) < 1e-12] = 1e-12
    b = (v2[:, 0] * v1[:, 1] - v1[:, 0] * v2[:, 1]) / den; c = (v0[:, 0] * v2[:, 1] - v2[:, 0] * v0[:, 1]) / den
    return np.clip(np.stack([1 - b - c, b, c], 1), -0.5, 1.5)

# --- 1. the view. Silhouette alone cannot tell the front of a symmetrical object from its back, so each turn's
#        best distance is then judged by how like the photograph the mesh's own texture looks from there.
H, W = alpha.shape; best = None
if a.view_only:  # an untextured mesh: which turn shows the cut-out's side, by silhouette alone
    for t in [float(x) for x in a.turns.split(",")]:
        iou, dist = max((overlap(seen(t, d)[1]), d) for d in (0, 8, 4, 3, 2.4, 2, 1.7)); print(f"  turn {t:g}: silhouette IoU {iou:.3f}")
        if best is None or iou > best[0]: best = (iou, t)
    print(f"view: turn {best[1]:g} deg, silhouette IoU {best[0]:.3f}"); raise SystemExit
for turn in [float(x) for x in a.turns.split(",")]:
    iou, dist = max((overlap(seen(turn, d)[1]), d) for d in (0, 8, 4, 3, 2.4, 2, 1.7))
    if iou < 0.6: continue
    shot = look(turn, dist); both = (shot[2] >= 0) & alpha
    unlike = np.abs(cv2.blur(shot[4], (25, 25)).astype(int) - cv2.blur(photo, (25, 25)).astype(int))[both].mean() / 255
    print(f"  turn {turn:g}: eye distance {dist or 'infinite'}, silhouette IoU {iou:.3f}, colour difference {unlike:.3f}")
    if best is None or iou - unlike > best[0]: best = (iou - unlike, turn, dist, iou, shot)
assert best, "no view of the mesh matches the cut-out's silhouette"
_, turn, dist, iou, (V, px, ids, depth, own) = best
print(f"view: turn {turn:g} deg, eye distance {dist or 'infinite'}, silhouette IoU {iou:.3f}")
shift = np.zeros((H, W, 2), np.float32)
if not a.no_flow:
    grey = lambda im: cv2.createCLAHE(2.0, (8, 8)).apply(cv2.cvtColor(im, cv2.COLOR_RGB2GRAY))
    s = 768.0 / max(H, W); small = lambda im: cv2.resize(im, (int(W * s), int(H * s)), interpolation=cv2.INTER_AREA)
    flow = cv2.calcOpticalFlowFarneback(small(grey(own)), small(grey(photo)), None, 0.5, 5, 41, 5, 7, 1.5, 0)
    flow = cv2.GaussianBlur(flow, (0, 0), 9); flow = np.clip(flow, -0.03 * 768, 0.03 * 768)  # a nudge, never a relocation
    shift = cv2.resize(flow, (W, H), interpolation=cv2.INTER_LINEAR) / s
    print(f"nudge: median {np.median(np.linalg.norm(shift[ids >= 0], axis=1)):.1f} px, largest {np.linalg.norm(shift[ids >= 0], axis=1).max():.1f} px of {max(H, W)}")
if a.debug: Image.fromarray(own).save(a.debug + "-own.jpg", quality=88)

# --- repaint the texture: which face owns each texel, where that point is, whether the view sees it
S = a.size; owner = np.full((S, S), -1, np.int32); uvpx = UV * S
for f, t in enumerate(uvpx[F].astype(np.int32)): cv2.fillConvexPoly(owner, t, f)
ty, tx = np.where(owner >= 0); tf = owner[ty, tx]
w = weights(np.stack([tx + .5, ty + .5], 1), uvpx[F[tf]])
spot = (w[:, :, None] * px[F[tf]]).sum(1); deep = (w * V[F[tf]][:, :, 2]).sum(1)
e1, e2 = V[F][:, 1] - V[F][:, 0], V[F][:, 2] - V[F][:, 0]; normal = np.cross(e1, e2); normal /= np.linalg.norm(normal, axis=1, keepdims=True) + 1e-12
facing = normal[:, 2]
if np.median(facing[np.unique(ids[ids >= 0])]) < 0: facing = -facing  # winding the other way round
sx, sy = np.clip(spot[:, 0], 0, W - 1.001), np.clip(spot[:, 1], 0, H - 1.001); ix, iy = sx.astype(int), sy.astype(int)
visible = deep >= depth[iy, ix] - 0.012
sx2, sy2 = sx + shift[iy, ix, 0], sy + shift[iy, ix, 1]
core = cv2.erode(alpha.astype(np.uint8), np.ones((7, 7), np.uint8)) > 0  # not the cut-out's fringe, before or after the nudge
inside = core[iy, ix] & core[np.clip(sy2, 0, H - 1).astype(int), np.clip(sx2, 0, W - 1).astype(int)]
r0, r1 = (float(x) for x in a.ramp.split(","))  # how squarely a surface must face the view to take its colour: from r0, full at r0 + r1
weight = np.clip((facing[tf] - r0) / r1, 0, 1) * visible * inside
sx2, sy2 = np.clip(sx2, 0, W - 1.001), np.clip(sy2, 0, H - 1.001); jx, jy = sx2.astype(int), sy2.astype(int); fx, fy = (sx2 - jx)[:, None], (sy2 - jy)[:, None]
colour = (photo[jy, jx] * (1 - fx) + photo[jy, jx + 1] * fx) * (1 - fy) + (photo[jy + 1, jx] * (1 - fx) + photo[jy + 1, jx + 1] * fx) * fy
wmap = np.zeros((S, S), np.float32); wmap[ty, tx] = weight; wmap = cv2.GaussianBlur(wmap, (0, 0), 1.5)  # soften the edge of what was seen
wmap[ty, tx] = np.where(weight > 0, wmap[ty, tx], 0)  # the blur may lower a seen texel, never lend weight to an unseen one: its colour is the background
out = atlas.copy().astype(np.float32); k = wmap[ty, tx][:, None]
out[ty, tx] = colour * k + out[ty, tx] * (1 - k)
# keep island gutters from bleeding old colour: spread the repainted texels outward a few pixels
painted = np.zeros((S, S), np.uint8); painted[ty, tx] = 1; result = out.astype(np.uint8)
spread = cv2.dilate(result, np.ones((5, 5), np.uint8)); edge = (cv2.dilate(painted, np.ones((5, 5), np.uint8)) > 0) & (painted == 0)
result[edge] = spread[edge]
Image.fromarray(result).save(a.out)
if a.layer:  # this view alone, for blend_views.py: its colour, how much it should count, and which texels the mesh uses
    lay = np.zeros((S, S, 3), np.uint8); lay[ty, tx] = np.clip(colour, 0, 255)
    Image.fromarray(lay).save(a.layer + "-rgb.png"); Image.fromarray((np.clip(wmap, 0, 1) * 255).astype(np.uint8)).save(a.layer + "-w.png")
    Image.fromarray(((owner >= 0) * 255).astype(np.uint8)).save(a.layer + "-used.png")
print(f"repainted {100 * (wmap[ty, tx] > 0.5).mean():.0f}% of the used texture, {int((wmap > 0.5).sum())} texels, at {S} px")
if a.debug:
    over = photo.copy(); edgepx = cv2.Canny(((ids >= 0) * 255).astype(np.uint8), 50, 150) > 0; over[edgepx] = (255, 0, 255)
    Image.fromarray(over).save(a.debug + "-fit.jpg", quality=85)
