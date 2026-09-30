extends SceneTree
var failures := 0
var quantization_mode := 2
var output_dir := ""


func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out-dir="):
			output_dir = arg.trim_prefix("--out-dir=")
			DirAccess.make_dir_recursive_absolute(output_dir)
	call_deferred("run")


func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		print("FAIL ", message)


func q(image: Image, x: int, y: int) -> Vector3:
	x = clampi(x, 0, image.get_width() - 1)
	y = clampi(y, 0, image.get_height() - 1)
	var c := image.get_pixel(x, y)
	if quantization_mode == 0:
		return Vector3(c.r, c.g, c.b)
	var out := Vector3.ZERO
	var d := ((x ^ y) & 1) * 2 + (y & 1)
	for i in 3:
		var v := floorf(c[i] * 255.0 + 0.5)
		if quantization_mode == 2:
			v = v - floorf(v / 64.0) + d
		out[i] = clampf(floorf(v / 4.0) / 63.0, 0.0, 1.0)
	return out


func row(image: Image, x: int, y: int, side: float) -> Vector3:
	return (
		q(image, x, y - 1) * side + q(image, x, y) * (1.0 - 2.0 * side) + q(image, x, y + 1) * side
	)


func run() -> void:
	var source := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	for y in 8:
		for x in 8:
			source.set_pixel(x, y, Color(float(x) / 7.0, float(y) / 7.0, float((x + y) % 8) / 7.0))
	var vp := SubViewport.new()
	vp.size = Vector2i(40, 40)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var rect := TextureRect.new()
	rect.texture = ImageTexture.create_from_image(source)
	rect.size = Vector2(40, 40)
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	var material := ShaderMaterial.new()
	material.shader = load("res://modules/shell/prototype/gallery_walk4/gamecube.gdshader")
	rect.material = material
	vp.add_child(rect)
	for mode in [0, 1, 2]:
		quantization_mode = mode
		material.set_shader_parameter("quantization_mode", mode)
		for strength in [0.0, 0.5, 1.0]:
			material.set_shader_parameter("copy_filter", strength)
			await process_frame
			await process_frame
			await RenderingServer.frame_post_draw
			var result := vp.get_texture().get_image()
			var worst := 0.0
			for y in 40:
				for x in 40:
					var p := Vector2((x + 0.5) / 5.0 - 0.5, (y + 0.5) / 5.0 - 0.5)
					var ix := floori(p.x)
					var iy := floori(p.y)
					var fx := p.x - floorf(p.x)
					var fy := p.y - floorf(p.y)
					var top := row(source, ix, iy, strength * 0.25).lerp(
						row(source, ix + 1, iy, strength * 0.25), fx
					)
					var bottom := row(source, ix, iy + 1, strength * 0.25).lerp(
						row(source, ix + 1, iy + 1, strength * 0.25), fx
					)
					var wanted := top.lerp(bottom, fy)
					var got := result.get_pixel(x, y)
					for channel in 3:
						worst = maxf(worst, absf(got[channel] - wanted[channel]))
			check(worst <= 1.1 / 255.0, "RGB6/filter/upscale error exceeds one output code")
			print(
				"GAMECUBE_GPU mode=",
				quantization_mode,
				" filter=",
				strength,
				" pixels=1600 max_error=",
				worst
			)
	for color in [Color.BLACK, Color.WHITE]:
		source.fill(color)
		rect.texture = ImageTexture.create_from_image(source)
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		var result := vp.get_texture().get_image()
		check(result.get_pixel(20, 20).is_equal_approx(color), "black/white changed")
	await check_3d_chart()
	await check_quiet_stack()
	check_mapping_refresh()
	print("FINAL_RENDER_GPU_FAILURES ", failures)
	quit(failures)


