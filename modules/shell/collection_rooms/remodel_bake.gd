## Main Hall native UV2 / LightmapGI recipe applied to the new authored room only.
extends SceneTree

## #274: one light for every added room. The rule, in words, is in
## docs/playtest/room-builder-guide.md ("Light"); these are its numbers.
const FILL_ENERGY:=1.4 # the fill for FILL_M2 of floor in a room with no spots
const UPLIGHT:=.35 # of each fill, sent up at the ceiling from UPLIGHT_DROP below it
const UPLIGHT_DROP:=1.5
const FILL_M2:=25.0
const SPILL:=.03 # of its spots' energy a room's fill gives up: they light the floor too
const FILL_BAY:=5.0 # metres between fills, the Hall's bay
const GROUP_M:=2.4 # works within this width of one wall share a spot
## What the rule leaves over, measured: the fill a room needs for its floor to read as the
## Hall's (143 of 255, give or take ten) depends on its furniture and how low its spots aim, so
## after a bake the light pass's floor number sets the room's trim here. A room not listed is 1.
const FILL_TRIM:={"Rockefeller":.75,"grey French gallery":.5,"adjacent gallery":.82,"light Renaissance room":.95,
	"dark medieval room":1.1,"modern painting gallery":.86,"marble stair hall":.85,
	"purple elevator-5 connector":4.8,"modern adjoining gallery threshold study limit":5.6,
	"Grand Gallery reveal threshold":2.3,"Rockefeller reveal threshold":1.5,
	"white sculpture gallery threshold study limit":1.4}
## The Hall's lamps are #ffe1b2 and #ffd391, but its daylight cools them: its white skirting
## reads (195,174,155). Alone, those two colours turn white trim tan and grey paint olive, so
## the rooms' lamps are the colours that make their trim read as the Hall's skirting does, and
## the oak carries its honey in its own tone (remodel_room.gd, OAK_TONE).
const FILL_COLOR:="ffeee8"
const SPOT_COLOR:="ffe4c8"
const SPOT_ENERGY_PER_M:=1.8 # the Hall's 6.8 at 3.8 m from its painting
const SPOT_LEAN:=.7 # metres out from the work per metre above it: the Hall's 2.2 for 3.1
const SPOT_DROP:=3.1 # a spot hangs at most this far above its work's middle
const SHADE_FLOOR:=.45 # what a work's face turned away from its lamp keeps
const PLAIN_TINT:="fff6ea" # on a work's parts that carry no picture
## What stays out of the baked scene altogether, because the bake traces every triangle and the
## scene is read as text at the first doorway: every work (thirteen placed meshes are 130,000
## triangles), and anything modelled finer than DETAIL_TRIANGLES (the Skylight Gallery's
## ironwork is one mesh of 121,080; with both in, a bake ran past 28 minutes and the scene
## was 35 MB). The game goes on drawing the room's own mesh; all the bake keeps of it is one
## brightness a vertex (a byte, SHADE_TOP at 255). A standing work casts through a plain box
## PROXY of its footprint; fine detail casts nothing and is drawn at DETAIL_LEVEL of its colour.
const DETAIL_TRIANGLES:=30000
const DETAIL_LEVEL:=.45
const PROXY:=.6
const SHADE_TOP:=1.2
## Two switches for a room the bake cannot yet afford, both by plan label.
## LAMPLESS_ROOMS: the room's surfaces are baked, but the rule gives it no fills, spots, probes
## or shadow boxes; it is lit by whatever glows in it and by bounce. Today the two-storey
## Skylight Gallery: without it a full bake took 1:35, with its geometry and none of its lamps
## 2:08, with its lamps more than 15 minutes; which of them costs that is not yet known. Its
## laylights are emissive. Its works keep the brightness of the spot they would have had.
## UNBAKED_ROOMS: the room is kept out of the lightmap altogether, every surface drawn at
## UNBAKED_LEVEL of its own colour and shaded per vertex from above. Empty today; it is the
## fallback if a room's geometry alone is what a bake cannot afford.
const LAMPLESS_ROOMS:=["Skylight Gallery"]
const UNBAKED_ROOMS:=[]
const UNBAKED_LEVEL:=.6
## Daylight the footage shows; the only lamps not derived from the plan and the works.
## Room, from, to (room-scene metres), energy, cone, colour.
const DAYLIGHT:=[["marble stair hall",Vector3(20.2,5.9,-1.96),Vector3(15.0,.5,-1.96),4.0,60.0,"eff5ff"]]
const HALL:="Grand Gallery"

