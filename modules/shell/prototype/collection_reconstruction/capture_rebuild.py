"""#182 whole-capture split: fresh source-only geometry and freely refined intrinsics."""
import argparse
import collections
import hashlib
import json
from pathlib import Path
import shutil
import sqlite3

import numpy as np
import pycolmap

ROOT = Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
OUT = ROOT/'sfm-capture-split-v1'
parser = argparse.ArgumentParser()
parser.add_argument('--validate', action='store_true')
args = parser.parse_args()
selection = json.loads((ROOT/'sampling-timing-v1/strict-training-selection.json').read_text())
allowed = sorted(n for n in selection['training_names'] if n.startswith('IMG_6380/') and int(Path(n).stem)>=244)
assert len(allowed)>100 and all(n.startswith('IMG_6380/') for n in allowed)
if not args.validate:
    OUT.mkdir(exist_ok=False)
    source = ROOT/'sfm-strict-doorway-v1/database.db'
    source_sha = hashlib.sha256(source.read_bytes()).hexdigest()
    shutil.copyfile(source, OUT/'database.db')
    (OUT/'images').symlink_to(ROOT/'sfm-strict-doorway-v1/images',target_is_directory=True)
    with pycolmap.Database.open(OUT/'database.db') as db:
        images = {v.name:v for v in db.read_all_images()}
        ids = {images[n].image_id for n in allowed}
        cameras = {images[n].camera_id for n in allowed}
        assert len(cameras)==1
        camera = db.read_camera(next(iter(cameras)))
        assert camera.model == pycolmap.CameraModelId.SIMPLE_RADIAL
        # COLMAP's nominal focal heuristic; no old fitted intrinsics, points or poses.
        camera.params = np.array([1.2*max(camera.width,camera.height),camera.width/2,camera.height/2,0.])
        camera.has_prior_focal_length = False
        db.update_camera(camera)
        db.clear_two_view_geometries()
    with sqlite3.connect(OUT/'database.db') as db:
        pairs = [pycolmap.pair_id_to_image_pair(row[0]) for row in db.execute('SELECT pair_id FROM matches WHERE rows>=15')]
    reverse = {v.image_id:n for n,v in images.items()}
    pairs = [(a,b) for a,b in pairs if a in ids and b in ids]
    (OUT/'pairs.txt').write_text(''.join(f'{reverse[a]} {reverse[b]}\n' for a,b in pairs))
    assert pairs
    options = pycolmap.IncrementalPipelineOptions()
    options.image_names = allowed
    options.num_threads = 8
    options.random_seed = 182
    options.max_num_models = 1
    options.max_runtime_seconds = 300
    options.ba_refine_focal_length = True
    options.ba_refine_extra_params = True
    options.ba_use_gpu = True
    options.ba_gpu_index = '0'
    options.snapshot_path = str(OUT/'snapshots')
    options.snapshot_frames_freq = 50
    (OUT/'snapshots').mkdir()
    (OUT/'selection.json').write_text(json.dumps(dict(training=allowed,heldout_capture='IMG_6384',
        source_sha256=source_sha,nominal_camera=camera.todict(),cached_training_pairs=len(pairs),
        caveat='Reuse cached CUDA features/tentative matches only. Reverify source pairs after resetting '
               'nominal intrinsics; no query cameras, points or poses enter mapping. Ceres CPU fallback is known.'),indent=2,default=lambda x:x.tolist() if isinstance(x,np.ndarray) else str(x))+'\n')
    pycolmap.verify_matches(OUT/'database.db',OUT/'pairs.txt')
    models = pycolmap.incremental_mapping(OUT/'database.db',OUT/'images',OUT/'sparse',options=options)
    assert models, 'No source-only model; preserve logs/snapshots'
    rows=[]
    for index,model in models.items():
        names=sorted(v.name for v in model.images.values() if v.has_pose)
        assert set(names)<=set(allowed) and not any(n.startswith('IMG_6384/') for n in names)
        model.write(OUT/'sparse'/str(index))
        rows.append(dict(component=index,images=len(names),points=model.num_points3D(),
            mean_reprojection_error_px=model.compute_mean_reprojection_error(),registered=names,
            cameras=[dict(model=str(c.model),params=c.params.tolist()) for c in model.cameras.values()]))
    assert hashlib.sha256(source.read_bytes()).hexdigest()==source_sha
    (OUT/'result.json').write_text(json.dumps(rows,indent=2)+'\n')
    print(json.dumps([{k:v for k,v in row.items() if k!='registered'} for row in rows]))
