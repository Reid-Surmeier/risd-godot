"""Deterministic derivative: blender -b --python prepare.py -- /path/to/pinned/Rogue.glb.
Never downloads or modifies its source. CC0 Kay Lousberg; see SOURCE.md.
"""
import bpy, sys, pathlib, hashlib, json
src=pathlib.Path(sys.argv[sys.argv.index('--')+1]);out=pathlib.Path(__file__).parent
assert hashlib.sha256(src.read_bytes()).hexdigest()=='e825437cd4d2ee9c1960b517a74a69101e33eb409ae7fa8cedc7134a998fbb7d'
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.context.scene.render.fps=30
bpy.ops.import_scene.gltf(filepath=str(src))
rig=next(o for o in bpy.data.objects if o.type=='ARMATURE')
keep={'Rogue_ArmLeft','Rogue_ArmRight','Rogue_Body','Rogue_Head','Rogue_LegLeft','Rogue_LegRight'}
for o in list(bpy.data.objects):
 if o!=rig and o.name not in keep:bpy.data.objects.remove(o,do_unlink=True)
for track in list(rig.animation_data.nla_tracks):rig.animation_data.nla_tracks.remove(track)
rig.animation_data.action=None
for action in list(bpy.data.actions):
 if action.name not in ['Idle_Rig','Walking_A_Rig','Interact_Rig']:bpy.data.actions.remove(action)
 else:action.name=action.name.replace('_Rig','');action.use_fake_user=True
rig.animation_data.action=bpy.data.actions['Idle'];bpy.context.scene.frame_set(0)
# One body mesh preserves the existing skin weights, atlas and material.
bpy.ops.object.select_all(action='DESELECT')
for o in bpy.data.objects:
 if o.type=='MESH':o.select_set(True);bpy.context.view_layer.objects.active=o
bpy.ops.object.join();bpy.context.object.name='VisitorBody'
body=bpy.context.object
coords=[body.matrix_world@v.co for v in body.evaluated_get(bpy.context.evaluated_depsgraph_get()).data.vertices]
print('DERIVATIVE_BOUNDS', min(v.z for v in coords),max(v.z for v in coords))
bpy.ops.export_scene.gltf(filepath=str(out/'visitor.glb'),export_format='GLB',export_animations=True,export_animation_mode='ACTIONS',export_frame_range=False,export_force_sampling=True,export_skins=True,export_yup=True,export_cameras=False,export_lights=False)
print('DERIVATIVE_SHA256',hashlib.sha256((out/'visitor.glb').read_bytes()).hexdigest())
