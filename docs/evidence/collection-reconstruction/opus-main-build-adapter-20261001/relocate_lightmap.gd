extends SceneTree
func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	assert(args.size() == 2)
	var data := load(args[0]) as LightmapGIData
	assert(data != null and data.get_user_count() > 0)
	assert(ResourceSaver.save(data, args[1]) == OK)
	var saved := load(args[1]) as LightmapGIData
	assert(saved != null and saved.get_user_count() == data.get_user_count())
	print("LIGHTMAP_TEXT_COPY_OK users=", saved.get_user_count())
	quit()