else:
    path=OUT/'capture-validation.json'
    assert not path.exists(), 'Preserve completed validation'
    model=pycolmap.Reconstruction(OUT/'sparse/0')
    refs=list(model.images.values())
    assert {v.name for v in refs}<=set(allowed)
    shutil.copyfile(ROOT/'heldout-calibrated-v1/database.db',OUT/'validation.db')
    rows=[]
    with pycolmap.Database.open(OUT/'validation.db') as db:
        records={v.name:v for v in db.read_all_images()}
        for name in ['IMG_6384/000196.jpg','IMG_6384/000206.jpg','IMG_6384/000207.jpg','IMG_6384/000209.jpg']:
            query=records[name];matches=collections.defaultdict(collections.Counter)
            for ref in refs:
                for a,b in db.read_matches(query.image_id,ref.image_id):
                    point=ref.points2D[int(b)]
                    if point.has_point3D():matches[int(a)][point.point3D_id]+=1
            ids=sorted(matches);pids=np.array([matches[i].most_common(1)[0][0] for i in ids])
            row=dict(image=name,correspondences=len(ids),supported=False)
            if len(ids)<40:rows.append(row);continue
            xy=db.read_keypoints(query.image_id)[ids,:2].astype(float)
            xyz=np.array([model.points3D[int(i)].xyz for i in pids])
            fit=(pids%2==1)&(xy[:,0]<700);test=(pids%2==0)&(xy[:,0]<700)
            row.update(fit_features=int(fit.sum()),unused_features=int(test.sum()))
            if min(fit.sum(),test.sum())<20:rows.append(row);continue
            camera=pycolmap.Camera(model.cameras[refs[0].camera_id].todict())
            options=pycolmap.AbsolutePoseEstimationOptions();options.ransac.max_error=4.;options.ransac.random_seed=182
            pose=pycolmap.estimate_and_refine_absolute_pose(xy[fit],xyz[fit],camera,estimation_options=options)
            if pose:
                camera_xyz=pose['cam_from_world']*xyz[test]
                errors=np.linalg.norm(camera.img_from_cam(camera_xyz)-xy[test],axis=1)
                good=np.isfinite(errors)&(errors<4)&(camera_xyz[:,2]>0)
                row.update(fit_inliers=int(pose['num_inliers']),unused_below4px=int(good.sum()),
                    unused_fraction=float(good.mean()),unused_errors_p50_p90_px=np.percentile(errors,[50,90]).tolist(),
                    supported=bool(pose['num_inliers']>=20 and pose['num_inliers']/fit.sum()>=.25 and good.sum()>=20 and good.mean()>=.25),
                    camera=dict(model=str(camera.model).split('.')[-1],width=camera.width,height=camera.height,params=camera.params.tolist()),
                    cam_from_world=pose['cam_from_world'].matrix().tolist())
            rows.append(row)
    report=dict(rows=rows,training_capture='IMG_6380',heldout_capture='IMG_6384',
        whole_capture_excluded_from_mapping=True,nominal_intrinsics_refined_on_training_only=True,
        upper_pose_cutoff=700,fit_ids='odd',unused_ids='even',navigation_accepted=False,cost_usd=0,
        caveat='Different capture absent from fresh mapping and calibration. Pose fits upper query pixels '
               'only; evaluates unused point IDs without trimming. Tentative match identity and catalogue scale '
               'remain unverified; source depth, floor planarity and physical collision acceptance are separate gates.')
    path.write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(rows,indent=2))
