"""THROWAWAY native Blender projection; original GLB arrays retained byte-for-byte.
Run: blender --background --factory-startup --threads 1 --python projection.py
"""
import bpy, hashlib, json, struct, copy, sys
from pathlib import Path
from mathutils import Vector

HERE = Path(__file__).resolve().parent
PILOT = HERE.parents[1]
INPUTS = HERE
RESOLUTION = 1024 if '--resolution1024' in sys.argv else 512
if RESOLUTION == 1024:
    HERE = HERE/'atlas1024'
    HERE.mkdir(exist_ok=True)
SOURCE = PILOT / 'target-baked-normalized-idle.glb'
raw = SOURCE.read_bytes()
json_length = struct.unpack_from('<I', raw, 12)[0]
source_json = json.loads(raw[20:20+json_length])
bin_start = 20 + json_length
bin_length = struct.unpack_from('<I', raw, bin_start)[0]
source_bin = raw[bin_start+8:bin_start+8+bin_length]

def geometry():
    return {
        'vertices': [list(v.co) for v in mesh.data.vertices],
        'polygons': [list(p.vertices) for p in mesh.data.polygons],
        'uv': [list(p.uv) for p in mesh.data.uv_layers['UVMap'].data],
        'groups': [[(g.group, g.weight) for g in v.groups] for v in mesh.data.vertices],
        'bones': [(b.name, b.parent.name if b.parent else None,
                   [list(row) for row in b.matrix_local]) for b in rig.data.bones],
        'actions': [(a.name, [(f.data_path, f.array_index,
                              [list(p.co) for p in f.keyframe_points])
                             for f in a.fcurves]) for a in bpy.data.actions]
    }

def material_for_image(image, uv_name='UVMap'):
    mat = bpy.data.materials.new(image.name + ' unlit')
    mat.use_nodes = True
    ns = mat.node_tree.nodes; ns.clear()
    uv = ns.new('ShaderNodeUVMap'); uv.uv_map = uv_name
    tex = ns.new('ShaderNodeTexImage'); tex.image = image
    emit = ns.new('ShaderNodeEmission')
    out = ns.new('ShaderNodeOutputMaterial')
    links = mat.node_tree.links
    links.new(uv.outputs['UV'], tex.inputs['Vector'])
    links.new(tex.outputs['Color'], emit.inputs['Color'])
    links.new(emit.outputs[0], out.inputs['Surface'])
    return mat

