## The 800x680 3D sculpture viewer window: the clean media-player chrome over a SubViewport with
## the Buddha scan; drag orbits, the wheel zooms, previous / next, play / pause, scrubber, audio
## and menu with their Muse + Seedance motion frames. Lives inside desktop.gd; reach it through
## interface.gd only.
##
## Ported from figma-ui-ux-qwen-pipeline prototype/painting-tool-mixbox @ 7ee5e9c
## viewer-godot/scripts/main.gd. Left behind: the JavaScriptBridge publishes, the ?qa-plate test
## hook and the ?lod-bias / ?no-shadow QA levers. Changed: asset paths, and qa_state() trimmed to
## the fields the probe documents. Behaviour unchanged.
extends Control

const CANVAS_SIZE := Vector2(800, 680)
const CAMERA_TARGET := Vector3(0.0, 2.25, 0.0)
const DEFAULT_YAW := -132.48
const DEFAULT_PITCH := -8.0
const DEFAULT_DISTANCE := 8.7
const MODEL_PATH := "res://modules/sculpture_viewer/assets/models/proton-buddha-3124123123.glb"
const MODEL_TEXTURE_PATH := "res://modules/sculpture_viewer/assets/models/3124123123.jpg"
const TRANSPORT_Y := 592.0
const SOURCE_ASSET_PATHS := {
	"background": "res://modules/sculpture_viewer/assets/clean-ui/background.png",
}

var yaw_degrees := DEFAULT_YAW
var pitch_degrees := DEFAULT_PITCH
var camera_distance := DEFAULT_DISTANCE
var playing := true
var muted := false
var menu_open := false
var dragging_viewport := false
var playback_progress := 0.132
var active_view := 0
var lighting_mode := 0
var interaction_count := 0
var animation_count := 0
var last_animated_control := ""
var menu_overlay_visible := false
var source_components_loaded: Array[String] = []
var visual_components: Dictionary = {}
var control_visual_states: Dictionary = {}
var control_hovered: Dictionary = {}
var control_feedback_active: Dictionary = {}
var control_pressed: Dictionary = {}
var motion_textures: Dictionary = {}
var motion_phase: Dictionary = {}
var motion_targets: Dictionary = {}
var motion_frames: Dictionary = {}
var scrubber_dragging := false
const MOTION_SIZES := {
	"previous": Vector2(122, 160), "next": Vector2(122, 160),
	"play-pause": Vector2(58, 46), "audio": Vector2(64, 46),
	"menu": Vector2(115, 46), "scrubber": Vector2(34, 34),
}
const MOTION_HOVER := 7.0
const MOTION_PRESS := 14.0
const MOTION_END := 23.0
var model_loaded := false
var model_texture_loaded := false

var camera: Camera3D
var environment: Environment
var viewport_container: SubViewportContainer
var play_button: Button
var progress_slider: HSlider
var timer_label: Label
var audio_button: Button
var menu_button: Button
var menu_panel: PanelContainer
var previous_button: Button
var next_button: Button
var scrubber_thumb: TextureRect
var scrubber_fill: TextureRect
var last_pointer_position := Vector2.ZERO

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	focus_mode = Control.FOCUS_ALL
	_build_surface()
	_load_motion_assets()
	_build_3d_viewport()
	_build_navigation()
	_build_transport()
	_build_menu()
	_update_scrubber_thumb()
	_update_camera()
	grab_focus()

var _spin_frame := 0

func _process(delta: float) -> void:
	if playing and not scrubber_dragging:
		yaw_degrees = wrapf(yaw_degrees + delta * 8.0, -180.0, 180.0)
		playback_progress = fposmod(playback_progress + delta / 45.0, 1.0)
		progress_slider.set_value_no_signal(playback_progress * 100.0)
		_update_scrubber_thumb()
		# The autoplay orbit moves 8 degrees a second; re-rendering the 360k-triangle scan every
		# other frame is invisible at that speed and halves the 3D cost while other windows work.
		_spin_frame += 1
		_update_camera(_spin_frame % 2 == 0)
	_step_control_motion(delta)

func _build_surface() -> void:
	var base := _add_source_component("background", Rect2(Vector2.ZERO, CANVAS_SIZE), TextureRect.STRETCH_SCALE)
	var material := ShaderMaterial.new()
	material.shader = load("res://modules/sculpture_viewer/shaders/player_base.gdshader")
	base.material = material

