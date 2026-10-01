"""Extrude the saved Muse stone silhouettes into closed native low-polygon meshes."""
from pathlib import Path
from collections import Counter
import cv2,numpy as np,json,hashlib
from PIL import Image
app=Path(__file__).resolve().parent
def closed_faces(mask):
 rows,columns=mask.shape
 faces=[]
 for yy,xx in np.argwhere(mask):
  x0,x1=int(xx),int(xx+1);y0,y1=rows-int(yy)-1,rows-int(yy)
  faces.extend([[(x0,y0,1),(x1,y0,1),(x1,y1,1),(x0,y1,1)],[(x1,y0,0),(x0,y0,0),(x0,y1,0),(x1,y1,0)]])
  for dx,dy,face in [(-1,0,[(x0,y0,0),(x0,y0,1),(x0,y1,1),(x0,y1,0)]),(1,0,[(x1,y0,1),(x1,y0,0),(x1,y1,0),(x1,y1,1)]),(0,-1,[(x0,y1,1),(x1,y1,1),(x1,y1,0),(x0,y1,0)]),(0,1,[(x0,y0,0),(x1,y0,0),(x1,y0,1),(x0,y0,1)])]:
   nx,ny=xx+dx,yy+dy
   if not(0<=nx<columns and 0<=ny<rows) or not mask[ny,nx]:faces.append(face)
 edges=Counter(tuple(sorted((q[i],q[(i+1)%4]))) for q in faces for i in range(4))
 assert set(edges.values())=={2},'Stone extrusion is not closed'
 return faces,len(edges)

for kind,size,columns in [('romanesque-portal',[4.229,3.861,.45],64),('tracery-arch',[1.410,1.092,.273],96)]:
 native=app/'trial'/f'{kind}-original.webp';a=np.array(Image.open(native).convert('RGBA'))
 hsv=cv2.cvtColor(a[:,:,:3],cv2.COLOR_RGB2HSV);key=(hsv[:,:,0]>=125)&(hsv[:,:,0]<=175)&(hsv[:,:,1]>70)
 a[key,3]=0
 rgb=a[:,:,:3].astype(float);pink=((rgb[:,:,0]+rgb[:,:,2])/2-rgb[:,:,1]>8)&(rgb[:,:,0]>rgb[:,:,1]+5)&(rgb[:,:,2]>rgb[:,:,1]+5)
 a[pink,:3]=[177,169,147]
 y,x=np.where(a[:,:,3]>0);a=a[y.min():y.max()+1,x.min():x.max()+1]
 Image.fromarray(a).save(app/'trial'/f'{kind}.png')
 rows=round(columns*size[1]/size[0]);small=np.array(Image.fromarray(a[:,:,3]).resize((columns,rows),Image.Resampling.BOX));mask=small>127
 # ponytail: silhouette extrusion approximates carving at 1-7cm cells; carved depth needs side-view modelling.
 # Remove diagonal-only contact so the native mesh has two faces per edge, including around holes.
 for yy in range(rows-1):
  for xx in range(columns-1):
   square=mask[yy:yy+2,xx:xx+2]
   if square.sum()==2 and square[0,0]==square[1,1]:
    cells=[(yy+j,xx+i) for j in range(2) for i in range(2) if not square[j,i]]
    iy,ix=max(cells,key=lambda p:small[p]);mask[iy,ix]=True
 faces,edge_count=closed_faces(mask)
 assert not mask[rows-1,columns//2] and not mask[rows//2,columns//2], 'Walk-through opening sealed'
 # Front/back share authentic Muse colours; rear/profile fidelity remains unverified.
 data=dict(size_m=size,grid=[columns,rows],faces=faces,triangles=len(faces)*2,closed_quad_edges=edge_count,edge_pair_counts=[2],
 source_sha256=hashlib.sha256(native.read_bytes()).hexdigest(),depth_basis='catalogue' if kind=='tracery-arch' else 'provisional .45m; catalogue gives height/width only',
 limitations='Constant-depth silhouette extrusion, not fully modelled engaged columns or carved capitals. Rear appearance inferred; whole architectural acceptance incomplete.')
 infill=np.zeros_like(mask)
 for yy in range(rows):
  occupied=np.flatnonzero(mask[yy]);assert len(occupied)>0
  infill[yy,:occupied[0]]=True;infill[yy,occupied[-1]+1:]=True
 data['infill_faces'],data['infill_closed_edges']=closed_faces(infill)
 (app/'trial'/f'{kind}-geometry.json').write_text(json.dumps(data,separators=(',',':'))+'\n')
 print(kind,len(faces)*2,'triangles; closed edges',edge_count)
