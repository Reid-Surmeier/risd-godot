"""Isolate imported ACNH face layers against the rejected 600px scratch render.

Run with Blender 4: blender -b -t 2 --python probe_face_layers.py
The source GLB and images are temporary audit inputs, not runtime assets.
"""

import bpy

exec(compile(open("/tmp/risd-150-mouth-controlled-render.py").read(),
             "/tmp/risd-150-mouth-controlled-render.py", "exec"))

for layer in ("Body__mCheek", "Paint__mPaint", "Body__mSoftmesh", "Body__mMouth"):
    obj = bpy.data.objects[layer]
    obj.hide_render = True
    bpy.context.scene.render.filepath = "/tmp/risd-163-without-" + layer + ".png"
    bpy.ops.render.render(write_still=True)
    obj.hide_render = False
