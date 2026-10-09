"""Fit doorway alignment on selected localized cameras; reserve three views for checking."""
import json,pathlib,numpy as np,pycolmap
root=pathlib.Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion');run=root/'sfm-doorway-v1'
a=pycolmap.Reconstruction(run/'sparse/0');b=pycolmap.Reconstruction(root/'sfm-connected-v4/sparse/0')
rows=[r for r in json.loads((run/'doorway-localization.json').read_text()) if r['supported']]
train=rows[::2];holdout=rows[1::2]
rotations=[np.array(r['target_rotation']).T@np.array(r['source_rotation']) for r in train]
x=[r['source_camera_center'] for r in train];y=[r['target_camera_center'] for r in train]
for im in a.images.values():
 if im.image_id in b.images:
  other=b.images[im.image_id];rotations.append(other.cam_from_world().rotation.matrix().T@im.cam_from_world().rotation.matrix());x.append(im.projection_center());y.append(other.projection_center())
u,_,vt=np.linalg.svd(sum(rotations));rot=u@vt;x=np.array(x);y=np.array(y);xc=x-x.mean(0);yc=y-y.mean(0);scale=np.sum((xc@rot.T)*yc)/np.sum(xc*xc);t=y.mean(0)-scale*rot@x.mean(0)
validation=[]
with pycolmap.Database.open(run/'database.db') as db:
 for row in holdout:
  q=next(i for i in a.images.values() if i.name==row['image']);matches={}
  for ref in b.images.values():
   for aa,bb in db.read_two_view_geometry(q.image_id,ref.image_id).inlier_matches:
    p=ref.points2D[int(bb)]
    if p.has_point3D():matches[int(aa)]=p.point3D_id
  ids=sorted(matches);xy=db.read_keypoints(q.image_id)[ids,:2];xyz=np.array([b.points3D[matches[i]].xyz for i in ids]);xyz=(xyz-t)@rot/scale
  errors=np.linalg.norm(a.cameras[q.camera_id].img_from_cam(q.cam_from_world()*xyz)-xy,axis=1)
  validation.append(dict(image=q.name,points=len(ids),below4px=int((errors<4).sum()),median_px=float(np.median(errors)),p90_px=float(np.percentile(errors,90))))
result=dict(source='sfm-doorway-v1/sparse/0',target='sfm-connected-v4/sparse/0',train=[r['image'] for r in train],scale=float(scale),rotation=rot.tolist(),translation=t.tolist(),validation=validation,passes_alignment_gate=bool(sum(v['points'] for v in validation)>=50 and sum(v['below4px'] for v in validation)/sum(v['points'] for v in validation)>=.8),caveat='Local doorway alignment only, not full-map or navigation acceptance.')
(run/'refined-alignment.json').write_text(json.dumps(result,indent=2));print(json.dumps(result,indent=2))

# Recover the seed coordinate system before applying its separately fitted catalogue scale.
seed=pycolmap.Reconstruction(root/'sfm-connected-v4/sparse/5')
def tracks(model):
 return {(e.image_id,e.point2D_idx):pid for pid,p in model.points3D.items() for e in p.track.elements}
left=tracks(a);right=tracks(seed)
pairs=sorted({(left[k],right[k]) for k in left.keys()&right.keys()})
src=np.array([a.points3D[i].xyz for i,j in pairs]);dst=np.array([seed.points3D[j].xyz for i,j in pairs])
options=pycolmap.RANSACOptions();options.max_error=.05;options.random_seed=182
fit=pycolmap.estimate_sim3d_robust(src,dst,options);assert fit is not None
tform=fit['tgt_from_src'];errors=np.linalg.norm(tform*src-dst,axis=1)
seed_result=dict(source='sfm-doorway-v1/sparse/0',target='sfm-connected-v4/sparse/5',scale=float(tform.scale),rotation=tform.rotation.matrix().tolist(),translation=tform.translation.tolist(),
 shared_points=len(pairs),inlier_fraction=float(np.mean(errors<.05)),median_error=float(np.median(errors)),p90_error=float(np.percentile(errors,90)))
assert seed_result['inlier_fraction']>.9
(run/'seed-alignment.json').write_text(json.dumps(seed_result,indent=2));print(json.dumps(seed_result,indent=2))

# Nearby camera poses can predict images while leaving scale poorly conditioned.
import itertools
scales=[]
for subset in itertools.combinations(rows,3):
    rots=[np.array(v['target_rotation']).T@np.array(v['source_rotation']) for v in subset]
    src=[v['source_camera_center'] for v in subset];dst=[v['target_camera_center'] for v in subset]
    for q in a.images.values():
        if q.image_id in b.images:
            other=b.images[q.image_id];rots.append(other.cam_from_world().rotation.matrix().T@q.cam_from_world().rotation.matrix());src.append(q.projection_center());dst.append(other.projection_center())
    u,_,vt=np.linalg.svd(sum(rots));r=u@vt
    x=np.array(src);y=np.array(dst);x-=x.mean(0);y-=y.mean(0)
    scales.append(float(np.sum((x@r.T)*y)/np.sum(x*x)))
interval=np.percentile(scales,[10,90]);spread=float(np.ptp(interval)/np.median(scales))
result['scale_stability']=dict(triplets=len(scales),p10_p90=interval.tolist(),relative_spread=spread)
result['passes_image_gate']=result.pop('passes_alignment_gate')
result['passes_alignment_gate']=bool(result['passes_image_gate'] and spread<.1)
result['caveat']='Reject despite a local image fit when scale varies by more than 10 percent across camera triplets. No map join accepted.'
(run/'refined-alignment.json').write_text(json.dumps(result,indent=2))
print('Stable alignment gate',result['passes_alignment_gate'],'scale spread',spread)
