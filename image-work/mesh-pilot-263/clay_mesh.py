"""A geometry-only mesh (Tripo, texture off) -> a game mesh with UVs, sized to the catalogue, ready for colour.

blender --background --factory-startup --python clay_mesh.py -- RAW.glb OUT.glb --turn DEG --height M [--width M] [--depth M]
        [--low N] [--maps PX] [--unshaded] [--base R,G,B]

--turn brings the front round to glTF +Z (project_photo.py --view-only reports it). Height is the catalogue's; width
and depth, when given, are set to the catalogue's too (each axis scaled alone: a generator invents depth).
Without --low: the mesh as it came, unwrapped. With --low N: the mesh is kept as the high one, a copy is collapsed to
about N triangles and unwrapped, and the high mesh's surface is baked onto it as a tangent normal map and an
ambient-occlusion map (OUT.normal.png, OUT.ao.png, --maps px). --unshaded bakes the occlusion only and writes no
tangents: for works the rooms draw unshaded, where a normal map does nothing. The colour texture is a flat --base colour for now;
project_photo.py paints it and set_texture.py puts it in. Writes OUT.json. Origin bottom centre."""
import sys, json, math, struct, hashlib, argparse
import bpy, bmesh
from mathutils import Vector
p = argparse.ArgumentParser(); p.add_argument("raw"); p.add_argument("out"); p.add_argument("--turn", type=float, default=0)
p.add_argument("--height", type=float, required=True); p.add_argument("--width", type=float); p.add_argument("--depth", type=float)
p.add_argument("--low", type=int); p.add_argument("--maps", type=int, default=1024); p.add_argument("--base", default="0.72,0.68,0.60"); p.add_argument("--unshaded", action="store_true")
a = p.parse_args(sys.argv[sys.argv.index("--") + 1:]); log = {"raw_sha256": hashlib.sha256(open(a.raw, "rb").read()).hexdigest()}
bpy.ops.wm.read_factory_settings(use_empty=True); bpy.ops.import_scene.gltf(filepath=a.raw, merge_vertices=True)
ms = [o for o in bpy.context.scene.objects if o.type == "MESH"]
for o in ms: o.select_set(True)
bpy.context.view_layer.objects.active = ms[0]
if len(ms) > 1: bpy.ops.object.join()
ob = bpy.context.object; bpy.ops.object.transform_apply(location=True, rotation=True, scale=True); me = ob.data
log["raw_triangles"] = sum(len(f.vertices) - 2 for f in me.polygons)
c, s = math.cos(math.radians(a.turn)), math.sin(math.radians(a.turn))
for v in me.vertices: v.co = Vector((c * v.co.x + s * v.co.y, -s * v.co.x + c * v.co.y, v.co.z))
lo = [min(v.co[i] for v in me.vertices) for i in range(3)]; hi_ = [max(v.co[i] for v in me.vertices) for i in range(3)]
made = [hi_[i] - lo[i] for i in range(3)]; k = a.height / made[2]
kx = a.width / made[0] if a.width else k; ky = a.depth / made[1] if a.depth else k
for v in me.vertices: v.co = Vector(((v.co.x - (lo[0] + hi_[0]) / 2) * kx, (v.co.y - (lo[1] + hi_[1]) / 2) * ky, (v.co.z - lo[2]) * k))
log["as_made_m_at_catalogue_height"] = {"width": round(made[0] * k, 4), "depth": round(made[1] * k, 4)}
log["scale"] = {"height": round(k, 5), "width_against_height": round(kx / k, 4), "depth_against_height": round(ky / k, 4)}
for f in me.polygons: f.use_smooth = True
def unwrap(o):
    bpy.ops.object.select_all(action="DESELECT"); o.select_set(True); bpy.context.view_layer.objects.active = o
    while o.data.uv_layers: o.data.uv_layers.remove(o.data.uv_layers[0])
    bpy.ops.object.mode_set(mode="EDIT"); bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.uv.smart_project(angle_limit=math.radians(66), island_margin=0.004); bpy.ops.object.mode_set(mode="OBJECT")
