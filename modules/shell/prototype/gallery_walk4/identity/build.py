"""Build an original low-poly visitor skin on KayKit's CC0 Rogue skeleton.

Run: blender -b -t 1 --python modules/shell/prototype/gallery_walk4/identity/build.py
The imported Rogue geometry is deleted; only its armature and animation survive.
"""
import bpy
from pathlib import Path

HERE = Path(__file__).resolve().parent
SOURCE = HERE / 'Rogue.source.glb'
OUT = HERE / 'visitor_identity.glb'

bpy.ops.wm.read_factory_settings(use_empty=True)
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
                          export_animations=True, export_nla_strips=True)
print('OUTPUT', OUT, 'parts joined', len(parts), 'bytes', OUT.stat().st_size)
