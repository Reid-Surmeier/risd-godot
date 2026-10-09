extends SceneTree
func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	assert(args.size() == 2)
	var data := load(args[0]) as LightmapGIData
	assert(data != null and data.get_user_count() > 0)
	var probes: Dictionary = data.get("probe_data")
	assert(probes.points.size() > 0, "A real renderer is required to preserve light probes")
	assert(ResourceSaver.save(data, args[1]) == OK)
	var saved := ResourceLoader.load(args[1], "LightmapGIData", ResourceLoader.CACHE_MODE_IGNORE) as LightmapGIData
	assert(saved != null and saved.get_user_count() == data.get_user_count())
	assert(saved.get("probe_data") == probes, "Lightmap conversion changed the probe field")
	print("LIGHTMAP_TEXT_COPY_OK users=", saved.get_user_count(), " probes=", probes.points.size())
	quit()
