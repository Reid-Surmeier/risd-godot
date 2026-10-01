"""Throwaway Blender4.3.2 inspection: original GLB retained, three-view review scene."""
import bpy
import json
from pathlib import Path
import sys
from mathutils import Vector

HERE = Path(__file__).resolve().parent
kind = sys.argv[sys.argv.index('--') + 1] if '--' in sys.argv else 'mesh'
source = HERE / ('mesh-output-model_glb.glb' if kind == 'mesh' else 'rig-output-rigged_character_glb.glb')
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.context.preferences.filepaths.save_version = 0
bpy.ops.import_scene.gltf(filepath=str(source))
meshes = [o for o in bpy.context.scene.objects if o.type == 'MESH']
assert meshes, 'No geometry'
points = [o.matrix_world @ Vector(corner) for o in meshes for corner in o.bound_box]
low = Vector([min(p[i] for p in points) for i in range(3)])
high = Vector([max(p[i] for p in points) for i in range(3)])
center = (low + high) / 2
height = high.z - low.z
assert height > 0
for o in meshes:
    o.data.calc_loop_triangles()
textures = [{'name': im.name, 'size': list(im.size)} for im in bpy.data.images if im.type == 'IMAGE']
rigs = [o for o in bpy.context.scene.objects if o.type == 'ARMATURE']
evidence = {'blender': bpy.app.version_string, 'kind': kind, 'source': source.name,
    'triangles': sum(len(o.data.loop_triangles) for o in meshes),
    'vertices': sum(len(o.data.vertices) for o in meshes), 'mesh_objects': len(meshes),
    'all_meshes_uv': all(bool(o.data.uv_layers) for o in meshes),
    'textures': textures, 'bounds_blender_z_up': [list(low), list(high)],
    'height_meters': height, 'rigs': len(rigs), 'bones': [len(o.data.bones) for o in rigs],
    'actions': [a.name for a in bpy.data.actions], 'visual_acceptance': 'pending owner review'}
if rigs:
    for rig in rigs:
        rig.data.pose_position = 'REST'
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.device = 'CPU'
scene.cycles.samples = 12
scene.cycles.use_denoising = True
scene.render.resolution_x = 640
scene.render.resolution_y = 640
scene.render.resolution_percentage = 100
scene.render.image_settings.file_format = 'PNG'
scene.world = bpy.data.worlds.new('neutral review')
scene.world.use_nodes = True
scene.world.node_tree.nodes['Background'].inputs['Color'].default_value = (.8,.8,.8,1)
scene.world.node_tree.nodes['Background'].inputs['Strength'].default_value = .7
bpy.ops.object.light_add(type='AREA', location=center + Vector((-height,-height,2*height)))
bpy.context.object.data.energy = 200 * height * height
bpy.context.object.data.size = 2 * height
bpy.ops.object.camera_add()
camera = bpy.context.object
camera.data.type = 'ORTHO'
camera.data.ortho_scale = max(high.x-low.x, height) * 1.2
scene.camera = camera
for name, offset in [('front',(0,-3,0)),('side',(3,0,0)),('back',(0,3,0))]:
    camera.location = center + Vector(offset) * height
    camera.rotation_euler = (center-camera.location).to_track_quat('-Z','Y').to_euler()
    scene.render.filepath = str(HERE / (kind + '-' + name + '.png'))
    bpy.ops.render.render(write_still=True)
bpy.ops.wm.save_as_mainfile(filepath=str(HERE / (kind + '-review.blend')))
(HERE / (kind + '-inspection.json')).write_text(json.dumps(evidence,indent=2)+'\n')
print('INSPECTION', json.dumps(evidence))
