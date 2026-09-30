## The Fly Through video player: the Video Player Tab's Tenant and its desktop. One draggable
## viewer window (the owner's Fly Through v7 screenshot as chrome, its controls cut from the
## same pixels, Muse / Seedance frames for hover, pressed and settled) on a white ground. Reach
## it through interface.gd only.
##
## Ported from this repository's branch Reid-Surmeier/issue-20-video-player-usability @ f2097ff,
## prototypes/video-player-usability/main.gd. Left behind: the A/B/C variant remnants, the
## hidden state strip, the command-line capture and reference-check paths, the JavaScriptBridge
## publishes (now state()), the unused thumbnails/ files. Changed for the Page seam (#24, #31):
## the viewer is scaled to fit the Page and centred, again on every resize (#63; the prototype scaled its whole
## window the same way, 1536x1632 shown at 768x816); fullscreen fills the Page instead of the
## OS window; the video pauses while the Page is hidden and resumes on show; the rendering is
## linear-filtered as the prototype's project was; the media are the checked-in 480-wide
## previews under media/. Everything else — layout, pixels, motion, keys, drag, clamp — is the
## prototype's.
extends Control

const Errors := preload("res://modules/video_player/errors.gd")

const ROOT := "res://modules/video_player/"
# the owner's plate; controls keep their canvas coordinates
const CANVAS_SIZE := Vector2(1536, 1632)
## The plate's two windows (#63), cut with their own chrome and shadow: Fly Through (the video) and
## Information (transport, title, Save, tiles). The Information window grows in height by one
## plain white row of its body (INFO_STRETCH_Y); Fly Through grows both ways by its straight frame
## runs, the video letterboxed in header grey at the plate's aspect.
const FLY_RECT := Rect2(64, 54, 1406, 802)
const INFO_RECT := Rect2(282, 888, 938, 658)
const INFO_STRETCH_Y := 1100.0
const MARGIN := 24.0  # native px around the pair
const GAP := 32.0  # native px between the windows, as on the plate
const VIDEO_RECT := Rect2(82, 106, 1366, 732)  # the video inside the viewer, canvas px
const VIDEOS := [
	{"id": "1191767929", "title": "The Observer"},
	{"id": "1187745268", "title": "Inside the Exhibition: Indigenous Artists Honor the Seal"},
	{"id": "1014865523", "title": "A Look Into Our Collection’s Polaroids by Andy Warhol"},
	{"id": "1009870521", "title": "The Making of Wallpaper"},
	{"id": "1008943970", "title": "Short Cuts: Sháńdíín Sháńdíín on Diné Textiles"},
]
## On the Web build the five videos are not in the game pack (they were ~29 MB of the first load):
## scripts/export-web.sh puts them beside the page under media/, and each is downloaded into
## WEB_MEDIA_DIR the first time its tile is picked, under the loading dots (loading.gdshader).
const WEB_MEDIA_DIR := "user://video_player/"
const STATE_TEXTURES := {
	"idle": ROOT + "assets/muse-controls/idle.png",
	"hover": ROOT + "assets/muse-controls/hover.png",
	"pressed": ROOT + "assets/muse-controls/pressed.png",
	"settled": ROOT + "assets/muse-controls/settled.png",
}

var key := ""
var ticks := 0
var selected_video := 0
var muted := false
var fullscreen := false
var hidden_paused := false
var dragging_seek := false
var drag_intent_count := 0
var dragging_viewer := false
var drag_pointer_start := Vector2.ZERO
var drag_surface_start := Vector2.ZERO
var dragged_window: Control
var dragged_handle: Control
var arrangement := "side"
var info_extra := 0.0
var interaction_count := 0
var last_action := "ready"
var viewer_scale := 1.0

var background: ColorRect
var surface: Control  # the Fly Through window
var plate_texture: Texture2D
var fly_chrome: Control
var fly_body: ColorRect
var info: Control  # the Information window
var info_chrome: Control
var info_top: Control
var info_bottom: Control
var info_drag: Control
var video: VideoStreamPlayer
var movie_fit: AspectRatioContainer
var movie_image: TextureRect
var movie_letterbox: ColorRect
var transport: Control
var play_button: TextureButton
var mute_button: TextureButton
var fullscreen_button: TextureButton
var expand_button: TextureButton
var seek: HSlider
var timer_label: Label
var title_label: Label
var title_drag: Control
var thumbnail_buttons: Array[TextureButton] = []
var thumbnail_frames: Array[Panel] = []
var textures := {}
var source_faces := {}
var model_frames := {}
var active_motion := {}
var motion_play_count := 0
var volume: HSlider
var save_button: TextureButton
var saved := {}
var fetch: HTTPRequest
var fetching_id := ""
var loading_overlay: ColorRect


