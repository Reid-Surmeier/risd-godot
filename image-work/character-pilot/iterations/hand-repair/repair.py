"""Target-specific palm correction, through the existing MCP stage runner ($0)."""
from pathlib import Path
import bpy,bmesh,json,hashlib,math
from mathutils import Vector
HERE=Path(__file__).resolve().parent
SOURCE=HERE.parent/'driven-character/short-arm/canonical-rest.glb'
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=str(SOURCE))
rig=next(o for o in bpy.context.scene.objects if o.type=='ARMATURE')
mesh=next(o for o in bpy.context.scene.objects if o.type=='MESH' and o.find_armature()==rig)
rig.data.pose_position='REST';bpy.context.view_layer.update()
uv=[tuple(v.uv) for v in mesh.data.uv_layers.active.data]
groups={g.index:g.name for g in mesh.vertex_groups};reports={}
# Add shape control only at the thumb contour; interpolated UVs and weights stay local.
for side in ['Left','Right']:
    matrix=rig.matrix_world@rig.data.bones[side+'Hand'].matrix_local
    bm=bmesh.new();bm.from_mesh(mesh.data);layer=bm.verts.layers.deform.active
    hand=mesh.vertex_groups[side+'Hand'].index
    def thumb_vertex(v):
        p=matrix.inverted()@(mesh.matrix_world@v.co)
        return v[layer].get(hand,0)>.5 and 0<p.y<15 and p.z<-1
    edges=[e for e in bm.edges if all(thumb_vertex(v) for v in e.verts)]
    bmesh.ops.subdivide_edges(bm,edges=edges,cuts=2,use_grid_fill=True)
    bm.to_mesh(mesh.data);bm.free();mesh.data.update()
for side in ['Left','Right']:
    matrix=rig.matrix_world@rig.data.bones[side+'Hand'].matrix_local
    rows=[]
    for v in mesh.data.vertices:
        weight=sum(g.weight for g in v.groups if groups[g.group]==side+'Hand')
        if weight>.05:rows.append((v,weight,matrix.inverted()@(mesh.matrix_world@v.co)))
    distal=max(p.y for v,w,p in rows if w>.5)
    # ponytail: this mesh's palm axis; a different character needs its own landmarks.
    factor=14.5/distal
    adjusted=[]
    for v,w,p in rows:
        blend=min(1,max(0,(w-.05)/.6));blend=blend*blend*(3-2*blend)
        p.y*=1+(factor-1)*blend
        p.z*=1-.12*blend
        # The reference has a mitten and one proximal thumb, not a finger rig.
        top=max(0,min(1,(-p.z-2)/4))
        p.z+=top*blend*2.5*math.exp(-((p.y-8.0)/1.6)**2)
        adjusted.append((v,w,p,top*blend*math.exp(-((p.y-4.2)/2.8)**2)))
    amplitude=min((p.z+12)/coefficient for v,w,p,coefficient in adjusted if coefficient>.001)
    for v,w,p,coefficient in adjusted:
        p.z-=amplitude*coefficient
        v.co=mesh.matrix_world.inverted()@(matrix@p)
        # Distal palm is rigid; keep mixed weights at the actual wrist seam.
        if w>.6 and p.y>3:
            for group in mesh.vertex_groups:group.remove([v.index])
            mesh.vertex_groups[side+'Hand'].add([v.index],1,'REPLACE')
    points=[matrix.inverted()@(mesh.matrix_world@v.co) for v,w,p in rows if w>.5]
    bounds=[[min(p[i] for p in points)*.01 for i in range(3)],[max(p[i] for p in points)*.01 for i in range(3)]]
    thumb=min(p.z for p in points if 2<p.y<6)*.01
    palm=min(p.z for p in points if 8<p.y<13)*.01
    assert palm-thumb>.035 and abs(thumb+.12)<.0001,('thumb contour',side,thumb,palm)
    assert .14<bounds[1][1]<.15 and .15<bounds[1][0]-bounds[0][0]<.20
    reports[side]={'vertices':len(rows),'distal_length_before_m':distal*.01,'bounds_after_m':bounds,'length_factor':factor,'thumb_projection_m':palm-thumb}
assert set(uv)<=set(tuple(v.uv) for v in mesh.data.uv_layers.active.data)
assert len(rig.data.bones)==24
mesh.data.update();bpy.context.preferences.filepaths.save_version=0
bpy.ops.object.select_all(action='DESELECT');rig.select_set(True);mesh.select_set(True);bpy.context.view_layer.objects.active=mesh
out=HERE/'canonical-rest.glb'
bpy.ops.export_scene.gltf(filepath=str(out),export_format='GLB',use_selection=True,export_animations=False,export_skins=True)
bpy.ops.wm.save_as_mainfile(filepath=str(HERE/'canonical-rest.blend'),compress=True)
(HERE/'repair.json').write_text(json.dumps({'source_sha256':hashlib.sha256(SOURCE.read_bytes()).hexdigest(),'output_sha256':hashlib.sha256(out.read_bytes()).hexdigest(),'palms':reports,'original_uv_coordinates_preserved':True,'thumb_uvs_interpolated':True,'bones':24,'cost_usd':0},indent=2)+'\n')
print('HANDS_REPAIRED',reports)