func check_quiet_stack() -> void:
	var source := Image.create(40, 40, false, Image.FORMAT_RGBA8)
	for y in 40:
		for x in 40:
			source.set_pixel(x, y, Color(0.2 if x % 2 else 0.8, float(y) / 40.0, 0.4))
	var texture := ImageTexture.create_from_image(source)
	var vp := SubViewport.new()
	vp.size = Vector2i(40, 40)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var rect := TextureRect.new()
	rect.texture = texture
	rect.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	rect.size = Vector2(40, 40)
	vp.add_child(rect)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var baseline := vp.get_texture().get_image()
	var material := ShaderMaterial.new()
	material.shader = load("res://modules/shell/crt_luminance.gdshader")
	material.set_shader_parameter("tex", texture)
	material.set_shader_parameter("quiet_rect", Vector4(0, 0, 1, 1))
	rect.material = material
	var haze := ColorRect.new()
	haze.size = Vector2(40, 40)
	var haze_mat := ShaderMaterial.new()
	haze_mat.shader = load("res://modules/shell/haze_screen.gdshader")
	haze_mat.set_shader_parameter("quiet_rect", Vector4(0, 0, 1, 1))
	haze.material = haze_mat
	vp.add_child(haze)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var result := vp.get_texture().get_image()
	var worst := 0.0
	for y in 40:
		for x in 40:
			var a := baseline.get_pixel(x, y)
			var b := result.get_pixel(x, y)
			for channel in 3:
				worst = maxf(worst, absf(a[channel] - b[channel]))
	print("QUIET_GPU CRT_and_HAZE pixels=1600 max_error=", worst)
	var passed := worst <= 1.1 / 255.0
	material.set_shader_parameter("quiet_rect", Vector4.ZERO)
	haze_mat.set_shader_parameter("quiet_rect", Vector4.ZERO)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	result = vp.get_texture().get_image()
	var delta := absf(result.get_pixel(20, 20).r - baseline.get_pixel(20, 20).r)
	print("QUIET_GPU outside_region_effect_delta=", delta)
	passed = passed and delta > 0.01
	check(passed, "quiet region must preserve pixels while the outside retains its finish")


func check_mapping_refresh() -> void:
	# Minimal host for the real adapter; three frame callbacks stay below its QA timer.
	var host = load("res://modules/shell/crt_display.gd").new()
	host.size = Vector2(800, 600)
	var desktop := SubViewport.new()
	desktop.name = "Desktop"
	host.add_child(desktop)
	var screen := TextureRect.new()
	screen.name = "Screen"
	screen.material = ShaderMaterial.new()
	screen.material.shader = load("res://modules/shell/crt_luminance.gdshader")
	screen.material.set_shader_parameter("curve", 0.018)
	screen.material.set_shader_parameter("screen_scale", 0.9)
	host.add_child(screen)
	root.add_child(host)
	host.set_process(false)
	host._qa_enabled = true
	var view := Control.new()
	view.position = Vector2(100, 50)
	view.size = Vector2(200, 100)
	desktop.add_child(view)
	view.add_to_group("soft_render_view")
	desktop.size = Vector2i(1000, 500)
	host._process(1.0 / 60.0)
	var haze: ShaderMaterial = host.haze.material
	check(
		haze.get_shader_parameter("quiet_rect").is_equal_approx(Vector4(0.1, 0.1, 0.3, 0.3)),
		"mapping did not refresh on first frame"
	)
	check(
		(
			is_equal_approx(haze.get_shader_parameter("desktop_curve"), 0.018)
			and is_equal_approx(haze.get_shader_parameter("desktop_scale"), 0.9)
		),
		"enabled CRT warp did not reach haze"
	)
	desktop.size = Vector2i(800, 800)
	view.position = Vector2(240, 160)
	host.enabled = false
	host._process(1.0 / 60.0)
	var expected := Vector4(0.3, 0.2, 0.55, 0.325)
	check(
		(
			haze.get_shader_parameter("quiet_rect").is_equal_approx(expected)
			and host.crt_material.get_shader_parameter("quiet_rect").is_equal_approx(expected)
		),
		"resized/moved exclusion stayed stale"
	)
	check(
		(
			is_equal_approx(haze.get_shader_parameter("desktop_aspect"), 1.0)
			and is_zero_approx(haze.get_shader_parameter("desktop_curve"))
			and is_equal_approx(haze.get_shader_parameter("desktop_scale"), 1.0)
		),
		"resize/CRT toggle left stale haze coordinates"
	)
	view.hide()
	host._process(1.0 / 60.0)
	check(
		(
			haze.get_shader_parameter("quiet_rect") == Vector4.ZERO
			and host.crt_material.get_shader_parameter("quiet_rect") == Vector4.ZERO
		),
		"hidden gallery retained its exclusion"
	)
	print("MAPPING_REFRESH production_callbacks=3 elapsed=0.05s qa_timer=", host._qa_elapsed)
	host.free()


