"""#182: rebuild without leaked views, then evaluate cached withheld matches."""
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
SOURCE = ROOT/'sfm-calibrated-doorway-v1'
OUT = ROOT/'sfm-strict-doorway-v1'
parser = argparse.ArgumentParser()
parser.add_argument('--validate', action='store_true')
args = parser.parse_args()
selection = json.loads((ROOT/'sampling-timing-v1/strict-training-selection.json').read_text())
allowed = set(selection['training_names'])
withheld = set(selection['heldout_names'])
assert len(allowed) == 473 and not allowed & withheld
assert not allowed & set(selection['excluded_names'])
pins = selection['source_sha256']


def preserve_source():
    assert all(hashlib.sha256((SOURCE/p).read_bytes()).hexdigest() == h for p, h in pins.items())


preserve_source()
if not args.validate:
    OUT.mkdir(exist_ok=False)  # An interrupted trial must be inspected, never overwritten.
    shutil.copyfile(SOURCE/'database.db', OUT/'database.db')
    (OUT/'images').symlink_to(SOURCE/'images', target_is_directory=True)
    options = pycolmap.IncrementalPipelineOptions()
    options.image_names = sorted(allowed)
    options.num_threads = 8
    options.random_seed = 182
    options.max_num_models = 1
    options.max_runtime_seconds = 420
    options.ba_use_gpu = True
    options.ba_gpu_index = '0'
    options.ba_refine_focal_length = False
    options.ba_refine_extra_params = False
    options.snapshot_path = str(OUT/'snapshots')
    options.snapshot_frames_freq = 50
    (OUT/'snapshots').mkdir()
    (OUT/'selection.json').write_text(json.dumps(selection, indent=2)+'\n')
    (OUT/'options.json').write_text(json.dumps(options.todict(), indent=2, default=str)+'\n')
    # No input_path: no old points/poses enter the fresh reconstruction. Intrinsics
    # remain inherited video estimates, not independent external calibration.
    models = pycolmap.incremental_mapping(OUT/'database.db', OUT/'images', OUT/'sparse', options=options)
    rows = []
    for index, model in models.items():
        names = sorted(i.name for i in model.images.values() if i.has_pose)
        assert set(names) <= allowed
        model.write(OUT/'sparse'/str(index))
        rows.append(dict(component=index, images=len(names), points=model.num_points3D(),
            mean_reprojection_error=model.compute_mean_reprojection_error(), registered=names))
    assert rows, 'No model recovered; preserve snapshots/logs for the next tick.'
    (OUT/'result.json').write_text(json.dumps(rows, indent=2)+'\n')
    print(json.dumps([{k: v for k, v in row.items() if k != 'registered'} for row in rows]))
else:
    assert not (OUT/'validation.json').exists(), 'Preserve completed validation.'
    model = pycolmap.Reconstruction(OUT/'sparse/0')
    refs = [i for i in model.images.values() if i.has_pose]
    assert {i.name for i in refs} <= allowed
    output = []
    with pycolmap.Database.open(ROOT/'heldout-calibrated-v1/database.db') as db:
        records = {i.name: i for i in db.read_all_images()}
        for name in sorted(withheld):
            matches = collections.defaultdict(collections.Counter)
            for ref in refs:
                for a, b in db.read_matches(records[name].image_id, ref.image_id):
                    point = ref.points2D[int(b)]
                    if point.has_point3D():
                        matches[int(a)][point.point3D_id] += 1
            ids = sorted(matches)
            point_ids = np.array([matches[i].most_common(1)[0][0] for i in ids])
            xy = db.read_keypoints(records[name].image_id)[ids, :2].astype(float)
            xyz = np.array([model.points3D[int(i)].xyz for i in point_ids])
            test = point_ids % 2 == 0
            row = dict(image=name, fit_points=int((~test).sum()), test_points=int(test.sum()), supported=False)
            ref = next((r for r in refs if r.name.split('/')[0] == name.split('/')[0]), None)
            if ref and min(row['fit_points'], row['test_points']) >= 6:
                camera = pycolmap.Camera(model.cameras[ref.camera_id].todict())
                options = pycolmap.AbsolutePoseEstimationOptions()
                options.ransac.max_error = 4.
                options.ransac.random_seed = 182
                pose = pycolmap.estimate_and_refine_absolute_pose(xy[~test], xyz[~test], camera, estimation_options=options)
                if pose:
                    camera_xyz = pose['cam_from_world'] * xyz[test]
                    predicted = camera.img_from_cam(camera_xyz)
                    errors = np.linalg.norm(predicted-xy[test], axis=1)
                    good = np.isfinite(errors) & (errors < 4) & (camera_xyz[:, 2] > 0)
                    row.update(fit_inliers=int(pose['num_inliers']), test_below4px=int(good.sum()),
                        test_fraction=float(good.mean()), supported=bool(pose['num_inliers'] >= 20
                            and pose['num_inliers']/row['fit_points'] >= .25 and good.sum() >= 20 and good.mean() >= .25))
                    if name in ['IMG_6380/000206.jpg', 'IMG_6380/000496.jpg', 'IMG_6380/000506.jpg', 'IMG_6380/000516.jpg']:
                        im = Image.open(ROOT/'survey-2fps'/name).convert('RGB')
                        draw = ImageDraw.Draw(im)
                        for observed, projected, passed in zip(xy[test], predicted, good):
                            x, y = observed
                            draw.ellipse((x-3, y-3, x+3, y+3), outline='lime' if passed else 'orange', width=2)
                            if passed:
                                draw.line((x, y, *projected), fill='red', width=2)
                        draw.rectangle((0, 0, 1280, 30), fill='black')
                        draw.text((8, 8), f'{name}: {good.sum()}/{len(good)} unused points below 4px; fresh model; provisional calibration', fill='white')
                        im.save(OUT/(Path(name).stem+'-validation.jpg'))
            output.append(row)
    assert len(output) == 69
    validation = dict(samples=len(output), supported=sum(r['supported'] for r in output), rows=output,
        excluded_names=selection['excluded_names'], registered_views=len(refs),
        model_sha256={p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in (OUT/'sparse/0').glob('*.bin')},
        caveat='No old geometry seed. Same-video withheld samples and inherited video intrinsics; '
            'not independent capture/metric validation. New point IDs give a new fit/test split; '
            'counts are not paired statistical comparisons. No room/floor/collision acceptance.', navigation_accepted=False)
    (OUT/'validation.json').write_text(json.dumps(validation, indent=2)+'\n')
    print(json.dumps({k: v for k, v in validation.items() if k != 'rows'}, indent=2))
preserve_source()
