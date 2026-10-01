## #183: catalogue-matched frame asset; room placement and bake remain unverified.
extends SceneTree

const APP := "res://image-work/collection-room-remodel/"

func _initialize() -> void:
	call_deferred("run")

func texture(path: String) -> ImageTexture:
	var image := Image.load_from_file(path)
	assert(image != null and not image.is_empty())
	return ImageTexture.create_from_image(image)

func run() -> void:
	root.size=Vector2i(960,720)
	var scene:=Node3D.new()
	root.add_child(scene)
	var env:=WorldEnvironment.new()
	env.environment=Environment.new()
	env.environment.background_mode=Environment.BG_COLOR
	env.environment.background_color=Color("55514a")
	scene.add_child(env)
	var data:Dictionary=JSON.parse_string(FileAccess.get_file_as_string(APP+"trial/fetti-frame-geometry.json"))
	var asset=load("res://modules/shell/prototype/gallery_walk4/painting_asset.gd").new()
	scene.add_child(asset)
	asset.build_framed(texture(APP+"trial/fetti-frame.png"),texture(APP+"inventory-catalogue/fetti-angels-zoom-0.jpg"),Vector2(data.canvas_m[0],data.canvas_m[1]),data.margins_px)
	assert(asset.get_child_count()==4)
	var camera:=Camera3D.new()
	scene.add_child(camera)
	camera.current=true
	camera.fov=55
	var output:="res://docs/evidence/collection-reconstruction/main-worker-wide-20260930T2140/"
	DirAccess.make_dir_recursive_absolute(output)
	for view in [["detail",Vector3(0,0,1.65)],["angle",Vector3(.8,.2,1.5)],["walking",Vector3(.4,0,3.0)]]:
		camera.position=view[1]
		camera.look_at(Vector3.ZERO)
		await process_frame
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(output+"fetti-frame-"+view[0]+".png")==OK)
	print("FETTI_FRAME_TRIAL_OK: 4 meshes, 3 views, authentic 36.003 canvas .781 x .895 m; room placement/bake unverified")
	quit()
