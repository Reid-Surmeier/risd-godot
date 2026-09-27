"""Scratch deletion trial of the disconnected flat underside, never a runtime asset."""

import bpy
import bmesh
from collections import deque
from pathlib import Path


source = Path("/home/reidsurmeier/risd-godot-ingestion/proton/20260811121459/candidate-120k-rerun/proton-scan-20260811121459.glb")
output = Path("/tmp/risd-scan-154/group-without-flat-underside.glb")
output.parent.mkdir(parents=True, exist_ok=True)
bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)
bpy.ops.import_scene.gltf(filepath=str(source))
obj = next(obj for obj in bpy.context.scene.objects if obj.type == "MESH")
bm = bmesh.new()
bm.from_mesh(obj.data)
bm.verts.ensure_lookup_table()
seen = set()
removed = []
for vertex in bm.verts:
    if vertex.index in seen:
        continue
    queue = deque([vertex])
    seen.add(vertex.index)
    component = []
    while queue:
        current = queue.pop()
        component.append(current)
        for edge in current.link_edges:
            other = edge.other_vert(current)
            if other.index not in seen:
                seen.add(other.index)
                queue.append(other)
    if len(component) != 894:
        continue
    low = min(v.co.z for v in component)
    high = max(v.co.z for v in component)
    width = max(v.co.x for v in component) - min(v.co.x for v in component)
    depth = max(v.co.y for v in component) - min(v.co.y for v in component)
    if low < 0 and high < 0.43 and width > 4 and depth > 4:
        removed = component
        break
assert len(removed) == 894, "Unexpected source topology; do not delete"
bmesh.ops.delete(bm, geom=removed, context="VERTS")
bm.to_mesh(obj.data)
bm.free()
bpy.ops.export_scene.gltf(filepath=str(output), export_format="GLB")
print("TRIAL", output, "removed_component_vertices", len(removed))
