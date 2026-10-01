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

# ponytail: faceted rings keep catalogue depth; unobserved anatomy still needs review.
def volume_asset(kind, size):
    original=app/'trial'/f'{kind}-original.webp'
    pixels=np.array(Image.open(original).convert('RGB'))
    paired = kind == 'recamier'
    if paired:
        # Body only: the two Muse views include different amounts of pedestal.
        pixels=pixels[:1515]
    hsv=cv2.cvtColor(pixels,cv2.COLOR_RGB2HSV)
    mask=((hsv[:,:,0]<125)|(hsv[:,:,0]>175)|(hsv[:,:,1]<=70)|(hsv[:,:,2]<=35)).astype('uint8')
    contours,_=cv2.findContours(mask,cv2.RETR_EXTERNAL,cv2.CHAIN_APPROX_SIMPLE)
    contour=max(contours,key=cv2.contourArea)
    x,y,w,h=cv2.boundingRect(contour);pixels=pixels[y:y+h,x:x+w];mask=mask[y:y+h,x:x+w]
    assert .1<mask.mean()<.95 and w>30 and h>30
    pixels[mask==0]=[218,209,188]
    texture=Image.fromarray(np.dstack([pixels,mask*255]));texture.thumbnail((512,512),Image.Resampling.LANCZOS)
    texture.save(out/'assets'/f'{kind}-volume.png')
    if paired:
        rear_path=app/'trial/recamier-rear-original.webp'
        rear=np.array(Image.open(rear_path).convert('RGB'))[:1170]
        rhsv=cv2.cvtColor(rear,cv2.COLOR_RGB2HSV)
        rmask=((rhsv[:,:,0]<125)|(rhsv[:,:,0]>175)|(rhsv[:,:,1]<=70)|(rhsv[:,:,2]<=35)).astype('uint8')
        rx,ry,rw,rh=cv2.boundingRect(max(cv2.findContours(rmask,cv2.RETR_EXTERNAL,cv2.CHAIN_APPROX_SIMPLE)[0],key=cv2.contourArea))
        rear=rear[ry:ry+rh,rx:rx+rw];rmask=rmask[ry:ry+rh,rx:rx+rw]
        rear[rmask==0]=[218,209,188]
        # Neutral outside-silhouette pixels prevent cut-out holes on a closed volume.
        atlas=Image.new('RGB',(1024,512))
        atlas.paste(Image.fromarray(pixels).resize((512,512)),(0,0))
        atlas.paste(Image.fromarray(rear).resize((512,512)),(512,0))
        atlas.save(out/'assets'/f'{kind}-volume.png')
        inputs[str(rear_path)]=hashlib.sha256(rear_path.read_bytes()).hexdigest()
        full_size=size;size=[size[0],size[1]-.13,size[2]]
    vertices=[];uv=[];triangles=[]
    for row in range(20):
        yy=int(round((h-1)*row/19));where=np.where(mask[yy]>0)[0]
        assert len(where)>0,(kind,yy)
        lo,hi=where.min()/w,where.max()/w
        center=(lo+hi)/2;radius=max((hi-lo)/2,.001)
        for side in range(8):
            angle=side*np.pi/4;xx=center+radius*np.cos(angle)
            vertices.append([(xx-.5)*size[0],(1-yy/(h-1))*size[1],np.sin(angle)*size[2]/2*min(1,max(.2,radius*3))])
            uv.append([float(xx),yy/(h-1)])
            if paired:
                # Front/rear depth follows the official side photograph's neck,
                # projecting face and swept-back hair; intermediate profiles provisional.
                t=row/19
                front=np.interp(t,[0,.12,.32,.46,.55,.63,.70,.80,1],[.08,.72,.72,.9,1,.72,.37,.60,.52])
                back=np.interp(t,[0,.12,.32,.46,.55,.63,.70,.80,1],[.08,1,.96,.82,.60,.42,.35,.65,.55])
                vertices[-1][2]=np.sin(angle)*size[2]/2*(front if np.sin(angle)>=0 else back)
    # Rows run top to bottom. Outward faces and both caps are checked below.
    for row in range(19):
        for side in range(8):
            a=row*8+side;b=row*8+(side+1)%8;c=(row+1)*8+(side+1)%8;d=(row+1)*8+side
            triangles.extend([[a,b,c],[a,c,d]])
    for row,reverse in [(0,True),(19,False)]:
        ids=list(range(row*8,row*8+8));center=np.mean(np.array(vertices)[ids],axis=0).tolist()
        index=len(vertices);vertices.append(center);uv.append([.5,row/19])
        for side in range(8):
            face=[index,ids[side],ids[(side+1)%8]]
            triangles.append(face[::-1] if reverse else face)
    from collections import Counter
    edges=Counter(tuple(sorted((t[i],t[(i+1)%3]))) for t in triangles for i in range(3))
    assert all(count==2 for count in edges.values()), 'Asset mesh must be closed'
    signed=sum(np.dot(vertices[t[0]],np.cross(vertices[t[1]],vertices[t[2]])) for t in triangles)/6
    assert signed>0,(kind,'inverted volume',signed)
    inputs[str(original)]=hashlib.sha256(original.read_bytes()).hexdigest()
    outline=cv2.approxPolyDP(max(cv2.findContours(mask,cv2.RETR_EXTERNAL,cv2.CHAIN_APPROX_SIMPLE)[0],key=cv2.contourArea),2,True)[:,0,:]/[w,h]
    asset={'vertices':vertices,'uv':uv,'triangles':triangles,'outline':outline.tolist(),'size_m':size,'closed_edges_checked':len(edges),'rear':'inferred catalogue-depth volume; frontal UV repeated; multi-view anatomy unverified'}
    if paired:
        triangle_uv=[];hemispheres=[]
        for face in triangles:
            is_rear=np.mean([vertices[i][2] for i in face])<0
            coords=[]
            for i in face:
                t=uv[i][1];yy=min(int(round(t*((rh if is_rear else h)-1))), (rh if is_rear else h)-1)
                active=np.where((rmask if is_rear else mask)[yy]>0)[0];assert len(active)>0
                if i<160:
                    across=(1+np.cos((i%8)*np.pi/4))/2
                    if is_rear:across=1-across
                else:across=.5
                xx=(active.min()+across*(active.max()-active.min()))/((rw if is_rear else w)-1)
                coords.append([(.5 if is_rear else 0)+xx*.5,t])
            triangle_uv.append(coords);hemispheres.append('rear' if is_rear else 'front')
        assert {'front','rear'}==set(hemispheres)
        assert all((u>=.5)==(side=='rear') for side,face in zip(hemispheres,triangle_uv) for u,v in face if 0<u<1 and u!=.5)
        asset.update(triangle_uv=triangle_uv,hemispheres=hemispheres,size_m=full_size,body_height_m=size[1],socle_height_m=.13,
            rear='saved Muse rear view mapped to rear triangles; side depth from official photograph; intermediate anatomy provisional',
            raster_crops={'front_bottom_px':1515,'rear_bottom_px':1170,'reason':'exclude generated socles and photographed black display stand'})
    return asset

