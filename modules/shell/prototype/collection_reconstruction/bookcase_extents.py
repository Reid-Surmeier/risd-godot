"""Cross-check catalogue scale using triangulated extrema, without a planar homography."""
import hashlib
import json
from pathlib import Path

import numpy as np
import pycolmap
from PIL import Image, ImageDraw
from measurements import project, triangulate, heldout_pose

ROOT = Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
OUT = ROOT/'bookcase-extents-v1'
SOURCE = ROOT/'sfm-calibrated-doorway-v1/sparse/0'
model = pycolmap.Reconstruction(SOURCE)
# Top rail left/right and outer front castor contacts, in upright 720x1280 pixels.
annotations = {'IMG_6380/000292.jpg': [[268, 401], [596, 411], [304, 897], [573, 827]],
               'IMG_6380/000297.jpg': [[110, 362], [612, 370], [171, 983], [560, 955]]}
images = {n: next(i for i in model.images.values() if i.name == n) for n in annotations}
cameras = {n: model.cameras[im.camera_id] for n, im in images.items()}
poses = {n: im.cam_from_world() for n, im in images.items()}
points, angles = zip(*(triangulate(cameras, poses, {n: np.array(p[k]) for n, p in annotations.items()}) for k in range(4)))
points = np.array(points)
# Independently picked before projecting these reconstructed extrema.
query = 'IMG_6380/000296.jpg'
annotations[query] = [[131, 350], [616, 369], [190, 989], [569, 929]]
cameras[query], poses[query], inliers = heldout_pose(
    model, ROOT/'heldout-calibrated-v1/database.db', query, annotations[query])
assert np.isfinite(points).all() and min(angles) > 1
floor = json.loads((ROOT/'doorway-geometry-v1/geometry.json').read_text())
up = np.array(floor['basis_rows'])[1]
width = float(np.linalg.norm(points[1]-points[0]))
height = float(np.mean(points[:2]@up)-np.min(points[2:]@up))
assert width > 0 and height > 0
scales = [1.1/width, 1.515/height]
OUT.mkdir(exist_ok=True)
errors = {}
source_hashes = {}
for n in annotations:
    cam_points = poses[n]*points
    assert np.all(cam_points[:, 2] > 0)
    xy = project(cameras[n], poses[n], points)
    errors[n] = np.linalg.norm(xy-annotations[n], axis=1).tolist()
    source = ROOT/'survey-2fps'/n
    source_hashes[n] = hashlib.sha256(source.read_bytes()).hexdigest()
    picture = Image.open(source).transpose(Image.Transpose.ROTATE_270).convert('RGB')
    draw = ImageDraw.Draw(picture)
    for k, (observed, predicted) in enumerate(zip(annotations[n], xy)):
        x, y = observed
        draw.ellipse((x-6, y-6, x+6, y+6), outline='lime', width=2)
        draw.text((x+8, y), str(k), fill='lime')
        x, y = predicted
        draw.line((x-8, y, x+8, y), fill='red', width=2)
        draw.line((x, y-8, x, y+8), fill='red', width=2)
    draw.rectangle((0, 0, 720, 26), fill='black')
    draw.text((5, 5), ('HELD OUT ' if n == query else 'FIT ')+'Bookcase: green picked, red predicted', fill='white')
    picture.save(OUT/(Path(n).stem+'.png'))
report = dict(annotations=annotations, points_world=points.tolist(), ray_angles_degrees=list(angles), heldout=query, heldout_pose_fit_inliers=inliers,
              heldout_errors_px=errors[query], heldout_threshold_px=8.,
              heldout_diagnostic_pass=max(errors[query]) <= 8.,
              reprojection_errors_px=errors, width_model_units=width, height_model_units=height,
              width_scale_m_per_unit=scales[0], height_scale_m_per_unit=scales[1],
              width_height_scale_disagreement=float(abs(scales[0]-scales[1])/np.mean(scales)),
              previous_scale_m_per_unit=floor['provisional_m_per_unit'],
              source_image_sha256=source_hashes,
              model_sha256={p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in SOURCE.glob('*.bin')},
              accepted=False,
              caveat='Manual two-view extrema, catalogue dimensions 1.100 x 1.515 m from local decorative-anchor evidence. Top rail may not be maximum width; castors and floor-derived up remain uncertain. Nearby held-out video diagnostic only; not an independent object/measurement. Do not replace metric scale yet.')
(OUT/'result.json').write_text(json.dumps(report, indent=2)+'\n')
print(json.dumps(report, indent=2))