static func create(deps: Dictionary) -> Dictionary:
	for v in VIDEOS:
		if not OS.has_feature("web") and not FileAccess.file_exists(ROOT + "media/%s.ogv" % v.id):
			return Errors.err(Errors.MEDIA_MISSING, ROOT + "media/%s.ogv" % v.id)
	# an imported texture: only its .ctex is in an export
	if not ResourceLoader.exists(ROOT + "assets/fly-through-v7.png"):
		return Errors.err(Errors.ASSET_MISSING, ROOT + "assets/fly-through-v7.png")
	for path in [
		"assets/source-controls/manifest.json",
		"assets/seedance-motion/manifest.json",
		"assets/fonts/LiberationSans-Regular.bytes",
		"assets/fonts/LiberationSans-Bold.bytes"
	]:  # raw files, exported by the include filter
		if not FileAccess.file_exists(ROOT + path):
			return Errors.err(Errors.ASSET_MISSING, ROOT + path)
	var t = load(ROOT + "video_player.gd").new()
	t.key = deps.get("key", "")
	t.name = "VideoPlayer"
	t.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return Errors.ok(t)


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR  # the prototype's project default
	for state in STATE_TEXTURES:
		textures[state] = load(STATE_TEXTURES[state])
	_load_source_controls()
	_build_surface()
	_build_transport()
	_build_thumbnails()
	_apply_layout()
	_fit_viewer()
	resized.connect(_fit_viewer)
	visibility_changed.connect(_on_visibility_changed)
	_select_video(0)


func _process(delta: float) -> void:
	ticks += 1
	_advance_motion(delta)
	if fetching_id != "" and fetch.get_body_size() > 0:
		loading_overlay.material.set_shader_parameter(
			"progress", float(fetch.get_downloaded_bytes()) / fetch.get_body_size()
		)
	if video.stream != null and video.is_playing() and not video.paused and not dragging_seek:
		var length := video.get_stream_length()
		if length > 0.0:
			seek.set_value_no_signal(video.stream_position / length * 100.0)
	_update_timer()


func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	match event.keycode:
		KEY_SPACE:
			_toggle_play_pause()
		KEY_M:
			_toggle_mute()
		KEY_F:
			_toggle_fullscreen()
		KEY_LEFT:
			_seek_seconds(-5.0)
		KEY_RIGHT:
			_seek_seconds(5.0)
		KEY_1, KEY_2, KEY_3, KEY_4, KEY_5:
			_select_video(event.keycode - KEY_1)


## The Page seam: the Shell hides the Page and freezes it. Pause the video on hide; resume on
## show if it was playing.
func _on_visibility_changed() -> void:
	if video == null:
		return
	if not is_visible_in_tree():
		hidden_paused = video.is_playing() and not video.paused
		if hidden_paused:
			video.paused = true
			last_action = "paused by hide"
	elif hidden_paused:
		hidden_paused = false
		video.paused = false
		last_action = "resumed on show"


## The pair fills the Page (#63): one uniform scale for the plate's pixels, the larger of the two
## arrangements — side by side (Fly Through left, Information right) or stacked (Fly Through over
## Information, centred) — each with MARGIN around and GAP between, in native px. The leftover
## goes to the windows: side by side both run to the page's top and bottom margins (Fly Through
## also takes any spare width); stacked, Fly Through takes the spare width and height. Every resize
## lays the pair out again, a dragged window included.
func _fit_viewer() -> void:
	dragging_viewer = false
	var side := (
		Vector2(FLY_RECT.size.x + GAP + INFO_RECT.size.x, FLY_RECT.size.y)
		+ Vector2.ONE * 2.0 * MARGIN
	)
	var stack := (
		Vector2(FLY_RECT.size.x, FLY_RECT.size.y + GAP + INFO_RECT.size.y)
		+ Vector2.ONE * 2.0 * MARGIN
	)
	var s_side := minf(size.x / side.x, size.y / side.y)
	var s_stack := minf(size.x / stack.x, size.y / stack.y)
	arrangement = "side" if s_side >= s_stack else "stacked"
	viewer_scale = maxf(s_side, s_stack)
	if viewer_scale <= 0.0:
		return
	var u := size / viewer_scale  # the Page in native px
	var fly_size: Vector2
	var info_at: Vector2
	if arrangement == "side":
		fly_size = Vector2(u.x - 2.0 * MARGIN - GAP - INFO_RECT.size.x, u.y - 2.0 * MARGIN)
		info_at = Vector2(u.x - MARGIN - INFO_RECT.size.x, MARGIN)
		info_extra = u.y - 2.0 * MARGIN - INFO_RECT.size.y
	else:
		fly_size = Vector2(u.x - 2.0 * MARGIN, u.y - 2.0 * MARGIN - GAP - INFO_RECT.size.y)
		info_at = Vector2((u.x - INFO_RECT.size.x) / 2.0, u.y - MARGIN - INFO_RECT.size.y)
		info_extra = 0.0
	for window in [surface, info]:
		window.scale = Vector2(viewer_scale, viewer_scale)
	surface.position = Vector2(MARGIN, MARGIN) * viewer_scale
	surface.size = fly_size.max(FLY_RECT.size)
	info.position = info_at * viewer_scale
	info.size = Vector2(INFO_RECT.size.x, INFO_RECT.size.y + maxf(0.0, info_extra))
	info_bottom.position = -INFO_RECT.position + Vector2(0, maxf(0.0, info_extra))
	_layout_windows()
	if fullscreen:
		_fill_page()


