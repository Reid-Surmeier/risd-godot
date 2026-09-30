"""#182: frozen-plane transfer to withheld pixels; upper-image-only pose fit."""
import argparse
import collections
import hashlib
import json
from pathlib import Path
import shutil

import numpy as np
import pycolmap
from PIL import Image, ImageDraw

ROOT = Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
parser = argparse.ArgumentParser()
parser.add_argument('--output', default='strict-floor-holdout-v1')
parser.add_argument('--photometric', action='store_true', help='Transfer fixed floor pixels, with shifted-plane controls')
parser.add_argument('--triangle', type=Path, help='Frozen corrected-model triangle replacing only the near-plane hypothesis')
parser.add_argument('--queries', nargs='+', help='Reserved image names; source separation and pose gates remain enforced')
parser.add_argument('--pose-ceiling', type=int, default=450, help='Source-reviewed upper-image cutoff, frozen before fitting')
args = parser.parse_args()
assert 0 < args.pose_ceiling <= 1280
OUT = ROOT/args.output
OUT.mkdir(exist_ok=False)
SOURCE = ROOT/'strict-depth-floor-v1/result.json'
source = json.loads(SOURCE.read_text())
model = pycolmap.Reconstruction(ROOT/'sfm-strict-doorway-v1/sparse/0')
dense = pycolmap.Reconstruction(ROOT/'dense-strict-floor-v1/sparse')
refs = [v for v in model.images.values() if v.has_pose]
view = next(v for v in refs if v.name == source['source'])
camera = model.cameras[view.camera_id]
dense_view = next(v for v in dense.images.values() if v.name == view.name)
dense_camera = dense.cameras[dense_view.camera_id]
assert np.max(abs(view.cam_from_world().matrix()-dense_view.cam_from_world().matrix())) < 1e-8
selection = json.loads((ROOT/'sampling-timing-v1/strict-training-selection.json').read_text())
queries = args.queries or ['IMG_6380/000246.jpg', 'IMG_6380/000506.jpg', 'IMG_6380/000516.jpg']
assert set(queries) <= set(selection['heldout_names'])
assert not set(queries) & {v.name for v in refs}
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
inputs = {str(SOURCE): sha(SOURCE)}
database = ROOT/'heldout-calibrated-v1/database.db'
inputs[str(database)] = sha(database)
inputs.update({str(p): sha(p) for folder in ['sfm-strict-doorway-v1/sparse/0', 'dense-strict-floor-v1/sparse']
    for p in (ROOT/folder).glob('*.bin')})
if args.triangle:
    triangle = json.loads(args.triangle.read_text())
    assert triangle['source_sha256'] == {p.name: sha(p) for p in (ROOT/'sfm-strict-doorway-v1/sparse/0').glob('*.bin')}
    assert not set(queries) & set(triangle['selection']['training']), 'Query used in triangle fit'
    points = np.array(triangle['points_world'], dtype=float)
    normal = np.array(triangle['candidate_normal_world'], dtype=float)
    assert points.shape == (3, 3) and normal.shape == (3,) and np.isfinite(points).all()
    assert np.isfinite(normal).all() and abs(np.linalg.norm(normal)-1) < 1e-8
    assert max(abs((points-points.mean(0))@normal)) < 1e-8
    near = next(p for p in source['patches'] if p['patch'] == 'near')
    near.update(center_world=points.mean(0).tolist(), normal_world=normal.tolist())
    inputs[str(args.triangle)] = sha(args.triangle)
masks = {}
for patch in source['patches']:
    mask = Image.new('1', (360, 640))
    ImageDraw.Draw(mask).polygon([tuple(p) for p in patch['polygon']], fill=1)
    masks[patch['patch']] = mask
floor_features = {}
for b, point in enumerate(view.points2D):
    if not point.has_point3D():
        continue
    ray = np.r_[camera.cam_from_img(point.xy), 1.]
    dxy = dense_camera.img_from_cam(ray)
    px, py = np.rint([359-dxy[1], dxy[0]]).astype(int)
    for label, mask in masks.items():
        if 0 <= px < 360 and 0 <= py < 640 and mask.getpixel((px, py)):
            floor_features[b] = (label, ray)