base = bpy.data.images.new("colour", 64, 64, alpha=False); base.generated_color = tuple(float(x) for x in a.base.split(",")) + (1.0,); base.pack()
mat = bpy.data.materials.new("stone"); mat.use_nodes = True; nt = mat.node_tree; bsdf = nt.nodes["Principled BSDF"]
bsdf.inputs["Metallic"].default_value = 0.0; bsdf.inputs["Roughness"].default_value = 0.95
tex = nt.nodes.new("ShaderNodeTexImage"); tex.image = base; nt.links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
if a.low:
    high = ob; ob = high.copy(); ob.data = high.data.copy(); bpy.context.scene.collection.objects.link(ob); me = ob.data
    bpy.ops.object.select_all(action="DESELECT"); ob.select_set(True); bpy.context.view_layer.objects.active = ob
    mod = ob.modifiers.new("low", "DECIMATE"); mod.ratio = a.low / len(me.polygons); mod.use_collapse_triangulate = True
    bpy.ops.object.modifier_apply(modifier=mod.name)
    for f in me.polygons: f.use_smooth = True
    unwrap(ob); me.materials.clear(); me.materials.append(mat)
    sc = bpy.context.scene; sc.render.engine = "CYCLES"; sc.cycles.device = "CPU"; sc.cycles.samples = 16
    out_maps = {}
    for kind, name in ((("AO", "ao"),) if a.unshaded else (("NORMAL", "normal"), ("AO", "ao"))):  # drawn unshaded, a normal map does nothing
        img = bpy.data.images.new(name, a.maps, a.maps, alpha=False); img.colorspace_settings.name = "Non-Color"
        node = nt.nodes.new("ShaderNodeTexImage"); node.image = img; nt.nodes.active = node
        bpy.ops.object.select_all(action="DESELECT"); high.select_set(True); ob.select_set(True); bpy.context.view_layer.objects.active = ob
        # the operator's own arguments, not the scene's bake settings, decide this: left at their defaults it bakes the low
        # mesh's own empty material, which is the black bake of 7 October
        bpy.ops.object.bake(type=kind, use_selected_to_active=True, cage_extrusion=0.01 * a.height, max_ray_distance=0.03 * a.height, margin=8, normal_space="TANGENT")
        px = img.pixels[:]; mean = [sum(px[i::4]) / (len(px) // 4) for i in range(3)]; out_maps[name] = [round(m, 3) for m in mean]
        path = a.out.rsplit(".", 1)[0] + f".{name}.png"; img.filepath_raw = path; img.file_format = "PNG"; img.save()
        if kind == "NORMAL":
            assert mean[2] > 0.6, f"the normal bake is not a normal map: mean {mean}"
            nm = nt.nodes.new("ShaderNodeNormalMap"); nt.links.new(node.outputs["Color"], nm.inputs["Color"]); nt.links.new(nm.outputs["Normal"], bsdf.inputs["Normal"])
        else:
            assert mean[0] > 0.2, f"the occlusion bake is black: mean {mean}"; nt.nodes.remove(node)
    nt.nodes.active = tex; bpy.data.objects.remove(high, do_unlink=True); log["baked_map_means"] = out_maps; log["maps_px"] = a.maps
else:
    unwrap(ob); me.materials.clear(); me.materials.append(mat)
bpy.ops.object.select_all(action="DESELECT"); ob.select_set(True); ob.name = "Mesh"
bpy.ops.export_scene.gltf(filepath=a.out, export_format="GLB", use_selection=True, export_yup=True, export_normals=True, export_tangents=bool(a.low) and not a.unshaded, export_cameras=False, export_lights=False)
b = open(a.out, "rb").read(); n = struct.unpack("<I", b[12:16])[0]; g = json.loads(b[20:20 + n]); pr = g["meshes"][0]["primitives"][0]; pos = g["accessors"][pr["attributes"]["POSITION"]]
size = [round(h - l, 4) for l, h in zip(pos["min"], pos["max"])]
assert abs(size[1] - a.height) < 0.003 and "TEXCOORD_0" in pr["attributes"] and "NORMAL" in pr["attributes"]
assert g["materials"][0]["pbrMetallicRoughness"].get("metallicFactor", 1) == 0
log.update(triangles=g["accessors"][pr["indices"]]["count"] // 3, size_m_width_height_depth=size, glb_bytes=len(b), images=len(g.get("images", [])), blender=bpy.app.version_string)
open(a.out.rsplit(".", 1)[0] + ".json", "w").write(json.dumps(log, indent=1) + "\n"); print("CLAY", json.dumps(log))