## Everything inside the two windows that depends on their sizes, in native px.
func _layout_windows() -> void:
	var w := surface.size.x
	var h := surface.size.y
	fly_chrome.size = surface.size
	fly_body.position = Vector2(18, 52)
	fly_body.size = Vector2(w - 40, h - 70)
	if not fullscreen:
		var k := minf(fly_body.size.x / VIDEO_RECT.size.x, fly_body.size.y / VIDEO_RECT.size.y)
		video.size = VIDEO_RECT.size * k
		video.position = fly_body.position + (fly_body.size - video.size) / 2.0
	title_drag.position = Vector2(18, 1)
	title_drag.size = Vector2(w - 81, 50)
	expand_button.position = Vector2(w - 52, 9)
	expand_button.size = Vector2(32, 35)
	info_chrome.size = info.size
	fly_chrome.queue_redraw()
	info_chrome.queue_redraw()


func _patch(canvas: Control, source: Rect2, destination: Rect2) -> void:
	if destination.size.x > 0 and destination.size.y > 0:
		canvas.draw_texture_rect_region(plate_texture, destination, source)


## The Fly Through chrome from the plate: fixed corners, caps and title lettering; only straight
## runs of the frame stretch (the title stays where it sits on the plate, the spare width split
## either side of it).
func _draw_fly_chrome() -> void:
	var w := surface.size.x
	var h := surface.size.y
	var extra := w - FLY_RECT.size.x
	var run1 := 440.0 + floorf(extra / 2.0)
	var run2 := 540.0 + extra - floorf(extra / 2.0)
	var c := fly_chrome
	_patch(c, Rect2(64, 54, 136, 52), Rect2(0, 0, 136, 52))
	_patch(c, Rect2(200, 54, 440, 52), Rect2(136, 0, run1, 52))
	_patch(c, Rect2(640, 54, 220, 52), Rect2(136 + run1, 0, 220, 52))
	_patch(c, Rect2(860, 54, 540, 52), Rect2(356 + run1, 0, run2, 52))
	_patch(c, Rect2(1400, 54, 70, 52), Rect2(w - 70, 0, 70, 52))
	_patch(c, Rect2(64, 106, 18, 732), Rect2(0, 52, 18, h - 70))
	_patch(c, Rect2(1448, 106, 22, 732), Rect2(w - 22, 52, 22, h - 70))
	_patch(c, Rect2(64, 838, 136, 18), Rect2(0, h - 18, 136, 18))
	_patch(c, Rect2(200, 838, 1200, 18), Rect2(136, h - 18, w - 206, 18))
	_patch(c, Rect2(1400, 838, 70, 18), Rect2(w - 70, h - 18, 70, 18))


## The Information chrome from the plate: its top (title and transport bar) and bottom (title,
## Save, tiles) fixed, one plain white row of the body stretched between them.
func _draw_info_chrome() -> void:
	var top := INFO_STRETCH_Y - INFO_RECT.position.y
	var bottom := INFO_RECT.end.y - INFO_STRETCH_Y - 10.0
	_patch(
		info_chrome,
		Rect2(INFO_RECT.position, Vector2(INFO_RECT.size.x, top)),
		Rect2(0, 0, INFO_RECT.size.x, top)
	)
	_patch(
		info_chrome,
		Rect2(INFO_RECT.position.x, INFO_STRETCH_Y, INFO_RECT.size.x, 10),
		Rect2(0, top, INFO_RECT.size.x, 10 + info_extra)
	)
	_patch(
		info_chrome,
		Rect2(INFO_RECT.position.x, INFO_STRETCH_Y + 10, INFO_RECT.size.x, bottom),
		Rect2(0, info.size.y - bottom, INFO_RECT.size.x, bottom)
	)


