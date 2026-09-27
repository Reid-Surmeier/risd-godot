"""CPU preview: blender -b -t 1 --python modules/shell/prototype/gallery_walk4/identity/render_check.py"""
import bpy
from mathutils import Vector
from pathlib import Path

here = Path(__file__).resolve().parent
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=str(here / 'visitor_identity.glb'))
rig = next(obj for obj in bpy.data.objects if obj.type == 'ARMATURE')
skin = bpy.data.objects['Original visitor skin']
assert len(rig.data.bones) == 41 and len(bpy.data.actions) == 76
assert skin.find_armature() == rig
rig.animation_data_create()
for track in rig.animation_data.nla_tracks:
    track.mute = True
rig.animation_data.action = bpy.data.actions['Idle_Rig']
bpy.context.scene.frame_set(1)

bpy.ops.mesh.primitive_plane_add(size=200)
floor = bpy.context.object
floor.location.z = -0.02
mat = bpy.data.materials.new('preview floor')
mat.diffuse_color = (.44, .38, .31, 1)
floor.data.materials.append(mat)
bpy.ops.object.camera_add(location=(2.5, -5.5, 3.2))
camera = bpy.context.object
camera.rotation_euler = (Vector((0, 0, 1.02)) - camera.location).to_track_quat('-Z', 'Y').to_euler()
camera.data.type = 'ORTHO'
camera.data.ortho_scale = 2.55
bpy.context.scene.camera = camera
bpy.ops.object.light_add(type='AREA', location=(-2, -3, 5))
bpy.context.object.data.energy = 350
bpy.context.object.data.size = 4
scene = bpy.context.scene
scene.world = bpy.data.worlds.new('preview ambient')
scene.world.color = (.18, .18, .18)
scene.render.engine = 'CYCLES'
scene.cycles.device = 'CPU'
scene.cycles.samples = 16
scene.cycles.use_denoising = False
scene.render.resolution_x = 512
scene.render.resolution_y = 512
scene.render.resolution_percentage = 100
scene.render.filepath = str(here / 'visitor_identity_preview.png')
bpy.ops.render.render(write_still=True)
print('PREVIEW', scene.render.filepath)
rig.animation_data.action = bpy.data.actions['Walking_A_Rig']
scene.frame_set(8)
scene.render.filepath = str(here / 'visitor_identity_walk_preview.png')
bpy.ops.render.render(write_still=True)
print('WALK_PREVIEW', scene.render.filepath)
