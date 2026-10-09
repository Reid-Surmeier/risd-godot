"""Read-only native empirical character rig diagnosis. Writes sanitized measurements only."""
import bpy, json, hashlib, math
import numpy as np
from pathlib import Path
HERE=Path(__file__).resolve().parent
SOURCE=HERE.parents[1]/'target-baked-normalized-idle.glb'
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=str(SOURCE))
rig=next(o for o in bpy.context.scene.objects if o.type=='ARMATURE')
mesh=next(o for o in bpy.context.scene.objects if o.type=='MESH' and o.find_armature()==rig)
walk=next(t.strips[0].action for t in rig.animation_data.nla_tracks if t.name=='walk')
for t in rig.animation_data.nla_tracks:t.mute=True
rig.animation_data.action=walk
rig.data.pose_position='REST';bpy.context.view_layer.update()
def world_positions():
 bpy.context.view_layer.update()
 obj=mesh.evaluated_get(bpy.context.evaluated_depsgraph_get())
 return np.array([tuple(obj.matrix_world@v.co) for v in obj.data.vertices])
rest=world_positions()
groups={g.index:g.name for g in mesh.vertex_groups}
weights=[{groups[g.group]:g.weight for g in v.groups if g.weight>1e-5} for v in mesh.data.vertices]
neighbors=[set() for _ in mesh.data.vertices]
for e in mesh.data.edges:
 a,b=e.vertices;neighbors[a].add(b);neighbors[b].add(a)
todo=set(range(len(neighbors)));components=[]
while todo:
 seed=todo.pop();stack=[seed];members=[seed]
 while stack:
  for other in neighbors[stack.pop()]:
   if other in todo:todo.remove(other);members.append(other);stack.append(other)
 pts=rest[members]
 components.append({'vertices':len(members),'low':pts.min(axis=0).tolist(),'high':pts.max(axis=0).tolist()})
components.sort(key=lambda c:c['vertices'],reverse=True)
# Diagnostic welding joins source duplicates at UV/normal seams; never edit the mesh.
weld_position_index={};aliases=[]
for i,point in enumerate(rest):
 key=tuple(round(float(v),5) for v in point);aliases.append(weld_position_index.setdefault(key,i))
welded_neighbors={i:set() for i in set(aliases)}
for e in mesh.data.edges:
 a,b=(aliases[i] for i in e.vertices);welded_neighbors[a].add(b);welded_neighbors[b].add(a)
todo=set(welded_neighbors);welded=[]
while todo:
 seed=todo.pop();stack=[seed];members=[seed]
 while stack:
  for other in welded_neighbors[stack.pop()]:
   if other in todo:todo.remove(other);stack.append(other);members.append(other)
 welded.append({'unique_positions':len(members),'low':rest[members].min(axis=0).tolist(),'high':rest[members].max(axis=0).tolist()})
welded.sort(key=lambda c:c['unique_positions'],reverse=True)
slices=[]
for low in np.arange(.6,1.41,.05):
 indices=np.where((rest[:,2]>=low)&(rest[:,2]<low+.05))[0]
 if len(indices):
  pts=rest[indices]
  slices.append({'z_low':float(low),'count':len(indices),'x_span':float(np.ptp(pts[:,0])),'y_span':float(np.ptp(pts[:,1])),'median_abs_x':float(np.median(np.abs(pts[:,0])))})
def weight_summary(mask):
 ids=np.where(mask)[0];totals={};dominant={};outside=0
 for i in ids:
  for name,value in weights[i].items():totals[name]=totals.get(name,0)+value
  top=max(weights[i],key=weights[i].get);dominant[top]=dominant.get(top,0)+1
  if any(name not in ['Head','neck','head_end','headfront'] and value>.02 for name,value in weights[i].items()):outside+=1
 return {'vertices':len(ids),'average_weights':{k:v/len(ids) for k,v in sorted(totals.items(),key=lambda p:-p[1])},'dominant_counts':dominant,'vertices_non_head_neck_weight_gt_02':outside}
