"""Cross-localize doorway photographs in a frozen component; no invented joins."""
import argparse
import collections
import json
import pathlib
import numpy as np
import pycolmap

parser=argparse.ArgumentParser()
parser.add_argument('--source-run',default='sfm-connected-v4')
parser.add_argument('--component',default='5')
args=parser.parse_args()
base=pathlib.Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
root=base/args.source_run
source=pycolmap.Reconstruction(root/'sparse'/args.component)
target=pycolmap.Reconstruction(base/'sfm-connected-v4/sparse/0')
results=[]
with pycolmap.Database.open(root/'database.db') as db:
    for q in sorted(source.images.values(),key=lambda x:x.name):
        if not q.name.startswith(('IMG_6380/','IMG_6380_exit6fps/')):continue
        if q.name.startswith('IMG_6380/') and int(pathlib.Path(q.name).stem)<490:continue
        if q.image_id in target.images:continue
        candidates=collections.defaultdict(collections.Counter)
        for ref in target.images.values():
            for a,b in db.read_two_view_geometry(q.image_id,ref.image_id).inlier_matches:
                point=ref.points2D[int(b)]
                if point.has_point3D():candidates[int(a)][point.point3D_id]+=1
        ids=sorted(candidates)
        row=dict(image=q.name,correspondences=len(ids),supported=False)
        if len(ids)>=20:
            xy=db.read_keypoints(q.image_id)[ids,:2].astype(float)
            xyz=np.array([target.points3D[candidates[i].most_common(1)[0][0]].xyz for i in ids])
            camera=pycolmap.Camera(source.cameras[q.camera_id].todict())
            options=pycolmap.AbsolutePoseEstimationOptions();options.ransac.max_error=4.;options.ransac.random_seed=182
            pose=pycolmap.estimate_and_refine_absolute_pose(xy,xyz,camera,estimation_options=options)
            if pose:
                mask=pose['inlier_mask'];error=np.linalg.norm(camera.img_from_cam(pose['cam_from_world']*xyz)-xy,axis=1)[mask]
                row.update(inliers=int(pose['num_inliers']),fraction=float(np.mean(mask)),median_error_px=float(np.median(error)),
                    supported=bool(pose['num_inliers']>=30 and np.mean(mask)>=.25),
                    target_camera_center=pose['cam_from_world'].inverse().translation.tolist(),
                    source_camera_center=q.projection_center().tolist(),
                    target_rotation=pose['cam_from_world'].rotation.matrix().tolist(),
                    source_rotation=q.cam_from_world().rotation.matrix().tolist())
        results.append(row)
(root/'doorway-localization.json').write_text(json.dumps(results,indent=2))
print(json.dumps([{k:v for k,v in r.items() if not isinstance(v,list)} for r in results],indent=2))

# Two common cameras give a tentative transform, but it must also predict other photographs.
shared=sorted([(i,target.images[i.image_id]) for i in source.images.values() if i.image_id in target.images],key=lambda pair:pair[0].name)
assert len(shared)>=2
u,_,vt=np.linalg.svd(sum(b.cam_from_world().rotation.matrix().T@a.cam_from_world().rotation.matrix() for a,b in shared))
rotation=u@vt
x=np.array([a.projection_center() for a,b in shared]);y=np.array([b.projection_center() for a,b in shared])
xc=x-x.mean(0);yc=y-y.mean(0);scale=float(np.sum((xc@rotation.T)*yc)/np.sum(xc*xc))
translation=y.mean(0)-scale*rotation@x.mean(0)
validation=[]
with pycolmap.Database.open(root/'database.db') as db:
    for row in results:
        if row['correspondences']==0:continue
        q=next(i for i in source.images.values() if i.name==row['image'])
        observations={}
        for ref in target.images.values():
            for aa,bb in db.read_two_view_geometry(q.image_id,ref.image_id).inlier_matches:
                point=ref.points2D[int(bb)]
                if point.has_point3D():observations[int(aa)]=point.point3D_id
        ids=sorted(observations);xy=db.read_keypoints(q.image_id)[ids,:2]
        xyz=np.array([target.points3D[observations[i]].xyz for i in ids]);xyz=(xyz-translation)@rotation/scale
        projected=source.cameras[q.camera_id].img_from_cam(q.cam_from_world()*xyz)
        errors=np.linalg.norm(projected-xy,axis=1)
        validation.append(dict(image=q.name,points=len(ids),median_px=float(np.median(errors)),p90_px=float(np.percentile(errors,90)),below4px=int((errors<4).sum())))
count=sum(v['points'] for v in validation);passed=sum(v['below4px'] for v in validation)
report=dict(shared_images=[a.name for a,b in shared],scale=scale,rotation=rotation.tolist(),translation=translation.tolist(),validation=validation,
    supported=bool(count>=50 and passed/count>=.8),reason='Require at least 50 cross-view points and 80 percent below four pixels before treating this as a candidate join; navigation remains separate.')
(root/'doorway-alignment.json').write_text(json.dumps(report,indent=2))
print('Doorway candidate',report['supported'],passed,'/',count,'below 4px')
