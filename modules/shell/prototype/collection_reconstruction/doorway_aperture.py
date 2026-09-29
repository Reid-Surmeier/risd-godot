"""Throwaway aperture measurement: frozen picks, fresh query, unchanged sparse model."""
import hashlib
import json
from pathlib import Path
import shutil

import numpy as np
import pycolmap
from PIL import Image, ImageDraw
from measurements import project, triangulate, heldout_pose

ROOT = Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
SOURCE = ROOT/'sfm-calibrated-doorway-v1'
OUT = ROOT/'doorway-aperture-v1'
# Source pixels, upright 720x1280. Bottom picks retain v1 unchanged; upper
# picks refer to the inner bevel/reveal junction, not the outer casing.
# These are frozen BEFORE fitting or looking at query projections.
PICKS = {
    'IMG_6380/000505.jpg': [[110, 778], [469, 760], [62, 199], [514, 237]],
    'IMG_6380_exit6fps/000013.jpg': [[84, 770], [431, 746], [24, 195], [470, 244]],
    'IMG_6380_exit6fps/000018.jpg': [[166, 827], [586, 832], [102, 156], [680, 161]],
    'IMG_6380_exit6fps/000015.jpg': [[134, 791], [504, 783], [85, 202], [557, 224]],
}
TRAIN = list(PICKS)[:3]
QUERY = list(PICKS)[3]
THRESHOLD = 8.  # Same exploratory diagnostic as v1; not final #181 criteria.
OUT.mkdir(exist_ok=True)
frozen = OUT/'annotations.json'
serialized = json.dumps(PICKS, indent=2)+'\n'
if frozen.exists():
    assert frozen.read_text() == serialized, 'Preserve evaluated annotations; use a new named trial'
else:
    frozen.write_text(serialized)


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def photo(name):
    return ROOT/('sfm-doorway-v1/images' if 'exit6fps' in name else 'survey-2fps')/name


model = pycolmap.Reconstruction(SOURCE/'sparse/0')
refs = {i.name: i for i in model.images.values()}
assert QUERY not in refs
assert sha(photo(QUERY)) not in {sha(photo(n)) for n in refs}
assert sha(photo(QUERY)) != sha(photo('IMG_6380/000506.jpg'))
hashes = {str(p.relative_to(SOURCE)): sha(p) for p in (SOURCE/'sparse/0').glob('*.bin')}
database = OUT/'database.db'
if not (OUT/'matches-complete.json').exists():
    assert not database.exists(), 'Inspect interrupted matching; never overwrite an existing trial'
    shutil.copyfile(SOURCE/'database.db', database)
    images = OUT/'images'
    (images/Path(QUERY).parent).mkdir(parents=True, exist_ok=True)
    (images/QUERY).symlink_to(photo(QUERY))
    options = pycolmap.FeatureExtractionOptions()
    options.gpu_index = '0'
    options.num_threads = 8
    pycolmap.extract_features(database, images, camera_mode=pycolmap.CameraMode.PER_FOLDER,
                              extraction_options=options, device=pycolmap.Device.cuda)
    pairs = OUT/'pairs.txt'
    pairs.write_text(''.join(f'{QUERY} {n}\n' for n in refs))
    matching = pycolmap.FeatureMatchingOptions()
    matching.gpu_index = '0'
    matching.num_threads = 8
    pycolmap.match_image_pairs(database, matching_options=matching,
                              pairing_options=pycolmap.ImportedPairingOptions(match_list_path=pairs),
                              device=pycolmap.Device.cuda)
    (OUT/'matches-complete.json').write_text(json.dumps(dict(query=QUERY, references=len(refs))))

cameras = {n: model.cameras[refs[n].camera_id] for n in TRAIN}
poses = {n: refs[n].cam_from_world() for n in TRAIN}
cameras[QUERY], poses[QUERY], inliers = heldout_pose(model, database, QUERY, PICKS[QUERY])
points, angles = zip(*(triangulate(cameras, poses, {n: PICKS[n][k] for n in TRAIN}) for k in range(4)))
points = np.array(points)
assert np.isfinite(points).all()
assert all(np.all((poses[n]*points)[:, 2] > 0) for n in PICKS)
for point in points:
    recovered, _ = triangulate(cameras, poses, {n: project(cameras[n], poses[n], point[None])[0] for n in TRAIN})
    assert np.linalg.norm(recovered-point) < 1e-6
errors = {n: np.linalg.norm(project(cameras[n], poses[n], points)-PICKS[n], axis=1).tolist() for n in PICKS}
assert np.max(np.linalg.norm(project(cameras[QUERY], poses[QUERY], points)-(np.array(PICKS[QUERY])+[50, 0]), axis=1)) > THRESHOLD
old = json.loads((ROOT/'doorway-triangulation-v1/result.json').read_text())
assert np.allclose(points[:2], old['corners_world'])
assert hashes == old['source_sha256']
scale = old['provisional_m_per_unit']
floor = json.loads((ROOT/'doorway-geometry-v1/geometry.json').read_text())
up = np.array(floor['basis_rows'])[1]
heights = ((points[2:]-points[:2])@up)*scale
widths = [np.linalg.norm(points[1]-points[0])*scale, np.linalg.norm(points[3]-points[2])*scale]
right = points[1]-points[0]
right -= up*np.dot(right, up)
right /= np.linalg.norm(right)
basis = np.array([right, up, np.cross(right, up)])
origin = points[:2].mean(0)
local = (points-origin)@basis.T*scale
for n in PICKS:
    picture = Image.open(photo(n)).transpose(Image.Transpose.ROTATE_270).convert('RGB')
    draw = ImageDraw.Draw(picture)
    for label, observed, predicted in zip(['BL', 'BR', 'TL', 'TR'], PICKS[n], project(cameras[n], poses[n], points)):
        x, y = observed
        draw.ellipse((x-7, y-7, x+7, y+7), outline='lime', width=2)
        draw.text((x+9, y), label, fill='lime')
        x, y = predicted
        draw.line((x-9, y, x+9, y), fill='red', width=2)
        draw.line((x, y-9, x, y+9), fill='red', width=2)
    draw.rectangle((0, 0, 720, 38), fill='black')
    draw.text((8, 4), n+(' HELD OUT' if n == QUERY else 'FIT'), fill='white')
    draw.text((8, 20), 'Green: reserved manual picks; red: prediction. Provisional geometry.', fill='white')
    picture.save(OUT/(n.replace('/', '-')+'.png'))
report = dict(annotations=PICKS, training=TRAIN, heldout=QUERY, heldout_pose_fit_inliers=inliers,
              source_sha256=hashes, source_image_sha256={n: sha(photo(n)) for n in PICKS},
              corners_world=points.tolist(), maximum_ray_angle_degrees=list(angles),
              reprojection_errors_px=errors, widths_provisional_m=widths,
              heights_provisional_m=heights.tolist(), opening_local_m=local.tolist(),
              basis_rows=basis.tolist(), origin_world=origin.tolist(), provisional_m_per_unit=scale,
              threshold_px=THRESHOLD, diagnostic_pass=bool(max(errors[QUERY]) <= THRESHOLD and min(angles) >= 1),
              navigation_accepted=False,
              caveat='One new same-video query, temporally correlated, not independent capture or metric calibration. Old failed query remains failed. No room shell/collision acceptance.')
assert hashes == {str(p.relative_to(SOURCE)): sha(p) for p in (SOURCE/'sparse/0').glob('*.bin')}
(OUT/'result.json').write_text(json.dumps(report, indent=2)+'\n')
print(json.dumps(report, indent=2))
