"""Make a Flora Trellis GLB fit for the game. Pattern: 247f8e74 modules/sculpture_viewer/prototype/issue-81/prepare_scan.py.

blender --background --factory-startup --python prepare_mesh.py -- SOURCE.glb OUT.glb --height M
        [--wall-depth M] [--width M] [--texture PX] [--min-island F] [--no-fill]

Trellis ships no normals and no metallicFactor (glTF then means fully metallic, which bakes black). This script:
joins the mesh, drops loose scraps, fills holes, scales to the catalogue height (and --width), for a piece that
stands against a wall (--wall-depth) presses the back flat and scales the depth to the catalogue depth, recalculates
normals, sets metallic 0, and exports a GLB with one JPEG texture. Front stays glTF +Z; the origin is bottom centre
(on the wall plane when --wall-depth is given). It then reads the GLB back and fails if a promise is broken.

It does not reduce triangles. Choose the count in the Trellis call (mesh_simplify): Trellis textures the mesh after
simplifying it. Collapsing afterwards tears the texture, because the atlas is hundreds of small islands; the fix is
to collapse a copy and bake the colour across, and that bake came out black three times here (Blender 4.0.2,
headless, DIFFUSE and EMIT), so it is not in this script.
Writes OUT.json beside the GLB."""
import sys, json, math, struct, hashlib, argparse
import bpy, bmesh
from mathutils import Vector

p = argparse.ArgumentParser()
p.add_argument("source"); p.add_argument("out"); p.add_argument("--height", type=float, required=True)
p.add_argument("--wall-depth", type=float); p.add_argument("--width", type=float); p.add_argument("--texture", type=int, default=1024)
p.add_argument("--min-island", type=float, default=0.05); p.add_argument("--no-fill", action="store_true")
a = p.parse_args(sys.argv[sys.argv.index("--") + 1:])
sha = lambda path: hashlib.sha256(open(path, "rb").read()).hexdigest()
log = {"source": {"sha256": sha(a.source)}, "steps": []}

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=a.source, merge_vertices=True)  # merged so normals run smooth over UV seams
meshes = [o for o in bpy.context.scene.objects if o.type == "MESH"]
bpy.ops.object.select_all(action="DESELECT")
for o in meshes: o.select_set(True)
bpy.context.view_layer.objects.active = meshes[0]
if len(meshes) > 1: bpy.ops.object.join()
ob = bpy.context.object
bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
me = ob.data
log["source"].update(vertices=len(me.vertices), triangles=sum(len(f.vertices) - 2 for f in me.polygons))

bm = bmesh.new(); bm.from_mesh(me); bm.faces.ensure_lookup_table()
# 1. loose scraps (Trellis turns a leftover of floor or shadow into a floating plate)
seen, islands = set(), []
for f in bm.faces:
    if f in seen: continue
    stack, isle = [f], []
    seen.add(f)
    while stack:
        g = stack.pop(); isle.append(g)
        for e in g.edges:
            for h in e.link_faces:
                if h not in seen: seen.add(h); stack.append(h)
    islands.append(isle)
islands.sort(key=len, reverse=True)
drop = [i for i in islands[1:] if len(i) < a.min_island * len(islands[0])]
log["steps"].append({"islands": [len(i) for i in islands][:12], "dropped_faces": sum(len(i) for i in drop)})
bmesh.ops.delete(bm, geom=[f for i in drop for f in i], context="FACES")
bmesh.ops.delete(bm, geom=[v for v in bm.verts if not v.link_faces], context="VERTS")
# 2. holes: close them and give the patch its rim's own texture coordinates
if not a.no_fill:
    uv = bm.loops.layers.uv.active
    rim = [e for e in bm.edges if e.is_boundary]
    new = bmesh.ops.holes_fill(bm, edges=rim, sides=0)["faces"]
    for f in new:
        for l in f.loops:
            l[uv].uv = next((m[uv].uv.copy() for m in l.vert.link_loops if m.face not in new), l[uv].uv)
    bmesh.ops.triangulate(bm, faces=new)
    log["steps"].append({"boundary_edges": len(rim), "hole_patches": len(new)})
# 3. size: uniform, to the catalogue height (Blender Z is up, the front faces -Y)
def to_height():
    zs = [v.co.z for v in bm.verts]; s = a.height / (max(zs) - min(zs))
    xs = [v.co.x for v in bm.verts]; cx = (max(xs) + min(xs)) / 2; z0 = min(zs)
    for v in bm.verts: v.co = Vector(((v.co.x - cx) * s, v.co.y * s, (v.co.z - z0) * s))
