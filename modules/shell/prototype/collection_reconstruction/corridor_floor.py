"""Measure wider corridor floor support from purple baseboard corners, #182."""
import hashlib
import argparse
import json
from pathlib import Path

import numpy as np
import pycolmap
from PIL import Image, ImageDraw
from measurements import project, triangulate

ROOT = Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
SOURCE = ROOT/'sfm-calibrated-doorway-v1'
parser = argparse.ArgumentParser()
parser.add_argument('--earlier-pass', action='store_true')
args = parser.parse_args()
OUT = ROOT/('corridor-floor-v2' if args.earlier_pass else 'corridor-floor-v1')
# Upright source pixels, chosen before evaluating projections. Frame 11 is
# reserved for these manual landmarks, but already contributed to camera SfM.
PICKS = {
    'IMG_6380_exit6fps/000009.jpg': [[232, 720], [363, 832]],
    'IMG_6380_exit6fps/000013.jpg': [[532, 780], [703, 980]],
    'IMG_6380_exit6fps/000011.jpg': [[410, 746], [553, 895]],
}
TRAIN = list(PICKS)[:2]
QUERY = list(PICKS)[2]
if args.earlier_pass:
    # New view selected for wider ray separation, not after testing its residual.
    PICKS = {n: PICKS[n] for n in TRAIN} | {
        'IMG_6380/000238.jpg': [[608, 709], [663, 823]],
        'IMG_6380/000241.jpg': [[275, 725], [394, 849]],
    }
    TRAIN = list(PICKS)[:3]
    QUERY = list(PICKS)[3]
LABELS = ['purple-return-toe', 'elevator-front-toe']
OUT.mkdir(exist_ok=True)
annotations = json.dumps(dict(picks=PICKS, labels=LABELS, training=TRAIN,
    reserved=QUERY, pose_independent=False), indent=2)+'\n'
if (OUT/'annotations.json').exists():
    assert (OUT/'annotations.json').read_text() == annotations, 'Use a new trial for changed picks'
else:
    (OUT/'annotations.json').write_text(annotations)


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def plane(points, up):
    center = points.mean(0)
    _, singular, axes = np.linalg.svd(points-center, full_matrices=False)
    normal = axes[-1]
    return center, normal if normal@up >= 0 else -normal, singular


grid = np.array([[x, 0., z] for x in range(3) for z in range(3)])
c, n, _ = plane(grid, np.array([0, 1, 0]))
assert np.max(np.abs((grid-c)@n)) < 1e-10
assert np.min(np.abs((grid+[0, .1, 0]-c)@n)) > .09
model = pycolmap.Reconstruction(SOURCE/'sparse/0')
views = {i.name: i for i in model.images.values()}
hashes = {p.name: sha(p) for p in (SOURCE/'sparse/0').glob('*.bin')}
audit = json.loads((ROOT/'heldout-calibrated-v1/audit.json').read_text())
assert all(hashes[Path(p).name] == digest for p, digest in audit['source_sha256'].items())
cameras = {name: model.cameras[views[name].camera_id] for name in PICKS}
poses = {name: views[name].cam_from_world() for name in PICKS}
photos = {name: SOURCE/'images'/name for name in PICKS}
assert len({sha(p) for p in photos.values()}) == len(photos)
points, angles = zip(*(triangulate(cameras, poses, {n: PICKS[n][k] for n in TRAIN}) for k in range(2)))
points = np.array(points)
assert np.isfinite(points).all()
assert all(np.all((poses[n]*points)[:, 2] > 0) for n in PICKS)
for point in points:
    recovered, _ = triangulate(cameras, poses, {n: project(cameras[n], poses[n], point[None])[0] for n in TRAIN})
    assert np.linalg.norm(recovered-point) < 1e-6
