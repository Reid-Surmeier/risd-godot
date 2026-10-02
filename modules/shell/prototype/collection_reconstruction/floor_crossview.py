"""Project frozen floor patches into other cached depth views without refitting."""
import argparse
import hashlib
import json
from pathlib import Path

import numpy as np
import pycolmap
from PIL import Image, ImageDraw

ROOT = Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
DENSE = ROOT/'dense-doorway-calibrated-v2'
OUT = ROOT/'floor-crossview-v1'
SOURCE = ROOT/'floor-patches-v2/result.json'
TARGETS = ['IMG_6380/000505.jpg'] + [f'IMG_6380_exit6fps/{i:06}.jpg' for i in (10, 14, 18, 22, 26)]
parser = argparse.ArgumentParser()
parser.add_argument('--strict', action='store_true', help='Corrected model, without historical metric scale')
parser.add_argument('--output')
args = parser.parse_args()
if args.strict:
    DENSE = ROOT/'dense-strict-floor-v1'
    SOURCE = ROOT/'strict-depth-floor-v1/result.json'
    OUT = ROOT/'strict-floor-crossview-v1'
if args.output:
    OUT = ROOT/args.output
assert not (OUT/'result.json').exists(), 'Preserve completed cross-view diagnostics.'


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def read_depth(path):
    with path.open('rb') as stream:
        header = b''
        while header.count(b'&') < 3:
            byte = stream.read(1)
            assert byte, 'Truncated depth header'
            header += byte
        width, height, channels = map(int, header[:-1].split(b'&'))
        assert (width, height, channels) == (640, 360, 1)
        data = np.frombuffer(stream.read(), dtype='<f4')
        assert data.size == width*height, 'Truncated depth data'
        return data.reshape((width, height), order='F').T


def raw(pixels):
    pixels = np.asarray(pixels)
    return np.stack([pixels[..., 1], 359-pixels[..., 0]], axis=-1)


def plane_polygon(camera, pose, polygon, center, normal):
    rays = np.c_[camera.cam_from_img(raw(polygon)), np.ones(len(polygon))]
    rays = rays @ pose.rotation.matrix()
    origin = pose.inverse().translation
    distance = ((center-origin)@normal)/(rays@normal)
    assert np.all(distance > 0), 'Patch intersects plane behind source camera'
    return origin + rays*distance[:, None]


def project(camera, pose, xyz):
    points = pose*xyz
    assert np.all(points[:, 2] > 0), 'Patch behind target camera'
    pixels = camera.img_from_cam(points)
    return np.c_[359-pixels[:, 1], pixels[:, 0]]


source = json.loads(SOURCE.read_text())
scale = 1. if args.strict else source['provisional_m_per_unit']
units = 'world_units' if args.strict else 'm'
model = pycolmap.Reconstruction(DENSE/'sparse')
views = {view.name: view for view in model.images.values()}
if args.strict:
    TARGETS = sorted(views)
    assert not set(TARGETS) & {'IMG_6380_exit6fps/000021.jpg', 'IMG_6380_exit6fps/000025.jpg'}