func _build_surface() -> void:
	background = ColorRect.new()
	background.name = "ground"
	background.color = Color.WHITE
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	plate_texture = load(ROOT + "assets/fly-through-v7.png")

	surface = Control.new()
	surface.name = "fly-through-window"
	surface.size = FLY_RECT.size
	add_child(surface)
	fly_chrome = Control.new()
	fly_chrome.name = "chrome"
	fly_chrome.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fly_chrome.draw.connect(_draw_fly_chrome)
	surface.add_child(fly_chrome)
	fly_body = ColorRect.new()
	fly_body.name = "letterbox"
	fly_body.color = Color("#f0f0f0")  # Header midtone sampled from fly-through-v7.png (#83).
	fly_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	surface.add_child(fly_body)

	info = Control.new()
	info.name = "information-window"
	info.size = INFO_RECT.size
	add_child(info)
	info_chrome = Control.new()
	info_chrome.name = "chrome"
	info_chrome.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_chrome.draw.connect(_draw_info_chrome)
	info.add_child(info_chrome)
	for part in ["top", "bottom"]:  # plate-coordinate layers: the bottom one moves down by the stretch
		var layer := Control.new()
		layer.name = "plate-" + part
		layer.position = -INFO_RECT.position
		layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		info.add_child(layer)
		if part == "top":
			info_top = layer
		else:
			info_bottom = layer
	info_drag = Control.new()
	info_drag.name = "information-drag-handle"
	info_drag.tooltip_text = "Drag to move the information window; focus and use arrow keys to move"
	info_drag.focus_mode = Control.FOCUS_ALL
	info_drag.mouse_default_cursor_shape = Control.CURSOR_MOVE
	info_drag.position = Vector2(10, 4)
	info_drag.size = Vector2(918, 48)
	info.add_child(info_drag)

	var info_clear := ColorRect.new()
	info_clear.name = "reference-information-clear"
	info_clear.color = Color.WHITE
	info_clear.position = Vector2(408, 1298)
	info_clear.size = Vector2(614, 32)
	info_clear.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_bottom.add_child(info_clear)

	video = VideoStreamPlayer.new()
	video.name = "video"
	video.expand = true
	video.mouse_filter = Control.MOUSE_FILTER_IGNORE
	video.finished.connect(_on_video_finished)
	surface.add_child(video)
	# Keep the playback/input rect; native container fits the decoded movie inside it (#208).
	video.self_modulate = Color(1, 1, 1, 0)
	movie_letterbox = ColorRect.new()
	movie_letterbox.color = Color("#f0f0f0")
	movie_letterbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	video.add_child(movie_letterbox)
	movie_letterbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	movie_fit = AspectRatioContainer.new()
	movie_fit.mouse_filter = Control.MOUSE_FILTER_IGNORE
	video.add_child(movie_fit)
	movie_fit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	movie_image = TextureRect.new()
	movie_image.name = "movie-image"
	movie_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	movie_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	movie_fit.add_child(movie_image)

	loading_overlay = ColorRect.new()  # the loading dots over the video while it downloads (Web only)
	loading_overlay.name = "video-loading"
	loading_overlay.material = ShaderMaterial.new()
	loading_overlay.material.shader = load(ROOT + "loading.gdshader")
	loading_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	loading_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	loading_overlay.visible = false
	video.add_child(loading_overlay)

	title_label = Label.new()
	title_label.name = "live-title"
	title_label.add_theme_color_override("font_color", Color("#111111"))
	title_label.add_theme_font_size_override("font_size", 26)
	title_label.add_theme_font_override("font", _source_font("Bold"))
	title_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_label.position = Vector2(409, 1298)
	title_label.size = Vector2(611, 32)
	info_bottom.add_child(title_label)

	title_drag = Control.new()
	title_drag.name = "window-drag-handle"
	title_drag.tooltip_text = "Drag to move the viewer; focus and use arrow keys to move"
	title_drag.focus_mode = Control.FOCUS_ALL
	title_drag.mouse_default_cursor_shape = Control.CURSOR_MOVE
	title_drag.gui_input.connect(_on_title_drag_input.bind(surface, title_drag))
	surface.add_child(title_drag)
	info_drag.gui_input.connect(_on_title_drag_input.bind(info, info_drag))


