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
weights=np.array([[a/4,b/4,1-(a+b)/4] for a in range(5) for b in range(5-a)])
def hemisphere_uv(front):
    view=views[0 if front else 1]
    uv=[]
    for face in triangles:
        corners=[]
        for index in face:
            if index>=rings*sides:
                fraction=.5/rings if index==rings*sides else 1-.5/rings
                horizontal=0
            else:
                fraction=(index//sides+.5)/rings
                horizontal=np.sin(-np.pi/2+(index%sides)*2*np.pi/sides)*(1 if front else -1)
            row=min(len(view['bounds'])-1,int(fraction*len(view['bounds'])))
            left,right=view['bounds'][row]
            corners.append([(left+(right-left)*(horizontal+1)/2)/w,
                (view['top']+fraction*(view['bottom']-view['top']))/h])
        uv.append(corners)
    uv=np.array(uv)
    def chroma_samples():
        samples=np.einsum('sj,tjk->tsk',weights,uv)
        px=np.minimum(w-1,(samples[:,:,0]*w).astype(int));py=np.minimum(h-1,(samples[:,:,1]*h).astype(int))
        sampled=picture[py,px].astype(int)
        return (sampled[:,:,0]-sampled[:,:,1]>80)&(sampled[:,:,2]-sampled[:,:,1]>80)&(sampled[:,:,0]>180)&(sampled[:,:,2]>180)
    initial=int(chroma_samples().sum())
    adjusted=set()
    for _ in range(50):
        bad=np.flatnonzero(chroma_samples().any(axis=1))
        if not len(bad):break
        for index in bad:
            adjusted.add(int(index))
            row=np.clip((uv[index,:,1]*h-view['top']).astype(int),0,len(view['bounds'])-1)
            centers=view['bounds'][row].mean(axis=1)/w
            uv[index,:,0]=centers+.9*(uv[index,:,0]-centers)
    assert not chroma_samples().any(), 'UV interpolation crosses the chroma background'
    assert np.isfinite(uv).all() and uv.min()>=0 and uv.max()<=1
    return uv.tolist(),initial,len(adjusted)
front_uv,front_bleed,front_adjusted=hemisphere_uv(True)
rear_uv,rear_bleed,rear_adjusted=hemisphere_uv(False)
blend=[float(np.clip((np.cos(-np.pi/2+(i%sides)*2*np.pi/sides)+.20)/.40,0,1))
    if i<rings*sides else .5 for i in range(len(vertices))]
assert np.allclose(np.array(blend)[np.arange(rings)*sides+sides//4],1)
assert np.allclose(np.array(blend)[np.arange(rings)*sides+3*sides//4],0)
(out/'mesh.json').write_text(json.dumps(dict(vertices=vertices.tolist(),triangles=triangles.tolist(),
    face_uv_front=front_uv,face_uv_rear=rear_uv,front_weight=blend),separators=(',',':')))
shutil.copyfile(texture,out/'appearance.webp')
report=dict(vertices=len(vertices),triangles=len(triangles),edge_use_counts=sorted(set(edges.values())),
    euler_characteristic=2,closed_position_mesh=True,signed_volume_m3=float(volume),
    dimensions_m=np.ptp(vertices,axis=0).tolist(),texture_sha256=hashlib.sha256(texture.read_bytes()).hexdigest(),
    provider='local NumPy geometry; existing OpenRouter meta/muse-image appearance',new_cost_usd=0,
    source_appearance_cost_usd=.01,source_spend_state='unknown / never-resubmit',
    complete_scan=False,visual_accepted=False,uv_chroma_sample_count=int(2*len(triangles)*len(weights)),
    uv_chroma_samples_remaining=0,uv_inset_adjusted_triangles=front_adjusted+rear_adjusted,initial_uv_chroma_samples=front_bleed+rear_bleed,
    caveat='Closed silhouette loft with inferred side, top, underside, nose and depth. Catalogue '
           'envelope axes are inferred and do not validate shape. Existing Muse front/rear appearance '
           'has baked shading and unverified crack/carving preservation. Side UVs blend the two appearances; '
           'no frontal face on the back. Neither watertight topology nor dimensions mean faithful geometry. '
           'Pedestal, global placement, video silhouette comparison and final bake remain unverified.')
(out/'checks.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))
