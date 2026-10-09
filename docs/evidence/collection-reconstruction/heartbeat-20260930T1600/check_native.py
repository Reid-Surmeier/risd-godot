"""Run with ingestion .venv/bin/python from the prototype checkout."""
import json
from pathlib import Path
import sys

import numpy as np
import pycolmap

sys.path.insert(0, 'modules/shell/prototype/collection_reconstruction')
from measurements import project, triangulate, upright

here = Path(__file__).parent
root = Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
report = json.loads((here/'result.json').read_text())
selection = report['selection']
assert not set(selection['training']) & set(selection['reserved'])
assert not report['navigation_accepted'] and not report['floor_pixels_used_for_query_pose']
original = json.loads((here/'source-candidates.json').read_text())
assert original == [{k: v for k, v in c.items() if k != 'reserved'} for c in report['candidates']]
assert len(original) == 1, 'Recorded native run has only one source floor anchor.'
model = pycolmap.Reconstruction(root/'sfm-strict-doorway-v1/sparse/0')
views = {v.name: v for v in model.images.values() if v.has_pose}
cameras = {n: model.cameras[views[n].camera_id] for n in selection['training']}
poses = {n: views[n].cam_from_world() for n in selection['training']}
point, angle = triangulate(cameras, poses, original[0]['source_pixels'])
assert np.allclose(point, original[0]['point_world'], atol=1e-10)
assert abs(angle-3.919215348827046) < 1e-8
wall = json.loads((here/'wall-poses.json').read_text())
old = json.loads((root/'strict-floor-holdout-checkpoint-replay/result.json').read_text())
old_rows = {r['image']: r for r in old['rows']}
assert wall['pose_fit_upright_y_below'] == 450
assert wall['all_floor_query_features_excluded_from_pose']
for row in wall['rows']:
    assert {k: v for k, v in row.items() if k not in ['camera', 'cam_from_world']} == old_rows[row['image']]
    assert row['pose_supported'] and row['image'] not in views
    matrix = np.array(row['cam_from_world'])
    pose = pycolmap.Rigid3d(pycolmap.Rotation3d(matrix[:, :3]), matrix[:, 3])
    predicted = project(pycolmap.Camera(row['camera']), pose, point[None])[0]
    evaluation = report['candidates'][0]['reserved'][row['image']]
    assert np.allclose(predicted, evaluation['predicted_pixel'], atol=1e-10)
    for observation in evaluation['observations']:
        error = np.linalg.norm(predicted-observation['pixel'])
        assert abs(error-observation['error_px']) < 1e-8
        assert np.linalg.norm(predicted-(np.array(observation['pixel'])+[50, 0])) > 8
assert len(report['candidates'][0]['reserved']['IMG_6380/000246.jpg']['observations']) == 0
assert abs(report['candidates'][0]['reserved']['IMG_6380/000506.jpg']['observations'][0]['error_px']-6.330078397849466) < 1e-8
print('Source freeze, exact default replay, wall-only poses, ray/projection and negative-control checks pass.')

# Exploratory plane: the only native candidate plus two previously frozen threshold
# features. Reserved pixels choose none of these points; old queries are reused.
threshold_path = root/'strict-floor-tracks-v2/result.json'
threshold = json.loads(threshold_path.read_text())
assert threshold['selection']['point_ids'][:2] == [13116, 13515]
assert threshold['source_sha256'] == report['source_sha256']
points = np.array(threshold['points_world'][:2]+[point.tolist()])
normal = np.cross(points[1]-points[0], points[2]-points[0])
normal /= np.linalg.norm(normal)
assert max(abs((points-points.mean(0))@normal)) < 1e-8
names = threshold['selection']['training']
threshold_cameras = {n: model.cameras[views[n].camera_id] for n in names}
threshold_poses = {n: views[n].cam_from_world() for n in names}
picks = {n: {int(p.point3D_id): upright(p.xy)
    for p in views[n].points2D if p.has_point3D() and int(p.point3D_id) in [13116, 13515]} for n in names}
rng = np.random.default_rng(182)
changes = []
for _ in range(200):
    perturbed = [triangulate(threshold_cameras, threshold_poses,
        {n: picks[n][i]+rng.uniform(-2, 2, 2) for n in names})[0] for i in [13116, 13515]]
    perturbed.append(triangulate(cameras, poses,
        {n: np.array(p)+rng.uniform(-2/1.5, 2/1.5, 2) for n, p in original[0]['source_pixels'].items()})[0])
    cross = np.cross(perturbed[1]-perturbed[0], perturbed[2]-perturbed[0])
    changes.append(float(np.degrees(np.arccos(np.clip(abs(cross@normal)/np.linalg.norm(cross), 0, 1)))))
combined = dict(selection=dict(training=names+selection['training'], reserved=selection['reserved'],
    point_ids=[13116, 13515, 'native-candidate-0'],
    reason='Only native source candidate plus two previously frozen floor tracks; no query-residual selection.'),
    points_world=points.tolist(), candidate_normal_world=normal.tolist(), source_sha256=report['source_sha256'],
    normal_change_p95_degrees=float(np.percentile(changes, 95)),
    sensitivity_note='Threshold picks +/-2 at 720px; native picks +/-2 at1080px. Camera uncertainty omitted.',
    navigation_accepted=False, cost_usd=0,
    caveat='Exploratory reuse of old reserved views, correlated cameras and unverified native identity. '
        'Three points define a hypothesis, not physical planarity, metric scale, extent or collision acceptance.')
(here/'combined-triangle.json').write_text(json.dumps(combined, indent=2)+'\n')
print('Combined plane p95 normal change:', combined['normal_change_p95_degrees'])