func _build_transport() -> void:
	transport = Control.new()
	transport.name = "transport"
	transport.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transport.size = CANVAS_SIZE
	info_top.add_child(transport)
	for item in [
		["seek-clean", Rect2(424, 981, 29, 31)],
		["volume-clean", Rect2(1035, 975, 23, 38)],
		["timer-clean", Rect2(823, 981, 73, 24)]
	]:
		var picture := TextureRect.new()
		picture.texture = load(ROOT + "assets/source-controls/%s.png" % item[0])
		picture.position = item[1].position
		picture.size = item[1].size
		picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
		transport.add_child(picture)
	play_button = _state_button("play-pause", "Play / pause · Space")
	play_button.pressed.connect(_toggle_play_pause)
	transport.add_child(play_button)
	seek = _source_slider("seek", Rect2(424, 981, 374, 31), 0.0)
	seek.drag_started.connect(func(): dragging_seek = true)
	seek.drag_ended.connect(_on_seek_ended)
	seek.tooltip_text = "Seek through the video · Left / Right"
	timer_label = Label.new()
	timer_label.name = "time"
	timer_label.add_theme_color_override("font_color", Color.WHITE)
	timer_label.add_theme_font_size_override("font_size", 23)
	timer_label.add_theme_font_override("font", _source_font("Regular"))
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	timer_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transport.add_child(timer_label)
	mute_button = _state_button("mute", "Mute / unmute · M")
	mute_button.pressed.connect(_toggle_mute)
	transport.add_child(mute_button)
	fullscreen_button = _state_button("fullscreen", "Fullscreen · F")
	fullscreen_button.pressed.connect(_toggle_fullscreen)
	transport.add_child(fullscreen_button)
	volume = _source_slider("volume", Rect2(941, 975, 117, 38), 100.0)
	volume.tooltip_text = "Volume"
	volume.value_changed.connect(_set_volume)
	save_button = _state_button("save", "Save this video for this session")
	save_button.pressed.connect(_toggle_save)
	save_button.position = Vector2(1028, 1298)
	save_button.size = Vector2(143, 51)
	info_bottom.add_child(save_button)
	expand_button = _state_button("minimize", "Expand / restore the player")
	expand_button.pressed.connect(_toggle_fullscreen)
	surface.add_child(expand_button)


func _build_thumbnails() -> void:
	for index in 8:
		var button := TextureButton.new()
		button.name = "thumbnail-%d" % (index + 1)
		button.focus_mode = Control.FOCUS_NONE
		var original := AtlasTexture.new()
		original.atlas = plate_texture
		original.region = Rect2(306 + index * 111, 1381, 110, 110)
		button.texture_normal = original
		button.texture_disabled = original
		button.ignore_texture_size = true
		button.stretch_mode = TextureButton.STRETCH_SCALE
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.position = Vector2(306 + index * 111, 1381)
		button.size = Vector2(110, 110)
		if index < VIDEOS.size():
			button.tooltip_text = VIDEOS[index].title
			button.pressed.connect(func(): _select_video(index))
			button.mouse_entered.connect(func(): _thumbnail_hover(index, true))
			button.mouse_exited.connect(func(): _thumbnail_hover(index, false))
		else:
			button.disabled = true
			button.mouse_default_cursor_shape = Control.CURSOR_ARROW
			button.tooltip_text = "Original reference artwork; no video supplied for this tile yet"
		info_bottom.add_child(button)
		thumbnail_buttons.append(button)
		var frame := Panel.new()
		frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		button.add_child(frame)
		thumbnail_frames.append(frame)


func _state_button(node_name: String, tooltip: String) -> TextureButton:
	var button := TextureButton.new()
	button.name = node_name
	button.focus_mode = Control.FOCUS_NONE  # keys stay page shortcuts (see MODULE.md)
	button.texture_normal = source_faces[_source_key(node_name)]
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_SCALE
	button.tooltip_text = tooltip
	button.mouse_entered.connect(func(): _animate_button(button, true))
	button.mouse_exited.connect(func(): _animate_button(button, false))
	button.button_down.connect(func(): _press_button(button))
	button.button_up.connect(func(): _start_source_motion(button, "settled"))
	return button


## Layout A, the source-faithful one the owner selected: every control at its source rect.
func _apply_layout() -> void:
	play_button.position = Vector2(325, 969)
	play_button.size = Vector2(95, 49)
	timer_label.position = Vector2(818, 976)
	timer_label.size = Vector2(84, 33)
	mute_button.position = Vector2(1057, 975)
	mute_button.size = Vector2(42, 41)
	fullscreen_button.position = Vector2(1117, 975)
	fullscreen_button.size = Vector2(49, 40)
	_update_thumbnail_frames()


func _select_video(index: int) -> void:
	if index < 0 or index >= VIDEOS.size():
		return
	selected_video = index
	var stream := _video_stream(VIDEOS[selected_video].id)
	video.stop()
	if stream == null and OS.has_feature("web"):
		_fetch_video(VIDEOS[selected_video].id)  # plays from _on_video_fetched once it is here
	elif stream == null:
		push_error("video_player: missing preview video %s" % VIDEOS[selected_video].id)
		return
	else:
		loading_overlay.visible = false
		video.stream = stream
		movie_image.texture = video.get_video_texture()
		if movie_image.texture != null and movie_image.texture.get_height() > 0:
			movie_fit.ratio = movie_image.texture.get_size().aspect()
		video.paused = false
		video.play()
		video.stream_position = 0.0
	hidden_paused = false
	title_label.text = VIDEOS[selected_video].title
	title_label.tooltip_text = VIDEOS[selected_video].title
	play_button.texture_normal = source_faces.pause
	active_motion.erase(play_button)
	save_button.tooltip_text = (
		"Saved for this session"
		if saved.get(selected_video, false)
		else "Save this video for this session"
	)
	last_action = "selected video %d" % (selected_video + 1)
	interaction_count += 1
	_update_thumbnail_frames()


