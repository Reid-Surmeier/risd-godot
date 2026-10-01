"""Local prototype body/rest-rig correction; preserves appearance UVs and rigid head.
Run through the existing Blender MCP native-stage runner. No provider calls.
"""
from pathlib import Path
import bpy, json, hashlib, sys
from mathutils import Vector, Matrix

BASE=Path(__file__).resolve().parent
profile=Path(sys.argv[sys.argv.index('--profile')+1]).resolve() if '--profile' in sys.argv else None
assert profile is None or profile.is_relative_to(BASE)
config=json.loads(profile.read_text()) if profile else {}
HERE=BASE/profile.stem if profile else BASE
HERE.mkdir(exist_ok=True)
arm_scale=config.get('arm_scale',1)
assert .5<=arm_scale<=1
SOURCE=BASE.parent/'video-match/authored-walk-v5/footplant-candidate.glb'
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.context.preferences.filepaths.save_version=0
bpy.ops.import_scene.gltf(filepath=str(SOURCE))
rig=next(o for o in bpy.context.scene.objects if o.type=='ARMATURE')
mesh=next(o for o in bpy.context.scene.objects if o.type=='MESH' and o.find_armature()==rig)
rig.animation_data_clear()
rig.data.pose_position='REST'
bpy.context.view_layer.update()
old={b.name:rig.matrix_world@b.matrix_local for b in rig.data.bones}
points={n:m.translation.copy() for n,m in old.items()}
new={n:p.copy() for n,p in points.items()}
uv=[tuple(v.uv) for v in mesh.data.uv_layers.active.data]
scale=sum((points['Left'+b]-points['Left'+a]).length for a,b in [('UpLeg','Leg'),('Leg','Foot')])/850
segments={}
for side,sign in [('Left',1),('Right',-1)]:
    new[side+'UpLeg'].x=points['Hips'].x+sign*350*scale
    new[side+'Arm'].x=points['Hips'].x+sign*450*scale
    new[side+'Shoulder']+=new[side+'Arm']-points[side+'Arm']
    for a,b,length in [('UpLeg','Leg',450),('Leg','Foot',400),('Arm','ForeArm',626),('ForeArm','Hand',625)]:
        if a in ['Arm','ForeArm']:length*=arm_scale
        a,b=side+a,side+b
        direction=(points[b]-points[a]).normalized()
        new[b]=new[a]+direction*length*scale
        segments[a]=(direction,length*scale/(points[b]-points[a]).length)
    for a,b in [('Foot','ToeBase'),('Hand','Hand')]:
        if a!=b:new[side+b]+=new[side+a]-points[side+a]
groups={g.index:g.name for g in mesh.vertex_groups}
for vertex in mesh.data.vertices:
    point=mesh.matrix_world@vertex.co
    result=Vector()
    total=0
    for influence in vertex.groups:
        name=groups[influence.group]
        if name not in old:continue
        relative=point-points[name]
        if name in segments:
            axis,factor=segments[name]
            relative+=axis*relative.dot(axis)*(factor-1)
        if name in ['LeftFoot','RightFoot','LeftToeBase','RightToeBase']:relative*=.8
        result+=(new[name]+relative)*influence.weight
        total+=influence.weight
    assert abs(total-1)<.0001
    vertex.co=mesh.matrix_world.inverted()@result
bpy.context.view_layer.objects.active=rig
bpy.ops.object.mode_set(mode='EDIT')
for bone in rig.data.edit_bones:
    bone.use_connect=False
    start=rig.matrix_world.inverted()@new[bone.name]
    delta=start-bone.head
    bone.head=start
    bone.tail+=delta
bpy.ops.object.mode_set(mode='OBJECT')
assert uv==[tuple(v.uv) for v in mesh.data.uv_layers.active.data]
assert len(rig.data.bones)==24
def ratios(values):
    leg=sum((values['Left'+b]-values['Left'+a]).length for a,b in [('UpLeg','Leg'),('Leg','Foot')])
    arm=sum((values['Left'+b]-values['Left'+a]).length for a,b in [('Arm','ForeArm'),('ForeArm','Hand')])
    hip=(values['LeftUpLeg']-values['RightUpLeg']).length
    shoulder=(values['LeftArm']-values['RightArm']).length
    return {'arm_leg':arm/leg,'hip_shoulder':hip/shoulder,'leg':leg,'arm':arm}
after=ratios(new)
assert abs(after['arm_leg']-1251/850*arm_scale)<.00001
assert abs(after['hip_shoulder']-700/900)<.0001
# Two source-arm end lengths include different hand display joints; visible fit is separate.
bpy.ops.object.select_all(action='DESELECT')
rig.select_set(True);mesh.select_set(True)
bpy.context.view_layer.objects.active=mesh
out=HERE/'canonical-rest.glb'
bpy.ops.export_scene.gltf(filepath=str(out),export_format='GLB',use_selection=True,export_animations=False,export_skins=True)
bpy.ops.wm.save_as_mainfile(filepath=str(HERE/'canonical-rest.blend'),compress=True)
(HERE/'canonical.json').write_text(json.dumps({'source_sha256':hashlib.sha256(SOURCE.read_bytes()).hexdigest(),'output_sha256':hashlib.sha256(out.read_bytes()).hexdigest(),'bones':24,'uv_unchanged':True,'before':ratios(points),'after':after,'source_scale':scale,'shoe_scale':.8,'arm_visual_scale':arm_scale,'geometry_acceptance':'prototype; joint ratios are not a silhouette verdict','paid_calls':0},indent=2)+'\n')
print('CANONICAL_RIG',json.dumps(after))
