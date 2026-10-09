"""Triangulate the observed threshold strip; do not extend it into a room floor."""
import hashlib
import json
from pathlib import Path

import numpy as np
import pycolmap
from PIL import Image, ImageDraw
from measurements import heldout_pose, project, triangulate

ROOT = Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
SOURCE = ROOT/'sfm-calibrated-doorway-v1'
OUT = ROOT/'threshold-landmarks-v1'
# Upright source pixels. Frozen before any fitted projection was inspected.
# First two are existing aperture toe picks. Next two are the outer casing
# toes, at the near edge of the threshold. Last is a visible threshold knot.
LABELS = ['inner-left', 'inner-right', 'outer-left', 'outer-right', 'knot']
PICKS = {
    'IMG_6380_exit6fps/000013.jpg': [[84, 770], [431, 746], [52, 794], [459, 766], [265, 775]],
    'IMG_6380_exit6fps/000018.jpg': [[166, 827], [586, 832], [127, 858], [630, 872], [364, 851]],
    'IMG_6380_exit6fps/000015.jpg': [[134, 791], [504, 783], [101, 815], [534, 808], [316, 804]],
}
TRAIN = list(PICKS)[:2]
QUERY = list(PICKS)[2]
THRESHOLD = 8.  # Existing exploratory pixel diagnostic, not the #181 contract.
OUT.mkdir(exist_ok=True)
frozen = OUT/'annotations.json'
serialized = json.dumps(dict(labels=LABELS, picks=PICKS, train=TRAIN, query=QUERY), indent=2)+'\n'
if frozen.exists():
    assert frozen.read_text() == serialized, 'Preserve evaluated picks; use a new named trial'
else:
    frozen.write_text(serialized)


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def plane(points):
    center = points.mean(0)
    _, singular, axes = np.linalg.svd(points-center, full_matrices=False)
    return center, axes[-1], singular


# Plane recovery and displaced-plane negative control.
grid = np.array([[x, 0., z] for x in range(3) for z in range(3)])
c, n, _ = plane(grid)
assert np.max(np.abs((grid-c)@n)) < 1e-10
assert np.min(np.abs((grid+[0., .1, 0.]-c)@n)) > .09
model = pycolmap.Reconstruction(SOURCE/'sparse/0')
refs = {i.name: i for i in model.images.values()}
hashes = {p.name: sha(p) for p in (SOURCE/'sparse/0').glob('*.bin')}
photos = {name: ROOT/'sfm-doorway-v1/images'/name for name in PICKS}
assert QUERY not in refs
assert sha(photos[QUERY]) not in {sha(photos[n]) for n in TRAIN}
cameras = {n: model.cameras[refs[n].camera_id] for n in TRAIN}
poses = {n: refs[n].cam_from_world() for n in TRAIN}
cameras[QUERY], poses[QUERY], inliers = heldout_pose(
    model, ROOT/'doorway-aperture-v1/database.db', QUERY, PICKS[QUERY])
points, angles = zip(*(triangulate(cameras, poses, {n: PICKS[n][k] for n in TRAIN}) for k in range(len(LABELS))))
points = np.array(points)
assert np.isfinite(points).all()
assert all(np.all((poses[n]*points)[:, 2] > 0) for n in PICKS)
for p in points:
    recovered, _ = triangulate(cameras, poses, {n: project(cameras[n], poses[n], p[None])[0] for n in TRAIN})
    assert np.linalg.norm(recovered-p) < 1e-6
errors = {n: np.linalg.norm(project(cameras[n], poses[n], points)-PICKS[n], axis=1).tolist() for n in PICKS}
assert np.min(np.linalg.norm(project(cameras[QUERY], poses[QUERY], points)-(np.array(PICKS[QUERY])+[50, 0]), axis=1)) > THRESHOLD
aperture = json.loads((ROOT/'doorway-aperture-v1/result.json').read_text())
scale = aperture['provisional_m_per_unit']
up = np.array(aperture['basis_rows'])[1]
center, normal, singular = plane(points[:4])
if normal@up < 0:
    normal = -normal
# Pixel sensitivity describes manual-pick uncertainty only, not camera/scale error.
rng = np.random.default_rng(182)
samples = []
for _ in range(300):
    perturbed = np.array([triangulate(cameras, poses, {
        name: np.array(PICKS[name][k])+rng.uniform(-3., 3., 2) for name in TRAIN
    })[0] for k in range(4)])
    pc, pn, _ = plane(perturbed)
    if pn@up < 0:
        pn = -pn
    samples.append([np.degrees(np.arccos(np.clip(pn@normal, -1., 1.))),
                    np.linalg.norm(perturbed[2]-perturbed[0])*scale,
                    np.linalg.norm(perturbed[3]-perturbed[1])*scale])
