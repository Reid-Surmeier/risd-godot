"""Check the two observed floor patches separately before assuming a level join."""
import hashlib
import argparse
import json
from pathlib import Path

import numpy as np
import pycolmap
from PIL import Image, ImageDraw

ROOT = Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
DENSE = ROOT/'dense-doorway-calibrated-v2'
parser = argparse.ArgumentParser()
parser.add_argument('--revisit', action='store_true', help='Use reviewed later doorway view 000018')
args = parser.parse_args()
OUT = ROOT/('floor-patches-v2' if args.revisit else 'floor-patches-v1')
geometry = json.loads((ROOT/'doorway-geometry-v1/geometry.json').read_text())
source = 'IMG_6380_exit6fps/000018.jpg' if args.revisit else geometry['source']
polygons = ([[[60, 470], [290, 470], [335, 620], [20, 620]],
             [[140, 335], [220, 335], [245, 395], [110, 395]]]
            if args.revisit else geometry['annotations']['floor'])
aperture = json.loads((ROOT/'doorway-aperture-v1/result.json').read_text())
scale = geometry['provisional_m_per_unit']
model = pycolmap.Reconstruction(DENSE/'sparse')
view = next(i for i in model.images.values() if i.name == source)
camera = model.cameras[view.camera_id]
path = DENSE/'stereo/depth_maps'/(view.name+'.geometric.bin')
depth_hash = hashlib.sha256(path.read_bytes()).hexdigest()
if not args.revisit:
    assert depth_hash == geometry['depth_sha256']
with path.open('rb') as stream:
    header = b''
    while header.count(b'&') < 3:
        byte = stream.read(1)
        assert byte, 'Truncated depth header'
        header += byte
    width, height, channels = map(int, header[:-1].split(b'&'))
    assert (width, height, channels) == (640, 360, 1)
    depth = np.frombuffer(stream.read(), dtype='<f4').reshape((width, height), order='F').T


def fit_plane(points, tolerance):
    assert len(points) >= 100
    rng = np.random.default_rng(182)
    best = np.zeros(len(points), dtype=bool)
    for _ in range(300):
        a, b, c = points[rng.choice(len(points), 3, replace=False)]
        normal = np.cross(b-a, c-a)
        if np.linalg.norm(normal) < 1e-10:
            continue
        normal /= np.linalg.norm(normal)
        supported = np.abs((points-a)@normal) < tolerance
        if supported.sum() > best.sum():
            best = supported
    assert best.sum() >= 100
    center = points[best].mean(0)
    normal = np.linalg.svd(points[best]-center, full_matrices=False)[2][-1]
    if normal@np.array(geometry['basis_rows'])[1] < 0:
        normal = -normal
    return center, normal


# Runnable recovery and negative control, independent of the measured depth.
grid = np.array([[x, y, 0.] for x in range(12) for y in range(12)])
center, normal = fit_plane(grid, .001)
assert np.max(np.abs((grid-center)@normal)) < 1e-8
assert np.min(np.abs((grid+[0, 0, .1]-center)@normal)) > .09

picture = Image.open(DENSE/'images'/view.name).transpose(Image.Transpose.ROTATE_270).convert('RGB')
draw = ImageDraw.Draw(picture)
planes, reports = [], []
for label, polygon, color in zip(['near', 'far'], polygons, ['lime', 'cyan']):
    mask = Image.new('1', picture.size)
    ImageDraw.Draw(mask).polygon(polygon, fill=1)
    y, x = np.nonzero(np.array(mask))
    distances = depth[height-1-x, y]
    valid = np.isfinite(distances) & (distances > 0)
    for px, py in zip(x[valid], y[valid]):
        draw.point((int(px), int(py)), fill=color)
    raw = np.c_[y[valid], height-1-x[valid]]
    xyz = view.cam_from_world().inverse()*(np.c_[camera.cam_from_img(raw), np.ones(valid.sum())]*distances[valid, None])
    # Spatial blocks, not alternating pixels; still correlated depth, not a held-out capture.
    fit = ((x[valid]//8+y[valid]//8) % 2) == 0
    draw.line(polygon+[polygon[0]], fill=color, width=2)
    draw.text(polygon[0], label, fill=color)
    if min(fit.sum(), (~fit).sum()) < 100:
        reports.append(dict(patch=label, polygon=polygon, polygon_pixels=len(x),
                            valid_depth_samples=len(xyz), valid_depth_fraction=float(valid.mean()),
                            fit_samples=int(fit.sum()), check_samples=int((~fit).sum()),
                            status='insufficient depth: require 100 fit and 100 check samples'))
        continue
    center, normal = fit_plane(xyz[fit], .025/scale)
    residual = np.abs((xyz[~fit]-center)@normal)*scale
    planes.append((label, center, normal))
    reports.append(dict(patch=label, polygon=polygon, polygon_pixels=len(x), valid_depth_samples=len(xyz),
                        valid_depth_fraction=float(valid.mean()), fit_samples=int(fit.sum()),
                        check_samples=int((~fit).sum()), check_support_25mm=float(np.mean(residual < .025)),
                        check_p50_p90_m=np.percentile(residual, [50, 90]).tolist(),
                        center_world=center.tolist(), normal_world=normal.tolist()))
up = np.array(geometry['basis_rows'])[1]
toes = np.array(aperture['corners_world'][:2])
# Intersect vertical lines through both measured jamb toes with each floor plane.
levels = {label: (((center-toes)@normal)/(up@normal)*scale).tolist() for label, center, normal in planes}
angle = float(np.degrees(np.arccos(np.clip(planes[0][2]@planes[1][2], -1, 1)))) if len(planes) == 2 else None
report = dict(source=view.name, depth_sha256=depth_hash,
              image_sha256=hashlib.sha256((DENSE/'images'/view.name).read_bytes()).hexdigest(), patches=reports,
              floor_normal_angle_degrees=angle, floor_relative_to_toes_m=levels,
              far_minus_near_at_toes_m=(np.array(levels['far'])-levels['near']).tolist() if len(planes) == 2 else None,
              provisional_m_per_unit=scale, navigation_accepted=False,
              caveat='Separate fits to existing near/far masks in one CUDA depth map. Block checks are correlated, not independent capture validation. Plane extension to doorway toes is extrapolation; metric scale remains provisional.')
OUT.mkdir(exist_ok=True)
picture.resize((720, 1280)).save(OUT/'patches.png')
(OUT/'result.json').write_text(json.dumps(report, indent=2)+'\n')
print(json.dumps(report, indent=2))
