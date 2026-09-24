## Prototype (owner's references: the kiiikiii.kr hover glow, the nodate.club two-state cursor).
## A hovered button or tab gets a soft sky-blue halo that hugs its shape and spills GLOW_PX screen pixels
## into the scene, fading in over FADE_IN and out over FADE_OUT; the arrow cursor turns blue over it.
## The cursor pair is Muse output conformed to its pixel grid (prototype/hover-glow/).
extends RefCounted

const SHADER := preload("res://modules/shell/hover_glow.gdshader")
const GLOW_PX := 22.0
const FADE_IN := 0.22
const FADE_OUT := 0.4
const ARROW := "res://assets/cursor/arrow.png"
const ARROW_HOVER := "res://assets/cursor/arrow-hover.png"


static func use_cursor() -> void:
	Input.set_custom_mouse_cursor(load(ARROW), Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(load(ARROW_HOVER), Input.CURSOR_POINTING_HAND)


static func attach_all(root: Node) -> void:
	for button in root.find_children("*", "BaseButton", true, false):
		attach(button)


static func attach(target: Control) -> void:
	if target.has_meta("hover_glow"):
		return
	var halo := ColorRect.new()
	halo.name = "HoverGlow"
	halo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	halo.z_index = 1  # over the neighbours, so the glow spills into the area around the control
	var material := ShaderMaterial.new()
	material.shader = SHADER
	var picture: Texture2D = target.texture_normal if target is TextureButton else null
	material.set_shader_parameter("has_shape", picture != null)
	material.set_shader_parameter("shape", picture)
	material.set_shader_parameter("strength", 0.0)  # unset parameters read back as null
	halo.material = material
	halo.visible = false
	target.add_child(halo)
	target.set_meta("hover_glow", halo)
	for c in [target] + target.find_children("*", "Control", true, false):
		if c != halo:
			c.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var fit := func():
		var pad := GLOW_PX / maxf(target.get_global_transform().get_scale().x, 0.01)  # the tabs sit in a scaled strip
		halo.position = -Vector2(pad, pad)
		halo.size = target.size + Vector2(pad, pad) * 2.0
		material.set_shader_parameter("box", target.size)
		material.set_shader_parameter("pad", pad)
		material.set_shader_parameter("radius", minf(6.0, minf(target.size.x, target.size.y) * 0.25))
	var fade := func(to: float, seconds: float):
		if halo.has_meta("tween"):
			(halo.get_meta("tween") as Tween).kill()
		var from: float = material.get_shader_parameter("strength")
		halo.visible = true
		var t := halo.create_tween()
		t.tween_method(func(v: float): material.set_shader_parameter("strength", v), from, to, seconds * absf(to - from))
		if to == 0.0:
			t.tween_callback(func(): halo.visible = false)
		halo.set_meta("tween", t)
	target.resized.connect(fit)
	target.mouse_entered.connect(func():
		fit.call()
		fade.call(1.0, FADE_IN))
	target.mouse_exited.connect(func(): fade.call(0.0, FADE_OUT))
	target.hidden.connect(func():
		material.set_shader_parameter("strength", 0.0)
		halo.visible = false)
	fit.call()
