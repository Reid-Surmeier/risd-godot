"""North-wall spacing from the verified Taking of Peter panel, not point clouds.
Run with system Python from the application folder. Hand picks and support-plane
uncertainty remain explicit; neither these metres nor the whole room are accepted.
"""
from pathlib import Path
import cv2,numpy as np,json,hashlib
from PIL import Image,ImageDraw
app=Path(__file__).resolve().parent
root=Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
rows=[]
for name,path,corners,corner,magdalene,projection,role in [
 ('85.75',root/'medieval-panel-native-v1/panel-85.75.png',[[552,783],[738,779],[733,917],[553,910]],[258,900],[398,843],[899,900],'fit'),
 ('86.75',root/'medieval-panel-native-v1/panel-86.75.png',[[562,776],[718,775],[717,891],[565,882]],[300,880],[430,830],[862,880],'cross-check'),
 ('87.25',root/'medieval-wall-native-v1/medieval-87.25.png',[[295,788],[442,791],[441,895],[296,888]],None,[146,836],None,'held-out relative-spacing check')]:
 image=Image.open(path).convert('RGB');draw=ImageDraw.Draw(image)
 target=np.float32([[0,0],[.54,0],[.54,.387],[0,.387]])
 H=cv2.getPerspectiveTransform(np.float32(corners),target)
 def point(q):return cv2.perspectiveTransform(np.float32([[q]]),H)[0,0].tolist()
 exact=cv2.perspectiveTransform(np.float32([corners]),H)[0]
 assert np.max(np.abs(exact-target))<1e-5
 sample={'seconds':name,'role':role,'source':str(path),'source_sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'peter_corners_px':corners,'magdalene_centre_px':magdalene,'peter_to_magdalene_horizontal_m':.27-point(magdalene)[0]}
 if corner:
  sample.update(corner_px=corner,projection_edge_px=projection,peter_centre_from_west_corner_m=.27-point(corner)[0],projection_edge_from_corner_m=point(projection)[0]-point(corner)[0])
 draw.polygon([tuple(q) for q in corners],outline='lime',width=3)
 for title,q in [('corner',corner),('Magdalene centre',magdalene),('projection edge',projection)]:
  if q:
   x,y=q;draw.ellipse((x-5,y-5,x+5,y+5),outline='cyan',width=2);draw.text((x+8,y),title,fill='cyan')
 image.thumbnail((540,960));image.save(app/'inventory-references'/f'medieval-fit-{name}.png');rows.append(sample)
# ponytail: planar local ruler; unknown support offsets and blurred picks prevent room-scale acceptance.
result={'anchor_accession':'22.047','anchor_size_m':[.54,.387],'method':'Hand-annotated planar original panel; inverse homography. No point cloud product. Corner/display coordinates assume the same wall plane and are not a calibrated floor reconstruction.','rows':rows,'accepted':False,'authored_peter_centre_m':[2.00,1.55,28.30],'authored_west_wall_x_m':.55,'uncertainty':'Roughly10-20px edge/centre uncertainty plus nonplanar mounts; taking-image border may include support. Held-out87.25 is blurred. Frame and room heights unverified.'}
(app/'medieval-panel-source-fit.json').write_text(json.dumps(result,indent=2)+'\n')
for row in rows:print(row['seconds'],{k:round(v,3) for k,v in row.items() if k.endswith('_m')})
