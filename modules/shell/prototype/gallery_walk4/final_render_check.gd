extends SceneTree
var failures := 0
func _initialize() -> void:
	call_deferred("run")
func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		print("FAIL ", message)
func q(image: Image, x: int, y: int) -> Vector3:
	x = clampi(x, 0, image.get_width()-1)
	y = clampi(y, 0, image.get_height()-1)
	var c := image.get_pixel(x,y)
	var out := Vector3.ZERO
	var d := ((x ^ y) & 1) * 2 + (y & 1)
	for i in 3:
		var v := floorf(c[i]*255.0+0.5)
		out[i] = clampf(floorf((v-floorf(v/64.0)+d)/4.0)/63.0,0.0,1.0)
	return out
func row(image: Image, x: int, y: int, side: float) -> Vector3:
	return q(image,x,y-1)*side + q(image,x,y)*(1.0-2.0*side) + q(image,x,y+1)*side
func run() -> void:
	var source := Image.create(8,8,false,Image.FORMAT_RGBA8)
	for y in 8:
		for x in 8:
			source.set_pixel(x,y,Color(float(x)/7.0,float(y)/7.0,float((x+y)%8)/7.0))
	var vp := SubViewport.new()
	vp.size = Vector2i(40,40)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var rect := TextureRect.new()
	rect.texture = ImageTexture.create_from_image(source)
	rect.size = Vector2(40,40)
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	var material := ShaderMaterial.new()
	material.shader = load("res://modules/shell/prototype/gallery_walk4/gamecube.gdshader")
	rect.material = material
	vp.add_child(rect)
	for strength in [0.0,0.5,1.0]:
		material.set_shader_parameter("copy_filter",strength)
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		var result := vp.get_texture().get_image()
		var worst := 0.0
		for y in 40:
			for x in 40:
				var p := Vector2((x+0.5)/5.0-0.5,(y+0.5)/5.0-0.5)
				var ix := floori(p.x)
				var iy := floori(p.y)
				var fx := p.x-floorf(p.x)
				var fy := p.y-floorf(p.y)
				var top := row(source,ix,iy,strength*0.25).lerp(row(source,ix+1,iy,strength*0.25),fx)
				var bottom := row(source,ix,iy+1,strength*0.25).lerp(row(source,ix+1,iy+1,strength*0.25),fx)
				var wanted := top.lerp(bottom,fy)
				var got := result.get_pixel(x,y)
				for channel in 3:
					worst = maxf(worst,absf(got[channel]-wanted[channel]))
		check(worst <= 1.1/255.0,"RGB6/filter/upscale error exceeds one output code")
		print("GAMECUBE_GPU filter=",strength," pixels=1600 max_error=",worst)
	for color in [Color.BLACK, Color.WHITE]:
		source.fill(color)
		rect.texture = ImageTexture.create_from_image(source)
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		var result := vp.get_texture().get_image()
		check(result.get_pixel(20,20).is_equal_approx(color),"black/white changed")
	await check_quiet_stack()
	check_mapping_refresh()
	print("FINAL_RENDER_GPU_FAILURES ",failures)
	quit(failures)

