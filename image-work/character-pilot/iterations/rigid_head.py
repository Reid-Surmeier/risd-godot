"""THROWAWAY: remove limb influences from this measured chibi head; native portable skin."""
import bpy, json, hashlib
import numpy as np
from pathlib import Path
HERE=Path(__file__).resolve().parent
SOURCE=HERE.parent/'target-baked-normalized-idle.glb'
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.context.scene.render.fps=30
bpy.context.preferences.filepaths.save_version=0
bpy.ops.import_scene.gltf(filepath=str(SOURCE))
rig=next(o for o in bpy.context.scene.objects if o.type=='ARMATURE')
mesh=next(o for o in bpy.context.scene.objects if o.type=='MESH' and o.find_armature()==rig)
for track in rig.animation_data.nla_tracks: track.mute=True
walk=next(t.strips[0].action for t in rig.animation_data.nla_tracks if t.name=='walk')
rig.animation_data.action=walk
rig.data.pose_position='REST';bpy.context.view_layer.update()
rest=np.array([tuple(mesh.matrix_world@v.co) for v in mesh.data.vertices])
uv_before=[tuple(p.uv) for p in mesh.data.uv_layers.active.data]
# ponytail: measured collar height for this pilot, not an automatic head classifier.
ids=np.where(rest[:,2]>=1.05)[0].tolist()
head=mesh.vertex_groups['Head']
for group in mesh.vertex_groups: group.remove(ids)
head.add(ids,1.0,'REPLACE')
mesh.data.update();mesh.update_tag(refresh={'OBJECT','DATA'})
rig.data.pose_position='POSE'
ref=rest[ids]-rest[ids].mean(axis=0)
errors=[]
for i in range(32):
 frame=float(walk.frame_range[0]+(walk.frame_range[1]-walk.frame_range[0])*i/32)
 bpy.context.scene.frame_set(int(frame),subframe=frame-int(frame))
 bpy.context.view_layer.update()
 obj=mesh.evaluated_get(bpy.context.evaluated_depsgraph_get())
 cur=np.array([tuple(obj.matrix_world@obj.data.vertices[v].co) for v in ids])
 cur-=cur.mean(axis=0)
 u,_,vt=np.linalg.svd(ref.T@cur);rotation=u@vt
 if np.linalg.det(rotation)<0:u[:,-1]*=-1;rotation=u@vt
 errors.append(float(np.sqrt(np.mean(np.sum((ref@rotation-cur)**2,axis=1)))))
assert max(errors)<0.0001,errors
assert [tuple(p.uv) for p in mesh.data.uv_layers.active.data]==uv_before
assert len(rig.data.bones)==24 and sum(len(p.vertices)-2 for p in mesh.data.polygons)==7719
assert all(len(mesh.data.vertices[v].groups)==1 and abs(mesh.data.vertices[v].groups[0].weight-1)<1e-6 for v in ids)
bpy.ops.object.select_all(action='DESELECT');rig.select_set(True);mesh.select_set(True);bpy.context.view_layer.objects.active=mesh
output=HERE/'rigid-head.glb'
bpy.ops.export_scene.gltf(filepath=str(output),export_format='GLB',use_selection=True,export_animations=True,export_animation_mode='ACTIONS',export_skins=True,export_force_sampling=False)
bpy.ops.wm.save_as_mainfile(filepath=str(HERE/'rigid-head.blend'),compress=True)
report={'success':True,'source_sha256':hashlib.sha256(SOURCE.read_bytes()).hexdigest(),'output_sha256':hashlib.sha256(output.read_bytes()).hexdigest(),'head_world_z_threshold_m':1.05,'head_vertices':len(ids),'head_rigid_fit_rms_max_m':max(errors),'sample_count':32,'uv_and_geometry_unchanged':True,'bones':24,'triangles':7719,'cost_usd':0,'scope':'head/cap/horn skin repair; foot contacts separate'}
(HERE/'rigid_head.json').write_text(json.dumps(report,indent=2)+'\n')
print('RIGID_HEAD_PASS',json.dumps(report))
