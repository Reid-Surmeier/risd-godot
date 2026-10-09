extends "res://testing/harness_base.gd"
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var stage = load("res://modules/shell/demo.tscn").instantiate()
	stage.get_node("Desktop/Content").set_script(null)
	var content: Control = stage.get_node("Desktop/Content")
	for i in range(18):
		var line := ColorRect.new()
		line.position = Vector2(70 + i * 48, 80)
		line.size = Vector2(3 + i % 3, 870)
		line.color = Color(0.1, 0.15, 0.3)
		content.add_child(line)
	var label := Label.new()
	label.text = "RISD MUSEUM\nCRT + Squigglevision\nProportional windows"
	label.position = Vector2(120, 350)
	label.add_theme_color_override("font_color", Color("#bb315f"))
	label.add_theme_font_size_override("font_size", 54)
	content.add_child(label)
	var out := await _mount(stage, Vector2i(1080,1080), "/tmp/shader193")
	await create_timer(1).timeout
	assert(stage.enabled and stage.squiggle_enabled and stage.squiggle.visible)
	# Static input and fixed noise phase isolate squiggle from CRT's animated grain.
	stage.crt_material.set_shader_parameter("grain_strength", 0.0)
	stage.squiggle.material.set_shader_parameter("fps", 0.0)
	await _frames(3)
	await _shot(out, "both-with-haze.png")
	await _key(KEY_F9, "disable squiggle")
	await _frames(3)
	await _shot(out, "crt-with-haze.png")
	await _key(KEY_F8, "disable CRT")
	await _frames(3)
	await _shot(out, "neither-with-haze.png")
	await _key(KEY_F8, "restore CRT")
	await _key(KEY_F9, "restore squiggle")
	await _frames(3)
	await _shot(out, "both-restored.png")
	print("SHADER193 defaults and F8/F9 controls PASS; inspect pixel comparisons")
	quit()
