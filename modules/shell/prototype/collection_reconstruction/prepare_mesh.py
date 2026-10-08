"""Make a room-ready GLB from a scanned or generated mesh: the Blender step of the mesh route.

Run: blender -b -P prepare_mesh.py -- IN.glb OUT.glb --height METRES
         [--depth METRES] [--triangles 3000] [--texture 512] [--yaw DEGREES]

It joins the meshes, sets every material to metallic 0 (a generated GLB arrives fully metallic and
bakes black), recalculates normals, decimates to the triangle budget, shrinks textures to the pixel
budget, turns the front to +Z, scales to the catalogue height, squeezes the depth to the catalogue
depth when one is given, and puts the base centre at the origin. The room places that origin with
`place_mesh()`. The last line printed is the row to copy into PROVENANCE.md.
The default budgets are the builder guide's for a work of 0.5 m or more
(docs/playtest/room-builder-guide.md); a smaller work takes --triangles 1500 --texture 256.
The mesh keeps the UV layout it came with, so look at the result: a photogrammetry scan's
patchwork atlas tears when it is decimated hard.
"""
import argparse
import hashlib
import json
import math
import sys

import bpy
from mathutils import Matrix, Vector

parser = argparse.ArgumentParser()
parser.add_argument("source")
parser.add_argument("output")
parser.add_argument("--height", type=float, required=True, help="catalogue height in metres")
parser.add_argument("--depth", type=float, default=0.0, help="catalogue depth in metres; 0 keeps the mesh's own")
parser.add_argument("--triangles", type=int, default=3000)
parser.add_argument("--texture", type=int, default=512, help="longest texture side in pixels")
parser.add_argument("--yaw", type=float, default=0.0, help="turn about the vertical axis so the front faces +Z")
args = parser.parse_args(sys.argv[sys.argv.index("--") + 1:])

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=args.source)
meshes = [o for o in bpy.context.scene.objects if o.type == "MESH"]
assert meshes, "no mesh in " + args.source
bpy.ops.object.select_all(action="DESELECT")
for item in meshes:
    item.select_set(True)
bpy.context.view_layer.objects.active = meshes[0]
if len(meshes) > 1:
    bpy.ops.object.join()
body = bpy.context.view_layer.objects.active
bpy.ops.object.parent_clear(type="CLEAR_KEEP_TRANSFORM")
bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)

body.data.calc_loop_triangles()
before = len(body.data.loop_triangles)
if before > args.triangles:
    modifier = body.modifiers.new("budget", "DECIMATE")
    modifier.ratio = args.triangles / before
    modifier.use_collapse_triangulate = True
    bpy.ops.object.modifier_apply(modifier=modifier.name)
bpy.ops.object.mode_set(mode="EDIT")
bpy.ops.mesh.select_all(action="SELECT")
bpy.ops.mesh.normals_make_consistent(inside=False)
bpy.ops.object.mode_set(mode="OBJECT")
bpy.ops.object.shade_smooth()

for material in body.data.materials:
    if material is None or not material.use_nodes:
        continue
    for node in material.node_tree.nodes:
        if node.type == "BSDF_PRINCIPLED":
            for name, value in [("Metallic", 0.0), ("Roughness", 0.95)]:
                socket = node.inputs[name]
                for link in list(socket.links):
                    material.node_tree.links.remove(link)
                socket.default_value = value
texture = 0
for index, image in enumerate(bpy.data.images):
    image.name = "albedo" + (str(index) if index else "")  # Godot names the extracted file after it
    longest = max(image.size)
    if longest > args.texture:
        image.scale(max(1, round(image.size[0] * args.texture / longest)), max(1, round(image.size[1] * args.texture / longest)))
    texture = max(texture, max(image.size))

# Blender is Z up and faces -Y; the exporter turns that into glTF's Y up, front +Z.
body.data.transform(Matrix.Rotation(math.radians(args.yaw), 4, "Z"))
points = [vertex.co for vertex in body.data.vertices]
low = Vector((min(p.x for p in points), min(p.y for p in points), min(p.z for p in points)))
high = Vector((max(p.x for p in points), max(p.y for p in points), max(p.z for p in points)))
scale = args.height / (high.z - low.z)
depth = (high.y - low.y) * scale
squeeze = args.depth / depth if 0 < args.depth < depth else 1.0
centre = Vector(((low.x + high.x) / 2, (low.y + high.y) / 2, low.z))
body.data.transform(Matrix.Diagonal((scale, scale * squeeze, scale, 1.0)) @ Matrix.Translation(-centre))
body.data.update()

bpy.ops.export_scene.gltf(filepath=args.output, export_format="GLB", export_image_format="JPEG", export_apply=True,
                          export_yup=True, export_normals=True, export_tangents=False, export_materials="EXPORT")
body.data.calc_loop_triangles()
size = [round(max(c[i] for c in body.bound_box) - min(c[i] for c in body.bound_box), 3) for i in (0, 2, 1)]
data = open(args.output, "rb").read()
print("PREPARED_MESH " + json.dumps({
    "file": args.output, "bytes": len(data), "sha256": hashlib.sha256(data).hexdigest(),
    "triangles": len(body.data.loop_triangles), "triangles_before": before, "texture_px": texture,
    "size_m_width_height_depth": size, "depth_squeezed_to": round(squeeze, 3)}))
