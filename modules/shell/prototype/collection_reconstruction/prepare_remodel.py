"""#182/#183 standalone low polygon room; no point cloud in the render or pack.

Run: /usr/bin/python3 modules/shell/prototype/collection_reconstruction/prepare_remodel.py OUTPUT
Then Godot --path OUTPUT --selfcheck --out=OUTPUT/evidence (arguments after --).
"""
import argparse
import hashlib
import json
from pathlib import Path
import shutil

import cv2
import numpy as np
from PIL import Image

parser = argparse.ArgumentParser()
parser.add_argument('output', type=Path)
args = parser.parse_args()
out = args.output
out.mkdir(parents=True, exist_ok=False)
(out/'assets').mkdir()
(out/'evidence').mkdir()
(out/'web').mkdir()
repo = Path(__file__).resolve().parents[4]
source = Path(__file__).parent
app = repo/'image-work/collection-room-remodel'
ingestion = Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
inputs = {}

def copy(original, relative):
    original = Path(original)
    target = out/relative
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(original, target)
    inputs[str(original)] = hashlib.sha256(original.read_bytes()).hexdigest()

for kind in ['bookcase', 'mirror']:
    path = app/'trial'/f'{kind}-original.webp'
    image = np.array(Image.open(path).convert('RGB'))
    hsv = cv2.cvtColor(image, cv2.COLOR_RGB2HSV)
    chroma = (hsv[:,:,0]>=125)&(hsv[:,:,0]<=175)&(hsv[:,:,1]>70)&(hsv[:,:,2]>35)
    alpha = (~chroma).astype('uint8')*255
    assert .1 < np.mean(alpha>0) < .9
    # Transparent texels carry a neutral asset edge tone to prevent magenta mip fringes.
    # Visible source RGB is unchanged; native Muse rasters remain archived intact.
    image[chroma] = [103,64,36] if kind == 'bookcase' else [162,124,55]
    Image.fromarray(np.dstack([image, alpha])).save(out/'assets'/f'{kind}.png')
    inputs[str(path)] = hashlib.sha256(path.read_bytes()).hexdigest()
    if kind == 'mirror':
        contours, _ = cv2.findContours(alpha, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        contour = cv2.approxPolyDP(max(contours, key=cv2.contourArea), 2.5, True)[:,0,:]
        assert 20 < len(contour) < 600
        outline = contour/[image.shape[1],image.shape[0]]
        (out/'assets/mirror-outline.json').write_text(json.dumps(dict(outline=outline.tolist(),
            vertices=len(outline),key='magenta chroma; original RGB unchanged',
            holes='front alpha cut, not physically modeled pierced side walls'),indent=2)+'\n')
    else:
        assert image.shape[:2] == (1760,1440), 'Bookcase authored UV rectangles need a new review for changed raster dimensions'
geometry = json.loads((ingestion/'room-route-walk-v5/geometry.json').read_text())
geometry['caption'] = 'Collection · WASD move · Space reset · 1/2 room views\nRoom prototype · placements and unfinished objects are provisional.\n'
geometry['point_cloud_render'] = False
(out/'geometry.json').write_text(json.dumps(geometry,indent=2)+'\n')
inputs[str(ingestion/'room-route-walk-v5/geometry.json')] = hashlib.sha256((ingestion/'room-route-walk-v5/geometry.json').read_bytes()).hexdigest()
for name in ['doorway_walk.gd','remodel_room.gd','remodel_review.gd']:
    copy(source/name,name)
visitor_source = repo/'image-work/collection-room-remodel/main-hall-visitor159'
for path in visitor_source.rglob('*'):
    if path.is_file():
        copy(path,'modules/shell/prototype/gallery_walk4/visitor159/'+str(path.relative_to(visitor_source)))
for name in ['painting_asset.gd','ps1.gdshader']:
    copy(repo/'modules/shell/prototype/gallery_walk4'/name,'modules/shell/prototype/gallery_walk4/'+name)
for name in ['oak-muse.webp','wall-muse.webp']:
    copy(repo/'modules/shell/prototype/gallery_walk4/textures'/name,'textures/'+name)
copy(app/'trial/sofa-cloth-original.webp','assets/sofa-cloth.webp')
frame = repo/'image-work/collection-expansion-frame'
for name, origin in [('frame.png','trial/frame.png'),('frame-geometry.json','trial/geometry.json'),('painting-35.786.jpg','references/painting-35.786.jpg')]:
    copy(frame/origin,'assets/'+name)
(out/'remodel_room.tscn').write_text('[gd_scene load_steps=2 format=3]\n[ext_resource type="Script" path="res://remodel_room.gd" id="1"]\n[node name="CollectionRemodel" type="Node3D"]\nscript = ExtResource("1")\n')
(out/'project.godot').write_text('config_version=5\n[application]\nconfig/name="Collection low polygon rooms"\nrun/main_scene="res://remodel_room.tscn"\n[display]\nwindow/size/viewport_width=1100\nwindow/size/viewport_height=760\n[rendering]\nrenderer/rendering_method="gl_compatibility"\n')
(out/'export_presets.cfg').write_text('[preset.0]\nname="Web"\nplatform="Web"\nrunnable=true\nexport_filter="all_resources"\ninclude_filter="geometry.json,assets/*.json"\nexclude_filter="web/*,evidence/*,manifest.json"\nexport_path="web/index.html"\n[preset.0.options]\nvariant/thread_support=false\nhtml/export_icon=false\nhtml/canvas_resize_policy=2\n')
(out/'manifest.json').write_text(json.dumps(dict(source_sha256=inputs,point_cloud_render=False,
    room_extents='provisional captured spacing guide; no new connectors',
    bookcase_dimensions_m=[1.1,1.515,.33],mirror_dimensions_m=[.78,1.95],
    mirror_pair='repeated source mirror proxy; second identity and size unverified',
    sofa_vessels='provisional sofa geometry with source-guided Muse cloth; vessels are authored placeholders',
    lighting='Muse baked asset appearance plus provisional live room light; offline UV2 pending'),indent=2)+'\n')
assert not (out/'points.bin').exists()
assert all(hashlib.sha256(Path(p).read_bytes()).hexdigest()==h for p,h in inputs.items())
print(out)
