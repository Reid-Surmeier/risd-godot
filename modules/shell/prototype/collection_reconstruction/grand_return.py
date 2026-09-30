"""#182: localize three fresh return samples without changing the frozen model."""
import collections
import hashlib
import json
from pathlib import Path
import shutil

import numpy as np
import pycolmap
from PIL import Image, ImageDraw
from measurements import heldout_pose

ROOT = Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
SOURCE = ROOT/'sfm-calibrated-doorway-v1'
FRAMES = ROOT/'grand-casing-revisit-v1'
OUT = ROOT/'grand-return-fresh-calibrated-v3'
# Upright source pixels, frozen before fitting. Frame 28 has no visible Grand toe.
PICKS = {24: [312, 1021], 26: [548, 1036], 28: [0, 0]}
OUT.mkdir(exist_ok=True)


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


annotations = dict(picks=PICKS, reserved=26, training=[203, 24],
    excluded_from_triangulation=[28], caveat='Blurred toe picks; frame 28 turns toward adjacent blue room.')
text = json.dumps(annotations, indent=2)+'\n'
if (OUT/'annotations.json').exists():
    assert (OUT/'annotations.json').read_text() == text, 'Changed picks need a new trial.'
else:
    (OUT/'annotations.json').write_text(text)
audit = json.loads((ROOT/'heldout-calibrated-v1/audit.json').read_text())
assert all(sha(SOURCE/p) == h for p, h in audit['source_sha256'].items())
model = pycolmap.Reconstruction(SOURCE/'sparse/0')
views = list(model.images.values())
camera = model.cameras[next(v.camera_id for v in views if v.name == 'IMG_6380/000203.jpg')]
queries = {f'IMG_6380/grandreturn-{f:06}.jpg': f for f in PICKS}
assert not set(queries) & {v.name for v in views}
provenance = json.loads((FRAMES/'provenance.json').read_text())
for f in PICKS:
    assert sha(FRAMES/f'{f:06}.jpg') == provenance['frames_sha256'][f'{f:06}.jpg']
database = OUT/'database.db'
if not (OUT/'matches-complete.json').exists():
    assert not database.exists(), 'Inspect interrupted matching; never retry blindly.'
    shutil.copyfile(SOURCE/'database.db', database)
    with pycolmap.Database.open(database) as db:
        db.update_camera(camera)
    for name, f in queries.items():
        target = OUT/'images'/name
        target.parent.mkdir(parents=True, exist_ok=True)
        target.symlink_to(FRAMES/f'{f:06}.jpg')
    extraction = pycolmap.FeatureExtractionOptions()
    extraction.gpu_index = '0'
    extraction.num_threads = 8
    reader = pycolmap.ImageReaderOptions(existing_camera_id=camera.camera_id)
    # PER_FOLDER creates a new camera even with existing_camera_id (vendored ImageReader).
    pycolmap.extract_features(database, OUT/'images', camera_mode=pycolmap.CameraMode.AUTO,
        reader_options=reader, extraction_options=extraction, device=pycolmap.Device.cuda)
    with pycolmap.Database.open(database) as db:
        assert all(v.camera_id == camera.camera_id for v in db.read_all_images() if v.name in queries)
        assert np.allclose(db.read_camera(camera.camera_id).params, camera.params)
    pairs = OUT/'pairs.txt'
    pairs.write_text(''.join(f'{q} {r.name}\n' for q in queries for r in views))
    matching = pycolmap.FeatureMatchingOptions()
    matching.gpu_index = '0'
    matching.num_threads = 8
    pycolmap.match_image_pairs(database, matching_options=matching,
        pairing_options=pycolmap.ImportedPairingOptions(match_list_path=pairs), device=pycolmap.Device.cuda)
    (OUT/'matches-complete.json').write_text(json.dumps(dict(queries=queries, references=len(views))))
rows = []
with pycolmap.Database.open(database) as db:
    records = {v.name: v for v in db.read_all_images()}
    assert all(records[q].camera_id == camera.camera_id for q in queries)
    assert np.allclose(db.read_camera(camera.camera_id).params, camera.params)
    for name, f in queries.items():
        tracks = collections.Counter()
        for ref in views:
            for _, b in db.read_matches(records[name].image_id, ref.image_id):
                point = ref.points2D[int(b)]
                if point.has_point3D():
                    tracks[point.point3D_id] += 1
        row = dict(image=name, unique_tracked_points=len(tracks), supported=False)
        try:
            camera, pose, inliers = heldout_pose(model, database, name, [PICKS[f]])
            row.update(supported=True, pose_inliers=inliers, camera=camera.todict(), pose=pose.matrix().tolist())
        except AssertionError as error:
            row['rejection'] = str(error) or 'Fewer than 20 pose inliers after RANSAC.'
        rows.append(row)
        image = Image.open(FRAMES/f'{f:06}.jpg').transpose(Image.Transpose.ROTATE_270).convert('RGB')
        draw = ImageDraw.Draw(image)
        if f != 28:
            x, y = PICKS[f]
            draw.ellipse((x-8, y-8, x+8, y+8), outline='lime', width=2)
        draw.rectangle((0, 0, 720, 48), fill='black')
        draw.text((8, 5), f'{name}: '+('RESERVED PIXELS' if f == 26 else 'REFERENCE'), fill='white')
        draw.text((8, 25), f'Pose supported: {row["supported"]}; tracked points: {len(tracks)}. No geometry accepted.', fill='white')
        image.save(OUT/f'{f:06}.png')
assert all(sha(SOURCE/p) == h for p, h in audit['source_sha256'].items())
report = dict(rows=rows, source_sha256=audit['source_sha256'], annotations=annotations,
    query_camera_id=camera.camera_id, query_camera_params=camera.params.tolist(),
    provider='local COLMAP CUDA RTX4070SUPER; absolute pose CPU', cost_usd=0,
    geometry_accepted=False, navigation_accepted=False,
    caveat='Same-video reference diagnostics; frozen model/holdout unchanged. No new floor or collision.')
(OUT/'result.json').write_text(json.dumps(report, indent=2)+'\n')
print(json.dumps(report, indent=2))