func _add_source_component(asset_id: String, rect: Rect2, stretch_mode := TextureRect.STRETCH_KEEP) -> TextureRect:
	var texture := TextureRect.new()
	texture.name = "visual-%s" % asset_id
	texture.position = rect.position
	texture.size = rect.size
	texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture.stretch_mode = stretch_mode
	texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var path: String = SOURCE_ASSET_PATHS[asset_id]
	if ResourceLoader.exists(path):
		texture.texture = load(path)
		source_components_loaded.append(asset_id)
	visual_components[asset_id] = texture
	add_child(texture)
	return texture

func _build_3d_viewport() -> void:
	viewport_container = SubViewportContainer.new()
	viewport_container.name = "viewport"
	viewport_container.position = Vector2(134, 78)
	viewport_container.size = Vector2(529, 486)
	viewport_container.stretch = true
	viewport_container.focus_mode = Control.FOCUS_ALL
	viewport_container.mouse_default_cursor_shape = Control.CURSOR_DRAG
	viewport_container.gui_input.connect(_on_viewport_input)
	add_child(viewport_container)

	var viewport := SubViewport.new()
	viewport.name = "render-surface"
	viewport.size = Vector2i(529, 486)
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE # re-armed on every camera change
	viewport.handle_input_locally = false
	viewport_container.add_child(viewport)

	environment = Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#f8f8fa")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#d9e1e7")
	environment.ambient_light_energy = 0.82
	var world_environment := WorldEnvironment.new()
	world_environment.environment = environment
	viewport.add_child(world_environment)

	var key_light := DirectionalLight3D.new()
	key_light.name = "key-light"
	key_light.light_color = Color("#ffffff")
	key_light.light_energy = 1.15
	key_light.rotation_degrees = Vector3(-42, -28, 0)
	key_light.shadow_enabled = true
	# One orthogonal shadow pass instead of the default cascades: the scan is a single small
	# object, and each cascade re-submits its 120k triangles.
	key_light.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	viewport.add_child(key_light)

	var fill_light := OmniLight3D.new()
	fill_light.name = "fill-light"
	fill_light.position = Vector3(-3.5, 2.5, 4.0)
	fill_light.light_color = Color("#dcebf4")
	fill_light.light_energy = 0.52
	fill_light.omni_range = 10.0
	viewport.add_child(fill_light)

	var sculpture := Node3D.new()
	sculpture.name = "sculpture-model"
	sculpture.rotation_degrees.y = -144.0
	viewport.add_child(sculpture)
	_load_proton_model(sculpture)

	var floor_mesh := PlaneMesh.new()
	floor_mesh.size = Vector2(7.0, 7.0)
	var floor := MeshInstance3D.new()
	floor.name = "studio-floor"
	floor.mesh = floor_mesh
	var floor_material := StandardMaterial3D.new()
	floor_material.albedo_color = Color("#f7f7f9")
	floor_material.roughness = 0.9
	floor.material_override = floor_material
	viewport.add_child(floor)

	camera = Camera3D.new()
	camera.name = "orbit-camera"
	camera.fov = 36.0
	viewport.add_child(camera)

func _load_proton_model(root: Node3D) -> void:
	if not ResourceLoader.exists(MODEL_PATH):
		push_error("Verified Proton-derived model is missing: %s" % MODEL_PATH)
		return
	var packed := load(MODEL_PATH) as PackedScene
	if packed == null:
		push_error("Verified Proton-derived model could not be loaded")
		return
	var model := packed.instantiate()
	model.name = "proton-buddha-3124123123"
	root.add_child(model)
	var gold_texture := load(MODEL_TEXTURE_PATH) as Texture2D
	if gold_texture == null:
		push_error("Verified gold texture beside the Proton OBJ is missing: %s" % MODEL_TEXTURE_PATH)
		return
	var gold := StandardMaterial3D.new()
	gold.albedo_texture = gold_texture
	gold.albedo_color = Color.WHITE
	gold.metallic = 0.32
	gold.metallic_specular = 0.64
	gold.roughness = 0.38
	_apply_model_material(model, gold)
	model_texture_loaded = true
	model_loaded = true

func _apply_model_material(node: Node, material: StandardMaterial3D) -> void:
	if node is MeshInstance3D:
		(node as MeshInstance3D).material_override = material
	for child in node.get_children():
		_apply_model_material(child, material)

