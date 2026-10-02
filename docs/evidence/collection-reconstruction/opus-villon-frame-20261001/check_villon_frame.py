"""Villon 70.058 frame check: official pixels kept, oval mask/rim topology, no rectangular border. CPU only.

Run: /usr/bin/python3 check_villon_frame.py OUTPUT
OUTPUT is a project written by prepare_remodel.py. Godot runs headless (no GPU, no render) to build the real
room scene and hand back the Villon meshes; it imports OUTPUT first if that has not been done.
"""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

import cv2
import numpy as np
from PIL import Image

out = Path(sys.argv[1]).resolve()
godot = os.environ.get('GODOT', 'godot')
CANVAS = (.460, .548)  # catalogue size passed to build_shaped in remodel_room.gd
failed = []

def check(name, ok, detail=''):
    print(('PASS ' if ok else 'FAIL ') + name + (' | ' + str(detail) if detail != '' else ''))
    if not ok:
        failed.append(name)

def ellipse_points(width, height, count=720):
    """Boundary points and outward unit normals of the ellipse inscribed in a width x height pixel box."""
    t = np.linspace(0, 2*np.pi, count, endpoint=False)
    edge = np.stack([width/2 + width/2*np.cos(t), height/2 + height/2*np.sin(t)], 1)
    normal = np.stack([np.cos(t)/width, np.sin(t)/height], 1)
    return edge, normal/np.linalg.norm(normal, axis=1)[:, None]

def last_dark_run(dark, edge, normal, reach=(-40, 61)):
    """Per boundary point: offsets (px along the outward normal) where the outermost dark run starts and ends."""
    runs = []
    for e, n in zip(edge, normal):
        hits = []
        for s in range(*reach):
            x, y = np.rint(e + s*n - .5).astype(int)
            hits.append(0 <= y < dark.shape[0] and 0 <= x < dark.shape[1] and bool(dark[y, x]))
        index = np.flatnonzero(hits)
        if len(index) == 0:
            runs.append(None)
            continue
        first = last = index[-1]
        while first > 0 and hits[first-1]:
            first -= 1
        runs.append((first + reach[0], last + reach[0]))
    return runs

# --- A. Official artwork pixels inside the oval -------------------------------------------------------------------
proof = json.loads((out/'assets/villon-oval-source-proof.json').read_text())
manifest = json.loads((out/'manifest.json').read_text())['source_sha256']
official_path = out/'assets/villon-official-original.jpg'
official_hash = hashlib.sha256(official_path.read_bytes()).hexdigest()
check('official museum JPEG is the hashed catalogue source, byte-identical',
      official_hash in [h for p, h in manifest.items() if p.endswith('villon-head-woman-zoom-0.jpg')], official_hash)
official = np.array(Image.open(official_path).convert('RGB'))
x0, y0, x1, y1 = proof['crop_px']
source = official[y0:y1, x0:x1]
art = np.array(Image.open(out/'assets/painting-70.058.png').convert('RGB'))
height, width = art.shape[:2]
check('artwork texture is the official crop, no resampling', art.shape == source.shape, f'{width}x{height} from crop {proof["crop_px"]}')
yy, xx = np.indices((height, width))
inside = ((xx + .5 - width/2)/(width/2))**2 + ((yy + .5 - height/2)/(height/2))**2 <= 1
changed = int(np.any(art[inside] != source[inside], axis=1).sum()) if art.shape == source.shape else -1
check('every pixel inside the oval equals the official photograph', changed == 0, f'{changed} changed of {int(inside.sum())}')
check('outside the oval the texture is plain white backing', bool(np.all(art[~inside] == 255)))
# The 48-gon the room draws (same expression as remodel_room.gd): texels it can show = pixel centres inside it.
angles = np.arange(48)*2*np.pi/48
polygon = np.stack([(.5 + .5*np.cos(angles))*width, (.5 + .5*np.sin(angles))*height], 1)
shown = np.ones((height, width), bool)
for a, b in zip(polygon, np.roll(polygon, -1, 0)):
    shown &= (b[0]-a[0])*(yy + .5 - a[1]) - (b[1]-a[1])*(xx + .5 - a[0]) >= 0
check('the drawn 48-sided oval shows only official pixels', not np.any(shown & ~inside),
      f'{int(shown.sum())} texels shown, {shown.sum()/inside.sum():.4%} of the ellipse')
