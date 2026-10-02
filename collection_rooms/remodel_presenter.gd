## Isolated Collection demo: exact Main Hall page art and screen shaders, no Tenant integration.
extends Control

var scene: Node3D
var desktop: SubViewport
var screen: TextureRect

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.WHITE)
	desktop=SubViewport.new()
	desktop.size=Vector2i(1080,1080)
	desktop.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	desktop.transparent_bg=false
	add_child(desktop)
	var white:=ColorRect.new()
	white.color=Color.WHITE
	white.size=Vector2(1080,1080)
	desktop.add_child(white)
	var page:=TextureRect.new()
	page.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	page.texture=load("res://collection_rooms/presentation/page.png")
	page.size=Vector2(1080,1080)
	assert(page.size==Vector2(1080,1080),"Page art must fit the desktop before measuring its opening")
	page.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	page.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	desktop.add_child(page)
	var scale_factor:=minf(page.size.x/page.texture.get_width(),page.size.y/page.texture.get_height())
	var origin:Vector2=(page.size-page.texture.get_size()*scale_factor)/2
	var game:=SubViewportContainer.new()
	game.position=(origin+Vector2(458,521)*scale_factor).round()
	game.size=(Vector2(2110,1412)*scale_factor).round()
	game.stretch=true
	game.stretch_shrink=maxi(1,roundi(game.size.x/480.0))
	game.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
	game.material=ShaderMaterial.new()
	game.material.shader=load("res://collection_rooms/presentation/gamecube.gdshader")
	page.add_child(game)
	var view:=SubViewport.new()
	view.own_world_3d=true
	view.msaa_3d=Viewport.MSAA_2X
	game.add_child(view)
	scene=load("res://collection_rooms/remodel_room.tscn").instantiate()
	view.add_child(scene)
	scene.label.hide()
	screen=TextureRect.new()
	screen.texture=desktop.get_texture()
	screen.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	screen.stretch_mode=TextureRect.STRETCH_SCALE
	screen.material=ShaderMaterial.new()
	screen.material.shader=load("res://collection_rooms/presentation/crt_luminance.gdshader")
	screen.material.set_shader_parameter("tex",desktop.get_texture())
	screen.material.set_shader_parameter("curve",.018)
	screen.material.set_shader_parameter("quiet_rect",Vector4(game.position.x/1080,game.position.y/1080,(game.position.x+game.size.x)/1080,(game.position.y+game.size.y)/1080))
	add_child(screen)
	for name in ["squiggle_screen","haze_screen"]:
		var effect:=ColorRect.new()
		effect.mouse_filter=Control.MOUSE_FILTER_IGNORE
		effect.material=ShaderMaterial.new()
		effect.material.shader=load("res://collection_rooms/presentation/"+name+".gdshader")
		effect.material.set_shader_parameter("quiet_rect",Vector4(game.position.x/1080,game.position.y/1080,(game.position.x+game.size.x)/1080,(game.position.y+game.size.y)/1080))
		effect.material.set_shader_parameter("desktop_curve",.018)
		if name=="squiggle_screen":
			var noise:=NoiseTexture2D.new()
			noise.width=256
			noise.height=256
			noise.seamless=true
			noise.seamless_blend_skirt=1.0
			noise.noise=FastNoiseLite.new()
			effect.material.set_shader_parameter("noise",noise)
		add_child(effect)
	resized.connect(fit)
	fit()

func fit() -> void:
	var side:=minf(size.x,size.y)
	for surface in get_children():
		if surface is Control:
			surface.position=(size-Vector2.ONE*side)/2
			surface.size=Vector2.ONE*side

func _input(event: InputEvent) -> void:
	# Movement is physical keyboard state; forward only view/reset shortcuts.
	if event is InputEventKey:scene._unhandled_key_input(event)
