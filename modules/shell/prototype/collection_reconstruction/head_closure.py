"""#183 closed appearance proxy; inferred volume, never a completed scan."""
import argparse
import collections
import hashlib
import json
from pathlib import Path
import shutil

import numpy as np
from PIL import Image

parser = argparse.ArgumentParser()
parser.add_argument('output', type=Path)
args = parser.parse_args()
out = args.output
out.mkdir(parents=True, exist_ok=False)
repo = Path(__file__).resolve().parents[4]
texture = repo/'image-work/collection-expansion-sculpture/trial/muse-original.webp'
picture = np.array(Image.open(texture).convert('RGB'))
h, w = picture.shape[:2]
views = []
for offset, limit in [(0, w//2), (w//2, w)]:
    p = picture[:, offset:limit].astype(int)
    background = (p[:,:,0]-p[:,:,1]>80)&(p[:,:,2]-p[:,:,1]>80)&(p[:,:,0]>180)&(p[:,:,2]>180)
    mask = ~background
    rows = np.flatnonzero(mask.sum(axis=1)>6)
    assert len(rows)>h*.8
    top, bottom = int(rows.min()), int(rows.max())
    bounds = []
    for y in range(top, bottom+1):
        row = np.flatnonzero(mask[y])
        assert len(row)>6, 'Texture silhouette contains an unsupported row'
        bounds.append([offset+row.min()+min(12,len(row)//4), offset+row.max()-min(12,len(row)//4)])
    views.append(dict(top=top,bottom=bottom,bounds=np.array(bounds)))
assert views[0]['bottom']-views[0]['top']>h*.8
rings, sides = 96, 64
vertices = []
for ring in range(rings):
    fraction = (ring+.5)/rings
    widths = []
    for view in views:
        row = min(len(view['bounds'])-1,int(fraction*len(view['bounds'])))
        widths.append(np.ptp(view['bounds'][row])/np.max(np.ptp(view['bounds'],axis=1)))
    half_width = .254*np.mean(widths)
    y = .813*(.5-fraction)
    half_depth = .20*np.sqrt(max(.015,1-(y/.415)**2))
    for side in range(sides):
        theta = -np.pi/2 + side*2*np.pi/sides
        x = half_width*np.sin(theta)
        z = half_depth*np.cos(theta)
        # ponytail: inferred nose/eye volume under baked appearance; replace with supported profiles.
        if np.cos(theta)>0:
            z += .08*np.exp(-(x/.05)**2-((y+.09)/.095)**2)*np.cos(theta)
            z -= .02*sum(np.exp(-((x-eye)/.05)**2-((y-.025)/.04)**2) for eye in [-.115,.115])
        vertices.append([x,y,z])
vertices.extend([[0,.4065,0],[0,-.4065,0]])
vertices=np.array(vertices)
vertices[:,0]*=.508/np.ptp(vertices[:,0])
vertices[:,2]*=.508/np.ptp(vertices[:,2])
vertices[:,2]-=(vertices[:,2].min()+vertices[:,2].max())/2
triangles=[]
for ring in range(rings-1):
    for side in range(sides):
        a=ring*sides+side;b=ring*sides+(side+1)%sides;c=a+sides;d=b+sides
        triangles.extend([[a,b,c],[b,d,c]])
for side in range(sides):
    triangles.extend([[rings*sides,(side+1)%sides,side],
        [rings*sides+1,(rings-1)*sides+side,(rings-1)*sides+(side+1)%sides]])
triangles=np.array(triangles)
# Topology check uses shared position indices before UV seams duplicate render vertices.
edges=collections.Counter(tuple(sorted((a,b))) for face in triangles for a,b in zip(face,np.roll(face,-1)))
assert all(n==2 for n in edges.values()), 'Open or non-manifold edge'
assert len(vertices)-len(edges)+len(triangles)==2
p=vertices[triangles]
volume=np.sum(np.einsum('ij,ij->i',p[:,0],np.cross(p[:,1],p[:,2])))/6
if volume<0:triangles=triangles[:,::-1];volume=-volume
assert volume>0 and np.isfinite(vertices).all()
assert np.allclose(np.ptp(vertices,axis=0),[.508,.813,.508])
# One front hemisphere and one rear hemisphere, each mapped to its own sheet panel.
# UV seams duplicate render vertices while the canonical position mesh remains closed.
face_uv=[]
for face in triangles:
    cosines=[np.cos(-np.pi/2+(i%sides)*2*np.pi/sides) for i in face if i<rings*sides]
    front=np.mean(cosines)>=0
    view=views[0 if front else 1]
    uv=[]
    for index in face:
        if index>=rings*sides:
            fraction=.5/rings if index==rings*sides else 1-.5/rings;horizontal=0
        else:
            fraction=(index//sides+.5)/rings
            horizontal=np.sin(-np.pi/2+(index%sides)*2*np.pi/sides)*(1 if front else -1)
        row=min(len(view['bounds'])-1,int(fraction*len(view['bounds'])))
        left,right=view['bounds'][row]
        uv.append([(left+(right-left)*(horizontal+1)/2)/w,
                   (view['top']+fraction*(view['bottom']-view['top']))/h])
    face_uv.append(uv)
# Check the raster sampled between UV corners, not merely the corners themselves.
weights=np.array([[a/4,b/4,1-(a+b)/4] for a in range(5) for b in range(5-a)])
uv_array=np.array(face_uv)
def chroma_samples(uv):
    samples=np.einsum('sj,tjk->tsk',weights,uv)
    px=np.minimum(w-1,(samples[:,:,0]*w).astype(int));py=np.minimum(h-1,(samples[:,:,1]*h).astype(int))
    sampled=picture[py,px].astype(int)
    return (sampled[:,:,0]-sampled[:,:,1]>80)&(sampled[:,:,2]-sampled[:,:,1]>80)&(sampled[:,:,0]>180)&(sampled[:,:,2]>180)
initial_bleed=int(chroma_samples(uv_array).sum())
adjusted=set()
for _ in range(50):
    bad=np.flatnonzero(chroma_samples(uv_array).any(axis=1))
    if not len(bad):break
    for index in bad:
        adjusted.add(int(index))
        panel=views[0 if uv_array[index,:,0].mean()<.5 else 1]
        row=np.clip((uv_array[index,:,1]*h-panel['top']).astype(int),0,len(panel['bounds'])-1)
        centers=panel['bounds'][row].mean(axis=1)/w
        uv_array[index,:,0]=centers+.9*(uv_array[index,:,0]-centers)
assert not chroma_samples(uv_array).any(), 'UV interpolation still crosses the chroma background'
face_uv=uv_array.tolist()
assert np.isfinite(face_uv).all() and np.min(face_uv)>=0 and np.max(face_uv)<=1
(out/'mesh.json').write_text(json.dumps(dict(vertices=vertices.tolist(),triangles=triangles.tolist(),face_uv=face_uv),separators=(',',':')))
shutil.copyfile(texture,out/'appearance.webp')
report=dict(vertices=len(vertices),triangles=len(triangles),edge_use_counts=sorted(set(edges.values())),
    euler_characteristic=2,closed_position_mesh=True,signed_volume_m3=float(volume),
    dimensions_m=np.ptp(vertices,axis=0).tolist(),texture_sha256=hashlib.sha256(texture.read_bytes()).hexdigest(),
    provider='local NumPy geometry; existing OpenRouter meta/muse-image appearance',new_cost_usd=0,
    source_appearance_cost_usd=.01,source_spend_state='unknown / never-resubmit',
    complete_scan=False,visual_accepted=False,uv_chroma_sample_count=int(len(triangles)*len(weights)),
    uv_chroma_samples_remaining=0,uv_inset_adjusted_triangles=len(adjusted),initial_uv_chroma_samples=initial_bleed,
    caveat='Closed silhouette loft with inferred side, top, underside, nose and depth. Catalogue '
           'envelope axes are inferred and do not validate shape. Existing Muse front/rear appearance '
           'has baked shading and unverified crack/carving preservation. Rear uses its own texture; '
           'no frontal face on the back. Neither watertight topology nor dimensions mean faithful geometry. '
           'Pedestal, global placement, video silhouette comparison and final bake remain unverified.')
(out/'checks.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))
