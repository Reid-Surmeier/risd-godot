"""Read-only connected-component probe for #154's selected 120k GLBs.

Run: blender -b -P docs/research/proton-scan-validation/component_probe.py
"""

import bpy
import bmesh
from collections import deque
from pathlib import Path


ROOT = Path("/home/reidsurmeier/risd-godot-ingestion/proton")
PATHS = {
    "20260811121459": ROOT / "20260811121459/candidate-120k-rerun/proton-scan-20260811121459.glb",
    "20260811122415": ROOT / "20260811122415/candidate-120k/proton-scan-20260811122415.glb",
    "20260811123051": ROOT / "20260811123051/candidate-120k/proton-scan-20260811123051.glb",
    "20260820133334": ROOT / "20260820133334/prototype/proton-scan-20260820133334.glb",
}

for scan_id, path in PATHS.items():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    bpy.ops.import_scene.gltf(filepath=str(path))
    meshes = [obj for obj in bpy.context.scene.objects if obj.type == "MESH"]
    assert len(meshes) == 1, (scan_id, len(meshes))
    bm = bmesh.new()
    bm.from_mesh(meshes[0].data)
    bm.verts.ensure_lookup_table()
    seen = set()
    components = []
    for vertex in bm.verts:
        if vertex.index in seen:
            continue
        queue = deque([vertex])
        seen.add(vertex.index)
        count = 0
        bounds = [[float("inf"), float("-inf")] for _ in range(3)]
        while queue:
            current = queue.pop()
            count += 1
            for axis in range(3):
                value = current.co[axis]
                bounds[axis][0] = min(bounds[axis][0], value)
                bounds[axis][1] = max(bounds[axis][1], value)
            for edge in current.link_edges:
                other = edge.other_vert(current)
                if other.index not in seen:
                    seen.add(other.index)
                    queue.append(other)
        components.append((count, bounds))
    components.sort(reverse=True)
    print("SCAN", scan_id, "verts", len(bm.verts), "components", len(components))
    for count, bounds in components[:15]:
        print("COMP", count, "bounds", [[round(n, 4) for n in axis] for axis in bounds])
    if scan_id == "20260811121459":
        low_wide = [
            (count, bounds)
            for count, bounds in components
            if bounds[2][0] < 0.5
            and bounds[0][1] - bounds[0][0] > 2
            and bounds[1][1] - bounds[1][0] > 1
        ]
        print("LOW_WIDE", len(low_wide), "vertices", sum(count for count, _ in low_wide))
        for count, bounds in low_wide[:30]:
            print("LOW", count, "bounds", [[round(n, 4) for n in axis] for axis in bounds])
    bm.free()
