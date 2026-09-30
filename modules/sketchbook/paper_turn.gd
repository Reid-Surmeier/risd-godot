extends Control
## The web prototype's paper turn, projected the way CSS does it:
## transform: perspective(1800px) rotateY(0 -> -88deg at 48% -> -180deg) scaleX(1 -> .965 -> 1)
## translateZ(0 -> 14px -> 0), transform-origin at the spine, cubic-bezier(.48,.05,.28,1) per
## keyframe segment, drop-shadow (5,1,7,.16) -> (18,4,14,.28) -> (-5,1,7,.12), a cream underlay
## revealing from 40% to 100% by 55%, faces with backface-visibility hidden. The sheet is a
## flat cream card carrying the outgoing half's ink (rendered to a SubViewport texture).
## Ported unchanged in behaviour from figma-ui-ux-qwen-pipeline prototype/painting-tool-mixbox @ 7ee5e9c
## viewer-godot/scripts/paper_turn.gd (the global class_name dropped; the module preloads it). Reach it through interface.gd only.

const PERSPECTIVE := 1800.0
const STRIPS := 32
const CREAM := Color("#fdf4dc")
const UNDERLAY := Color("#fdf5e1")
const BORDER := Color(126 / 255.0, 103 / 255.0, 62 / 255.0, 0.18)
const SHADOW_TINT := Color(55 / 255.0, 39 / 255.0, 20 / 255.0)

var direction := "forward"
var progress := 0.0
var hinge := Vector2.ZERO  # spine point on the sheet's vertical centre, in this control's space
var sheet_size := Vector2.ZERO  # width from the spine to the page edge, full page height
var face: Texture2D