## The video's stream: from the project on desktop, from WEB_MEDIA_DIR on the Web (null until fetched).
func _video_stream(id: String) -> VideoStream:
	if not OS.has_feature("web"):
		return load(ROOT + "media/%s.ogv" % id) as VideoStream
	var path := WEB_MEDIA_DIR + "%s.ogv" % id
	if not FileAccess.file_exists(path):
		return null
	var stream := VideoStreamTheora.new()
	stream.file = path
	return stream


## Download one video from beside the page and write it into WEB_MEDIA_DIR when complete. Picking
## another tile mid-download cancels this one; ponytail: one download at a time, no prefetch.
func _fetch_video(id: String) -> void:
	loading_overlay.visible = true
	loading_overlay.material.set_shader_parameter("progress", 0.0)
	if fetching_id == id:
		return
	if fetch == null:
		fetch = HTTPRequest.new()
		fetch.download_chunk_size = 4 << 20  # the default 64 KB per frame hands a video over slowly
		fetch.name = "video-download"
		fetch.request_completed.connect(_on_video_fetched)
		add_child(fetch)
	fetch.cancel_request()
	fetching_id = id
	var media_url: String = JavaScriptBridge.eval("new URL('media/', document.baseURI).href")
	if fetch.request(media_url + "%s.ogv" % id) != OK:
		_on_video_fetched(
			HTTPRequest.RESULT_CANT_CONNECT, 0, PackedStringArray(), PackedByteArray()
		)


func _on_video_fetched(
	result: int, code: int, _headers: PackedStringArray, body: PackedByteArray
) -> void:
	var id := fetching_id
	fetching_id = ""
	var file: FileAccess = null
	if result == HTTPRequest.RESULT_SUCCESS and code == 200:
		DirAccess.make_dir_recursive_absolute(WEB_MEDIA_DIR)
		file = FileAccess.open(WEB_MEDIA_DIR + "%s.ogv" % id, FileAccess.WRITE)
	if file == null:  # never retried automatically: picking the tile again retries
		push_error(
			(
				"video_player: download of video %s failed (result %d, HTTP %d, write %s)"
				% [id, result, code, FileAccess.get_open_error()]
			)
		)
		loading_overlay.visible = false
		last_action = "video %s failed to download" % id
		return
	file.store_buffer(body)
	file.close()
	if VIDEOS[selected_video].id == id:
		_select_video(selected_video)


func _toggle_play_pause() -> void:
	if not video.is_playing():
		video.play()
	elif video.paused:
		video.paused = false
	else:
		video.paused = true
	hidden_paused = false
	play_button.texture_normal = source_faces[_source_key("play-pause")]
	_start_source_motion(play_button, "settled")
	last_action = "paused" if video.paused else "playing"
	interaction_count += 1


func _toggle_mute() -> void:
	muted = not muted
	video.set_volume(0.0 if muted else volume.value / 100.0)
	mute_button.texture_normal = source_faces[_source_key("mute")]
	_start_source_motion(mute_button, "settled")
	last_action = "muted" if muted else "unmuted"
	interaction_count += 1


## Fullscreen fills the Page (#31), never the OS window: the video leaves the viewer's transform
## (top_level, so it never leaves the tree and keeps playing), covers the Tenant's rect on top
## of everything and takes the pointer so nothing under it is clicked; back restores its place.
func _toggle_fullscreen() -> void:
	fullscreen = not fullscreen
	movie_letterbox.color = Color.BLACK if fullscreen else Color("#f0f0f0")
	if fullscreen:
		surface.move_child(video, -1)
		video.top_level = true
		video.mouse_filter = Control.MOUSE_FILTER_STOP
		_fill_page()
	else:
		video.top_level = false
		surface.move_child(video, fly_body.get_index() + 1)  # back above the letterbox
		video.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_layout_windows()
	_start_source_motion(fullscreen_button, "settled")
	last_action = "fullscreen" if fullscreen else "windowed"
	interaction_count += 1


func _fill_page() -> void:
	video.global_position = global_position
	video.size = size


func _seek_percent(percent: float) -> void:
	var length := video.get_stream_length()
	if length > 0.0:
		video.stream_position = clampf(percent, 0.0, 100.0) / 100.0 * length
		seek.set_value_no_signal(clampf(percent, 0.0, 100.0))
		last_action = "seek %.1f%%" % percent
		interaction_count += 1


