## Prototype (owner's screenshot of 2026-09-25): a column of desktop icons on every Page, under the
## Tenant's windows. Each icon is a Muse isolation of the screenshot's own icon and label
## (image-work/desktop-icons). Click selects, double-click opens (for now a pressed flash and the
## `opened` signal); a click on empty desktop clears the selection.
extends Control

signal opened(key: String)

const ROOT := "res://modules/shell/assets/desktop_icons/"
const ICONS: Array[String] = ["downloads", "documents", "websurfer2", "nextrooms", "wastebin", "screensavers", "do_not_open"]
const SIDE := "left"  # "left" or "right"; windows overlap the column
const MARGIN := 14.0  # page px from the page's edge and top
const PITCH := 150.0  # page px between icon tops at most; shrinks to fit a short page
const SELECTED := Color(0.62, 0.66, 1.0)  # the classic selected-icon blue, as a tint

var _selected: TextureRect
var _flash: Tween


## Put the column inside `tenant`, under its windows: descend through plain containers that fill the
## page or hold its backdrop (the Sketchbook's and 3D Viewer's `desktop`) to the node that holds the windows, then sit just
## above any full-page backdrop there (the paper, the ground), below everything else.
static func insert(tenant: Control) -> Control:
	var holder := tenant
	var descended := true
	while descended:
		descended = false
		for c in holder.get_children():
			if c.get_class() == "Control" and c.visible and (_full(c, tenant) or (c.get_index() == 0 and _backdrop_in(c, tenant) >= 0)):
				holder = c
				descended = true
				break
	var at := _backdrop_in(holder, tenant) + 1
	var icons: Control = load("res://modules/shell/desktop_icons.gd").new()
	holder.add_child(icons)
	holder.move_child(icons, at)
	return icons


## The index of the last full-page ColorRect/TextureRect among `holder`'s children (the paper, the ground), or -1.
static func _backdrop_in(holder: Node, tenant: Control) -> int:
	var at := -1
	for i in holder.get_child_count():
		var c := holder.get_child(i)
		if (c is ColorRect or c is TextureRect) and _full(c, tenant):
			at = i
	return at


static func _full(c: Control, tenant: Control) -> bool:  # anchored to fill, or already laid out filling
	var anchored := c.anchor_left == 0.0 and c.anchor_top == 0.0 and c.anchor_right == 1.0 and c.anchor_bottom == 1.0
	return anchored or (tenant.size.x > 0.0 and c.size.distance_to(tenant.size) < 2.0 and c.position.length() < 2.0)


func _ready() -> void:
	name = "DesktopIcons"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for key in ICONS:
		var icon := TextureRect.new()
		icon.name = key
		icon.texture = load(ROOT + key + ".png")
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		icon.mouse_filter = Control.MOUSE_FILTER_STOP
		icon.gui_input.connect(_on_icon_input.bind(icon))
		add_child(icon)
	resized.connect(_fit)
	item_rect_changed.connect(_fit)
	_fit.call_deferred()


func _fit() -> void:
	var k := get_global_transform().get_scale().x  # a Tenant that scales its desktop (3D Viewer, Sketchbook)
	if k <= 0.0:
		return
	var margin := MARGIN / k
	var pitch := minf(PITCH / k, (size.y - margin) / ICONS.size())
	var column := 0.0
	for icon in get_children():
		column = maxf(column, icon.texture.get_width() / k)
	for i in get_child_count():
		var icon: TextureRect = get_child(i)
		icon.size = icon.texture.get_size()
		icon.scale = Vector2.ONE / k  # page pixels, whatever the desktop's scale
		var x := margin if SIDE == "left" else size.x - margin - column
		icon.position = Vector2(x + (column - icon.size.x / k) * 0.5, margin + i * pitch)


func _on_icon_input(event: InputEvent, icon: TextureRect) -> void:
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	_select(icon)
	if event.double_click:
		icon.modulate = Color(0.4, 0.45, 1.0)
		_flash = create_tween()
		_flash.tween_property(icon, "modulate", SELECTED, 0.15)
		emit_signal("opened", icon.name)
	icon.accept_event()


func _select(icon: TextureRect) -> void:
	if _flash != null and _flash.is_valid():
		_flash.kill()
	if _selected != null and _selected != icon:
		_selected.modulate = Color.WHITE
	_selected = icon
	if icon != null:
		icon.modulate = SELECTED


func _input(event: InputEvent) -> void:  # a click anywhere off the icons clears the selection
	if _selected != null and is_visible_in_tree() and event is InputEventMouseButton and event.pressed \
			and not _selected.get_global_rect().has_point(get_global_mouse_position()):
		_select(null)
