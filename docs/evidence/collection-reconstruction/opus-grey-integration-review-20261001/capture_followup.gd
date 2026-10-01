## Follow-up review captures on CPU (Mesa llvmpipe), unbaked, in a scratch project prepared from the reviewed sources:
##   env LIBGL_ALWAYS_SOFTWARE=1 GALLIUM_DRIVER=llvmpipe DISPLAY=:99 godot --path <project> --rendering-method gl_compatibility -s capture_followup.gd -- --out=<folder>
## Six views of what the follow-up changed: connector faces, columned opening, piano door, labels.
## The retained Hall's north-passage meshes are hidden, as the full app's grey-gallery camera leaves the Hall's layer out
## (see capture_hall_passage.gd for the same room with them drawn).
## Camera positions approximate the IMG_6380 viewpoints named beside each view; they are not measured.
extends SceneTree

func _initialize() -> void:
	create_timer(300).timeout.connect(func(): quit(2))
	call_deferred("run")

func run() -> void:
	var out := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out = arg.trim_prefix("--out=")
	root.size = Vector2i(1100, 760)
	var scene: Node3D = load("res://remodel_room.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.set_physics_process(false)
	scene.visitor.hide()
	scene.contact_shadow.hide()
	scene.label.hide()
	for casing in scene.casings:
		casing.get_child(1).show()
	scene.update_baked_visibility()
	for node in scene.find_children("*", "MeshInstance3D", true, false):
		if node.has_meta("retained_main_hall") and str(node.name) != "Surface000" and (node.global_transform * node.mesh.get_aabb()).position.z < 1.6:
			node.hide()
	for view in [["connector-looking-east-245s", Vector3(.9, 1.6, .58), Vector3(11.05, 1.4, .3)], ["connector-looking-west-103s", Vector3(5.4, 1.6, .2), Vector3(0, 1.3, .7)],
			["columns-from-west-248s", Vector3(4.6, 1.6, -.6), Vector3(11.05, 1.9, -1.2)], ["piano-door-14s", Vector3(6.6, 1.6, -.4), Vector3(5.3, 1.5, -4.2)],
			["courbet-label-corner", Vector3(7.2, 1.6, -2.2), Vector3(3.9, 1.7, -3.5)], ["corot-label-and-north-pilaster", Vector3(8.4, 1.6, -1.4), Vector3(10.7, 1.9, -4.2)]]:
		scene.camera.fov = 70
		scene.camera.position = view[1]
		scene.camera.look_at(view[2])
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(out.path_join(view[0] + ".png"))
	print("CAPTURE ", JSON.stringify({"views": 6}))
	quit(0)