masks={'above_neck_bone':rest[:,2]>(rig.matrix_world@rig.data.bones['neck'].head_local).z,'head_z1_05':rest[:,2]>=1.05,'head_z1_10':rest[:,2]>=1.10,'head_z1_15':rest[:,2]>=1.15,'cap_horns_z1_55':rest[:,2]>=1.55}
edge_pairs=np.array([tuple(e.vertices) for e in mesh.data.edges],dtype=int)
bone_names=['Hips','Spine02','Spine01','Spine','neck','Head','head_end','headfront']
def matrix_stats(matrix):
 a=np.array([list(row)[:3] for row in matrix][:3])
 columns=a.T;norms=np.linalg.norm(columns,axis=1)
 normalized=columns/norms[:,None]
 gram=normalized@normalized.T
 return {'column_scales':norms.tolist(),'max_axis_dot':float(np.max(np.abs(gram-np.eye(3)))),'singular_values':np.linalg.svd(a,compute_uv=False).tolist()}
def deformation(mask,positions):
 selected=mask[edge_pairs[:,0]]&mask[edge_pairs[:,1]]
 pairs=edge_pairs[selected]
 old=rest[pairs[:,0]]-rest[pairs[:,1]]
 new=positions[pairs[:,0]]-positions[pairs[:,1]]
 before=np.linalg.norm(old,axis=1);after=np.linalg.norm(new,axis=1)
 good=before>1e-7;ratio=after[good]/before[good]
 # Global shape alignment removes translation and one rigid rotation, never scaling.
 ref=rest[mask];cur=positions[mask]
 x=ref-ref.mean(axis=0);y=cur-cur.mean(axis=0)
 u,_,vt=np.linalg.svd(x.T@y)
 rotation=u@vt
 if np.linalg.det(rotation)<0:u[:,-1]*=-1;rotation=u@vt
 residual=np.linalg.norm(x@rotation-y,axis=1)
 return {'edge_count':len(ratio),'ratio_min':float(ratio.min()),'ratio_p05':float(np.percentile(ratio,5)),'ratio_median':float(np.median(ratio)),'ratio_p95':float(np.percentile(ratio,95)),'ratio_max':float(ratio.max()),'rigid_alignment_rms_m':float(np.sqrt(np.mean(residual**2))),'rigid_alignment_max_m':float(residual.max())}
start,end=walk.frame_range
frames=[float(start+(end-start)*i/24) for i in range(24)]
rig.data.pose_position='POSE'
records=[]
for frame in frames:
 bpy.context.scene.frame_set(int(frame),subframe=frame-int(frame))
 positions=world_positions()
 records.append({'frame':frame,'bones':{name:{'pose_scale':list(rig.pose.bones[name].scale),'pose_matrix':matrix_stats(rig.pose.bones[name].matrix),'deform_matrix':matrix_stats(rig.pose.bones[name].matrix@rig.data.bones[name].matrix_local.inverted())} for name in bone_names},'deformation':{name:deformation(mask,positions) for name,mask in masks.items()}})
