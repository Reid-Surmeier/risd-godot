"""Read-only bust topology/UV probe; run with blender -b -P this-file."""
import json
from pathlib import Path
import bpy
import bmesh
from mathutils import Vector
import hashlib

ROOT = Path('/home/reidsurmeier/risd-godot-ingestion/proton')
report = {}
for scan_id, folder in [('20260811123051', 'candidate-120k'), ('20260820133334', 'prototype')]:
    manifest = json.loads((ROOT / scan_id / folder / 'manifest.json').read_text())
    candidate = ROOT / scan_id / folder / f'proton-scan-{scan_id}.glb'
    candidate_hash = hashlib.sha256(candidate.read_bytes()).hexdigest()
    assert candidate_hash == manifest['derived']['glb']['sha256']
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete(use_global=False)
    bpy.ops.import_scene.gltf(filepath=str(candidate))
    obj = next(o for o in bpy.context.scene.objects if o.type == 'MESH')
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    bmesh.ops.remove_doubles(bm, verts=list(bm.verts), dist=0.000001)
    bm.verts.ensure_lookup_table()
    uv = bm.loops.layers.uv.active
    seen = set()
    components = []
    for vertex in bm.verts:
        if vertex.index in seen:
            continue
        pending = [vertex]
        seen.add(vertex.index)
        verts = []
        while pending:
            v = pending.pop()
            verts.append(v)
            for edge in v.link_edges:
                other = edge.other_vert(v)
                if other.index not in seen:
                    seen.add(other.index)
                    pending.append(other)
        faces = set(f for v in verts for f in v.link_faces)
        zero_uv = []
        for f in faces:
            a, b, c = [loop[uv].uv for loop in f.loops]
            if abs((b-a).cross(c-a)) < 1e-12:
                zero_uv.append(f)
        components.append({'vertices': len(verts), 'faces': len(faces),
            'bounds': [[min(v.co[a] for v in verts), max(v.co[a] for v in verts)] for a in range(3)],
            'area': sum(f.calc_area() for f in faces), 'zero_uv_faces': len(zero_uv),
            'zero_uv_area': sum(f.calc_area() for f in zero_uv)})
    components.sort(key=lambda c: c['vertices'], reverse=True)
    report[scan_id] = {'components': components, 'boundary_edges': sum(e.is_boundary for e in bm.edges),
        'boundary_length': sum(e.calc_length() for e in bm.edges if e.is_boundary), 'candidate_sha256': candidate_hash}
    bm.free()
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete(use_global=False)
    source = ROOT / scan_id / f'{scan_id}.obj'
    bpy.ops.wm.obj_import(filepath=str(source), forward_axis='Y', up_axis='Z')
    obj = next(o for o in bpy.context.scene.objects if o.type == 'MESH')
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    lo = Vector([min(v.co[a] for v in obj.data.vertices) for a in range(3)])
    hi = Vector([max(v.co[a] for v in obj.data.vertices) for a in range(3)])
    center = (lo + hi) / 2
    center.z = lo.z
    factor = 4.5 / max(hi - lo)
    for v in obj.data.vertices:
        v.co = (v.co - center) * factor
        v.co.x = -v.co.x
        v.co.y = -v.co.y
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    uv = bm.loops.layers.uv.active
    zero_uv = []
    for f in bm.faces:
        a, b, c = [loop[uv].uv for loop in f.loops]
        if abs((b-a).cross(c-a)) < 1e-12:
            zero_uv.append(f)
    report[scan_id]['source'] = {
        'vertices': len(bm.verts), 'faces': len(bm.faces),
        'boundary_edges': sum(e.is_boundary for e in bm.edges),
        'boundary_length': sum(e.calc_length() for e in bm.edges if e.is_boundary),
        'zero_uv_faces': len(zero_uv), 'zero_uv_area': sum(f.calc_area() for f in zero_uv),
        'area': sum(f.calc_area() for f in bm.faces),
        'input_sha256': {ext: hashlib.sha256((ROOT / scan_id / f'{scan_id}.{ext}').read_bytes()).hexdigest() for ext in ('obj', 'mtl', 'jpg')},
    }
    for ext, key in [('obj', 'obj'), ('mtl', 'mtl'), ('jpg', 'texture')]:
        assert report[scan_id]['source']['input_sha256'][ext] == manifest['source'][key]['sha256']
    assert report[scan_id]['source']['faces'] == manifest['source']['polygons']
    bm.free()
    for image in bpy.data.images:
        if image.size[0] > 2048:
            w, h = image.size
            image.scale(2048, round(h * 2048 / w))
    output = Path('/tmp/risd-scan-154-bust-source')
    output.mkdir(exist_ok=True)
    path = output / f'{scan_id}.glb'
    bpy.ops.export_scene.gltf(filepath=str(path), export_format='GLB', export_image_format='JPEG')
    report[scan_id]['source']['output'] = str(path)
    report[scan_id]['source']['sha256'] = hashlib.sha256(path.read_bytes()).hexdigest()
    Path(__file__).with_suffix('.json').write_text(json.dumps(report, indent=2) + '\n')
Path(__file__).with_suffix('.json').write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps(report, indent=2))
