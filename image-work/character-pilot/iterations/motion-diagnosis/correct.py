"""Throwaway analytic two-joint footplant candidate; no imported display-tail assumptions.
Run pinned Blender4.3.2 --background --factory-startup --python correct.py.
"""
import bpy,json,hashlib,math,struct,sys
from pathlib import Path
from mathutils import Vector,Matrix,Quaternion
HERE=Path(__file__).resolve().parent
SOURCE=HERE.parent/'rigid-head.glb'
profile={}
if '--profile' in sys.argv:
 profile_path=Path(sys.argv[sys.argv.index('--profile')+1]).resolve()
 assert profile_path.is_relative_to(HERE.parent/'video-match') and profile_path.is_file()
 profile=json.loads(profile_path.read_text())
 DEST=profile_path.parent/profile_path.stem;DEST.mkdir(exist_ok=True)
else:DEST=HERE
assert SOURCE.exists(),'root rigid-head candidate must exist first'
bpy.ops.wm.read_factory_settings(use_empty=True)
scene=bpy.context.scene;fps=profile.get('bake_fps',60);assert fps in [60,240];scene.render.fps=fps
bpy.ops.import_scene.gltf(filepath=str(SOURCE))
rig=next(o for o in scene.objects if o.type=='ARMATURE')
mesh=next(o for o in scene.objects if o.type=='MESH' and o.find_armature()==rig)
for track in rig.animation_data.nla_tracks:track.mute=True
rig.data.pose_position='REST';bpy.context.view_layer.update()
rests={b.name:b.matrix_local.copy() for b in rig.data.bones}
sig={b.name:(b.parent.name if b.parent else None,tuple(v for row in b.matrix_local for v in row)) for b in rig.data.bones}
restverts=[mesh.matrix_world@v.co for v in mesh.data.vertices]
if profile.get('arm_weight_mask'):
 mask=json.loads((profile_path.parent/profile['arm_weight_mask']).read_text())
 assert len(mask['vertices'])==mask['vertex_count']
 groups={g.index:g.name for g in mesh.vertex_groups}
 for item in mask['vertices']:
  index=item['id'];weights=item['weights']
  assert (restverts[index]-Vector(item['rest_world_m'])).length<.00002,'arm mask geometry mismatch'
  original={groups[g.group]:g.weight for g in mesh.data.vertices[index].groups if g.weight>1e-6}
  assert set(original)==set(item['original_weights']) and all(abs(value-item['original_weights'][name])<.00001 for name,value in original.items()),'arm mask weight mismatch'
  assert abs(sum(weights.values())-1)<1e-6 and all(0<value<=1 for value in weights.values())
  for group in mesh.vertex_groups:group.remove([index])
  for name,value in weights.items():mesh.vertex_groups[name].add([index],value,'REPLACE')
if profile.get('jaw_mask'):
 mask=json.loads((profile_path.parent/profile['jaw_mask']).read_text())
 jawids=mask['additional_vertex_ids']
 coordinates={v['id']:Vector(v['rest_world_m']) for v in mask['vertices']}
 assert len(jawids)==mask['vertex_count'] and all((restverts[i]-coordinates[i]).length<.00002 for i in jawids),'jaw mask does not match imported geometry'
 for group in mesh.vertex_groups:group.remove(jawids)
 mesh.vertex_groups['Head'].add(jawids,1,'REPLACE')
shoeids={s:[i for i,v in enumerate(restverts) if v.z<=.20 and (v.x>0 if s=='Left' else v.x<=0)] for s in ['Left','Right']}
# Deliberately narrow, target-specific shoe repair; preserve positions, faces, atlas.
for side,ids in shoeids.items():
 for group in mesh.vertex_groups:group.remove(ids)
 mesh.vertex_groups[side+'Foot'].add(ids,1,'REPLACE')
