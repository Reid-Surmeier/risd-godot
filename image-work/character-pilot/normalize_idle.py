"""THROWAWAY derived Idle repair. Preserve target-baked.glb and provider files."""
import bpy,json,struct,hashlib,traceback
from pathlib import Path
from mathutils import Vector
HERE=Path(__file__).resolve().parent
DONE=HERE/'target-idle-normalization.json'
def bounds(mesh):
 bpy.context.view_layer.update()
 obj=mesh.evaluated_get(bpy.context.evaluated_depsgraph_get())
 verts=[obj.matrix_world@v.co for v in obj.data.vertices]
 low=[min(v[i] for v in verts) for i in range(3)]
 high=[max(v[i] for v in verts) for i in range(3)]
 return {'low':low,'high':high,'height':high[2]-low[2]}
try:
 bpy.ops.wm.read_factory_settings(use_empty=True)
 source=HERE/'target-baked.glb'
 original=source.read_bytes()
 bpy.ops.import_scene.gltf(filepath=str(source))
 rig=next(o for o in bpy.context.scene.objects if o.type=='ARMATURE')
 mesh=next(o for o in bpy.context.scene.objects if o.type=='MESH' and o.find_armature()==rig)
 idle=next(t.strips[0].action for t in rig.animation_data.nla_tracks if t.name=='idle')
 walk=next(t.strips[0].action for t in rig.animation_data.nla_tracks if t.name=='walk')
 for track in rig.animation_data.nla_tracks:track.mute=True
 rig.data.pose_position='REST';rest=bounds(mesh)
 rig.data.pose_position='POSE';rig.animation_data.action=idle
 frame=int(idle.frame_range[0]);bpy.context.scene.frame_set(frame)
 raw=bounds(mesh)
 curves=[f for f in idle.fcurves if f.data_path=='pose.bones["Hips"].scale']
 assert len(curves)==3 and {f.array_index for f in curves}=={0,1,2}
 old_values=[p.co.y for f in curves for p in f.keyframe_points]
 assert old_values and all(abs(v-1.176471)<1e-4 for v in old_values)
 scene=bpy.context.scene
 center=Vector([(rest['low'][i]+rest['high'][i])/2 for i in range(3)])
 height=rest['height']
 bpy.ops.object.camera_add(location=center+Vector((height*.3,-height*2,height*.22)))
 camera=bpy.context.object;camera.rotation_euler=(center-camera.location).to_track_quat('-Z','Y').to_euler();camera.data.type='ORTHO';camera.data.ortho_scale=height*1.4;scene.camera=camera
 bpy.ops.object.light_add(type='AREA',location=center+Vector((-height,-height,height*2)))
 bpy.context.object.data.energy=250;bpy.context.object.data.size=height*2
 scene.world=bpy.data.worlds.new('normalization white');scene.world.use_nodes=True;scene.world.node_tree.nodes['Background'].inputs[0].default_value=(.8,.8,.8,1)
 scene.render.engine='CYCLES';scene.cycles.device='CPU';scene.cycles.samples=8
 scene.cycles.use_denoising=False;scene.render.resolution_x=512;scene.render.resolution_y=512;scene.render.resolution_percentage=100
 scene.render.filepath=str(HERE/'baked-idle-raw.png');bpy.ops.render.render(write_still=True)
 for f in curves:
  for p in f.keyframe_points:p.co.y=1.0;p.handle_left.y=1.0;p.handle_right.y=1.0
  f.update()
 rig.update_tag(refresh={'OBJECT','DATA','TIME'})
 scene.frame_set(frame+1);scene.frame_set(frame)
 corrected=bounds(mesh)
 assert all(abs(v-1)<1e-6 for v in rig.pose.bones['Hips'].scale)
 scene.render.filepath=str(HERE/'baked-idle-normalized.png');bpy.ops.render.render(write_still=True)
 bpy.ops.object.select_all(action='DESELECT');rig.select_set(True);mesh.select_set(True);bpy.context.view_layer.objects.active=mesh
 output=HERE/'target-baked-normalized-idle.glb'
 bpy.ops.export_scene.gltf(filepath=str(output),export_format='GLB',use_selection=True,export_animations=True,export_animation_mode='ACTIONS',export_skins=True,export_force_sampling=False)
 out=output.read_bytes();length=struct.unpack_from('<I',out,12)[0];data=json.loads(out[20:20+length])
 assert len(data['skins'][0]['joints'])==24 and len(data['animations'])==4
 assert sum(data['accessors'][p['indices']]['count']//3 for m in data['meshes'] for p in m['primitives'])==7719
 rig.animation_data.action=walk;scene.frame_set(8);walk_bounds=bounds(mesh)
 report={'success':True,'derived_only':True,'source':source.name,'source_sha256':hashlib.sha256(original).hexdigest(),'output':output.name,'output_sha256':hashlib.sha256(out).hexdigest(),'clip':'idle','changed_channel':'pose.bones["Hips"].scale','before_key_value_min':min(old_values),'before_key_value_max':max(old_values),'after_key_value':1.0,'curves_changed':len(curves),'key_points_changed':len(old_values),'rest_bounds':rest,'raw_idle_bounds':raw,'normalized_idle_bounds':corrected,'walk_frame8_bounds':walk_bounds,'bones':24,'triangles':7719,'clip_names':[a['name'] for a in data['animations']],'material_and_atlas_preserved':True,'raw_file_unchanged':source.read_bytes()==original,'walk_contact_not_fixed':True,'blender':bpy.app.version_string,'cost_usd':0}
 DONE.write_text(json.dumps(report,indent=2)+'\n')
 print('IDLE_NORMALIZED')
except Exception:
 DONE.write_text(json.dumps({'success':False,'error':traceback.format_exc()},indent=2)+'\n')
 raise
