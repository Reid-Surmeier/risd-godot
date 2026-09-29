## Issue #183: isolated trial, uses the existing frame builder and authentic canvas.
extends SceneTree

const APP := "res://image-work/collection-expansion-frame/"
const OUT := "res://docs/evidence/collection-reconstruction/"

func _initialize() -> void:
	call_deferred("run")

func texture(path: String) -> ImageTexture:
	var image := Image.load_from_file(path)
	assert(image != null and not image.is_empty())
	return ImageTexture.create_from_image(image)

func run() -> void:
	root.size = Vector2i(960, 720)
	var scene := Node3D.new()
	root.add_child(scene)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color("55514a")
	scene.add_child(env)
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(APP + "trial/geometry.json"))
	var asset = load("res://modules/shell/prototype/gallery_walk4/painting_asset.gd").new()
	scene.add_child(asset)
	asset.build_framed(texture(APP + "trial/frame.png"), texture(APP + "references/painting-35.786.jpg"), Vector2(0.651, 0.541), data.margins_px)
	assert(asset.get_child_count() == 4)
	# Trial only: extrude the actual cutout perimeter instead of four rectangle strips.
	var old_sides: Node = asset.get_child(1)
	asset.remove_child(old_sides)
	old_sides.queue_free()
	var frame_image := Image.load_from_file(APP + "trial/frame.png")
	var bitmap := BitMap.new()
	bitmap.create_from_image_alpha(frame_image, 0.5)
	var polygons := bitmap.opaque_to_polygons(Rect2i(Vector2i.ZERO, frame_image.get_size()), 2.0)
	var outline: PackedVector2Array = polygons[0]
	for polygon in polygons:
		if polygon.size() > outline.size():
			outline = polygon
	var margins: Array = data.margins_px
	var mpp: float = 0.541 / (frame_image.get_height() - margins[1] - margins[3])
	var map_x := func(x: float) -> float:
		if x < margins[0]:
			return -0.3255 + (x - margins[0]) * mpp
		var right: float = frame_image.get_width() - margins[2]
		if x > right:
			return 0.3255 + (x - right) * mpp
		return (x - margins[0]) / (right - margins[0]) * 0.651 - 0.3255
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in outline.size():
		var a := outline[i]
		var b := outline[(i + 1) % outline.size()]
		var ax: float = map_x.call(a.x)
		var bx: float = map_x.call(b.x)
		var ay: float = 0.2705 - (a.y - margins[1]) * mpp
		var by: float = 0.2705 - (b.y - margins[1]) * mpp
		asset.quad(st, [Vector3(ax, ay, 0), Vector3(bx, by, 0), Vector3(bx, by, 0.09), Vector3(ax, ay, 0.09)], [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO])
	var sides := MeshInstance3D.new()
	sides.mesh = st.commit()
	var side_material := StandardMaterial3D.new()
	side_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	side_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	side_material.albedo_color = Color(0.24, 0.20, 0.12)
	sides.material_override = side_material
	asset.add_child(sides)
	var camera := Camera3D.new()
	scene.add_child(camera)
	camera.current = true
	camera.fov = 55
	for view in [["detail", Vector3(0, 0, 1.2)], ["angle", Vector3(0.75, 0.2, 1.1)], ["walking", Vector3(0.4, 0, 2.5)]]:
		camera.position = view[1]
		camera.look_at(Vector3.ZERO)
		await process_frame
		await RenderingServer.frame_post_draw
		var error := root.get_texture().get_image().save_png(OUT + "muse-frame-" + view[0] + ".png")
		assert(error == OK)
	print("FRAME_TRIAL_OK: four meshes; three views; canvas 0.651 x 0.541 m; bake unverified")
	quit()
