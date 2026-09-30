"""Throwaway analytic two-joint footplant candidate; no imported display-tail assumptions.
Run pinned Blender4.3.2 --background --factory-startup --python correct.py.
"""
import bpy,json,hashlib,math,struct
from pathlib import Path
from mathutils import Vector,Matrix,Quaternion
HERE=Path(__file__).resolve().parent
SOURCE=HERE.parent/'rigid-head.glb'
assert SOURCE.exists(),'root rigid-head candidate must exist first'
bpy.ops.wm.read_factory_settings(use_empty=True)
scene=bpy.context.scene;scene.render.fps=60
bpy.ops.import_scene.gltf(filepath=str(SOURCE))
rig=next(o for o in scene.objects if o.type=='ARMATURE')
mesh=next(o for o in scene.objects if o.type=='MESH' and o.find_armature()==rig)
for track in rig.animation_data.nla_tracks:track.mute=True
rig.data.pose_position='REST';bpy.context.view_layer.update()
rests={b.name:b.matrix_local.copy() for b in rig.data.bones}
sig={b.name:(b.parent.name if b.parent else None,tuple(v for row in b.matrix_local for v in row)) for b in rig.data.bones}
restverts=[mesh.matrix_world@v.co for v in mesh.data.vertices]
shoeids={s:[i for i,v in enumerate(restverts) if v.z<=.20 and (v.x>0 if s=='Left' else v.x<=0)] for s in ['Left','Right']}
# Deliberately narrow, target-specific shoe repair; preserve positions, faces, atlas.
for side,ids in shoeids.items():
 for group in mesh.vertex_groups:group.remove(ids)
 mesh.vertex_groups[side+'Foot'].add(ids,1,'REPLACE')
mesh.data.update();mesh.update_tag(refresh={'OBJECT','DATA'})
restworld={n:rig.matrix_world@m for n,m in rests.items()}
soleoffset={s:restworld[s+'Foot'].translation.z-min(restverts[i].z for i in ids) for s,ids in shoeids.items()}
rig.data.pose_position='POSE'
length=32/30;speed=.52;stance=.5;swinglift=.08
sources={kind:next(t.strips[0].action for t in rig.animation_data.nla_tracks if t.name==kind) for kind in ['idle','walk']}
reports={};newactions={}
for kind,source in sources.items():
 rig.animation_data.action=source
 frames=64 if kind=='walk' else 242
 samples=[]
 boundary={}
 if kind=='walk':
  for key in [0,2,62]:
   sf=2+key*62/64
   scene.frame_set(int(sf),subframe=sf-int(sf));bpy.context.view_layer.update()
   boundary[key]={p.name:(p.location.copy(),p.rotation_quaternion.copy(),p.scale.copy()) for p in rig.pose.bones}
 # Pose sampling before assigning a new action; explicitly evaluate source time, preserving source seconds.
 for frame in range(frames+1):
  # Provider omitted time0 rotation keys, yielding a one-frame leading hold.
  sourceframe=2+frame*62/64 if kind=='walk' else frame
  scene.frame_set(int(sourceframe),subframe=sourceframe-int(sourceframe))
  bpy.context.view_layer.update()
  if kind=='walk' and frame in [1,2,62,63]:
   # Symmetric local tangents around the repeated start pose; solve legs again afterward.
   for p in rig.pose.bones:
    if any(p.name==side+part for side in ['Left','Right'] for part in ['UpLeg','Leg','Foot','ToeBase']):continue
    loc0,q0,scale0=boundary[0][p.name]
    loc1,q1,_=boundary[2][p.name];loc31,q31,_=boundary[62][p.name]
    tangent=((q0.inverted()@q1).to_exponential_map()-(q0.inverted()@q31).to_exponential_map())/2
    sign=frame/2 if frame<=2 else -(64-frame)/2
    p.location=loc0+sign*(loc1-loc31)/2
    p.rotation_quaternion=q0@Quaternion(sign*tangent)
    p.scale=scale0
   bpy.context.view_layer.update()
  original={p.name:rig.matrix_world@p.matrix.copy() for p in rig.pose.bones}
  targets={};contact={}
  for side,phaseoffset in [('Left',.25),('Right',.75)]:
   phase=((frame/64-phaseoffset)%1) if kind=='walk' else 0
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
  samples.append({'frame':frame,'contact':contact,'targets':{s:list(t) for s,t in targets.items()},'ankle_error_m':errors,'hips_lowering_m':lower,'poses':{p.name:(list(p.location),list(p.rotation_quaternion),list(p.scale)) for p in rig.pose.bones}})
 # Match local T/Q/S endpoint derivatives for every exported channel. The portable
 # importer samples30fps; neighbors2 andframes-2 are +/-one such interval at bake60fps.
 if kind in ['idle','walk']:
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
 reports[kind]={'frames':frames,'max_ankle_error_m':max(max(x['ankle_error_m'].values()) for x in samples),'samples':[{k:v for k,v in s.items() if k!='poses'} for s in samples]}
# Only corrected idle/walk in export; no source NLA strips or actions linked to export rig.
for track in list(rig.animation_data.nla_tracks):rig.animation_data.nla_tracks.remove(track)
rig.animation_data.action=None
for kind,action in newactions.items():
 action.name=kind
 track=rig.animation_data.nla_tracks.new();track.name=kind;track.strips.new(kind,0,action);track.mute=True
assert sig=={b.name:(b.parent.name if b.parent else None,tuple(v for row in b.matrix_local for v in row)) for b in rig.data.bones}
bpy.context.preferences.filepaths.save_version=0
bpy.ops.object.select_all(action='DESELECT');rig.select_set(True);mesh.select_set(True);bpy.context.view_layer.objects.active=mesh
output=HERE/'footplant-candidate.glb'
bpy.ops.export_scene.gltf(filepath=str(output),export_format='GLB',use_selection=True,export_animation_mode='NLA_TRACKS',export_animations=True,export_force_sampling=False,export_skins=True)
rig.animation_data.action=newactions['walk'];scene.frame_set(0);bpy.ops.wm.save_as_mainfile(filepath=str(HERE/'footplant-candidate.blend'),compress=True)
raw=output.read_bytes();size=struct.unpack_from('<I',raw,12)[0];g=json.loads(raw[20:20+size])
assert len(g['skins'][0]['joints'])==24
report={'source_sha256':hashlib.sha256(SOURCE.read_bytes()).hexdigest(),'output_sha256':hashlib.sha256(raw).hexdigest(),'bones':24,'rest_signature_unchanged':True,'shoe_repair_threshold_m':.20,'shoe_vertices':{s:len(v) for s,v in shoeids.items()},'shoe_assignment':'one Foot joint; target-specific rest-height classifier, owner review pending','controller_speed_mps':speed,'walk_period_seconds':length,'bake_fps':60,'stance_phase':{'Left':[.25,.75],'Right':[.75,1.25]},'dust_event_phases':[.25,.75],'swing_lift_m':swinglift,'contact_accepted':False,'export_animations':[a['name'] for a in g['animations']],'clips':reports,'cost_usd':0}
(HERE/'correction.json').write_text(json.dumps(report,indent=2)+'\n')
print('CONTACT_CANDIDATE',json.dumps({k:v for k,v in report.items() if k!='clips'}))
