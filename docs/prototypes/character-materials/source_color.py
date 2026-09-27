"""Diagnostic unlit source-color render for cheek and paint UV/material mapping."""

import bpy

exec(compile(open("/tmp/risd-150-mouth-controlled-render.py").read(),
             "/tmp/risd-150-mouth-controlled-render.py", "exec"))

for name, path in (
    ("mCheek", "/tmp/mCheek_Alb.0.png"),
    ("mPaint", "/tmp/risd-163-mPaint_Alb.png"),
):
    material = bpy.data.materials[name]
    material.node_tree.nodes.clear()
    out = material.node_tree.nodes.new("ShaderNodeOutputMaterial")
    emissive = material.node_tree.nodes.new("ShaderNodeEmission")
    texture = material.node_tree.nodes.new("ShaderNodeTexImage")
    texture.image = bpy.data.images.load(path, check_existing=True)
    material.node_tree.links.new(texture.outputs["Color"], emissive.inputs["Color"])
    material.node_tree.links.new(emissive.outputs[0], out.inputs["Surface"])

bpy.context.scene.render.filepath = "/tmp/risd-163-source-color.png"
bpy.ops.render.render(write_still=True)
