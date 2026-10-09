"""#182: test three source-visible floor features without changing the sparse model."""
import argparse
import hashlib
import json
from pathlib import Path

import numpy as np
import pycolmap
from PIL import Image, ImageDraw
from measurements import project, triangulate, upright

ROOT = Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
parser = argparse.ArgumentParser()
parser.add_argument('output', nargs='?', default='strict-floor-tracks-v2')
args = parser.parse_args()
OUT = ROOT/args.output
SOURCE = ROOT/'sfm-strict-doorway-v1/sparse/0'
assert not (OUT/'result.json').exists(), 'Preserve completed diagnostics.'
selection_path = OUT/'selection.json'
selection = json.loads(selection_path.read_text())
training, reserved = selection['training'], selection['reserved']
assert len(training) == 2 and not set(training) & set(reserved)
ids = selection['point_ids']
assert len(ids) == 3 and len(set(ids)) == 3
pins = {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in SOURCE.glob('*.bin')}
model = pycolmap.Reconstruction(SOURCE)
views = {v.name: v for v in model.images.values() if v.has_pose}
names = [n for n in training+reserved if n in views]
tracks = {n: {int(p.point3D_id): upright(p.xy) for p in views[n].points2D if p.has_point3D()}
    for n in names}
# Negative IDs denote source-visible manual floor contacts, frozen in selection.json.
for name, picks in selection.get('manual_picks', {}).items():
    assert name in tracks
    for key, pixel in picks.items():
        key = int(key)
        assert key < 0 and key in ids and len(pixel) == 2
        assert np.isfinite(pixel).all() and 0 <= pixel[0] < 720 and 0 <= pixel[1] < 1280
        tracks[name][key] = np.array(pixel, dtype=float)
cameras = {n: model.cameras[views[n].camera_id] for n in names}
poses = {n: views[n].cam_from_world() for n in names}
assert all(set(ids) <= set(tracks[n]) for n in training)
points, angles = zip(*(triangulate(cameras, poses, {n: tracks[n][i] for n in training}) for i in ids))
points = np.array(points)
assert np.isfinite(points).all() and min(angles) >= 1
assert all(np.all((p*points)[:, 2] > 0) for p in poses.values())
rows = []
for name in training+reserved:
    present = [i for i in ids if name in tracks and i in tracks[name]]
    errors = {}
    if name in views:
        predicted = project(cameras[name], poses[name], points)
        errors = {str(i): float(np.linalg.norm(predicted[ids.index(i)]-tracks[name][i])) for i in present}
        photo = ROOT/'sfm-doorway-v1/images'/name
        image = Image.open(photo).transpose(Image.Transpose.ROTATE_270).convert('RGB')
        draw = ImageDraw.Draw(image)
        draw.polygon([tuple(p) for p in predicted], outline='yellow', width=2)
        for i, (x, y) in zip(ids, predicted):
            draw.line((x-8, y, x+8, y), fill='red', width=2)
            draw.line((x, y-8, x, y+8), fill='red', width=2)
            if i in present:
                x, y = tracks[name][i]
                draw.ellipse((x-6, y-6, x+6, y+6), outline='lime', width=2)
                draw.text((x+8, y+8), str(i), fill='lime')
        draw.rectangle((0, 0, 720, 44), fill='black')
        draw.text((8, 6), name+(' RESERVED tracks' if name in reserved else ' TRAINING tracks'), fill='white')
        draw.text((8, 23), 'Floor triangle hypothesis; no scale or collision acceptance', fill='white')
        image.save(OUT/(Path(name).stem+'-triangle.png'))
    rows.append(dict(image=name, errors_px=errors, missing_ids=sorted(set(ids)-set(present)),
        diagnostic_pass=len(present) == 3 and max(errors.values()) <= 8))

# The triangle is a hypothesis: three points always define a plane. Record its
# shape and sensitivity rather than pretending this verifies a whole-room floor.
cross = np.cross(points[1]-points[0], points[2]-points[0])
normal = cross/np.linalg.norm(cross)
edges = np.array([np.linalg.norm(points[a]-points[b]) for a, b in [(0, 1), (1, 2), (2, 0)]])
altitude = np.linalg.norm(cross)/max(edges)
for point in points:
    recovered, _ = triangulate(cameras, poses, {n: project(cameras[n], poses[n], point[None])[0] for n in training})
    assert np.linalg.norm(recovered-point) < 1e-6
assert np.max(abs((points-points[0])@normal)) < 1e-8
assert abs((points[0]+normal-points[0])@normal) > .99
rng = np.random.default_rng(182)
changes = []
for _ in range(200):
    perturbed = np.array([triangulate(cameras, poses, {n: tracks[n][i]+rng.uniform(-2, 2, 2) for n in training})[0] for i in ids])
    alternative = np.cross(perturbed[1]-perturbed[0], perturbed[2]-perturbed[0])
    changes.append(float(np.degrees(np.arccos(np.clip(abs(alternative@normal)/np.linalg.norm(alternative), 0, 1)))))
assert pins == {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in SOURCE.glob('*.bin')}
report = dict(selection=selection, selection_sha256=hashlib.sha256(selection_path.read_bytes()).hexdigest(),
    source_sha256=pins, points_world=points.tolist(), ray_angles_degrees=list(angles), views=rows,
    candidate_normal_world=normal.tolist(), edges_world_units=edges.tolist(), minimum_altitude_world_units=float(altitude),
    pick_sensitivity_camera_pixel_radius=2, normal_change_p95_degrees=float(np.percentile(changes, 95)),
    threshold_px=8, navigation_accepted=False, cost_usd=0,
    caveat='Reserved observations excluded from point triangulation, but cameras are globally fitted '
        'using cached tracks. Negative IDs are frozen manual contacts, not sparse track identities. '
        'Same-video correlated diagnostic, not independent validation. '
        'Three points define a candidate plane, not physical planarity, metric scale, floor extent or collision approval.')
(OUT/'result.json').write_text(json.dumps(report, indent=2)+'\n')
print(json.dumps(report, indent=2))