func _draw() -> void:
	if face == null or sheet_size.x <= 0.0:
		return
	var t := clampf(progress, 0.0, 1.0)
	var angle: float
	var scale_x: float
	var lift: float
	var shadow: Array
	if t < 0.48:
		var u := _bezier(t / 0.48)
		angle = lerpf(0.0, -88.0, u)
		scale_x = lerpf(1.0, 0.965, u)
		lift = lerpf(0.0, 14.0, u)
		shadow = [lerpf(5, 18, u), lerpf(1, 4, u), lerpf(7, 14, u), lerpf(0.16, 0.28, u)]
	else:
		var u := _bezier((t - 0.48) / 0.52)
		angle = lerpf(-88.0, -180.0, u)
		scale_x = lerpf(0.965, 1.0, u)
		lift = lerpf(14.0, 0.0, u)
		shadow = [lerpf(18, -5, u), lerpf(4, 1, u), lerpf(14, 7, u), lerpf(0.28, 0.12, u)]
	var forward := direction == "forward"
	var sign := 1.0 if forward else -1.0
	if not forward:
		angle = -angle
		shadow[0] = -shadow[0]
	# The page under the lifting sheet is the book's own blank page; what the lift adds is the
	# shadow it casts into the spine, strongest when the sheet stands up.
	var rad0 := deg_to_rad(absf(angle))
	var standing := sin(rad0)
	var gutter_shadow := sheet_size.x * 0.22
	var under_origin := hinge + Vector2(0.0 if forward else -gutter_shadow, -sheet_size.y / 2.0)
	var shade := Color(SHADOW_TINT, 0.16 * standing)
	var clear := Color(SHADOW_TINT, 0.0)
	var a := under_origin
	var b := under_origin + Vector2(gutter_shadow, 0.0)
	var c := under_origin + Vector2(gutter_shadow, sheet_size.y)
	var d := under_origin + Vector2(0.0, sheet_size.y)
	var near_spine := shade if forward else clear
	var far_spine := clear if forward else shade
	draw_polygon(
		PackedVector2Array([a, b, c, d]),
		PackedColorArray([near_spine, far_spine, far_spine, near_spine])
	)
	# Projected strips of the sheet.
	var rad := deg_to_rad(angle)
	var cos_a := cos(rad)
	var sin_a := sin(rad)
	var back_face := cos_a < 0.0
	var tops := PackedVector2Array()
	var bottoms := PackedVector2Array()
	for i in range(STRIPS + 1):
		var x := sheet_size.x * i / STRIPS * sign * scale_x
		# CSS applies translateZ, then scaleX, then rotateY, then perspective from the origin.
		var big_x := x * cos_a + lift * sin_a
		var big_z := -x * sin_a + lift * cos_a
		var w := PERSPECTIVE / (PERSPECTIVE - big_z)
		var half_h := sheet_size.y / 2.0 * w
		tops.append(hinge + Vector2(big_x * w, -half_h))
		bottoms.append(hinge + Vector2(big_x * w, half_h))
	# drop-shadow: the projected sheet is a trapezoid, so one offset quad per softness pass.
	var shadow_offset := Vector2(shadow[0], shadow[1])
	var blur: float = shadow[2]
	var near := tops[0]
	var far := tops[STRIPS]
	var outward := Vector2(signf(far.x - near.x), 0.0)
	for pass_index in range(3):
		var spread := blur * (0.3 + 0.35 * pass_index)
		var tint := Color(SHADOW_TINT, shadow[3] * 0.45 / (1.0 + pass_index))
		var quad := PackedVector2Array(
			[
				tops[0] + shadow_offset + Vector2(0.0, -spread),
				tops[STRIPS] + shadow_offset + outward * spread + Vector2(0.0, -spread),
				bottoms[STRIPS] + shadow_offset + outward * spread + Vector2(0.0, spread),
				bottoms[0] + shadow_offset + Vector2(0.0, spread)
			]
		)
		draw_colored_polygon(quad, tint)
	for i in range(STRIPS):
		var u0 := float(i) / STRIPS
		var u1 := float(i + 1) / STRIPS
		if back_face:
			# backface-visibility hidden: the back face is the same content rotated 180deg, which
			# reads un-mirrored on screen.
			u0 = 1.0 - u0
			u1 = 1.0 - u1
		if not forward:
			u0 = 1.0 - u0
			u1 = 1.0 - u1
		var quad := PackedVector2Array([tops[i], tops[i + 1], bottoms[i + 1], bottoms[i]])
		var uvs := PackedVector2Array(
			[Vector2(u0, 0), Vector2(u1, 0), Vector2(u1, 1), Vector2(u0, 1)]
		)
		# Fold shading: the sheet darkens toward the spine as it stands up, like paper in a curl.
		var fold0 := 1.0 - 0.22 * standing * (1.0 - float(i) / STRIPS)
		var fold1 := 1.0 - 0.22 * standing * (1.0 - float(i + 1) / STRIPS)
		var c0 := Color(fold0, fold0, fold0)
		var c1 := Color(fold1, fold1, fold1)
		draw_polygon(quad, PackedColorArray([c0, c1, c1, c0]), uvs, face)
	# 1 px face border, as the web faces have.
	var edge := PackedVector2Array([tops[0], tops[STRIPS], bottoms[STRIPS], bottoms[0], tops[0]])
	draw_polyline(edge, BORDER, 1.0, true)


## cubic-bezier(.48, .05, .28, 1) as CSS evaluates it: solve x(s) = t for s, return y(s).
static func _bezier(t: float) -> float:
	if t <= 0.0:
		return 0.0
	if t >= 1.0:
		return 1.0
	var s := t
	for _i in range(8):
		var x := _cubic(0.48, 0.28, s) - t
		var dx := _cubic_derivative(0.48, 0.28, s)
		if absf(dx) < 1e-6:
			break
		s = clampf(s - x / dx, 0.0, 1.0)
	return _cubic(0.05, 1.0, s)


static func _cubic(p1: float, p2: float, s: float) -> float:
	var q := 1.0 - s
	return 3.0 * q * q * s * p1 + 3.0 * q * s * s * p2 + s * s * s


static func _cubic_derivative(p1: float, p2: float, s: float) -> float:
	var q := 1.0 - s
	return 3.0 * q * q * p1 + 6.0 * q * s * (p2 - p1) + 3.0 * s * s * (1.0 - p2)
