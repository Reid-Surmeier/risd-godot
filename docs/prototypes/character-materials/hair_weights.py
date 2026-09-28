"""Locate the authored bang groups before trying a scoped hair pose."""

import bpy

bpy.ops.import_scene.gltf(filepath="/tmp/risd-150-unified.glb")
hair = bpy.data.objects["Hair__mHair"]
group_names = {group.index: group.name for group in hair.vertex_groups}
for name in ("Armature_Bangs_C", "Armature_Bangs_L", "Armature_Bangs_R"):
    vertices = [
        hair.matrix_world @ vertex.co
        for vertex in hair.data.vertices
        if any(group.weight > 0.25 and group_names[group.group] == name for group in vertex.groups)
    ]
    print("BANG_GROUP", name, len(vertices),
          "front_y", min(v.y for v in vertices), max(v.y for v in vertices),
          "z", min(v.z for v in vertices), max(v.z for v in vertices))