source_view = views[source['source']]
source_camera = model.cameras[source_view.camera_id]
assert (source_camera.width, source_camera.height) == (640, 360)
image_sha = source['annotations']['image_sha256'] if args.strict else source['image_sha256']
assert sha(DENSE/'images'/source_view.name) == image_sha
assert sha(DENSE/'stereo/depth_maps'/(source_view.name+'.geometric.bin')) == source['depth_sha256']
inputs = {str(SOURCE): sha(SOURCE)}
inputs.update({str(path): sha(path) for path in (DENSE/'sparse').glob('*.bin')})
OUT.mkdir(exist_ok=True)
rows = []
seen = {}
for name in TARGETS:
    view = views[name]
    camera = model.cameras[view.camera_id]
    assert (camera.width, camera.height) == (640, 360)
    path = DENSE/'stereo/depth_maps'/(name+'.geometric.bin')
    depth = read_depth(path)
    image_path = DENSE/'images'/name
    inputs.update({str(path): sha(path), str(image_path): sha(image_path)})
    signature = (inputs[str(image_path)], inputs[str(path)])
    if signature in seen:
        rows.append(dict(view=name, duplicate_of=seen[signature], status='identical image and depth; not counted again'))
        continue
    seen[signature] = name
    picture = Image.open(image_path).transpose(Image.Transpose.ROTATE_270).convert('RGB')
    assert picture.size == (360, 640)
    draw = ImageDraw.Draw(picture)
    for patch, color in zip(source['patches'], ['lime', 'cyan']):
        center, normal = np.array(patch['center_world']), np.array(patch['normal_world'])
        corners = plane_polygon(source_camera, source_view.cam_from_world(), patch['polygon'], center, normal)
        if np.any((view.cam_from_world()*corners)[:, 2] <= 0):
            rows.append(dict(view=name, patch=patch['patch'], status='patch crosses camera plane; not evaluated'))
            continue
        polygon = project(camera, view.cam_from_world(), corners)
        # One runnable projection check and a displaced-plane negative control.
        assert np.max(np.abs((corners-center)@normal)) < 1e-8
        assert np.max(np.abs(project(source_camera, source_view.cam_from_world(), corners)-patch['polygon'])) < 1e-7
        assert np.min(np.abs((corners+normal*.1/scale-center)@normal)*scale) > .099
        mask = Image.new('1', picture.size)
        vertices = [tuple(p) for p in np.rint(polygon).astype(int)]
        ImageDraw.Draw(mask).polygon(vertices, fill=1)
        y, x = np.nonzero(np.array(mask))
        z = depth[359-x, y]
        valid = np.isfinite(z) & (z > 0)
        pixels = raw(np.c_[x[valid], y[valid]])
        xyz = view.cam_from_world().inverse()*(np.c_[camera.cam_from_img(pixels), np.ones(valid.sum())]*z[valid, None])
        residual = (xyz-center)@normal*scale
        # Relative camera depth avoids inventing metres for the corrected model.
        relative = np.abs(residual)/z[valid] if args.strict else np.abs(residual)/.025
        threshold = .01 if args.strict else 1.
        for px, py, error in zip(x[valid], y[valid], relative):
            draw.point((int(px), int(py)), fill=color if error < threshold else 'orange')
        draw.line(vertices+[vertices[0]], fill=color, width=2)
        row = dict(view=name, patch=patch['patch'], source_control=name == source_view.name,
                   projected_polygon=polygon.tolist(), visible_mask_pixels=len(x), valid_depth_samples=int(valid.sum()),
                   valid_depth_fraction=float(valid.mean()) if len(x) else None)
        if len(residual):
            row.update({('fraction_below_1pct_camera_depth' if args.strict else 'support_25mm'): float(np.mean(relative < threshold)),
                       'signed_p10_p50_p90_'+units: np.percentile(residual, [10, 50, 90]).tolist(),
                       'absolute_p50_p90_'+units: np.percentile(np.abs(residual), [50, 90]).tolist()})
            if args.strict:
                row['absolute_p50_p90_fraction_camera_depth'] = np.percentile(relative, [50, 90]).tolist()
        sparse = []
        for point in view.points2D:
            px, py = np.rint([359-point.xy[1], point.xy[0]]).astype(int)
            if point.has_point3D() and 0 <= px < 360 and 0 <= py < 640 and mask.getpixel((px, py)):
                sparse.append(point.point3D_id)
        row['sparse_point_ids'] = sorted(set(sparse))
        if sparse:
            errors = (np.array([model.points3D[i].xyz for i in sparse])-center)@normal*scale
            row['sparse_signed_p10_p50_p90_'+units] = np.percentile(errors, [10, 50, 90]).tolist()
        rows.append(row)
    draw.rectangle((0, 0, 360, 34), fill='black')
    draw.text((4, 2), name, fill='white')
    legend = '1% camera depth' if args.strict else '25mm'
    draw.text((4, 14), 'Green/cyan: fixed plane residual <'+legend, fill='white')
    draw.text((4, 24), 'Orange: larger; photo: missing depth', fill='white')
    picture.resize((720, 1280)).save(OUT/(name.replace('/', '-')+'.png'))
report = dict(source=str(SOURCE), inputs_sha256=inputs, targets=TARGETS, rows=rows,
              provisional_m_per_unit=None if args.strict else scale, navigation_accepted=False,
              caveat='Frozen planes and patch extents; no target refit or residual-based rejection. '
              'Shared multiview stereo inputs are correlated, not independent held-out captures. '
              'Projected polygons require visual occlusion review. '+legend+' is an exploratory diagnostic, '
              'not the owner quality contract. Absolute scale remains provisional.')
assert all(sha(Path(path)) == digest for path, digest in inputs.items())
(OUT/'result.json').write_text(json.dumps(report, indent=2)+'\n')
print(json.dumps(rows, indent=2))
