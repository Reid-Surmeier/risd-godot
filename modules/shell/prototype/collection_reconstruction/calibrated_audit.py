"""Audit the frozen doorway model using cached matches; no reconstruction or paid calls."""
import collections
import hashlib
import json
import pathlib

import numpy as np
import pycolmap
from PIL import Image, ImageDraw

ROOT = pathlib.Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
SOURCE = ROOT/'sfm-calibrated-doorway-v1'
OUT = ROOT/'heldout-calibrated-v1'
model = pycolmap.Reconstruction(SOURCE/'sparse/0')
references = list(model.images.values())
rows = json.loads((OUT/'result.json').read_text())
hashes = {str(p.relative_to(SOURCE)): hashlib.sha256(p.read_bytes()).hexdigest()
          for p in (SOURCE/'sparse/0').glob('*.bin')}
assert hashes and not ({r['image'] for r in rows} & {i.name for i in references})
# Extra doorway samples must also exclude the same nominal held-out timestamps.
extra = [250+(int(pathlib.Path(i.name).stem)-1)/6 for i in references
         if i.name.startswith('IMG_6380_exit6fps/')]
assert all(abs(t-h) > .2 for t in extra for h in [252.5, 257.5])

evaluated = []
with pycolmap.Database.open(OUT/'database.db') as db:
    records = {i.name: i for i in db.read_all_images()}
    for row in rows:
        name = row['image']
        q = records[name]
        matches = collections.defaultdict(collections.Counter)
        for ref in references:
            for a, b in db.read_matches(q.image_id, ref.image_id):
                p = ref.points2D[int(b)]
                if p.has_point3D():
                    matches[int(a)][p.point3D_id] += 1
        ids = sorted(matches)
        point_ids = np.array([matches[i].most_common(1)[0][0] for i in ids])
        xy = db.read_keypoints(q.image_id)[ids, :2].astype(float)
        xyz = np.array([model.points3D[int(i)].xyz for i in point_ids])
        # Split by 3D point, so repeated query features cannot share a fit/test point.
        test = point_ids % 2 == 0
        entry = dict(image=name, fit_points=int((~test).sum()), test_points=int(test.sum()),
                     supported=False)
        if min(entry['fit_points'], entry['test_points']) >= 6:
            ref = next(i for i in references if i.name.split('/')[0] == name.split('/')[0])
            camera = pycolmap.Camera(model.cameras[ref.camera_id].todict())
            options = pycolmap.AbsolutePoseEstimationOptions()
            options.ransac.max_error = 4.
            options.ransac.random_seed = 182
            pose = pycolmap.estimate_and_refine_absolute_pose(xy[~test], xyz[~test], camera,
                                                           estimation_options=options)
            if pose:
                camera_xyz = pose['cam_from_world'] * xyz[test]
                projected = camera.img_from_cam(camera_xyz)
                errors = np.linalg.norm(projected-xy[test], axis=1)
                good = np.isfinite(errors) & (errors < 4) & (camera_xyz[:, 2] > 0)
                entry.update(fit_inliers=int(pose['num_inliers']), test_below4px=int(good.sum()),
                             test_fraction=float(good.mean()),
                             supported=bool(pose['num_inliers'] >= 20 and
                                            pose['num_inliers']/entry['fit_points'] >= .25 and
                                            good.sum() >= 20 and good.mean() >= .25))
                if name in ['IMG_6380/000496.jpg', 'IMG_6380/000506.jpg', 'IMG_6380/000516.jpg']:
                    picture = Image.open(ROOT/'survey-2fps'/name).convert('RGB')
                    draw = ImageDraw.Draw(picture)
                    for observed, predicted in zip(xy[test][good], projected[good]):
                        x, y = observed
                        draw.ellipse((x-3, y-3, x+3, y+3), outline='lime', width=2)
                        draw.line((x, y, *predicted), fill='red', width=2)
                    draw.rectangle((0, 0, 1100, 26), fill='black')
                    draw.text((8, 8), f'{name}: {good.sum()}/{len(good)} unused points within 4px; pose fit on other points', fill='white')
                    picture.save(OUT/(pathlib.Path(name).stem+'-validation.jpg'))
        evaluated.append(entry)

