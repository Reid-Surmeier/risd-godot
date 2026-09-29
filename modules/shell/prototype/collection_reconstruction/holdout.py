"""Localize withheld photographs against a frozen sparse model; never refit it."""
import argparse
import collections
import json
import pathlib
import shutil
import sys

import numpy as np
import pycolmap

root = pathlib.Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
parser=argparse.ArgumentParser()
parser.add_argument('--source',default='sfm-galleries-v3')
parser.add_argument('--output')
parser.add_argument('--all-references',action='store_true')
args=parser.parse_args()
source = root/args.source
all_references = args.all_references
output = root/(args.output or ('heldout-v2' if all_references else 'heldout-v1'))
output.mkdir(exist_ok=True)
database = output/'database.db'
assert not database.exists(), 'Use a new trial directory; preserve previous evaluation'
shutil.copyfile(source/'database.db', database)
images = output/'images'
images.mkdir(exist_ok=True)
model = pycolmap.Reconstruction(source/'sparse/0')
registered = [i for i in model.images.values() if i.has_pose]
queries = {}
for clip in sorted({i.name.split('/')[0] for i in registered}):
    (images/clip).mkdir(exist_ok=True)
    refs = [i for i in registered if i.name.startswith(clip+'/')]
    for f in sorted((root/'survey-2fps'/clip).glob('*.jpg')):
        if (int(f.stem)-1) % 10 != 5:
            continue
        nearest = sorted(refs, key=lambda r: abs(int(pathlib.Path(r.name).stem)-int(f.stem)))[:6]
        if abs(int(pathlib.Path(nearest[0].name).stem)-int(f.stem)) > 10:
            continue
        name = f'{clip}/{f.name}'
        assert name not in {i.name for i in registered}
        (images/name).symlink_to(f)
        queries[name] = nearest + [r for r in registered if r not in nearest] if all_references else nearest
o = pycolmap.FeatureExtractionOptions();o.gpu_index='0';o.num_threads=8
pycolmap.extract_features(database, images, camera_mode=pycolmap.CameraMode.PER_FOLDER,
                          extraction_options=o, device=pycolmap.Device.cuda)
pairs = output/'pairs.txt'
pairs.write_text(''.join(f'{q} {r.name}\n' for q, refs in queries.items() for r in refs))
matching = pycolmap.FeatureMatchingOptions();matching.gpu_index='0';matching.num_threads=8
pycolmap.match_image_pairs(database, matching_options=matching,
                          pairing_options=pycolmap.ImportedPairingOptions(match_list_path=pairs),
                          device=pycolmap.Device.cuda)
results = []
with pycolmap.Database.open(database) as db:
    records = {i.name:i for i in db.read_all_images()}
    for name, refs in queries.items():
        q = records[name]
        matches = collections.defaultdict(collections.Counter)
        for ref in refs:
            for a, b in db.read_matches(q.image_id, ref.image_id):
                point = ref.points2D[int(b)]
                if point.has_point3D():
                    matches[int(a)][point.point3D_id] += 1
        ids = list(matches)
        xy = db.read_keypoints(q.image_id)[ids, :2].astype(float)
        xyz = np.array([model.points3D[matches[i].most_common(1)[0][0]].xyz for i in ids])
        camera = model.cameras[refs[0].camera_id]
        est = pycolmap.AbsolutePoseEstimationOptions();est.ransac.max_error=4.;est.ransac.random_seed=182
        pose = pycolmap.estimate_and_refine_absolute_pose(xy, xyz, camera, estimation_options=est) if len(ids)>=6 else None
        row = dict(image=name, correspondences=len(ids), localized=pose is not None)
        if pose:
            projected = camera.img_from_cam(pose['cam_from_world'] * xyz)
            residual = np.linalg.norm(projected-xy,axis=1)[pose['inlier_mask']]
            row.update(inliers=int(pose['num_inliers']), median_error_px=float(np.median(residual)))
        row['supported'] = row.get('inliers', 0) >= 20 and row.get('inliers', 0)/max(1, len(ids)) >= .25
        results.append(row)
(output/'result.json').write_text(json.dumps(results,indent=2))
print(json.dumps(results,indent=2))