func _seek_seconds(delta: float) -> void:
	var length := video.get_stream_length()
	if length > 0.0:
		video.stream_position = clampf(video.stream_position + delta, 0.0, length)
		last_action = "seek %+.0fs" % delta
		interaction_count += 1


func _on_seek_ended(_value_changed: bool) -> void:
	dragging_seek = false
	_seek_percent(seek.value)


func _on_video_finished() -> void:
	video.stream_position = 0.0
	video.play()
	last_action = "looped selected video"


func _thumbnail_hover(index: int, entered: bool) -> void:
	_update_thumbnail_frames(index if entered else -1)


func _update_thumbnail_frames(hovered := -1) -> void:
	for index in thumbnail_frames.size():
		var active := index == selected_video
		var width := 2 if active or index == hovered else 0
		thumbnail_frames[index].add_theme_stylebox_override(
			"panel", _panel_style(Color.TRANSPARENT, Color("#737373"), width, 0)
		)


func _animate_button(button: TextureButton, entered: bool) -> void:
	_start_source_motion(button, "hover" if entered else "settled")


func _press_button(button: TextureButton) -> void:
	_start_source_motion(button, "pressed")


func _on_title_drag_input(event: InputEvent, window: Control, handle: Control) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		dragging_viewer = true
		dragged_window = window
		dragged_handle = handle
		drag_pointer_start = event.global_position
		drag_surface_start = window.position
		drag_intent_count += 1
		last_action = "viewer drag" if window == surface else "information drag"
		interaction_count += 1
	elif event is InputEventKey and event.pressed:
		var direction := Vector2.ZERO
		match event.keycode:
			KEY_LEFT:
				direction = Vector2.LEFT
			KEY_RIGHT:
				direction = Vector2.RIGHT
			KEY_UP:
				direction = Vector2.UP
			KEY_DOWN:
				direction = Vector2.DOWN
		if direction != Vector2.ZERO:
			window.position += direction * (80.0 if event.shift_pressed else 20.0)
			_clamp_window(window, handle)
			get_viewport().set_input_as_handled()


func _input(event: InputEvent) -> void:
	if not dragging_viewer:
		return
	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and not event.pressed
	):
		dragging_viewer = false
	elif event is InputEventMouseMotion:
		if not event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			dragging_viewer = false
		else:
			dragged_window.position = drag_surface_start + event.position - drag_pointer_start
			_clamp_window(dragged_window, dragged_handle)


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		dragging_viewer = false


## Keep 200 px of a window's title bar across and all of its height inside the Page, as the
## prototype did on its window, at the pair's scale.
func _clamp_window(window: Control, handle: Control) -> void:
	var s := viewer_scale
	window.position.x = clampf(
		window.position.x,
		200.0 - handle.get_rect().end.x * s,
		size.x - 200.0 - handle.position.x * s
	)
	window.position.y = clampf(
		window.position.y, -handle.position.y * s, size.y - handle.get_rect().end.y * s
	)


func _update_timer() -> void:
	if video.stream == null:
		return
	timer_label.text = _format_time(video.stream_position)
	timer_label.tooltip_text = (
		"%s / %s" % [_format_time(video.stream_position), _format_time(video.get_stream_length())]
	)


func _format_time(seconds: float) -> String:
	var whole := maxi(0, int(seconds))
	return "%02d:%02d" % [whole / 60, whole % 60]


func _grect(c: Control) -> Rect2:
	return c.get_global_transform() * Rect2(Vector2.ZERO, c.size)


## The grabber of a source slider, where HSlider draws it: ratio * (track - grabber) along, centred across.
func _knob_rect(slider: HSlider) -> Rect2:
	var icon: Texture2D = source_faces[slider.name]
	var gs := icon.get_size()
	var local := Rect2(
		Vector2(slider.ratio * (slider.size.x - gs.x), (slider.size.y - gs.y) / 2.0), gs
	)
	return slider.get_global_transform() * local