# The pre-finish texture comes from actual 3D materials, not a CPU-created chart.
func check_3d_chart() -> void:
	var source := SubViewport.new()
	source.size = Vector2i(160, 80)
	source.own_world_3d = true
	source.msaa_3d = Viewport.MSAA_2X
	source.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(source)
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color.BLACK
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color.WHITE
	environment.environment.ambient_light_energy = 1.0
	environment.environment.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	source.add_child(environment)
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 4.0
	camera.position.z = 5.0
	source.add_child(camera)
	var colors := [
		Color.BLACK,
		Color.WHITE,
		Color(0.25, 0.25, 0.25),
		Color(0.5, 0.5, 0.5),
		Color(0.75, 0.75, 0.75),
		Color(0.9, 0.8, 0.6),
		Color(0.8, 0.1, 0.1),
		Color(0.1, 0.2, 0.8)
	]
	var locations: Array[Vector2i] = []
	for row_index in 2:
		for x in colors.size():
			var mesh := MeshInstance3D.new()
			mesh.mesh = QuadMesh.new()
			mesh.mesh.size = Vector2(0.9, 1.2)
			mesh.position = Vector3(float(x) - 3.5, 0.85 if row_index == 0 else -0.85, 0)
			var paint := StandardMaterial3D.new()
			paint.albedo_color = colors[x]
			paint.shading_mode = (
				BaseMaterial3D.SHADING_MODE_UNSHADED
				if row_index == 0
				else BaseMaterial3D.SHADING_MODE_PER_PIXEL
			)
			paint.metallic_specular = 0.0
			paint.roughness = 1.0
			mesh.material_override = paint
			source.add_child(mesh)
			locations.append(Vector2i(camera.unproject_position(mesh.position)))
	var final := SubViewport.new()
	final.size = source.size
	final.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(final)
	var rect := TextureRect.new()
	rect.texture = source.get_texture()
	rect.size = Vector2(source.size)
	var finish := ShaderMaterial.new()
	finish.shader = load("res://modules/shell/prototype/gallery_walk4/gamecube.gdshader")
	rect.material = finish
	final.add_child(rect)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var raw := source.get_texture().get_image()
	if not output_dir.is_empty():
		raw.save_png(output_dir.path_join("chart-3d-source.png"))
	var color_error := 0.0
	var engine_error := 0.0
	# Independent, precomputed oracle: Godot GLES3 tonemap_inc.glsl's sRGB
	# approximation round-trip, rounded to RGBA8; not our finish shader output.
	# https://github.com/godotengine/godot/blob/4.5/drivers/gles3/shaders/tonemap_inc.glsl
	var engine_codes := [
		[0, 0, 0],
		[255, 255, 255],
		[64, 64, 64],
		[128, 128, 128],
		[191, 191, 191],
		[229, 204, 153],
		[204, 23, 23],
		[23, 50, 204]
	]
	var samples := []
	for i in locations.size():
		var color := raw.get_pixelv(locations[i])
		var expected: Color = colors[i % colors.size()]
		for channel in 3:
			color_error = maxf(color_error, absf(color[channel] - expected[channel]))
			engine_error = maxf(
				engine_error,
				absf(color[channel] - float(engine_codes[i % colors.size()][channel]) / 255.0)
			)
		samples.append([color.r, color.g, color.b])
	check(
		engine_error <= 1.1 / 255.0,
		"3D unlit/white-ambient chart deviates from independent engine color oracle"
	)
	print(
		"COLOR_3D backend=",
		RenderingServer.get_current_rendering_method(),
		" viewport=160x80 msaa=2x max_paint_error=",
		color_error,
		" max_engine_oracle_error=",
		engine_error,
		" samples=",
		JSON.stringify(samples)
	)
	for mode in [0, 1, 2]:
		quantization_mode = mode
		finish.set_shader_parameter("quantization_mode", mode)
		finish.set_shader_parameter("copy_filter", 0.5 if mode != 0 else 0.0)
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		var result := final.get_texture().get_image()
		if not output_dir.is_empty():
			result.save_png(output_dir.path_join("chart-3d-mode-%d.png" % mode))
		var worst := 0.0
		for location in locations:
			var wanted := row(raw, location.x, location.y, 0.125 if mode != 0 else 0.0)
			var got := result.get_pixelv(location)
			for channel in 3:
				worst = maxf(worst, absf(got[channel] - wanted[channel]))
		check(worst <= 1.1 / 255.0, "3D-to-finish conversion changed chart color unexpectedly")
		print("COLOR_3D_FINISH mode=", mode, " max_error=", worst)
	source.queue_free()
	final.queue_free()
