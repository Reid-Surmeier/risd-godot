"""Measure one observed opening from CUDA depth; annotations are reviewable, scale provisional."""
import hashlib
import json
import pathlib

import numpy as np
import pycolmap
from PIL import Image, ImageDraw

ROOT = pathlib.Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
DENSE = ROOT/'dense-doorway-calibrated-v2'
OUT = ROOT/'doorway-geometry-v1'
OUT.mkdir(exist_ok=True)
name = 'IMG_6380/000505.jpg'
model = pycolmap.Reconstruction(DENSE/'sparse')
im = next(i for i in model.images.values() if i.name == name)
camera = model.cameras[im.camera_id]
depth_path = DENSE/'stereo/depth_maps'/(name+'.geometric.bin')
with depth_path.open('rb') as f:
    header = b''
    while header.count(b'&') < 3:
        byte = f.read(1)
        assert byte, 'Truncated COLMAP depth header'
        header += byte
    w, h, channels = map(int, header[:-1].split(b'&'))
    assert channels == 1 and (w, h) == (camera.width, camera.height)
    depth = np.frombuffer(f.read(), dtype='<f4').reshape((w, h), order='F').T
picture = Image.open(DENSE/'images'/name).transpose(Image.Transpose.ROTATE_270)
assert picture.size == (h, w) == (360, 640), 'Annotations require the reviewed 640px depth export'
# Pixel coordinates in the upright, 360x640 undistorted reference. White casing
# polygons exclude the hole; floor polygons exclude the pedestal and wall bases.
annotations = dict(
    casing=[[(8, 77), (277, 94), (275, 107), (12, 94)],
            [(15, 110), (25, 110), (49, 380), (39, 380)],
            [(250, 150), (260, 150), (253, 370), (242, 370)]],
    floor=[[(70, 430), (280, 430), (335, 620), (20, 620)],
           [(85, 330), (155, 330), (170, 365), (80, 365)]],
    opening=[(25, 102), (262, 116), (240, 383), (50, 387)])
audit = json.loads((ROOT/'heldout-calibrated-v1/audit.json').read_text())
alignment = next(x for x in audit['component_consistency'] if x['component'] == 5)
anchor = next(x for x in json.loads((ROOT/'scale-bookcase-v1/result.json').read_text()) if x['component'] == '5')
scale = alignment['scale']*anchor['meters_per_unit']

def world(upright, distance):
    raw = np.c_[upright[:, 1], h-1-upright[:, 0]]
    return im.cam_from_world().inverse() * (np.c_[camera.cam_from_img(raw), np.ones(len(raw))]*distance[:, None])

def samples(polygons):
    mask = Image.new('1', picture.size)
    draw = ImageDraw.Draw(mask)
    for polygon in polygons:
        draw.polygon(polygon, fill=1)
    y, x = np.nonzero(np.array(mask))
    d = depth[h-1-x, y]
    good = np.isfinite(d) & (d > 0)
    return world(np.c_[x[good], y[good]], d[good])

def plane(points):
    assert len(points) >= 100
    rng = np.random.default_rng(182)
    best = np.zeros(len(points), dtype=bool)
    for _ in range(300):
        a, b, c = points[rng.choice(len(points), 3, replace=False)]
        n = np.cross(b-a, c-a)
        if np.linalg.norm(n) < 1e-10:
            continue
        n /= np.linalg.norm(n)
        good = np.abs((points-a)@n)*scale < .025
        if good.sum() > best.sum():
            best = good
    center = points[best].mean(0)
    _, _, axes = np.linalg.svd(points[best]-center, full_matrices=False)
    normal = axes[-1]
    residual = np.abs((points[best]-center)@normal)*scale
    return center, normal, dict(samples=len(points), support=int(best.sum()), fraction=float(best.mean()),
                               p90_residual_provisional_m=float(np.percentile(residual, 90)))

floor_origin, up, floor = plane(samples(annotations['floor']))
if np.dot(im.projection_center()-floor_origin, up) < 0:
    up = -up
door_origin, normal, casing = plane(samples(annotations['casing']))
corners = np.array(annotations['opening'])
origin = im.projection_center()
rays = world(corners, np.ones(4))-origin
distance = ((door_origin-origin)@normal)/(rays@normal)
assert np.all(distance > 0)
quad = origin+rays*distance[:, None]
right = quad[2]-quad[3]
right -= up*np.dot(right, up)
right /= np.linalg.norm(right)
forward = np.cross(right, up)
basis = np.array([right, up, forward])
center = (quad[2]+quad[3])/2
center -= up*np.dot(center-floor_origin, up)
local = (quad-center)@basis.T*scale
width = float(np.linalg.norm(local[2]-local[3]))
height = float(np.mean(local[:2, 1]))
floor_gap = float(np.max(np.abs(local[2:, 1])))
orthogonality = float(abs(np.dot(normal, up)))
passed = bool(floor['fraction'] > .8 and casing['fraction'] > .7 and floor_gap < .08 and orthogonality < .1)
data = dict(source=name, depth_sha256=hashlib.sha256(depth_path.read_bytes()).hexdigest(),
            annotations=annotations, floor=floor, casing=casing,
            opening_corners=local.tolist(), width_provisional_m=width, height_provisional_m=height,
            floor_corner_gap_provisional_m=floor_gap, normal_dot_up=orthogonality,
            geometry_gate=passed, world_origin=center.tolist(), basis_rows=basis.tolist(),
            provisional_m_per_unit=scale,
            caveat='Manual opening/casing pixels; single-view dense measurement supported by multiview depth. Scale inherits stepped bookcase bias. No complete room shell, camera or navigation acceptance.')
draw = ImageDraw.Draw(picture)
for key, color in [('floor', 'lime'), ('casing', 'cyan')]:
    for polygon in annotations[key]:
        draw.line(polygon+[polygon[0]], fill=color, width=2)
draw.line(annotations['opening']+[annotations['opening'][0]], fill='red', width=2)
picture.save(OUT/'annotated-source.png')
cloud = pycolmap.Reconstruction()
cloud.import_PLY(str(DENSE/'fused.ply'))
points = list(cloud.points3D.values())
xyz = (np.array([p.xyz for p in points])-center)@basis.T*scale
overview = Image.new('RGB', (1400, 800), '#20252a')
draw = ImageDraw.Draw(overview)
for offset, axes, label in [(0, (0, 1), 'Elevation'), (700, (0, 2), 'Plan')]:
    for i in np.argsort(xyz[:, 2 if axes[1] == 1 else 1]):
        p = xyz[i]
        x, y = int(offset+350+p[axes[0]]*90), int(440-p[axes[1]]*90)
        if offset < x < offset+700 and 60 < y < 780:
            draw.point((x, y), fill=tuple(points[i].color))
    draw.text((offset+20, 20), label+' | observed CUDA depth points | provisional metres', fill='white')
    draw.text((offset+20, 40), 'Rejected casing-plane fit; do not use as collision geometry', fill='#ffaaaa')
overview.save(OUT/'depth-overview.png')
data['fused_points'] = len(points)
data['fused_sha256'] = hashlib.sha256((DENSE/'fused.ply').read_bytes()).hexdigest()
(OUT/'geometry.json').write_text(json.dumps(data, indent=2))
print(json.dumps({k: v for k, v in data.items() if k not in ['annotations', 'basis_rows']}, indent=2))
