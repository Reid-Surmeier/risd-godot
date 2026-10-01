"""THROWAWAY issue230: inspect/re-render the reimported baked fixture."""
import bpy, json, struct, hashlib
from mathutils import Vector
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[1]
raw=(HERE/'fixture.glb').read_bytes()
length=struct.unpack_from('<I',raw,12)[0]
data=json.loads(raw[20:20+length])
attrs=[p['attributes'] for m in data['meshes'] for p in m['primitives']]
assert len(data['skins'])==1 and len(data['skins'][0]['joints'])==41
assert len(data['animations'])==76
assert all('JOINTS_0' in a and 'WEIGHTS_0' in a and 'TEXCOORD_0' in a for a in attrs)
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=str(HERE/'fixture.glb'))
rig=next(o for o in bpy.data.objects if o.type=='ARMATURE')
skin=bpy.data.objects['Original visitor skin']
assert len(rig.data.bones)==41 and len(bpy.data.actions)==76
assert skin.find_armature()==rig
textured=[m for m in data['materials'] if 'baseColorTexture' in m.get('pbrMetallicRoughness',{})]
assert len(textured)==1 and 'occlusionTexture' in textured[0]
textures=[(m.name,n.image.name,tuple(n.image.size)) for m in skin.data.materials for n in m.node_tree.nodes if n.type=='TEX_IMAGE']
assert len(textures)==2 and all(t[2]==(512,512) for t in textures)
rig.animation_data_create()
for track in rig.animation_data.nla_tracks: track.mute=True
bpy.ops.mesh.primitive_plane_add(size=200)
floor=bpy.context.object; floor.location.z=-0.02
mat=bpy.data.materials.new('preview floor'); mat.diffuse_color=(.44,.38,.31,1); floor.data.materials.append(mat)
bpy.ops.object.camera_add(location=(2.5,-5.5,3.2))
camera=bpy.context.object
camera.rotation_euler=(Vector((0,0,1.02))-camera.location).to_track_quat('-Z','Y').to_euler()
camera.data.type='ORTHO'; camera.data.ortho_scale=2.55
scene=bpy.context.scene; scene.camera=camera
bpy.ops.object.light_add(type='AREA',location=(-2,-3,5))
bpy.context.object.data.energy=350; bpy.context.object.data.size=4
scene.world=bpy.data.worlds.new('preview ambient'); scene.world.color=(.18,.18,.18)
scene.render.engine='CYCLES'; scene.cycles.device='CPU'
scene.cycles.samples=8; scene.cycles.use_denoising=False
scene.render.resolution_x=512; scene.render.resolution_y=512; scene.render.resolution_percentage=100
scene.render.image_settings.file_format='PNG'
rig.data.pose_position='REST'
scene.frame_set(1); scene.render.filepath=str(HERE/'rest.png'); bpy.ops.render.render(write_still=True)
rig.data.pose_position='POSE'
rig.animation_data.action=bpy.data.actions['Idle_Rig']
scene.frame_set(1); scene.render.filepath=str(HERE/'idle.png'); bpy.ops.render.render(write_still=True)
rig.animation_data.action=bpy.data.actions['Walking_A_Rig']
scene.frame_set(8); scene.render.filepath=str(HERE/'walk.png'); bpy.ops.render.render(write_still=True)
frames=HERE/'frames'; frames.mkdir(exist_ok=True)
for previous in frames.glob('walk-*.png'): previous.unlink()
scene.render.resolution_x=384; scene.render.resolution_y=384
matrices=[]
for frame in range(1,25,3):
 scene.frame_set(frame)
 matrices.append([round(v,6) for row in rig.pose.bones['foot.l'].matrix for v in row])
 scene.render.filepath=str(frames/f'walk-{frame:03d}.png'); bpy.ops.render.render(write_still=True)
assert len({tuple(m) for m in matrices})>1, 'walking bone stayed static'
evidence={'blender':bpy.app.version_string,'device':'CPU','mcp_exercised':False,
 'fixture':'authored existing visitor, not supplied horned character','generated_provider':None,'cost_usd':0,
 'source_commit':'0f690ea63245c633b04cb2dbb35ac28ff0bb710e',
 'source_sha256':hashlib.sha256((ROOT/'modules/shell/prototype/gallery_walk4/identity/Rogue.source.glb').read_bytes()).hexdigest(),
 'output_sha256':hashlib.sha256(raw).hexdigest(),'output_bytes':len(raw),
 'skins':len(data['skins']),'joints':len(data['skins'][0]['joints']),'animations':len(data['animations']),
 'clip_names':[a['name'] for a in data['animations']],'primitives':len(attrs),
 'all_primitives_uv_skin':True,'textured_materials':len(textured),'images':len(data['images']),
 'embedded_images':all('bufferView' in im for im in data['images']),
 'reimport_bones':len(rig.data.bones),'reimport_actions':len(bpy.data.actions),'reimport_texture_sizes':[list(t[2]) for t in textures],
 'walk_action':'Walking_A_Rig','render_frames':list(range(1,25,3)),'animated_foot_matrix_changed':True,
 'godot_tested':False,'browser_render_tested':False,'visual_verdict':'pending owner review'}
(HERE/'evidence.json').write_text(json.dumps(evidence,indent=2)+'\n')
print('FIXTURE_EVIDENCE',json.dumps({k:v for k,v in evidence.items() if k not in ['clip_names']}))
