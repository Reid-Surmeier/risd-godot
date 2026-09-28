"""#154: compare real source holes with UV splits; weld only coincident points.

Run: blender -b -P docs/research/proton-scan-validation/relief_seam_trial.py
Outputs are disposable. Source files and accepted candidates are read-only.
"""
import hashlib
import json
from pathlib import Path

import bpy
import bmesh
from mathutils import Vector

ROOT = Path('/home/reidsurmeier/risd-godot-ingestion/proton/20260811122415')
OUT = Path('/tmp/risd-scan-154-relief-seams')
OUT.mkdir(exist_ok=True)
EVIDENCE = Path(__file__).parent / 'relief-seam-trial.json'
report = {'weld_distance_normalized_units': 0.000001, 'source_yaw_degrees': 180, 'inputs': {}, 'meshes': {}}
for path in [ROOT / ('20260811122415.' + ext) for ext in ('obj', 'mtl', 'jpg')] + [ROOT / 'candidate-120k/proton-scan-20260811122415.glb']:
    report['inputs'][str(path)] = hashlib.sha256(path.read_bytes()).hexdigest()
assert report['inputs'][str(ROOT / '20260811122415.obj')] == '9f5fda816915b8e02620f64da22450158f683b05e24014fde9732141416f1d48'

def stats(bm):
    bm.verts.ensure_lookup_table()
    seen = set()
    sizes = []
    for v in bm.verts:
        if v.index in seen:
            continue
        queue = [v]
        seen.add(v.index)
        size = 0
        while queue:
            current = queue.pop()
            size += 1
            for edge in current.link_edges:
                other = edge.other_vert(current)
                if other.index not in seen:
                    seen.add(other.index)
                    queue.append(other)
        sizes.append(size)
    edges = [e for e in bm.edges if e.is_boundary]
    return {'vertices': len(bm.verts), 'faces': len(bm.faces), 'components': len(sizes),
            'largest_components': sorted(sizes, reverse=True)[:5],
            'open_edges': len(edges),
            'pedestal_open_edges_below_z_1': sum(max(v.co.z for v in e.verts) < 1 for e in edges),
            'open_edge_length': sum(e.calc_length() for e in edges)}

for mode in ('candidate', 'source'):
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete(use_global=False)
    if mode == 'candidate':
        bpy.ops.import_scene.gltf(filepath=str(ROOT / 'candidate-120k/proton-scan-20260811122415.glb'))
    else:
        bpy.ops.wm.obj_import(filepath=str(ROOT / '20260811122415.obj'), forward_axis='Y', up_axis='Z')
    obj = next(o for o in bpy.context.scene.objects if o.type == 'MESH')
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    if mode == 'source':
        lo = Vector([min(v.co[a] for v in obj.data.vertices) for a in range(3)])
        hi = Vector([max(v.co[a] for v in obj.data.vertices) for a in range(3)])
        center = (lo + hi) / 2
        center.z = lo.z
        factor = 4.5 / max(hi - lo)
        for v in obj.data.vertices:
            v.co = (v.co - center) * factor
            # Match the selected GLB's horizontal orientation, preserving shape.
            v.co.x = -v.co.x
            v.co.y = -v.co.y
        for img in bpy.data.images:
            if img.size[0] > 2048:
                w, h = img.size
                img.scale(2048, round(h * 2048 / w))
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    before = stats(bm)
    bmesh.ops.remove_doubles(bm, verts=list(bm.verts), dist=0.000001)
    after = stats(bm)
    # This repair may merge split indices; it must never add or remove faces.
    assert after['faces'] == before['faces'], (mode, before, after)
    report['meshes'][mode] = {'before_weld': before, 'after_weld': after}
    if mode == 'candidate':
        bm.to_mesh(obj.data)
    bm.free()
    path = OUT / (mode + '.glb')
    bpy.ops.export_scene.gltf(filepath=str(path), export_format='GLB', export_image_format='JPEG')
    report['meshes'][mode]['output'] = str(path)
    report['meshes'][mode]['sha256'] = hashlib.sha256(path.read_bytes()).hexdigest()
    EVIDENCE.write_text(json.dumps(report, indent=2) + '\n')
    print('RELIEF', mode, json.dumps(report['meshes'][mode]), flush=True)