report={'source_sha256':hashlib.sha256(SOURCE.read_bytes()).hexdigest(),'blender':bpy.app.version_string,'vertex_count':len(mesh.data.vertices),'bone_count':len(rig.data.bones),'walk_action':walk.name,'walk_frame_range':[float(start),float(end)],'masks':{n:weight_summary(m) for n,m in masks.items()},'components':components[:40],'slices':slices,'rest_bones':{n:{'head_world':list(rig.matrix_world@rig.data.bones[n].head_local),'tail_world':list(rig.matrix_world@rig.data.bones[n].tail_local)} for n in bone_names},'walk_samples':records,'armature_preserve_volume':next(m for m in mesh.modifiers if m.type=='ARMATURE').use_deform_preserve_volume,'paid_calls':0}
report['diagnostic_welded_components']={'coordinate_rounding_m':1e-5,'unique_positions':len(weld_position_index),'components':welded}
report['joint_mask_ambiguity']={name:{'head_world':list(rig.matrix_world@rig.data.bones[name].head_local),'parent':rig.data.bones[name].parent.name} for name in ['LeftHand','RightHand','LeftForeArm','RightForeArm','LeftFoot','RightFoot','LeftToeBase','RightToeBase']}
report['hand_foot_spatial_masks']={'outer_mittens_absx_gt_069_z06to09':weight_summary((np.abs(rest[:,0])>.69)&(rest[:,2]>=.6)&(rest[:,2]<=.9)),'shoes_below_z016':weight_summary(rest[:,2]<=.16)}
# Variant checks change RAM only. No modified mesh, rig or animation is saved.
def sample_core():
 metrics=[]
 for frame in frames:
  bpy.context.scene.frame_set(int(frame),subframe=frame-int(frame))
  metrics.append(deformation(masks['head_z1_10'],world_positions()))
 return {'head_core_rms_m_max':max(m['rigid_alignment_rms_m'] for m in metrics),'head_core_edge_ratio_min':min(m['ratio_min'] for m in metrics),'head_core_edge_ratio_max':max(m['ratio_max'] for m in metrics)}
variants={'baseline':sample_core()}
saved=[]
for f in walk.fcurves:
 if f.data_path.endswith('].scale') and any(f.data_path.startswith('pose.bones["'+name+'"]') for name in bone_names):
  for p in f.keyframe_points:
   saved.append((p,p.co.y,p.handle_left.y,p.handle_right.y))
   p.co.y=p.handle_left.y=p.handle_right.y=1.0
  f.update()
rig.update_tag(refresh={'OBJECT','DATA','TIME'})
variants['ancestor_scale_tracks_forced_one']=sample_core()
for point,value,left,right in saved:point.co.y=value;point.handle_left.y=left;point.handle_right.y=right
for f in walk.fcurves:f.update()
rig.update_tag(refresh={'OBJECT','DATA','TIME'})
head=mesh.vertex_groups['Head']
for threshold in [1.10,1.05,1.0]:
 ids=np.where(rest[:,2]>=threshold)[0].tolist()
 for group in mesh.vertex_groups:group.remove(ids)
 head.add(ids,1.0,'REPLACE')
 mesh.data.update();mesh.update_tag(refresh={'OBJECT','DATA'})
 variants['rigid_head_z'+str(threshold)]=sample_core()
report['ram_only_variant_checks']=variants
assert variants['baseline']['head_core_rms_m_max']>.01
assert abs(variants['ancestor_scale_tracks_forced_one']['head_core_rms_m_max']-variants['baseline']['head_core_rms_m_max'])<.001
assert variants['rigid_head_z1.1']['head_core_rms_m_max']<.001
print('RAM_ONLY_VARIANTS',json.dumps(variants))
(HERE/'diagnosis.json').write_text(json.dumps(report,indent=2)+'\n')
print('MASKS',json.dumps(report['masks']))
print('COMPONENTS',json.dumps(report['components'][:8]))
print('DEFORMATION_MAX',json.dumps({n:{'rms_m_max':max(r['deformation'][n]['rigid_alignment_rms_m'] for r in records),'edge_ratio_min':min(r['deformation'][n]['ratio_min'] for r in records),'edge_ratio_max':max(r['deformation'][n]['ratio_max'] for r in records)} for n in masks}))
print('BONE_SCALE_RANGES',json.dumps({n:{'local_min':min(min(r['bones'][n]['pose_scale']) for r in records),'local_max':max(max(r['bones'][n]['pose_scale']) for r in records),'deform_singular_min':min(min(r['bones'][n]['deform_matrix']['singular_values']) for r in records),'deform_singular_max':max(max(r['bones'][n]['deform_matrix']['singular_values']) for r in records),'shear_max':max(r['bones'][n]['deform_matrix']['max_axis_dot'] for r in records)} for n in bone_names}))
