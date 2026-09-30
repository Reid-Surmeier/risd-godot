"""#182: all native-resolution floor matches; withheld wall cameras stay frozen."""
import argparse
import hashlib
import json
from pathlib import Path

import numpy as np
import pycolmap
from PIL import Image, ImageDraw
from measurements import project, raw, triangulate, upright

parser = argparse.ArgumentParser()
parser.add_argument('selection', type=Path)
parser.add_argument('output', type=Path)
args = parser.parse_args()
root = Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
out = args.output
out.mkdir(exist_ok=False)
selection = json.loads(args.selection.read_text())
training, reserved = selection['training'], selection['reserved']
assert len(training) == 2 and not set(training) & set(reserved)
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
model_path = root/'sfm-strict-doorway-v1/sparse/0'
model = pycolmap.Reconstruction(model_path)
views = {v.name: v for v in model.images.values() if v.has_pose}
registered_queries = [n for n in reserved if n in views]
assert not registered_queries or selection.get('allow_registered_reserved') is True, 'Registered cameras require explicit correlated-diagnostic scope'
inputs = {str(p): sha(p) for p in [args.selection, *model_path.glob('*.bin')]}
if len(registered_queries) < len(reserved):
    pose_path = root/selection['pose_source']
    pose_report = json.loads(pose_path.read_text())
    assert pose_report['all_floor_query_features_excluded_from_pose']
    assert pose_report['pose_fit_upright_y_below'] == 450
    inputs[str(pose_path)] = sha(pose_path)
    for p, h in pose_report['inputs_sha256'].items():
        assert sha(Path(p)) == h
cameras = {n: model.cameras[views[n].camera_id] for n in training}
poses = {n: views[n].cam_from_world() for n in training}
for name in reserved:
    if name in views:
        cameras[name] = model.cameras[views[name].camera_id]
        poses[name] = views[name].cam_from_world()
        continue
    row = next(r for r in pose_report['rows'] if r['image'] == name)
    assert row['pose_supported']
    cameras[name] = pycolmap.Camera(row['camera'])
    matrix = np.array(row['cam_from_world'])
    poses[name] = pycolmap.Rigid3d(pycolmap.Rotation3d(matrix[:, :3]), matrix[:, 3])
    assert np.max(abs(poses[name].matrix()-matrix)) < 1e-8
images = out/'images'
photos, masks = {}, {}
for name, source in selection['images'].items():
    path = root/source
    inputs[str(path)] = sha(path)
    target = images/name
    target.parent.mkdir(parents=True, exist_ok=True)
    target.symlink_to(path)
    photo = Image.open(path)
    assert photo.size == (1920, 1080)
    photos[name] = photo.transpose(Image.Transpose.ROTATE_270).convert('RGB')
for name in training:
    mask = Image.new('1', (720, 1280))
    ImageDraw.Draw(mask).polygon([tuple(p) for p in selection['floor_polygons_upright'][name]], fill=1)
    masks[name] = np.array(mask)
database = out/'database.db'
extraction = pycolmap.FeatureExtractionOptions()
extraction.gpu_index = '0'
extraction.num_threads = 8
pycolmap.extract_features(database, images, camera_mode=pycolmap.CameraMode.PER_FOLDER,
    extraction_options=extraction, device=pycolmap.Device.cuda)
pairs = [(training[0], training[1])]+[(q, r) for q in reserved for r in training]
pair_path = out/'pairs.txt'
pair_path.write_text(''.join(f'{a} {b}\n' for a, b in pairs))
matching = pycolmap.FeatureMatchingOptions()
matching.gpu_index = '0'
matching.num_threads = 8
pycolmap.match_image_pairs(database, matching_options=matching,
    pairing_options=pycolmap.ImportedPairingOptions(match_list_path=pair_path), device=pycolmap.Device.cuda)
