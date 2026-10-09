"""Visible sculpture surface study. Missing rear stays missing; no watertight-mesh claim."""
import json
import pathlib
import sys
import subprocess
import argparse
import numpy as np

ROOT=pathlib.Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
parser=argparse.ArgumentParser()
parser.add_argument('--source',default='dense-head-v1')
parser.add_argument('--output',default='head-surface-v1')
parser.add_argument('--mesh',action='store_true')
args=parser.parse_args()
OUT=ROOT/args.output;OUT.mkdir(exist_ok=True)
if not args.mesh:
    import pycolmap
    model=pycolmap.Reconstruction(ROOT/'sfm-connected-v4/sparse/11')
    view=next(i for i in model.images.values() if i.name=='IMG_6382/000064.jpg')
    dense=pycolmap.Reconstruction();dense.import_PLY(str(ROOT/args.source/'fused.ply'))
    points=list(dense.points3D.values());world=np.array([p.xyz for p in points])
    camera=view.cam_from_world()*world;pixels=model.cameras[view.camera_id].img_from_cam(camera)
    # Visually selected head ROI and depth interval exclude the pedestal and rear wall.
    keep=(pixels[:,0]>255)&(pixels[:,0]<615)&(pixels[:,1]>255)&(pixels[:,1]<485)&(camera[:,2]>1.48)&(camera[:,2]<1.85)
    np.savez(OUT/'surface.npz',xyz=camera[keep][:,[1,0,2]]*-1,pixels=pixels[keep])
    subprocess.run(['/usr/bin/python3',__file__,*sys.argv[1:],'--mesh'],check=True)
else:
    from scipy.spatial import Delaunay,cKDTree
    data=np.load(OUT/'surface.npz');xyz=data['xyz'];pixels=data['pixels']
    distances=cKDTree(xyz).query(xyz,k=7)[0][:,-1]
    keep=distances<np.percentile(distances,95);xyz=xyz[keep];pixels=pixels[keep]
    # Small CPU triangulation; CUDA already performed feature matching and depth estimation.
    _,ids=np.unique((pixels/5).astype(int),axis=0,return_index=True);xyz=xyz[ids];pixels=pixels[ids]
    scale=.813/np.ptp(xyz[:,1]);xyz=(xyz-(xyz.min(0)+xyz.max(0))/2)*scale
    triangles=Delaunay(pixels).simplices
    good=[]
    for face in triangles:
        p=xyz[face];uv=pixels[face]
        if max(np.linalg.norm(p[i]-p[(i+1)%3]) for i in range(3))>.09:continue
        if max(np.linalg.norm(uv[i]-uv[(i+1)%3]) for i in range(3))>24:continue
        good.append(face.tolist())
    assert len(good)>100 and np.isfinite(xyz).all()
    result=dict(vertices=xyz.tolist(),uv=(pixels/np.array([1280,720])).tolist(),triangles=good)
    (OUT/'surface.json').write_text(json.dumps(result,separators=(',',':')))
    (OUT/'checks.json').write_text(json.dumps(dict(vertices=len(xyz),triangles=len(good),
        source='IMG_6382/000064.jpg',height_m=.813,width_m=float(np.ptp(xyz[:,0])),visible_depth_m=float(np.ptp(xyz[:,2])),
        caveat='Cropped visible front surface scaled to catalogue height. Rear, underside, mount and complete silhouette are absent. Not a finished sculpture.'),indent=2))
    print((OUT/'checks.json').read_text())
