## PROTOTYPE #155: actual Godot 1080-square captures of every Tenant in each layout.
extends SceneTree

const Scene := preload("res://modules/shell/prototype/square_stage/demo.tscn")
const Shell := preload("res://modules/shell/interface.gd")
const KEYS := ["map", "sketchbook", "3d_viewer", "video_player", "collection", "playground", "flowers"]

func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var out := "/tmp/square-stage-captures"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out-dir="):
			out = arg.trim_prefix("--out-dir=")
	DirAccess.make_dir_recursive_absolute(out)
	root.size = Vector2i(1080, 1080)
	var stage: Control = Scene.instantiate()
	root.add_child(stage)
	stage.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for _frame in 30:
		await process_frame
	var shell: Control = stage.shell
	var records := []
	for v in 3:
		stage._set_variant(v)
		for i in KEYS.size():
			stage._select(i)
			for _frame in 24:
				await process_frame
			var state: Dictionary = Shell.state(shell).value
			var shown_size: Vector2 = stage.pages.size * stage.pages.scale
			if state.active != i or state.fixed_count != 7 or not stage.tab_buttons[i].button_pressed or shown_size.x <= 0 or shown_size.y <= 0 or stage.pages.position.x + shown_size.x > 1080.5 or stage.pages.position.y + shown_size.y > 1026.5 or not stage.header.get_global_rect().encloses(stage.switcher.get_global_rect()) or (v == 2 and stage.side_panel.get_global_rect().intersects(stage.pages.get_global_rect())):
				push_error("square stage failed at variant %s Tab %s" % [v, KEYS[i]])
				quit(1)
				return
			if i == 0 and not stage.pages.has_node("Page_map/Atlas/minimap/PrototypeClockMask") or i == 4 and not stage.pages.has_node("Page_collection/CollectionFrame/PrototypeClockMask"):
				push_error("prototype clock mask missing at %s" % KEYS[i])
				quit(1)
				return
			var path := "%s/%s-%s.png" % [out, "ABC"[v], KEYS[i]]
			root.get_texture().get_image().save_png(path)
			records.append({"variant": "ABC"[v], "tab": KEYS[i], "active": state.active, "page_rect": [stage.pages.position.x, stage.pages.position.y, shown_size.x, shown_size.y], "capture": path})
	stage._open_start()
	if stage.start_menu.item_count != 7:
		push_error("Start menu does not list seven Tabs")
		quit(1)
		return
	stage._select(4)
	stage.strip.get_child(stage.strip.get_child_count() - 1).pressed.emit()
	if Shell.state(shell).value.active != 0:
		push_error("Home did not select Map")
		quit(1)
		return
	var file := FileAccess.open(out + "/state.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"size": [1080, 1080], "start_items": stage.start_menu.item_count, "home_active": 0, "captures": records}, "  "))
	file.close()
	print("Captured %d real Godot frames at 1080x1080 to %s" % [records.size(), out])
	quit()
