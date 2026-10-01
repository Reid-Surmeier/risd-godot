"""THROWAWAY pilot: original UV color bake and verified matching-rig clip transfer.
Executed by an actual MCP request that launches the pinned native headless process.
"""
import bpy, json, struct, hashlib, traceback
from pathlib import Path
from mathutils import Vector

HERE=Path(__file__).resolve().parent
SOURCE=HERE/'rig-output-rigged_character_glb.glb'
DONE=HERE/'target-bake-completion.json'
def glb(path):
 raw=path.read_bytes(); length=struct.unpack_from('<I',raw,12)[0]
 return raw,json.loads(raw[20:20+length])
def signature(rig):
 return {b.name:(b.parent.name if b.parent else None,tuple(v for row in b.matrix_local for v in row)) for b in rig.data.bones}
try:
 raw,source_json=glb(SOURCE)
 for obj in list(bpy.data.objects): bpy.data.objects.remove(obj,do_unlink=True)
 for action in list(bpy.data.actions): bpy.data.actions.remove(action)
 bpy.ops.import_scene.gltf(filepath=str(SOURCE))
 rig=next(o for o in bpy.context.scene.objects if o.type=='ARMATURE')
 meshes=[o for o in bpy.context.scene.objects if o.type=='MESH' and o.find_armature()==rig]
 assert len(meshes)==1
 mesh=meshes[0]
 source_uv=tuple((u.uv.x,u.uv.y) for u in mesh.data.uv_layers.active.data)
 mesh.data.calc_loop_triangles()
 source_triangles=len(mesh.data.loop_triangles)
 assert source_triangles==7719 and len(rig.data.bones)==24
 source_signature=signature(rig)
 comparisons=[]
 motion_actions={}
 for clip,filename in [('idle','rig-output-animations-0-animation_glb.glb'),('walk','rig-output-basic_animations-walking_armature_glb.glb'),('run','rig-output-basic_animations-running_armature_glb.glb')]:
  old=set(bpy.data.objects)
  old_actions=set(bpy.data.actions)
  bpy.ops.import_scene.gltf(filepath=str(HERE/filename))
  imported=set(bpy.data.objects)-old
  other=next(o for o in imported if o.type=='ARMATURE')
  sig=signature(other)
  assert set(sig)==set(source_signature)
  assert all(sig[k][0]==source_signature[k][0] for k in sig)
  difference=max(abs(x-y) for k in sig for x,y in zip(sig[k][1],source_signature[k][1]))
  world_difference=max(abs(other.matrix_world[i][j]-rig.matrix_world[i][j]) for i in range(4) for j in range(4))
  assert difference<1e-6 and world_difference<1e-6
  action=other.animation_data.action.copy(); action.name=clip
  track=rig.animation_data.nla_tracks.new(); track.name=clip
  track.strips.new(clip,int(action.frame_range[0]),action); track.mute=True
  motion_actions[clip]=action
  comparisons.append({'file':filename,'bones_and_parents_match':True,'max_rest_matrix_difference':difference,'max_world_difference':world_difference,'added_action':clip})
  for obj in imported: bpy.data.objects.remove(obj,do_unlink=True)
  for imported_action in set(bpy.data.actions)-old_actions:
   if imported_action != action: bpy.data.actions.remove(imported_action,do_unlink=True)
 for track in rig.animation_data.nla_tracks: track.mute=True
 rig.animation_data.action=None
 rig.data.pose_position='REST'
 assert len(mesh.data.materials)==1
 mat=mesh.data.materials[0]
 assert mat.use_nodes
 bsdf=next(n for n in mat.node_tree.nodes if n.type=='BSDF_PRINCIPLED')
 bsdf.inputs['Metallic'].default_value=0.0
 bsdf.inputs['Roughness'].default_value=1.0
 image=bpy.data.images.new('target color bake512',width=512,height=512,alpha=True)
 image.colorspace_settings.name='sRGB'
 target=mat.node_tree.nodes.new('ShaderNodeTexImage');target.image=image
 for node in mat.node_tree.nodes:node.select=False
 target.select=True;mat.node_tree.nodes.active=target
 bpy.ops.object.select_all(action='DESELECT')
 mesh.select_set(True);bpy.context.view_layer.objects.active=mesh
 scene=bpy.context.scene;scene.render.engine='CYCLES';scene.cycles.device='CPU';scene.cycles.samples=1;scene.render.bake.margin=8
 bpy.ops.object.bake(type='DIFFUSE',pass_filter={'COLOR'})
 pixels=list(image.pixels);rgb=[v for i,v in enumerate(pixels) if i%4!=3]
 assert max(rgb)>.1 and max(rgb)-min(rgb)>.1
 image.filepath_raw=str(HERE/'target-albedo512.png');image.file_format='PNG';image.save()
 mat.node_tree.links.new(target.outputs['Color'],bsdf.inputs['Base Color'])
 bsdf.inputs['Roughness'].default_value=1.0
 bsdf.inputs['Metallic'].default_value=0.0
 for link in list(bsdf.inputs['Emission Color'].links): mat.node_tree.links.remove(link)
 bsdf.inputs['Emission Color'].default_value=(0,0,0,1)
 bsdf.inputs['Emission Strength'].default_value=0.0
 bsdf.inputs['Specular IOR Level'].default_value=0.0
 bsdf.inputs['Specular Tint'].default_value=(1,1,1,1)
 assert tuple((u.uv.x,u.uv.y) for u in mesh.data.uv_layers.active.data)==source_uv
 assert signature(rig)==source_signature
 rig.data.pose_position='POSE'
 rig.animation_data.action=motion_actions['idle']
 scene.frame_set(int(motion_actions['idle'].frame_range[0]))
 bpy.ops.object.select_all(action='DESELECT');mesh.select_set(True);rig.select_set(True);bpy.context.view_layer.objects.active=mesh
 output=HERE/'target-baked.glb'
 bpy.ops.export_scene.gltf(filepath=str(output),export_format='GLB',use_selection=True,export_animations=True,export_animation_mode='ACTIONS',export_skins=True,export_force_sampling=False)
 out_raw,data=glb(output)
 assert len(data['skins'])==1 and len(data['skins'][0]['joints'])==24
 assert len(data['meshes'])==1 and len(data['animations'])==4
 attrs=[p['attributes'] for m in data['meshes'] for p in m['primitives']]
 assert all('TEXCOORD_0' in a and 'JOINTS_0' in a and 'WEIGHTS_0' in a for a in attrs)
 output_triangles=sum(data['accessors'][p['indices']]['count']//3 for m in data['meshes'] for p in m['primitives'])
 assert output_triangles==source_triangles
 assert len(data['images'])==1 and all('bufferView' in im for im in data['images'])
 bpy.context.preferences.use_preferences_save=False
 bpy.context.preferences.filepaths.save_version=0
 bpy.ops.wm.save_as_mainfile(filepath=str(HERE/'target-baked.blend'),compress=True)
 rig.data.pose_position='REST'
 bpy.context.view_layer.update()
 evaluated=mesh.evaluated_get(bpy.context.evaluated_depsgraph_get())
 verts=[evaluated.matrix_world@v.co for v in evaluated.data.vertices]
 low=Vector((min(v.x for v in verts),min(v.y for v in verts),min(v.z for v in verts)))
 high=Vector((max(v.x for v in verts),max(v.y for v in verts),max(v.z for v in verts)))
 center=(low+high)/2;height=high.z-low.z
 bpy.ops.object.camera_add(location=center+Vector((height*.30,-height*2,height*.22)))
 camera=bpy.context.object;camera.rotation_euler=(center-camera.location).to_track_quat('-Z','Y').to_euler()
 camera.data.type='ORTHO';camera.data.ortho_scale=height*1.2;scene.camera=camera
 bpy.ops.object.light_add(type='AREA',location=center+Vector((-height,-height,height*2)))
 bpy.context.object.data.energy=250;bpy.context.object.data.size=height*2
 scene.world=bpy.data.worlds.new('pilot white');scene.world.use_nodes=True;scene.world.node_tree.nodes['Background'].inputs[0].default_value=(.8,.8,.8,1)
 scene.cycles.samples=8;scene.cycles.use_denoising=False
 scene.render.resolution_x=512;scene.render.resolution_y=512;scene.render.resolution_percentage=100
 scene.render.image_settings.file_format='PNG'
 scene.render.filepath=str(HERE/'baked-rest.png');bpy.ops.render.render(write_still=True)
 rig.data.pose_position='POSE'
 rig.animation_data.action=motion_actions['walk'];scene.frame_set(8)
 scene.render.filepath=str(HERE/'baked-walk.png');bpy.ops.render.render(write_still=True)
 completion={'success':True,'route':'actual stdio MCP execute_blender_code launched pinned native headless process','blender':bpy.app.version_string,'background':bpy.app.background,'device':'CPU',
 'input':SOURCE.name,'input_sha256':hashlib.sha256(raw).hexdigest(),'input_bytes':len(raw),'input_triangles':source_triangles,'input_joints':24,'input_clip_names':[a['name'] for a in source_json['animations']],
 'uv_unchanged_in_memory':True,'rest_skeleton_unchanged':True,'clip_transfer_checks':comparisons,
 'derived_material_roughness':1.0,'derived_material_metallic':0.0,'raw_idle_scale_not_normalized_here':True,
 'derived_emission_removed':True,'derived_specular_ior_level':0.0,
 'source_shape_height':height,'bounds_exclude_non_skinned_helper':True,'output':output.name,'output_sha256':hashlib.sha256(out_raw).hexdigest(),'output_bytes':len(out_raw),
 'output_triangles':output_triangles,'output_meshes':len(data['meshes']),'output_joints':len(data['skins'][0]['joints']),'output_clip_names':[a['name'] for a in data['animations']],
 'image_size':[512,512],'rgb_min':min(rgb),'rgb_max':max(rgb),'embedded_images':len(data['images']),'paid_calls':0,'cost_usd':0,'godot_tested':False}
 DONE.write_text(json.dumps(completion,indent=2)+'\n')
 print('TARGET_BAKE_COMPLETED',flush=True)
except Exception:
 DONE.write_text(json.dumps({'success':False,'error':traceback.format_exc()},indent=2)+'\n')
 raise