func _build_navigation() -> void:
	_add_control_visual("previous", Rect2(0, 225, 122, 168))
	_add_control_visual("next", Rect2(678, 225, 122, 168))
	previous_button = _make_button("previous", "", Rect2(0, 225, 134, 168))
	previous_button.tooltip_text = "Previous view"
	previous_button.pressed.connect(func(): _rotate_by(-30.0))
	next_button = _make_button("next", "", Rect2(663, 225, 137, 168))
	next_button.tooltip_text = "Next view"
	next_button.pressed.connect(func(): _rotate_by(30.0))

func _build_transport() -> void:
	_add_control_visual("play-pause", Rect2(36, 591, 48, 40))
	_add_control_visual("audio", Rect2(579, 591, 54, 40))
	_add_control_visual("menu", Rect2(639, 591, 122, 40))

	play_button = _make_button("play-pause", "", Rect2(35, TRANSPORT_Y, 58, 46))
	play_button.tooltip_text = "Play or pause auto-rotation"
	play_button.pressed.connect(_toggle_playback)

	var track := TextureRect.new()
	track.position = Vector2(106, 602)
	track.size = Vector2(342, 20)
	track.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	track.texture = load("res://modules/sculpture_viewer/assets/control-motion/track-empty.png")
	track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var rail_material := ShaderMaterial.new()
	rail_material.shader = load("res://modules/sculpture_viewer/shaders/control_face.gdshader")
	rail_material.set_shader_parameter("frame_size", Vector2(350, 46))
	rail_material.set_shader_parameter("display_size", track.size)
	rail_material.set_shader_parameter("inset", Vector4(0, 8, 0, 16))
	rail_material.set_shader_parameter("face_kind", 2)
	rail_material.set_shader_parameter("fill_texture", load("res://modules/sculpture_viewer/assets/control-motion/track-fill.png"))
	track.material = rail_material
	add_child(track)
	scrubber_fill = track

	progress_slider = HSlider.new()
	progress_slider.name = "scrubber"
	progress_slider.position = Vector2(106, TRANSPORT_Y)
	progress_slider.size = Vector2(350, 46)
	progress_slider.min_value = 0.0
	progress_slider.max_value = 100.0
	progress_slider.value = playback_progress * 100.0
	progress_slider.step = 0.1
	progress_slider.tooltip_text = "Rotate through the complete view"
	progress_slider.value_changed.connect(_set_progress)
	progress_slider.drag_started.connect(_on_scrubber_drag_started)
	progress_slider.drag_ended.connect(_on_scrubber_drag_ended)
	progress_slider.mouse_entered.connect(func(): _on_control_hover_changed("scrubber", true))
	progress_slider.mouse_exited.connect(func(): _on_control_hover_changed("scrubber", false))
	progress_slider.add_theme_icon_override("grabber", _slider_thumb(Color(1, 1, 1, 0)))
	progress_slider.add_theme_icon_override("grabber_highlight", _slider_thumb(Color(1, 1, 1, 0)))
	progress_slider.add_theme_stylebox_override("slider", _style(Color(1, 1, 1, 0), Color(1, 1, 1, 0), 0, 0))
	progress_slider.add_theme_stylebox_override("grabber_area", _style(Color(1, 1, 1, 0), Color(1, 1, 1, 0), 0, 0))
	add_child(progress_slider)

	scrubber_thumb = _add_control_visual("scrubber", Rect2(138, TRANSPORT_Y + 6, 34, 34))

	var timer_visual := TextureRect.new()
	timer_visual.name = "visual-timer-source"
	timer_visual.position = Vector2(472, 595)
	timer_visual.size = Vector2(94, 31)
	timer_visual.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	timer_visual.stretch_mode = TextureRect.STRETCH_SCALE
	timer_visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	timer_visual.texture = load("res://modules/sculpture_viewer/assets/clean-ui/timer-source.png")
	var timer_material := ShaderMaterial.new()
	timer_material.shader = load("res://modules/sculpture_viewer/shaders/control_face.gdshader")
	timer_material.set_shader_parameter("frame_size", Vector2(109, 46))
	timer_material.set_shader_parameter("display_size", timer_visual.size)
	timer_material.set_shader_parameter("inset", Vector4(6, 3, 9, 12))
	timer_material.set_shader_parameter("corner_radius", 15.0)
	timer_visual.material = timer_material
	add_child(timer_visual)

	timer_label = Label.new()
	timer_label.name = "timer"
	timer_label.text = "04:21"
	timer_label.position = Vector2(466, TRANSPORT_Y)
	timer_label.size = Vector2(109, 46)
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	timer_label.modulate = Color(1, 1, 1, 0)
	timer_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(timer_label)

	audio_button = _make_button("audio", "", Rect2(575, TRANSPORT_Y, 63, 46))
	audio_button.tooltip_text = "Mute or unmute"
	audio_button.pressed.connect(_toggle_mute)

	menu_button = _make_button("menu", "", Rect2(638, TRANSPORT_Y, 115, 46))
	menu_button.tooltip_text = "Open viewer menu"
	menu_button.pressed.connect(_toggle_menu)
	menu_button.add_theme_font_size_override("font_size", 22)
	menu_button.add_theme_color_override("font_color", Color("#4e575d"))
	menu_button.add_theme_color_override("font_hover_color", Color("#35434c"))
	menu_button.add_theme_color_override("font_pressed_color", Color("#26333b"))