to_height()
ys = [v.co.y for v in bm.verts]; front = min(ys)
if a.wall_depth:
    # 4. a piece that stands against a wall. Trellis invents a back and too much depth (the fireplace came 1.03 m
    #    deep for a 0.51 m object, and in another run a whole cabinet behind it). The wall is taken to be just inside
    #    the back of the top third, which is the part that rests on the wall. Everything behind it is pressed flat
    #    onto that plane (cutting it off instead opened the firebox to the wall behind), the pressed faces that
    #    look backwards are dropped, and depth alone is scaled to the catalogue depth.
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    wall = max(v.co.y for v in bm.verts if v.co.z > a.height * 0.67) - a.height * 0.01
    behind = [f for f in bm.faces if all(v.co.y >= wall for v in f.verts)]
    backs = [f for f in behind if f.normal.y > 0.1]
    for v in bm.verts: v.co.y = min(v.co.y, wall)
    bmesh.ops.delete(bm, geom=backs + [f for f in behind if f not in backs and f.calc_area() < 1e-9], context="FACES")
    bmesh.ops.delete(bm, geom=[v for v in bm.verts if not v.link_faces], context="VERTS")
    to_height()  # pressing can remove the lowest point
    ys = [v.co.y for v in bm.verts]; front, wall = min(ys), max(ys); k = a.wall_depth / (wall - front)
    for v in bm.verts: v.co.y = (v.co.y - wall) * k
    log["steps"].append({"depth_as_made_m": round(wall - front, 3), "depth_scale": round(k, 3), "depth_m": a.wall_depth, "pressed_faces_dropped": len(backs)})
else:
    cy = (max(ys) + min(ys)) / 2
    for v in bm.verts: v.co.y -= cy
if a.width:  # the catalogue width, when the photograph looks straight at the front
    xs = [v.co.x for v in bm.verts]; kx = a.width / (max(xs) - min(xs))
    for v in bm.verts: v.co.x *= kx
    log["steps"].append({"width_scale": round(kx, 3)})
bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])  # 5. Trellis ships no normals
bm.to_mesh(me); bm.free()
# 6. glTF's default metallic is 1.0, and Trellis leaves the factor out
for m in bpy.data.materials:
    for n in (m.node_tree.nodes if m.use_nodes else []):
        if n.type == "BSDF_PRINCIPLED": n.inputs["Metallic"].default_value = 0.0; n.inputs["Roughness"].default_value = 0.95
for f in me.polygons: f.use_smooth = True
me.use_auto_smooth = True; me.auto_smooth_angle = math.radians(60)  # Blender 4.0; 4.1+ uses shade_smooth_by_angle
for im in bpy.data.images:
    if im.size[0] > a.texture and im.users: im.scale(a.texture, round(im.size[1] * a.texture / im.size[0])); im.pack()
bpy.ops.object.select_all(action="DESELECT"); ob.select_set(True); ob.name = "Mesh"
bpy.ops.export_scene.gltf(filepath=a.out, export_format="GLB", use_selection=True, export_yup=True, export_normals=True,
                          export_image_format="JPEG", export_jpeg_quality=88, export_cameras=False, export_lights=False)

# the check: read the file back
b = open(a.out, "rb").read(); n, _ = struct.unpack("<II", b[12:20]); g = json.loads(b[20:20 + n])
prims = [q for m in g["meshes"] for q in m["primitives"]]; acc = g["accessors"]
tris = sum(acc[q["indices"]]["count"] for q in prims) // 3
pos = acc[prims[0]["attributes"]["POSITION"]]; size = [round(hi - lo, 4) for lo, hi in zip(pos["min"], pos["max"])]
mat = g["materials"][0]["pbrMetallicRoughness"]
assert all("NORMAL" in q["attributes"] and "TEXCOORD_0" in q["attributes"] for q in prims), "no normals or UVs"
assert mat.get("metallicFactor", 1.0) == 0.0, "metallic is not 0"
assert len(g["images"]) == 1 and "baseColorTexture" in mat, "expected one colour texture"
assert abs(size[1] - a.height) < 0.002, f"height {size[1]} is not {a.height}"
assert not a.wall_depth or size[2] <= a.wall_depth + 0.002, f"depth {size[2]} exceeds {a.wall_depth}"
log["out"] = {"sha256": sha(a.out), "bytes": len(b), "triangles": tris, "vertices": sum(acc[q["attributes"]["POSITION"]]["count"] for q in prims),
              "size_m_width_height_depth": size, "min": pos["min"], "max": pos["max"], "metallicFactor": mat.get("metallicFactor"),
              "texture": {"mime": g["images"][0].get("mimeType"), "bytes": g["bufferViews"][g["images"][0]["bufferView"]]["byteLength"], "px": [list(im.size) for im in bpy.data.images if im.size[0] and im.users]},
              "blender": bpy.app.version_string}
open(a.out.rsplit(".", 1)[0] + ".json", "w").write(json.dumps(log, indent=1) + "\n")
print("PREPARED", json.dumps(log))
