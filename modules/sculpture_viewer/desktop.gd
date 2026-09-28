## Square catalogue Tenant. The Buddha viewer remains available to embedding hosts.
extends Control

const Errors := preload("res://modules/sculpture_viewer/errors.gd")
const Catalogue := preload("res://modules/sculpture_viewer/catalogue.gd")
const ROOT := "res://modules/sculpture_viewer/"
const REQUIRED := [
	"assets/setup/panel-2x.png", "assets/clean-ui/background.png", "assets/clean-ui/timer-source.png",
	"assets/control-motion/previous.png", "assets/control-motion/next.png", "assets/control-motion/play-pause.png",
	"assets/control-motion/audio.png", "assets/control-motion/menu.png", "assets/control-motion/scrubber.png",
	"assets/control-motion/track-empty.png", "assets/control-motion/track-fill.png",
	"assets/models/proton-buddha-3124123123.glb", "assets/models/3124123123.jpg",
	"shaders/player_base.gdshader", "shaders/control_face.gdshader",
]

var key := ""
var ticks := 0
var inputs := 0
var catalogue: Control


static func create(deps: Dictionary) -> Dictionary:
	var paths := ["assets/setup/panel-2x.png"]
	for id in Catalogue.IDS:
		paths.append("assets/scans/%s-front.png" % id)
	for cell in Catalogue.TURN:
		paths.append("assets/setup/turn/%s.png" % Catalogue.TURN[cell][0])
	for path in paths:
		if not ResourceLoader.exists(ROOT + path):
			return Errors.err(Errors.ASSET_MISSING, ROOT + path)
	var tenant = load("res://modules/sculpture_viewer/desktop.gd").new()
	tenant.key = deps.get("key", "")
	tenant.name = "SculptureViewer"
	tenant.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return Errors.ok(tenant)


static func embedded_viewer() -> Dictionary:
	for path in REQUIRED:
		if not ResourceLoader.exists(ROOT + path):
			return Errors.err(Errors.ASSET_MISSING, ROOT + path)
	var embedded = load(ROOT + "viewer.gd").new()
	embedded.name = "embedded-3d-viewer"
	return Errors.ok(embedded)


func _ready() -> void:
	texture_filter = TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	catalogue = Catalogue.new()
	add_child(catalogue)
	resized.connect(_fit)
	_fit()


func _fit() -> void:
	var factor := minf(size.x / 1080.0, size.y / 1022.0)
	catalogue.scale = Vector2.ONE * factor
	catalogue.position = (size - Vector2(1080, 1022) * factor) / 2.0


func _process(_delta: float) -> void:
	ticks += 1


func _input(_event: InputEvent) -> void:
	inputs += 1


func state() -> Dictionary:
	var data: Dictionary = catalogue.catalogue_state()
	var cards := []
	for i in range(20):
		cards.append(catalogue.get_global_transform() * catalogue._card_rect(i))
	data.merge({"key": key, "ticks": ticks, "inputs": inputs, "size": size,
		"desktop_scale": catalogue.scale.x, "cards": cards, "rows": 5, "columns": 4,
		"selected_name": catalogue.APPEARANCE[catalogue.selected],
		"department": "unverified", "hover_tick": catalogue.tick})
	return Errors.ok(data)