func _build_menu() -> void:
	menu_panel = PanelContainer.new()
	menu_panel.name = "menu-panel"
	menu_panel.position = Vector2.ZERO
	menu_panel.size = Vector2.ZERO
	menu_panel.visible = false
	menu_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(menu_panel)

func _add_control_visual(control_id: String, rect: Rect2) -> TextureRect:
	var texture := TextureRect.new()
	texture.name = "visual-%s" % control_id
	texture.position = rect.position
	texture.size = rect.size
	texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture.stretch_mode = TextureRect.STRETCH_SCALE
	texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture.pivot_offset = texture.size * 0.5
	if control_id != "scrubber":
		var material := ShaderMaterial.new()
		material.shader = load("res://modules/sculpture_viewer/shaders/control_face.gdshader")
		material.set_shader_parameter("frame_size", MOTION_SIZES[control_id])
		material.set_shader_parameter("display_size", rect.size)
		if control_id in ["previous", "next"]:
			material.set_shader_parameter("face_kind", 1)
			material.set_shader_parameter("circle_center_x", 34.0 if control_id == "previous" else 88.0)
		else:
			# Complete generated buttons, excluding donor gutters and neighbours.
			material.set_shader_parameter("inset", Vector4(0, 0, 0, 6) if control_id == "menu" else Vector4(0, 0, 9, 0))
		texture.material = material
	visual_components[control_id] = texture
	control_hovered[control_id] = false
	control_feedback_active[control_id] = false
	add_child(texture)
	_refresh_control_visual(control_id)
	return texture

func _make_button(node_name: String, copy: String, rect: Rect2) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = copy
	button.position = rect.position
	button.size = rect.size
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_stylebox_override("normal", _style(Color(1, 1, 1, 0), Color(1, 1, 1, 0), 0, 0))
	button.add_theme_stylebox_override("hover", _style(Color(1, 1, 1, 0), Color(1, 1, 1, 0), 0, 0))
	button.add_theme_stylebox_override("pressed", _style(Color(1, 1, 1, 0), Color(1, 1, 1, 0), 0, 0))
	button.add_theme_color_override("font_color", Color(1, 1, 1, 0))
	button.mouse_entered.connect(func(): _on_control_hover_changed(node_name, true))
	button.mouse_exited.connect(func(): _on_control_hover_changed(node_name, false))
	button.button_down.connect(func(): _on_control_button_down(node_name))
	button.button_up.connect(func(): _on_control_button_up(node_name))
	button.add_theme_stylebox_override("focus", _style(Color.TRANSPARENT, Color("#7094ac"), 1, 3))
	add_child(button)
	return button

func _set_control_visual_state(control_id: String, state_name: String) -> void:
	control_visual_states[control_id] = state_name
	motion_targets[control_id] = {"idle": 0.0, "hover": MOTION_HOVER, "active": MOTION_PRESS}[state_name]
	_show_motion_frame(control_id)

func _load_motion_assets() -> void:
	for control_id in MOTION_SIZES:
		var path := "res://modules/sculpture_viewer/assets/control-motion/%s.png" % control_id
		if not ResourceLoader.exists(path):
			push_error("Missing generated control motion: %s" % path)
			continue
		var atlas := AtlasTexture.new()
		atlas.atlas = load(path)
		atlas.filter_clip = true
		motion_textures[control_id] = atlas
		motion_phase[control_id] = 0.0
		motion_frames[control_id] = 0
		motion_targets[control_id] = 0.0