# Dishes use the observed top outline on a faceted hollow profile, not a vertical card.
def dish_asset(kind, size):
    original=app/'trial'/f'{kind}-original.webp'
    pixels=np.array(Image.open(original).convert('RGB'));hsv=cv2.cvtColor(pixels,cv2.COLOR_RGB2HSV)
    mask=((hsv[:,:,0]<125)|(hsv[:,:,0]>175)|(hsv[:,:,1]<=70)|(hsv[:,:,2]<=35)).astype('uint8')
    contours,_=cv2.findContours(mask,cv2.RETR_EXTERNAL,cv2.CHAIN_APPROX_SIMPLE)
    x,y,w,h=cv2.boundingRect(max(contours,key=cv2.contourArea));pixels=pixels[y:y+h,x:x+w];mask=mask[y:y+h,x:x+w]
    pixels[mask==0]=[218,209,188]
    texture=Image.fromarray(np.dstack([pixels,mask*255]));texture.thumbnail((512,512),Image.Resampling.LANCZOS)
    texture.save(out/'assets'/f'{kind}-volume.png')
    # ponytail: top-only decoration is repeated on the reverse; catalogue underside
    # photographs must replace that UV before the object can be accepted as complete.
    profile=[(.35,0),(.5,.08),(.65,.35),(.85,.65),(1,1),(.98,.90),(.82,.58),(.6,.22),(.35,.10)]
    edge=[]
    for i in range(24):
        angle=i*np.pi/12;dx=np.cos(angle);dy=np.sin(angle)
        samples=np.linspace(0,.71,300);xs=np.clip(((.5+dx*samples)*(w-1)).astype(int),0,w-1);ys=np.clip(((.5+dy*samples)*(h-1)).astype(int),0,h-1)
        inside=(.5+dx*samples>=0)&(.5+dx*samples<=1)&(.5+dy*samples>=0)&(.5+dy*samples<=1)&(mask[ys,xs]>0)
        r=float(samples[np.where(inside)[0][-1]]);edge.append((dx*r,dy*r))
    vertices=[];uv=[];triangles=[]
    for radius,height in profile:
        for dx,dz in edge:
            vertices.append([dx*radius*size[0],height*size[1],dz*radius*size[2]])
            uv.append([.5+dx*radius,.5+dz*radius])
    for j in range(len(profile)-1):
        for i in range(24):
            a=j*24+i;b=j*24+(i+1)%24;c=(j+1)*24+(i+1)%24;d=(j+1)*24+i
            triangles.extend([[a,c,b],[a,d,c]])
    for j,reverse in [(0,False),(len(profile)-1,True)]:
        center=len(vertices);vertices.append([0,profile[j][1]*size[1],0]);uv.append([.5,.5])
        for i in range(24):
            face=[center,j*24+i,j*24+(i+1)%24];triangles.append(face[::-1] if reverse else face)
    from collections import Counter
    edges=Counter(tuple(sorted((t[i],t[(i+1)%3]))) for t in triangles for i in range(3))
    assert all(count==2 for count in edges.values())
    signed=sum(np.dot(vertices[t[0]],np.cross(vertices[t[1]],vertices[t[2]])) for t in triangles)/6
    assert signed>0,(kind,'dish winding',signed)
    inputs[str(original)]=hashlib.sha256(original.read_bytes()).hexdigest()
    return {'vertices':vertices,'uv':uv,'triangles':triangles,'size_m':size,'closed_edges_checked':len(edges),'rear':'top decoration repeated; underside unverified','shape':'authored hollow dish profile; Muse top-outline and decoration'}

