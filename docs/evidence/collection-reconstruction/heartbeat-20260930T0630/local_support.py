"""#182 fitted-track coverage only; does not certify manually picked corners."""
import collections, hashlib, json
from pathlib import Path
import numpy as np
import pycolmap
from PIL import Image, ImageDraw
from measurements import project, upright
root = Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
source = root/'sfm-calibrated-doorway-v1'
trial = root/'grand-casing-outer-header-v1'
out = Path('docs/evidence/collection-reconstruction/heartbeat-20260930T0630')
annotations = json.loads((trial/'annotations.json').read_text())
pins = json.loads((root/'heldout-calibrated-v1/audit.json').read_text())['source_sha256']
assert all(hashlib.sha256((source/p).read_bytes()).hexdigest()==h for p,h in pins.items())
model = pycolmap.Reconstruction(source/'sparse/0')
views = {v.name: v for v in model.images.values()}
rows, local_ids = [], []
for name, pixels in annotations['picks'].items():
 view = views[name]; camera = model.cameras[view.camera_id]
 points = [p for p in view.points2D if p.has_point3D()]
 xy = upright(np.array([p.xy for p in points]))
 ids = np.array([p.point3D_id for p in points])
 xyz = np.array([model.points3D[int(i)].xyz for i in ids])
 residual = np.linalg.norm(project(camera, view.cam_from_world(), xyz)-xy,axis=1)
 distance = np.min(np.linalg.norm(xy[:,None]-np.array(pixels)[None],axis=2),axis=1)
 mask = distance<=120
 local_ids.append(set(int(i) for i in ids[mask]))
 im = Image.open(source/'images'/name).transpose(Image.Transpose.ROTATE_270).convert('RGB'); d=ImageDraw.Draw(im)
 for (x,y),near,error in zip(xy,mask,residual):
  d.ellipse((x-2,y-2,x+2,y+2),fill='lime' if near and error<=4 else ('orange' if near else '#449fff'))
 for x,y in pixels:
  d.ellipse((x-120,y-120,x+120,y+120),outline='white',width=2)
  d.line((x-8,y,x+8,y),fill='red',width=2);d.line((x,y-8,x,y+8),fill='red',width=2)
 d.rectangle((0,0,720,42),fill='black');d.text((8,8),f'{name}: fitted tracks, not independent corner validation.',fill='white')
 im.save(out/(Path(name).stem+'-local-tracks.png'))
 rows.append(dict(image=name,registered_tracks=len(ids),within120px=int(mask.sum()),
  within60px=int((distance<=60).sum()),within30px=int((distance<=30).sum()),
  nearest_track_px=float(distance.min()), local_fitted_median_error_px=float(np.median(residual[mask])) if mask.any() else None,
  local_track_ids=sorted(local_ids[-1])))
report=dict(rows=rows,common_tracks_all_three=len(set.intersection(*local_ids)),
 pairwise_common=[dict(images=[rows[i]['image'],rows[j]['image']],count=len(local_ids[i]&local_ids[j])) for i in range(3) for j in range(i+1,3)],
 provider='local pycolmap/NumPy/Pillow; no extraction, matching or optimization',cost_usd=0,
 caveat='Registered model residuals are fitted evidence, not held-out. Pixel proximity does not establish physical casing-face membership. White circle radius fixed at 120 source pixels; no camera/model refit or corner repick.')
assert all(hashlib.sha256((source/p).read_bytes()).hexdigest()==h for p,h in pins.items())
(out/'local-track-support.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))
