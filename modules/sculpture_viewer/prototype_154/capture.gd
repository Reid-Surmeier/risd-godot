extends Node

const Catalogue := preload("res://modules/sculpture_viewer/catalogue.gd")
const CASES := [0, 60, 120, 180, 240, 300, -1, -2, -4]
var page: Control
var current := -1
var settled := 0

func _ready() -> void:
	page = Catalogue.new()
	add_child(page)
	page.set_process(false)
	page.set_process_input(false)
	if not OS.has_feature("web"):
		_native()

func _set_case(index: int) -> void:
	assert(index >= 0 and index < CASES.size())
	current = index
	settled = 0
	var angle: int = CASES[index]
	page.selected = 2 if angle >= 0 else -angle - 1
	page.hovered = page.selected
	page.scan_yaw = float(maxi(angle, 0))
	page._update_scan_camera()
	page._scan_render_mode()
	assert(page.scan_viewport.render_target_update_mode == (SubViewport.UPDATE_ALWAYS if angle >= 0 else SubViewport.UPDATE_DISABLED))
	page.queue_redraw()

func _process(_delta: float) -> void:
	if not OS.has_feature("web"):
		return
	var request = JavaScriptBridge.eval("window.scan154Request ?? -1")
	if request >= 0 and int(request) != current:
		_set_case(int(request))
	settled += 1
	if current >= 0 and settled == 8:
		JavaScriptBridge.eval("window.scan154Ready = %d" % current)

func _native() -> void:
	var args := OS.get_cmdline_user_args()
	assert(args.size() == 2)
	get_window().size = Vector2i(int(args[1]), int(args[1]))
	DirAccess.make_dir_recursive_absolute(args[0])
	for index in CASES.size():
		_set_case(index)
		for frame in 8:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		assert(get_viewport().get_texture().get_image().save_png(args[0].path_join("%s-%02d.png" % [args[1], index])) == OK)
	print("PASS: six native angles and three unavailable states")
	get_tree().quit()
