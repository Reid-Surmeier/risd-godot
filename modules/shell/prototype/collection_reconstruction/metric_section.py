"""Export the observed cabinet section in provisional metres, not a room shell."""
import json
import pathlib

import numpy as np
import pycolmap
from PIL import Image, ImageDraw

ROOT = pathlib.Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
fit = next(x for x in json.loads((ROOT/'scale-fit-v1/result.json').read_text()) if x['component'] == '3')
basis = np.array(fit['basis_rows'])
scale = fit['meters_per_unit']
assert scale > 0 and np.allclose(basis @ basis.T, np.eye(3), atol=1e-6)
model = pycolmap.Reconstruction()
model.import_PLY(str(ROOT/'dense-connected-v1/fused.ply'))
points = list(model.points3D.values())
xyz = (np.array([p.xyz for p in points])-fit['origin']) @ basis.T * scale
assert np.isfinite(xyz).all()
for p, position in zip(points, xyz):
    p.xyz = position
out = ROOT/'metric-section-v1'
out.mkdir(exist_ok=True)
model.export_PLY(str(out/'observed-section-metres.ply'))
colors = np.array([p.color for p in points])
canvas = Image.new('RGB', (1500, 1250), '#20252a')
draw = ImageDraw.Draw(canvas)
# Same 260 pixels/metre for both orthographic projections; painting centre is origin.
for title, axes, origin in [('Front: X / Y', (0,1), (235,230)), ('Plan: X / Z', (0,2), (235,1080))]:
    ox, oy = origin
    for tick in np.arange(-1, 4.51, .5):
        px = ox + tick*260
        draw.line((px, oy-140, px, oy+440 if axes[1]==1 else oy+100), fill='#39434a')
        draw.text((px+3, oy-155), f'{tick:g}m', fill='white')
    for tick in np.arange(-1.5, .51, .5) if axes[1]==1 else np.arange(-.25,1.26,.25):
        py = oy-tick*260
        draw.line((35,py,1460,py),fill='#39434a')
        draw.text((40,py+3),f'{tick:g}m',fill='white')
    # Draw rear points first; this is an orthographic evidence plot, not a render.
    for idx in np.argsort(xyz[:,2 if axes[1]==1 else 1]):
        p=xyz[idx]
        x,y=int(ox+p[axes[0]]*260),int(oy-p[axes[1]]*260)
        if 0<=x<1500 and 0<=y<1250:
            draw.point((x,y),fill=tuple(int(c) for c in colors[idx]))
    draw.text((45,60 if axes[1]==1 else 710),title,fill='white')
draw.text((45,20),'Observed section | provisional catalogue scale | no inferred walls or connections',fill='white')
canvas.save(out/'orthographic.png')
(out/'provenance.json').write_text(json.dumps(dict(source='dense-connected-v1/fused.ply',
    scale_fit='scale-fit-v1/result.json component 3', points=len(points),
    metres_per_unit=scale,scale_p10_p90=fit['scale_p10_p90'],
    caveat=fit['caveat']),indent=2))
print(out)
