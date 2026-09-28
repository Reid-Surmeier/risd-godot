## Prototype (owner's screenshot of 2026-09-25): a column of desktop icons on every Page, under the
## Tenant's windows. Each icon is a Muse isolation of the screenshot's own icon and label
## (image-work/desktop-icons). Click selects, double-click opens (for now a pressed flash and the
## `opened` signal); a click on empty desktop clears the selection.
extends Control

signal opened(key: String)

const ROOT := "res://modules/shell/assets/desktop_icons/"
const ICONS: Array[String] = ["downloads", "documents", "websurfer2", "nextrooms", "wastebin", "screensavers", "do_not_open"]
const SIDE := "left"  # "left" or "right"
const MARGIN := 14.0  # page px from the page's edge and top
const INSET := 115.0  # widest icon and baked caption (87 px), plus both 14 px margins
const PITCH := 150.0  # page px between icon tops at most; shrinks to fit a short page
const SELECTED := Color(0.62, 0.66, 1.0)  # the classic selected-icon blue, as a tint
const QUIET := preload("res://modules/shell/desktop_icon.gdshader")  # lighter grey, slightly see-through; a selected icon is drawn in full

var _selected: TextureRect
var _flash: Tween


## Put the column inside `tenant`, under its windows: descend through plain containers that fill the
## page or hold its backdrop (the Sketchbook's and 3D Viewer's `desktop`) to the node that holds the windows, then sit just
## above any full-page backdrop there (the paper, the ground), below everything else.
static func insert(tenant: Control) -> Control:
	var holder := window_holder(tenant)
	var at := _backdrop_in(holder, tenant) + 1
	if SIDE == "left":
		tenant.offset_left += INSET
	else:
		tenant.offset_right -= INSET
	var icons: Control = load("res://modules/shell/desktop_icons.gd").new()
	holder.add_child(icons)
	holder.move_child(icons, at)
	holder.resized.connect(icons._fit)
	holder.item_rect_changed.connect(icons._fit)
	return icons


## The node whose children are `tenant`'s windows (window_shadows.gd uses it too).
static func window_holder(tenant: Control) -> Control:
	var holder := tenant
	var descended := true
	while descended:
		descended = false
		for c in holder.get_children():
			if c.get_class() == "Control" and c.visible and (_full(c, tenant) or (c.get_index() == 0 and _backdrop_in(c, tenant) >= 0)):
				holder = c
				descended = true
				break
	return holder


## True for a full-page backdrop (the paper, the ground) among a holder's children.
static func is_backdrop(c: Node, tenant: Control) -> bool:
	return (c is ColorRect or c is TextureRect) and _full(c, tenant)


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
	size = Vector2.ZERO  # nothing to click: a Tenant that picks the child under the pointer never finds the layer
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for key in ICONS:
		var icon := TextureRect.new()
		icon.name = key
		icon.texture = load(ROOT + key + ".png")
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		icon.mouse_filter = Control.MOUSE_FILTER_STOP
		icon.gui_input.connect(_on_icon_input.bind(icon))
		var quiet := ShaderMaterial.new()
		quiet.shader = QUIET
		icon.material = quiet
		add_child(icon)
	_fit.call_deferred()


func _fit() -> void:
	var k := get_global_transform().get_scale().x  # a Tenant that scales its desktop (3D Viewer, Sketchbook)
	if k <= 0.0:
		return
	# the column is placed in Page pixels, out in the strip the Tenant gave up (this layer does not clip)
	var page := _page()
	if page == null:
		return
	var to_local := get_global_transform().affine_inverse()
	var page_rect := Rect2(page.global_position, page.size)
	var pitch := minf(PITCH, (page_rect.size.y - MARGIN) / ICONS.size())
	var column := 0.0
	for icon in get_children():
		column = maxf(column, icon.texture.get_width())
	for i in get_child_count():
		var icon: TextureRect = get_child(i)
		icon.size = icon.texture.get_size()
		icon.scale = Vector2.ONE / k  # page pixels, whatever the desktop's scale
		var x := MARGIN if SIDE == "left" else page_rect.size.x - MARGIN - column
		var at := page_rect.position + Vector2(x + (column - icon.size.x) * 0.5, MARGIN + i * pitch)
		icon.position = to_local * at


func _page() -> Control:  # the Shell's Page this column's Tenant sits on
	var n := get_parent()
	while n != null and not n.name.begins_with("Page_"):
		n = n.get_parent()
	return n as Control


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
		(_selected.material as ShaderMaterial).set_shader_parameter("quiet", 1.0)
	_selected = icon
	if icon != null:
		icon.modulate = SELECTED
		(icon.material as ShaderMaterial).set_shader_parameter("quiet", 0.0)


func _input(event: InputEvent) -> void:  # a click anywhere off the icons clears the selection
	if _selected != null and is_visible_in_tree() and event is InputEventMouseButton and event.pressed \
			and not _selected.get_global_rect().has_point(get_global_mouse_position()):
		_select(null)
