"""Source-map material trial; deliberately stays outside the runtime asset tree."""

import bpy

exec(compile(open("/tmp/risd-150-mouth-controlled-render.py").read(),
             "/tmp/risd-150-mouth-controlled-render.py", "exec"))

# The scratch renderer used opaque black for the authored Paint face mesh.
# Its actual albedo is a fully opaque, flat grey. Keep the geometry and map.
paint = bpy.data.materials["mPaint"]
paint_bsdf = next(n for n in paint.node_tree.nodes if n.type == "BSDF_PRINCIPLED")
paint_tex = paint.node_tree.nodes.new("ShaderNodeTexImage")
paint_tex.image = bpy.data.images.load("/tmp/risd-163-mPaint_Alb.png")
paint.node_tree.links.new(paint_tex.outputs["Color"], paint_bsdf.inputs["Base Color"])

# The cheek albedo has no useful opacity; its matching source Mix alpha does.
cheek = bpy.data.materials["mCheek"]
cheek_bsdf = next(n for n in cheek.node_tree.nodes if n.type == "BSDF_PRINCIPLED")
cheek_mix = cheek.node_tree.nodes.new("ShaderNodeTexImage")
cheek_mix.image = bpy.data.images.load("/tmp/risd-163-mCheek_Mix.0.png")
cheek.node_tree.links.new(cheek_mix.outputs["Alpha"], cheek_bsdf.inputs["Alpha"])
cheek.blend_method = "BLEND"

bpy.context.scene.render.filepath = "/tmp/risd-163-material-trial.png"
bpy.ops.render.render(write_still=True)

# The 2.0 direct shirt member timed out; the same authored clothing texture
# member in the 1.6 export was retrieved and hash-checked for this trial.
shirt = bpy.data.materials["mTops"]
shirt_bsdf = next(n for n in shirt.node_tree.nodes if n.type == "BSDF_PRINCIPLED")
shirt_tex = shirt.node_tree.nodes.new("ShaderNodeTexImage")
shirt_tex.image = bpy.data.images.load("/tmp/risd-163-mTops-1.6.png")
shirt.node_tree.links.new(shirt_tex.outputs["Color"], shirt_bsdf.inputs["Base Color"])

for name, tint in (
    ("mSkin", (0.98, 0.70, 0.58, 1)),
    ("mPaint", (1.25, 0.92, 0.75, 1)),
    ("mHair", (0.53, 0.24, 0.12, 1)),
):
    material = bpy.data.materials[name]
    bsdf = next(n for n in material.node_tree.nodes if n.type == "BSDF_PRINCIPLED")
    source = next(link.from_socket for link in material.node_tree.links if link.to_socket == bsdf.inputs["Base Color"])
    multiply = material.node_tree.nodes.new("ShaderNodeMixRGB")
    multiply.blend_type = "MULTIPLY"
    multiply.inputs[0].default_value = 1
    multiply.inputs[2].default_value = tint
    material.node_tree.links.new(source, multiply.inputs[1])
    material.node_tree.links.new(multiply.outputs[0], bsdf.inputs["Base Color"])

bpy.context.scene.render.filepath = "/tmp/risd-163-palette-trial.png"
bpy.ops.render.render(write_still=True)

# Probe the source normals under an even frontal fill. This changes lighting
# alone, testing whether the apparently wrong skin/cheek tone is a shader bug.
bpy.ops.object.light_add(type="AREA", location=(0, -14, 9))
fill = bpy.context.object
fill.data.energy = 2300
fill.data.shape = "DISK"
fill.data.size = 16
bpy.context.scene.render.filepath = "/tmp/risd-163-front-fill-trial.png"
bpy.ops.render.render(write_still=True)

# Isolate alpha sorting/shadowing from colour and lighting.
cheek.blend_method = "OPAQUE"
cheek.node_tree.links.remove(next(link for link in cheek.node_tree.links if link.to_socket == cheek_bsdf.inputs["Alpha"]))
cheek_bsdf.inputs["Alpha"].default_value = 1
bpy.context.scene.render.filepath = "/tmp/risd-163-cheek-opaque-trial.png"
bpy.ops.render.render(write_still=True)

bpy.data.objects["Hair__mHair"].visible_shadow = False
bpy.context.scene.render.filepath = "/tmp/risd-163-no-hair-shadow.png"
bpy.ops.render.render(write_still=True)

for name in ("Body__mCheek", "Body__mEye", "Body__mMouth", "Paint__mPaint"):
    bpy.data.objects[name].visible_shadow = False
bpy.context.scene.render.filepath = "/tmp/risd-163-no-overlay-shadow.png"
bpy.ops.render.render(write_still=True)
