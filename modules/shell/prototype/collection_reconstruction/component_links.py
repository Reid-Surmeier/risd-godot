"""Audit shared-track similarity fits; never join components on camera proximity."""
import json
import pathlib
import sys

import numpy as np
import pycolmap

root=pathlib.Path(sys.argv[1])
models={int(p.name):pycolmap.Reconstruction(p) for p in (root/'sparse').iterdir() if p.is_dir() and p.name.isdigit()}
tracks={i:{(e.image_id,e.point2D_idx):pid for pid,p in m.points3D.items() for e in p.track.elements} for i,m in models.items()}
results=[]
for i in sorted(models):
    for j in sorted(models):
        if j>=i:continue
        pairs=sorted({(tracks[i][k],tracks[j][k]) for k in tracks[i].keys()&tracks[j].keys()})
        if len(pairs)<20:continue
        a=np.array([models[i].points3D[x].xyz for x,y in pairs])
        b=np.array([models[j].points3D[y].xyz for x,y in pairs])
        radius=np.percentile(np.linalg.norm(b-np.median(b,axis=0),axis=1),90)
        assert radius>0
        holdout=np.arange(len(a))%5==0
        opts=pycolmap.RANSACOptions();opts.max_error=radius*.02;opts.random_seed=182
        fit=pycolmap.estimate_sim3d_robust(a[~holdout],b[~holdout],opts)
        row=dict(source=i,target=j,shared_points=len(a),accepted=False)
        if fit is not None:
            transform=fit['tgt_from_src']
            errors=np.linalg.norm(transform*a-b,axis=1)
            good=errors<opts.max_error
            spread=np.linalg.svd(b[good]-np.mean(b[good],axis=0),compute_uv=False)
            train=float(good[~holdout].mean());test=float(good[holdout].mean())
            row.update(train_inlier_fraction=train,heldout_inlier_fraction=test,
                median_relative_error=float(np.median(errors)/radius),
                heldout_p90_relative_error=float(np.percentile(errors[holdout],90)/radius),
                scale=float(transform.scale),rotation=transform.rotation.matrix().tolist(),
                translation=transform.translation.tolist(),
                accepted=bool(len(a)>=50 and train>=.8 and test>=.8 and spread[1]/spread[0]>.1))
        results.append(row)
(root/'component-links.json').write_text(json.dumps(results,indent=2))
print(json.dumps(results,indent=2))
# The installed wheel returns a dict despite its Sim3d docstring. Check direction too.
x=np.random.default_rng(182).normal(size=(30,3));y=x*2+np.array([1,2,3])
test=pycolmap.estimate_sim3d_robust(x,y)['tgt_from_src']
assert np.max(np.abs(test*x-y))<1e-8