func _initialize() -> void:
	call_deferred("prepare")

## Every catalogued work that is not in the Hall: its drawn meshes, its box, its room, the
## way it faces (off its wall, or toward the middle of the room) and whether it hangs flat.
func find_works(walk:Node,plan:Array) -> Array:
	var tops:Array=[]
	for node in walk.find_children("*","Node3D",true,false):
		var script:Script=node.get_script()
		if not (node.has_meta("catalogue_accession") or node.has_meta("catalogue_asset") or (script!=null and script.resource_path.ends_with("painting_asset.gd"))):continue
		var nested:=false
		for other in tops:nested=nested or other.is_ancestor_of(node)
		if not nested:tops.append(node)
	var works:=[]
	for node in tops:
		var parts:Array=node.find_children("*","MeshInstance3D",true,false)
		if node is MeshInstance3D:parts.append(node)
		parts=parts.filter(func(part):return part.mesh!=null and part.mesh.get_surface_count()>0 and part.is_visible_in_tree() and not part.has_meta("retained_main_hall"))
		if parts.is_empty():continue
		var box:AABB=parts[0].global_transform*parts[0].get_aabb()
		for part in parts:box=box.merge(part.global_transform*part.get_aabb())
		var flat:=Rect2(box.position.x,box.position.z,box.size.x,box.size.z).grow(.05)
		var room:Dictionary={}
		var most:=0.0
		for area in plan:
			var b:Array=area.bounds
			var share:=Rect2(b[0],b[2],b[1]-b[0],b[3]-b[2]).intersection(flat).get_area()
			if share>most:
				most=share
				room=area
		if room.is_empty() or room.label==HALL:continue
		var b:Array=room.bounds
		var facing:=Vector3.ZERO
		var nearest:=.45
		for side in [[box.position.x-b[0],Vector3.RIGHT],[b[1]-box.end.x,Vector3.LEFT],[box.position.z-b[2],Vector3.BACK],[b[3]-box.end.z,Vector3.FORWARD]]:
			if side[0]<nearest:
				nearest=side[0]
				facing=side[1]
		var hung:=facing!=Vector3.ZERO
		if not hung:
			# Free-standing: lit from the side of the room's middle, square to the walls so that
			# neighbours on one plinth or in one case face the same way and share a spot.
			var off:=Vector2(((b[0]+b[1])/2-box.get_center().x)/(b[1]-b[0]),((b[2]+b[3])/2-box.get_center().z)/(b[3]-b[2]))
			facing=Vector3(signf(off.x),0,0) if absf(off.x)>absf(off.y) else Vector3(0,0,signf(off.y) if off.y!=0 else 1.0)
		# The key a click reports (main_build_walk.gd): the accession, else the asset name; a framed
		# painting carries its accession only in its canvas file, assets/painting-<accession>.jpg.
		var key:=str(node.get_meta("catalogue_accession",""))
		if key=="":key=str(node.get_meta("catalogue_asset",node.name))
		if not (node.has_meta("catalogue_accession") or node.has_meta("catalogue_asset")):
			for part in parts:
				var texture=part.material_override.get_shader_parameter("albedo") if part.material_override is ShaderMaterial else part.material_override.albedo_texture if part.material_override is BaseMaterial3D else null
				if texture is Texture2D and (texture.resource_path.get_file().begins_with("painting-") or texture.resource_path.get_file().begins_with("wallpaper-")):
					key=texture.resource_path.get_file().get_basename().get_slice("-",1)
		works.append({"key":key,"parts":parts,"box":box,"room":room,"facing":facing,
			"flat":hung and absf(box.size.dot(facing))<=.25})
	return works

