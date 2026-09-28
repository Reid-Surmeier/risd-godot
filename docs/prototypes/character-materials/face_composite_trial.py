"""Composite eye/mouth masks over opaque skin, preserving source UV and rig."""

import bpy

exec(compile(open("/tmp/risd-150-mouth-controlled-render.py").read(),
             "/tmp/risd-150-mouth-controlled-render.py", "exec"))

skin = (0.75, 0.44, 0.34, 1)

def flat_skin(name):
    material = bpy.data.materials[name]
    material.node_tree.nodes.clear()
    material.blend_method = "OPAQUE"
    out = material.node_tree.nodes.new("ShaderNodeOutputMaterial")
    emission = material.node_tree.nodes.new("ShaderNodeEmission")
    emission.inputs["Color"].default_value = skin
    material.node_tree.links.new(emission.outputs[0], out.inputs["Surface"])

for layer in ("mSkin", "mCheek", "mPaint"):
    flat_skin(layer)

def facial_detail(name, albedo_path, mask_path=None):
    material = bpy.data.materials[name]
    material.node_tree.nodes.clear()
    material.blend_method = "OPAQUE"
    out = material.node_tree.nodes.new("ShaderNodeOutputMaterial")
    emission = material.node_tree.nodes.new("ShaderNodeEmission")
    albedo = material.node_tree.nodes.new("ShaderNodeTexImage")
    albedo.image = bpy.data.images.load(albedo_path, check_existing=True)
    blend = material.node_tree.nodes.new("ShaderNodeMixRGB")
    blend.blend_type = "MIX"
    blend.inputs[1].default_value = skin
    material.node_tree.links.new(albedo.outputs["Color"], blend.inputs[2])
    if mask_path:
        mask = material.node_tree.nodes.new("ShaderNodeTexImage")
        mask.image = bpy.data.images.load(mask_path, check_existing=True)
        separate = material.node_tree.nodes.new("ShaderNodeSeparateColor")
        invert = material.node_tree.nodes.new("ShaderNodeMath")
        invert.operation = "SUBTRACT"
        invert.inputs[0].default_value = 1
        cutout = material.node_tree.nodes.new("ShaderNodeMath")
        cutout.operation = "GREATER_THAN"
        cutout.inputs[1].default_value = 0.5
        material.node_tree.links.new(mask.outputs["Color"], separate.inputs["Color"])
        material.node_tree.links.new(separate.outputs["Red"], invert.inputs[1])
        material.node_tree.links.new(invert.outputs[0], cutout.inputs[0])
        material.node_tree.links.new(cutout.outputs[0], blend.inputs[0])
    else:
        material.node_tree.links.new(albedo.outputs["Alpha"], blend.inputs[0])
    material.node_tree.links.new(blend.outputs[0], emission.inputs["Color"])
    material.node_tree.links.new(emission.outputs[0], out.inputs["Surface"])

facial_detail("mEye", "/tmp/risd-source-audit-eye.png")
facial_detail("mMouth", "/tmp/risd-source-audit-mouth.png", "/tmp/risd-source-audit-mouth-mix.png")

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

bpy.context.scene.render.filepath = "/tmp/risd-163-face-composite.png"
bpy.ops.render.render(write_still=True)
