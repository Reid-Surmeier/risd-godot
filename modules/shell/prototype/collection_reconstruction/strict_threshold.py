"""#182: frozen native-pixel threshold marks against the corrected model."""
import hashlib
import json
from pathlib import Path

import numpy as np
import pycolmap
from PIL import Image, ImageDraw
from measurements import project, triangulate

ROOT = Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
SOURCE = ROOT/'sfm-strict-doorway-v1'
OUT = ROOT/'strict-threshold-native-v1'
assert not (OUT/'result.json').exists(), 'Preserve completed measurements.'
annotation_path = OUT/'annotations.json'
annotations = json.loads(annotation_path.read_text())
training, query = annotations['training'], annotations['reserved']
assert query not in training and len(training) == 2
native = {name: np.array(pixels, dtype=float) for name, pixels in annotations['picks'].items()}
# Pixel-centre alignment for 1080x1920 native upright -> 720x1280 camera upright.
picks = {name: (pixels+.5)/1.5-.5 for name, pixels in native.items()}
model = pycolmap.Reconstruction(SOURCE/'sparse/0')
views = {view.name: view for view in model.images.values() if view.has_pose}
pins = {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in (SOURCE/'sparse/0').glob('*.bin')}
assert set(picks) <= set(views)
assert not set(picks) & {'IMG_6380_exit6fps/000018.jpg', 'IMG_6380_exit6fps/000048.jpg'}
cameras = {name: model.cameras[views[name].camera_id] for name in picks}
poses = {name: views[name].cam_from_world() for name in picks}
points, angles = zip(*(triangulate(cameras, poses, {name: picks[name][k] for name in training})
    for k in range(len(annotations['labels']))))
points = np.array(points)
assert np.isfinite(points).all() and all(np.all((pose*points)[:, 2] > 0) for pose in poses.values())
errors = {name: np.linalg.norm(project(cameras[name], poses[name], points)-pixels, axis=1).tolist()
    for name, pixels in picks.items()}
for point in points:
    recovered, _ = triangulate(cameras, poses, {name: project(cameras[name], poses[name], point[None])[0]
        for name in training})
    assert np.linalg.norm(recovered-point) < 1e-6
assert np.min(np.linalg.norm(project(cameras[query], poses[query], points)-(picks[query]+[50, 0]), axis=1)) > 8
rng = np.random.default_rng(182)
spread = []
for _ in range(200):
    perturbed = np.array([triangulate(cameras, poses, {name: picks[name][k]+rng.uniform(-2, 2, 2)
        for name in training})[0] for k in range(len(points))])
    spread.append(np.linalg.norm(perturbed-points, axis=1))
for name in picks:
    frame = int(Path(name).stem)
    photo = OUT/f'{frame}-upright.png'
    assert hashlib.sha256(photo.read_bytes()).hexdigest() == annotations['photo_sha256'][name]
    image = Image.open(photo).convert('RGB')
    draw = ImageDraw.Draw(image)
    for label, observed, predicted in zip(annotations['labels'], native[name],
            (project(cameras[name], poses[name], points)+.5)*1.5-.5):
        x, y = observed
        draw.ellipse((x-8, y-8, x+8, y+8), outline='lime', width=3)
        draw.text((x+12, y+10), label, fill='lime')
        x, y = predicted
        draw.line((x-12, y, x+12, y), fill='red', width=3)
        draw.line((x, y-12, x, y+12), fill='red', width=3)
    draw.rectangle((0, 0, 1080, 40), fill='black')
    draw.text((8, 8), f'{name}: '+('RESERVED marks' if name == query else 'FIT marks')+'; no floor/collision acceptance', fill='white')
    image.save(OUT/f'{frame}-prediction.png')
report = dict(annotations=annotations, annotations_sha256=hashlib.sha256(annotation_path.read_bytes()).hexdigest(),
    source_sha256=pins, points_world=points.tolist(), ray_angles_degrees=list(angles), errors_px=errors,
    threshold_px=8, minimum_ray_angle_degrees=1,
    diagnostic_pass=[bool(error <= 8 and angle >= 1) for error, angle in zip(errors[query], angles)],
    manual_pick_p95_world_units=np.percentile(spread, 95, axis=0).tolist(),
    sensitivity_native_pixel_radius=3, navigation_accepted=False, cost_usd=0,
    caveat='New marks frozen before prediction. Reserved pixels unused in triangulation; its camera is '
        'already fitted. Same-video correlated views with inherited intrinsics, not independent survey. '
        'Only the splice is a floor point; casing crease is elevated. No plane, scale, opening or collision inferred.')
assert pins == {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in (SOURCE/'sparse/0').glob('*.bin')}
(OUT/'result.json').write_text(json.dumps(report, indent=2)+'\n')
print(json.dumps(report, indent=2))