## One track spot per work, or per group of works within GROUP_M of each other on one wall (a
## case of small things, a tight hang): hung above and out from the work as the Hall's are, as
## strong as its distance asks, its cone fitted to what it lights. Every lamp is paid for in
## bake time (159 lamps did not finish in the 28 minutes the rebuild allows; 57 take 8).
func spots_for(works:Array) -> Array:
	var groups:=[]
	works=works.duplicate()
	works.sort_custom(func(a,b):
		var along:Vector3=Vector3.UP.cross(a.facing)
		return [a.room.label,a.facing.x,a.facing.z,a.box.get_center().dot(along)]<[b.room.label,b.facing.x,b.facing.z,b.box.get_center().dot(along)])
	for work in works:
		var joined=null
		for group in groups: # ponytail: one greedy pass along each wall, not the fewest lamps possible
			var both:AABB=group.box.merge(work.box)
			if joined==null and group.room==work.room and group.facing.dot(work.facing)>.9 and maxf(both.size.x,both.size.z)<=GROUP_M and absf(both.size.dot(work.facing))<=1.2:joined=group
		if joined==null:
			groups.append({"room":work.room,"facing":work.facing,"box":work.box,"works":[work]})
		else:
			joined.box=joined.box.merge(work.box)
			joined.works.append(work)
	var spots:=[]
	for group in groups:
		var b:Array=group.room.bounds
		var box:AABB=group.box
		var facing:Vector3=group.facing
		var target:Vector3=box.get_center()+facing*absf(box.size.dot(facing))/2
		var drop:float=clampf(float(group.room.get("height",3.5))-.3-target.y,.5,SPOT_DROP)
		var at:Vector3=target+facing*maxf(.6,drop*SPOT_LEAN)+Vector3.UP*drop
		at.x=clampf(at.x,b[0]+.25,b[1]-.25)
		at.z=clampf(at.z,b[2]+.25,b[3]-.25)
		var reach:float=at.distance_to(target)
		var across:Vector3=Vector3.UP.cross(facing)
		var width:float=maxf(absf(box.size.dot(across.abs())),box.size.y)
		for work in group.works:work["lamp"]=at
		spots.append({"room":group.room.label,"kind":"spot","at":at,"target":target,"energy":SPOT_ENERGY_PER_M*reach,
			"cone":clampf(rad_to_deg(atan((width/2+.35)/reach)),14.0,32.0),"color":SPOT_COLOR,"works":group.works.map(func(work):return work.key)})
	return spots

## A work is drawn at its own colours, not through lightmap texels (14 cm texels on a 20 cm
## object came out dark and blotchy): each vertex is shaded once, here, by the lamp aimed at
## the work. The face it shows the room keeps its full colour; faces turned away fall to
## SHADE_FLOOR. One byte a vertex, in the mesh's own vertex order.
func shades_of(arrays:Array,pose:Transform3D,work:Dictionary,level:float) -> PackedByteArray:
	var points:PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
	var normals=arrays[Mesh.ARRAY_NORMAL]
	var shades:=PackedByteArray()
	shades.resize(points.size())
	var centre:Vector3=work.box.get_center()
	var facing:Vector3=work.facing
	for i in points.size():
		var at:Vector3=pose*points[i]
		var normal:Vector3=(pose.basis*normals[i]).normalized() if normals!=null and normals.size()==points.size() else facing
		# Cards are drawn from both sides: a normal counts as pointing out of the work.
		var out:float=(at-centre).dot(normal)
		if out< -.02 or (absf(out)<=.02 and normal.dot(facing)<0):normal=-normal
		var toward:Vector3=(work.lamp-at).normalized()
		var shade:float=level*clampf(lerpf(SHADE_FLOOR,1.0,(normal.dot(toward)*.5+.5)/(facing.dot(toward)*.5+.5)),SHADE_FLOOR,1.1)
		shades[i]=clampi(roundi(shade/SHADE_TOP*255.0),0,255)
	return shades

