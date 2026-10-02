"""Export observed decorative-room points and a robust floor plane, in provisional metres."""
import json
import pathlib
import numpy as np
import pycolmap
from PIL import Image,ImageDraw

root=pathlib.Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
fit=next(x for x in json.loads((root/'scale-bookcase-v1/result.json').read_text()) if x['component']=='5')
basis=np.array(fit['basis_rows']);scale=fit['meters_per_unit'];origin=np.array(fit['origin'])
assert scale>0 and np.allclose(basis@basis.T,np.eye(3),atol=1e-6)
model=pycolmap.Reconstruction();model.import_PLY(str(root/'dense-expanded-v1/fused.ply'))
points=list(model.points3D.values());xyz=(np.array([p.xyz for p in points])-origin)@basis.T*scale
colors=np.array([p.color for p in points]);assert np.isfinite(xyz).all()
out=root/'decorative-geometry-v1';out.mkdir(exist_ok=True)
np.c_[xyz,colors/255].astype('<f4').tofile(out/'points.bin')
# This ROI was inspected against the source views and plan: exclude walls and white display plinths.
mask=(xyz[:,1]>-.94)&(xyz[:,1]<-.65)&(xyz[:,0]>-2.3)&(xyz[:,0]<3)&(xyz[:,2]>.4)&(xyz[:,2]<5.7)&(colors[:,0]>colors[:,1])&(colors[:,1]>colors[:,2])
q=xyz[mask];a=np.c_[q[:,0],q[:,2],np.ones(len(q))]
for _ in range(4):
    coefficients=np.linalg.lstsq(a,q[:,1],rcond=None)[0]
    residual=np.abs(a@coefficients-q[:,1]);keep=residual<.04;q=q[keep];a=a[keep]
residual=np.abs(a@coefficients-q[:,1]);assert len(q)>1000 and np.percentile(residual,90)<.04
metadata=dict(points=len(points),scale_m_per_unit=scale,scale_p10_p90=fit['scale_p10_p90'],
    floor=dict(equation='y = a*x + b*z + c',coefficients=coefficients.tolist(),support_points=len(q),
               median_residual_m=float(np.median(residual)),p90_residual_m=float(np.percentile(residual,90))),
    caveat='Bookcase is stepped, so whole-object planar scale is provisional and may be biased. No walls, openings or inter-room transform accepted.')
(out/'geometry.json').write_text(json.dumps(metadata,indent=2))
for axes,label in [((0,1),'front'),((0,2),'plan')]:
    projected=xyz[:,axes];lo,hi=np.percentile(projected,[.5,99.5],axis=0)
    factor=min(1300/(hi-lo)[0],850/(hi-lo)[1]);picture=Image.new('RGB',(1400,1000),'#20252a');draw=ImageDraw.Draw(picture)
    def pixel(q):return (int(50+(q[0]-lo[0])*factor),int(930-(q[1]-lo[1])*factor))
    for tick in range(int(np.floor(lo[0])),int(np.ceil(hi[0]))+1):
        x,y=pixel((tick,lo[1]));draw.line((x,40,x,950),fill='#40454a');draw.text((x,950),f'{tick}m',fill='white')
    for tick in range(int(np.floor(lo[1])),int(np.ceil(hi[1]))+1):
        x,y=pixel((lo[0],tick));draw.line((30,y,1390,y),fill='#40454a');draw.text((5,y),f'{tick}m',fill='white')
    for i in np.argsort(xyz[:,2 if label=='front' else 1]):
        px=pixel(projected[i])
        if 0<=px[0]<1400 and 40<px[1]<940:draw.point(px,fill=tuple(colors[i]))
    draw.text((30,15),f'{label}: provisional catalogue scale; observed points, not final room surfaces',fill='white')
    picture.save(out/f'{label}.png')
print(json.dumps(metadata,indent=2))