errors = {n: np.linalg.norm(project(cameras[n], poses[n], points)-PICKS[n], axis=1).tolist() for n in PICKS}
assert np.min(np.linalg.norm(project(cameras[QUERY], poses[QUERY], points)-(np.array(PICKS[QUERY])+[50, 0]), axis=1)) > 8
threshold = json.loads((ROOT/'threshold-landmarks-v1/result.json').read_text())
aperture = json.loads((ROOT/'doorway-aperture-v1/result.json').read_text())
scale = aperture['provisional_m_per_unit']
up = np.array(threshold['jamb_up_world'])
old = np.array(threshold['points_world'])
# Reuse the measured left outer casing toe as the third, non-collinear support.
# The right outer toe and other threshold landmarks are excluded from this fit.
support = np.vstack([old[2], points])
center, normal, singular = plane(support, up)
rng = np.random.default_rng(182)
sensitivity = []
for radius in [3, 6]:
    samples = []
    for _ in range(300):
        new = [triangulate(cameras, poses, {name: np.array(PICKS[name][k])+rng.uniform(-radius, radius, 2) for name in TRAIN})[0] for k in range(2)]
        # Perturb the inherited anchor too, using its original camera pair.
        names = threshold['training']
        anchor = triangulate({n: model.cameras[views[n].camera_id] for n in names},
            {n: views[n].cam_from_world() for n in names},
            {n: np.array(threshold['annotations'][n][2])+rng.uniform(-radius, radius, 2) for n in names})[0]
        pc, pn, _ = plane(np.array([anchor]+new), up)
        samples.append([np.degrees(np.arccos(np.clip(pn@normal, -1, 1))),
                        abs((old[3]-pc)@pn)*scale])
    sensitivity.append(dict(pixel_uniform_radius=radius, samples=300,
        columns=['normal_deviation_degrees', 'excluded_right_outer_toe_distance_m'],
        percentiles=[5, 50, 95], values=np.percentile(samples, [5, 50, 95], axis=0).tolist()))
far = json.loads((ROOT/'floor-patches-v2/result.json').read_text())['patches'][1]
far_normal = np.array(far['normal_world'])
if far_normal@normal < 0:
    far_normal = -far_normal
for name, path in photos.items():
    im = Image.open(path).transpose(Image.Transpose.ROTATE_270).convert('RGB')
    d = ImageDraw.Draw(im)
    for label, pick, prediction in zip(LABELS, PICKS[name], project(cameras[name], poses[name], points)):
        x, y = pick
        d.ellipse((x-7, y-7, x+7, y+7), outline='lime', width=2)
        d.text((min(x+9, 580), y+12), label, fill='lime')
        x, y = prediction
        d.line((x-8, y, x+8, y), fill='red', width=2)
        d.line((x, y-8, x, y+8), fill='red', width=2)
    projected = project(cameras[name], poses[name], support)
    d.line([tuple(p) for p in projected]+[tuple(projected[0])], fill='cyan', width=2)
    d.rectangle((0, 0, 720, 58), fill='black')
    d.text((8, 5), name+(' RESERVED LANDMARKS' if name == QUERY else 'FIT'), fill='white')
    d.text((8, 23), 'Green picks; red predictions; cyan measured support triangle.', fill='white')
    d.text((8, 41), 'Camera poses are correlated. No full corridor extent or navigation acceptance.', fill='white')
    im.save(OUT/(Path(name).stem+'.png'))

report = dict(labels=LABELS, annotations=PICKS, training=TRAIN, reserved=QUERY,
    source_sha256=hashes, image_sha256={n: sha(p) for n, p in photos.items()},
    points_world=points.tolist(), maximum_ray_angle_degrees=list(angles),
    reprojection_errors_px=errors, landmark_diagnostic_pass=bool(max(errors[QUERY]) <= 8 and min(angles) >= 1),
    support_world=support.tolist(), center_world=center.tolist(), normal_world=normal.tolist(),
    support_triangle_area_m2=float(np.linalg.norm(np.cross(support[1]-support[0], support[2]-support[0]))*.5*scale**2),
    plane_spread_singular_values_m=(singular*scale).tolist(),
    threshold_signed_distances_m=dict(zip(threshold['labels'], ((old-center)@normal*scale).tolist())),
    far_floor_angle_degrees=float(np.degrees(np.arccos(np.clip(far_normal@normal, -1, 1)))),
    floor_relative_to_aperture_toes_m=(((center-np.array(aperture['corners_world'][:2]))@normal)/(up@normal)*scale).tolist(),
    provisional_m_per_unit=scale, sensitivity=sensitivity, navigation_accepted=False,
    caveat='Manual landmarks held out of triangulation only; reserved camera already in SfM. Source blur limits toe picks. Three-point plane has zero fit residual by construction. Existing threshold anchor reused, but all other threshold points excluded. Sensitivity omits pose and scale errors. Only the observed triangle is supported, not a whole corridor or surveyed level floor.')
assert hashes == {p.name: sha(p) for p in (SOURCE/'sparse/0').glob('*.bin')}
(OUT/'result.json').write_text(json.dumps(report, indent=2)+'\n')
print(json.dumps(report, indent=2))