mesh.data.update();mesh.update_tag(refresh={'OBJECT','DATA'})
restworld={n:rig.matrix_world@m for n,m in rests.items()}
reference=None
if profile.get('source_curves'):
 reference=json.loads((profile_path.parent/profile['source_curves']).read_text())
 assert len(reference['samples'])==129 and len(reference['joint_hierarchy'])==26
 conversion=Matrix(((1,0,0),(0,0,-1),(0,1,0)))
 neutral={};indices={}
 structural={'root':(0,0,90),'LeftHipBase':(0,0,180),'RightHipBase':(0,0,180),'LeftShoulderBase':(0,0,-90),'RightShoulderBase':(0,0,90)}
 for joint in reference['joint_hierarchy']:
  indices[joint['name']]=joint['index'];rotation=Matrix.Identity(3)
  angles=structural.get(joint['name'],(0,0,0))
  for axis,angle in zip('ZYX',reversed(angles)):rotation=rotation@Matrix.Rotation(math.radians(angle),3,axis)
  parent=joint['parent'];neutral[joint['index']]=rotation if parent is None else neutral[parent]@rotation
 mapping={'Hips':'base','Spine02':'chest','Spine01':'chest','Spine':'chest','LeftShoulder':'LeftShoulderBase','LeftArm':'LeftUpperArm','LeftForeArm':'LeftForearm','LeftHand':'LeftForearm','RightShoulder':'RightShoulderBase','RightArm':'RightUpperArm','RightForeArm':'RightForearm','RightHand':'RightForearm','neck':'HeadBase','Head':'head','LeftUpLeg':'LeftThigh','LeftLeg':'LeftKnee','LeftFoot':'LeftShoe','LeftToeBase':'LeftShoe','RightUpLeg':'RightThigh','RightLeg':'RightKnee','RightFoot':'RightShoe','RightToeBase':'RightShoe'}
 # Parent first even though the source and target have different extra spine/hand joints.
 order=sorted(mapping,key=lambda n:len(rig.data.bones[n].parent_recursive))
 calibration={name:Quaternion() for name in mapping}
 if profile.get('anatomical_axes',False):
  children={'Shoulder':'Arm','Arm':'ForeArm','ForeArm':'Hand','UpLeg':'Leg','Leg':'Foot'}
  for side in ['Left','Right']:
   for part,child in children.items():
    name=side+part;j=indices[mapping[name]]
    own=(restworld[side+child].translation-restworld[name].translation).normalized()
    canonical=(conversion@neutral[j]@Vector((1,0,0))).normalized()
    calibration[name]=own.rotation_difference(canonical)
