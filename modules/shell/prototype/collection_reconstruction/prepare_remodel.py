"""#182/#183 standalone low polygon room; no point cloud in the render or pack.

Run: /usr/bin/python3 modules/shell/prototype/collection_reconstruction/prepare_remodel.py OUTPUT
Then Godot --path OUTPUT --selfcheck --out=OUTPUT/evidence (arguments after --).
"""
import argparse
import hashlib
import json
from pathlib import Path
import shutil

import cv2
import numpy as np
from PIL import Image

parser = argparse.ArgumentParser()
parser.add_argument('output', type=Path)
args = parser.parse_args()
out = args.output
out.mkdir(parents=True, exist_ok=False)
(out/'assets').mkdir()
(out/'evidence').mkdir()
(out/'web').mkdir()
repo = Path(__file__).resolve().parents[4]
source = Path(__file__).parent
app = repo/'image-work/collection-room-remodel'
ingestion = Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
inputs = {}

def copy(original, relative):
    original = Path(original)
    target = out/relative
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(original, target)
    inputs[str(original)] = hashlib.sha256(original.read_bytes()).hexdigest()

for kind in ['bookcase', 'mirror', 'pair-mirror', 'settee', 'armchair', 'entrance-chair', 'tureen']:
    path = app/'trial'/f'{kind}-original.webp'
    image = np.array(Image.open(path).convert('RGB'))
    hsv = cv2.cvtColor(image, cv2.COLOR_RGB2HSV)
    chroma = (hsv[:,:,0]>=125)&(hsv[:,:,0]<=175)&(hsv[:,:,1]>70)&(hsv[:,:,2]>35)
    alpha = (~chroma).astype('uint8')*255
    assert .1 < np.mean(alpha>0) < .9
    # Transparent texels carry a neutral asset edge tone to prevent magenta mip fringes.
    # Visible source RGB is unchanged; native Muse rasters remain archived intact.
    image[chroma] = [103,64,36] if kind == 'bookcase' else [162,124,55]
    if kind in ['mirror','pair-mirror']:
        contours,_=cv2.findContours(alpha,cv2.RETR_EXTERNAL,cv2.CHAIN_APPROX_SIMPLE)
        x,y,w,h=cv2.boundingRect(max(contours,key=cv2.contourArea))
        image=image[y:y+h,x:x+w];alpha=alpha[y:y+h,x:x+w]
    Image.fromarray(np.dstack([image, alpha])).save(out/'assets'/f'{kind}.png')
    inputs[str(path)] = hashlib.sha256(path.read_bytes()).hexdigest()
    if kind in ['mirror','pair-mirror','armchair','entrance-chair','settee']:
        contours, _ = cv2.findContours(alpha, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        contour = cv2.approxPolyDP(max(contours, key=cv2.contourArea), 3.5, True)[:,0,:]
        assert 20 < len(contour) < 600
        outline = contour/[image.shape[1],image.shape[0]]
        (out/'assets'/f'{kind}-outline.json').write_text(json.dumps(dict(outline=outline.tolist(),
            vertices=len(outline),key='magenta chroma; original RGB unchanged',
            holes='front alpha cut, not physically modeled pierced side walls'),indent=2)+'\n')
    if kind == 'bookcase':
        assert image.shape[:2] == (1760,1440), 'Bookcase authored UV rectangles need a new review for changed raster dimensions'
# Furniture face regions become separate shallow reliefs around modeled seats/arms/legs.
for kind, bounds, real_size, pieces, cloth_rect in [
    ('settee',(120,203,1640,1290),(1.39,.94),[(290,203,1483,768,-.12,.10),(138,777,1610,922,.50,.05),(120,918,282,1290,.51,.045),(785,918,966,1290,.51,.045),(1459,918,1640,1290,.51,.045)],(450,250,1250,600)),
    ('armchair',(284,105,1485,1347),(.82,.93),[(577,105,1193,733,-.06,.035),(438,884,584,1347,.42,.045),(1187,884,1310,1347,.42,.045)],(650,770,1100,820)),
    ('entrance-chair',(397,90,1360,1376),(.68,.94),[(583,90,1194,734,-.06,.035),(448,815,1310,933,.50,.045),(443,918,604,1370,.50,.04),(1145,918,1317,1375,.50,.04),(397,430,620,818,.1,.04),(1158,430,1360,818,.1,.04)],(640,740,1100,790))]:
    native=np.array(Image.open(app/'trial'/f'{kind}-original.webp').convert('RGB'))
    keyed=np.array(Image.open(out/'assets'/f'{kind}.png'))
    assert native.shape[:2]==(1440,1760), 'Furniture UV regions require review for different native pixels'
    x0,y0,x1,y1=bounds; w,h=real_size
    data={'reliefs':[],'hidden_sides':'authored neutral wood / repeated Muse upholstery; rear design unobserved'}
    for i,(a,b,c,d,z,depth) in enumerate(pieces):
        region=keyed[b:d,a:c];alpha=region[:,:,3];contours,_=cv2.findContours(alpha,cv2.RETR_EXTERNAL,cv2.CHAIN_APPROX_SIMPLE)
        contour=cv2.approxPolyDP(max(contours,key=cv2.contourArea),1.5,True)[:,0,:]/[c-a,d-b]
        texture=f'{kind}-part-{i}.png';Image.fromarray(region).save(out/'assets'/texture)
        data['reliefs'].append({'texture':texture,'outline':contour.tolist(),'size':[(c-a)/(x1-x0)*w,(d-b)/(y1-y0)*h],
            'position':[((a+c)/2-(x0+x1)/2)/(x1-x0)*w,(y1-(b+d)/2)/(y1-y0)*h,z],'depth':depth})
    (out/'assets'/f'{kind}-parts.json').write_text(json.dumps(data,indent=2)+'\n')
    a,b,c,d=cloth_rect;cloth=keyed[b:d,a:c]
    assert np.mean(cloth[:,:,3]==0)<.001, 'Upholstery must be sampled inside the cloth, without chroma margins'
    Image.fromarray(cloth[:,:,:3]).save(out/'assets'/f'{kind}-cloth.png')

# Reuse the accepted frame preparation: chroma key, crop, centre-connected white opening.
frame_path=app/'trial/edwards-frame-original.webp'
a=np.array(Image.open(frame_path).convert('RGBA'));hsv=cv2.cvtColor(a[:,:,:3],cv2.COLOR_RGB2HSV)
chroma=(hsv[:,:,0]>=125)&(hsv[:,:,0]<=175)&(hsv[:,:,1]>70)&(hsv[:,:,2]>35)
a[chroma,3]=0;a[chroma,:3]=[162,124,55]
y,x=np.where(a[:,:,3]>0);a=a[y.min():y.max()+1,x.min():x.max()+1]
white=(np.min(a[:,:,:3],axis=2)>245).astype('uint8');count,labels,stats,centers=cv2.connectedComponentsWithStats(white)
h,w=white.shape;label=int(labels[h//2,w//2]);assert label>0
x0,y0,ww,hh=map(int,stats[label,:4]);assert ww>500 and hh>700
Image.fromarray(a).save(out/'assets/edwards-frame.png')
(out/'assets/edwards-frame-geometry.json').write_text(json.dumps({'canvas_m':[.637,.760],'margins_px':[x0,y0,w-x0-ww,h-y0-hh],'opening_aspect':ww/hh,'catalogue_aspect':.637/.760,'profile':'native Muse bands; 9cm inferred depth; aspect corrected by existing nine-slice geometry'},indent=2)+'\n')
copy(app/'catalogue/painting-58.197.jpg','assets/painting-58.197.jpg')
inputs[str(frame_path)]=hashlib.sha256(frame_path.read_bytes()).hexdigest()

geometry = json.loads((ingestion/'room-route-walk-v5/geometry.json').read_text())
geometry['caption'] = 'Collection · WASD move · Space reset · 1/2 room views\nRoom prototype · placements and unfinished objects are provisional.\n'
geometry['point_cloud_render'] = False
geometry['doorway_correction'] = {'upright_source':'IMG_6384/000207.jpg','fixed_casing_pixels':[[20,1025],[460,1150]],'source_floor_local_m':[[-.711604,0,6.918638],[1.233235,0,6.934083]],'plane_z_origin_m':6.92636,'confidence':'floor-ray placement hypothesis, not surveyed; source-side fixed jamb checks disagree by up to 0.7m'}
geometry['patches']=[{'label':'authored room support','color':'81735c','vertices':[[-2.75,0,-7.20],[3.65,0,-7.20],[3.65,0,7],[-2.75,0,7]]}]
geometry['patches'].append({'label':'bounded source-observed right corridor','color':'81735c','vertices':[[3.65,0,-2.8],[5.6,0,-2.8],[5.6,0,-1.2],[3.65,0,-1.2]]})
geometry['boxes']=[]
geometry['start']=[.26,.25,1.2]
geometry['trials']=[['forward',[.26,.25,1.2],[.26,0,-1.2],False],['reverse',[.26,.25,-1.2],[.26,0,1.2],False],['left_blocked',[-.90,.25,.75],[-.90,0,-.5],True],['right_blocked',[1.42,.25,.75],[1.42,0,-.5],True],['decorative_room',[.26,.25,-1.2],[.26,0,-4],False],['painting_gallery',[.26,.25,1.2],[.26,0,4],False]]
geometry['trials'] += [['right_door_out',[3.0,.25,-2.0],[4.8,0,-2.0],False],['right_door_back',[4.8,.25,-2.0],[3.0,0,-2.0],False],['right_wall_blocked',[3.0,.25,-.65],[4.5,0,-.65],True]]
geometry['trial_seconds']=3.5
geometry['room_geometry']='Bookcase wall observed at source z=-0.19, sofa wall x=-2.70; authored enclosing walls remain provisional. No point cloud in renderer.'

(out/'geometry.json').write_text(json.dumps(geometry,indent=2)+'\n')
inputs[str(ingestion/'room-route-walk-v5/geometry.json')] = hashlib.sha256((ingestion/'room-route-walk-v5/geometry.json').read_bytes()).hexdigest()
for name in ['doorway_walk.gd','remodel_room.gd','remodel_review.gd','remodel_presenter.gd','remodel_bake.gd']:
    copy(source/name,name)
visitor_source = repo/'image-work/collection-room-remodel/main-hall-visitor159'
for path in visitor_source.rglob('*'):
    if path.is_file():
        copy(path,'modules/shell/prototype/gallery_walk4/visitor159/'+str(path.relative_to(visitor_source)))
for name in ['painting_asset.gd','ps1.gdshader']:
    copy(app/'main-hall-presentation'/name,'modules/shell/prototype/gallery_walk4/'+name)
for name in ['oak-muse.webp']:
    copy(repo/'modules/shell/prototype/gallery_walk4/textures'/name,'textures/'+name)
copy(app/'trial/sofa-cloth-original.webp','assets/sofa-cloth.webp')
for name in ['floor_oak.gdshader','gamecube.gdshader','crt_luminance.gdshader','squiggle_screen.gdshader','haze_screen.gdshader','page.png','wall-muse.webp','oak-board-atlas-168-v3.webp']:
    copy(app/'main-hall-presentation'/name, 'presentation/'+name)
# This gallery's observed plaster is ivory, while the Main Hall Muse wall is blue-grey.
wall=np.array(Image.open(app/'main-hall-presentation/wall-muse.webp').convert('RGB'),dtype=float)
grain=(wall.mean(axis=2)-wall.mean())*.15
plaster=np.clip(np.array([231,226,217])+grain[:,:,None],0,255).astype('uint8')
Image.fromarray(plaster).save(out/'presentation/wall-plaster.png')
assert np.allclose(plaster.mean((0,1)),[230.5,225.5,216.5],atol=1)
copy(app/'main-hall-presentation/plugin.gd','bake/plugin.gd')
(out/'bake/plugin.cfg').write_text('[plugin]\nname="Collection bake"\ndescription="Reuse Main Hall native LightmapGI editor bake"\nauthor="RISD"\nversion="1"\nscript="plugin.gd"\n')
(out/'modules/shell/prototype/gallery_walk4/baked').mkdir(parents=True,exist_ok=True)
frame = repo/'image-work/collection-expansion-frame'
for name, origin in [('frame.png','trial/frame.png'),('frame-geometry.json','trial/geometry.json'),('painting-35.786.jpg','references/painting-35.786.jpg')]:
    copy(frame/origin,'assets/'+name)
(out/'remodel_room.tscn').write_text('[gd_scene load_steps=2 format=3]\n[ext_resource type="Script" path="res://remodel_room.gd" id="1"]\n[node name="CollectionRemodel" type="Node3D"]\nscript = ExtResource("1")\n')
(out/'remodel_presenter.tscn').write_text('[gd_scene load_steps=2 format=3]\n[ext_resource type="Script" path="res://remodel_presenter.gd" id="1"]\n[node name="CollectionPresentation" type="Control"]\nlayout_mode=3\nanchors_preset=15\nanchor_right=1.0\nanchor_bottom=1.0\ngrow_horizontal=2\ngrow_vertical=2\nscript = ExtResource("1")\n')
(out/'project.godot').write_text('config_version=5\n[application]\nconfig/name="Collection low polygon rooms"\nrun/main_scene="res://remodel_presenter.tscn"\n[display]\nwindow/size/viewport_width=1100\nwindow/size/viewport_height=760\n[rendering]\nrenderer/rendering_method="gl_compatibility"\n')
(out/'export_presets.cfg').write_text('[preset.0]\nname="Web"\nplatform="Web"\nrunnable=true\nexport_filter="all_resources"\ninclude_filter="geometry.json,assets/*.json"\nexclude_filter="web/*,evidence/*,manifest.json"\nexport_path="web/index.html"\n[preset.0.options]\nvariant/thread_support=false\nhtml/export_icon=false\nhtml/canvas_resize_policy=2\n')
(out/'manifest.json').write_text(json.dumps(dict(source_sha256=inputs,point_cloud_render=False,
    room_extents='provisional captured spacing guide; shared opening corrected and source-observed right corridor represented by bounded stub',
    bookcase_dimensions_m=[1.1,1.515,.33],mirror_dimensions_m=[.914,2.311],
    mirror_pair='2017.74.4.1 and .4.2 separately matched to official front photographs; foreground cropped before metric scaling',
    sofa_vessels='API-confirmed 2017.74.5, 2017.74.7.1 and 2017.74.39.18a-c; hidden profiles inferred',
    lighting='Main Hall native UV2 LightmapGI workflow; see bake evidence', presentation_reuse=json.loads((app/'presentation-reuse.json').read_text())),indent=2)+'\n')
assert not (out/'points.bin').exists()
assert all(hashlib.sha256(Path(p).read_bytes()).hexdigest()==h for p,h in inputs.items())
print(out)
