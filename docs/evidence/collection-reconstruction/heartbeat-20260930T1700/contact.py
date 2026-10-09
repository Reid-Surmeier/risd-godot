"""Source-frozen single jamb contact; never accept floor, scale or navigation."""
import hashlib
import json
from pathlib import Path
import sys

import numpy as np
import pycolmap
from PIL import Image, ImageDraw

sys.path.insert(0, 'modules/shell/prototype/collection_reconstruction')
from measurements import project, raw, triangulate

out = Path(__file__).parent
root = Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
selection = json.loads((out/'source-selection-wall700.json').read_text())
source = root/'sfm-strict-doorway-v1/sparse/0'
assert selection['source_sha256'] == {p.name: sha(p) for p in source.glob('*.bin')}
model = pycolmap.Reconstruction(source)
views = {v.name: v for v in model.images.values() if v.has_pose}
names = selection['training']
assert not set(names) & set(selection['reserved'])
cameras = {n: model.cameras[views[n].camera_id] for n in names}
poses = {n: views[n].cam_from_world() for n in names}
picks = {n: np.array(selection['source_pixels_upright'][n], dtype=float) for n in names}
point, angle = triangulate(cameras, poses, picks)
assert np.isfinite(point).all()
errors = {n: float(np.linalg.norm(project(cameras[n], poses[n], point[None])[0]-picks[n])) for n in names}
rng = np.random.default_rng(182)
cloud = np.array([triangulate(cameras, poses, {n: picks[n]+rng.normal(0, selection['uncertainty_px'], 2)
    for n in names})[0] for _ in range(500)])
depth = np.mean([np.linalg.norm(point-poses[n].inverse().translation) for n in names])
report = dict(selection=selection, point_world=point.tolist(), ray_angle_degrees=angle,
    training_errors_px=errors, positive_depth=all((poses[n]*point)[2] > 0 for n in names),
    perturbation_p95_fraction_camera_distance=float(np.percentile(np.linalg.norm(cloud-point, axis=1)/depth, 95)),
    navigation_accepted=False, cost_usd=0,
    caveat='Single manually marked source-visible contact, globally fitted source cameras; '
        'same-video and inherited-calibration correlation. No metric scale, opening width or floor plane.')
# Freeze the source calculation before opening the reserved pose or photograph.
target = out/'contact-source-result.json'
assert not target.exists(), 'Preserve completed trials'
target.write_text(json.dumps(report, indent=2)+'\n')
pose_path = root/'strict-6384-wall-pose-v2/result.json'
pose_report = json.loads(pose_path.read_text())
for name in selection['reserved']:
    assert name not in views
    row = next(r for r in pose_report['rows'] if r['image'] == name)
    if not row['pose_supported']:
        report['reserved'] = dict(image=name, status=row['status'], pose_supported=False)
        continue
    camera = pycolmap.Camera(row['camera'])
    matrix = np.array(row['cam_from_world'])
    pose = pycolmap.Rigid3d(pycolmap.Rotation3d(matrix[:, :3]), matrix[:, 3])
    predicted = project(camera, pose, point[None])[0]
    assert np.allclose(raw(predicted), camera.img_from_cam(pose*point))
    report['reserved'] = dict(image=name, predicted_pixel=predicted.tolist(), pose_supported=True,
        pose_inliers=row['pose_inliers'], pose_test_below4px=row['pose_test_below4px'])
    picture = Image.open(root/'survey-2fps'/name).transpose(Image.Transpose.ROTATE_270).convert('RGB')
    draw = ImageDraw.Draw(picture)
    x, y = predicted
    draw.line((x-10, y, x+10, y), fill='red', width=2)
    draw.line((x, y-10, x, y+10), fill='red', width=2)
    draw.rectangle((0, 0, 720, 40), fill='black')
    draw.text((8, 8), 'Frozen jamb contact prediction; identity UNVERIFIED', fill='white')
    picture.save(out/'reserved-contact-prediction.png')
assert selection['source_sha256'] == {p.name: sha(p) for p in source.glob('*.bin')}
report['inputs_sha256'] = {str(p): sha(p) for p in [out/'source-selection-wall700.json', pose_path, *source.glob('*.bin')]}
(out/'contact-result.json').write_text(json.dumps(report, indent=2)+'\n')
print(json.dumps(report, indent=2))
