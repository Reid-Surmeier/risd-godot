"""Deterministic chroma key and opening measurement for the single Muse trial."""
import json
import pathlib
import shutil
import numpy as np
from PIL import Image
app=pathlib.Path(__file__).resolve().parent
source=app/'artifacts/image-generation/runs/run-ed0aaab20f6b84b6db0db31b/materialized/image-01.webp'
a=np.array(Image.open(source).convert('RGBA'))
rgb=a[:,:,:3].astype(float)
# Reuse the established desktop-icons/conform.py magenta unmixing formula.
magenta=np.array([255.,0.,255.])
alpha=np.clip((np.linalg.norm(rgb-magenta,axis=2)-60)/120,0,1)
rgb=np.clip((rgb-(1-alpha[:,:,None])*magenta)/np.maximum(alpha[:,:,None],1e-3),0,255)
alpha[np.minimum(rgb[:,:,0],rgb[:,:,2])-rgb[:,:,1]>15]=0
a=np.dstack([rgb,alpha*255]).astype(np.uint8)
ys,xs=np.where(alpha>.5)
box=(xs.min(),ys.min(),xs.max()+1,ys.max()+1)
a=a[box[1]:box[3],box[0]:box[2]]
# Opening is the centre-connected white rectangle, not highlights on the gilt.
white=np.min(a[:,:,:3],axis=2)>245
h,w=white.shape
row=np.where(white[h//2])[0];col=np.where(white[:,w//2])[0]
x0,x1=int(row.min()),int(row.max()+1);y0,y1=int(col.min()),int(col.max()+1)
assert white[y0:y1,x0:x1].mean()>.995
assert abs((x1-x0)/(y1-y0)-.651/.541)<.04
(app/'trial').mkdir(exist_ok=True)
Image.fromarray(a).save(app/'trial/frame.png')
shutil.copyfile('/home/reidsurmeier/risd-godot-ingestion/collection-expansion/anchors/painting-0.jpg',app/'references/painting-35.786.jpg')
(app/'trial/geometry.json').write_text(json.dumps(dict(canvas_m=[.651,.541],
    margins_px=[x0,y0,w-x1,h-y1],texture_size=[w,h],
    depth_m=.09,canvas_inset_m=.035,
    depth_note='Reused prototype depth; not a measured frame profile.'),indent=2))
print((app/'trial/geometry.json').read_text())