def bilinear(pixels, xy):
    """Caller supplies finite interior coordinates; retain subpixel sampling."""
    x, y = xy.T
    ix, iy = np.floor(x).astype(int), np.floor(y).astype(int)
    fx, fy = (x-ix)[:, None], (y-iy)[:, None]
    return ((1-fy)*((1-fx)*pixels[iy, ix]+fx*pixels[iy, ix+1])
            + fy*((1-fx)*pixels[iy+1, ix]+fx*pixels[iy+1, ix+1]))


known = np.arange(12, dtype=float).reshape(2, 2, 3)
assert np.allclose(bilinear(known, np.array([[.5, .5]])), known.mean(axis=(0, 1)))
assert np.allclose(bilinear(known, np.array([[0., 0.]])), known[0, 0])
source_photo = ROOT/'dense-strict-floor-v1/images'/view.name
inputs[str(source_photo)] = sha(source_photo)
source_pixels = np.array(Image.open(source_photo).convert('RGB'), dtype=float)
rows = []
# Database.open may update SQLite bytes even for read calls. Keep the cache intact.
scratch_database = OUT/'database.db'
shutil.copyfile(database, scratch_database)
with pycolmap.Database.open(scratch_database) as db:
    records = {v.name: v for v in db.read_all_images()}
    for name in queries:
        q = records[name]
        keypoints = db.read_keypoints(q.image_id)[:, :2].astype(float)
        matches = collections.defaultdict(collections.Counter)
        for ref in refs:
            for a, b in db.read_matches(q.image_id, ref.image_id):
                p = ref.points2D[int(b)]
                if p.has_point3D():
                    matches[int(a)][p.point3D_id] += 1
        ids = sorted(matches)
        point_ids = np.array([matches[i].most_common(1)[0][0] for i in ids])
        xy = keypoints[ids]
        xyz = np.array([model.points3D[int(i)].xyz for i in point_ids])
        direct = db.read_matches(q.image_id, view.image_id)
        floor_query_ids = {int(a) for a, b in direct if int(b) in floor_features}
        # Raw x is upright y. Freeze the source-reviewed cutoff before evaluating floor.
        not_floor = np.array([i not in floor_query_ids for i in ids])
        fit = (point_ids % 2 == 1) & (xy[:, 0] < args.pose_ceiling) & not_floor
        fit_query_ids = set(np.array(ids)[fit].tolist())
        row = dict(image=name, pose_fit_features=int(fit.sum()), patches=[], pose_supported=False)
        if fit.sum() < 20:
            row['status'] = 'insufficient upper-image pose correspondences'
            rows.append(row)
            continue
        qc = pycolmap.Camera(camera.todict())
        options = pycolmap.AbsolutePoseEstimationOptions()
        options.ransac.max_error = 4.
        options.ransac.random_seed = 182
        estimated = pycolmap.estimate_and_refine_absolute_pose(xy[fit], xyz[fit], qc, estimation_options=options)
        if estimated is None or estimated['num_inliers'] < 20:
            row['status'] = 'upper-image pose failed'
            rows.append(row)
            continue
        row['pose_inliers'] = int(estimated['num_inliers'])
        test = (point_ids % 2 == 0) & (xy[:, 0] < args.pose_ceiling) & not_floor
        test_camera_xyz = estimated['cam_from_world']*xyz[test]
        test_errors = np.linalg.norm(qc.img_from_cam(test_camera_xyz)-xy[test], axis=1)
        good = np.isfinite(test_errors) & (test_errors < 4) & (test_camera_xyz[:, 2] > 0)
        row.update(pose_test_features=int(test.sum()), pose_test_below4px=int(good.sum()),
            pose_supported=bool(estimated['num_inliers']/fit.sum() >= .25 and good.sum() >= 20
                and good.mean() >= .25))
        if not row['pose_supported']:
            row['status'] = 'upper-image pose lacks unused-point support'
            rows.append(row)
            continue
        if args.pose_ceiling != 450:
            row['cam_from_world'] = estimated['cam_from_world'].matrix().tolist()
            row['camera'] = dict(model=str(qc.model).split('.')[-1], width=qc.width,
                height=qc.height, params=qc.params.tolist())
        image_path = ROOT/'survey-2fps'/name
        inputs[str(image_path)] = sha(image_path)
        picture = Image.open(image_path).transpose(Image.Transpose.ROTATE_270).convert('RGB')
        draw = ImageDraw.Draw(picture)
        query_pixels = np.array(Image.open(image_path).convert('RGB'), dtype=float)
        for patch in source['patches']:
            center, normal = np.array(patch['center_world']), np.array(patch['normal_world'])
            if args.photometric:
                yy, xx = np.nonzero(np.array(masks[patch['patch']]))
                raw = np.c_[yy, 359-xx]
                rays = np.c_[dense_camera.cam_from_img(raw), np.ones(len(raw))]
                directions = rays @ view.cam_from_world().rotation.matrix()
                origin = view.projection_center()
                distances = ((center-origin)@normal)/(directions@normal)
                assert np.isfinite(distances).all() and (distances > 0).all()
                on_plane = origin+directions*distances[:, None]
                assert max(abs((on_plane-center)@normal)) < 1e-8
                assert np.max(abs(dense_camera.img_from_cam(view.cam_from_world()*on_plane)-raw)) < 1e-6
                depth_scale = float(np.median(distances))
                variants, projections = [], []
                for offset in [0., -.01, .01, -.05, .05]:
                    shifted = center+normal*(offset*depth_scale)
                    distance = ((shifted-origin)@normal)/(directions@normal)
                    world = origin+directions*distance[:, None]
                    target = estimated['cam_from_world']*world
                    projected = qc.img_from_cam(target)
                    valid = np.isfinite(projected).all(axis=1) & (target[:, 2] > 0)
                    valid &= (projected[:, 0] >= 0) & (projected[:, 0] < qc.width-1)
                    valid &= (projected[:, 1] >= 0) & (projected[:, 1] < qc.height-1)
                    variants.append((offset, valid))
                    projections.append(projected)
                # Compare every control on identical pixels, never select by residual.
                common = np.logical_and.reduce([valid for _, valid in variants])
                original = source_pixels[raw[common, 1], raw[common, 0]]
                photometric = []
                for (offset, valid), projected in zip(variants, projections):
                    if common.sum() < 100:
                        photometric.append(dict(offset_fraction_source_camera_depth=offset,
                            visible_pixels=int(valid.sum()), common_pixels=int(common.sum()),
                            status='insufficient common visible pixels; no score'))
                        continue
                    warped = bilinear(query_pixels, projected[common])
                    a, b = original.mean(axis=1), warped.mean(axis=1)
                    score = float(np.corrcoef(a, b)[0, 1]) if min(a.std(), b.std()) > 0 else None
                    photometric.append(dict(offset_fraction_source_camera_depth=offset,
                        pixels=int(common.sum()), grayscale_correlation=score,
                        median_absolute_rgb_difference=float(np.median(abs(original-warped)))))
                    if offset == 0:
                        panel = np.zeros((640, 1080, 3), dtype=np.uint8)
                        panel[yy[common], xx[common]] = original.astype(np.uint8)
                        panel[yy[common], xx[common]+360] = warped.clip(0, 255).astype(np.uint8)
                        panel[yy[common], xx[common]+720] = (abs(original-warped)*4).clip(0, 255).astype(np.uint8)
                        crop = Image.fromarray(panel[yy[common].min():yy[common].max()+1])
                        panel_image = Image.new('RGB', (1080, crop.height+34))
                        panel_image.paste(crop, (0, 34))
                        labels = ImageDraw.Draw(panel_image)
                        labels.text((4, 4), 'Training source / withheld transfer / difference x4', fill='white')
                        labels.text((4, 18), name+' '+patch['patch']+'; frozen plane, upper-image pose', fill='white')
                        panel_image.save(OUT/(Path(name).stem+'-'+patch['patch']+'-photometric.png'))
                        corners = np.array(patch['polygon'])
                        corner_rays = np.c_[dense_camera.cam_from_img(np.c_[corners[:, 1], 359-corners[:, 0]]), np.ones(4)]
                        corner_directions = corner_rays @ view.cam_from_world().rotation.matrix()
                        corner_distance = ((center-origin)@normal)/(corner_directions@normal)
                        projected_corners = qc.img_from_cam(estimated['cam_from_world']*(origin+corner_directions*corner_distance[:, None]))
                        upright = [(719-y, x) for x, y in projected_corners]
                        draw.line(upright+[upright[0]], fill='yellow', width=2)
                row.setdefault('photometric', []).append(dict(patch=patch['patch'],
                    source_mask_pixels=len(raw), common_visible_fraction=float(common.mean()),
                    controls=photometric))
            observed, predicted, tested_ids = [], [], []
            for a, b in direct:
                point = view.points2D[int(b)]
                if not point.has_point3D() or point.point3D_id % 2 != 0:
                    continue
                if int(b) not in floor_features or floor_features[int(b)][0] != patch['patch']:
                    continue
                assert int(a) not in fit_query_ids, 'Floor check feature entered camera pose fit'
                ray = floor_features[int(b)][1]
                direction = view.cam_from_world().rotation.matrix().T @ ray
                origin = view.projection_center()
                distance = ((center-origin)@normal)/(direction@normal)
                if not np.isfinite(distance) or distance <= 0:
                    continue
                world = origin+direction*distance
                assert abs((world-center)@normal) < 1e-8
                assert np.linalg.norm(camera.img_from_cam(view.cam_from_world()*world)-point.xy) < 1e-6
                assert abs((world+normal*.1-center)@normal) > .099
                target = estimated['cam_from_world']*world
                if target[2] <= 0:
                    continue
                observed.append(keypoints[int(a)])
                predicted.append(qc.img_from_cam(target))
                tested_ids.append(int(point.point3D_id))
            errors = np.linalg.norm(np.array(predicted)-observed, axis=1) if observed else np.array([])
            pr = dict(patch=patch['patch'], observations=len(errors), unique_points=len(set(tested_ids)),
                point_ids=tested_ids, errors_px=errors.tolist())
            if len(errors):
                pr['p50_p90_px'] = np.percentile(errors, [50, 90]).tolist()
                pr['fraction_below8px'] = float(np.mean(errors <= 8))
            row['patches'].append(pr)
            for obs, pred, error in zip(observed, predicted, errors):
                x, y = 719-obs[1], obs[0]
                draw.ellipse((x-4, y-4, x+4, y+4), outline='lime' if error <= 8 else 'orange', width=2)
                draw.line((x, y, 719-pred[1], pred[0]), fill='red', width=2)
        draw.rectangle((0, 0, 720, 45), fill='black')
        label = 'frozen triangle/depth planes' if args.triangle else 'frozen depth planes'
        draw.text((8, 5), name+' WITHHELD pixels; '+label, fill='white')
        draw.text((8, 24), 'Upper-image pose only; green <=8px, orange larger', fill='white')
        picture.save(OUT/(Path(name).stem+'-transfer.png'))
        row['status'] = 'diagnostic only; report all floor matches without outlier trimming'
        rows.append(row)
assert all(sha(Path(p)) == h for p, h in inputs.items())
report = dict(rows=rows, inputs_sha256=inputs, navigation_accepted=False, cost_usd=0,
    photometric=args.photometric,
    pose_fit_upright_y_below=args.pose_ceiling, pose_fit_point_parity='odd', floor_check_point_parity='even',
    all_floor_query_features_excluded_from_pose=True,
    caveat='Withheld query pixels and floor features excluded from pose fit. Plane fixed from '
    'training depth; no query floor refit. Cached tentative matches are not verified identity. '
    'Same-video cameras, shared reconstruction and inherited intrinsics remain correlated. '
    'Photometric controls use fixed normal offsets and common visible pixels; repeated wood, '
    'occlusion, exposure and short baseline can hide errors. No score implies acceptance. '
    '8px is a prior diagnostic gate, not physical planarity, scale or collision acceptance.')
if args.triangle:
    report['near_plane_triangle'] = str(args.triangle)
    report['caveat'] = report['caveat'].replace('Plane fixed from training depth',
        'Near plane fixed from the supplied training triangle; far plane fixed from training depth')
(OUT/'result.json').write_text(json.dumps(report, indent=2)+'\n')
print(json.dumps(rows, indent=2))
