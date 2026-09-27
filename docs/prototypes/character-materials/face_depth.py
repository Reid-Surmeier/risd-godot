"""Print camera-ray mesh order at face pixels in the rejected 600px view."""

import bpy
from mathutils import Vector

bpy.ops.import_scene.gltf(filepath="/tmp/risd-150-unified.glb")
bpy.ops.object.camera_add(location=(0, -35, 14))
camera = bpy.context.object
camera.rotation_euler = (Vector((0, 0, 8)) - camera.location).to_track_quat("-Z", "Y").to_euler()
camera.data.type = "ORTHO"
camera.data.ortho_scale = 22
bpy.context.scene.camera = camera
depsgraph = bpy.context.evaluated_depsgraph_get()
direction = camera.matrix_world.to_3x3() @ Vector((0, 0, -1))

for px, py in ((250, 215), (300, 215), (350, 215), (250, 265), (300, 265), (350, 265)):
    origin = camera.matrix_world @ Vector(((px / 600 - 0.5) * 22, (0.5 - py / 600) * 22, 0))
    hits = []
    for _ in range(12):
        found, position, _, _, obj, _ = bpy.context.scene.ray_cast(depsgraph, origin, direction)
        if not found:
            break
        hits.append(obj.name)
        origin = position + direction * 0.002
    print("FACE_RAY", px, py, hits)
