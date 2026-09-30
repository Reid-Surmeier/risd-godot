"""Throwaway #182: reserve casing pixels before triangulating local landmarks."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import sys

import numpy as np
import pycolmap
from PIL import Image, ImageDraw
from measurements import heldout_pose, project, triangulate

ROOT = Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
SOURCE = ROOT/'sfm-calibrated-doorway-v1'
parser = argparse.ArgumentParser()
parser.add_argument('--grand', action='store_true')
parser.add_argument('--grand-registered', action='store_true')
parser.add_argument('--grand-return', action='store_true')
parser.add_argument('--grand-header', action='store_true')
parser.add_argument('--grand-outer-header', action='store_true')
args = parser.parse_args()
OUT = ROOT/('corridor-grand-extents-v1' if args.grand else 'corridor-extents-v1')
# Upright 720x1280 source pixels. Query marks are frozen before any projection.
PICKS = {
    'IMG_6380/000238.jpg': [[250, 681], [560, 701]],
    'IMG_6380/000244.jpg': [[60, 925], [640, 896]],
    'IMG_6380/000239.jpg': [[48, 736], [390, 716]],
}
LABELS = ['decorative-black-outer-toe', 'decorative-purple-outer-toe']
if args.grand:
    PICKS = {
        'IMG_6380/000490.jpg': [[170, 757], [516, 765]],
        'IMG_6380/000495.jpg': [[40, 921], [594, 925]],
        'IMG_6380/000492.jpg': [[95, 800], [522, 805]],
    }
    LABELS = ['grand-purple-outer-toe', 'grand-black-outer-toe']
if args.grand_registered:
    assert not args.grand and not args.grand_return
    OUT = ROOT/'grand-casing-registered-v1'
    PICKS = {
        'IMG_6380/000203.jpg': [[421, 857]],
        'IMG_6380/000205.jpg': [[149, 964]],
        'IMG_6380/000204.jpg': [[310, 871]],
    }
    LABELS = ['grand-white-exterior-casing-toe']
if args.grand_return:
    assert not args.grand
    OUT = ROOT/'grand-casing-return-v1'
    PICKS = {
        'IMG_6380/000203.jpg': [[421, 857]],
        'IMG_6380/000211.jpg': [[548, 1035]],
        'IMG_6380/000210.jpg': [[197, 1039]],
    }
    LABELS = ['grand-white-exterior-casing-toe']
if args.grand_header:
    assert not (args.grand or args.grand_registered or args.grand_return)
    OUT = ROOT/'grand-casing-header-v1'
    PICKS = {
        'IMG_6380/000202.jpg': [[533, 406]],
        'IMG_6380/000205.jpg': [[122, 105]],
        'IMG_6380/000203.jpg': [[445, 243]],
    }
    LABELS = ['grand-white-inner-header-left']
if args.grand_outer_header:
    assert not (args.grand or args.grand_registered or args.grand_return or args.grand_header)
    OUT = ROOT/'grand-casing-outer-header-v1'
    PICKS = {
        'IMG_6380/000202.jpg': [[503, 375]],
        'IMG_6380/000204.jpg': [[278, 100]],
        'IMG_6380/000203.jpg': [[420, 204]],
    }
    LABELS = ['grand-white-outer-mitre-left']
TRAIN = list(PICKS)[:2]
QUERY = list(PICKS)[2]


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


OUT.mkdir(exist_ok=True)
annotations = json.dumps(dict(picks=PICKS, training=TRAIN, reserved=QUERY, labels=LABELS), indent=2)+'\n'
if (OUT/'annotations.json').exists():
    assert (OUT/'annotations.json').read_text() == annotations, 'Use a new trial for changed picks'
else:
    (OUT/'annotations.json').write_text(annotations)
model = pycolmap.Reconstruction(SOURCE/'sparse/0')
views = {v.name: v for v in model.images.values()}
cameras = {n: model.cameras[views[n].camera_id] for n in PICKS if n in views}
poses = {n: views[n].cam_from_world() for n in PICKS if n in views}
inputs = {str(p): sha(p) for p in (SOURCE/'sparse/0').glob('*.bin')}
inputs.update({str(SOURCE/'images'/n): sha(SOURCE/'images'/n) for n in PICKS})
audit = json.loads((ROOT/'heldout-calibrated-v1/audit.json').read_text())
assert all(sha(SOURCE/p) == digest for p, digest in audit['source_sha256'].items())
pose_inliers = {}
missing = [n for n in PICKS if n not in views]
if missing:
    database = OUT/'database.db'
    if not (OUT/'matches-complete.json').exists():
        assert not database.exists(), 'Inspect interrupted matching before any retry'
        shutil.copyfile(SOURCE/'database.db', database)
        for name in missing:
            target = OUT/'images'/name
            target.parent.mkdir(parents=True, exist_ok=True)
            target.symlink_to(SOURCE/'images'/name)
        extraction = pycolmap.FeatureExtractionOptions()
        extraction.gpu_index = '0'
        extraction.num_threads = 8
        pycolmap.extract_features(database, OUT/'images', camera_mode=pycolmap.CameraMode.PER_FOLDER,
                                  extraction_options=extraction, device=pycolmap.Device.cuda)
        pairs = OUT/'pairs.txt'
        pairs.write_text(''.join(f'{query} {ref}\n' for query in missing for ref in views))
        matching = pycolmap.FeatureMatchingOptions()
        matching.gpu_index = '0'
        matching.num_threads = 8
        pycolmap.match_image_pairs(database, matching_options=matching,
            pairing_options=pycolmap.ImportedPairingOptions(match_list_path=pairs), device=pycolmap.Device.cuda)
        (OUT/'matches-complete.json').write_text(json.dumps(dict(queries=missing, references=len(views))))
    failed = []
    for name in missing:
        try:
            cameras[name], poses[name], pose_inliers[name] = heldout_pose(model, database, name, PICKS[name])
        except AssertionError:
            failed.append(name)
    if failed:
        report = dict(failed_images=failed, localized_pose_inliers=pose_inliers,
            requirement='At least 20 odd-point pose inliers, excluding 20px around landmarks.',
            diagnostic_pass=False, navigation_accepted=False, source_sha256=inputs,
            decision='Do not triangulate or extend collision from unsupported poses; preserve cached matching.')
        (OUT/'pose-failure.json').write_text(json.dumps(report, indent=2)+'\n')
        print(json.dumps(report, indent=2))
        sys.exit(1)
points, angles = zip(*(triangulate(cameras, poses, {n: PICKS[n][k] for n in TRAIN}) for k in range(len(LABELS))))
points = np.array(points)
assert np.isfinite(points).all()
assert all(np.all((poses[n]*points)[:, 2] > 0) for n in PICKS)
errors = {n: np.linalg.norm(project(cameras[n], poses[n], points)-PICKS[n], axis=1).tolist() for n in PICKS}
for point in points:
    recovered, _ = triangulate(cameras, poses, {n: project(cameras[n], poses[n], point[None])[0] for n in TRAIN})
    assert np.linalg.norm(recovered-point) < 1e-6
assert np.min(np.linalg.norm(project(cameras[QUERY], poses[QUERY], points)-(np.array(PICKS[QUERY])+[50, 0]), axis=1)) > 8
aperture = json.loads((ROOT/'doorway-aperture-v1/result.json').read_text())
near = json.loads((ROOT/'corridor-floor-v2/result.json').read_text())
for name in ['doorway-aperture-v1/result.json', 'corridor-floor-v2/result.json']:
    inputs[str(ROOT/name)] = sha(ROOT/name)
scale = aperture['provisional_m_per_unit']
basis = np.array(aperture['basis_rows'])
local = (points-aperture['origin_world'])@basis.T*scale
distances = (points-near['center_world'])@np.array(near['normal_world'])*scale
rng = np.random.default_rng(182)
samples = np.array([[triangulate(cameras, poses, {n: np.array(PICKS[n][k])+rng.uniform(-3, 3, 2) for n in TRAIN})[0] for k in range(len(LABELS))] for _ in range(300)])
for name in PICKS:
    im = Image.open(SOURCE/'images'/name).transpose(Image.Transpose.ROTATE_270).convert('RGB')
    draw = ImageDraw.Draw(im)
    for label, pick, prediction in zip(LABELS, PICKS[name], project(cameras[name], poses[name], points)):
        x, y = pick
        draw.ellipse((x-7, y-7, x+7, y+7), outline='lime', width=2)
        draw.text((max(2, min(x+9, 450)), y+12), label, fill='lime')
        x, y = prediction
        draw.line((x-8, y, x+8, y), fill='red', width=2)
        draw.line((x, y-8, x, y+8), fill='red', width=2)
    draw.rectangle((0, 0, 720, 42), fill='black')
    draw.text((8, 5), name+(' RESERVED PIXELS' if name == QUERY else 'FIT'), fill='white')
    draw.text((8, 23), 'Green observations / red predictions. Correlated poses; provisional scale.', fill='white')
    im.save(OUT/(Path(name).stem+'.png'))
report = dict(labels=LABELS, annotations=PICKS, training=TRAIN, reserved=QUERY,
    localized_pose_inliers=pose_inliers,
    points_world=points.tolist(), points_local_m=local.tolist(), ray_angles_degrees=list(angles),
    errors_px=errors, source_sha256=inputs, provisional_m_per_unit=scale,
    distance_to_frozen_corridor_plane_m=distances.tolist(),
    pick_sensitivity_p95_displacement_m=np.percentile(np.linalg.norm(samples-points, axis=2)*scale, 95, axis=0).tolist(),
    diagnostic_pass=bool(max(errors[QUERY]) <= 8 and min(angles) >= 1), navigation_accepted=False,
    caveat='Visible casing toes at one corridor connection, not a complete room shell. '
           'Manual query pixels withheld from triangulation; query pose already in SfM and same video. '
           'No gravity/scale acceptance. Plane distances are extrapolation diagnostics, not evidence of steps. '
           'Pick sensitivity omits pose and scale errors; do not tune evaluated pixels.')
if args.grand_registered or args.grand_return:
    report['caveat'] += (' Grand casing trial measures one exterior white toe only; reverse frame 484 '
        'shows the opposite casing face and is excluded rather than asserted to match. '
        'One toe cannot define an aperture, floor polygon or collision extension. '
        'This is the corridor casing at the Grand Gallery end, not the adjacent blue-room doorway.')
if args.grand_header or args.grand_outer_header:
    report['caveat'] = (('Outer mitre' if args.grand_outer_header else 'Inner header') +
        ' corner only; no opposite jamb or full aperture. '
        'Query pixels withheld from triangulation, but camera poses are correlated in the same video. '
        'Plane distance is a header diagnostic, not a floor measurement. '
        'Pick sensitivity omits pose/scale error. Do not tune evaluated pixels or extend collision.')
assert all(sha(Path(p)) == digest for p, digest in inputs.items())
(OUT/'result.json').write_text(json.dumps(report, indent=2)+'\n')
print(json.dumps(report, indent=2))