aspect_error = (width/height)/(CANVAS[0]/CANVAS[1]) - 1
check('oval artwork is not stretched onto its catalogue canvas', abs(aspect_error) < .001, f'aspect error {aspect_error:+.4%}')
# The photographed black rim must stay outside the oval, so the only rim seen is the Muse one.
edge, normal = ellipse_points(width, height)
runs = last_dark_run(official.max(axis=2) < 70, edge + [x0, y0], normal)
rim = [r for r in runs if r and r[1] - r[0] < 24]  # angles where the rim is not merged with black paint
inner = [r[0] for r in rim]
check('photographed rim and backing stay outside the oval at every probed angle', len(rim) > 360 and min(inner) >= 1,
      f'{len(rim)} angles; rim starts {min(inner)}..{max(inner)} px outside the oval, median {int(np.median(inner))}')

# --- B. Muse box texture: one oval ring, no rectangle -------------------------------------------------------------
frame = np.array(Image.open(out/'assets/villon-frame.png').convert('RGBA'))
geometry = json.loads((out/'assets/villon-frame-geometry.json').read_text())
left, top, right, bottom = [int(m) for m in geometry['margins_px']]
frame_h, frame_w = frame.shape[:2]
open_w, open_h = frame_w - left - right, frame_h - top - bottom
check('box texture is opaque edge to edge: no opening is cut', bool(np.all(frame[4:-4, 4:-4, 3] == 255)))
check('oval opening has the catalogue aspect and is centred', abs(open_w/open_h/(CANVAS[0]/CANVAS[1]) - 1) < .002 and left == right and top == bottom,
      f'opening {open_w}x{open_h}px, margins {geometry["margins_px"]}')
# Dark texels in and 40px around the opening, where the old rectangular border sat. (The box's own corner shading
# lies further out, against its outer walls.)
dark = np.zeros((frame_h, frame_w), 'uint8')
near = np.s_[top-40:frame_h-bottom+40, left-40:frame_w-right+40]
dark[near] = frame[:, :, :3].max(axis=2)[near] < 140
count, labels, stats, _ = cv2.connectedComponentsWithStats(dark)
contours, tree = cv2.findContours(dark, cv2.RETR_CCOMP, cv2.CHAIN_APPROX_NONE)
holes = sum(1 for c, node in zip(contours, tree[0]) if node[3] >= 0 and cv2.contourArea(c) > 1000) if len(contours) else 0
check('dark rim is one closed ring: a single dark piece with a single hole', count == 2 and holes == 1, f'{count-1} dark pieces, {holes} holes')
edge, normal = ellipse_points(open_w, open_h)
runs = last_dark_run(dark > 0, edge + [left, top], normal)
thickness = [r[1] - r[0] + 1 for r in runs if r]
starts = [r[0] for r in runs if r]
check('rim follows the oval at an even, thin width all the way round',
      len(thickness) == len(runs) and min(thickness) >= 6 and max(thickness) <= 16 and min(starts) >= -3 and max(starts) <= 4,
      f'width {min(thickness)}..{max(thickness)} px (={min(thickness)*CANVAS[1]/open_h*1000:.1f}..{max(thickness)*CANVAS[1]/open_h*1000:.1f} mm), starts {min(starts)}..{max(starts)} px from the oval')
def longest_run(mask):
    best = 0
    for row in mask:
        change = np.flatnonzero(np.diff(np.r_[0, row, 0]))
        best = max(best, int((change[1::2] - change[::2]).max()) if len(change) else 0)
    return best
straight = (longest_run(dark)/frame_w, longest_run(dark.T)/frame_h)
opening = ((np.indices((frame_h, frame_w))[1] + .5 - left - open_w/2)/(open_w/2 - 5))**2 + ((np.indices((frame_h, frame_w))[0] + .5 - top - open_h/2)/(open_h/2 - 5))**2 <= 1
check('opening under the artwork is clean Muse white', int(frame[:, :, :3].min(axis=2)[opening].min()) >= 235, f'darkest value {int(frame[:, :, :3].min(axis=2)[opening].min())}')
# An oval ring this thin meets a tangent line for under a fifth of the texture; a rectangular border runs most of it.
check('no straight dark border line around the opening', max(straight) < .35, f'longest dark run {straight[0]:.1%} of width, {straight[1]:.1%} of height')