soleoffset={s:restworld[s+'Foot'].translation.z-min(restverts[i].z for i in ids) for s,ids in shoeids.items()}
rig.data.pose_position='POSE'
length=profile.get('period_seconds',32/30);speed=profile.get('controller_speed_mps',.52);stance=.5;swinglift=profile.get('swing_lift_m',.08)
walkframes=round(length*fps)
assert abs(walkframes/fps-length)<1e-6 and walkframes%2==0 and 0<speed<2 and 0<swinglift<.3
sources={kind:next(t.strips[0].action for t in rig.animation_data.nla_tracks if t.name==kind) for kind in ['idle','walk']}
reports={};newactions={}
for kind,source in sources.items():
 rig.animation_data.action=source
 frames=walkframes if kind=='walk' else round(121/30*fps)
 samples=[]
 boundary={}
 if kind=='walk':
  for key in [0,2,frames-2]:
   sf=2+key*62/frames
   scene.frame_set(int(sf),subframe=sf-int(sf));bpy.context.view_layer.update()
   boundary[key]={p.name:(p.location.copy(),p.rotation_quaternion.copy(),p.scale.copy()) for p in rig.pose.bones}
 # Pose sampling before assigning a new action; explicitly evaluate source time, preserving source seconds.
 for frame in range(frames+1):
  # Provider omitted time0 rotation keys, yielding a one-frame leading hold.
  sourceframe=2+frame*62/frames if kind=='walk' else frame*60/fps
  scene.frame_set(int(sourceframe),subframe=sourceframe-int(sourceframe))
  bpy.context.view_layer.update()
  if kind=='walk' and frame in [1,2,frames-2,frames-1]:
   # Symmetric local tangents around the repeated start pose; solve legs again afterward.
   for p in rig.pose.bones:
    if any(p.name==side+part for side in ['Left','Right'] for part in ['UpLeg','Leg','Foot','ToeBase']):continue
    loc0,q0,scale0=boundary[0][p.name]
    loc1,q1,_=boundary[2][p.name];loc31,q31,_=boundary[frames-2][p.name]
    tangent=((q0.inverted()@q1).to_exponential_map()-(q0.inverted()@q31).to_exponential_map())/2
    sign=frame/2 if frame<=2 else -(frames-frame)/2
    p.location=loc0+sign*(loc1-loc31)/2
    p.rotation_quaternion=q0@Quaternion(sign*tangent)
    p.scale=scale0
   bpy.context.view_layer.update()
  if profile.get('forward_idle',False) and kind=='idle':
   # ponytail: forward idle for this pilot; authored look targets belong to a later runtime controller.
   hips=restworld['Hips'].copy();hips.translation.z+=.002*math.sin(2*math.pi*frame/frames)
   rig.pose.bones['Hips'].matrix=rig.matrix_world.inverted()@hips
   bpy.context.view_layer.update()
   for name in ['Spine02','Spine01','Spine']:
    bone=rig.pose.bones[name];position=(rig.matrix_world@bone.matrix).translation.copy()
    pose=restworld[name].copy();pose.translation=position
    bone.matrix=rig.matrix_world.inverted()@pose;bpy.context.view_layer.update()
  if profile.get('stable_head',False):
   for name in ['neck','Head']:
    bone=rig.pose.bones[name];position=(rig.matrix_world@bone.matrix).translation.copy()
    pose=restworld[name].copy();pose.translation=position
    if name=='Head' and kind=='walk':
     pitch=math.radians(profile.get('head_pitch_degrees',1))*math.sin(4*math.pi*frame/frames)
     pose=Quaternion(Vector((1,0,0)),pitch).to_matrix().to_4x4()@pose;pose.translation=position
    bone.matrix=rig.matrix_world.inverted()@pose;bpy.context.view_layer.update()
  if reference is not None and kind=='walk':
   pos=frame/frames*128;index=min(127,int(pos));fraction=pos-index
   a=reference['samples'][index];b=reference['samples'][index+1]
   for name in order:
    j=indices[mapping[name]]
    qa=Matrix(a['global_matrices_row_major'][j]).to_quaternion();qb=Matrix(b['global_matrices_row_major'][j]).to_quaternion()
    rotation=conversion@qa.slerp(qb,fraction).to_matrix()@neutral[j].inverted()@conversion.inverted()
    bone=rig.pose.bones[name];origin=(rig.matrix_world@bone.matrix).translation.copy()
    if name=='Hips':
     y=a['global_joint_positions'][0][1]*(1-fraction)+b['global_joint_positions'][0][1]*fraction
     origin=restworld[name].translation.copy();origin.z+=(y-1000)*profile.get('source_units_to_m',.0004695)
    pose=(rotation@calibration[name].to_matrix()@restworld[name].to_quaternion().to_matrix()).to_4x4()@Matrix.Diagonal(Vector((.01,.01,.01,1)))
    pose.translation=origin;bone.matrix=rig.matrix_world.inverted()@pose;bpy.context.view_layer.update()
  original={p.name:rig.matrix_world@p.matrix.copy() for p in rig.pose.bones}
  targets={};contact={}
  for side,phaseoffset in [('Left',.25),('Right',.75)]:
   if reference is not None and kind=='walk' and profile.get('authored_legs',False):continue
   phase=((frame/frames-phaseoffset)%1) if kind=='walk' else 0
   contact[side]=kind=='idle' or phase<stance
   ycenter=restworld[side+'Foot'].translation.y
   if kind=='idle':forward=0;lift=0
   elif phase<stance:
    forward=speed*length*(stance/2-phase);lift=0
   else:
    u=(phase-stance)/(1-stance)
    amp=speed*length*stance/2
    tangent=-speed*length*(1-stance)
    forward=-amp+tangent*u+(2*amp-tangent)*(10*u**3-15*u**4+6*u**5)
    lift=64*swinglift*u**3*(1-u)**3
   targets[side]=Vector((restworld[side+'Foot'].translation.x,ycenter-forward,soleoffset[side]+lift))
  # Keep source pelvis bob unless reach would overextend the short legs.
  hips=original['Hips'].translation
  lower=0
  for side in targets:
   hip=original[side+'UpLeg'].translation
   knee=original[side+'Leg'].translation;ankle=original[side+'Foot'].translation
   l1=(knee-hip).length;l2=(ankle-knee).length
   horiz=Vector((targets[side].x-hip.x,targets[side].y-hip.y,0)).length
   maxheight=targets[side].z+math.sqrt(max(0,(.985*(l1+l2))**2-horiz*horiz))
   lower=max(lower,hip.z-maxheight)
  lower=max(lower,0)
  pelvis=original['Hips'].copy();pelvis.translation.z-=lower
  rig.pose.bones['Hips'].matrix=rig.matrix_world.inverted()@pelvis
  bpy.context.view_layer.update()
  errors={}
  for side,target in targets.items():
   thigh=rig.pose.bones[side+'UpLeg'];shin=rig.pose.bones[side+'Leg'];foot=rig.pose.bones[side+'Foot']
   h=(rig.matrix_world@thigh.matrix).translation.copy()
   k0=original[side+'Leg'].translation-Vector((0,0,lower));a0=original[side+'Foot'].translation-Vector((0,0,lower))
   l1=(k0-h).length;l2=(a0-k0).length
   direction=(target-h);d=direction.length;direction.normalize()
   assert abs(l1-l2)+1e-5<d<l1+l2-1e-5,(frame,side,d,l1,l2)
   along=(l1*l1-l2*l2+d*d)/(2*d)
   pole=Vector((0,-1,0));pole=(pole-direction*pole.dot(direction)).normalized()
   knee=h+direction*along+pole*math.sqrt(max(0,l1*l1-along*along))
   delta=(k0-h).normalized().rotation_difference((knee-h).normalized())
   tmat=(delta@original[side+'UpLeg'].to_quaternion()).to_matrix().to_4x4();tmat= tmat@Matrix.Diagonal(Vector((.01,.01,.01,1)));tmat.translation=h
   thigh.matrix=rig.matrix_world.inverted()@tmat
   bpy.context.view_layer.update()
   delta=(a0-k0).normalized().rotation_difference((target-knee).normalized())
   smat=(delta@original[side+'Leg'].to_quaternion()).to_matrix().to_4x4();smat=smat@Matrix.Diagonal(Vector((.01,.01,.01,1)));smat.translation=knee
   shin.matrix=rig.matrix_world.inverted()@smat
   bpy.context.view_layer.update()
   fmat=restworld[side+'Foot'].copy();fmat.translation=target
   foot.matrix=rig.matrix_world.inverted()@fmat
   bpy.context.view_layer.update()
   errors[side]=((rig.matrix_world@foot.matrix).translation-target).length
  source_ground_shift=0
  if reference is not None and kind=='walk' and profile.get('authored_legs',False):
   # Preserve authored joint rotations; only the visual root is translated onto this plane.
   # ponytail: this target has different leg/foot proportions; ground shift is not a stance lock.
   evaluated=mesh.evaluated_get(bpy.context.evaluated_depsgraph_get())
   floor=min((evaluated.matrix_world@v.co).z for v in evaluated.data.vertices)
   pelvis=rig.matrix_world@rig.pose.bones['Hips'].matrix;pelvis.translation.z-=floor
   rig.pose.bones['Hips'].matrix=rig.matrix_world.inverted()@pelvis;bpy.context.view_layer.update()
   source_ground_shift=-floor
  if profile.get('symmetric_arms',False) and not(reference is not None and kind=='walk'):
   # Wrist paths are mirrored, using each arm's actual unequal segment lengths.
   # Mirroring rotations alone would preserve the provider's asymmetric hand paths.
   phase=2*math.pi*frame/frames
   amplitude=profile.get('arm_swing_m',.14) if kind=='walk' else 0
   radius=profile.get('arm_reach_m',.35)
   for side,sign in [('Left',1),('Right',-1)]:
    shoulder=rig.pose.bones[side+'Shoulder'];pos=(rig.matrix_world@shoulder.matrix).translation.copy()
    matrix=restworld[side+'Shoulder'].copy();matrix.translation=pos
    shoulder.matrix=rig.matrix_world.inverted()@matrix;bpy.context.view_layer.update()
    upper=rig.pose.bones[side+'Arm'];fore=rig.pose.bones[side+'ForeArm'];hand=rig.pose.bones[side+'Hand']
    h=(rig.matrix_world@upper.matrix).translation.copy()
    k0=restworld[side+'ForeArm'].translation;a0=restworld[side+'Hand'].translation
    l1=(k0-restworld[side+'Arm'].translation).length;l2=(a0-k0).length
    forward=sign*amplitude*math.sin(phase)
    dx=profile.get('arm_outward_m',.07)
    drop=math.sqrt(radius*radius-dx*dx-forward*forward)
    target=h+Vector((sign*dx,forward,-drop))
    direction=(target-h).normalized();d=(target-h).length
    assert abs(l1-l2)+1e-5<d<l1+l2-1e-5,(kind,frame,side,'arm reach',d,l1,l2)
    along=(l1*l1-l2*l2+d*d)/(2*d)
    pole=Vector((sign*.3,-1,0));pole=(pole-direction*pole.dot(direction)).normalized()
    elbow=h+direction*along+pole*math.sqrt(max(0,l1*l1-along*along))
    for bone,start,end,reststart,restend in [(upper,h,elbow,restworld[side+'Arm'].translation,k0),(fore,elbow,target,k0,a0)]:
     delta=(restend-reststart).normalized().rotation_difference((end-start).normalized())
     pose=(delta@restworld[bone.name].to_quaternion()).to_matrix().to_4x4()@Matrix.Diagonal(Vector((.01,.01,.01,1)))
     pose.translation=start;bone.matrix=rig.matrix_world.inverted()@pose;bpy.context.view_layer.update()
    delta=(a0-restworld[side+'Arm'].translation).normalized().rotation_difference(direction)
    pose=(delta@restworld[side+'Hand'].to_quaternion()).to_matrix().to_4x4()@Matrix.Diagonal(Vector((.01,.01,.01,1)))
    pose.translation=target;hand.matrix=rig.matrix_world.inverted()@pose;bpy.context.view_layer.update()
    errors[side+'Hand']=((rig.matrix_world@hand.matrix).translation-target).length
  samples.append({'frame':frame,'contact':contact,'targets':{s:list(t) for s,t in targets.items()},'ankle_error_m':errors,'hips_lowering_m':lower,'source_ground_shift_m':source_ground_shift,'poses':{p.name:(list(p.location),list(p.rotation_quaternion),list(p.scale)) for p in rig.pose.bones}})
 # Match local T/Q/S endpoint derivatives for every exported channel. The portable
 # importer samples30fps; neighbors2 andframes-2 are +/-one such interval at bake60fps.
 if kind in ['idle','walk'] and not(kind=='walk' and reference is not None and profile.get('preserve_reference_seam',False)):
  for name in samples[0]['poses']:
   loc0,rot0,scale0=samples[0]['poses'][name];q0=Quaternion(rot0)
   loc1,rot1,_=samples[2]['poses'][name];loc31,rot31,_=samples[frames-2]['poses'][name]
   tangent=((q0.inverted()@Quaternion(rot1)).to_exponential_map()-(q0.inverted()@Quaternion(rot31)).to_exponential_map())/2
   for key in [1,2,frames-2,frames-1]:
    sign=key/2 if key<=2 else -(frames-key)/2
    loc=Vector(loc0)+sign*(Vector(loc1)-Vector(loc31))/2
    rot=q0@Quaternion(sign*tangent)
    samples[key]['poses'][name]=(list(loc),list(rot),scale0)
  samples[-1]['poses']=samples[0]['poses']
 # Source idle has a measured2.2mm seam; duplicate initial pose only at its true terminal time.
 if kind=='idle':samples[-1]['poses']=samples[0]['poses']
 action=bpy.data.actions.new(kind+'-contact');rig.animation_data.action=action
 for sample in samples:
  for p in rig.pose.bones:
   loc,rot,scale=sample['poses'][p.name];p.rotation_mode='QUATERNION';p.location=loc;p.rotation_quaternion=rot;p.scale=scale
   for channel in ['location','rotation_quaternion','scale']:p.keyframe_insert(data_path=channel,frame=sample['frame'],group=p.name)
 for curve in action.fcurves:
  for point in curve.keyframe_points:point.interpolation='LINEAR'
 newactions[kind]=action
 reports[kind]={'frames':frames,'max_ankle_error_m':max((max(x['ankle_error_m'].values()) for x in samples if x['ankle_error_m']),default=None),'samples':[{k:v for k,v in s.items() if k!='poses'} for s in samples]}
