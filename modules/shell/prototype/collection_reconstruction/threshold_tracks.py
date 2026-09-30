"""Diagnose threshold residuals from cached three-view tracks, without refitting SfM."""
import hashlib
import json
from pathlib import Path

import numpy as np
import pycolmap
from PIL import Image, ImageDraw
from measurements import project, raw, triangulate, upright

ROOT = Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
OUT = ROOT/'strict-threshold-native-v1'
assert not (OUT/'track-audit-depth-checked.json').exists(), 'Preserve completed diagnostics.'
measured = json.loads((OUT/'result.json').read_text())
source = ROOT/'sfm-strict-doorway-v1/sparse/0'
assert measured['source_sha256'] == {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in source.glob('*.bin')}
annotation = measured['annotations']
training, query = annotation['training'], annotation['reserved']
model = pycolmap.Reconstruction(ROOT/'sfm-strict-doorway-v1/sparse/0')
views = {v.name: v for v in model.images.values() if v.has_pose}
cameras = {name: model.cameras[views[name].camera_id] for name in training+[query]}
poses = {name: views[name].cam_from_world() for name in training+[query]}
tracks = {name: {p.point3D_id: upright(p.xy) for p in views[name].points2D if p.has_point3D()}
    for name in training+[query]}
ids = sorted(set.intersection(*(set(t) for t in tracks.values())))
rows = []
for point_id in ids:
    point, angle = triangulate(cameras, poses, {name: tracks[name][point_id] for name in training})
    if angle < 1 or any((pose*point)[2] <= 0 for pose in poses.values()):
        continue
    fitted = max(np.linalg.norm(project(cameras[name], poses[name], point[None])[0]-tracks[name][point_id])
        for name in training)
    if fitted > 4:
        continue
    observed = tracks[query][point_id]
    residual = project(cameras[query], poses[query], point[None])[0]-observed
    rows.append(dict(point_id=int(point_id), xyz=point.tolist(), observed=observed.tolist(),
        residual=residual.tolist(), error_px=float(np.linalg.norm(residual)), ray_angle_degrees=angle))
assert rows, 'No three-view tracks with adequate training geometry.'
xy = np.array([r['observed'] for r in rows])
xyz = np.array([r['xyz'] for r in rows])
errors = np.array([r['error_px'] for r in rows])
marks = (np.array(annotation['picks'][query])+.5)/1.5-.5
near = np.min(np.linalg.norm(xy[:, None]-marks[None], axis=2), axis=1) < 100
report = dict(samples=len(rows), median_error_px=float(np.median(errors)),
    p95_error_px=float(np.percentile(errors, 95)), below8px=int((errors <= 8).sum()),
    near_marks_samples=int(near.sum()), near_marks_median_error_px=float(np.median(errors[near])) if near.any() else None,
    rows=rows, alternative_pose=None, navigation_accepted=False, cost_usd=0,
    caveat='Tracked points triangulated from the two training cameras only. Query pixels excluded '
        'from that triangulation, but training cameras were globally fitted using query observations. '
        'Correlated diagnostic only; frozen model and failed manual trial unchanged.')
fit = np.array([r['point_id'] % 2 == 1 for r in rows])
fit &= np.min(np.linalg.norm(xy[:, None]-marks[None], axis=2), axis=1) > 20
test = np.array([r['point_id'] % 2 == 0 for r in rows])
if fit.sum() >= 20 and test.sum() >= 20:
    camera = pycolmap.Camera(cameras[query].todict())
    options = pycolmap.AbsolutePoseEstimationOptions()
    options.ransac.max_error = 4.
    options.ransac.random_seed = 182
    pose = pycolmap.estimate_and_refine_absolute_pose(raw(xy[fit]), xyz[fit], camera, estimation_options=options)
    if pose:
        test_errors = np.linalg.norm(project(camera, pose['cam_from_world'], xyz[test])-xy[test], axis=1)
        mark_errors = np.linalg.norm(project(camera, pose['cam_from_world'], np.array(measured['points_world']))-marks, axis=1)
        good = np.isfinite(test_errors) & (test_errors < 4) & ((pose['cam_from_world']*xyz[test])[:, 2] > 0)
        report['alternative_pose'] = dict(fit_points=int(fit.sum()), fit_inliers=int(pose['num_inliers']),
            test_points=int(test.sum()), test_below4px=int(good.sum()),
            test_median_error_px=float(np.median(test_errors)), manual_mark_errors_px=mark_errors.tolist(),
            caveat='Pose diagnostic from odd track IDs; even tracks and manual marks excluded from pose fit. No acceptance or camera replacement.')
image = Image.open(OUT/'23-upright.png').convert('RGB')
draw = ImageDraw.Draw(image)
for row in rows:
    x, y = (np.array(row['observed'])+.5)*1.5-.5
    delta = np.array(row['residual'])*1.5
    draw.ellipse((x-3, y-3, x+3, y+3), outline='lime' if row['error_px'] <= 8 else 'orange', width=2)
    draw.line((x, y, x+delta[0], y+delta[1]), fill='red', width=2)
draw.rectangle((0, 0, 1080, 32), fill='black')
draw.text((8, 8), f'{len(rows)} cached tracks; two-view geometry, original query pose; correlated diagnostic', fill='white')
image.save(OUT/'23-track-residuals-depth-checked.png')
assert measured['source_sha256'] == {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in source.glob('*.bin')}
(OUT/'track-audit-depth-checked.json').write_text(json.dumps(report, indent=2)+'\n')
print(json.dumps({k: v for k, v in report.items() if k != 'rows'}, indent=2))
