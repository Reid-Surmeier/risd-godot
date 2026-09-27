"""Try the authored albedos with an even game-like skin shader, not flat blocks."""

import bpy

exec(compile(open("docs/prototypes/character-materials/source_color.py").read(),
             "source_color.py", "exec"))

albedos = {
    "mSkin": ("/tmp/mSkin_Alb.png", (0.97, 0.72, 0.61, 1)),
    "mCheek": ("/tmp/mCheek_Alb.0.png", (0.92, 0.70, 0.60, 1)),
    "mPaint": ("/tmp/risd-163-mPaint_Alb.png", (1.24, 0.94, 0.80, 1)),
}
for name, (path, tint) in albedos.items():
    material = bpy.data.materials[name]
    material.node_tree.nodes.clear()
    out = material.node_tree.nodes.new("ShaderNodeOutputMaterial")
    emissive = material.node_tree.nodes.new("ShaderNodeEmission")
    texture = material.node_tree.nodes.new("ShaderNodeTexImage")
    texture.image = bpy.data.images.load(path, check_existing=True)
    multiply = material.node_tree.nodes.new("ShaderNodeMixRGB")
    multiply.blend_type = "MULTIPLY"
    multiply.inputs[0].default_value = 1
    multiply.inputs[2].default_value = tint
    material.node_tree.links.new(texture.outputs["Color"], multiply.inputs[1])
    material.node_tree.links.new(multiply.outputs[0], emissive.inputs["Color"])
    material.node_tree.links.new(emissive.outputs[0], out.inputs["Surface"])

shirt = bpy.data.materials["mTops"]
shirt_bsdf = next(node for node in shirt.node_tree.nodes if node.type == "BSDF_PRINCIPLED")
shirt_tex = shirt.node_tree.nodes.new("ShaderNodeTexImage")
shirt_tex.image = bpy.data.images.load("/tmp/risd-163-mTops-1.6.png")
shirt.node_tree.links.new(shirt_tex.outputs["Color"], shirt_bsdf.inputs["Base Color"])

hair = bpy.data.materials["mHair"]
hair_bsdf = next(node for node in hair.node_tree.nodes if node.type == "BSDF_PRINCIPLED")
hair_source = next(link.from_socket for link in hair.node_tree.links if link.to_socket == hair_bsdf.inputs["Base Color"])
hair_tint = hair.node_tree.nodes.new("ShaderNodeMixRGB")
hair_tint.blend_type = "MULTIPLY"
hair_tint.inputs[0].default_value = 1
hair_tint.inputs[2].default_value = (0.53, 0.26, 0.13, 1)
hair.node_tree.links.new(hair_source, hair_tint.inputs[1])
hair.node_tree.links.new(hair_tint.outputs[0], hair_bsdf.inputs["Base Color"])

bpy.context.scene.render.filepath = "/tmp/risd-163-style-trial.png"
bpy.ops.render.render(write_still=True)

cheek_offset = bpy.data.objects["Body__mCheek"].modifiers.new("face_overlay_depth_probe", "DISPLACE")
cheek_offset.strength = 0.05
cheek_offset.mid_level = 0
bpy.context.scene.render.filepath = "/tmp/risd-163-cheek-offset-trial.png"
bpy.ops.render.render(write_still=True)
bpy.data.objects["Body__mCheek"].modifiers.remove(cheek_offset)

for layer in ("Body__mEye", "Body__mMouth", "Paint__mPaint"):
    obj = bpy.data.objects[layer]
    obj.hide_render = True
    bpy.context.scene.render.filepath = "/tmp/risd-163-style-without-" + layer + ".png"
    bpy.ops.render.render(write_still=True)
    obj.hide_render = False

# A controlled palette-transfer trial: the archived albedos drive authored
# light/dark detail, while all three skin regions share one skin palette.
for name, (path, _) in albedos.items():
    material = bpy.data.materials[name]
    material.node_tree.nodes.clear()
    out = material.node_tree.nodes.new("ShaderNodeOutputMaterial")
    emissive = material.node_tree.nodes.new("ShaderNodeEmission")
    texture = material.node_tree.nodes.new("ShaderNodeTexImage")
    texture.image = bpy.data.images.load(path, check_existing=True)
    luminance = material.node_tree.nodes.new("ShaderNodeRGBToBW")
    ramp = material.node_tree.nodes.new("ShaderNodeValToRGB")
    ramp.color_ramp.elements[0].position = 0
    ramp.color_ramp.elements[0].color = (0.55, 0.22, 0.17, 1)
    ramp.color_ramp.elements[1].position = 1
    ramp.color_ramp.elements[1].color = (0.82, 0.47, 0.34, 1)
    if name == "mPaint":
        ramp.color_ramp.elements[0].color = (0.82, 0.47, 0.34, 1)
    material.node_tree.links.new(texture.outputs["Color"], luminance.inputs[0])
    material.node_tree.links.new(luminance.outputs[0], ramp.inputs[0])
    material.node_tree.links.new(ramp.outputs[0], emissive.inputs["Color"])
    material.node_tree.links.new(emissive.outputs[0], out.inputs["Surface"])
bpy.context.scene.render.filepath = "/tmp/risd-163-palette-ramp.png"
bpy.ops.render.render(write_still=True)

for name in albedos:
    ramp = next(node for node in bpy.data.materials[name].node_tree.nodes if node.type == "VALTORGB")
    ramp.color_ramp.elements[0].color = (0.82, 0.47, 0.34, 1)
bpy.context.scene.render.filepath = "/tmp/risd-163-flat-skin-control.png"
bpy.ops.render.render(write_still=True)

for name in albedos:
    bpy.data.materials[name].blend_method = "OPAQUE"
    bpy.data.materials[name].diffuse_color = (1, 1, 1, 1)
bpy.context.scene.render.filepath = "/tmp/risd-163-flat-skin-opaque.png"
bpy.ops.render.render(write_still=True)

bpy.data.objects["Body__mCheek"].hide_render = True
bpy.context.scene.render.filepath = "/tmp/risd-163-flat-skin-without-cheek.png"
bpy.ops.render.render(write_still=True)