def tracks(m):
    return {(e.image_id, e.point2D_idx): pid for pid, p in m.points3D.items() for e in p.track.elements}

source_tracks = tracks(model)
alignments = []
for component in [0, 5]:
    seed = pycolmap.Reconstruction(ROOT/f'sfm-connected-v4/sparse/{component}')
    target_tracks = tracks(seed)
    pairs = sorted({(source_tracks[k], target_tracks[k]) for k in source_tracks.keys() & target_tracks.keys()})
    x = np.array([model.points3D[a].xyz for a, b in pairs])
    y = np.array([seed.points3D[b].xyz for a, b in pairs])
    radius = np.percentile(np.linalg.norm(y-np.median(y, axis=0), axis=1), 90)
    test = np.array([a % 5 == 0 for a, b in pairs])
    options = pycolmap.RANSACOptions()
    options.max_error = radius*.02
    options.random_seed = 182
    fit = pycolmap.estimate_sim3d_robust(x[~test], y[~test], options)
    assert fit is not None
    transform = fit['tgt_from_src']
    error = np.linalg.norm(transform*x-y, axis=1)/radius
    alignments.append(dict(component=component, shared_points=len(pairs), scale=float(transform.scale),
                           rotation=transform.rotation.matrix().tolist(), translation=transform.translation.tolist(),
                           test_fraction_below_2pct=float(np.mean(error[test] < .02)),
                           test_p90_relative_error=float(np.percentile(error[test], 90))))
    if component == 5:
        metric = next(v for v in json.loads((ROOT/'scale-bookcase-v1/result.json').read_text()) if v['component'] == '5')
        basis = np.array(metric['basis_rows'])
        def project(points):
            return (transform*points-metric['origin']) @ basis.T * metric['meters_per_unit']
        points = list(model.points3D.values())
        xyz = project(np.array([p.xyz for p in points]))
        cameras = project(np.array([i.projection_center() for i in references]))
        lo, hi = np.percentile(xyz[:, [0, 2]], [1, 99], axis=0)
        factor = min(1300/(hi-lo)[0], 850/(hi-lo)[1])
        picture = Image.new('RGB', (1400, 1000), '#20252a')
        draw = ImageDraw.Draw(picture)
        def pixel(v):
            return int(50+(v[0]-lo[0])*factor), int(940-(v[2]-lo[1])*factor)
        for p, v in zip(points, xyz):
            draw.point(pixel(v), fill=tuple(p.color))
        palette = dict(IMG_6380='cyan', IMG_6380_exit6fps='yellow', IMG_6384='magenta', IMG_6385='lime', IMG_6386='orange')
        for im, v in zip(references, cameras):
            x, y = pixel(v)
            draw.ellipse((x-2, y-2, x+2, y+2), fill=palette[im.name.split('/')[0]])
            if im.name in ['IMG_6380/000504.jpg', 'IMG_6380/000520.jpg']:
                draw.text((x+5, y), im.name, fill='white')
        draw.text((20, 15), 'Frozen joined model: observed points/cameras only; bookcase scale provisional; no accepted collision surfaces', fill='white')
        draw.text((20, 35), str(palette), fill='white')
        picture.save(OUT/'joined-plan.png')

report = dict(source='sfm-calibrated-doorway-v1/sparse/0', source_sha256=hashes,
              samples=len(rows), original_supported=sum(r['supported'] for r in rows),
              split_point_supported=sum(r['supported'] for r in evaluated), split_point_results=evaluated,
              component_consistency=alignments, nominal_time_exclusion_passed=True,
              caveat='Nearby held-out video frames, not independent capture sessions. Split image points test pose prediction but share reconstructed geometry. Component checks measure consistency with correlated seed models, not absolute accuracy. No metric/navigation acceptance.')
assert all(hashlib.sha256((SOURCE/p).read_bytes()).hexdigest() == h for p, h in hashes.items())
(OUT/'audit.json').write_text(json.dumps(report, indent=2))
print(json.dumps({k: v for k, v in report.items() if k not in ['split_point_results', 'source_sha256']}, indent=2))