## How high a lamp can hang over a point: under whatever is built above it (a doorway's
## header, a landing), else `top`.
func headroom(covers:Array,x:float,z:float,top:float) -> float:
	var clear:=top
	for box in covers:
		if box.position.y<clear and box.position.x<=x and box.end.x>=x and box.position.z<=z and box.end.z>=z:clear=box.position.y
	return clear

func prepare() -> void:
	var walk=load("res://modules/shell/collection_rooms/remodel_room.tscn").instantiate()
	walk.set_meta("bake_preparing",true)
	root.add_child(walk)
	await process_frame
	assert(not walk.inventory.has("native_lightmap_users"),"Rebake must exclude the previous baked room")
	walk.set_physics_process(false)
	var plan:Array=JSON.parse_string(FileAccess.get_file_as_string("res://modules/shell/collection_rooms/geometry.json")).rooms
	# ROOMS_LIGHT_ONLY=<room label>: a trial bake of that one room, minutes instead of the whole museum.
	var only:String=OS.get_environment("ROOMS_LIGHT_ONLY")
	if only!="":plan=plan.filter(func(area):return area.label==only)
	var works:=find_works(walk,plan)
	var work_of:={}
	for work in works:
		for part in work.parts:work_of[part]=work
	# What is built overhead: everything drawn that starts above head height and is not a work.
	var covers:=[]
	for mesh in walk.find_children("*","MeshInstance3D",true,false):
		if mesh.mesh==null or not mesh.is_visible_in_tree() or work_of.has(mesh) or walk.visitor.is_ancestor_of(mesh):continue
		var over:AABB=mesh.global_transform*mesh.get_aabb()
		if over.position.y>1.9:covers.append(over)
	var lamps:=spots_for(works)
	for lamp in lamps:
		lamp.at.y=maxf(2.0,minf(lamp.at.y,headroom(covers,lamp.at.x,lamp.at.z,lamp.at.y+.2)-.1))
		lamp.energy=SPOT_ENERGY_PER_M*lamp.at.distance_to(lamp.target)
	lamps=lamps.filter(func(lamp):return not (lamp.room in UNBAKED_ROOMS or lamp.room in LAMPLESS_ROOMS))
	var asked:={} # room -> what it puts in the bake and what it keeps out
	var shades:={} # authored mesh name -> [is a work, a PackedByteArray of brightness for each surface]
	var room:=Node3D.new()
	room.name="BakedRoom"
	var index:=0
	var floors:=SurfaceTool.new()
	var floor_names:=[]
	var floor_material:Material
	for source in walk.find_children("*","MeshInstance3D",true,false):
		if source.has_meta("retained_main_hall") or walk.visitor.is_ancestor_of(source) or source.has_meta("contact_shadow") or not source.is_visible_in_tree() or source.mesh.get_surface_count()==0 or source.has_meta("skylight"):continue
		if source.material_override is StandardMaterial3D and source.material_override.transparency==BaseMaterial3D.TRANSPARENCY_ALPHA:continue
		if only!="":
			var middle:Vector3=(source.global_transform*source.get_aabb()).get_center()
			var b:Array=plan[0].bounds
			if middle.x<b[0]-.5 or middle.x>b[1]+.5 or middle.z<b[2]-.5 or middle.z>b[3]+.5:continue
		var reach:AABB=source.global_transform*source.get_aabb()
		var where:="elsewhere"
		for area in plan:
			var rb:Array=area.bounds
			if reach.get_center().x>=rb[0] and reach.get_center().x<=rb[1] and reach.get_center().z>=rb[2] and reach.get_center().z<=rb[3]:where=area.label
		var unbaked:bool=where in UNBAKED_ROOMS
		if not unbaked and source.material_override is ShaderMaterial and source.material_override.shader.resource_path.ends_with("floor_oak.gdshader"):
			floors.append_from(source.mesh,0,source.global_transform)
			floor_names.append(source.name)
			floor_material=source.material_override
			continue
		var work=work_of.get(source)
		var triangles:int=source.mesh.get_faces().size()/3
		# What each room asks of the bake, printed before it starts.
		var row:Dictionary=asked.get_or_add(where,{"surfaces":0,"triangles":0,"texels":0,"kept_out":0,"kept_out_triangles":0})
		if work!=null or unbaked or triangles>DETAIL_TRIANGLES:
			var lit:Dictionary=work if work!=null else {"box":reach,"facing":Vector3.UP,"lamp":reach.get_center()+Vector3.UP*2.5}
			var kept:=[work!=null]
			for surface in source.mesh.get_surface_count():
				kept.append(shades_of(source.mesh.surface_get_arrays(surface),source.global_transform,lit,1.0 if work!=null else UNBAKED_LEVEL if unbaked else DETAIL_LEVEL))
			shades[source.name]=kept
			row.kept_out+=1
			row.kept_out_triangles+=triangles
			continue
		var st:=SurfaceTool.new()
		for surface in source.mesh.get_surface_count():st.append_from(source.mesh,surface,Transform3D.IDENTITY)
		var mesh:=st.commit()
		var normals=mesh.surface_get_arrays(0)[Mesh.ARRAY_NORMAL]
		if normals==null or normals.is_empty():
			st.generate_normals()
			mesh=st.commit()
		var result:=mesh.lightmap_unwrap(source.global_transform,.14)
		assert(result==OK,"Native UV2 unwrap failed")
		row.surfaces+=1
		row.triangles+=triangles
		row.texels+=mesh.lightmap_size_hint.x*mesh.lightmap_size_hint.y
		var instance:=MeshInstance3D.new()
		instance.name="Surface%03d"%index
		instance.mesh=mesh
		instance.material_override=source.material_override
		# Reuse gallery_walk4/bake/prepare.gd's native PS1-to-bake material handling.
		if source.material_override is ShaderMaterial and source.material_override.shader.resource_path.ends_with("/ps1.gdshader"):
			var original:ShaderMaterial=source.material_override
			var material:=StandardMaterial3D.new()
			var tint=original.get_shader_parameter("tint")
			material.albedo_color=tint if tint!=null else Color.WHITE
			material.albedo_texture=original.get_shader_parameter("albedo")
			var scale_uv=original.get_shader_parameter("uv_scale")
			if scale_uv!=null:material.uv1_scale=Vector3(scale_uv.x,scale_uv.y,1)
			material.specular_mode=BaseMaterial3D.SPECULAR_DISABLED
			material.cull_mode=BaseMaterial3D.CULL_DISABLED
			material.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
			var alpha=original.get_shader_parameter("alpha_cut")
			if alpha!=null and alpha>0:
				material.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
				material.alpha_scissor_threshold=alpha
			if material.albedo_texture and not "/textures/" in material.albedo_texture.resource_path:material.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
			if source.get_parent().name=="ConnectedHall" and source.mesh.get_aabb().position.y>=6 and source.mesh.get_aabb().size.y>1:material.albedo_color=Color("e2dccd")
			instance.material_override=material
		instance.transform=source.global_transform
		instance.gi_mode=GeometryInstance3D.GI_MODE_STATIC
		instance.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_DOUBLE_SIDED
		instance.set_meta("source_path",source.name)
		room.add_child(instance)
		instance.owner=room
		index+=1
	# Same continuous world UV2 floor as the Main Hall: joins cannot become bake islands.
	var merged:=floors.commit()
	var arrays:=merged.surface_get_arrays(0)
	var uv2:=PackedVector2Array()
	var bounds:=merged.get_aabb()
	for point in arrays[Mesh.ARRAY_VERTEX]:
		var uv:=Vector2((point.x-bounds.position.x)/bounds.size.x,(point.z-bounds.position.z)/bounds.size.z)
		assert(uv.x>=0 and uv.x<=1 and uv.y>=0 and uv.y<=1)
		uv2.append(uv)
	arrays[Mesh.ARRAY_TEX_UV2]=uv2
	var floor_mesh:=ArrayMesh.new()
	floor_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	floor_mesh.lightmap_size_hint=Vector2i(512,1024)
	var floor_instance:=MeshInstance3D.new()
	floor_instance.name="ContinuousFloor"
	floor_instance.mesh=floor_mesh
	floor_instance.material_override=floor_material
	floor_instance.gi_mode=GeometryInstance3D.GI_MODE_STATIC
	floor_instance.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	floor_instance.set_meta("source_paths",floor_names)
	room.add_child(floor_instance)
	floor_instance.owner=room
	index+=1
	# A standing work's shadow, from a box the game never draws (remodel_room.gd hides it).
	var plain:=StandardMaterial3D.new()
	plain.albedo_color=Color("8c8c8c")
	var proxies:=0
	for work in works:
		if work.flat or work.room.label in UNBAKED_ROOMS or work.room.label in LAMPLESS_ROOMS:continue
		var cube:=BoxMesh.new()
		cube.size=Vector3(work.box.size.x*PROXY,work.box.size.y,work.box.size.z*PROXY)
		var shell:=SurfaceTool.new()
		shell.append_from(cube,0,Transform3D.IDENTITY)
		var caster:=shell.commit()
		var stand:=Transform3D(Basis.IDENTITY,work.box.get_center())
		assert(caster.lightmap_unwrap(stand,.14)==OK,"Native UV2 unwrap failed")
		var proxy:=MeshInstance3D.new()
		proxy.name="Proxy%03d"%proxies
		proxy.mesh=caster
		proxy.material_override=plain
		proxy.transform=stand
		proxy.gi_mode=GeometryInstance3D.GI_MODE_STATIC
		proxy.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_DOUBLE_SIDED
		proxy.set_meta("shadow_proxy",true)
		room.add_child(proxy)
		proxy.owner=room
		proxies+=1
	# Fill: every area of the plan has at least one, so no room is left unlit.
	for area in plan:
		if area.label==HALL or area.label in UNBAKED_ROOMS or area.label in LAMPLESS_ROOMS:continue
		var b:Array=area.bounds
		var across:int=maxi(1,roundi((b[1]-b[0])/FILL_BAY))
		var along:int=maxi(1,roundi((b[3]-b[2])/FILL_BAY))
		# The floor is to read like the Hall's in every room, so the fill makes up what the room's
		# spots do not already give: a room dense with works needs little, a bare stair needs it all.
		var whole:float=FILL_ENERGY*(b[1]-b[0])*(b[3]-b[2])/FILL_M2
		var spots:=0.0
		for lamp in lamps:
			if lamp.room==area.label:spots+=lamp.energy
		var each:float=maxf(maxf(whole-SPILL*spots,whole*.25)/(across*along),FILL_ENERGY*.15)*float(FILL_TRIM.get(area.label,1.0))
		for i in across:
			for j in along:
				# A lamp at the ceiling lighting everything below it: floor and walls take it, the
				# ceiling only what bounces (an all-round lamp left a glow on the ceiling over it).
				var hung:=Vector3(lerpf(b[0],b[1],(i+.5)/across),0,lerpf(b[2],b[3],(j+.5)/along))
				hung.y=maxf(2.0,headroom(covers,hung.x,hung.z,minf(float(area.get("height",3.5)),5.8))-.3)
				lamps.append({"room":area.label,"kind":"fill","at":hung,"target":Vector3(hung.x,0,hung.z),"cone":88.0,
					"energy":each,"color":FILL_COLOR})
				# The footage's ceilings are white: bounce off an oak floor alone leaves them dim and
				# tan. A second, weaker lamp looks up from well below the ceiling, far enough that it
				# washes the whole ceiling instead of glowing on one patch of it.
				var low:=Vector3(hung.x,maxf(1.9,hung.y+.3-UPLIGHT_DROP),hung.z)
				if hung.y+.3-low.y>=1.0:
					lamps.append({"room":area.label,"kind":"up","at":low,"target":Vector3(hung.x,hung.y+.3,hung.z),"cone":85.0,
						"energy":each*UPLIGHT,"color":FILL_COLOR})
		# The visitor takes the room's light from probes at body height.
		for x in range(maxi(1,int((b[1]-b[0])/2.0))):
			for z in range(maxi(1,int((b[3]-b[2])/2.0))):
				for y in [.3,1.1,2.0]:
					var probe:=LightmapProbe.new()
					probe.position=Vector3(lerpf(b[0],b[1],(x+.5)/maxi(1,int((b[1]-b[0])/2.0))),y,lerpf(b[2],b[3],(z+.5)/maxi(1,int((b[3]-b[2])/2.0))))
					room.add_child(probe)
					probe.owner=room
	for spec in DAYLIGHT:
		if not (spec[0] in UNBAKED_ROOMS or spec[0] in LAMPLESS_ROOMS) and plan.any(func(area):return area.label==spec[0]):
			lamps.append({"room":spec[0],"kind":"daylight","at":spec[1],"target":spec[2],"energy":spec[3],"cone":spec[4],"color":spec[5]})
	for lamp in lamps:
		var light:=SpotLight3D.new()
		room.add_child(light)
		light.owner=room
		light.look_at_from_position(lamp.at,lamp.target,Vector3.UP if absf((lamp.target-lamp.at).normalized().y)<.99 else Vector3.RIGHT)
		light.spot_angle=lamp.cone
		if lamp.kind in ["fill","up"]:
			light.spot_range=lamp.at.y+4.0
			light.spot_attenuation=.65 # the Hall's fills fall off this gently
			light.spot_angle_attenuation=.35
			light.light_size=.4
		else:
			light.spot_range=lamp.at.distance_to(lamp.target)+2.0
			light.spot_angle_attenuation=1.5
			light.light_size=.05 # the lightmap's 14 cm texels soften a shadow's edge more than a wide lamp would
		light.light_energy=lamp.energy
		light.light_color=Color(lamp.color)
		light.light_bake_mode=Light3D.BAKE_STATIC
		light.shadow_enabled=true
	# The bake keeps no lamp nodes; this list is what the playtest's light pass reads.
	var rows:=[]
	for lamp in lamps:
		var row:Dictionary=lamp.duplicate()
		for key in ["at","target"]:
			if row.has(key):row[key]=[snappedf(row[key].x,.001),snappedf(row[key].y,.001),snappedf(row[key].z,.001)]
		for key in ["energy","cone"]:
			if row.has(key):row[key]=snappedf(row[key],.001)
		rows.append(row)
	var record:=FileAccess.open("res://modules/shell/collection_rooms/addition_baked/room-lamps.json",FileAccess.WRITE)
	if record!=null:
		record.store_string(JSON.stringify(rows,"\t")+"\n")
		record.close()
	var lm:=LightmapGI.new()
	lm.name="Lightmap"
	lm.quality=LightmapGI.BAKE_QUALITY_MEDIUM
	lm.bounces=2
	lm.directional=false
	lm.generate_probes_subdiv=LightmapGI.GENERATE_PROBES_SUBDIV_8
	# No sky and no sun: a room is lit by its own lamps, with or without a ceiling over it.
	lm.environment_mode=LightmapGI.ENVIRONMENT_MODE_DISABLED
	room.add_child(lm)
	lm.owner=room
	room.set_meta("vertex_shades",shades)
	room.set_meta("shade_top",SHADE_TOP)
	room.set_meta("plain_tint",Color(PLAIN_TINT))
	var packed:=PackedScene.new()
	assert(packed.pack(room)==OK)
	assert(ResourceSaver.save(packed,"res://modules/shell/collection_rooms/addition_baked/room.tscn")==OK)
	walk.queue_free()
	room.free()
	await process_frame
	var sum:={"surfaces":0,"triangles":0,"texels":0,"kept_out":0,"kept_out_triangles":0}
	for where in asked:
		print("BAKE_PREPARE asks ",where," ",JSON.stringify(asked[where])) # the rebuild script shows lines with this prefix
		for key in sum:sum[key]+=asked[where][key]
	print("BAKE_PREPARE asks in all ",JSON.stringify(sum)," shadow boxes ",proxies)
	print("BAKE_PREPARE surfaces=",index," works=",works.size()," lamps=",lamps.size())
	quit()
