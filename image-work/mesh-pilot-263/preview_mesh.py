"""Render a GLB from several sides so its depth can be judged (Cycles CPU, no GPU needed).
blender --background --factory-startup --python preview_mesh.py -- MESH.glb OUT_PREFIX [yaw,yaw,...] [size]
Yaw 0 looks at the glTF +Z face (Blender -Y); 90 looks at the +X side. Writes OUT_PREFIX-<yaw>.png.
CLAY=1 in the environment renders the shape in plain matte grey on a pale ground (any normal map kept)."""
import sys, math, os
import bpy
from mathutils import Vector
argv = sys.argv[sys.argv.index("--") + 1:]
src, prefix = argv[0], argv[1]
yaws = [int(v) for v in (argv[2] if len(argv) > 2 else "0,45,90,180").split(",")]
size = int(argv[3]) if len(argv) > 3 else 640
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=src)
meshes = [o for o in bpy.context.scene.objects if o.type == "MESH"]
for m in bpy.data.materials:
    if m.use_nodes:
        for n in m.node_tree.nodes:
            if n.type == "BSDF_PRINCIPLED":
                n.inputs["Metallic"].default_value = 0.0; n.inputs["Roughness"].default_value = 0.9
                if os.environ.get("CLAY"):  # plain matte clay grey, keeping any normal map: the shape with no colour
                    for l in list(n.inputs["Base Color"].links): m.node_tree.links.remove(l)
                    n.inputs["Base Color"].default_value = (0.62, 0.60, 0.57, 1)
pts = [o.matrix_world @ Vector(c) for o in meshes for c in o.bound_box]
lo = Vector([min(p[i] for p in pts) for i in range(3)]); hi = Vector([max(p[i] for p in pts) for i in range(3)])
centre = (lo + hi) / 2; span = max(hi - lo)
s = bpy.context.scene
s.render.engine = "CYCLES"; s.cycles.device = "CPU"; s.cycles.samples = 24; s.cycles.use_denoising = False
s.render.resolution_x = s.render.resolution_y = size; s.render.image_settings.file_format = "PNG"
s.view_settings.view_transform = "Standard"
s.world = bpy.data.worlds.new("w"); s.world.use_nodes = True
s.world.node_tree.nodes["Background"].inputs[0].default_value = (0.93, 0.93, 0.93, 1) if os.environ.get("CLAY") else (0.75, 0.75, 0.75, 1); s.world.node_tree.nodes["Background"].inputs[1].default_value = 0.45 if os.environ.get("CLAY") else 0.6
cam = bpy.data.objects.new("cam", bpy.data.cameras.new("cam")); s.collection.objects.link(cam); s.camera = cam; cam.data.lens = 85
sun = bpy.data.objects.new("sun", bpy.data.lights.new("sun", "SUN")); sun.data.energy = 1.6 if os.environ.get("CLAY") else 3.0; sun.data.angle = 0.3; s.collection.objects.link(sun)
dist = span * 3.2
for yaw in yaws:
    a = math.radians(yaw - 90)
    cam.location = centre + Vector((dist * math.cos(a), dist * math.sin(a), span * 0.25))
    cam.rotation_euler = (centre - cam.location).to_track_quat("-Z", "Y").to_euler()
    key = centre + Vector((dist * math.cos(a - 0.7), dist * math.sin(a - 0.7), span * 1.2))
    sun.rotation_euler = (centre - key).to_track_quat("-Z", "Y").to_euler()
    s.render.filepath = f"{prefix}-{yaw:03d}.png"; bpy.ops.render.render(write_still=True)
print("bounds", [round(v, 4) for v in lo], [round(v, 4) for v in hi])
