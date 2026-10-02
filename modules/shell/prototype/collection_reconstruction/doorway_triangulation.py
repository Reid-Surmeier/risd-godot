"""Triangulate reviewed jamb/floor pixels; reserve a photograph for prediction."""
import hashlib
import json
from pathlib import Path

import numpy as np
import pycolmap
from PIL import Image, ImageDraw
from measurements import raw, upright, project as camera_project, triangulate as camera_triangulate, heldout_pose

ROOT = Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
SOURCE = ROOT/'sfm-calibrated-doorway-v1'
OUT = ROOT/'doorway-triangulation-v1'
# Upright 720x1280 source pixels: inner left/right jamb intersection with floor.
# Deliberately no plane assumption across the stepped/recessed casing.
ANNOTATIONS = {
    'IMG_6380/000505.jpg': [[110, 778], [469, 760]],
    'IMG_6380_exit6fps/000013.jpg': [[84, 770], [431, 746]],
    'IMG_6380_exit6fps/000018.jpg': [[166, 827], [586, 832]],
    'IMG_6380/000506.jpg': [[168, 809], [568, 800]],
}
TRAIN = list(ANNOTATIONS)[:3]
QUERY = list(ANNOTATIONS)[3]
model = pycolmap.Reconstruction(SOURCE/'sparse/0')
references = {i.name: i for i in model.images.values()}
assert QUERY not in references
hashes = {str(p.relative_to(SOURCE)): hashlib.sha256(p.read_bytes()).hexdigest()
          for p in (SOURCE/'sparse/0').glob('*.bin')}
cameras = {n: model.cameras[references[n].camera_id] for n in TRAIN}
poses = {n: references[n].cam_from_world() for n in TRAIN}

cameras[QUERY], poses[QUERY], pose_inliers = heldout_pose(
    model, ROOT/'heldout-calibrated-v1/database.db', QUERY, ANNOTATIONS[QUERY])


def project(name, points):
    return camera_project(cameras[name], poses[name], points)


def triangulate(observations):
    return camera_triangulate(cameras, poses, observations)


points, angles = zip(*(triangulate({n: np.array(ANNOTATIONS[n][k]) for n in TRAIN}) for k in range(2)))
points = np.array(points)
assert np.isfinite(points).all()
assert all(np.all((poses[n]*points)[:, 2] > 0) for n in ANNOTATIONS)
# Runnable regression: recover synthetic points through the same camera adapters.
for p in points:
    recovered, _ = triangulate({n: project(n, p[None])[0] for n in TRAIN})
    assert np.linalg.norm(recovered-p) < 1e-6
assert np.allclose(upright(raw(points[:, :2])), points[:, :2])
audit = json.loads((ROOT/'heldout-calibrated-v1/audit.json').read_text())
assert hashes == audit['source_sha256']
alignment = next(x for x in audit['component_consistency'] if x['component'] == 5)
anchor = next(x for x in json.loads((ROOT/'scale-bookcase-v1/result.json').read_text()) if x['component'] == '5')
scale = alignment['scale']*anchor['meters_per_unit']
errors = {n: np.linalg.norm(project(n, points)-ANNOTATIONS[n], axis=1).tolist() for n in ANNOTATIONS}
# Sensitivity to manual picking is a diagnostic, not a statistical confidence interval.
rng = np.random.default_rng(182)
widths = []
for _ in range(100):
    perturbed = [triangulate({n: np.array(ANNOTATIONS[n][k])+rng.normal(0, 3, 2) for n in TRAIN})[0] for k in range(2)]
    widths.append(float(np.linalg.norm(perturbed[1]-perturbed[0])*scale))
threshold = 8.  # Prototype diagnostic only; final quality contract #181 remains open.
passed = max(errors[QUERY]) <= threshold and min(angles) >= 1.
# A displaced withheld annotation must fail the same diagnostic.
assert np.max(np.linalg.norm(project(QUERY, points)-(np.array(ANNOTATIONS[QUERY])+[50, 0]), axis=1)) > threshold
OUT.mkdir(exist_ok=True)
source_hashes = {}
for n in ANNOTATIONS:
    source = ROOT/('sfm-doorway-v1/images' if 'exit6fps' in n else 'survey-2fps')/n
    source_hashes[n] = hashlib.sha256(source.read_bytes()).hexdigest()
    picture = Image.open(source).transpose(Image.Transpose.ROTATE_270).convert('RGB')
    assert picture.size == (720, 1280)
    draw = ImageDraw.Draw(picture)
    for k, (observed, predicted) in enumerate(zip(ANNOTATIONS[n], project(n, points))):
        x, y = observed
        draw.ellipse((x-7, y-7, x+7, y+7), outline='lime', width=2)
        x, y = predicted
        draw.line((x-9, y, x+9, y), fill='red', width=2)
        draw.line((x, y-9, x, y+9), fill='red', width=2)
    draw.rectangle((0, 0, 720, 45), fill='black')
    draw.text((8, 5), n+(' HELD OUT' if n == QUERY else 'FIT'), fill='white')
    draw.text((8, 24), 'Green: manual floor corners; red: triangulated prediction', fill='white')
    picture.save(OUT/(n.replace('/', '-')+'.png'))
floor = json.loads((ROOT/'doorway-geometry-v1/geometry.json').read_text())
floor_residuals = (points-floor['world_origin'])@np.array(floor['basis_rows'])[1]*scale
report = dict(floor_residuals_provisional_m=floor_residuals.tolist(), source_sha256=hashes, source_image_sha256=source_hashes, annotations=ANNOTATIONS,
              training=TRAIN, heldout=QUERY, heldout_pose_fit_inliers=pose_inliers,
              corners_world=points.tolist(), maximum_ray_angle_degrees=list(angles),
              reprojection_errors_px=errors, width_provisional_m=float(np.linalg.norm(points[1]-points[0])*scale),
              width_3px_perturbation_p10_p90_m=np.percentile(widths, [10, 90]).tolist(),
              provisional_m_per_unit=scale, heldout_threshold_px=threshold, diagnostic_pass=bool(passed),
              navigation_accepted=False,
              caveat='Manual blurred-video picks; correlated nearby captures; metric scale inherits stepped bookcase bias. No height, room shell, collisions or final #181 tolerance acceptance.')
assert all(hashlib.sha256((SOURCE/p).read_bytes()).hexdigest() == h for p, h in hashes.items())
(OUT/'result.json').write_text(json.dumps(report, indent=2)+'\n')
print(json.dumps(report, indent=2))