func check_quiet_stack() -> void:
	var source := Image.create(40,40,false,Image.FORMAT_RGBA8)
	for y in 40:
		for x in 40:
			source.set_pixel(x,y,Color(0.2 if x%2 else 0.8, float(y)/40.0, 0.4))
	var texture := ImageTexture.create_from_image(source)
	var vp := SubViewport.new()
	vp.size = Vector2i(40,40)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var rect := TextureRect.new()
	rect.texture = texture
	rect.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	rect.size = Vector2(40,40)
	vp.add_child(rect)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var baseline := vp.get_texture().get_image()
	var material := ShaderMaterial.new()
	material.shader = load("res://modules/shell/crt_luminance.gdshader")
	material.set_shader_parameter("tex",texture)
	material.set_shader_parameter("quiet_rect",Vector4(0,0,1,1))
	rect.material = material
	var haze := ColorRect.new()
	haze.size = Vector2(40,40)
	var haze_mat := ShaderMaterial.new()
	haze_mat.shader = load("res://modules/shell/haze_screen.gdshader")
	haze_mat.set_shader_parameter("quiet_rect",Vector4(0,0,1,1))
	haze.material = haze_mat
	vp.add_child(haze)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var result := vp.get_texture().get_image()
	var worst := 0.0
	for y in 40:
		for x in 40:
			var a := baseline.get_pixel(x,y)
			var b := result.get_pixel(x,y)
			for channel in 3:
				worst = maxf(worst,absf(a[channel]-b[channel]))
	print("QUIET_GPU CRT_and_HAZE pixels=1600 max_error=",worst)
	var passed := worst<=1.1/255.0
	material.set_shader_parameter("quiet_rect",Vector4.ZERO)
	haze_mat.set_shader_parameter("quiet_rect",Vector4.ZERO)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	result = vp.get_texture().get_image()
	var delta := absf(result.get_pixel(20,20).r-baseline.get_pixel(20,20).r)
	print("QUIET_GPU outside_region_effect_delta=",delta)
	passed = passed and delta>0.01
	check(passed, "quiet region must preserve pixels while the outside retains its finish")

func check_mapping_refresh() -> void:
	# Minimal host for the real adapter; three frame callbacks stay below its QA timer.
	var host = load("res://modules/shell/crt_display.gd").new()
	host.size = Vector2(800,600)
	var desktop := SubViewport.new()
	desktop.name = "Desktop"
	host.add_child(desktop)
	var screen := TextureRect.new()
	screen.name = "Screen"
	screen.material = ShaderMaterial.new()
	screen.material.shader = load("res://modules/shell/crt_luminance.gdshader")
	screen.material.set_shader_parameter("curve",0.018)
	screen.material.set_shader_parameter("screen_scale",0.9)
	host.add_child(screen)
	root.add_child(host)
	host.set_process(false)
	host._qa_enabled = true
	var view := Control.new()
	view.position = Vector2(100,50)
	view.size = Vector2(200,100)
	desktop.add_child(view)
	view.add_to_group("soft_render_view")
	desktop.size = Vector2i(1000,500)
	host._process(1.0/60.0)
	var haze: ShaderMaterial = host.haze.material
	check(haze.get_shader_parameter("quiet_rect").is_equal_approx(Vector4(0.1,0.1,0.3,0.3)),"mapping did not refresh on first frame")
	check(is_equal_approx(haze.get_shader_parameter("desktop_curve"),0.018) and is_equal_approx(haze.get_shader_parameter("desktop_scale"),0.9),"enabled CRT warp did not reach haze")
	desktop.size = Vector2i(800,800)
	view.position = Vector2(240,160)
	host.enabled = false
	host._process(1.0/60.0)
	var expected := Vector4(0.3,0.2,0.55,0.325)
	check(haze.get_shader_parameter("quiet_rect").is_equal_approx(expected) and host.crt_material.get_shader_parameter("quiet_rect").is_equal_approx(expected),"resized/moved exclusion stayed stale")
	check(is_equal_approx(haze.get_shader_parameter("desktop_aspect"),1.0) and is_zero_approx(haze.get_shader_parameter("desktop_curve")) and is_equal_approx(haze.get_shader_parameter("desktop_scale"),1.0),"resize/CRT toggle left stale haze coordinates")
	view.hide()
	host._process(1.0/60.0)
	check(haze.get_shader_parameter("quiet_rect") == Vector4.ZERO and host.crt_material.get_shader_parameter("quiet_rect") == Vector4.ZERO,"hidden gallery retained its exclusion")
	print("MAPPING_REFRESH production_callbacks=3 elapsed=0.05s qa_timer=",host._qa_elapsed)
	host.free()
