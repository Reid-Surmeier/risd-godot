"""#182 evaluate a frozen source floor against a different, pose-supported capture."""
import argparse
import collections
import hashlib
import json
from pathlib import Path
import shutil

import numpy as np
import pycolmap
from PIL import Image, ImageDraw
from measurements import project, upright

ROOT=Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
parser=argparse.ArgumentParser()
parser.add_argument('--output',default='capture-floor-check-v1')
args=parser.parse_args()
OUT=ROOT/args.output
OUT.mkdir(exist_ok=False)
geometry_path=ROOT/'room-route-walk-v4/geometry.json'
pose_path=ROOT/'sfm-capture-split-v1/capture-validation.json'
geometry=json.loads(geometry_path.read_text());pose_report=json.loads(pose_path.read_text())
assert pose_report['whole_capture_excluded_from_mapping']
model=pycolmap.Reconstruction(ROOT/'sfm-capture-split-v1/sparse/0')
assert all(v.name.startswith('IMG_6380/') for v in model.images.values())
inputs=[geometry_path,pose_path,*(ROOT/'sfm-capture-split-v1/sparse/0').glob('*.bin')]
pins={str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in inputs}
up=np.array(geometry['basis_rows'])[1];origin=np.array(geometry['floor_origin_world'])
floor_ids={int(i) for i in geometry['floor']['candidate_point_ids'] if i%2==0}
assert len(floor_ids)>=30
shutil.copyfile(ROOT/'sfm-capture-split-v1/validation.db',OUT/'database.db')
rows=[]
with pycolmap.Database.open(OUT/'database.db') as db:
    records={v.name:v for v in db.read_all_images()}
    for row in pose_report['rows']:
        if not row['supported']:continue
        name=row['image'];query=records[name]
        matches=collections.defaultdict(collections.Counter)
        for ref in model.images.values():
            for a,b in db.read_matches(query.image_id,ref.image_id):
                p=ref.points2D[int(b)]
                if p.has_point3D() and p.point3D_id in floor_ids:matches[int(a)][p.point3D_id]+=1
        keypoints=db.read_keypoints(query.image_id)[:,:2].astype(float)
        # A query feature can match both odd and even source IDs. Exclude the entire pose-fit region.
        ids=[i for i in sorted(matches) if keypoints[i,0]>=pose_report['upper_pose_cutoff']]
        pids=[matches[i].most_common(1)[0][0] for i in ids]
        xy=keypoints[ids]
        assert not len(xy) or np.all(xy[:,0]>=pose_report['upper_pose_cutoff'])
        camera=pycolmap.Camera(row['camera']);matrix=np.array(row['cam_from_world'])
        pose=pycolmap.Rigid3d(pycolmap.Rotation3d(matrix[:,:3]),matrix[:,3])
        report=dict(image=name,tentative_candidates=len(matches),excluded_upper_query_features=len(matches)-len(ids),floor_matches=len(ids),unique_source_points=len(set(pids)),
            independent_capture=True,all_floor_ids_even=True,floor_accepted=False,controls=[])
        if ids:
            xyz=np.array([model.points3D[i].xyz for i in pids])
            plane=xyz-((xyz-origin)@up)[:,None]*up
            assert max(abs((plane-origin)@up))<1e-8 and all(i%2==0 for i in pids)
            for offset in [0.,-.10,.10]:
                points=plane+up*(offset/geometry['scale_m_per_unit'])
                errors=np.linalg.norm(project(camera,pose,points)-upright(xy),axis=1)
                report['controls'].append(dict(offset_provisional_m=offset,errors_px=errors.tolist(),
                    p50_p90_px=np.percentile(errors,[50,90]).tolist(),fraction_below8px=float((errors<=8).mean())))
            im=Image.open(ROOT/'survey-2fps'/name).transpose(Image.Transpose.ROTATE_270)
            draw=ImageDraw.Draw(im)
            for observed,predicted in zip(upright(xy),project(camera,pose,plane)):
                x,y=observed;draw.ellipse((x-5,y-5,x+5,y+5),outline='lime',width=2)
                draw.line((x,y,*predicted),fill='red',width=2)
            draw.rectangle((0,0,720,50),fill='black')
            draw.text((8,6),name+' different capture / frozen source floor',fill='white')
            draw.text((8,27),'Lower unused-query matches retained; no physical acceptance.',fill='white')
            im.save(OUT/(Path(name).stem+'.png'))
        rows.append(report)
assert all(hashlib.sha256(Path(p).read_bytes()).hexdigest()==h for p,h in pins.items())
report=dict(rows=rows,inputs_sha256=pins,physical_floor_accepted=False,cost_usd=0,
    caveat='Floor fitted to odd source-only wood points; even floor IDs never enter query pose. '
           'All lower-query floor correspondences retained; upper query features excluded wholesale to prevent reuse of pose-fit pixels. Repeated wood can mismatch. '
           'Plane controls are fixed +/-10 provisional cm, not refits. Insufficient coverage or '
           'large residuals do not authorize a flat collision floor. Source scale remains provisional.')
(OUT/'result.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(rows,indent=2))
