"""#182: localize fresh casing samples without changing the frozen model."""
import argparse
import collections
import hashlib
import json
from pathlib import Path
import shutil

import numpy as np
import pycolmap
from PIL import Image, ImageDraw
from measurements import heldout_pose, project, triangulate, upright

ROOT = Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
SOURCE = ROOT/'sfm-calibrated-doorway-v1'
FRAMES = ROOT/'grand-casing-revisit-v1'
OUT = ROOT/'grand-return-fresh-calibrated-v3'
# Upright source pixels, frozen before fitting. Frame 28 has no visible Grand toe.
PICKS = {24: [312, 1021], 26: [548, 1036], 28: [0, 0]}
parser = argparse.ArgumentParser()
parser.add_argument('--right-toe', action='store_true')
args = parser.parse_args()
if args.right_toe:
    OUT = ROOT/'grand-right-toe-v1'
    PICKS = {12: [568, 1060], 14: [506, 1095]}
OUT.mkdir(exist_ok=True)


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


annotations = dict(picks=PICKS, reserved=26, training=[203, 24],
    excluded_from_triangulation=[28], caveat='Blurred toe picks; frame 28 turns toward adjacent blue room.')
if args.right_toe:
    annotations = dict(picks=PICKS, reserved='IMG_6380/000206.jpg', reserved_pixel=[626, 1043],
        training=[12, 14], caveat='Right exterior white casing toe only, not the inner aperture. '
        'Nearby same-video views; frozen query pixels, original 102.5s exclusion retained.')
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
    if args.right_toe:
        assert abs(101+(f-1)/6-102.5) > .2
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
            row.update(supported=True, pose_inliers=inliers,
                camera=dict(model=camera.model.name, camera_id=camera.camera_id,
                    width=camera.width, height=camera.height, params=camera.params.tolist()),
                pose=pose.matrix().tolist())
            if args.right_toe:
                matches = collections.defaultdict(collections.Counter)
                for ref in views:
                    for a, b in db.read_matches(records[name].image_id, ref.image_id):
                        point = ref.points2D[int(b)]
                        if point.has_point3D():
                            matches[int(a)][point.point3D_id] += 1
                ids = sorted(matches)
                point_ids = np.array([matches[i].most_common(1)[0][0] for i in ids])
                test = point_ids % 2 == 0  # Same disjoint-point audit as the frozen holdout.
                xy = db.read_keypoints(records[name].image_id)[ids, :2].astype(float)[test]
                xyz = np.array([model.points3D[int(i)].xyz for i in point_ids[test]])
                camera_xyz = pose*xyz
                errors = np.linalg.norm(camera.img_from_cam(camera_xyz)-xy, axis=1)
                good = np.isfinite(errors) & (errors < 4) & (camera_xyz[:, 2] > 0)
                row['unused_point_audit'] = dict(test_features=len(xy), below4px=int(good.sum()),
                    fraction=float(good.mean()) if len(good) else 0.,
                    supported=bool(good.sum() >= 20 and good.mean() >= .25),
                    caveat='Even 3D points excluded from odd-point pose fit; shared frozen geometry.')
                im = Image.open(FRAMES/f'{f:06}.jpg').transpose(Image.Transpose.ROTATE_270).convert('RGB')
                draw = ImageDraw.Draw(im)
                for pixel, passed in zip(upright(xy), good):
                    x, y = pixel
                    draw.ellipse((x-3, y-3, x+3, y+3), outline='lime' if passed else 'orange', width=2)
                draw.rectangle((0, 0, 720, 40), fill='black')
                draw.text((8, 8), f'{f}: unused even points. Green <4px; orange failed. Not corner validation.', fill='white')
                im.save(OUT/f'{f:06}-unused-points.png')
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
        draw.text((8, 25), f'Pose supported: {row["supported"]}; tracked points: {len(tracks)}. Diagnostic only.', fill='white')
        image.save(OUT/f'{f:06}.png')