for name, path in photos.items():
    im = Image.open(path).transpose(Image.Transpose.ROTATE_270).convert('RGB')
    draw = ImageDraw.Draw(im)
    for label, observed, predicted in zip(LABELS, PICKS[name], project(cameras[name], poses[name], points)):
        x, y = observed
        draw.ellipse((x-6, y-6, x+6, y+6), outline='lime', width=2)
        draw.text((x+8, y+8), label, fill='lime')
        x, y = predicted
        draw.line((x-8, y, x+8, y), fill='red', width=2)
        draw.line((x, y-8, x, y+8), fill='red', width=2)
    draw.rectangle((0, 0, 720, 45), fill='black')
    draw.text((8, 5), name+(' RESERVED' if name == QUERY else 'FIT'), fill='white')
    draw.text((8, 23), 'Green: frozen picks; red: triangulated predictions. Not accepted floor.', fill='white')
    im.save(OUT/(Path(name).stem+'.png'))
report = dict(labels=LABELS, annotations=PICKS, training=TRAIN, heldout=QUERY,
    source_sha256=hashes, image_sha256={n: sha(p) for n, p in photos.items()},
    heldout_pose_fit_inliers=inliers, points_world=points.tolist(),
    maximum_ray_angle_degrees=list(angles), reprojection_errors_px=errors,
    threshold_px=THRESHOLD, diagnostic_pass=bool(max(errors[QUERY]) <= THRESHOLD and min(angles) >= 1),
    provisional_m_per_unit=scale, center_world=center.tolist(), normal_world=normal.tolist(),
    corner_plane_residuals_m=(np.abs((points[:4]-center)@normal)*scale).tolist(),
    reserved_knot_plane_distance_m=float(abs((points[4]-center)@normal)*scale),
    plane_spread_singular_values_m=(singular*scale).tolist(),
    inner_to_outer_lengths_m=(np.linalg.norm(points[2:4]-points[:2], axis=1)*scale).tolist(),
    normal_angle_from_prior_up_degrees=float(np.degrees(np.arccos(np.clip(normal@up, -1, 1)))),
    sensitivity=dict(pixel_uniform_radius=3, samples=300,
        columns=['normal_deviation_deg', 'left_strip_length_m', 'right_strip_length_m'],
        percentiles=[5, 50, 95], values=np.percentile(samples, [5, 50, 95], axis=0).tolist()),
    navigation_accepted=False,
    caveat='Narrow threshold only. Outer casing toes may not identify the same surface as the inner toes. Knot excluded from plane fit. Same-video reserved pose is correlated; no independent capture, scale, full floor or navigation acceptance.')
# A second orientation diagnostic uses the observed jambs, not the noisy floor.
jambs = np.array(aperture['corners_world'])[2:]-np.array(aperture['corners_world'])[:2]
jambs /= np.linalg.norm(jambs, axis=1)[:, None]
jamb_up = jambs.mean(0)
jamb_up /= np.linalg.norm(jamb_up)
report['jamb_direction_disagreement_degrees'] = float(np.degrees(np.arccos(np.clip(jambs[0]@jambs[1], -1, 1))))
report['height_relative_to_inner_midpoint_along_jamb_up_m'] = ((points-points[:2].mean(0))@jamb_up*scale).tolist()
report['jamb_up_world'] = jamb_up.tolist()
report['caveat'] += ' Jamb-derived up assumes vertical casing; its disagreement is reported, not treated as surveyed gravity.'
local = (points-np.array(aperture['origin_world']))@np.array(aperture['basis_rows']).T*scale
im = Image.new('RGB', (1000, 640), '#172029')
draw = ImageDraw.Draw(im)
draw.text((25, 20), 'Observed threshold landmarks: provisional metres, not a room floor', fill='white')
for panel, axes, title in [(0, (0, 2), 'PLAN (prior aperture axes)'), (1, (0, 1), 'ELEVATION (prior aperture axes)')]:
    xy = local[:, axes]
    center2 = (xy.min(0)+xy.max(0))/2
    def px(p):
        return tuple((np.array([500., 180.+panel*290.])+(p-center2)*[360., -360.]).astype(int))
    draw.text((25, 55+panel*290), title, fill='white')
    # Connect only measured corner landmarks, not an inferred floor extent.
    draw.line([px(xy[i]) for i in [0, 1, 3, 2, 0]], fill='#6d8495', width=2)
    for label, p in zip(LABELS, xy):
        x, y = px(p)
        draw.ellipse((x-4, y-4, x+4, y+4), fill='lime')
        draw.text((x+8, y-17 if label == 'inner-left' else y+5), label, fill='white')
    y = 285+panel*290
    draw.line((25, y, 205, y), fill='white', width=2)
    draw.text((25, y+5), '0.5 provisional m (both axes)', fill='white')
draw.text((25, 610), 'Corner plane is unstable: 3 px pick sensitivity reaches 21 degrees. No collision surface accepted.', fill='#ffce88')
im.save(OUT/'threshold-plan.png')
assert hashes == {p.name: sha(p) for p in (SOURCE/'sparse/0').glob('*.bin')}
(OUT/'result.json').write_text(json.dumps(report, indent=2)+'\n')
print(json.dumps(report, indent=2))
