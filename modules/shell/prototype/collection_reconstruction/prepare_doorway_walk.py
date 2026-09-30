"""Build an isolated Godot doorway trial from cached measurements; no runtime edits."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil

import numpy as np
import pycolmap
from PIL import Image, ImageDraw

parser = argparse.ArgumentParser()
parser.add_argument('output', type=Path)
out = parser.parse_args().output
out.mkdir(parents=True, exist_ok=False)
root = Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
repo = Path(__file__).resolve().parents[4]
source = Path(__file__).resolve().parent
inputs = {}


def read(relative):
    path = root/relative
    inputs[str(path)] = hashlib.sha256(path.read_bytes()).hexdigest()
    return json.loads(path.read_text())


aperture = read('doorway-aperture-v1/result.json')
near = read('corridor-floor-v2/result.json')
floor = read('floor-patches-v2/result.json')
origin = np.array(aperture['origin_world'])
basis = np.array(aperture['basis_rows'])
scale = aperture['provisional_m_per_unit']


def local(points):
    return (np.asarray(points)-origin)@basis.T*scale


def level_at(points, plane):
    points = np.asarray(points)
    normal = np.array(plane['normal_world'])
    return points+((np.array(plane['center_world'])-points)@normal/(basis[1]@normal))[:, None]*basis[1]


for path in (root/'dense-doorway-calibrated-v2/sparse').glob('*.bin'):
    inputs[str(path)] = hashlib.sha256(path.read_bytes()).hexdigest()
model = pycolmap.Reconstruction(root/'dense-doorway-calibrated-v2/sparse')
view = next(v for v in model.images.values() if v.name == floor['source'])
camera = model.cameras[view.camera_id]
far = floor['patches'][1]
pixels = np.array(far['polygon'])
rays = np.c_[camera.cam_from_img(np.c_[pixels[:, 1], 359-pixels[:, 0]]), np.ones(4)]@view.cam_from_world().rotation.matrix()
eye = view.cam_from_world().inverse().translation
normal = np.array(far['normal_world'])
far_corners = eye+rays*((np.array(far['center_world'])-eye)@normal/(rays@normal))[:, None]
assert np.max(abs((far_corners-far['center_world'])@normal)) < 1e-8
threshold = read('threshold-landmarks-v1/result.json')
outer = level_at(np.array(threshold['points_world'])[2:4], near)
inner = level_at(np.array(aperture['corners_world'])[:2], far)
# The measured patches are connected by visible-floor interpolation, explicitly
# an experimental collision surface, not surveyed steps or physical room bounds.
patches = [dict(label='near measured support', color='76658c', vertices=local(near['support_world']).tolist()),
           dict(label='threshold interpolation', color='cba96c', vertices=local([outer[0], outer[1], inner[1], inner[0]]).tolist()),
           dict(label='near toe fill', color='cba96c', vertices=local([outer[0], near['support_world'][1], outer[1]]).tolist()),
           dict(label='far visible floor interpolation', color='608b8c', vertices=local([inner[0], inner[1], far_corners[1], far_corners[0]]).tolist())]
geometry = dict(patches=patches, aperture=aperture['opening_local_m'],
    source_sha256=inputs, provisional_m_per_unit=scale, navigation_accepted=False,
    caveat='Bounded doorway traversal only. Gold floor interpolates uncertain levels. '
           'Coloured patch edges are study limits, not museum walls. Jamb boxes are conservative proxies. '
           'No whole-room extents, independent scale, final lighting or production integration.')
(out/'geometry.json').write_text(json.dumps(geometry, indent=2)+'\n')
image = Image.new('RGB', (1000, 800), '#202934')
draw = ImageDraw.Draw(image)
draw.text((25, 20), 'Bounded doorway traversal: provisional metres', fill='white')
draw.text((25, 42), 'Patch edges are study limits, NOT museum walls. Gold connects uncertain floor levels.', fill='white')
def pixel(x, z):
    return (int(500+x*175), int(420+z*175))
for patch in patches:
    polygon = [pixel(p[0], p[2]) for p in patch['vertices']]
    draw.polygon(polygon, fill='#'+patch['color'], outline='white')
for a, b in [(0, 2), (1, 3)]:
    p, q = aperture['opening_local_m'][a], aperture['opening_local_m'][b]
    draw.line([pixel(p[0], p[2]), pixel(q[0], q[2])], fill='white', width=6)
draw.line([pixel(.55, .75), pixel(0, -1.3)], fill='#ffe484', width=3)
for x, z, text in [(.55, .75, 'start / return'), (0, -1.3, 'crossing target')]:
    px, py = pixel(x, z)
    draw.ellipse((px-5, py-5, px+5, py+5), fill='#ffe484')
    draw.text((px+10, py), text, fill='white')
draw.line((30, 720, 205, 720), fill='white', width=3)
draw.text((30, 735), '1 provisional metre', fill='white')
draw.text((30, 765), 'Purple: corridor support. Teal: visible far-floor patch extended to measured opening. No full rooms.', fill='white')
image.save(out/'plan.png')
for filename in ['doorway_walk.gd', 'doorway_walk.tscn']:
    shutil.copyfile(source/filename, out/filename)
for relative in ['modules/shell/prototype/gallery_walk4/rig/visitor.gd',
                 'modules/shell/prototype/gallery_walk4/identity/visitor_identity.glb']:
    target = out/relative
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(repo/relative, target)
    inputs[str(repo/relative)] = hashlib.sha256((repo/relative).read_bytes()).hexdigest()
(out/'project.godot').write_text('config_version=5\n[application]\nconfig/name="Collection doorway study"\nrun/main_scene="res://doorway_walk.tscn"\n[display]\nwindow/size/viewport_width=1100\nwindow/size/viewport_height=760\n[rendering]\nrenderer/rendering_method="gl_compatibility"\ntextures/default_filters/use_nearest_mipmap_filter=false\n')
(out/'export_presets.cfg').write_text('[preset.0]\nname="Web"\nplatform="Web"\nrunnable=true\nexport_filter="all_resources"\ninclude_filter="geometry.json"\nexclude_filter="web/*,evidence/*"\nexport_path="web/index.html"\n[preset.0.options]\nvariant/thread_support=false\nhtml/export_icon=false\nhtml/canvas_resize_policy=2\n')
(out/'provenance.json').write_text(json.dumps(dict(inputs_sha256=inputs, provider='local Godot/NumPy/pycolmap', cost_usd=0), indent=2)+'\n')
print(out)
