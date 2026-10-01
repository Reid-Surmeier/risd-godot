import bpy,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
SOURCE=HERE.parents[1]/'target-baked-normalized-idle.glb'
bpy.ops.import_scene.gltf(filepath=str(SOURCE))
rig=next(o for o in bpy.context.scene.objects if o.type=='ARMATURE')
report={'blender':bpy.app.version_string,'fps':bpy.context.scene.render.fps,'rig_world':str(rig.matrix_world),'actions':{a.name:list(a.frame_range) for a in bpy.data.actions},'bones':{}}
for name in ['LeftUpLeg','LeftLeg','LeftFoot','RightUpLeg','RightLeg','RightFoot']:
 b=rig.data.bones[name];p=rig.pose.bones[name]
 report['bones'][name]={'head':list(rig.matrix_world@b.head_local),'tail':list(rig.matrix_world@b.tail_local),'length_world':(rig.matrix_world@b.tail_local-rig.matrix_world@b.head_local).length,'parent':b.parent.name if b.parent else None}
c=rig.pose.bones['LeftLeg'].constraints.new('IK')
report['ik_properties']={name:getattr(c,name) if name not in ('target','pole_target') else str(getattr(c,name)) for name in ['chain_count','use_tail','use_stretch','use_rotation','use_location','pole_angle','iterations','influence','target','pole_target']}
report['bake_parameters']=str(bpy.ops.nla.bake.get_rna_type().properties.keys())
(HERE/'blender-api-evidence.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report))
