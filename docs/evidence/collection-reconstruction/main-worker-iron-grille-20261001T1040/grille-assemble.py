"""Closed low polygon iron coil; source repeat count, existing Muse metal material."""
from pathlib import Path
from collections import Counter
import json,hashlib,math
import numpy as np
from PIL import Image
app=Path(__file__).resolve().parent
native=app/'trial/medieval-grille-original.webp'
a=np.array(Image.open(native).convert('RGB'))
# Interior of the Muse sheet's left iron post; no generated repeat layout is reused.
patch=a[250:1550,413:419].copy();pink=(patch[:,:,0]>patch[:,:,1]+30)&(patch[:,:,2]>patch[:,:,1]+30)
assert np.mean(pink)<.05
patch[pink]=np.median(patch[~pink],axis=0).astype('uint8')
Image.fromarray(patch).resize((16,256),Image.Resampling.NEAREST).save(app/'trial/medieval-grille-metal.png')
segments=20;centres=[]
for i in range(segments+1):
 t=i/segments;angle=t*3.5*math.pi-math.pi/2;r=.066-.057*t
 centres.append(np.array([r*math.cos(angle),r*math.sin(angle),0.]))
centres.insert(0,np.array([0.,-.07,0.]));segments=len(centres)-1
vertices=[];uv=[];width=.011;depth=.014
for i,c in enumerate(centres):
 tangent=centres[min(i+1,segments)]-centres[max(0,i-1)];tangent/=np.linalg.norm(tangent);side=np.array([-tangent[1],tangent[0],0.])
 for j,(s,z) in enumerate([(-1,-1),(1,-1),(1,1),(-1,1)]):
  vertices.append((c+side*s*width/2+np.array([0,0,z*depth/2])).tolist());uv.append([j%2,i/segments])
faces=[]
for i in range(segments):
 for j in range(4):
  a=i*4+j;b=i*4+(j+1)%4;c=b+4;d=a+4;faces.extend([[a,b,c],[a,c,d]])
faces.extend([[0,2,1],[0,3,2],[segments*4,segments*4+1,segments*4+2],[segments*4,segments*4+2,segments*4+3]])
edges=Counter(tuple(sorted((t[i],t[(i+1)%3]))) for t in faces for i in range(3));directions=Counter()
for t in faces:
 for i in range(3):
  a,b=t[i],t[(i+1)%3];directions[tuple(sorted((a,b)))]+=1 if a<b else -1
assert set(edges.values())=={2} and set(directions.values())=={0}
v=np.array(vertices);volume=sum(np.dot(v[t[0]],np.cross(v[t[1]],v[t[2]]))/6 for t in faces)
if volume<0:faces=[t[::-1] for t in faces];volume=-volume
assert volume>0 and len(faces)==172
# ponytail: source-shaped repeat study, not individually modelled historical scrolls/rivets.
data={'columns':7,'rows':17,'column_count_observed':True,'row_count_provisional':True,'cell_pitch_m':.14,'size_m':[.98,2.38,depth],'vertices':vertices,'triangles':faces,'uv':uv,'coil_closed_edges':len(edges),'coil_signed_volume_m3':volume,'source_sha256':hashlib.sha256(native.read_bytes()).hexdigest(),'material_patch_px':[413,250,419,1550],'material_sha256':hashlib.sha256((app/'trial/medieval-grille-metal.png').read_bytes()).hexdigest(),'source_frames':['IMG_6382 12.25s','IMG_6382 12.375s','IMG_6382 88.75s'],'placement_m':[8.45,.12,28.44],'metric_accepted':False,'catalogue_identity':'unmatched','limitations':'7 columns observed,17 rows provisional. Alternating handedness,uniform coils,plain square profile,17 row pitch,depth/braces,plinth,height,width and placement unaccepted. Generated8-column sheet rejected as geometry; Muse post pixels reused only as iron material.'}
(app/'trial/medieval-grille-geometry.json').write_text(json.dumps(data,separators=(',',':'))+'\n')
print('Coil',len(vertices),'vertices',len(faces),'triangles',len(edges),'paired edges;positive volume',volume)
