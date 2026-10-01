extends SceneTree
## Deterministic actual-material comparison and frame-by-frame blink evidence.
var demo: Node3D
var materials := []
func _initialize() -> void:call_deferred("run")
func capture(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://appearance-"+name+".png")
func run() -> void:
	root.size=Vector2i(960,720)
	demo=load("res://demo.gd").new();root.add_child(demo);demo.set_physics_process(false)
	await process_frame
	demo._physics_process(1.0/60)
	for layer in demo.find_children("*","CanvasLayer",true,false):layer.visible=false
	for mesh in demo.model.find_children("*","MeshInstance3D",true,false):
		if mesh.skin==null:continue
		for index in mesh.mesh.get_surface_count():
			var source: Material=mesh.mesh.surface_get_material(index)
			if source is StandardMaterial3D and source.albedo_texture:
				materials.append({"mesh":mesh,"index":index,"source":source,"active":mesh.get_active_material(index)})
	assert(materials.size()==1)
	var atlas: Image=materials[0].source.albedo_texture.get_image()
	if atlas.is_compressed():atlas.decompress()
	atlas.save_png("res://appearance-atlas.png")
	for view in ["game","face"]:
		if view=="face":
			demo.camera.position=Vector3(0,1.8,5.8);demo.camera.look_at(Vector3(0,1.3,0))
		demo.face_material.set_shader_parameter("blink",0)
		await capture("current-"+view)
		for entry in materials:entry.mesh.set_surface_override_material(entry.index,entry.source)
		await capture("reference-"+view)
		for entry in materials:entry.mesh.set_surface_override_material(entry.index,entry.active)
	for i in 17:
		demo.face_material.set_shader_parameter("blink",i/16.0)
		await capture("closure-%02d"%i)
	var levels := []
	demo.blink_index=15;demo.blink_updates=0
	for i in 16:
		demo._physics_process(1.0/60)
		levels.append(demo.face_material.get_shader_parameter("blink"))
		demo.camera.position=Vector3(0,1.8,5.8);demo.camera.look_at(Vector3(0,1.3,0))
		await capture("timed-%02d"%i)
	demo.face_material.set_shader_parameter("blink",0)
	for clip in ["idle","walk","run","dash","jump"]:
		demo.player.play(clip)
		for phase in [0.0,.25,.5,.75]:
			demo.player.seek(demo.player.get_animation(clip).length*phase,true)
			demo.skeleton.force_update_all_bone_transforms()
			for view in ["front","side"]:
				demo.camera.position=Vector3(0,1.6,9) if view=="front" else Vector3(9,1.6,0)
				demo.camera.look_at(Vector3(0,1,0))
				await capture("hand-"+clip+"-"+view+"-%02d"%int(phase*100))
	# The reported bend is most visible while idle from above and to the side.
	demo.camera.projection=Camera3D.PROJECTION_ORTHOGONAL;demo.camera.size=.85
	for clip in ["idle","walk","run","dash","jump"]:
		demo.player.play(clip);demo.player.advance(0)
		demo.player.seek(demo.player.get_animation(clip).length*.25,true)
		demo.skeleton.force_update_all_bone_transforms()
		for side in ["Left","Right"]:
			var hand: Vector3=(demo.skeleton.global_transform*demo.skeleton.get_bone_global_pose(demo.skeleton.find_bone(side+"Hand"))).origin
			var aim := hand+Vector3.UP*.15
			demo.camera.position=aim+Vector3(2 if side=="Left" else -2,3,3)
			demo.camera.look_at(aim)
			await capture("wrist-"+clip+"-"+side.to_lower())
	# Paired renders catch puffs that exist but are hidden from the actual game camera.
	demo.camera.projection=Camera3D.PROJECTION_PERSPECTIVE;demo.camera.fov=20
	demo.reset();demo.tool="None";demo.surface="Grass"
	Input.action_press("down");Input.action_press("sprint")
	for frame in 40:
		for tick in 2:demo._physics_process(1.0/60)
		if frame in [8,12,16,20,24,28,36]:
			await capture("dust-visible-%02d"%frame)
			for puff in demo.dust:puff.node.visible=false
			await capture("dust-hidden-%02d"%frame)
			for puff in demo.dust:puff.node.visible=true
	Input.action_release("down");Input.action_release("sprint")
	FileAccess.open("res://appearance-check.json",FileAccess.WRITE).store_string(JSON.stringify({"source_material":{"roughness":materials[0].source.roughness,"metallic":materials[0].source.metallic,"shading_mode":materials[0].source.shading_mode,"albedo_color":materials[0].source.albedo_color,"emission_enabled":materials[0].source.emission_enabled,"emission":materials[0].source.emission},"blink_levels":levels,"same_pose_same_light_comparison":true},"  "))
	print("APPEARANCE_CAPTURED actual material reference and blink ramp")
	quit()