# Only corrected idle/walk in export; no source NLA strips or actions linked to export rig.
for track in list(rig.animation_data.nla_tracks):rig.animation_data.nla_tracks.remove(track)
rig.animation_data.action=None
for kind,action in newactions.items():
 action.name=kind
 track=rig.animation_data.nla_tracks.new();track.name=kind;track.strips.new(kind,0,action);track.mute=True
assert sig=={b.name:(b.parent.name if b.parent else None,tuple(v for row in b.matrix_local for v in row)) for b in rig.data.bones}
bpy.context.preferences.filepaths.save_version=0
bpy.ops.object.select_all(action='DESELECT');rig.select_set(True);mesh.select_set(True);bpy.context.view_layer.objects.active=mesh
output=DEST/'footplant-candidate.glb'
bpy.ops.export_scene.gltf(filepath=str(output),export_format='GLB',use_selection=True,export_animation_mode='NLA_TRACKS',export_animations=True,export_force_sampling=False,export_skins=True)
rig.animation_data.action=newactions['walk'];scene.frame_set(0);bpy.ops.wm.save_as_mainfile(filepath=str(DEST/'footplant-candidate.blend'),compress=True)
raw=output.read_bytes();size=struct.unpack_from('<I',raw,12)[0];g=json.loads(raw[20:20+size])
assert len(g['skins'][0]['joints'])==24
report={'source_sha256':hashlib.sha256(SOURCE.read_bytes()).hexdigest(),'output_sha256':hashlib.sha256(raw).hexdigest(),'bones':24,'rest_signature_unchanged':True,'shoe_repair_threshold_m':.20,'shoe_vertices':{s:len(v) for s,v in shoeids.items()},'shoe_assignment':'one Foot joint; target-specific rest-height classifier, owner review pending','controller_speed_mps':speed,'walk_period_seconds':length,'bake_fps':fps,'stance_phase':{'Left':[.25,.75],'Right':[.75,1.25]},'dust_event_phases':[.25,.75],'swing_lift_m':swinglift,'contact_accepted':False,'export_animations':[a['name'] for a in g['animations']],'clips':reports,'cost_usd':0}
if profile:
 report['profile']=profile
 if reference is not None:
  report['source_commit']=reference['source_commit'];report['source_animation']=profile['source_curves']
  report['anatomical_axis_correction_degrees']={n:math.degrees(q.angle) for n,q in calibration.items() if q.angle>.00001}
  if profile.get('authored_legs',False):
   report['stance_phase']=None;report['dust_event_phases']=[0,.5];report['planar_stance_lock_verified']=False
(DEST/'correction.json').write_text(json.dumps(report,indent=2)+'\n')
print('CONTACT_CANDIDATE',json.dumps({k:v for k,v in report.items() if k!='clips'}))
