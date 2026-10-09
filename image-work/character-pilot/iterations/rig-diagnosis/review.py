"""Read-only native collar/head review: four walk poses and REST turnaround."""
import bpy,json,hashlib
from pathlib import Path
from mathutils import Vector
HERE=Path(__file__).resolve().parent
SOURCE=HERE.parent/'rigid-head.glb'
bpy.ops.wm.read_factory_settings(use_empty=True)
scene=bpy.context.scene;scene.render.fps=30
bpy.ops.import_scene.gltf(filepath=str(SOURCE))
rig=next(o for o in bpy.context.scene.objects if o.type=='ARMATURE')
skin=next(o for o in bpy.context.scene.objects if o.type=='MESH' and o.find_armature()==rig)
for t in rig.animation_data.nla_tracks:t.mute=True
rig.animation_data.action=next(t.strips[0].action for t in rig.animation_data.nla_tracks if t.name=='walk')
bpy.ops.object.camera_add()
camera=bpy.context.object;camera.data.type='ORTHO';camera.data.ortho_scale=2.15;scene.camera=camera
center=Vector((0,0,.95))
bpy.ops.object.light_add(type='AREA',location=(-2,-3,4))
bpy.context.object.data.energy=300;bpy.context.object.data.size=4
bpy.ops.object.light_add(type='AREA',location=(2,3,3))
bpy.context.object.data.energy=150;bpy.context.object.data.size=4
scene.world=bpy.data.worlds.new('neutral review');scene.world.use_nodes=True
scene.world.node_tree.nodes['Background'].inputs[0].default_value=(.8,.8,.8,1)
scene.render.engine='CYCLES';scene.cycles.device='CPU';scene.cycles.samples=16
scene.cycles.use_denoising=False
scene.render.resolution_x=512;scene.render.resolution_y=512;scene.render.resolution_percentage=100
scene.render.image_settings.file_format='PNG'
records=[]
def render(label,offset,frame=None):
 camera.location=center+Vector(offset)
 camera.rotation_euler=(center-camera.location).to_track_quat('-Z','Y').to_euler()
 bpy.context.view_layer.update()
 scene.render.filepath=str(HERE/('review-'+label+'.png'))
 bpy.ops.render.render(write_still=True)
 records.append({'image':Path(scene.render.filepath).name,'frame':frame,'pose':rig.data.pose_position,'camera_offset':offset})
rig.data.pose_position='POSE'
for frame in [0,8,16,24]:
 scene.frame_set(frame)
 render('walk-'+str(frame)+'-front',(0,-3,0),frame)
 render('walk-'+str(frame)+'-profile',(3,0,0),frame)
rig.data.pose_position='REST';scene.frame_set(0)
for label,offset in [('front',(0,-3,0)),('side',(3,0,0)),('back',(0,3,0))]:
 render('rest-'+label,offset)
report={'source':str(SOURCE),'source_sha256':hashlib.sha256(SOURCE.read_bytes()).hexdigest(),'blender':bpy.app.version_string,'fps':30,'native_render_only':True,'source_changed':False,'views':records,'cost_usd':0}
(HERE/'review-report.json').write_text(json.dumps(report,indent=2)+'\n')
print('REVIEW_RENDER_COMPLETE')