catalogue_objects={'meshes':{},'instances':[]}
for row in json.loads((app/'video-inventory.json').read_text())['volume_instances']:
    kind=row['asset']
    if kind not in catalogue_objects['meshes']:
        catalogue_objects['meshes'][kind]=(dish_asset if row.get('shape')=='dish' else volume_asset)(kind,row['size_m'])
    catalogue_objects['instances'].append(row)
(out/'assets/catalogue-objects.json').write_text(json.dumps(catalogue_objects,indent=2)+'\n')
inputs[str(app/'video-inventory.json')]=hashlib.sha256((app/'video-inventory.json').read_bytes()).hexdigest()

# Reuse the accepted frame preparation for both video-matched portraits.
for kind, canvas, painting in [('edwards', [.637,.760], '58.197'), ('romany', [.762,.952], '2009.9'), ('courbet', [.733,.597], '43.571'), ('corot', [.460,.319], '24.089'), ('bertin', [.651,.489], '56.214'), ('perugino', [.391,.575], '16.236')]:
    frame_path=app/'trial'/f'{kind}-frame-original.webp'
    a=np.array(Image.open(frame_path).convert('RGBA'));hsv=cv2.cvtColor(a[:,:,:3],cv2.COLOR_RGB2HSV)
    chroma=(hsv[:,:,0]>=125)&(hsv[:,:,0]<=175)&(hsv[:,:,1]>70)&(hsv[:,:,2]>35)
    if kind=='perugino':
        # Source frame recesses are brown; retain native value/facets, archive the blue trial.
        blue=(hsv[:,:,0]>=95)&(hsv[:,:,0]<=125)&(hsv[:,:,1]>20)
        hsv[blue,0]=17
        a[blue,:3]=cv2.cvtColor(hsv,cv2.COLOR_HSV2RGB)[blue]
    a[chroma,3]=0;a[chroma,:3]=[162,124,55]
    y,x=np.where(a[:,:,3]>0);a=a[y.min():y.max()+1,x.min():x.max()+1]
    white=(np.min(a[:,:,:3],axis=2)>245).astype('uint8');count,labels,stats,centers=cv2.connectedComponentsWithStats(white)
    h,w=white.shape;label=int(labels[h//2,w//2]);assert label>0
    x0,y0,ww,hh=map(int,stats[label,:4]);assert ww>500 and hh>350
    fit=None
    if kind in ['courbet','corot','bertin','perugino']:
        fit_path=app/('perugino-frame-source-fit.json' if kind=='perugino' else 'grey-frames-source-fit.json')
        fit=json.loads(fit_path.read_text())[kind]
        inputs[str(fit_path)]=hashlib.sha256(fit_path.read_bytes()).hexdigest()
        margins=[round(m*hh/canvas[1]) for m in fit['target_margins_m']]
        left,top,right,bottom=margins
        resized=Image.new('RGBA',(left+ww+right,top+hh+bottom))
        old_x=[0,x0,x0+ww,w];old_y=[0,y0,y0+hh,h]
        new_x=[0,left,left+ww,left+ww+right];new_y=[0,top,top+hh,top+hh+bottom]
        native=Image.fromarray(a)
        for j in range(3):
            for i in range(3):
                piece=native.crop((old_x[i],old_y[j],old_x[i+1],old_y[j+1]))
                resized.paste(piece.resize((new_x[i+1]-new_x[i],new_y[j+1]-new_y[j]),Image.Resampling.LANCZOS),(new_x[i],new_y[j]))
        assert np.array_equal(np.array(resized)[top:top+hh,left:left+ww],a[y0:y0+hh,x0:x0+ww])
        a=np.array(resized);h,w=a.shape[:2];x0,y0=left,top
    Image.fromarray(a).save(out/'assets'/f'{kind}-frame.png')
    (out/'assets'/f'{kind}-frame-geometry.json').write_text(json.dumps({'canvas_m':canvas,'margins_px':[x0,y0,w-x0-ww,h-y0-hh],'opening_aspect':ww/hh,'catalogue_aspect':canvas[0]/canvas[1],'profile':'native Muse bands; 9cm inferred depth; aspect corrected by existing nine-slice geometry','source_fit':fit},indent=2)+'\n')
    if kind in ['courbet','corot','bertin','perugino']:
        painting_path=app/'inventory-catalogue'/({'courbet':'courbet-jura','corot':'corot-river','bertin':'bertin-tivoli','perugino':'perugino-madonna'}[kind]+'-zoom-0.jpg')
        image=Image.open(painting_path)
        image.crop({'courbet':(19,18,1305,1059),'corot':(18,18,1306,911),'bertin':(5,5,1317,966),'perugino':(29,29,1295,1902)}[kind]).save(out/'assets'/f'painting-{painting}.jpg',quality=95)
        inputs[str(painting_path)]=hashlib.sha256(painting_path.read_bytes()).hexdigest()
    else:
        painting_path=app/'catalogue/painting-58.197.jpg' if kind=='edwards' else app/'inventory-catalogue/romany-0.jpg'
        copy(painting_path,'assets/painting-'+painting+'.jpg')
    inputs[str(frame_path)]=hashlib.sha256(frame_path.read_bytes()).hexdigest()

copy(app/'inventory-catalogue/arabesque-wallpaper-zoom-0.jpg','assets/wallpaper-34.912.jpg')
copy(app/'inventory-catalogue/arabesque-wallpaper.json','assets/wallpaper-34.912.json')
door=app/'trial/white-panel-door-original.webp'
image=Image.open(door).convert('RGB')
assert image.size==(1440,1760),'Door UV regions require review when native pixels change'
for index,box in enumerate([(523,258,921,632),(523,708,921,1086),(523,1150,921,1526)]):
    image.crop(box).save(out/'assets'/f'white-panel-door-{index}.png')
inputs[str(door)]=hashlib.sha256(door.read_bytes()).hexdigest()
for index in range(2):
    copy(app/'trial'/f'european-two-panel-door-{index}.png','assets/'+f'european-two-panel-door-{index}.png')
copy(app/'european-two-panel-door-geometry.json','assets/european-two-panel-door-geometry.json')
for kind in ['fetti-frame','goltzius-frame','romanesque-portal','tracery-arch','ionic-capital']:
    for suffix in ['.png','-geometry.json']:
        copy(app/'trial'/(kind+suffix),'assets/'+kind+suffix)
copy(app/'inventory-catalogue/goltzius-cold-stone-zoom-0.jpg','assets/painting-61.006.jpg')
copy(app/'sculpture-room-inventory.json','assets/sculpture-room-inventory.json')
# The official photograph includes the inner gilt edge; exclude it from the canvas.
fetti=app/'inventory-catalogue/fetti-angels-zoom-0.jpg'
canvas=Image.open(fetti).crop((38,28,1289,1469))
assert abs(canvas.width/canvas.height-.781/.895)<.01
canvas.save(out/'assets/painting-36.003.jpg',quality=95)
inputs[str(fetti)]=hashlib.sha256(fetti.read_bytes()).hexdigest()

geometry = json.loads((ingestion/'room-route-walk-v5/geometry.json').read_text())
geometry['caption'] = 'Collection · WASD move · Space reset · 1/2/3 room views\nRoom prototype · placements and unfinished objects are provisional.\n'
geometry['point_cloud_render'] = False
geometry['doorway_correction'] = {'sources':['IMG_6380/000247.jpg','IMG_6380/000449.jpg','IMG_6384/000209.jpg','IMG_6385/000005.jpg'], 'correction':'wide shots put the long-gallery doorway on the wall perpendicular to the sofa; purple doorway remains opposite the sofa wall. The v15 same-wall sofa/gallery-door arrangement was wrong.', 'confidence':'wall relationships visually corroborated; metric positions remain provisional pending matched wide renders'}
geometry['rooms']=[
    {'label':'Rockefeller','bounds':[-2.75,3.65,-7.2,-.4], 'openings':{'south':[-1.55,.45], 'east':[-2.8,-1.2]}},
    {'label':'adjacent gallery','bounds':[-3.6,2.5,-.4,18.85], 'openings':{'north':[-1.55,.45], 'south':[-1.55,.45]}},
    {'label':'light Renaissance room','bounds':[-3.6,2.5,18.85,24.95], 'openings':{'north':[-1.55,.45], 'east':[21.95,23.08]}, 'stone_sides':['east']},
    {'label':'dark medieval room','bounds':[2.5,11.5,18.85,24.95], 'height':4.25, 'openings':{'west':[21.95,23.08], 'north':[3.4355,7.6645], 'east':[19.95,21.65]}, 'stone_sides':['west','north']},
    {'label':'Main Hall portal threshold study limit','bounds':[3.4355,7.6645,17.25,18.85], 'height':4.25, 'openings':{'south':[3.4355,7.6645]}, 'stone_sides':['south']},
    {'label':'stairs landing threshold study limit','bounds':[11.5,12.9,19.95,21.65], 'openings':{'west':[19.95,21.65]}},
    {'label':'purple elevator-5 connector','bounds':[3.65,8.45,-2.8,-1.2], 'openings':{'west':[-2.8,-1.2],'east':[-2.8,-1.2]}},
    {'label':'grey French gallery','bounds':[8.45,15.65,-5.8,1.8], 'floor':'herringbone', 'column_sides':['east'], 'clear_heights':{'east':3.12}, 'openings':{'west':[-2.8,-1.2],'east':[-5.8,1.8],'north':[9.15,11.15],'south':[9.15,11.15]}},
    {'label':'Ionic marble-stair threshold study limit','bounds':[15.65,17.25,-5.8,1.8], 'column_sides':['west'], 'clear_heights':{'west':3.12}, 'openings':{'west':[-5.8,1.8]}},
    {'label':'piano-stair threshold study limit','bounds':[9.15,11.15,-7.4,-5.8], 'openings':{'south':[9.15,11.15]}},
    {'label':'Grand Gallery grey-entry threshold study limit','bounds':[9.15,11.15,1.8,3.4], 'height':6.0, 'openings':{'north':[9.15,11.15]}}]
geometry['grey_gallery_connections']={'source_frames':'6380:29-36,73-80,196-210,493-501','observed':'Purple connector faces Ionic opening across grey room; piano door on adjoining wall; Grand Gallery door perpendicular beside connector. Earlier opposite-ends claim removed.','metric_acceptance':False,'extent':'Authored grey room plus three threshold limits; full Grand Gallery/stairs and museum-loop metric fit unfinished'}
geometry['patches']=[{'label':r['label'],'color':'81735c','vertices':[[r['bounds'][0],0,r['bounds'][2]],[r['bounds'][1],0,r['bounds'][2]],[r['bounds'][1],0,r['bounds'][3]],[r['bounds'][0],0,r['bounds'][3]]]} for r in geometry['rooms']]
geometry['boxes']=[]
geometry['start']=[-.55,.25,-1.3]
geometry['trials']=[['gallery_door_out',[-.55,.25,-1.3],[-.55,0,1.6],False],['gallery_door_back',[-.55,.25,1.6],[-.55,0,-1.3],False],['sofa_wall_blocked',[-1.3,.25,-2.5],[-3.3,0,-2.5],True],['right_wall_blocked',[3.0,.25,-3.2],[4.5,0,-3.2],True],['decorative_room',[1.65,.25,-2.0],[1.65,0,-5.4],False],['adjacent_gallery',[-.55,.25,3],[-.55,0,6],False],['right_door_out',[3.0,.25,-2.0],[4.8,0,-2.0],False],['right_door_back',[4.8,.25,-2.0],[3.0,0,-2.0],False],['central_display_blocked',[.45,.25,-2.3],[.45,0,-4.2],True]]
geometry['trial_seconds']=3.5
geometry['trials'] += [['far_gallery_door_out',[-.55,.25,18],[-.55,0,19.7],False],['far_gallery_door_back',[-.55,.25,19.7],[-.55,0,18],False]]
geometry['trials'] += [['renaissance_left_leaf_blocked',[-1.20,.25,19.33],[-1.85,0,19.33],True],['renaissance_right_leaf_blocked',[.10,.25,19.33],[.75,0,19.33],True]]
geometry['trials'] += [['gold_service_base_blocked',[2.05,.25,-3.8],[3.25,0,-3.8],True]]
geometry['trials'] += [['purple_grey_out',[7.6,.25,-2],[9.3,0,-2],False],['purple_grey_back',[9.3,.25,-2],[7.6,0,-2],False],['grey_grand_out',[10.15,.25,1],[10.15,0,2.65],False],['grey_grand_back',[10.15,.25,2.65],[10.15,0,1],False],['grey_piano_out',[10.15,.25,-5],[10.15,0,-6.6],False],['grey_piano_back',[10.15,.25,-6.6],[10.15,0,-5],False],['grey_ionic_out',[14.85,.25,-2],[16.5,0,-2],False],['grey_ionic_back',[16.5,.25,-2],[14.85,0,-2],False]]
for a,side,b,opposite in [(6,'east',7,'west'),(7,'east',8,'west'),(7,'north',9,'south'),(7,'south',10,'north')]:
    assert geometry['rooms'][a]['openings'][side]==geometry['rooms'][b]['openings'][opposite]
geometry['object_placement_corrections']={'source':'IMG_6380:277-281,319-348,387-408', 'settee':'Aligned beneath Romany at z=-4.7; absolute offsets provisional', 'gold_service_case':'Solid pedestal to floor; pink Worcester retains tray and legs'}
geometry['trials'] += [['tracery_out',[1.7,.25,22.515],[3.35,0,22.515],False],['tracery_back',[3.35,.25,22.515],[1.7,0,22.515],False],['stone_portal_out',[5.55,.25,19.6],[5.55,0,17.85],False],['stone_portal_back',[5.55,.25,17.85],[5.55,0,19.6],False],['stairs_door_out',[10.7,.25,20.8],[12.25,0,20.8],False],['stairs_door_back',[12.25,.25,20.8],[10.7,0,20.8],False],['renaissance_bench_blocked',[-.8,.25,20.8],[-.8,0,22.4],True]]
geometry['far_connection']={'sources':['IMG_6383/000127.jpg','IMG_6383/000134.jpg','IMG_6382/000166.jpg'], 'observed':'Long gallery enters light Renaissance room; its perpendicular east doorway leads into dark medieval room. Medieval round portal and stairs door are on different walls.', 'extent':'Two room shells and portal/stairs thresholds; object contents and all room metrics incomplete. Main Hall has not been integrated.'}
geometry['medieval_case_layout']={'sources':['IMG_6382 78.25s','IMG_6382 88.75s'], 'observed':'Broad low relief case south-west of the smaller tall case near the stair doorway; different glass heights and solid grey bases.', 'metric_acceptance':False, 'contents_complete':False}
geometry['trials'] += [['medieval_low_case_blocked',[6.4,.25,21.5],[6.4,0,23.0],True],['medieval_tall_case_blocked',[9,.25,20.45],[9,0,22.0],True],['medieval_between_cases_clear',[7.8,.25,23.6],[7.8,0,20.3],False],['medieval_stairs_aisle_clear',[7.8,.25,20.2],[10.5,0,20.2],False]]
assert geometry['rooms'][2]['openings']['east']==geometry['rooms'][3]['openings']['west']
geometry['room_geometry']='Wide-shot wall relationships replace v15 layout; authored metric extents and distal gallery limit provisional. No point cloud in renderer.'

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
copy(app/'wide-camera-fit.json','assets/wide-camera-fit.json')
for name in ['floor_oak.gdshader','gamecube.gdshader','crt_luminance.gdshader','squiggle_screen.gdshader','haze_screen.gdshader','page.png','wall-muse.webp','oak-board-atlas-168-v3.webp']:
    copy(app/'main-hall-presentation'/name, 'presentation/'+name)
# Retain native Muse outputs; restrain facet contrast to match smooth source walls.
for kind,tone,contrast,target in [('ivory-plaster',[231,226,217],.22,'wall-plaster'),('ivory-plaster',[228,228,228],.22,'neutral-plaster'),('purple-plaster',[126,99,147],.12,'purple-plaster')]:
    original=app/'trial'/f'{kind}-original.webp'
    wall=np.array(Image.open(original).convert('RGB').resize((256,256)),dtype=float)
    grain=(wall.mean(axis=2)-wall.mean())*contrast
    quarter=np.clip(np.array(tone)+grain[:,:,None],0,255).astype('uint8')
    plaster=np.concatenate([quarter,quarter[:,::-1]],axis=1)
    plaster=np.concatenate([plaster,plaster[::-1]],axis=0)
    assert np.array_equal(plaster[0],plaster[-1]) and np.array_equal(plaster[:,0],plaster[:,-1])
    Image.fromarray(plaster).save(out/'presentation'/f'{target}.png')
    inputs[str(original)]=hashlib.sha256(original.read_bytes()).hexdigest()
for kind in ['door-architrave','baseboard']:
    original=app/'trial'/f'{kind}-original.webp'
    image=np.array(Image.open(original).convert('RGB'));hsv=cv2.cvtColor(image,cv2.COLOR_RGB2HSV)
    mask=((hsv[:,:,0]<125)|(hsv[:,:,0]>175)|(hsv[:,:,1]<70)).astype('uint8')
    contours,_=cv2.findContours(mask,cv2.RETR_EXTERNAL,cv2.CHAIN_APPROX_SIMPLE)
    x,y,w,h=cv2.boundingRect(max(contours,key=cv2.contourArea))
    assert w>200 and h>200
    # Sample the straight centre of each moulding, excluding generated end caps/margins.
    crop=image[y:y+h,x:x+w]
    strip=np.median(crop[h//4:3*h//4],axis=0).astype('uint8')[None,:,:] if kind=='door-architrave' else np.median(crop[:,w//4:3*w//4],axis=1).astype('uint8')[:,None,:]
    Image.fromarray(strip).resize((256,256)).save(out/'assets'/f'{kind}.png')
    inputs[str(original)]=hashlib.sha256(original.read_bytes()).hexdigest()
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
    room_extents='wide-shot corrected gallery doorway perpendicular to sofa wall; metric dimensions and distal long-gallery limit provisional',
    catalogue_objects=len(catalogue_objects['instances']),
    object_coverage=json.loads((app/'video-inventory.json').read_text()),
    bookcase_dimensions_m=[1.1,1.515,.33],mirror_dimensions_m=[.914,2.311],
    mirror_pair='2017.74.4.1 and .4.2 separately matched to official front photographs; foreground cropped before metric scaling',
    sofa_vessels='API-confirmed 2017.74.5, 2017.74.7.1 and 2017.74.39.18a-c; hidden profiles inferred',
    lighting='Main Hall native UV2 LightmapGI workflow; see bake evidence', presentation_reuse=json.loads((app/'presentation-reuse.json').read_text())),indent=2)+'\n')
assert not (out/'points.bin').exists()
assert all(hashlib.sha256(Path(p).read_bytes()).hexdigest()==h for p,h in inputs.items())
print(out)
