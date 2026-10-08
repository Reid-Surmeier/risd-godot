"""Put the painted colour texture into a GLB made by clay_mesh.py, keeping its normal map.
blender --background --factory-startup --python set_texture.py -- IN.glb COLOUR.png OUT.glb"""
import sys, bpy
src, colour, out = sys.argv[sys.argv.index("--") + 1:][:3]
bpy.ops.wm.read_factory_settings(use_empty=True); bpy.ops.import_scene.gltf(filepath=src)
img = bpy.data.images.load(colour); img.pack(); done = 0
for m in bpy.data.materials:
    for n in (m.node_tree.nodes if m.use_nodes else []):
        if n.type == "TEX_IMAGE" and any(l.to_socket.name == "Base Color" for l in n.outputs["Color"].links): n.image = img; done += 1
assert done == 1, f"expected one colour texture, found {done}"
ob = [o for o in bpy.context.scene.objects if o.type == "MESH"][0]; bpy.ops.object.select_all(action="DESELECT"); ob.select_set(True)
has_normal_map = any(n.type == "NORMAL_MAP" for m in bpy.data.materials for n in m.node_tree.nodes)
bpy.ops.export_scene.gltf(filepath=out, export_format="GLB", use_selection=True, export_yup=True, export_normals=True, export_tangents=has_normal_map,
                          export_image_format="JPEG", export_jpeg_quality=90, export_cameras=False, export_lights=False)
print("TEXTURED", out)
