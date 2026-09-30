"""Inspect only source cameras; never load reserved tracks or predictions."""
import hashlib,json,sys
from pathlib import Path
import numpy as np
import pycolmap
from PIL import Image,ImageDraw
sys.path.insert(0,'modules/shell/prototype/collection_reconstruction')
from measurements import upright,triangulate,project
root=Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
out=Path(__file__).parent
source=root/'sfm-strict-doorway-v1/sparse/0'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
pins={p.name:sha(p) for p in source.glob('*.bin')}
model=pycolmap.Reconstruction(source)
names=['IMG_6380_exit6fps/000013.jpg','IMG_6380_exit6fps/000019.jpg']
views={v.name:v for v in model.images.values() if v.name in names}
polygons={names[0]:[(50,820),(430,745),(650,1180),(600,1279),(20,1279)],
 names[1]:[(150,920),(560,890),(700,1279),(120,1279)]}
tracks={}
for n in names:
 mask=Image.new('1',(720,1280));ImageDraw.Draw(mask).polygon(polygons[n],fill=1)
 tracks[n]={int(p.point3D_id):upright(p.xy) for p in views[n].points2D if p.has_point3D()
  and 0<=upright(p.xy)[0]<720 and 0<=upright(p.xy)[1]<1280
  and mask.getpixel(tuple(np.rint(upright(p.xy)).astype(int)))}
ids=sorted(set(tracks[names[0]])&set(tracks[names[1]]))
cameras={n:model.cameras[views[n].camera_id] for n in names}
poses={n:views[n].cam_from_world() for n in names}
rows=[]
for i in ids:
 picks={n:tracks[n][i] for n in names}
 point,angle=triangulate(cameras,poses,picks)
 errors={n:float(np.linalg.norm(project(cameras[n],poses[n],point[None])[0]-p)) for n,p in picks.items()}
 assert np.isfinite(point).all()
 rows.append(dict(point_id=i,source_pixels={n:p.tolist() for n,p in picks.items()},point_world=point.tolist(),ray_angle_degrees=angle,training_errors_px=errors))
for n,photo in zip(names,['01.png','02.png']):
 path=root/'strict-threshold-native-v1'/photo
 image=Image.open(path).transpose(Image.Transpose.ROTATE_270).convert('RGB')
 draw=ImageDraw.Draw(image)
 draw.line([tuple(np.array(p)*1.5) for p in polygons[n]+[polygons[n][0]]],fill='yellow',width=3)
 for row in rows:
  x,y=np.array(row['source_pixels'][n])*1.5
  draw.ellipse((x-7,y-7,x+7,y+7),outline='lime',width=2)
  draw.text((x+9,y-8),str(row['point_id']),fill='red',stroke_width=1,stroke_fill='white')
 draw.rectangle((0,0,1080,50),fill='black');draw.text((10,10),n+' SOURCE ONLY floor candidates; no acceptance',fill='white')
 image.save(out/(Path(n).stem+'-source-floor.png'))
assert pins=={p.name:sha(p) for p in source.glob('*.bin')}
report=dict(training=names,source_sha256=pins,polygons_upright=polygons,candidates=rows,navigation_accepted=False,cost_usd=0,
 caveat='Source masks frozen before reserved inspection; global cameras and same-video tracks are correlated. Wood identities need visual verification.')
(out/'source-floor-candidates.json').write_text(json.dumps(report,indent=2)+'\n')
print('Shared source floor candidates:',len(rows))
print([(r['point_id'],r['ray_angle_degrees']) for r in rows])
