## Rendered sole/floor relation at native and embedded sizes. A displaced-shadow
## negative control must fail the same local visible-contact measurement.
extends "res://testing/harness_base.gd"
var walk: Control
var failures := 0


func require(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)


func _initialize() -> void:
	call_deferred("run")


func capture() -> Image:
	await _frames(3)
	return get_root().get_texture().get_image()


func contact_pixels(on: Image, off: Image, center: Vector2, radius: int) -> int:
	var count := 0
	for y in range(
		maxi(0, int(center.y) - radius), mini(on.get_height(), int(center.y) + radius + 1)
	):
		for x in range(
			maxi(0, int(center.x) - radius), mini(on.get_width(), int(center.x) + radius + 1)
		):
			if (
				Vector2(x, y).distance_to(center) <= radius
				and off.get_pixel(x, y).get_luminance() - on.get_pixel(x, y).get_luminance() > 0.035
			):
				count += 1
	return count


func run() -> void:
	walk = load("res://modules/shell/prototype/gallery_walk4/walk4.gd").new()
	walk.size = Vector2(1152, 720)
	walk.set_process(false)
	var out := await _mount(walk, Vector2i(1152, 720), "/tmp/gallery-contact")
	walk.set_process(false)
	walk._new_action()
	walk._entrance_active = false
	walk._entrance_waiting = false
	walk._target = null
	for size_label in ["native", "embedded"]:
		var dimensions := Vector2i(1152, 720) if size_label == "native" else Vector2i(588, 392)
		get_root().size = dimensions
		walk.size = dimensions
		await _frames(3)
		for situation in ["front", "side", "back", "stride", "white"]:
			walk._enter_space("arch" if situation == "white" else "gallery")
			walk._portal_flash.modulate.a = 0.0
			walk._pos = Vector3(0, 0, -2.6)
			walk._kid.position = walk._pos
			walk._kid.reset_contacts()
			walk.view_yaw = 0.0
			var heading := (
				Vector3.RIGHT
				if situation == "side"
				else (Vector3.FORWARD if situation == "back" else Vector3.BACK)
			)
			walk._kid.phase = 0.12
			walk._kid.pose(0.0, false, 0.0, heading, walk.view_yaw)
			walk._kid.pose(0.2, false, 0.0, heading, walk.view_yaw)
			if situation == "stride":
				for frame in 20:
					walk._pos += heading * 1.2 / 60.0
					walk._kid.position = walk._pos
					walk._kid.pose(1.0 / 60.0, true, 0.0, heading, walk.view_yaw)
			walk._update_camera(1.0)
			var after: Image = await capture()
			after.save_png(out + "/" + size_label + "-" + situation + "-after.png")
			var shadow_alpha: float = walk._shadow.material_override.albedo_color.a
			for patch in walk._sole_shadows:
				patch.hide()
			walk._shadow.hide()
			var off: Image = await capture()
			# Baseline's single diffuse body blob, reconstructed in the harness only.
			walk._shadow.show()
			walk._shadow.position = walk._kid.footprint_position() + Vector3.UP * 0.01
			walk._shadow.material_override.albedo_color.a = 0.55 / 0.9
			var before: Image = await capture()
			before.save_png(out + "/" + size_label + "-" + situation + "-before.png")
			walk._shadow.hide()
			for patch in walk._sole_shadows:
				patch.show()
				patch.position.x += 1.0
			var displaced: Image = await capture()
			var soles: Array = walk._kid.sole_positions()
			var support: Array = walk._kid.sole_support()
			var visible_support := 0
			var baseline_support := 0
			for index in 2:
				if not support[index]:
					continue
				var point: Vector2 = (
					walk._cam.unproject_position(soles[index])
					* Vector2(dimensions)
					/ Vector2(walk._vp.size)
				)
				var radius := 20 if size_label == "native" else 10
				var visible := contact_pixels(after, off, point, radius)
				var wrong := contact_pixels(displaced, off, point, radius)
				var baseline := contact_pixels(before, off, point, radius)
				print(
					"SOLE_VISIBILITY ",
					size_label,
					" ",
					situation,
					" foot=",
					index,
					" attached_pixels=",
					visible,
					" previous_pixels=",
					baseline,
					" displaced_pixels=",
					wrong
				)
				visible_support += visible
				baseline_support += baseline
				require(wrong < 5, "displaced-shadow negative control still passes contact check")
			# A side-facing rear sole can be physically occluded by the near boot.
			# Require visible support at the floor, not visibility through the body.
			# The stride may hide most of its support sole: preserve its visible
			# contact; require added readable support in the neutral views.
			var minimum := maxi(5, baseline_support + (0 if situation == "stride" else 5))
			require(
				visible_support >= minimum,
				"supporting sole/floor relation regressed: " + situation + size_label
			)
			walk._shadow.show()
			walk._shadow.material_override.albedo_color.a = shadow_alpha
			walk._update_camera(1.0)
	print("SOLE_VISIBILITY_FAILURES ", failures)
	quit(1 if failures else 0)
