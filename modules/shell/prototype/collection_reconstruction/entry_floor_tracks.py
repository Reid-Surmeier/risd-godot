"""#182: inspect every cached wood-floor match using the frozen wall-only pose."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil

import numpy as np
import pycolmap
from PIL import Image, ImageDraw
from measurements import project, upright

parser = argparse.ArgumentParser()
parser.add_argument('selection', type=Path)
parser.add_argument('output', type=Path)
args = parser.parse_args()
root = Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
out = args.output
out.mkdir(exist_ok=True)
assert not (out/'entry-floor-result.json').exists(), 'Preserve completed diagnostics'
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
selection = json.loads(args.selection.read_text())
pose_path = root/selection['pose_source']
pose_report = json.loads(pose_path.read_text())
query = selection['query']
row = next(r for r in pose_report['rows'] if r['image'] == query)
assert row['pose_supported'] and pose_report['all_floor_query_features_excluded_from_pose']
assert pose_report['pose_fit_upright_y_below'] == 540
camera = pycolmap.Camera(row['camera'])
assert (camera.width, camera.height) == (1280, 720)
matrix = np.array(row['cam_from_world'])
pose = pycolmap.Rigid3d(pycolmap.Rotation3d(matrix[:, :3]), matrix[:, 3])
assert np.max(abs(pose.matrix()-matrix)) < 1e-8
model_path = root/'sfm-strict-doorway-v1/sparse/0'
model = pycolmap.Reconstruction(model_path)
views = {v.name: v for v in model.images.values() if v.has_pose}
assert query not in views
database = root/'heldout-calibrated-v1/database.db'
inputs = {str(p): sha(p) for p in [args.selection, pose_path, database, *model_path.glob('*.bin')]}
for p, h in pose_report['inputs_sha256'].items():
    assert sha(Path(p)) == h, 'Saved pose source changed'
masks, photos = {}, {}
for name, polygon in selection['floor_polygons_upright'].items():
    mask = Image.new('1', (720, 1280))
    ImageDraw.Draw(mask).polygon([tuple(p) for p in polygon], fill=1)
    masks[name] = np.array(mask)
    photo = root/'survey-2fps'/name
    inputs[str(photo)] = sha(photo)
    photos[name] = Image.open(photo).transpose(Image.Transpose.ROTATE_270).convert('RGB')
    ImageDraw.Draw(photos[name]).polygon([tuple(p) for p in polygon], outline='cyan', width=2)


def in_wood(name, pixels):
    xy = np.rint(pixels).astype(int)
    valid = (xy[:, 0] >= 0) & (xy[:, 0] < 720) & (xy[:, 1] >= 0) & (xy[:, 1] < 1280)
    result = np.zeros(len(xy), dtype=bool)
    result[valid] = masks[name][xy[valid, 1], xy[valid, 0]]
    return result


assert not in_wood(query, np.array([[-1., 700.], [720., 700.], [100., -1.]])).any()
assert in_wood(query, np.array([[300., 750.]])).all()
scratch = out/'entry-floor-database.db'
assert not scratch.exists()
shutil.copyfile(database, scratch)
results = []
with pycolmap.Database.open(scratch) as db:
    records = {v.name: v for v in db.read_all_images()}
    q = records[query]
    keypoints = db.read_keypoints(q.image_id)[:, :2]
    for name in selection['references']:
        ref = views[name]
        matches = db.read_matches(q.image_id, ref.image_id)
        qxy = upright(keypoints[matches[:, 0]])
        rxy = upright(np.array([ref.points2D[int(b)].xy for _, b in matches]))
        wood = in_wood(query, qxy) & in_wood(name, rxy)
        floor_rows = []
        for index in np.flatnonzero(wood):
            a, b = (int(i) for i in matches[index])
            point = ref.points2D[b]
            observed = qxy[index]
            assert observed[1] >= 540, 'Floor observation entered upper-image pose fit'
            item = dict(query_feature=a, reference_feature=b, query_pixel=observed.tolist(),
                reference_pixel=rxy[index].tolist(), point_id=None, error_px=None)
            if point.has_point3D():
                point_id = int(point.point3D_id)
                xyz = model.points3D[point_id].xyz
                predicted = project(camera, pose, xyz[None])[0]
                item.update(point_id=point_id, predicted_pixel=predicted.tolist(),
                    positive_depth=bool((pose*xyz)[2] > 0),
                    error_px=float(np.linalg.norm(predicted-observed)))
                raw_prediction = camera.img_from_cam(pose*xyz)
                assert np.linalg.norm(camera.img_from_cam(np.r_[camera.cam_from_img(raw_prediction), 1.])
                    - raw_prediction) < 1e-6
                ImageDraw.Draw(photos[query]).line((*observed, *predicted), fill='red', width=2)
            floor_rows.append(item)
            for image, pixel in [(photos[query], observed), (photos[name], rxy[index])]:
                x, y = pixel
                draw = ImageDraw.Draw(image)
                draw.ellipse((x-5, y-5, x+5, y+5), outline='lime', width=2)
                draw.text((x+6, y+6), str(a), fill='lime')
        errors = [r['error_px'] for r in floor_rows if r['error_px'] is not None]
        results.append(dict(reference=name, cached_matches=len(matches), wood_matches=floor_rows,
            tracked_floor_matches=len(errors), errors_px=errors))
scratch.unlink()
for name, photo in photos.items():
    draw = ImageDraw.Draw(photo)
    draw.rectangle((0, 0, 720, 40), fill='black')
    draw.text((8, 5), name+'; cached floor matches, identities UNVERIFIED', fill='white')
    draw.text((8, 23), 'Saved wall-only pose; all errors retained; no floor acceptance', fill='white')
    photo.save(out/(Path(name).stem+'-entry-floor-matches.png'))
assert all(sha(Path(p)) == h for p, h in inputs.items())
report = dict(selection=selection, rows=results, inputs_sha256=inputs,
    pose_fit_upright_y_below=540, navigation_accepted=False, cost_usd=0,
    caveat='Tentative cached feature matches can confuse repeated floorboards. '
        'All masked matches retained, no residual selection or plane refit. '
        'Wall-only pose excludes these floor pixels; same-video cameras remain correlated. '
        'This diagnoses floor coverage, not metric scale, identity, extent or collision.')
(out/'entry-floor-result.json').write_text(json.dumps(report, indent=2)+'\n')
print(json.dumps({r['reference']: dict(cached=r['cached_matches'],
    wood=len(r['wood_matches']), tracked=r['tracked_floor_matches'], errors=r['errors_px'])
    for r in results}, indent=2))
