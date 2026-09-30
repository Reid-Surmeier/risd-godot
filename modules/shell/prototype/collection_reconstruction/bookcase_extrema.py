"""Triangulate visible bookcase endpoints without a whole-object planar fit (#182)."""
import argparse
import hashlib
import json
from pathlib import Path

import numpy as np
import pycolmap
from PIL import Image, ImageDraw
from measurements import project, triangulate

ROOT = Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
NAMES = ['IMG_6380/000292.jpg', 'IMG_6380/000297.jpg']
# Frozen source pixels: front rail corners and outer front castor contacts.
# They are corresponding features, not proven overall catalogue extrema.
PICKS = {'top_left': [[275, 410], [111, 378]],
         'top_right': [[598, 418], [623, 380]],
         'foot_left': [[307, 895], [169, 982]],
         'foot_right': [[574, 829], [562, 955]]}


def frame(points):
    left = points['top_left'] - points['foot_left']
    right = points['top_right'] - points['foot_right']
    up = left / np.linalg.norm(left) + right / np.linalg.norm(right)
    up /= np.linalg.norm(up)
    across = points['top_right'] - points['top_left']
    across -= up * (across @ up)
    width = np.linalg.norm(across)
    across /= width
    basis = np.array([across, up, np.cross(across, up)])
    height = np.mean([left @ up, right @ up])
    assert height > 0 and width > 0 and np.allclose(basis @ basis.T, np.eye(3))
    return basis, 1.515 / height, 1.100 / width


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', required=True, type=Path)
    parser.add_argument('--source', default='sfm-strict-doorway-v1')
    parser.add_argument('--selection', type=Path, help='Frozen source and reserved manual observations')
    args = parser.parse_args()
    args.output.mkdir(exist_ok=False, parents=True)
    selection = json.loads(args.selection.read_text()) if args.selection else dict(source_views=NAMES, picks=PICKS, reserved={})
    names, picks = selection['source_views'], selection['picks']
    assert all(len(p) == len(names) for p in picks.values())
    assert not set(names) & set(selection['reserved'])
    sparse = ROOT / args.source / 'sparse/0'
    files = list(sparse.glob('*.bin')) + [ROOT / 'survey-2fps' / n for n in names + list(selection['reserved'])]
    pins = {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in files}
    (args.output / 'annotations.json').write_text(json.dumps(selection, indent=2) + '\n')
    model = pycolmap.Reconstruction(sparse)
    views = {v.name: v for v in model.images.values()}
    cameras = {n: model.cameras[views[n].camera_id] for n in names}
    poses = {n: views[n].cam_from_world() for n in names}
    points, errors, angles = {}, {}, {}
    for label, pixels in picks.items():
        p, angles[label] = triangulate(cameras, poses, dict(zip(names, pixels)))
        points[label] = p
        errors[label] = [float(np.linalg.norm(project(cameras[n], poses[n], p) - xy))
                         for n, xy in zip(names, pixels)]
        assert min((pose * p)[2] for pose in poses.values()) > 0
        recovered, _ = triangulate(cameras, poses,
            {n: project(cameras[n], poses[n], p) for n in names})
        assert np.linalg.norm(p - recovered) < 1e-7
        assert min(np.linalg.norm(project(cameras[n], poses[n], p) - (np.array(xy) + [50, 0]))
                   for n, xy in zip(names, pixels)) > 40
    basis, height_scale, width_scale = frame(points)
    rng = np.random.default_rng(182)
    scales = []
    for _ in range(500):
        perturbed = {label: triangulate(cameras, poses,
            {n: np.array(xy) + rng.normal(0, 2, 2) for n, xy in zip(names, pixels)})[0]
            for label, pixels in picks.items()}
        scales.append(frame(perturbed)[1])
    result = dict(points_world={k: p.tolist() for k, p in points.items()},
        basis_rows=basis.tolist(), origin_world=points['foot_left'].tolist(),
        height_scale_m_per_unit=height_scale, width_scale_m_per_unit=width_scale,
        scale_disagreement_percent=100 * abs(height_scale / width_scale - 1),
        perturbation='500 trials, independent Gaussian sigma=2 upright pixels',
        height_scale_p05_p95=np.percentile(scales, [5, 95]).tolist(),
        ray_angles_degrees=angles, source_errors_px=errors, inputs_sha256=pins,
        source_views=names, provider='local NumPy/pycolmap', cost_usd=0,
        scale_accepted=False, navigation_accepted=False,
        caveat='Front rail/feet triangulated as separate 3D features. Catalogue overall '
               'dimensions 1.515h x 1.100w x .330d include the rear pierced rail; '
               'front picks are not proven overall extrema. Height scale is a prototype '
               'candidate; width disagreement and unseen depth prevent physical acceptance. '
               'Both cameras belong to the training clip; no independent capture validation.')
    reserved_errors = {}
    for n, observations in selection['reserved'].items():
        v = views[n]
        predictions = {k: project(model.cameras[v.camera_id], v.cam_from_world(), p) for k, p in points.items()}
        reserved_errors[n] = {k: float(np.linalg.norm(predictions[k] - xy)) for k, xy in observations.items()}
        im = Image.open(ROOT / 'survey-2fps' / n).transpose(Image.Transpose.ROTATE_270)
        draw = ImageDraw.Draw(im)
        for k, (x, y) in observations.items():
            draw.ellipse((x-6, y-6, x+6, y+6), outline='lime', width=2)
            a, b = predictions[k]
            draw.line((a-8, b, a+8, b), fill='red', width=2)
            draw.line((a, b-8, a, b+8), fill='red', width=2)
        im.save(args.output / ('reserved-' + Path(n).stem + '.png'))
    result['reserved_manual_errors_px'] = reserved_errors
    result['selection'] = selection
    (args.output / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
    for i, n in enumerate(names):
        im = Image.open(ROOT / 'survey-2fps' / n).transpose(Image.Transpose.ROTATE_270)
        draw = ImageDraw.Draw(im)
        for label, pixels in picks.items():
            x, y = pixels[i]
            draw.ellipse((x-6, y-6, x+6, y+6), outline='lime', width=2)
            draw.text((x+8, y), label, fill='lime')
        draw.rectangle((0, 0, 720, 50), fill='black')
        draw.text((10, 8), n + ': frozen endpoint picks, no planar homography', fill='white')
        draw.text((10, 28), 'Prototype scale only: overall catalogue extrema still unverified', fill='white')
        im.save(args.output / (Path(n).stem + '.png'))
    assert pins == {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in files}
    print(json.dumps({k: result[k] for k in ['height_scale_m_per_unit',
        'width_scale_m_per_unit', 'height_scale_p05_p95', 'scale_disagreement_percent']}))


if __name__ == '__main__':
    main()
