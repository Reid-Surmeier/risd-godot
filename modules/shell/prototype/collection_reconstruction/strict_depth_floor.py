"""#182: inspect frozen floor masks in corrected-model CUDA depth, without old scale."""
import argparse
import hashlib
import json
from pathlib import Path

import numpy as np
import pycolmap
from PIL import Image, ImageDraw

ROOT = Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
DENSE = ROOT/'dense-strict-floor-v1'
parser = argparse.ArgumentParser()
parser.add_argument('output', nargs='?', default='strict-depth-floor-v1')
args = parser.parse_args()
OUT = ROOT/args.output
assert not (OUT/'result.json').exists(), 'Preserve completed floor diagnostics.'
annotation_path = OUT/'annotations.json'
annotations = json.loads(annotation_path.read_text())
source = annotations['source']
photo = DENSE/'images'/source
assert hashlib.sha256(photo.read_bytes()).hexdigest() == annotations['image_sha256']
model = pycolmap.Reconstruction(DENSE/'sparse')
view = next(v for v in model.images.values() if v.name == source)
camera = model.cameras[view.camera_id]
path = DENSE/'stereo/depth_maps'/(source+'.geometric.bin')
with path.open('rb') as stream:
    header = b''
    while header.count(b'&') < 3:
        byte = stream.read(1)
        assert byte, 'Truncated depth header.'
        header += byte
    width, height, channels = map(int, header[:-1].split(b'&'))
    assert (width, height, channels) == (640, 360, 1)
    assert (camera.width, camera.height) == (width, height)
    data = np.frombuffer(stream.read(), dtype='<f4')
    assert data.size == width*height
    depth = data.reshape((width, height), order='F').T
picture = Image.open(photo).transpose(Image.Transpose.ROTATE_270).convert('RGB')
draw = ImageDraw.Draw(picture)
reports = []
normals = []
# Known planar recovery plus a displaced-surface negative control.
grid = np.array([[x, y, 0.] for x in range(12) for y in range(12)])
known_normal = np.linalg.svd(grid-grid.mean(0), full_matrices=False)[2][-1]
assert max(abs((grid-grid.mean(0))@known_normal)) < 1e-8
assert min(abs((grid+[0, 0, .1]-grid.mean(0))@known_normal)) > .09
for label, polygon in annotations['patches'].items():
    mask = Image.new('1', picture.size)
    ImageDraw.Draw(mask).polygon([tuple(p) for p in polygon], fill=1)
    y, x = np.nonzero(np.array(mask))
    distances = depth[height-1-x, y]
    valid = np.isfinite(distances) & (distances > 0)
    raw = np.c_[y[valid], height-1-x[valid]]
    points = view.cam_from_world().inverse()*(np.c_[camera.cam_from_img(raw), np.ones(valid.sum())]*distances[valid, None])
    assert np.max(np.linalg.norm(camera.img_from_cam(view.cam_from_world()*points)-raw, axis=1)) < 1e-6
    fit = ((x[valid]//8+y[valid]//8) % 2) == 0
    row = dict(patch=label, polygon=polygon, polygon_pixels=len(x), valid_samples=int(valid.sum()),
        valid_fraction=float(valid.mean()), fit_samples=int(fit.sum()), check_samples=int((~fit).sum()))
    for px, py in zip(x[valid], y[valid]):
        draw.point((int(px), int(py)), fill='lime' if label == 'near' else 'cyan')
    if min(fit.sum(), (~fit).sum()) >= 100:
        center = points[fit].mean(0)
        normal = np.linalg.svd(points[fit]-center, full_matrices=False)[2][-1]
        residual = abs((points[~fit]-center)@normal)
        assert np.isfinite(residual).all() and abs(np.linalg.norm(normal)-1) < 1e-8
        row.update(center_world=center.tolist(), normal_world=normal.tolist(),
            check_residual_p50_p90_world_units=np.percentile(residual, [50, 90]).tolist(),
            status='candidate plane only; block pixels remain correlated')
        normals.append(normal)
    else:
        row['status'] = 'insufficient depth: require 100 fit and 100 check samples'
    reports.append(row)
    draw.line([tuple(p) for p in polygon+[polygon[0]]], fill='red', width=2)
picture.save(OUT/'valid-depth.png')
triangle = json.loads((ROOT/'strict-floor-tracks-v2/result.json').read_text())
angle = lambda a, b: float(np.degrees(np.arccos(np.clip(abs(np.array(a)@b), 0, 1))))
report = dict(source=source, annotations=annotations,
    annotations_sha256=hashlib.sha256(annotation_path.read_bytes()).hexdigest(),
    depth_sha256=hashlib.sha256(path.read_bytes()).hexdigest(), patches=reports,
    near_far_normal_angle_degrees=angle(*normals) if len(normals) == 2 else None,
    triangle_normal_difference_degrees=[angle(n, triangle['candidate_normal_world']) for n in normals],
    navigation_accepted=False, cost_usd=0,
    caveat='Six training images only, corrected sparse model; reserved21/25 excluded from depth. '
        'Untrimmed SVD plane candidates and spatial block checks, no tuned inlier selection. '
        'Sparse cameras and dense pixels remain correlated. No old scale/floor transplant, '
        'independent planarity, room extent, physical tolerance or collision acceptance.')
(OUT/'result.json').write_text(json.dumps(report, indent=2)+'\n')
print(json.dumps(report, indent=2))
