"""Test wider near-floor support from observed purple-wall junctions (#182)."""
import hashlib
import json
from pathlib import Path

import numpy as np
import pycolmap
from PIL import Image, ImageDraw
from measurements import heldout_pose, project, triangulate

ROOT = Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
SOURCE = ROOT/'sfm-calibrated-doorway-v1/sparse/0'
OUT = ROOT/'wall-floor-landmarks-v1'
PREFIX = 'IMG_6380_exit6fps/'
# Upright 720x1280 pixels, frozen before inspecting any predicted projection.
# Each point has its own visible training views. No occluded corner is invented.
TRAIN = {
    'casing-left': {13: [52, 794], 18: [127, 858]},
    'casing-right': {13: [459, 766], 18: [630, 872]},
    'purple-reentrant': {10: [334, 734], 13: [531, 782]},
    'purple-door5-toe': {10: [463, 861], 13: [710, 981]},
}
RESERVED = {
    12: {'casing-left': [18, 789], 'casing-right': [413, 748],
         'purple-reentrant': [479, 761], 'purple-door5-toe': [640, 935]},
    15: {'casing-left': [101, 815], 'casing-right': [534, 808],
         'purple-reentrant': [620, 830]},
}


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def name(frame):
    return PREFIX+f'{frame:06}.jpg'


def plane(points):
    center = points.mean(0)
    _, singular, axes = np.linalg.svd(points-center, full_matrices=False)
    return center, axes[-1], singular


OUT.mkdir(exist_ok=True)
annotations = json.dumps(dict(training=TRAIN, reserved=RESERVED), indent=2)+'\n'
path = OUT/'annotations.json'
if path.exists():
    assert path.read_text() == annotations, 'Use a new trial; do not tune evaluated picks'
else:
    path.write_text(annotations)
model = pycolmap.Reconstruction(SOURCE)
views = {i.name: i for i in model.images.values()}
frames = sorted({f for obs in TRAIN.values() for f in obs} | set(RESERVED))
photos = {f: ROOT/'sfm-doorway-v1/images'/name(f) for f in frames}
inputs = {str(p): sha(p) for p in SOURCE.glob('*.bin')}
inputs.update({str(p): sha(p) for p in photos.values()})
cameras = {name(f): model.cameras[views[name(f)].camera_id] for f in frames if name(f) in views}
poses = {name(f): views[name(f)].cam_from_world() for f in frames if name(f) in views}
assert name(15) not in views
cameras[name(15)], poses[name(15)], inliers = heldout_pose(
    model, ROOT/'doorway-aperture-v1/database.db', name(15), list(RESERVED[15].values()))
points, angles = zip(*(triangulate(cameras, poses, {name(f): p for f, p in obs.items()})
                      for obs in TRAIN.values()))
points = np.array(points)
assert np.isfinite(points).all()
labels = list(TRAIN)
aperture = json.loads((ROOT/'doorway-aperture-v1/result.json').read_text())
scale = aperture['provisional_m_per_unit']
up = np.array(aperture['basis_rows'])[1]
center, normal, singular = plane(points)
if normal@up < 0:
    normal = -normal
# Runnable geometry checks: ray round trip and known parallel-plane displacement.
grid = np.array([[x, 0., z] for x in range(3) for z in range(3)])
gc, gn, _ = plane(grid)
assert np.max(np.abs((grid-gc)@gn)) < 1e-10
assert np.min(np.abs((grid+[0, .1, 0]-gc)@gn)) > .099
for point, obs in zip(points, TRAIN.values()):
    recovered, _ = triangulate(cameras, poses, {
        name(f): project(cameras[name(f)], poses[name(f)], point[None])[0] for f in obs})
    assert np.linalg.norm(recovered-point) < 1e-6
rng = np.random.default_rng(182)
sensitivity = []
for _ in range(300):
    trial = np.array([triangulate(cameras, poses, {
        name(f): np.array(p)+rng.uniform(-3, 3, 2) for f, p in obs.items()
    })[0] for obs in TRAIN.values()])
    _, tn, _ = plane(trial)
    sensitivity.append(np.degrees(np.arccos(np.clip(abs(tn@normal), -1, 1))))
rows = []
for f in frames:
    observed = RESERVED.get(f, {label: obs[f] for label, obs in TRAIN.items() if f in obs})
    im = Image.open(photos[f]).transpose(Image.Transpose.ROTATE_270).convert('RGB')
    draw = ImageDraw.Draw(im)
    for label, pixel in observed.items():
        k = labels.index(label)
        assert (poses[name(f)]*points[k])[2] > 0
        pred = project(cameras[name(f)], poses[name(f)], points[k:k+1])[0]
        error = float(np.linalg.norm(pred-pixel))
        rows.append(dict(frame=f, landmark=label, reserved=f in RESERVED, error_px=error))
        if f in RESERVED:
            assert np.linalg.norm(pred-(np.array(pixel)+[50, 0])) > 8
        x, y = pixel
        draw.ellipse((x-6, y-6, x+6, y+6), outline='lime', width=2)
        draw.text((max(2, min(x+8, 555)), y+8), label, fill='lime')
        x, y = pred
        draw.line((x-8, y, x+8, y), fill='red', width=2)
        draw.line((x, y-8, x, y+8), fill='red', width=2)
    draw.rectangle((0, 0, 720, 42), fill='black')
    draw.text((8, 5), name(f)+(' RESERVED PICKS' if f in RESERVED else 'FIT'), fill='white')
    draw.text((8, 23), 'Green: observed. Red: predicted. Floor hypothesis, not navigation.', fill='white')
    im.save(OUT/f'{f:06}.png')
threshold = json.loads((ROOT/'threshold-landmarks-v1/result.json').read_text())
knot = np.array(threshold['points_world'])[-1]
report = dict(training=TRAIN, reserved=RESERVED, labels=labels,
    points_world=points.tolist(), center_world=center.tolist(), normal_world=normal.tolist(),
    ray_angles_degrees=list(angles), plane_spread_singular_values_m=(singular*scale).tolist(),
    plane_residuals_m=(np.abs((points-center)@normal)*scale).tolist(),
    reserved_threshold_knot_distance_m=float(abs((knot-center)@normal)*scale),
    provisional_m_per_unit=scale, source_sha256=inputs, errors=rows,
    withheld_frame15_pose_inliers=inliers,
    pick_sensitivity=dict(uniform_radius_px=3, trials=300, percentiles=[5, 50, 95],
                          normal_deviation_degrees=np.percentile(sensitivity, [5, 50, 95]).tolist()),
    navigation_accepted=False,
    caveat='Frame 12 reserves manual geometry picks only: its pose contributed to SfM. '
           'Frame 15 was withheld from SfM, but is from the same correlated video and was used '
           'in previous trials. Blurry wall/baseboard junctions and provisional scale remain. '
           'Pixel perturbation is sensitivity, not a confidence interval or gravity calibration.')
assert all(sha(Path(p)) == digest for p, digest in inputs.items())
(OUT/'result.json').write_text(json.dumps(report, indent=2)+'\n')
print(json.dumps(report, indent=2))