with pycolmap.Database.open(database) as db:
    records = {i.name: i for i in db.read_all_images()}
    pixels = {n: db.read_keypoints(records[n].image_id)[:, :2].astype(float)/1.5 for n in records}
    a, b = training
    candidates = []
    for ia, ib in db.read_matches(records[a].image_id, records[b].image_id):
        picks = {a: upright(pixels[a][ia]), b: upright(pixels[b][ib])}
        in_floor = all(0 <= p[0] < 720 and 0 <= p[1] < 1280 and
            masks[n][int(round(min(p[1], 1279))) , int(round(min(p[0], 719)))] for n, p in picks.items())
        if not in_floor:
            continue
        point, angle = triangulate(cameras, poses, picks)
        errors = {n: float(np.linalg.norm(project(cameras[n], poses[n], point[None])[0]-p)) for n, p in picks.items()}
        candidates.append(dict(source_features=[int(ia), int(ib)], source_pixels={n: p.tolist() for n, p in picks.items()},
            point_world=point.tolist(), ray_angle_degrees=angle, training_errors_px=errors,
            positive_depth=all((poses[n]*point)[2] > 0 for n in training)))
    # Freeze every source candidate before reading reserved matches. No residual selection.
    (out/'source-candidates.json').write_text(json.dumps(candidates, indent=2)+'\n')
    for q in reserved:
        links = {n: {} for n in training}
        for n in training:
            for iq, ir in db.read_matches(records[q].image_id, records[n].image_id):
                links[n].setdefault(int(ir), []).append(int(iq))
        for index, item in enumerate(candidates):
            ids = sorted(set(iq for n, ir in zip(training, item['source_features']) for iq in links[n].get(ir, [])))
            predicted = project(cameras[q], poses[q], np.array(item['point_world'])[None])[0]
            observations = []
            for iq in ids:
                observed = upright(pixels[q][iq])
                observations.append(dict(query_feature=iq, pixel=observed.tolist(),
                    error_px=float(np.linalg.norm(predicted-observed))))
            item.setdefault('reserved', {})[q] = dict(predicted_pixel=predicted.tolist(), observations=observations)
            draw = ImageDraw.Draw(photos[q])
            x, y = predicted*1.5
            draw.line((x-8, y, x+8, y), fill='red', width=2)
            draw.line((x, y-8, x, y+8), fill='red', width=2)
            for obs in observations:
                x, y = np.array(obs['pixel'])*1.5
                draw.ellipse((x-6, y-6, x+6, y+6), outline='lime', width=2)
                draw.text((x+8, y+8), str(index), fill='lime')
for index, item in enumerate(candidates):
    for n, p in item['source_pixels'].items():
        x, y = np.array(p)*1.5
        draw = ImageDraw.Draw(photos[n])
        draw.ellipse((x-6, y-6, x+6, y+6), outline='lime', width=2)
        draw.text((x+8, y+8), str(index), fill='lime')
for n, photo in photos.items():
    draw = ImageDraw.Draw(photo)
    draw.rectangle((0, 0, 1080, 45), fill='black')
    draw.text((8, 5), n+'; ALL native floor candidates; identities UNVERIFIED', fill='white')
    pose_note = 'Globally fitted query cameras' if registered_queries else 'Reserved wall-only poses'
    draw.text((8, 24), pose_note+'; no plane/scale/collision acceptance', fill='white')
    photo.save(out/(Path(n).stem+'-native-matches.png'))
assert all(sha(Path(p)) == h for p, h in inputs.items())
for n in training+reserved:
    point = poses[n].inverse()*np.array([.1, .2, 3.])
    expected = cameras[n].img_from_cam(poses[n]*point)
    assert np.linalg.norm(raw(project(cameras[n], poses[n], point[None])[0])-expected) < 1e-8
report = dict(selection=selection, candidates=candidates, inputs_sha256=inputs,
    source_sha256={p.name: sha(p) for p in model_path.glob('*.bin')},
    floor_pixels_used_for_query_pose=bool(registered_queries), registered_query_cameras=registered_queries,
    navigation_accepted=False, cost_usd=0,
    caveat='All source floor matches retained; repeated wood may produce false identities. '
        'Native coordinates scaled 1.5 to frozen 1280x720 cameras. Registered query cameras, if listed, '
        'were globally fitted with cached tracks and are not held-out poses. Same-video/calibration correlation; '
        'no plane fit, physical scale or collision acceptance. CUDA extraction/matching; CPU ray algebra.')
(out/'result.json').write_text(json.dumps(report, indent=2)+'\n')
print(json.dumps(dict(source_candidates=len(candidates), reserved_observations={q:
    sum(len(c['reserved'][q]['observations']) for c in candidates) for q in reserved}), indent=2))
