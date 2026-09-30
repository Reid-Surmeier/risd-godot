"""Recheck frozen manual pixels against #182's fresh, exclusion-corrected model."""
import argparse
import hashlib
import json
from pathlib import Path

import numpy as np
import pycolmap
from PIL import Image, ImageDraw
from measurements import heldout_pose, project, triangulate

ROOT = Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
SOURCE = ROOT/'sfm-strict-doorway-v1'
parser = argparse.ArgumentParser()
parser.add_argument('--aperture-toes', action='store_true')
args = parser.parse_args()
OUT = ROOT/('strict-aperture-toes-v1' if args.aperture_toes else 'strict-landmarks-v1')
OUT.mkdir(exist_ok=False)
model = pycolmap.Reconstruction(SOURCE/'sparse/0')
views = {v.name: v for v in model.images.values() if v.has_pose}
pins = {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in (SOURCE/'sparse/0').glob('*.bin')}
reports = []
trials = ['doorway-aperture-v1'] if args.aperture_toes else ['doorway-aperture-v1', 'corridor-extents-v1', 'grand-casing-registered-v1', 'grand-casing-plinth-v1']
for trial in trials:
    path = ROOT/trial/'result.json'
    old = json.loads(path.read_text())
    picks = old['annotations']
    training = [n for n in old['training'] if n in views]
    query = old.get('heldout', old.get('reserved'))
    if args.aperture_toes:
        # New visible bottom reveal junctions, picked before any projection.
        # Upper-right reveal is cropped in these views: do not invent it.
        picks = {
            'IMG_6380_exit6fps/000013.jpg': old['annotations']['IMG_6380_exit6fps/000013.jpg'][:2],
            'IMG_6380_exit6fps/000019.jpg': [[150, 851], [598, 859]],
            'IMG_6380_exit6fps/000021.jpg': [[106, 899], [608, 924]],
        }
        training, query = list(picks)[:2], list(picks)[2]
        (OUT/'annotations.json').write_text(json.dumps(dict(picks=picks, training=training, reserved=query,
            scope='Bottom reveal toes only; all cameras registered; query manual pixels withheld.'), indent=2)+'\n')
    cameras = {n: model.cameras[views[n].camera_id] for n in training}
    poses = {n: views[n].cam_from_world() for n in training}
    if query in views:
        cameras[query], poses[query] = model.cameras[views[query].camera_id], views[query].cam_from_world()
    else:
        cameras[query], poses[query], _ = heldout_pose(model, ROOT/trial/'database.db', query, picks[query])
    assert len(training) >= 2
    points, angles = zip(*(triangulate(cameras, poses, {n: picks[n][k] for n in training})
        for k in range(len(picks[query]))))
    points = np.array(points)
    assert np.isfinite(points).all() and all(np.all((p*points)[:, 2] > 0) for p in poses.values())
    errors = {n: np.linalg.norm(project(cameras[n], poses[n], points)-picks[n], axis=1).tolist()
        for n in poses}
    for point in points:
        recovered, _ = triangulate(cameras, poses, {n: project(cameras[n], poses[n], point[None])[0] for n in training})
        assert np.linalg.norm(recovered-point) < 1e-6
    # Negative control rejects a deliberate 50px error under the unchanged gate.
    assert np.min(np.linalg.norm(project(cameras[query], poses[query], points)-(np.array(picks[query])+[50, 0]), axis=1)) > 8
    row = dict(trial=trial, annotations=picks, training=training, reserved=query,
        omitted_training=[n for n in old['training'] if n not in views],
        points_world=points.tolist(), ray_angles_degrees=list(angles), errors_px=errors,
        diagnostic_pass=bool(max(errors[query]) <= 8 and min(angles) >= 1), threshold_px=8,
        old_query_errors_px=(old.get('errors_px') or old['reprojection_errors_px']).get(query),
        input_sha256=hashlib.sha256(path.read_bytes()).hexdigest())
    reports.append(row)
    for name in [training[0], query]:
        path = ROOT/('sfm-doorway-v1/images' if 'exit6fps' in name else 'survey-2fps')/name
        im = Image.open(path).transpose(Image.Transpose.ROTATE_270).convert('RGB')
        draw = ImageDraw.Draw(im)
        for pixel, predicted in zip(picks[name], project(cameras[name], poses[name], points)):
            x, y = pixel
            draw.ellipse((x-7, y-7, x+7, y+7), outline='lime', width=2)
            x, y = predicted
            draw.line((x-8, y, x+8, y), fill='red', width=2)
            draw.line((x, y-8, x, y+8), fill='red', width=2)
        draw.rectangle((0, 0, 720, 54), fill='black')
        draw.text((8, 5), trial+(' RESERVED PIXELS' if name == query else ' FIT'), fill='white')
        draw.text((8, 22), 'Fresh model; original manual pixels unchanged. Scale not accepted.', fill='white')
        draw.text((8, 38), name, fill='white')
        im.save(OUT/(trial+('-reserved' if name == query else '-fit')+'.png'))
assert pins == {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in (SOURCE/'sparse/0').glob('*.bin')}
report = dict(source_sha256=pins, trials=reports, navigation_accepted=False, cost_usd=0,
    caveat='Old picks frozen; camera poses/points rebuilt without exit6fps 18/48. '
        'Reserved manual pixels excluded from triangulation, not independent captures. '
        'Threshold/floor anchors previously fitted with excluded frame 18 must be remeasured. '
        'No inherited world-coordinate floor/collision transplant or independent scale acceptance.')
(OUT/'result.json').write_text(json.dumps(report, indent=2)+'\n')
print(json.dumps([dict(trial=r['trial'], query_errors=r['errors_px'][r['reserved']],
    angles=r['ray_angles_degrees'], diagnostic_pass=r['diagnostic_pass'], omitted=r['omitted_training']) for r in reports], indent=2))