func _show_motion_frame(control_id: String) -> void:
	var visual := visual_components.get(control_id) as TextureRect
	var atlas := motion_textures.get(control_id) as AtlasTexture
	if visual == null or atlas == null:
		return
	var frame := clampi(roundi(float(motion_phase.get(control_id, 0.0))), 0, int(MOTION_END))
	var frame_size: Vector2 = MOTION_SIZES[control_id]
	atlas.region = Rect2(Vector2(frame % 8, frame / 8) * frame_size, frame_size)
	if visual.material is ShaderMaterial:
		visual.material.set_shader_parameter("frame_origin", atlas.region.position)
		if control_id in ["play-pause", "audio"]:
			# The take moves these faces down 5 source pixels during depression.
			# Register the complete face, excluding the matte below the idle frame.
			var depression := clampf((frame - 6.0) / 8.0, 0.0, 1.0) if frame <= 14 else (23.0 - frame) / 9.0
			visual.material.set_shader_parameter("inset", Vector4(0, 5.0 * depression, 9, 7.0 * (1.0 - depression)))
	visual.texture = atlas
	motion_frames[control_id] = frame

func _step_control_motion(delta: float) -> void:
	for control_id in motion_textures:
		var phase: float = motion_phase[control_id]
		var releasing: bool = control_feedback_active.get(control_id, false)
		var target: float = MOTION_END if releasing else motion_targets[control_id]
		var speed := 50.0 if releasing else 100.0
		motion_phase[control_id] = move_toward(phase, target, delta * speed)
		if releasing and is_equal_approx(motion_phase[control_id], MOTION_END):
			control_feedback_active[control_id] = false
			motion_phase[control_id] = 0.0
			_refresh_control_visual(control_id)
		_show_motion_frame(control_id)

func _control_is_toggled(control_id: String) -> bool:
	match control_id:
		"play-pause": return playing
		"audio": return muted
		"menu": return menu_open
	return false

func _refresh_control_visual(control_id: String) -> void:
	var visual := visual_components.get(control_id) as TextureRect
	if visual == null:
		return
	if control_feedback_active.get(control_id, false):
		return
	if control_pressed.get(control_id, false) or _control_is_toggled(control_id):
		_set_control_visual_state(control_id, "active")
	elif control_hovered.get(control_id, false):
		_set_control_visual_state(control_id, "hover")
	else:
		_set_control_visual_state(control_id, "idle")

func _on_control_hover_changed(control_id: String, hovered: bool) -> void:
	control_hovered[control_id] = hovered
	if not control_feedback_active.get(control_id, false):
		_refresh_control_visual(control_id)

func _on_control_button_down(control_id: String) -> void:
	control_pressed[control_id] = true
	control_feedback_active[control_id] = false
	if float(motion_phase.get(control_id, 0.0)) > MOTION_PRESS:
		motion_phase[control_id] = 0.0
	_set_control_visual_state(control_id, "active")

func _on_control_button_up(control_id: String) -> void:
	control_pressed[control_id] = false
	_animate_control(control_id)

func _on_scrubber_drag_started() -> void:
	scrubber_dragging = true
	_on_control_button_down("scrubber")

func _on_scrubber_drag_ended(_value_changed: bool) -> void:
	scrubber_dragging = false
	_on_control_button_up("scrubber")