def render(name, angle=0):
    from math import sin, cos
    camera.location = Vector((4*sin(angle), -4*cos(angle), 1.42))
    camera.rotation_euler = (Vector((0,0,1.42))-camera.location).to_track_quat('-Z','Y').to_euler()
    scene.render.filepath = str(HERE/name)
    bpy.ops.render.render(write_still=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.context.preferences.filepaths.save_version = 0
bpy.ops.import_scene.gltf(filepath=str(SOURCE))
mesh = next(o for o in bpy.context.scene.objects if o.type == 'MESH')
rig = next(o for o in bpy.context.scene.objects if o.type == 'ARMATURE')
rig.data.pose_position = 'REST'
for track in rig.animation_data.nla_tracks: track.mute = True
original_state = geometry()
original_image = next(n.image for n in mesh.data.materials[0].node_tree.nodes
                      if n.type == 'TEX_IMAGE')
assert list(original_image.size) == [512,512]
if RESOLUTION == 1024:
    original_image.scale(1024,1024)
base = list(original_image.pixels)
original_image.filepath_raw = str(HERE/f'before-atlas{RESOLUTION}.png')
original_image.file_format='PNG'; original_image.save()
original_image=bpy.data.images.load(str(HERE/f'before-atlas{RESOLUTION}.png'),check_existing=False)
base=list(original_image.pixels)
original_image.alpha_mode='STRAIGHT'
before_mat = material_for_image(original_image)
mesh.data.materials[0]=before_mat
scene = bpy.context.scene
scene.render.engine='CYCLES'; scene.cycles.device='CPU'; scene.cycles.samples=8
scene.cycles.use_denoising=False
scene.render.resolution_x=768;scene.render.resolution_y=768
scene.render.resolution_percentage=100;scene.render.image_settings.file_format='PNG'
scene.view_settings.view_transform='Standard'
scene.world=bpy.data.worlds.new('white');scene.world.use_nodes=True
scene.world.node_tree.nodes['Background'].inputs[0].default_value=(1,1,1,1)
bpy.ops.object.camera_add(location=(0,-4,1.42))
camera=bpy.context.object;camera.data.type='ORTHO';camera.data.ortho_scale=1.25
scene.camera=camera
render('before-face.png')
render('before-profile.png',1.57079632679)
render('before-back.png',3.14159265359)

# Calibration: the source's hat brim y=470 -> mesh z=1.40,
# source chin y=900 -> mesh z=.86, source x=450..1158 -> x=-.46..+.46.
mesh.data.uv_layers.new(name='THROWAWAY_front_projection')
mesh.data.color_attributes.new(name='THROWAWAY_front_only',type='FLOAT_COLOR',domain='CORNER')
projection_uv=mesh.data.uv_layers['THROWAWAY_front_projection']
front=mesh.data.color_attributes['THROWAWAY_front_only']
eligible=0
for poly in mesh.data.polygons:
    # Negative-Y faces only, no body or rear. No geometry is moved.
    normal=(mesh.matrix_world.to_3x3()@poly.normal).normalized()
    center=mesh.matrix_world@poly.center
    keep=float(normal.y < -.50 and center.y < -.06 and center.z > .82)
    eligible+=int(keep)
    for loop in poly.loop_indices:
        p=mesh.matrix_world@mesh.data.vertices[mesh.data.loops[loop].vertex_index].co
        source_x=450+(p.x+.46)/.92*708
        source_y=470+(1.40-p.z)/.54*430
        projection_uv.data[loop].uv=(source_x/1600,1-source_y/1600)
        n=(mesh.matrix_world.to_3x3()@mesh.data.vertices[mesh.data.loops[loop].vertex_index].normal).normalized()
        fade=max(0,min(1,(-n.y-.50)/.35))
        fade=fade*fade*(3-2*fade)
        front.data[loop].color=(keep*fade,keep*fade,keep*fade,1)
mesh.data.uv_layers['UVMap'].active_render=True
mesh.data.uv_layers.active=mesh.data.uv_layers['UVMap']
source_image=bpy.data.images.load(str(PILOT/'front.png'))
source_image.alpha_mode='STRAIGHT'
project_mat=material_for_image(source_image,projection_uv.name)
nodes=project_mat.node_tree.nodes;links=project_mat.node_tree.links
tex=next(n for n in nodes if n.type=='TEX_IMAGE')
tex.extension='CLIP'
emit=next(n for n in nodes if n.type=='EMISSION')
attr=nodes.new('ShaderNodeVertexColor');attr.layer_name=front.name
multiply=nodes.new('ShaderNodeMath');multiply.operation='MULTIPLY'
mask_image=bpy.data.images.load(str(INPUTS/'source-mask.png'))
mask_image.colorspace_settings.name='Non-Color'
mask_tex=nodes.new('ShaderNodeTexImage');mask_tex.image=mask_image;mask_tex.extension='CLIP'
uv_node=next(n for n in nodes if n.type=='UVMAP')
links.new(uv_node.outputs['UV'],mask_tex.inputs['Vector'])
links.new(mask_tex.outputs['Color'],multiply.inputs[0]);links.new(attr.outputs['Color'],multiply.inputs[1])
mesh.data.materials[0]=project_mat
scene.render.bake.margin=2;scene.cycles.samples=1
bpy.ops.object.select_all(action='DESELECT');mesh.select_set(True);bpy.context.view_layer.objects.active=mesh

def bake(name, coverage=False):
    image=bpy.data.images.new(name,width=RESOLUTION,height=RESOLUTION,alpha=True)
    image.colorspace_settings.name='Non-Color' if coverage else 'sRGB'
    target=nodes.new('ShaderNodeTexImage');target.image=image
    for n in nodes:n.select=False
    target.select=True;nodes.active=target
    links.new(multiply.outputs[0] if coverage else tex.outputs['Color'],emit.inputs['Color'])
    bpy.ops.object.bake(type='EMIT')
    pixels=list(image.pixels)
    nodes.remove(target)
    return image,pixels

projected,colors=bake('projected face pixels')
coverage,mask=bake('front coverage',True)
coverage.filepath_raw=str(HERE/f'uv-coverage{RESOLUTION}.png');coverage.file_format='PNG';coverage.save()
result=bpy.data.images.new(f'Muse face projected{RESOLUTION}',width=RESOLUTION,height=RESOLUTION,alpha=True)
result.colorspace_settings.name='sRGB'
values=base.copy();changed=0
for i in range(RESOLUTION*RESOLUTION):
    weight=max(0,min(1,mask[4*i]))
    if weight>.001:
        changed+=1
        for channel in range(3):
            values[4*i+channel]=base[4*i+channel]*(1-weight)+colors[4*i+channel]*weight
    else:
        assert values[4*i:4*i+4] == base[4*i:4*i+4]
result.pixels=values
result.filepath_raw=str(HERE/f'projected-albedo{RESOLUTION}.png');result.file_format='PNG';result.save()
result=bpy.data.images.load(str(HERE/f'projected-albedo{RESOLUTION}.png'),check_existing=False)
assert eligible > 0 and changed > 100, 'Face projection has no meaningful coverage'
mesh.data.uv_layers.remove(mesh.data.uv_layers['THROWAWAY_front_projection'])
mesh.data.color_attributes.remove(mesh.data.color_attributes['THROWAWAY_front_only'])
assert geometry()==original_state, 'Geometry, original UVs, weights, bones or actions changed'
mesh.data.materials[0]=material_for_image(result)
scene.cycles.samples=8
render('after-face.png')
render('after-profile.png',1.57079632679)
render('after-back.png',3.14159265359)
camera.data.ortho_scale=2.25
render('after-quarter-gameview.png',.78539816339)
mesh.data.materials[0]=before_mat
render('before-quarter-gameview.png',.78539816339)
mesh.data.materials[0]=material_for_image(result)

# Replace only the embedded PNG. Never export/reorder mesh or animation arrays.
data=copy.deepcopy(source_json)
png=(HERE/f'projected-albedo{RESOLUTION}.png').read_bytes()
offset=len(source_bin)
binary=source_bin+png
binary+=b'\x00'*((-len(binary))%4)
data['bufferViews'].append({'buffer':0,'byteOffset':offset,'byteLength':len(png)})
data['images'][0]['bufferView']=len(data['bufferViews'])-1
data['buffers'][0]['byteLength']=len(binary)
j=json.dumps(data,separators=(',',':')).encode();j+=b' '*((-len(j))%4)
out=struct.pack('<4sII',b'glTF',2,12+8+len(j)+8+len(binary))+struct.pack('<I4s',len(j),b'JSON')+j+struct.pack('<I4s',len(binary),b'BIN\x00')+binary
(HERE/'face-projection.glb').write_bytes(out)
assert binary[:len(source_bin)]==source_bin
for key in ['meshes','accessors','skins','nodes','animations','materials','textures']:
    assert data[key]==source_json[key],key+' changed'
assert SOURCE.read_bytes()==raw
report={'success':True,'visual_verdict':'pending inspection','source_sha256':hashlib.sha256(raw).hexdigest(),
 'front_sha256':hashlib.sha256((PILOT/'front.png').read_bytes()).hexdigest(),
 'output_sha256':hashlib.sha256(out).hexdigest(),'source_bin_prefix_identical':True,
 'geometry_uv_skin_actions_identical':True,'eligible_front_faces':eligible,'atlas_pixels_changed':changed,
 'atlas_resolution':RESOLUTION,'atlas_total_pixels':RESOLUTION*RESOLUTION,'blender':bpy.app.version_string,'paid_cost_usd':0,
 'camera':{'orthographic_scale':1.25,'target':[0,0,1.42],'front_location':[0,-4,1.42]},
 'calibration':{'source_x':[450,1158],'mesh_x':[-.46,.46],'source_y':[470,900],'mesh_z':[1.40,.86]},
 'mask_ellipses':[[530,500,725,705],[875,500,1080,705],[746,659,858,751],[665,757,947,827]],
 'source_mask_sha256':hashlib.sha256((INPUTS/'source-mask.png').read_bytes()).hexdigest(),
 'mask_feather_source_pixels':15,'bake_padding_pixels':2,
 'whole_body_excluded':'Muse arms slope while mesh rest pose is T; projection tested only face features',
 'remaining_limit':'Projection is planar; nose/cheeks and grazing profile require inspection. Occlusion is front face/region mask, not depth reconstruction.'}
(HERE/'report.json').write_text(json.dumps(report,indent=2)+'\n')
bpy.ops.wm.save_as_mainfile(filepath=str(HERE/'face-projection-review.blend'),compress=True)
print('FACE_PROJECTION_COMPLETE',changed)
