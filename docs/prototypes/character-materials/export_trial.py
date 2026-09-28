"""Export the source rig with baked diagnostic face layers (no runtime asset)."""

import bpy
from mathutils import Vector

exec(compile(open("docs/prototypes/character-materials/face_composite_trial.py").read(),
             "face_composite_trial.py", "exec"))


def composite(name, source_path, mask_path=None, tint=None):
    source = bpy.data.images.load(source_path, check_existing=True)
    source.pixels[0]
    mask = bpy.data.images.load(mask_path, check_existing=True) if mask_path else None
    if mask:
        mask.pixels[0]
        assert (source.size[0], source.size[1]) == (mask.size[0], mask.size[1])
    target = bpy.data.images.new(name, width=source.size[0], height=source.size[1], alpha=True)
    pixels = list(source.pixels[:])
    mask_pixels = list(mask.pixels[:]) if mask else None
    for offset in range(0, len(pixels), 4):
        if tint:
            for channel in range(3):
                pixels[offset + channel] *= tint[channel]
        else:
            coverage = (1.0 if 1.0 - mask_pixels[offset] > 0.5 else 0.0) if mask else pixels[offset + 3]
            for channel in range(3):
                pixels[offset + channel] = skin[channel] * (1.0 - coverage) + pixels[offset + channel] * coverage
        # New Blender images save raw channel bytes; encode scene-linear colour for PNG.
        for channel in range(3):
            linear = pixels[offset + channel]
            pixels[offset + channel] = 12.92 * linear if linear <= 0.0031308 else 1.055 * linear ** (1 / 2.4) - 0.055
        pixels[offset + 3] = 1.0
    target.pixels[:] = pixels
    target.filepath_raw = "/tmp/risd-163-" + name + ".png"
    target.file_format = "PNG"
    target.save()
    return target


eye = composite("eye-baked", "/tmp/risd-source-audit-eye.png")
mouth = composite("mouth-baked", "/tmp/risd-source-audit-mouth.png",
                  "/tmp/risd-source-audit-mouth-mix.png")
hair_color = (0.26, 0.105, 0.045, 1)
hair_image = composite("hair-baked", "/tmp/mHair_AlbGry.png", tint=hair_color)
shirt_image = composite("shirt-baked", "/tmp/risd-163-mTops-1.6.png", tint=(0.38, 0.38, 0.38))


def emission_texture(material_name, image):
    material = bpy.data.materials[material_name]
    material.node_tree.nodes.clear()
    material.blend_method = "OPAQUE"
    output = material.node_tree.nodes.new("ShaderNodeOutputMaterial")
    emission = material.node_tree.nodes.new("ShaderNodeEmission")
    texture = material.node_tree.nodes.new("ShaderNodeTexImage")
    texture.image = image
    material.node_tree.links.new(texture.outputs["Color"], emission.inputs["Color"])
    material.node_tree.links.new(emission.outputs[0], output.inputs["Surface"])


emission_texture("mEye", eye)
emission_texture("mMouth", mouth)
emission_texture("mHair", hair_image)
emission_texture("mTops", shirt_image)
for layer, color in (("mNose", (0.65, 0.30, 0.21, 1)),
                     ("mNose.001", (0.65, 0.30, 0.21, 1)),
                     ("mBottoms", (0.06, 0.055, 0.05, 1)),
                     ("mSocks", (0.09, 0.085, 0.08, 1))):
    flat_skin(layer)
    bpy.data.materials[layer].node_tree.nodes.get("Emission").inputs["Color"].default_value = color

bpy.ops.export_scene.gltf(filepath="/tmp/risd-163-character-test.glb", export_format="GLB",
                          export_apply=False, export_cameras=False, export_lights=False,
                          export_animations=True)

for label, position in (("front", (0, -35, 14)), ("profile", (35, 0, 14)),
                        ("back", (0, 35, 14))):
    cam.location = position
    cam.rotation_euler = (Vector((0, 0, 8)) - cam.location).to_track_quat("-Z", "Y").to_euler()
    bpy.context.scene.render.filepath = "/tmp/risd-163-baked-" + label + ".png"
    bpy.ops.render.render(write_still=True)
