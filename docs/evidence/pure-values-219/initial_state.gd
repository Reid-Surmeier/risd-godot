extends SceneTree

const FILES := [
	"modules/playground_page/playground_page.gd",
	"modules/shell/crt_display.gd",
	"modules/sketchbook/desktop.gd",
	"modules/sketchbook/drawing_surface.gd",
	"modules/sketchbook/paintbox.gd",
]
var allocated: Array[Node] = []


func snapshot(value: Variant) -> Variant:
	if value is Object:
		if value is Node and not allocated.has(value):
			allocated.append(value)
		var fields := {}
		var script: Script = value.get_script()
		if script != null:
			for property in script.get_script_property_list():
				if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
					fields[property.name] = snapshot(value.get(property.name))
		return {"class": value.get_class(), "fields": fields}
	if value is Array:
		var entries := []
		for entry in value:
			entries.append(snapshot(entry))
		return {"type": type_string(typeof(value)), "entries": entries}
	if value is Dictionary:
		var entries := {}
		for key in value:
			entries[var_to_str(key)] = snapshot(value[key])
		return {"type": "Dictionary", "entries": entries}
	return {"type": type_string(typeof(value)), "value": var_to_str(value)}


func _initialize() -> void:
	var result := {}
	var args := OS.get_cmdline_user_args()
	var sources := {}
	if args.size() > 1:
		sources = JSON.parse_string(FileAccess.get_file_as_string(args[1]))
	for path in FILES:
		var script := GDScript.new()
		script.source_code = sources.get(path, FileAccess.get_file_as_string("res://" + path))
		assert(script.reload() == OK, path)
		var instance = script.new()
		var static_fields := {}
		if path.ends_with("drawing_surface.gd") or path.ends_with("paintbox.gd"):
			static_fields["_blank_cursor"] = snapshot(script.get("_blank_cursor"))
		result[path] = {"instance": snapshot(instance), "static": static_fields}
	for node in allocated:
		node.free()
	var output := args[0]
	FileAccess.open(output, FileAccess.WRITE).store_string(JSON.stringify(result, "\t", true))
	print("INITIAL_STATE219 PASS: all declared fields in five fresh scripts")
	quit()
