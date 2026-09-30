"""Build an original low-poly visitor skin on KayKit's CC0 Rogue skeleton.

THROWAWAY fixture proof for issue230, copied from0f690ea.
Run pinned Blender4.3.2 -b -t1 --python-exit-code1 --python image-work/character-fixture/build.py
The imported Rogue geometry is deleted; only its armature and animation survive.
"""
import bpy
from math import cos, pi
from pathlib import Path

HERE = Path(__file__).resolve().parent
SOURCE = HERE.parents[1] / 'modules/shell/prototype/gallery_walk4/identity/Rogue.source.glb'
OUT = HERE / 'fixture.glb'
SOURCE_TEXTURE = HERE / 'shirt-source.png'
BAKED_TEXTURE = SOURCE_TEXTURE.parent / 'shirt-baked.png'
AO_TEXTURE = SOURCE_TEXTURE.parent / 'shirt-ao.png'

bpy.ops.wm.read_factory_settings(use_empty=True)
assert bpy.app.version >= (4, 3, 0), 'The host Blender 4.0 silently produces blank image bakes'
bpy.ops.import_scene.gltf(filepath=str(SOURCE))
rig = next(obj for obj in bpy.data.objects if obj.type == 'ARMATURE')
for obj in list(bpy.data.objects):
    if obj.type == 'MESH':
        bpy.data.objects.remove(obj, do_unlink=True)

def material(name, rgb):
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = (*rgb, 1)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (*rgb, 1)
    bsdf.inputs['Roughness'].default_value = 1
    return mat

skin = material('warm skin', (.83, .53, .36))
hair = material('dark brown hair', (.13, .075, .053))
cap = material('muted red cap', (.52, .11, .15))
cap_fold = material('cap fold', (.38, .072, .10))
shirt = material('cream shirt', (.88, .77, .56))
stripe = material('oxblood shirt stripe', (.33, .055, .075))
shorts = material('navy shorts', (.055, .065, .14))
shoes = material('brown shoes', (.21, .085, .045))
eyes = material('deep navy eyes', (.018, .028, .045))
white = material('eye whites', (.91, .89, .79))

parts = []

def ellipsoid(name, bone, center, scale, mat, segments=12, rings=8):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segments, ring_count=rings, location=center)
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(mat)
    group = obj.vertex_groups.new(name=bone)
    group.add(list(range(len(obj.data.vertices))), 1.0, 'REPLACE')
    mod = obj.modifiers.new('Rogue skeleton', 'ARMATURE')
    mod.object = rig
    obj.parent = rig
    parts.append(obj)
    return obj

# The original source sheet is a proportion and color reference, not a texture.
# All surfaces below are authored geometry and solid-color materials.
ellipsoid('head', 'head', (0, 0, 1.43), (.43, .38, .39), skin, 16, 10)
ellipsoid('hair', 'head', (0, .10, 1.64), (.42, .32, .25), hair, 16, 8)
ellipsoid('cap crown', 'head', (0, .02, 1.79), (.45, .39, .22), cap, 16, 8)
ellipsoid('cap band', 'head', (0, -.015, 1.69), (.46, .39, .07), cap_fold, 16, 6)
ellipsoid('cap soft tip', 'head', (.14, .025, 1.95), (.20, .17, .10), cap, 10, 6)
for side in (-1, 1):
    x = side * .20
    ellipsoid('eye white', 'head', (x, -.351, 1.45), (.11, .045, .16), white)
    ellipsoid('eye pupil', 'head', (x, -.388, 1.45), (.072, .025, .12), eyes)
    ellipsoid('eye glint', 'head', (x-.023, -.413, 1.50), (.020, .011, .025), white, 8, 6)
    ellipsoid('ear', 'head', (side*.422, .00, 1.38), (.065, .095, .105), skin, 10, 6)
ellipsoid('nose', 'head', (0, -.394, 1.34), (.055, .045, .055), skin, 8, 6)
ellipsoid('mouth', 'head', (0, -.38, 1.22), (.11, .012, .016), hair, 10, 6)
torso = ellipsoid('shirt body', 'spine', (0, 0, .88), (.35, .25, .39), shirt, 20, 20)
torso.data.materials.append(stripe)
for face in torso.data.polygons:
    if min(abs(face.center.z - z) for z in (-.15, 0, .15)) < .031:
        face.material_index = 1