func state() -> Dictionary:
	var tiles := []
	for i in thumbnail_buttons.size():
		tiles.append(
			{
				"index": i,
				"enabled": not thumbnail_buttons[i].disabled,
				"rect": _grect(thumbnail_buttons[i])
			}
		)
	return (
		Errors
		. ok(
			{
				"key": key,
				"ticks": ticks,
				"size": size,
				"viewer":
				{"position": surface.position, "scale": viewer_scale, "rect": _grect(surface)},
				"information": {"position": info.position, "rect": _grect(info)},
				"arrangement": arrangement,
				"selected_video": selected_video,
				"video_id": VIDEOS[selected_video].id,
				"title": VIDEOS[selected_video].title,
				"playing": video.is_playing() and not video.paused,
				"paused": video.paused,
				"hidden_paused": hidden_paused,
				"muted": muted,
				"volume": video.volume,
				"fullscreen": fullscreen,
				"stream_position": video.stream_position,
				"stream_length": video.get_stream_length(),
				"saved": saved.get(selected_video, false),
				"video_rect": _grect(video),
				"thumbnail_count": thumbnail_buttons.size(),
				"linked_video_count": VIDEOS.size(),
				"tiles": tiles,
				"controls":
				{
					"play": _grect(play_button),
					"seek": _grect(seek),
					"seek_knob": _knob_rect(seek),
					"timer": _grect(timer_label),
					"mute": _grect(mute_button),
					"volume": _grect(volume),
					"volume_knob": _knob_rect(volume),
					"fullscreen": _grect(fullscreen_button),
					"save": _grect(save_button),
					"minimize": _grect(expand_button),
					"title_bar": _grect(title_drag),
					"info_title_bar": _grect(info_drag)
				},
				"generated_motion_controls": model_frames.size(),
				"motion_play_count": motion_play_count,
				"drag_intent_count": drag_intent_count,
				"dragging_viewer": dragging_viewer,
				"interaction_count": interaction_count,
				"last_action": last_action,
			}
		)
	)


func _panel_style(fill: Color, border: Color, border_width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(border_width)
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	return style


# Source pixels are idle authority. Moving feedback is sampled Seedance imagery.
func _load_source_controls() -> void:
	var manifest: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string(ROOT + "assets/source-controls/manifest.json")
	)
	for k in manifest.controls:
		source_faces[k] = load(ROOT + "assets/source-controls/%s.png" % k)
	var generated: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string(ROOT + "assets/seedance-motion/manifest.json")
	)
	for k in generated.controls:
		model_frames[k] = {}
		for state in generated.controls[k]:
			model_frames[k][state] = []
			for path in generated.controls[k][state]:
				model_frames[k][state].append(load(ROOT + "assets/seedance-motion/" + path))


func _source_font(weight: String) -> FontFile:
	# The prototype loads the font bytes at run time (its editor build crashed importing them).
	var font := FontFile.new()
	font.data = FileAccess.get_file_as_bytes(ROOT + "assets/fonts/LiberationSans-%s.bytes" % weight)
	return font


func _source_key(k: String) -> String:
	if k == "play-pause":
		return "play" if video != null and video.paused else "pause"
	if k == "mute":
		return "mute" if muted else "speaker"
	return k


func _source_slider(k: String, rect: Rect2, initial: float) -> HSlider:
	var slider := HSlider.new()
	slider.name = k
	slider.focus_mode = Control.FOCUS_NONE
	slider.position = rect.position
	slider.size = rect.size
	slider.step = 0.01
	slider.value = initial
	for style in ["slider", "grabber_area", "grabber_area_highlight", "focus"]:
		slider.add_theme_stylebox_override(style, StyleBoxEmpty.new())
	for icon in ["grabber", "grabber_highlight", "grabber_disabled"]:
		slider.add_theme_icon_override(icon, source_faces[k])
	slider.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	slider.mouse_entered.connect(func(): _start_source_motion(slider, "hover"))
	slider.mouse_exited.connect(func(): _start_source_motion(slider, "settled"))
	slider.drag_started.connect(func(): _start_source_motion(slider, "pressed"))
	slider.drag_ended.connect(func(_changed): _start_source_motion(slider, "settled"))
	transport.add_child(slider)
	return slider


func _start_source_motion(control: Control, state: String) -> void:
	var k := _source_key(control.name)
	if not model_frames.has(k) or not model_frames[k].has(state):
		return
	active_motion[control] = {"key": k, "state": state, "elapsed": 0.0}
	motion_play_count += 1


func _advance_motion(delta: float) -> void:
	for control in active_motion.keys():
		var animation: Dictionary = active_motion[control]
		animation.elapsed += delta
		var frames: Array = model_frames[animation.key][animation.state]
		var index := mini(int(animation.elapsed / 0.045), frames.size() - 1)
		var texture: Texture2D = frames[index]
		if animation.elapsed >= frames.size() * 0.045 and animation.state == "settled":
			texture = source_faces[_source_key(control.name)]
			active_motion.erase(control)
		if control is HSlider:
			control.add_theme_icon_override("grabber", texture)
			control.add_theme_icon_override("grabber_highlight", texture)
		else:
			control.texture_normal = texture


func _set_volume(value: float) -> void:
	muted = value <= 0.0
	video.volume = value / 100.0
	mute_button.texture_normal = source_faces[_source_key("mute")]
	last_action = "volume %.0f%%" % value
	interaction_count += 1


func _toggle_save() -> void:
	saved[selected_video] = not saved.get(selected_video, false)
	save_button.tooltip_text = (
		"Saved for this session" if saved[selected_video] else "Save this video for this session"
	)
	last_action = "saved" if saved[selected_video] else "unsaved"
	interaction_count += 1
	_start_source_motion(save_button, "settled")
