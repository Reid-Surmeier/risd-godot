"""Temporary material-ID render to locate the source of each face rectangle."""

import bpy

exec(compile(open("/tmp/risd-150-mouth-controlled-render.py").read(),
             "/tmp/risd-150-mouth-controlled-render.py", "exec"))

for name, rgb in (
    ("mSkin", (1, 0, 0, 1)),
    ("mPaint", (0, 1, 0, 1)),
    ("mCheek", (0, 0, 1, 1)),
):
    material = bpy.data.materials[name]
    material.node_tree.nodes.clear()
    out = material.node_tree.nodes.new("ShaderNodeOutputMaterial")
    emissive = material.node_tree.nodes.new("ShaderNodeEmission")
    emissive.inputs["Color"].default_value = rgb
    material.node_tree.links.new(emissive.outputs[0], out.inputs["Surface"])

bpy.context.scene.render.filepath = "/tmp/risd-163-material-ids.png"
bpy.ops.render.render(write_still=True)