def bake_shirt():
    """Bake the authored UV source, stripe materials and gentle AO into one albedo map."""
    assert torso.data.uv_layers.active is not None
    SOURCE_TEXTURE.parent.mkdir(parents=True, exist_ok=True)
    if not SOURCE_TEXTURE.exists():
        source = bpy.data.images.new('authored shirt source', width=256, height=256, alpha=True)
        pixels = []
        for y in range(256):
            v = (y + .5) / 256
            for x in range(256):
                u = (x + .5) / 256
                shade = .94 + .035 * cos(2 * pi * u) + .025 * (v - .5)
                pixels.extend((shade, shade * .98, shade * .95, 1.0))
        source.pixels.foreach_set(pixels)
        source.filepath_raw = str(SOURCE_TEXTURE)
        source.file_format = 'PNG'
        source.save()
    source = bpy.data.images.load(str(SOURCE_TEXTURE), check_existing=False)
    albedo = bpy.data.images.new('shirt albedo bake', width=512, height=512, alpha=True)
    ao = bpy.data.images.new('shirt AO bake', width=512, height=512, alpha=True)
    source_colors = ((.88, .77, .56), (.33, .055, .075))
    for index, rgb in enumerate(source_colors):
        mat = bpy.data.materials.new('shirt bake source %d' % index)
        mat.use_nodes = True
        nodes = mat.node_tree.nodes
        nodes.clear()
        output = nodes.new('ShaderNodeOutputMaterial')
        emit = nodes.new('ShaderNodeEmission')
        tex = nodes.new('ShaderNodeTexImage')
        tex.image = source
        color = nodes.new('ShaderNodeRGB')
        color.outputs[0].default_value = (*rgb, 1.0)
        multiply = nodes.new('ShaderNodeMixRGB')
        multiply.blend_type = 'MULTIPLY'
        multiply.inputs[0].default_value = 1.0
        target = nodes.new('ShaderNodeTexImage')
        target.image = albedo
        for node in nodes:
            node.select = False
        target.select = True
        nodes.active = target
        links = mat.node_tree.links
        links.new(tex.outputs['Color'], multiply.inputs[1])
        links.new(color.outputs[0], multiply.inputs[2])
        links.new(multiply.outputs[0], emit.inputs['Color'])
        links.new(emit.outputs[0], output.inputs['Surface'])
        torso.data.materials[index] = mat
    for obj in bpy.context.selected_objects:
        obj.select_set(False)
    torso.select_set(True)
    bpy.context.view_layer.objects.active = torso
    scene = bpy.context.scene
    scene.render.engine = 'CYCLES'
    scene.cycles.samples = 16
    scene.cycles.device = 'CPU'
    scene.render.bake.margin = 8
    bpy.ops.object.bake(type='EMIT')
    assert max(list(albedo.pixels)[0::4]) > .2, 'albedo bake is blank'
    for mat in torso.data.materials:
        mat.node_tree.nodes.active.image = ao
    bpy.ops.object.bake(type='AO')
    assert max(list(ao.pixels)[0::4]) > .2, 'AO bake is blank'
    color_pixels = list(albedo.pixels)
    ao_pixels = list(ao.pixels)
    for pixel in range(0, len(color_pixels), 4):
        if color_pixels[pixel + 3] < .5:
            color_pixels[pixel:pixel + 4] = [.88, .77, .56, 1.0]
        if ao_pixels[pixel + 3] < .5:
            ao_pixels[pixel:pixel + 4] = [1.0, 1.0, 1.0, 1.0]
    albedo.pixels.foreach_set(color_pixels)
    albedo.filepath_raw = str(BAKED_TEXTURE)
    albedo.file_format = 'PNG'
    albedo.save()
    ao.pixels.foreach_set(ao_pixels)
    ao.filepath_raw = str(AO_TEXTURE)
    ao.file_format = 'PNG'
    ao.save()
    baked = bpy.data.materials.new('cream shirt AO baked')
    baked.use_nodes = True
    bsdf = baked.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (1, 1, 1, 1)
    bsdf.inputs['Roughness'].default_value = 1
    image_node = baked.node_tree.nodes.new('ShaderNodeTexImage')
    image_node.image = albedo
    baked.node_tree.links.new(image_node.outputs['Color'], bsdf.inputs['Base Color'])
    # The glTF exporter reads this group input as occlusionTexture. Keep AO
    # separate from albedo so it only dims indirect light in Godot.
    gltf_output = bpy.data.node_groups.new('glTF Material Output', 'ShaderNodeTree')
    gltf_output.interface.new_socket(name='Occlusion', in_out='INPUT', socket_type='NodeSocketFloat')
    group_node = baked.node_tree.nodes.new('ShaderNodeGroup')
    group_node.node_tree = gltf_output
    ao_node = baked.node_tree.nodes.new('ShaderNodeTexImage')
    ao_node.image = ao
    ao_node.image.colorspace_settings.name = 'Non-Color'
    baked.node_tree.links.new(ao_node.outputs['Color'], group_node.inputs['Occlusion'])
    torso.data.materials.clear()
    torso.data.materials.append(baked)
    for face in torso.data.polygons:
        face.material_index = 0

bake_shirt()
ellipsoid('shorts waist', 'hips', (0, 0, .55), (.30, .24, .15), shorts, 12, 6)

for side, suffix in ((-1, 'r'), (1, 'l')):
    x = side
    ellipsoid('sleeve', 'upperarm.'+suffix, (x*.33, 0, 1.105), (.16, .15, .16), shirt)
    ellipsoid('forearm', 'lowerarm.'+suffix, (x*.59, 0, 1.105), (.16, .095, .095), skin)
    ellipsoid('mitten hand', 'hand.'+suffix, (x*.81, 0, 1.105), (.12, .105, .12), skin)
    ellipsoid('shorts leg', 'upperleg.'+suffix, (x*.17, 0, .44), (.13, .15, .15), shorts)
    ellipsoid('leg', 'lowerleg.'+suffix, (x*.17, .0, .22), (.09, .09, .16), skin)
    ellipsoid('shoe', 'foot.'+suffix, (x*.17, -.09, .075), (.14, .22, .09), shoes)

for obj in bpy.context.selected_objects:
    obj.select_set(False)
for obj in parts:
    obj.select_set(True)
bpy.context.view_layer.objects.active = parts[0]
bpy.ops.object.join()
skin_mesh = bpy.context.object
skin_mesh.name = 'Original visitor skin'
rig.select_set(True)
bpy.ops.export_scene.gltf(filepath=str(OUT), export_format='GLB', use_selection=True,
                          export_animations=True, export_animation_mode='ACTIONS', export_skins=True)
bpy.ops.wm.save_as_mainfile(filepath=str(HERE / 'fixture.blend'))
print('OUTPUT', OUT, 'parts joined', len(parts), 'bytes', OUT.stat().st_size)
