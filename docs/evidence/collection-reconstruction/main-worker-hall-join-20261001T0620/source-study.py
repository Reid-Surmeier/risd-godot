from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,json,hashlib,shutil,tarfile
repo=Path.cwd();app=repo/'image-work/collection-room-remodel';e=repo/'docs/evidence/collection-reconstruction/main-worker-hall-join-20261001T0620';e.mkdir(exist_ok=True)
root=Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion');sources={}
for folder,prefix,times in [('renaissance-width-native-v1','renaissance',['35.75','63.75','64.75']),('hall-wide-native-v1','hall',['22.50','65.00','177.50'])]:
 d=root/folder;shutil.copyfile(d/'manifest.json',e/(prefix+'-native-manifest.json'))
 for sec in times:
  src=d/f'{prefix}-{sec}.png';dst=e/('source-'+src.name);shutil.copyfile(src,dst);sources[src.name]=hashlib.sha256(src.read_bytes()).hexdigest()
points={'63.75':{'painting_xy':[[906,718],[996,708],[995,841],[905,842]],'door_xy':[[315,577],[715,563],[698,1108],[320,1095]]},'64.75':{'painting_xy':[[494,774],[563,773],[568,876],[497,881]],'right_jamb_xy':[[290,649],[327,1160]]}}
rows={}
for sec,row in points.items():
 p=np.array(row['painting_xy'],dtype=float);target=np.array([[0,.575],[.391,.575],[.391,0],[0,0]])
 A=np.linalg.lstsq(np.c_[p,np.ones(4)],target,rcond=None)[0]
 door=np.array(row.get('door_xy',row.get('right_jamb_xy')),dtype=float);q=np.c_[door,np.ones(len(door))]@A
 assert np.isfinite(q).all();assert np.linalg.matrix_rank(A)==2
 result={'manual_pixels':row,'whole_panel_assumption_affine_m':q.tolist(),'accepted':False,'limitation':'Weak-perspective extrapolation from small, partly frame-covered panel; these numbers are sensitivity evidence, not calibrated room measurements.'}
 result['right_jamb_height_m']=float(np.linalg.norm(q[-2]-q[1])) if len(q)==4 else float(np.linalg.norm(q[1]-q[0]))
 if len(q)==4:result['door_width_top_m']=float(np.linalg.norm(q[1]-q[0]));assert 1<result['door_width_top_m']<3
 assert 1<result['right_jamb_height_m']<4
 rows[sec]=result
 im=Image.open(e/f'source-renaissance-{sec}.png');draw=ImageDraw.Draw(im)
 for name,color in [('painting_xy','cyan'),('door_xy','red'),('right_jamb_xy','red')]:
  if name in row:
   xy=[tuple(v) for v in row[name]];draw.line(xy+([xy[0]] if len(xy)>2 else []),fill=color,width=5)
   for x,y in xy:draw.ellipse((x-6,y-6,x+6,y+6),fill=color)
 draw.text((15,20),'Manual source features; metric fit unaccepted',fill='white',stroke_width=2,stroke_fill='black');im.save(e/f'annotated-renaissance-{sec}.png')
im=Image.open(e/'source-hall-177.50.png');draw=ImageDraw.Draw(im)
for x,y in [(274,891),(849,891),(548,891)]:draw.ellipse((x-8,y-8,x+8,y+8),fill='cyan')
draw.line((274,891,849,891),fill='cyan',width=4);draw.text((15,20),'End-wall floor corners + door centre; no accepted wall metres',fill='white',stroke_width=2,stroke_fill='black');im.save(e/'annotated-hall-177.50.png')
study={'scope':'Collection wide-angle geometry evidence; no point-cloud products','source_sha256':sources,'renaissance':rows,'decision':'Do not resize the2.0x2.74m opening or shift rooms from this unstable small-panel fit. Perugino source-relative centre1.48/1.55/18.93m installed as a visual reference. Original predicted lower doorway is unproven; paired views disagree.','covered_support':'Official photo includes worn panel edges partly hidden under the frame; visible opening cannot inherit complete57.5x39.1cm support size as an accepted scale.','invalid_sift_wides':{'63.75_inliers':5,'64.75_inliers':6,'reason':'Degenerate near-point quadrilaterals, below15inlier threshold; rejected. Near35.75 match16inliers alone does not validate extrapolated wide geometry.'},'main_hall':{'source':'IMG_6344 177.50s','floor_wall_corners_xy':[[274,891],[849,891]],'door_centre_xy':[548,891],'fraction_across_end_wall':(548-274)/(849-274),'observation':'Near-centred doorway; offset-end-door workaround contradicted by clear wide source.','accepted_metres':False,'unresolved':'Current grey and medieval Hall entry lateral4.60m/axial17.05m conflict requires coupled room fitting; no fabricated connector or new side door.'},'implemented':'Source-relative Perugino frame/authentic panel, neutral Renaissance walls/fill and shallow vent; global layout remains provisional.'}
assert abs(study['main_hall']['fraction_across_end_wall']-.5)<.05
(e/'wide-source-study.json').write_text(json.dumps(study,indent=2)+'\n');(app/'renaissance-wide-source-study.json').write_text(json.dumps(study,indent=2)+'\n')
shutil.copyfile(__file__,e/'source-study.py')
run=app/'artifacts/image-generation/runs/run-f55959297094d15b07761914'
with tarfile.open(e/'muse-perugino-run.tar.gz','w:gz') as archive:archive.add(run,arcname=run.name)
print('Saved source annotations, rejected geometry estimates and one full Muse run. Door sizes',[(k,v['right_jamb_height_m']) for k,v in rows.items()])
