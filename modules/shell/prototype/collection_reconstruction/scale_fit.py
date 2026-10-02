"""Fit catalogue canvas dimensions to frozen measured components, with GPU matches."""
import json
import argparse
import pathlib
import shutil

import numpy as np
import pycolmap
from PIL import Image, ImageDraw

ROOT = pathlib.Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
parser = argparse.ArgumentParser()
parser.add_argument('--source', default='sfm-galleries-v3')
parser.add_argument('--output', default='scale-fit-v1')
parser.add_argument('--anchor', default='anchors/painting-0.jpg')
parser.add_argument('--width', type=float, default=.651)
parser.add_argument('--height', type=float, default=.541)
parser.add_argument('--bounds', type=float, nargs=4, help='Object pixel bounds x0 y0 x1 y1 in catalogue photo')
args = parser.parse_args()
source = ROOT/args.source
out = ROOT/args.output
out.mkdir(exist_ok=True)
database = out/'database.db'
if not database.exists():
    shutil.copyfile(source/'database.db', database)
images = out/'images'
(images/'anchor').mkdir(parents=True, exist_ok=True)
anchor_name='anchor/'+pathlib.Path(args.anchor).name
anchor = images/anchor_name
if not anchor.exists():
    anchor.symlink_to(ROOT/args.anchor)
extract = pycolmap.FeatureExtractionOptions(); extract.gpu_index='0'; extract.num_threads=8
pycolmap.extract_features(database, images, extraction_options=extract, device=pycolmap.Device.cuda)
models = {p.name:pycolmap.Reconstruction(p) for p in (source/'sparse').iterdir()
          if p.is_dir() and p.name.isdigit()}
refs = {im.name for model in models.values() for im in model.images.values() if im.has_pose}
pairs = out/'pairs.txt'
pairs.write_text(''.join(f'{anchor_name} {name}\n' for name in sorted(refs)))
matching=pycolmap.FeatureMatchingOptions();matching.gpu_index='0';matching.num_threads=8
pycolmap.match_image_pairs(database, matching_options=matching,
                          pairing_options=pycolmap.ImportedPairingOptions(match_list_path=pairs),
                          device=pycolmap.Device.cuda)
width,height = Image.open(anchor).size
x0,y0,x1,y1=args.bounds or [0,0,width-1,height-1]
assert 0<=x0<x1<=width and 0<=y0<y1<=height and args.width>0 and args.height>0
corners = np.array([[x0,y0,1],[x1,y0,1],[x1,y1,1],[x0,y1,1]],float)
result=[]
with pycolmap.Database.open(database) as db:
    by_name = {im.name:im for im in db.read_all_images()}
    aid=by_name[anchor_name].image_id
    ak=db.read_keypoints(aid)[:,:2].astype(float)
    for mid,model in models.items():
        views=[]
        for im in model.images.values():
            if not im.has_pose: continue
            pairs2=db.read_matches(aid,im.image_id)
            if len(pairs2)<20:continue
            vk=db.read_keypoints(im.image_id)[:,:2].astype(float)
            opts=pycolmap.RANSACOptions();opts.max_error=3.;opts.random_seed=182
            hom=pycolmap.estimate_homography_matrix(ak[pairs2[:,0]],vk[pairs2[:,1]],opts)
            if hom is None or hom['num_inliers']<20:continue
            good=pairs2[hom['inlier_mask']]
            ids={im.points2D[int(b)].point3D_id for a,b in good if im.points2D[int(b)].has_point3D()}
            if len(ids)<15:continue
            xyz=np.array([model.points3D[i].xyz for i in ids]);center=np.median(xyz,axis=0)
            _,_,axes=np.linalg.svd(xyz-center,full_matrices=False);normal=axes[-1]
            distances=np.abs((xyz-center)@normal)
            limit=max(np.median(distances)*3, .001)
            fit=xyz[distances<limit]
            if len(fit)<15:continue
            center=fit.mean(axis=0);_,_,axes=np.linalg.svd(fit-center,full_matrices=False);normal=axes[-1]
            pixel=corners@hom['H'].T;pixel=pixel[:,:2]/pixel[:,2:]
            cam=model.cameras[im.camera_id]
            rays=np.c_[cam.cam_from_img(pixel),np.ones(4)]@im.cam_from_world().rotation.matrix()
            origin=im.projection_center();den=rays@normal
            if np.min(np.abs(den))<.05:continue
            depth=((center-origin)@normal)/den
            if np.any(depth<=0):continue
            quad=origin+rays*depth[:,None]
            w=(np.linalg.norm(quad[1]-quad[0])+np.linalg.norm(quad[2]-quad[3]))/2
            h=(np.linalg.norm(quad[3]-quad[0])+np.linalg.norm(quad[2]-quad[1]))/2
            sx,sy=args.width/w,args.height/h
            discrepancy=abs(sx-sy)/((sx+sy)/2)
            views.append(dict(image=im.name,homography_inliers=int(hom['num_inliers']),
                              plane_points=len(fit),pixel_corners=pixel.tolist(),
                              corners_3d=quad.tolist(),width_units=w,height_units=h,
                              scale_from_width=sx,scale_from_height=sy,
                              axis_disagreement=discrepancy,supported=bool(discrepancy<.05)))
        accepted=[v for v in views if v['supported']]
        entry=dict(component=mid,anchor=args.anchor,dimensions_m=[args.width,args.height],pixel_bounds=[x0,y0,x1,y1],views=views,accepted_views=len(accepted))
        if accepted:
            scales=np.array([(v['scale_from_width']+v['scale_from_height'])/2 for v in accepted])
            quad=np.median([v['corners_3d'] for v in accepted],axis=0)
            right=quad[1]-quad[0]+quad[2]-quad[3];right/=np.linalg.norm(right)
            up=quad[0]-quad[3]+quad[1]-quad[2];up-=right*np.dot(right,up);up/=np.linalg.norm(up)
            normal=np.cross(right,up)
            entry.update(meters_per_unit=float(np.median(scales)),
                         scale_p10_p90=np.percentile(scales,[10,90]).tolist(),
                         origin=quad.mean(axis=0).tolist(),basis_rows=[right.tolist(),up.tolist(),normal.tolist()],
                         caveat='Assumes level/plumb object and catalogue dimensions match the marked extent in its fitted plane; relief/depth and perspective can bias this scale. Independent validation pending.')
            best=max(accepted,key=lambda v:v['plane_points'])
            preview=Image.open(source/'images'/best['image']).convert('RGB');draw=ImageDraw.Draw(preview)
            poly=[tuple(p) for p in best['pixel_corners']];draw.line(poly+[poly[0]],fill='lime',width=4)
            preview.save(out/f'component-{mid}-canvas-fit.jpg')
        result.append(entry)
(out/'result.json').write_text(json.dumps(result,indent=2))
print(json.dumps([{k:v for k,v in r.items() if k!='views'} for r in result],indent=2))
