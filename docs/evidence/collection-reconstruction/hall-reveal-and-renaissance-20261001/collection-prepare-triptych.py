from pathlib import Path
import json,hashlib,datetime
from PIL import Image
root=Path('/home/reidsurmeier/orca/workspaces/risd-godot/collection-reconstruction');app=root/'image-work/collection-room-remodel';src=root/'docs/evidence/collection-reconstruction/opus-renaissance-case-inventory-20261001/photos'
front=src/'madonna-enthroned-saints-and-angels-2021131-zoom-0.jpg';back=src/'madonna-enthroned-saints-and-angels-2021131-zoom-1.jpg'
assert Image.open(front).size==(1324,1107) and Image.open(back).size==(1324,1107)
# Pixel contours from inspected source photographs; no generated replacement for the paintings.
shapes=[('left',[(168,1030),(395,1020),(393,425),(178,122)],[(931,1030),(1118,1014),(1118,140),(931,424)]),('centre',[(396,1020),(909,1020),(909,427),(651,62),(396,427)],[(397,1030),(918,1030),(919,417),(658,45),(397,417)]),('right',[(912,1020),(1155,1034),(1148,115),(914,428)],[(173,1014),(393,1030),(393,417),(169,143)])]
record={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'accession':'2021.131','catalogue_url':'https://risdmuseum.org/art-design/collection/madonna-enthroned-saints-and-angels-2021131','catalogue_height_width_m':[.67,.725],'source_photograph_sha256':{str(p.relative_to(root)):hashlib.sha256(p.read_bytes()).hexdigest() for p in [front,back]},'source_video':'verified/IMG_6383.MOV','source_seconds':[30.2,63.9,71.9],'source_rear_observed':True,'depth_m_provisional':.018,'side_angle_radians_provisional':.20,'panel_proportions_accepted':False,'placement_accepted':False,'fine_frame_fidelity_accepted':False,'paid_calls':0,'panels':[]}
for name,poly,rear in shapes:
 x0=min(p[0] for p in poly);x1=max(p[0] for p in poly);y0=min(p[1] for p in poly);y1=max(p[1] for p in poly)
 bx0=min(p[0] for p in rear);bx1=max(p[0] for p in rear);by0=min(p[1] for p in rear);by1=max(p[1] for p in rear)
 for side,img,box in [('front',front,(x0,y0,x1,y1)),('back',back,(bx0,by0,bx1,by1))]:
  target=app/'trial'/f'triptych-2021131-{name}-{side}.png';assert not target.exists();Image.open(img).crop(box).save(target)
 # Source-projected proportions fix overall height and the open photograph's span; wing angles/depth remain guesses.
 w=(x1-x0)/987*.725;h=(y1-y0)/972*.67
 record['panels'].append({'id':name,'size_m':[w,h],'centre_x_m':((x0+x1)/2-661.5)/987*.725,'base_y_m':(1034-y1)/972*.67,'outline':[[ (x-x0)/(x1-x0),(y-y0)/(y1-y0)] for x,y in poly],'front':f'triptych-2021131-{name}-front.png','back':f'triptych-2021131-{name}-back.png','source_polygon_px':poly,'rear_crop_px':[bx0,by0,bx1,by1]})
(app/'triptych-2021131-geometry.json').write_text(json.dumps(record,indent=2)+'\n')
print('Three source-panel crops plus actual observed rear; no paid call; provisional angles/depth')
