"""Export a review view of measured points; never export guessed room surfaces."""
import json
import pathlib
import shutil
import sys

import numpy as np
import pycolmap

root = pathlib.Path(sys.argv[1])
output = pathlib.Path(sys.argv[2])
output.mkdir(parents=True, exist_ok=True)
scene = []
for folder in sorted((root / 'sparse').iterdir()):
    if not folder.is_dir():
        continue
    model = pycolmap.Reconstruction(folder)
    points = list(model.points3D.values())
    xyz = np.array([p.xyz for p in points])
    center = np.median(xyz, axis=0)
    _, _, axes = np.linalg.svd(xyz-center, full_matrices=False)
    scale = np.quantile(np.linalg.norm(xyz-center, axis=1), .95)
    assert scale > 0 and np.isfinite(xyz).all()
    vertices = []
    for p in points:
        vertices.extend([*((p.xyz-center) @ axes.T/scale).tolist(), *(p.color/255).tolist(), 2.5])
    cameras = [i for i in model.images.values() if i.has_pose]
    for image in cameras:
        vertices.extend([*((image.projection_center()-center) @ axes.T/scale).tolist(), 0., 1., 1., 7.])
    scene.append(dict(label=f'Model {folder.name}', vertices=vertices,
                      images=len(cameras), points=len(points),
                      error=model.compute_mean_reprojection_error(),
                      clips=sorted({i.name.split('/')[0] for i in cameras})))
scene.sort(key=lambda m: m['images'], reverse=True)
cloud = root.parent/'dense-connected-v1/fused.ply'
if cloud.exists() and '--sparse-only' not in sys.argv[3:]:
    dense = pycolmap.Reconstruction()
    dense.import_PLY(str(cloud))
    points = list(dense.points3D.values())
    xyz = np.array([p.xyz for p in points])
    center = np.median(xyz, axis=0)
    _, _, axes = np.linalg.svd(xyz-center, full_matrices=False)
    scale = np.quantile(np.linalg.norm(xyz-center, axis=1), .95)
    vertices = []
    for p in points:
        vertices.extend([*((p.xyz-center) @ axes.T/scale).tolist(), *(p.color/255).tolist(), 2.])
    scene.append(dict(label='Dense section · 48 views',vertices=vertices,images=48,
                      points=len(points),error=None,clips=['Depth evidence; not a watertight mesh']))
(output/'scene.json').write_text(json.dumps(scene, separators=(',', ':')))
shutil.copyfile(pathlib.Path(__file__).with_name('view.html'), output/'index.html')
print([(m['label'], m['images'], m['points']) for m in scene])
