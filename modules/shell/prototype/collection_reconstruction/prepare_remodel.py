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

def painted_white(image):
    # Source-relative trim comparison: preserve Muse relief, reduce yellow stripes.
    pixels=np.asarray(image.convert('RGB'),dtype=float)
    grain=(pixels.mean(axis=2)-pixels.mean())*.16
    return Image.fromarray(np.clip([230,228,222]+grain[:,:,None],0,255).astype('uint8'))

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
    relief = kind.startswith("apostle-")
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
            if relief:
                # ponytail: wall-backed slab with authored relief depth, not inferred full anatomy.
                span=[1,1,.4,-.4,-1,-1,-.4,.4][side]
                front=[0,1,1.15,1.15,1,0,0,0][side]
                xx=center+radius*span
                vertices[-1]=[(xx-.5)*size[0],(1-yy/(h-1))*size[1],front*size[2]]
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
    if relief:
        # Existing front/side UV seam: plain Muse stone on slab sides avoids stretched facial bands.
        atlas=Image.new('RGB',(1024,512),tuple(np.median(pixels[mask>0],axis=0).astype('uint8')))
        atlas.paste(Image.fromarray(pixels).resize((512,512)),(0,0))
        atlas.save(out/'assets'/f'{kind}-volume.png')
        asset['triangle_uv']=[]
        for index,t in enumerate(triangles):
            front=index<19*16 and (index//2)%8 in [1,2,3]
            asset['triangle_uv'].append([[uv[i][0]*.5,uv[i][1]] if front else [.75,.5] for i in t])
        asset['rear']='Flat wall-backed slab;.12m relief depth provisional. Plain Muse stone sides/back; generated damage repairs unaccepted.'
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
# Source-protected wall panel: Muse study failed proportions/damage; original front retained.
# ponytail: closed constant-depth slab; brick relief/profile needs surveyed side geometry.
from collections import Counter
lion_original=app/'inventory-catalogue/striding-lion-zoom-0.jpg'
copy(lion_original,'assets/lion-panel-official.jpg')
copy(app/'inventory-catalogue/striding-lion.json','assets/lion-panel-catalogue.json')
original=app/'trial/lion-panel-original.webp'
a=np.array(Image.open(original).convert('RGB'));hsv=cv2.cvtColor(a,cv2.COLOR_RGB2HSV)
mask=((hsv[:,:,0]<125)|(hsv[:,:,0]>175)|(hsv[:,:,1]<70)).astype('uint8')
x,y,w,h=cv2.boundingRect(max(cv2.findContours(mask,cv2.RETR_EXTERNAL,cv2.CHAIN_APPROX_SIMPLE)[0],key=cv2.contourArea))
assert w>1000 and h>500
atlas=Image.new('RGB',(2048,1024));front=Image.open(lion_original).convert('RGB').resize((1024,1024))
atlas.paste(front,(0,0));atlas.paste(Image.fromarray(a[y:y+h,x:x+w]).resize((1024,1024)),(1024,0))
assert np.array_equal(np.array(atlas)[:,:1024],np.array(front))
atlas.save(out/'assets/lion-panel-volume.png');inputs[str(original)]=hashlib.sha256(original.read_bytes()).hexdigest()
size=[2.286,1.041,.08]
vertices=[[-size[0]/2,0,0],[size[0]/2,0,0],[size[0]/2,size[1],0],[-size[0]/2,size[1],0],[-size[0]/2,0,size[2]],[size[0]/2,0,size[2]],[size[0]/2,size[1],size[2]],[-size[0]/2,size[1],size[2]]]
triangles=[[4,5,6],[4,6,7],[0,2,1],[0,3,2],[0,1,5],[0,5,4],[3,7,6],[3,6,2],[0,4,7],[0,7,3],[1,2,6],[1,6,5]]
uv=[[0,1],[1,1],[1,0],[0,0]]*2
triangle_uv=[[[uv[i][0]*.5,uv[i][1]] for i in t] if n<2 else [[.75,.04]]*3 for n,t in enumerate(triangles)]
edges=Counter(tuple(sorted((t[i],t[(i+1)%3]))) for t in triangles for i in range(3));assert all(v==2 for v in edges.values())
volume=sum(np.dot(vertices[t[0]],np.cross(vertices[t[1]],vertices[t[2]])) for t in triangles)/6;assert volume>0 and abs(volume-np.prod(size))<1e-8
catalogue_objects['meshes']['lion-panel']={'vertices':vertices,'uv':uv,'triangles':triangles,'triangle_uv':triangle_uv,'size_m':size,'closed_edges_checked':len(edges),'signed_volume_m3':volume,'front':'Official photo; atlas region equals deterministic resized source exactly. Original JPEG also copied byte-identically.','rear':'Muse brick colours on inferred .08m wall-backed slab; damaged front generation rejected; brick relief/depth unaccepted'}
catalogue_objects['instances'].append({'asset':'lion-panel','position':[16.55,1.18,28.18],'position_basis':'Includes+1.95x to compensate existing catalogue group shift; installedx14.6 on the landing north wall','yaw':0.0,'size_m':size,'accession':'34.652'})
(out/'assets/catalogue-objects.json').write_text(json.dumps(catalogue_objects,indent=2)+'\n')
inputs[str(app/'video-inventory.json')]=hashlib.sha256((app/'video-inventory.json').read_bytes()).hexdigest()

# Reuse the accepted frame preparation for both video-matched portraits.
for kind, canvas, painting in [('edwards', [.637,.760], '58.197'), ('romany', [.762,.952], '2009.9'), ('courbet', [.733,.597], '43.571'), ('corot', [.460,.319], '24.089'), ('bertin', [.651,.489], '56.214'), ('perugino', [.391,.575], '16.236'), ('braque', [.721,.464], '48.248'), ('cezanne', [.737,.610], '43.255'), ('fauconnier', [3.054,2.396], '1995.043'), ('matisse', [.645,.800], '57.037'), ('villon', [.460,.548], '70.058')]:
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
    x0,y0,ww,hh=map(int,stats[label,:4]);assert ww>(250 if kind=='villon' else 500) and hh>350
    fit=None
    if kind in ['courbet','corot','bertin','perugino','braque','cezanne','fauconnier','matisse','villon']:
        fit_path=app/('modern-frames-source-fit.json' if kind in ['braque','cezanne','fauconnier','matisse','villon'] else 'perugino-frame-source-fit.json' if kind=='perugino' else 'grey-frames-source-fit.json')
        fit=json.loads(fit_path.read_text())[kind]
        inputs[str(fit_path)]=hashlib.sha256(fit_path.read_bytes()).hexdigest()
        margins=[round(m*hh/canvas[1]) for m in fit['target_margins_m']]
        left,top,right,bottom=margins
        # Villon's opening is an oval drawn narrower than its canvas; widen that piece to the catalogue aspect.
        cw=round(hh*canvas[0]/canvas[1]) if kind=='villon' else ww
        resized=Image.new('RGBA',(left+cw+right,top+hh+bottom))
        old_x=[0,x0,x0+ww,w];old_y=[0,y0,y0+hh,h]
        new_x=[0,left,left+cw,left+cw+right];new_y=[0,top,top+hh,top+hh+bottom]
        native=Image.fromarray(a)
        for j in range(3):
            for i in range(3):
                piece=native.crop((old_x[i],old_y[j],old_x[i+1],old_y[j+1]))
                resized.paste(piece.resize((new_x[i+1]-new_x[i],new_y[j+1]-new_y[j]),Image.Resampling.LANCZOS),(new_x[i],new_y[j]))
        assert cw!=ww or np.array_equal(np.array(resized)[top:top+hh,left:left+ww],a[y0:y0+hh,x0:x0+ww])
        if kind=='villon':
            # Re-lay the Muse dark rim and its soft shadow along the widened oval at native thickness: each texel
            # takes the Muse texel at the same angle and the same distance outside the oval. No pixel is drawn here.
            Y,X=np.indices((top+hh+bottom,left+cw+right)).astype('float32');X-=left+cw/2-.5;Y-=top+hh/2-.5
            gx,gy=X/(cw/2)**2,Y/(hh/2)**2;gn=np.hypot(gx,gy)+1e-9
            d=((X*2/cw)**2+(Y*2/hh)**2-1)/(2*gn)  # px outside the widened oval, first order
            t=np.arctan2((Y-d*gy/gn)*2/hh,(X-d*gx/gn)*2/cw)
            nx,ny=np.cos(t)/ww,np.sin(t)/hh;nn=np.hypot(nx,ny)
            ring=cv2.remap(a,x0+ww/2-.5+ww/2*np.cos(t)+d*nx/nn,y0+hh/2-.5+hh/2*np.sin(t)+d*ny/nn,cv2.INTER_LINEAR)
            keep=(np.clip((44-d)/24,0,1)*(d>-12))[...,None]  # white lip and whole rim, then its shadow fades into the backing
            resized=Image.fromarray((ring*keep+np.array(resized)*(1-keep)).round().astype('uint8'))
        a=np.array(resized);h,w=a.shape[:2];x0,y0,ww=left,top,cw
    Image.fromarray(a).save(out/'assets'/f'{kind}-frame.png')
    (out/'assets'/f'{kind}-frame-geometry.json').write_text(json.dumps({'canvas_m':canvas,'margins_px':[x0,y0,w-x0-ww,h-y0-hh],'opening_aspect':ww/hh,'catalogue_aspect':canvas[0]/canvas[1],'profile':'Muse box face with its rim re-laid to the catalogue oval; flat 5cm slab, box recess painted not modelled' if kind=='villon' else 'native Muse bands; 9cm inferred depth; aspect corrected by existing nine-slice geometry','source_fit':fit},indent=2)+'\n')
    if kind in ['courbet','corot','bertin','perugino']:
        painting_path=app/'inventory-catalogue'/({'courbet':'courbet-jura','corot':'corot-river','bertin':'bertin-tivoli','perugino':'perugino-madonna'}[kind]+'-zoom-0.jpg')
        image=Image.open(painting_path)
        image.crop({'courbet':(19,18,1305,1059),'corot':(18,18,1306,911),'bertin':(5,5,1317,966),'perugino':(29,29,1295,1902)}[kind]).save(out/'assets'/f'painting-{painting}.jpg',quality=95)
        inputs[str(painting_path)]=hashlib.sha256(painting_path.read_bytes()).hexdigest()
    elif kind in ['braque','cezanne','fauconnier','matisse']:
        copy(app/'inventory-catalogue'/({'braque':'braque-still-life','cezanne':'cezanne-banks-river','fauconnier':'fauconnier-mountaineers','matisse':'matisse-green-pumpkin'}[kind]+'-zoom-0.jpg'),'assets/painting-'+painting+'.jpg')
    elif kind=='villon':
        copy(app/'inventory-catalogue/villon-head-woman-zoom-0.jpg','assets/villon-official-original.jpg')
    else:
        painting_path=app/'catalogue/painting-58.197.jpg' if kind=='edwards' else app/'inventory-catalogue/romany-0.jpg'
        copy(painting_path,'assets/painting-'+painting+'.jpg')
    inputs[str(frame_path)]=hashlib.sha256(frame_path.read_bytes()).hexdigest()

villon=app/'inventory-catalogue/villon-head-woman-zoom-0.jpg'
# Catalogue-aspect ellipse inside the photographed black rim: neither that rim nor the backing is shown as artwork.
crop=(67,58,1242,1458)
oval=np.array(Image.open(villon).convert('RGB').crop(crop))
yy,xx=np.indices(oval.shape[:2]);inside=((xx+.5-oval.shape[1]/2)/(oval.shape[1]/2))**2+((yy+.5-oval.shape[0]/2)/(oval.shape[0]/2))**2<=1
canvas=oval.copy();canvas[~inside]=[255,255,255]
assert np.array_equal(canvas[inside],oval[inside])
Image.fromarray(canvas).save(out/'assets/painting-70.058.png')
(out/'assets/villon-oval-source-proof.json').write_text(json.dumps({'crop_px':crop,'inside_ellipse_changed_pixels':int(np.any(canvas[inside]!=oval[inside],axis=1).sum()),'outside_ellipse':'White backing; original museum JPEG copied byte-identically','oval_crop_alignment_accepted':False},indent=2)+'\n')
inputs[str(villon)]=hashlib.sha256(villon.read_bytes()).hexdigest()

copy(app/'trial/magdalene-frame-fitted.png','assets/magdalene-frame.png')
copy(app/'trial/magdalene-painting-original-crop.png','assets/painting-21.250.png')
copy(app/'magdalene-frame-source-fit.json','assets/magdalene-frame.json')
for original in [app/'fit-magdalene-frame.py',app/'magdalene-frame-guide-v2.json',app/'inventory-catalogue/memmi-magdalene-zoom-0.jpg',app/'trial/magdalene-frame-v2b-original.webp']:
    inputs[str(original)]=hashlib.sha256(original.read_bytes()).hexdigest()

copy(app/'inventory-catalogue/arabesque-wallpaper-zoom-0.jpg','assets/wallpaper-34.912.jpg')
copy(app/'inventory-catalogue/arabesque-wallpaper.json','assets/wallpaper-34.912.json')
door=app/'trial/white-panel-door-original.webp'
image=Image.open(door).convert('RGB')
assert image.size==(1440,1760),'Door UV regions require review when native pixels change'
for index,box in enumerate([(523,258,921,632),(523,708,921,1086),(523,1150,921,1526)]):
    painted_white(image.crop(box)).save(out/'assets'/f'white-panel-door-{index}.png')
inputs[str(door)]=hashlib.sha256(door.read_bytes()).hexdigest()
for index in range(2):
    copy(app/'trial'/f'european-two-panel-door-{index}.png','assets/'+f'european-two-panel-door-{index}.png')
copy(app/'european-two-panel-door-geometry.json','assets/european-two-panel-door-geometry.json')
for kind in ['fetti-frame','goltzius-frame','romanesque-portal','tracery-arch','ionic-capital']:
    for suffix in ['.png','-geometry.json']:
        copy(app/'trial'/(kind+suffix),'assets/'+kind+suffix)
copy(app/'inventory-catalogue/goltzius-cold-stone-zoom-0.jpg','assets/painting-61.006.jpg')
copy(app/'sculpture-room-inventory.json','assets/sculpture-room-inventory.json')
copy(app/'triptych-2021131-geometry.json','assets/triptych-2021131-geometry.json')
for case in ['a','b']:
    for original in sorted((app/f'renaissance-case-{case}').rglob('*')):
        if original.is_file():
            copy(original,Path('assets')/f'renaissance-case-{case}'/original.relative_to(app/f'renaissance-case-{case}'))
copy(app/'trial/cleric-45042-frame-fitted.png','assets/cleric-45042-frame-fitted.png')
copy(app/'renaissance-east-case-installation.json','assets/renaissance-east-case-installation.json')
for original in sorted((app/'renaissance-wall').rglob('*')):
    if original.is_file():
        copy(original,Path('assets/renaissance-wall')/original.relative_to(app/'renaissance-wall'))
for panel in ['left','centre','right']:
    for face in ['front','back']:
        name=f'triptych-2021131-{panel}-{face}.png'
        copy(app/'trial'/name,'assets/'+name)
copy(app/'trial/medieval-grille-geometry.json','assets/medieval-grille-geometry.json')
copy(app/'trial/medieval-grille-metal.png','assets/medieval-grille-metal.png')
# The official photograph includes the inner gilt edge; exclude it from the canvas.
fetti=app/'inventory-catalogue/fetti-angels-zoom-0.jpg'
canvas=Image.open(fetti).crop((38,28,1289,1469))
assert abs(canvas.width/canvas.height-.781/.895)<.01
canvas.save(out/'assets/painting-36.003.jpg',quality=95)
inputs[str(fetti)]=hashlib.sha256(fetti.read_bytes()).hexdigest()

# Medieval originals have integral gilt borders; do not add invented rectangular frames.
for kind, accession, size, box in [('bartolo-madonna','20.207',[.635,.902],(63,20,1264,1730)),('virgin-annunciation','57.301',[.419,.737],None),('taking-peter','22.047',[.540,.387],(24,17,1293,929))]:
    original=app/'inventory-catalogue'/f'{kind}-zoom-0.jpg'
    image=np.array(Image.open(original).convert('RGB'))
    if box:
        image=image[box[1]:box[3],box[0]:box[2]]
        outline=[[0,0],[1,0],[1,1],[0,1]]
    else:
        # White catalogue background is outside the curved wood panel, not painted gold.
        hsv=cv2.cvtColor(image,cv2.COLOR_RGB2HSV)
        contours,_=cv2.findContours((hsv[:,:,1]>30).astype('uint8'),cv2.RETR_EXTERNAL,cv2.CHAIN_APPROX_SIMPLE)
        contour=max(contours,key=cv2.contourArea)
        x,y,w,h=cv2.boundingRect(contour)
        shape=cv2.approxPolyDP(contour,5.0,True)[:,0,:]-[x,y]
        outline=(shape/[w,h]).tolist()
        image=image[y:y+h,x:x+w]
        assert 20<len(outline)<150
    assert abs(image.shape[1]/image.shape[0]-size[0]/size[1])<.025,(kind,'catalogue support aspect')
    Image.fromarray(image).save(out/'assets'/f'painting-{accession}.jpg',quality=95)
    (out/'assets'/f'panel-{accession}.json').write_text(json.dumps({'size_m':size,'outline':outline,'depth_m':.032 if kind=='virgin-annunciation' else .04,'depth_accepted':kind=='virgin-annunciation','source_sha256':hashlib.sha256(original.read_bytes()).hexdigest(),'source':'Official photograph; original painted image with its integral gilt border, not Muse-generated art','placement_accepted':False},indent=2)+'\n')
    inputs[str(original)]=hashlib.sha256(original.read_bytes()).hexdigest()

geometry = json.loads((ingestion/'room-route-walk-v5/geometry.json').read_text())
geometry['caption'] = 'Collection · WASD move · Space reset · 1/2/3/4/5 room views\nRoom prototype · placements and unfinished objects are provisional.\n'
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
    # Skylight Gallery (#238, IMG_6379): 9.5 x 5.0 m from a structure-from-motion fit scaled by the Diao canvas
    # (69.094, 2.21 m). ponytail: flattened to the door's level; the real floor is a storey lower, see NOTES.md.
    {'label':'Skylight Gallery','bounds':[4.95,14.45,-7.4,-5.8],'height':3.9,'openings':{'south':[9.15,11.15]}},
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
geometry['trials'] += [['tracery_out',[1.7,.25,22.515],[3.35,0,22.515],False],['tracery_back',[3.35,.25,22.515],[1.7,0,22.515],False],['stone_portal_out',[5.55,.25,19.6],[5.55,0,17.85],False],['stone_portal_back',[5.55,.25,17.85],[5.55,0,19.6],False],['stairs_door_out',[10.7,.25,22.515],[12.25,0,22.515],False],['stairs_door_back',[12.25,.25,22.515],[10.7,0,22.515],False],['renaissance_bench_blocked',[-.8,.25,20.8],[-.8,0,22.4],True]]
geometry['far_connection']={'sources':['IMG_6383/000127.jpg','IMG_6383/000134.jpg','IMG_6382/000166.jpg'], 'observed':'Long gallery enters light Renaissance room; its perpendicular east doorway leads into dark medieval room. Medieval round portal and stairs door are on different walls.', 'extent':'Two room shells and portal/stairs thresholds; object contents and all room metrics incomplete. Main Hall has not been integrated.'}
geometry['medieval_case_layout']={'sources':['IMG_6382 78.25s','IMG_6382 88.75s'], 'observed':'Broad low relief case west of the smaller tall case; tall case on the stair-door/tracery axis (6387 13.0/44.0s, 6383 66.5s); different glass heights and solid grey bases.', 'metric_acceptance':False, 'contents_complete':False}
geometry['trials'] += [['medieval_low_case_blocked',[6.4,.25,21.5],[6.4,0,23.0],True],['medieval_tall_case_blocked',[9,.25,21.315],[9,0,22.865],True],['medieval_between_cases_clear',[7.8,.25,23.6],[7.8,0,20.3],False],['medieval_stairs_aisle_clear',[7.8,.25,20.2],[10.5,0,20.2],False]]
assert geometry['rooms'][2]['openings']['east']==geometry['rooms'][3]['openings']['west']
geometry['room_geometry']='Wide-shot wall relationships replace v15 layout; authored metric extents and distal gallery limit provisional. No point cloud in renderer.'

# Coupled authored loop: the north-wall gold panels precede the portal in6382:85..88s.
# The projecting black display is not the room corner. Keep both Hall doors centred.
# ponytail:10x26.3m Hall retained from the reviewed prototype; exact survey metrics remain open.
for index,area in enumerate(geometry['rooms']):
    dx=-1.95 if index in [0,1,2] else -.95 if index==5 else -4.6 if index>=7 else 0
    dz=9.25 if index in [2,3,4,5] else 0
    for k in [0,1]:area['bounds'][k]+=dx
    for k in [2,3]:area['bounds'][k]+=dz
    for side,opening in area['openings'].items():
        area['openings'][side]=[v+(dz if side in ['west','east'] else dx) for v in opening]
geometry['rooms'][1]['bounds'][3]+=9.25
geometry['rooms'][3]['bounds'][0]=.55
geometry['rooms'][3]['bounds'][1]=10.55
# Grey register, docs/evidence/collection-reconstruction/opus-grey-register-fit-20261001: the connector
# doorway is a corner door at both ends (6380 38.3/101.6/240.3s, held out 6381 91.0s) and the grey west
# wall reads about 6.0m. Clear opening .30..2.14m from the grey south-west corner; Rockefeller's south
# wall takes the Hall's north-wall line, so the European gallery is the Hall's length.
# ponytail: planar fit scaled by one catalogue canvas. Every metre provisional; connector length,
# Rockefeller depth and column spacing unmeasured.
# Hall reveal, docs/evidence/collection-reconstruction/opus-hall-reveal-builder-20261001: both doors on
# this wall line are deep panelled reveals with the leaves folded inside (6343 0.5/35s, 6380 100/106.25s,
# 6385 0..2s). Rockefeller, connector, grey, Ionic and piano move north together by the wall's thickness.
# ponytail: depth is one folded leaf, half the retained 1.9m Hall opening, less the .19 the door frame
# already stands proud of a wall. A pose, not a measurement; refit when the door is surveyed.
leaf=.95
reveal=leaf-.19
door=[-.34-reveal,1.5-reveal]
geometry['rooms'][0]['bounds'][2:]=[-5.-reveal,1.8-reveal]
geometry['rooms'][0]['openings']['east']=list(door)
geometry['rooms'][1]['bounds'][2]=1.8
geometry['rooms'][6]={'label':'purple elevator-5 connector','bounds':[1.7,3.85]+door, 'openings':{'west':list(door),'east':list(door)}}
for index in [7,8]:geometry['rooms'][index]['bounds'][2:]=[-4.2-reveal,1.8-reveal]
geometry['rooms'][7]['openings'].update(west=list(door),east=[-4.2-reveal,1.8-reveal])
geometry['rooms'][8]['openings']['west']=[-4.2-reveal,1.8-reveal]
geometry['rooms'][9]['bounds'][2:]=[-10.-reveal,-5.-reveal]
geometry['rooms'][4]={'label':'Grand Gallery','bounds':[.55,10.55,1.8,28.1], 'height':6., 'floor':'herringbone','openings':{'north':[4.55,6.55],'south':[3.4355,7.6645]},'stone_sides':['south']}
geometry['rooms'].pop(10)
geometry['start'][0]-=1.95
geometry['start'][2]+=2.2-reveal
for trial in geometry['trials']:
    name=trial[0]
    for point in trial[1:3]:
        if name.startswith(('purple_grey','grey_')):
            point[0]-=4.6
            # Door axis; the piano door follows the north wall; the Ionic walk stays between the columns.
            point[2]+=2.58 if name.startswith('purple_grey') else 1.6 if name.startswith('grey_piano') else .8 if name.startswith('grey_ionic') else 0
            # Only the grey end of a Hall-door trial moves; its Hall end stays in the Hall.
            if point[2]<1.8:point[2]-=reveal
        elif name.startswith('right_door'):
            point[0]=(point[0]-3.65)*(2.15/4.8)+1.7
            point[2]+=2.58-reveal
        elif name.startswith(('stone_portal','medieval')):
            if name.startswith('medieval'):point[0]-=.95
            point[2]+=9.25
        elif name.startswith('stairs_door'):
            point[0]-=.95;point[2]+=9.25
        else:
            point[0]-=1.95
            if name.startswith(('tracery','renaissance','far_gallery')):point[2]+=9.25
            # Rockefeller trials move with the room; the gallery aisle trial is already south of its door.
            elif name!='adjacent_gallery':point[2]+=2.2-reveal
# Marble stair hall (#238, docs/evidence/museum-238/marble-hall/NOTES.md): the Ionic stub becomes the hall
# filmed in IMG_6381 and IMG_6380 45..82s. Room-scene metres. The columned opening keeps the grey gallery's
# east interval; the hall is as wide as that opening and 8.4m deep (fireplace 83.152 at 2.108m as the ruler).
# The void is the service stair under the upper flight, behind the chimneypiece wall.
# ponytail: one-camera estimates, every metre provisional; contents and the stair are marble_hall_additions.gd.
marble=next(area for area in geometry['rooms'] if area['label']=='Ionic marble-stair threshold study limit')
marble.update(label='marble stair hall',height=8.0,floor='marble',bounds=[marble['bounds'][0],marble['bounds'][0]+8.4]+marble['bounds'][2:])
marble['floor_void']=[marble['bounds'][0]+2.8,marble['bounds'][1],marble['bounds'][3]-1.6,marble['bounds'][3]]
geometry['trials']=[trial for trial in geometry['trials'] if not trial[0].startswith('grey_ionic')]
geometry['trials']+=[['grey_marble_out',[10.25,.25,-1.96],[12.6,0,-1.96],False],['grey_marble_back',[12.6,.25,-1.96],[10.25,0,-1.96],False],['marble_stair_blocked',[14.6,.25,-2.4],[14.6,0,-4.3],True]]
geometry['marble_hall']={'source':'IMG_6381 0..99s; IMG_6380 45.5..82.5s; RISD 83.152 and 2011.60 catalogue photographs taken in this hall','stair':'13 straight steps east along the north wall, 6 winders, half-landing under the east window, 6 winders, 4 steps west to the upper landing; 31 risers of .145m','walkable':'this floor only; flights, half-landing and the service-stair void are blocked','metric_accepted':False,'upper_floor_rooms_built':False}
# Real loop connections and bench clearance, checked by the capsule in both native and Web.
for a,b in [(2.2,5.2),(5.2,8.6),(8.6,12),(12,15.4),(15.4,18.8),(18.8,22.2),(22.2,25.6),(25.6,27.2)]:
    geometry['trials'].append([f'hall_aisle_{a:g}',[7,.25,a],[7,0,b],False])
geometry['trials'] += [['hall_bench_blocked',[5.55,.25,17.1],[5.55,0,19.2],True],['hall_back_to_grey',[5.55,.25,2.9],[5.55,0,1-reveal],False],['hall_grey_return',[5.55,.25,1-reveal],[5.55,0,2.9],False]]
# Source-connected full circuit, avoiding the central benches and display cases.
# Rockefeller leg: in at the corner door on the connector axis, then north of the pink service case.
route=[[-2.5,1.0-reveal],[-2.5,3.2],[-2.5,4.4],[-2.5,7.8],[-2.5,11.2],[-2.5,14.6],[-2.5,18],[-2.5,21.4],[-2.5,24.8],[-2.5,26.7],[-2.5,28.6],[-2.5,30],[-.2,30],[-.2,31.765],[1.25,31.765],[3.2,31.765],[3.2,29.2],[5.55,29.2],[5.55,26.7],[7,26.7],[7,23.3],[7,19.9],[7,16.5],[7,13.1],[7,9.7],[7,6.3],[7,2.9],[5.55,2.9],[5.55,1-reveal],[5.55,.58-reveal],[3.05,.58-reveal],[1.1,.2-reveal],[-1.2,.2-reveal],[-2.5,1.0-reveal]]
for i,(a,b) in enumerate(zip(route,route[1:])):
    assert (sum((x-y)**2 for x,y in zip(a,b)))**.5<=3.5
    geometry['trials'].append([f'loop_{i:02d}',[a[0],.25,a[1]],[b[0],0,b[1]],False])
geometry['continuous_loop_waypoints']=route
# Shared openings must agree, rooms must not overlap in plan, and the long sides meet.
for a,side,b,other in [(0,'south',1,'north'),(1,'south',2,'north'),(2,'east',3,'west'),(3,'north',4,'south'),(3,'east',5,'west'),(0,'east',6,'west'),(6,'east',7,'west'),(7,'east',8,'west'),(7,'north',9,'south'),(7,'south',4,'north')]:
    assert all(abs(x-y)<1e-8 for x,y in zip(geometry['rooms'][a]['openings'][side],geometry['rooms'][b]['openings'][other]))
for i,a in enumerate(geometry['rooms']):
    for b in geometry['rooms'][i+1:]:
        aa,bb=a['bounds'],b['bounds']
        assert min(aa[1],bb[1])-max(aa[0],bb[0])<1e-8 or min(aa[3],bb[3])-max(aa[2],bb[2])<1e-8,(a['label'],b['label'])
assert abs(geometry['rooms'][1]['bounds'][3]-geometry['rooms'][4]['bounds'][3])<1e-8
geometry['patches']=[{'label':r['label'],'color':'81735c','vertices':[[r['bounds'][0],0,r['bounds'][2]],[r['bounds'][1],0,r['bounds'][2]],[r['bounds'][1],0,r['bounds'][3]],[r['bounds'][0],0,r['bounds'][3]]]} for r in geometry['rooms']]
geometry['far_connection']['extent']='Connected complete Main Hall shell and23 reused paintings; room metrics and remaining object coverage unaccepted.'
geometry['grey_gallery_connections']['extent']='Connected walkable museum loop through the Main Hall, medieval, Renaissance, European, Rockefeller and grey rooms; stairs remain threshold studies.'
geometry['grey_register']={'source':'docs/evidence/collection-reconstruction/opus-grey-register-fit-20261001/REPORT.md and plan.json','door_clear_z':door,'grey_west_wall_m':6.0,'grey_west_wall_interval_m':[5.4,6.6],'rockefeller_shift_z_m':2.2,'european_gallery_m':26.3,'moved_with_rockefeller_door':'secretary and Delacroix35.786 (IMG_6385 from that door)','left_in_place_unaccepted':'Fetti36.003, both piers, Goltzius61.006 and the far door leaves keep their old z; their offsets from either end are unmeasured','columns':'south column unmoved, north column keeps1.6m from the moved north wall; spacing unmeasured','barn_painting_built':False,'metric_accepted':False,'calibrated_room_metric':False,'physical_loop_accepted':False,'connector_length_accepted':False}
geometry['loop_fit']={'source':'6382:64..89.25;6344:177.5;official floor5 topology', 'correction':'North-wall paintings lie left of projecting display and portal; do not mistake display edge for northwest corner. Extend parallel long galleries, align Hall end doors, preserve relative object placements.', 'metric_accepted':False,'connector_length_accepted':False,'hall_length_m':26.3,'hall_width_m':10.,'medieval_wall_width_m':10.}
geometry['trials'] += [['iron_grille_blocks_visitor',[8.45,.25,29.75],[8.45,0,28.44],True],['iron_grille_east_aisle_clear',[9.65,.25,29.65],[9.65,0,28.65],False]]

#6387 pans1.0..11.0/41.0..44.5s: medieval and modern doors are on two walls meeting at one inside
# corner (9.5/43.5s); text panel then lion right of the modern door on that white north wall; white
# sculpture gallery on the next (east) wall. Flight geometry/room metres provisional.
#6387 46.0..47.5/52.0..84.5s: the entry is in the Braque/Villon wall, so the modern room lies
# north of that door behind the lion wall; two windows; second doorway in the Cezanne wall.
# Accepted interior turned +PI/2 about the entry: old x,z -> (z-18.2,44.25-x).
#6387 13.0/44.0s,6383 66.5s: stair door, tall case and tracery doorway share one axis (z31.765).
# The stair door moves, not the tracery: the Bartolo and Virgin panels need the wall north of it.
# The draft void/flights/guard keep their authored1.1m from the door's south edge, so the block and the
# landing's south bound move +1.715 with it; a preserved draft shape, not a source measurement.
geometry['rooms'][3]['openings']['east']=[30.915,32.615]
# Stairwell (#238): one open-well stair fills the room's south end wall to wall, so the void is the full
# width south of the landing edge. landing_additions.gd builds the stair, the stone floor and the ceiling.
geometry['rooms'][5]={'label':'lion stair landing','bounds':[10.55,16.15,28.1,37.615], 'height':4.1,'floor':'stone-pinwheel','floor_void':[10.55,16.15,33.715,37.615],'openings':{'west':[30.915,32.615],'north':[11.0,12.7],'east':[29.5,31.5]}}
geometry['rooms'] += [
    {'label':'modern painting gallery','bounds':[10.70,16.70,22.30,28.10],'height':3.5,'boards_across':False,'openings':{'south':[11.0,12.7],'north':[15.10,16.40]}},
    {'label':'white sculpture gallery threshold study limit','bounds':[16.15,17.65,29.5,31.5],'openings':{'west':[29.5,31.5]}},
    {'label':'modern adjoining gallery threshold study limit','bounds':[15.10,16.40,20.70,22.30],'openings':{'south':[15.10,16.40]}}
]
assert sum(geometry['rooms'][3]['openings']['west'])==sum(geometry['rooms'][3]['openings']['east'])
for a,side,b,other in [(3,'east',5,'west'),(5,'north',10,'south'),(5,'east',11,'west'),(10,'north',12,'south')]:
    assert geometry['rooms'][a]['openings'][side]==geometry['rooms'][b]['openings'][other]
for i,a in enumerate(geometry['rooms']):
    for b in geometry['rooms'][i+1:]:
        aa,bb=a['bounds'],b['bounds']
        assert min(aa[1],bb[1])-max(aa[0],bb[0])<1e-8 or min(aa[3],bb[3])-max(aa[2],bb[2])<1e-8,(a['label'],b['label'])
geometry['patches']=[p for p in geometry['patches'] if p['label']!='stairs landing threshold study limit']
# The stair and the well are not walked: the landing's collision floor stops at the landing edge.
for label,b in [('landing north floor',[10.55,16.15,28.1,33.715])]+[(r['label'],r['bounds']) for r in geometry['rooms'][10:]]:
    geometry['patches'].append({'label':label,'color':'81735c','vertices':[[b[0],0,b[2]],[b[1],0,b[2]],[b[1],0,b[3]],[b[0],0,b[3]]]})
geometry['lion_modern_layout']={'source':'IMG_6387 native2.25..84.25s; reciprocal6382 stair view','stair_block':'Draft void, flights and guard translated +1.715 with the stair door; preserved shape, not a source measurement','door_order':'Medieval west on the tracery axis; modern north on the adjoining wall at one inside corner, lion right of modern on that wall; white sculpture gallery on the next east wall (z provisional); stairwell south','modern_wall_groups':'Entry/Braque/Villon south; large painting west off the entry jamb; pumpkin/landscape/second doorway north; two windows and sculpture case east','source_review':'docs/evidence/collection-reconstruction/opus-modern-layout-review-20261001; wall order docs/evidence/collection-reconstruction/opus-landing-refit-20261001','entry_reveal_depth_modelled':False,'metric_accepted':False,'stair_curve_and_destinations_complete':False,'white_sculpture_room_interior_complete':False,'adjoining_room_interior_complete':False}
geometry['trials'] += [['landing_to_modern',[11.85,.25,29.75],[11.85,0,26.55],False],['modern_to_landing',[11.85,.25,26.55],[11.85,0,29.75],False],['landing_white_out',[14.95,.25,30.5],[17.0,0,30.5],False],['landing_white_back',[17.0,.25,30.5],[14.95,0,30.5],False],['modern_far_opening_out',[15.75,.25,23.25],[15.75,0,21.45],False],['modern_far_opening_back',[15.75,.25,21.45],[15.75,0,23.25],False],['modern_bench_blocked',[15.1,.25,25.35],[12.4,0,25.35],True],['landing_guard_blocked',[13.35,.25,32.7],[13.35,0,34.6],True],['landing_stair_foot_blocked',[11.15,.25,32.9],[11.15,0,34.6],True],['landing_flight_down_blocked',[15.55,.25,32.9],[15.55,0,34.6],True]]
# #276: shorten the unsurveyed south shaft by 1.5m, putting its edge 4.115m from the lion wall.
# IMG_6387 15/27s, scaled to the north-wall door; uncertainty +/-0.35m. Doors retain their intervals.
lion_landing = next(r for r in geometry['rooms'] if r['label'] == 'lion stair landing')
lion_landing['bounds'][3] = 36.115
lion_landing['floor_void'] = [10.55, 16.15, 32.215, 36.115]
for patch in geometry['patches']:
    if patch['label'] == 'landing north floor':
        patch['vertices'][2][2] = 32.215
        patch['vertices'][3][2] = 32.215
# The central guard is 4.115m from the lion wall; its west ear supports the existing folded leaf.
lion_west_edge = max(32.215, lion_landing['openings']['west'][1] + .05)
lion_west_inner = lion_landing['bounds'][0] + .061 + 1.06
# The walking adapter blocks two rectangles, leaving the west floor ear walkable.
lion_landing['floor_voids'] = [
    [10.55, lion_west_inner, lion_west_edge, 36.115],
    [lion_west_inner, 16.15, 32.215, 36.115]]
if lion_west_edge > 32.216:
    geometry['patches'].append({'label': 'lion west landing ear', 'color': '81735c',
        'vertices': [[10.55, 0, 32.215], [lion_west_inner, 0, 32.215],
                     [lion_west_inner, 0, lion_west_edge], [10.55, 0, lion_west_edge]]})
for trial in geometry['trials']:
    if trial[0] in ['landing_guard_blocked', 'landing_stair_foot_blocked', 'landing_flight_down_blocked']:
        trial[1][2] = 31.6
        trial[2][2] = 33.1
geometry['lion_modern_layout']['stair_block'] = 'Landing edge 4.115m from the lion wall; rounded guard/stringers, two visible storeys below; all metres provisional (#276)'
geometry['trials']=[t for t in geometry['trials'] if not t[0].startswith('grey_piano')]

# The wall's thickness is walked as two threshold rooms; remodel_room.gd lines them and hangs the leaves.
for label,x in [('Grand Gallery reveal threshold',[4.6,6.5]),('Rockefeller reveal threshold',[-3.5,-1.5])]:
    area={'label':label,'reveal':True,'bounds':x+[1.8-reveal,1.8],'boards_across':True,'openings':{'north':list(x),'south':list(x)}}
    for other in geometry['rooms']:
        bb=other['bounds']
        assert min(x[1],bb[1])-max(x[0],bb[0])<1e-8 or min(1.8,bb[3])-max(1.8-reveal,bb[2])<1e-8,(label,other['label'])
    geometry['rooms'].append(area)
    geometry['patches'].append({'label':label,'color':'81735c','vertices':[[x[0],0,1.8-reveal],[x[1],0,1.8-reveal],[x[1],0,1.8],[x[0],0,1.8]]})
# IMG_6379 169..182s, IMG_6380 0/14s: the Skylight door is a deep panelled reveal with both leaves folded in it.
door=list(geometry['rooms'][7]['openings']['north'])
geometry['rooms'].append({'label':'Skylight Gallery reveal threshold','reveal':True,'bounds':door+[geometry['rooms'][9]['bounds'][3],geometry['rooms'][7]['bounds'][2]],'boards_across':True,'openings':{'north':list(door),'south':list(door)}})
b=geometry['rooms'][-1]['bounds']
assert geometry['rooms'][9]['label']=='Skylight Gallery' and geometry['rooms'][9]['openings']['south']==door and b[3]-b[2]>.5
geometry['patches'].append({'label':'Skylight Gallery reveal threshold','color':'81735c','vertices':[[b[0],0,b[2]],[b[1],0,b[2]],[b[1],0,b[3]],[b[0],0,b[3]]]})
assert abs(geometry['rooms'][7]['bounds'][3]-geometry['rooms'][7]['bounds'][2]-6.)<1e-8,'The grey register keeps its 6.0m west wall'
geometry['hall_reveal']={'source':'docs/evidence/collection-reconstruction/opus-hall-reveal-builder-20261001/REPORT.md','wall_m':reveal,'leaf_m':leaf,'leaf_panels_from_top':[[.06,.15],[.23,.63],[.74,.90]],'knob_from_top':.71,'hinge_side':'north','observed':'one cased opening, panelled soffit, both leaves folded flat on the reveal sides, free edge at the Hall; same construction at the Rockefeller door','depth_measured':False,'opening_metres_accepted':False,'leaf_fidelity_accepted':False,'rockefeller_leaf_built':False,'metric_accepted':False}

# #275: the grey door enters the upper landing, not the oak gallery floor.
# Keep the attached doorway and its deep reveal unchanged. The numerical survey
# and frame checks are in docs/evidence/skylight-275/NOTES.md. All numbers provisional.
skylight = next(r for r in geometry['rooms'] if r['label'] == 'Skylight Gallery')
sx0, sx1, sz0, sz1 = skylight['bounds']
skylight.update(height=3.9, floor='skylight-two-storey')
low = -2.55
lx0, lx1, lz0 = sx0 + 3.85, sx0 + 6.55, sz1 - 1.65
turn_x, turn_z = sx1 - 1.20, sz0 + 1.28
risers = [5, 7, 6]
rise = -low / sum(risers)
y1, y2 = -risers[0] * rise, -(risers[0] + risers[1]) * rise

def skylight_patch(label, corners):
    return {'label': 'Skylight ' + label, 'color': '81735c', 'vertices': corners}

def skylight_deck(label, x0, x1, z0, z1, y):
    return skylight_patch(label, [[x0,y,z0],[x1,y,z0],[x1,y,z1],[x0,y,z1]])

# Each collision patch is also the surface the game's walking adapter reads.
# Lower circulation excludes the lift / enclosed underside of the entry deck.
skylight_surfaces = [
    skylight_deck('lower north floor', sx0, lx1, sz0, lz0, low),
    skylight_deck('lower west floor', sx0, lx0, lz0, sz1, low),
    skylight_deck('lower well floor', lx1, turn_x, turn_z, lz0, low),
    skylight_deck('upper landing', lx0, lx1, lz0, sz1, 0),
    skylight_patch('upper ramp', [[lx1,0,lz0],[turn_x,y1,lz0],[turn_x,y1,sz1],[lx1,0,sz1]]),
    skylight_deck('south-east quarter landing', turn_x, sx1, lz0, sz1, y1),
    skylight_patch('east ramp', [[turn_x,y2,turn_z],[sx1,y2,turn_z],[sx1,y1,lz0],[turn_x,y1,lz0]]),
    skylight_deck('north-east quarter landing', turn_x, sx1, sz0, turn_z, y2),
    skylight_patch('lower ramp', [[lx1,low,sz0],[turn_x,y2,sz0],[turn_x,y2,turn_z],[lx1,low,turn_z]]),
]
geometry['patches'] = [p for p in geometry['patches'] if p['label'] != 'Skylight Gallery'] + skylight_surfaces
geometry['skylight_walk'] = {
    'source': 'IMG_6379 6.5/26/54/127/154.5/159.5s; docs/evidence/skylight-275/NOTES.md',
    'lower_y': low, 'ceiling_y': 3.9, 'landing': [lx0,lx1,lz0,sz1],
    'turn_x': turn_x, 'turn_z': turn_z, 'risers': risers,
    'surfaces': skylight_surfaces,
    'guards': [
        {'ends': [[lx0,0,sz1],[lx0,0,lz0]]},
        {'ends': [[lx0,0,lz0],[lx1,0,lz0]]},
        {'ends': [[lx1,0,lz0],[turn_x,y1,lz0]]},
        {'ends': [[turn_x,y1,lz0],[turn_x,y2,turn_z]]},
        {'ends': [[turn_x,y2,turn_z],[lx1,low,turn_z]]},
    ],
    'metric_accepted': False,
}
# Level entry, continuous stair legs in both directions, lower circulation and
# guard / furniture collisions. No other room's trials change.
up_at, se_at, ne_at, foot_at = [lx1,0,sz1-.82], [sx1-.58,y1,sz1-.82], [sx1-.58,y2,sz0+.64], [lx1-.60,low,sz0+.64]
def skylight_trial(name, start, target, blocked=False):
    return [name, [start[0],start[1]+.25,start[2]], list(target), blocked]
geometry['trials'] += [
    ['grey_skylight_out',[5.55,.25,-4.16],[5.55,0,sz1-.82],False],
    ['grey_skylight_back',[5.55,.25,sz1-.82],[5.55,0,-4.16],False],
    skylight_trial('skylight_landing_east',[5.55,0,sz1-.82],up_at),
    skylight_trial('skylight_upper_down',up_at,se_at),
    skylight_trial('skylight_east_down',se_at,ne_at),
    skylight_trial('skylight_lower_down',ne_at,foot_at),
    skylight_trial('skylight_lower_aisle',foot_at,[lx1-.60,low,lz0-.45]),
    skylight_trial('skylight_lower_west',[lx1-.60,low,lz0-.45],[3.50,low,lz0-.45]),
    skylight_trial('skylight_lower_lift',[3.50,low,lz0-.45],[3.50,low,sz1-.60]),
    skylight_trial('skylight_lower_up',foot_at,ne_at),
    skylight_trial('skylight_east_up',ne_at,se_at),
    skylight_trial('skylight_upper_up',se_at,up_at),
    skylight_trial('skylight_landing_back',up_at,[5.55,0,sz1-.82]),
    skylight_trial('skylight_front_guard',[5.55,0,sz1-.82],[5.55,0,lz0-.70],True),
    skylight_trial('skylight_west_guard',[lx0+.65,0,sz1-.82],[lx0-.65,0,sz1-.82],True),
    skylight_trial('skylight_piano_blocked',[2.70,low,sz0+2.60],[1.20,low,sz0+1.00],True),
]

(out/'geometry.json').write_text(json.dumps(geometry,indent=2)+'\n')
inputs[str(ingestion/'room-route-walk-v5/geometry.json')] = hashlib.sha256((ingestion/'room-route-walk-v5/geometry.json').read_bytes()).hexdigest()
for name in ['doorway_walk.gd','remodel_room.gd','remodel_review.gd','remodel_presenter.gd','remodel_bake.gd','connected_hall.gd','seated_woman_asset.gd','virgin_child_asset.gd','medieval_metal_assets.gd','medieval_ceramic_ivory_assets.gd','saint_roch_asset.gd','triptych_asset.gd','pieta_asset.gd','renaissance_case_a_assets.gd','renaissance_case_b_assets.gd','renaissance_wall_assets.gd']:
    copy(source/name,name)
    if name in ['renaissance_case_b_assets.gd','renaissance_wall_assets.gd']:
        target=out/name
        target.write_text(target.read_text().replace('preload("../gallery_walk4/painting_asset.gd")','preload("res://modules/shell/prototype/gallery_walk4/painting_asset.gd")'))
for name in ['decal-queens-roundel.png','decal-queens-boat.png','queens-decals-source.json','medieval-paper-L1.png','medieval-paper-L2.png']:
    copy(app/'trial'/name,'assets/'+name)
copy(app/'medieval-case-inventory.json','assets/medieval-case-inventory.json')
copy(app/'medieval-paper-source.json','assets/medieval-paper-source.json')
hall_source=repo/'modules/shell/prototype/gallery_walk4'
# Room additions (#238): every *_additions.gd beside this file, and its assets from
# image-work/collection-room-remodel/additions/<room>/ as assets/additions/<room>/.
for path in sorted(source.glob('*_additions.gd')):
    copy(path,path.name)
copy(source/'acceptance.json','acceptance.json') # read by architecture_check.gd
for path in sorted((app/'additions').rglob('*')):
    if path.is_file():
        copy(path,'assets/additions/'+str(path.relative_to(app/'additions')))
for name in ['walk4.gd','works.json','gaps.json']:
    copy(hall_source/name,'modules/shell/prototype/gallery_walk4/'+name)
for folder in ['frames','canvas','textures']:
    for path in (hall_source/folder).rglob('*'):
        if path.is_file() and not path.name.endswith('.import'):
            copy(path,'modules/shell/prototype/gallery_walk4/'+str(path.relative_to(hall_source)))
visitor_source = repo/'image-work/collection-room-remodel/main-hall-visitor159'
for path in visitor_source.rglob('*'):
    if path.is_file():
        copy(path,'modules/shell/prototype/gallery_walk4/visitor159/'+str(path.relative_to(visitor_source)))
for name in ['painting_asset.gd','ps1.gdshader']:
    copy(app/'main-hall-presentation'/name,'modules/shell/prototype/gallery_walk4/'+name)
for name in ['oak-muse.webp']:
    copy(repo/'modules/shell/prototype/gallery_walk4/textures'/name,'textures/'+name)
copy(app/'trial/sofa-cloth-original.webp','assets/sofa-cloth.webp')
copy(app/'trial/seated-woman-bronze-original.webp','assets/seated-woman-bronze.webp')
copy(app/'wide-camera-fit.json','assets/wide-camera-fit.json')
for name in ['floor_oak.gdshader','gamecube.gdshader','crt_luminance.gdshader','squiggle_screen.gdshader','haze_screen.gdshader','page.png','wall-muse.webp','oak-board-atlas-168-v3.webp']:
    copy(app/'main-hall-presentation'/name, 'presentation/'+name)
# Retain native Muse outputs; restrain facet contrast to match smooth source walls.
for kind,tone,contrast,target in [('ivory-plaster',[231,226,217],.22,'wall-plaster'),('ivory-plaster',[228,228,228],.22,'neutral-plaster'),('purple-plaster',[126,99,147],.12,'purple-plaster'),('landing-plaster',[175,171,163],.15,'landing-plaster')]:
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
    painted_white(Image.fromarray(strip).resize((256,256))).save(out/'assets'/f'{kind}.png')
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
inputs[str(source/'prepare_remodel.py')]=hashlib.sha256((source/'prepare_remodel.py').read_bytes()).hexdigest()
(out/'manifest.json').write_text(json.dumps(dict(source_sha256=inputs,point_cloud_render=False,
    room_extents='coupled authored parallel galleries and end-room connections; exact metrics provisional',
    catalogue_objects=len(catalogue_objects['instances']),
    object_coverage=json.loads((app/'video-inventory.json').read_text()),
    bookcase_dimensions_m=[1.1,1.515,.33],mirror_dimensions_m=[.914,2.311],
    mirror_pair='2017.74.4.1 and .4.2 separately matched to official front photographs; foreground cropped before metric scaling',
    sofa_vessels='API-confirmed 2017.74.5, 2017.74.7.1 and 2017.74.39.18a-c; hidden profiles inferred',
    lighting='Main Hall native UV2 LightmapGI workflow; see bake evidence', presentation_reuse=json.loads((app/'presentation-reuse.json').read_text())),indent=2)+'\n')
assert not (out/'points.bin').exists()
assert all(hashlib.sha256(Path(p).read_bytes()).hexdigest()==h for p,h in inputs.items())
print(out)
