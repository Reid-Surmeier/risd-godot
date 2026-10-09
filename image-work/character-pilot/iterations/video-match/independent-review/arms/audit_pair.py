"""Native Blender: --background --factory-startup --python audit_pair.py -- baseline.glb selected.glb mask.json output.json.
Compare original anatomical regions at normalized clip phase; never modify weights.
"""
import bpy,json,sys,hashlib
from pathlib import Path
from mathutils import Vector
from mathutils.kdtree import KDTree
import numpy as np
args=sys.argv[sys.argv.index('--')+1:];assert len(args)==4
baseline,selected,mask_path,output=map(Path,args)
assert all(p.is_file() for p in [baseline,selected,mask_path])
mask=json.loads(mask_path.read_text());report={'blender':bpy.app.version_string,'cost_usd':0,'samples_per_clip':129,'region_definition':'original Arm weight>0.75; target-specific reviewed mask','mask_sha256':hashlib.sha256(mask_path.read_bytes()).hexdigest(),'models':{}}
for stage,path in [('baseline',baseline),('selected',selected)]:
 bpy.ops.wm.read_factory_settings(use_empty=True);bpy.ops.import_scene.gltf(filepath=str(path));scene=bpy.context.scene;rig=next(o for o in scene.objects if o.type=='ARMATURE');mesh=next(o for o in scene.objects if o.type=='MESH' and o.find_armature()==rig)
 assert len(rig.data.bones)==24 and sum(len(p.vertices)-2 for p in mesh.data.polygons)==7719
 for t in rig.animation_data.nla_tracks:t.mute=True
 rig.data.pose_position='REST';bpy.context.view_layer.update();rest=np.array([list(mesh.matrix_world@v.co) for v in mesh.data.vertices]);tree=KDTree(len(rest))
 for i,v in enumerate(rest):tree.insert(Vector(v),i)
 tree.balance();regions={s:[] for s in ['Left','Right']};coordinate_errors=[];weight_errors=[]
 for x in mask['vertices']:
  expected=x['original_weights'] if stage=='baseline' else x['weights'];options=[]
  for co,i,d in tree.find_range(Vector(x['rest_world_m']),.00002):
   weights={mesh.vertex_groups[g.group].name:g.weight for g in mesh.data.vertices[i].groups};error=max(abs(weights.get(n,0)-expected.get(n,0)) for n in set(weights)|set(expected));options.append((error,d,i))
  assert options,'mask geometry absent';error,d,i=min(options);assert error<.0004
  coordinate_errors.append(d);weight_errors.append(error)
  for side in regions:
   if x['original_weights'].get(side+'Arm',0)>.75:regions[side].append(i)
 assert [len(regions[s]) for s in ['Left','Right']]==[282,457]
 model={'glb_sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'mask_coordinate_error_max_m':max(coordinate_errors),'mask_weight_error_max':max(weight_errors),'region_vertices':{s:len(v) for s,v in regions.items()},'clips':{}}
 for track in rig.animation_data.nla_tracks:
  action=track.strips[0].action;rig.animation_data.action=action;rig.data.pose_position='POSE';ratios={s:[] for s in regions};fits={s:[] for s in regions}
  for phase in np.linspace(0,1,129):
   f=phase*action.frame_range[1];scene.frame_set(int(f),subframe=float(f%1));bpy.context.view_layer.update();e=mesh.evaluated_get(bpy.context.evaluated_depsgraph_get());posed=np.array([list(e.matrix_world@v.co) for v in e.data.vertices])
   for side,ids in regions.items():
    a=rest[ids]-rest[ids].mean(axis=0);b=posed[ids]-posed[ids].mean(axis=0);ratio=np.linalg.svd(b,compute_uv=False)/np.linalg.svd(a,compute_uv=False);assert np.all(np.isfinite(ratio));ratios[side].append(ratio);u,z,vt=np.linalg.svd(a.T@b)
    if np.linalg.det(u@vt)<0:u[:,-1]*=-1
    fits[side].append(float(np.sqrt(np.mean(np.sum((a@(u@vt)-b)**2,axis=1)))))
  model['clips'][track.name]={'period_seconds':float(action.frame_range[1]/scene.render.fps),'extent_ratios':{s:{'min':np.min(v,axis=0).tolist(),'max':np.max(v,axis=0).tolist()} for s,v in ratios.items()},'rigid_fit_rms_max_m':{s:max(v) for s,v in fits.items()}}
 report['models'][stage]=model
assert set(report['models']['baseline']['clips'])==set(report['models']['selected']['clips'])=={'walk','idle'}
report['selected_extent_contraction_max_percent']=100*(1-min(min(x['min']) for c in report['models']['selected']['clips'].values() for x in c['extent_ratios'].values()));assert report['selected_extent_contraction_max_percent']<2,'selected arm still compresses beyond reviewed target'
output.write_text(json.dumps(report,indent=2));print('ARM_CHECK_PASS',report['selected_extent_contraction_max_percent'])