func _style(background: Color, border_color: Color, border_width: int, radius: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = background
	box.border_color = border_color
	box.set_border_width_all(border_width)
	box.set_corner_radius_all(radius)
	box.content_margin_left = 6
	box.content_margin_right = 6
	box.content_margin_top = 4
	box.content_margin_bottom = 4
	return box

func _slider_thumb(color: Color) -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([color, color])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 34
	texture.height = 34
	return texture

func _on_viewport_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging_viewport = event.pressed
			last_pointer_position = event.position
			if event.double_click:
				_reset_view()
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_by(-0.45)
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_by(0.45)
	elif event is InputEventMouseMotion and dragging_viewport:
		var pointer_delta: Vector2 = event.position - last_pointer_position
		last_pointer_position = event.position
		yaw_degrees = wrapf(yaw_degrees - pointer_delta.x * 0.35, -180.0, 180.0)
		pitch_degrees = clampf(pitch_degrees - pointer_delta.y * 0.25, -55.0, 45.0)
		playback_progress = fposmod((yaw_degrees + 180.0) / 360.0, 1.0)
		progress_slider.set_value_no_signal(playback_progress * 100.0)
		_update_scrubber_thumb()
		interaction_count += 1
		_update_camera()

func _rotate_by(amount: float) -> void:
	_animate_control("next" if amount > 0.0 else "previous")
	yaw_degrees = wrapf(yaw_degrees + amount, -180.0, 180.0)
	active_view = posmod(active_view + (1 if amount > 0.0 else -1), 12)
	playback_progress = fposmod((yaw_degrees + 180.0) / 360.0, 1.0)
	progress_slider.set_value_no_signal(playback_progress * 100.0)
	_update_scrubber_thumb()
	interaction_count += 1
	_update_camera()

func _zoom_by(amount: float) -> void:
	camera_distance = clampf(camera_distance + amount, 2.8, 10.5)
	interaction_count += 1
	_update_camera()

func _set_progress(value: float) -> void:
	playback_progress = clampf(value / 100.0, 0.0, 1.0)
	yaw_degrees = playback_progress * 360.0 - 180.0
	interaction_count += 1
	_update_scrubber_thumb()
	_update_camera()

func _toggle_playback() -> void:
	playing = not playing
	_animate_control("play-pause")
	_refresh_control_visual("play-pause")
	interaction_count += 1

func _toggle_mute() -> void:
	muted = not muted
	_animate_control("audio")
	_refresh_control_visual("audio")
	interaction_count += 1

func _toggle_menu() -> void:
	_animate_control("menu")
	menu_open = false
	menu_overlay_visible = false
	if menu_panel != null:
		menu_panel.visible = false
	grab_focus()
	interaction_count += 1

func _animate_control(control_id: String) -> void:
	last_animated_control = control_id
	animation_count += 1
	control_feedback_active[control_id] = not _control_is_toggled(control_id)
	motion_phase[control_id] = MOTION_PRESS
	_set_control_visual_state(control_id, "active")

func _reset_view() -> void:
	yaw_degrees = DEFAULT_YAW
	pitch_degrees = DEFAULT_PITCH
	camera_distance = DEFAULT_DISTANCE
	playback_progress = fposmod((yaw_degrees + 180.0) / 360.0, 1.0)
	progress_slider.set_value_no_signal(playback_progress * 100.0)
	_update_scrubber_thumb()
	active_view = 0
	menu_open = false
	menu_overlay_visible = false
	if menu_panel != null:
		menu_panel.visible = false
	_refresh_control_visual("menu")
	interaction_count += 1
	_update_camera()

func _update_scrubber_thumb() -> void:
	if scrubber_thumb == null:
		return
	scrubber_thumb.position.x = 106.0 + playback_progress * 316.0
	if scrubber_fill != null:
		scrubber_fill.material.set_shader_parameter("fill_width", scrubber_thumb.position.x - 106.0 + 17.0)

func _update_camera(rerender := true) -> void:
	if camera == null:
		return
	var yaw := deg_to_rad(yaw_degrees)
	var pitch := deg_to_rad(pitch_degrees)
	var offset := Vector3(
		sin(yaw) * cos(pitch),
		sin(pitch),
		cos(yaw) * cos(pitch)
	) * camera_distance
	camera.position = CAMERA_TARGET + offset
	camera.look_at(CAMERA_TARGET)
	var viewport := camera.get_viewport()
	if rerender and viewport is SubViewport:
		viewport.render_target_update_mode = SubViewport.UPDATE_ONCE

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match event.keycode:
		KEY_LEFT: _rotate_by(-30.0)
		KEY_RIGHT: _rotate_by(30.0)
		KEY_UP: _zoom_by(-0.45)
		KEY_DOWN: _zoom_by(0.45)
		KEY_SPACE: _toggle_playback()
		KEY_M: _toggle_mute()
		KEY_HOME: _reset_view()
		KEY_ESCAPE:
			if menu_open: _toggle_menu()

func qa_state() -> Dictionary:
	return {
		"model_loaded": model_loaded,
		"yaw": snappedf(yaw_degrees, 0.01),
		"pitch": snappedf(pitch_degrees, 0.01),
		"distance": snappedf(camera_distance, 0.01),
		"progress": snappedf(playback_progress, 0.001),
		"active_view": active_view,
		"playing": playing,
		"muted": muted,
		"interaction_count": interaction_count,
		"animation_count": animation_count,
		"last_animated_control": last_animated_control,
	}