# --- C. The meshes the real room code builds ----------------------------------------------------------------------
room_source = (out/'remodel_room.gd').read_text()
check('room code no longer builds the Villon as a framed rectangle', 'villon.build_framed' not in room_source and 'villon.build_shaped' in room_source)
probe = '''extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var room=load("res://remodel_room.tscn").instantiate()
	root.add_child(room)
	await process_frame
	var work:Array=room.get_children().filter(func(n):return n is Node3D and n.get_meta("catalogue_accession","")=="70.058")
	var facts:={"works":work.size(),"outer":[work[0].outer.x,work[0].outer.y],"surfaces":[]}
	for mi in work[0].find_children("*","MeshInstance3D",true,false):
		var offset:Vector3=Vector3.ZERO if mi.get_parent()==work[0] else mi.get_parent().position
		var points:Array=[]
		for v in mi.mesh.get_faces():
			points.append([v.x+offset.x,v.y+offset.y,v.z+offset.z])
		facts.surfaces.append(points)
	print("VILLON_MESH "+JSON.stringify(facts))
	quit()
'''
if not (out/'.godot/imported').exists():
    subprocess.run([godot, '--headless', '--path', str(out), '--import'], capture_output=True, timeout=600)
with tempfile.TemporaryDirectory() as folder:
    script = Path(folder)/'villon_probe.gd'
    script.write_text(probe)
    log = subprocess.run([godot, '--headless', '--path', str(out), '-s', str(script)], capture_output=True, text=True, timeout=300).stdout
lines = [line for line in log.splitlines() if line.startswith('VILLON_MESH ')]
check('headless Godot built the room and found one 70.058 work', len(lines) == 1)
if lines:
    facts = json.loads(lines[0][len('VILLON_MESH '):])
    half = np.array(facts['outer'])/2
    a, b = CANVAS[0]/2, CANVAS[1]/2
    triangles = [np.array(s).reshape(-1, 3, 3) for s in facts['surfaces']]
    fronts, sides = [], []
    for surface in triangles:
        (fronts if np.ptp(surface[:, :, 2]) < 1e-6 else sides).append(surface)
    area = lambda surface: float(sum(np.linalg.norm(np.cross(t[1] - t[0], t[2] - t[0]))/2 for t in surface))
    on_ellipse = lambda p: np.abs((p[..., 0]/a)**2 + (p[..., 1]/b)**2 - 1) < 1e-3
    # Godot hands faces back snapped to 0.1 mm, hence the tolerances.
    on_box_edge = lambda p: (np.abs(np.abs(p[..., 0]) - half[0]) < 2e-4) | (np.abs(np.abs(p[..., 1]) - half[1]) < 2e-4)
    check('work is two closed slabs: 2 front faces and 2 side walls', len(fronts) == 2 and len(sides) == 2, f'{len(fronts)} fronts, {len(sides)} side sets')
    if len(fronts) == 2 and len(sides) == 2:
        box, oval = sorted(fronts, key=area, reverse=True)
        check('box face is one unbroken rectangle the size of the whole frame: nothing is cut out of it',
              len(box) == 2 and abs(area(box) - 4*half[0]*half[1]) < 5e-4, f'{len(box)} triangles, {area(box):.5f} m2 of {4*half[0]*half[1]:.5f} m2')
        ideal = 24*np.sin(2*np.pi/48)*a*b
        check('artwork face is a 48-sided oval of the catalogue size', len(oval) == 46 and bool(np.all(on_ellipse(oval))) and abs(area(oval) - ideal) < 5e-4,
              f'{len(oval)} triangles, {area(oval):.5f} m2 of {ideal:.5f} m2')
        lift = float(oval[0, 0, 2] - box[0, 0, 2])
        check('artwork stands just proud of the backing', .001 < lift < .02, f'{lift*1000:.1f} mm')
        walls = np.concatenate(sides)
        box_walls = np.all(on_box_edge(walls), axis=1)
        oval_walls = np.all(on_ellipse(walls), axis=1)
        check('every side wall is either the box outer edge or the oval edge: no rectangular inner reveal exists',
              bool(np.all(box_walls | oval_walls)) and int(box_walls.sum()) == 8 and int(oval_walls.sum()) == 96,
              f'{int(box_walls.sum())} outer-box triangles, {int(oval_walls.sum())} oval triangles, {int((~(box_walls | oval_walls)).sum())} other')
        corner = np.concatenate(triangles).reshape(-1, 3)
        at_corner = (np.abs(np.abs(corner[:, 0]) - a) < 1e-4) & (np.abs(np.abs(corner[:, 1]) - b) < 1e-4)
        check('no vertex sits on the old rectangular canvas corners', not np.any(at_corner), f'{int(at_corner.sum())} vertices')

print('VILLON_FRAME_OK' if not failed else 'VILLON_FRAME_FAILED ' + json.dumps(failed))
sys.exit(1 if failed else 0)
