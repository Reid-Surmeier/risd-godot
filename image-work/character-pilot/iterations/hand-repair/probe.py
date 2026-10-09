from pathlib import Path
import bpy,json
from mathutils import Vector
HERE=Path(__file__).resolve().parent
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=str(HERE.parent/'driven-character/short-arm/canonical-rest.glb'))
rig=next(o for o in bpy.context.scene.objects if o.type=='ARMATURE');mesh=next(o for o in bpy.context.scene.objects if o.type=='MESH' and o.find_armature()==rig)
rig.data.pose_position='REST';bpy.context.view_layer.update()
groups={g.index:g.name for g in mesh.vertex_groups};out={}
for side in ['Left','Right']:
 bone=rig.data.bones[side+'Hand'];matrix=rig.matrix_world@bone.matrix_local
 verts=[]
 for v in mesh.data.vertices:
  weight=sum(g.weight for g in v.groups if groups[g.group]==side+'Hand')
  if weight>.5:verts.append(matrix.inverted()@(mesh.matrix_world@v.co))
 out[side]={'bone_head_world':list(matrix.translation),'bone_tail_world':list(rig.matrix_world@bone.tail_local),'axis_world':list(matrix.to_3x3()@Vector((0,1,0))),'verts':len(verts),'local_bounds':[list(Vector(min(v[i] for v in verts) for i in range(3))),list(Vector(max(v[i] for v in verts) for i in range(3)))],'local_positions':[list(v) for v in verts]}
(HERE/'probe.json').write_text(json.dumps(out,indent=2)+'\n');print('HANDS_PROBED',{s:{k:v for k,v in x.items() if k!='local_positions'} for s,x in out.items()})