assert all(sha(SOURCE/p) == h for p, h in audit['source_sha256'].items())
report = dict(rows=rows, source_sha256=audit['source_sha256'], annotations=annotations,
    query_camera_id=camera.camera_id, query_camera_params=camera.params.tolist(),
    provider='local COLMAP CUDA RTX4070SUPER; absolute pose CPU', cost_usd=0,
    geometry_accepted=False, navigation_accepted=False,
    caveat='Same-video reference diagnostics; frozen model/holdout unchanged. No new floor or collision.')
if args.right_toe and all(r['supported'] for r in rows):
    cameras, poses = {}, {}
    for name, f in queries.items():
        cameras[name], poses[name], _ = heldout_pose(model, database, name, [PICKS[f]])
    query = annotations['reserved']
    cameras[query], poses[query], inliers = heldout_pose(model,
        ROOT/'heldout-calibrated-v1/database.db', query, [annotations['reserved_pixel']])
    observations = {name: PICKS[f] for name, f in queries.items()}
    point, angle = triangulate(cameras, poses, observations)
    assert np.isfinite(point).all() and all((pose*point)[2] > 0 for pose in poses.values())
    recovered, _ = triangulate(cameras, poses,
        {name: project(cameras[name], poses[name], point[None])[0] for name in queries})
    assert np.linalg.norm(recovered-point) < 1e-6
    predicted = project(cameras[query], poses[query], point[None])[0]
    error = float(np.linalg.norm(predicted-annotations['reserved_pixel']))
    assert np.linalg.norm(predicted-(np.array(annotations['reserved_pixel'])+[50, 0])) > 8
    aperture = json.loads((ROOT/'doorway-aperture-v1/result.json').read_text())
    scale = aperture['provisional_m_per_unit']
    left = json.loads((ROOT/'grand-casing-registered-v1/result.json').read_text())
    rng = np.random.default_rng(182)
    samples = np.array([triangulate(cameras, poses,
        {name: np.array(pixel)+rng.uniform(-3, 3, 2) for name, pixel in observations.items()})[0]
        for _ in range(300)])
    report['toe'] = dict(point_world=point.tolist(), ray_angle_degrees=angle,
        reserved_pose_inliers=inliers, reserved_error_px=error,
        diagnostic_pass=error <= 8 and angle >= 1 and all(r['unused_point_audit']['supported'] for r in rows),
        provisional_m_per_unit=scale,
        exterior_toe_distance_m=float(np.linalg.norm(point-np.array(left['points_world'])[0])*scale),
        pick_sensitivity_p95_displacement_m=float(np.percentile(np.linalg.norm(samples-point, axis=1)*scale, 95)),
        caveat='Exterior casing separation is not inner opening width. Pick sensitivity excludes pose/scale error. '
        'No full aperture, floor, collision or navigation accepted.')
    for name, pixel in {**observations, query: annotations['reserved_pixel']}.items():
        path = ROOT/'survey-2fps'/name if name == query else FRAMES/f'{queries[name]:06}.jpg'
        im = Image.open(path).transpose(Image.Transpose.ROTATE_270).convert('RGB')
        draw = ImageDraw.Draw(im)
        x, y = pixel
        draw.ellipse((x-7, y-7, x+7, y+7), outline='lime', width=2)
        x, y = project(cameras[name], poses[name], point[None])[0]
        draw.line((x-8, y, x+8, y), fill='red', width=2)
        draw.line((x, y-8, x, y+8), fill='red', width=2)
        draw.rectangle((0, 0, 720, 40), fill='black')
        draw.text((8, 8), name+(' RESERVED PIXELS' if name == query else ' FIT'), fill='white')
        im.save(OUT/('reserved.png' if name == query else f'{queries[name]:06}.png'))
assert all(sha(SOURCE/p) == h for p, h in audit['source_sha256'].items())
(OUT/'result.json').write_text(json.dumps(report, indent=2)+'\n')
print(json.dumps(report, indent=2))
