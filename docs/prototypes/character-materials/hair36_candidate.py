"""Trial of an authored full-coverage New Horizons hairstyle from Human Pack."""

import bpy
from mathutils import Matrix, Vector

exec(compile(open("docs/prototypes/character-materials/export_trial.py").read(),
             "export_trial.py", "exec"))

old_hair = bpy.data.objects["Hair__mHair"]
old_rig = old_hair.parent
assert old_rig is not None and old_rig.type == "ARMATURE"
bpy.data.objects.remove(old_hair, do_unlink=True)
bpy.data.objects.remove(old_rig, do_unlink=True)

with bpy.data.libraries.load("/tmp/risd-163-sfm-hair36-textured.blend", link=False) as (source, destination):
    destination.objects = [name for name in source.objects
                           if name == "Hair36.smd" or name.endswith("Hair36_ARM")]
for obj in destination.objects:
    bpy.context.collection.objects.link(obj)
mesh = next(obj for obj in destination.objects if obj.type == "MESH")
rig = next(obj for obj in destination.objects if obj.type == "ARMATURE")
body = next(obj for obj in bpy.data.objects
            if obj.type == "ARMATURE" and "Armature_Skl_Root" in obj.name)

# Hair00 geometry in this SFM port and the untouched DAE has an exact common
# 0.23923 extent ratio; +0.403 Y aligns the two Hair00 bounding boxes.
rig.matrix_world = Matrix.Translation(Vector((0, 0.403, 0))) @ Matrix.Scale(0.23923, 4)
world = rig.matrix_world.copy()
rig.parent = body
rig.parent_type = "BONE"
rig.parent_bone = "Armature_Head"
rig.matrix_world = world

source_material = mesh.data.materials[0]
source_image = next(node.image for node in source_material.node_tree.nodes
                    if node.type == "TEX_IMAGE" and node.image and node.image.name == "mHair_D")
source_pixels = list(source_image.pixels[:])
hair_color = (0.26, 0.105, 0.045)
for offset in range(0, len(source_pixels), 4):
    for channel in range(3):
        linear = source_pixels[offset + channel] * hair_color[channel]
        source_pixels[offset + channel] = (12.92 * linear if linear <= 0.0031308
                                           else 1.055 * linear ** (1 / 2.4) - 0.055)
    source_pixels[offset + 3] = 1.0
baked = bpy.data.images.new("hair36-source-tinted", width=source_image.size[0],
                            height=source_image.size[1], alpha=True)
baked.pixels[:] = source_pixels
baked.filepath_raw = "/tmp/risd-163-hair36-source-tinted.png"
baked.file_format = "PNG"
baked.save()
source_material.node_tree.nodes.clear()
source_material.blend_method = "OPAQUE"
output = source_material.node_tree.nodes.new("ShaderNodeOutputMaterial")
emission = source_material.node_tree.nodes.new("ShaderNodeEmission")
texture = source_material.node_tree.nodes.new("ShaderNodeTexImage")
texture.image = baked
source_material.node_tree.links.new(texture.outputs["Color"], emission.inputs["Color"])
source_material.node_tree.links.new(emission.outputs[0], output.inputs["Surface"])

bpy.ops.export_scene.gltf(filepath="/tmp/risd-163-hair36-candidate.glb",
                          export_format="GLB", export_apply=False,
                          export_cameras=False, export_lights=False)
for label, position in (("front", (0, -35, 14)), ("profile", (35, 0, 14)),
                        ("back", (0, 35, 14))):
    cam.location = position
    cam.rotation_euler = (Vector((0, 0, 8)) - cam.location).to_track_quat("-Z", "Y").to_euler()
    bpy.context.scene.render.filepath = "/tmp/risd-163-hair36-candidate-" + label + ".png"
    bpy.ops.render.render(write_still=True)
