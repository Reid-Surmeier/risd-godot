@tool
extends EditorPlugin

const DIR := "res://modules/shell/prototype/gallery_walk4/baked/"

func _enter_tree() -> void:
	call_deferred("_bake_room")

func _bake_room() -> void:
	await get_tree().create_timer(2).timeout
	EditorInterface.open_scene_from_path(DIR + "room.tscn")
	await get_tree().create_timer(2).timeout
	var room := EditorInterface.get_edited_scene_root()
	var lightmap := room.get_node("Lightmap") as LightmapGI
	EditorInterface.edit_node(lightmap)
	await get_tree().create_timer(1).timeout
	# Baking is editor-only, without a public GDScript bake method in Godot 4.7.
	for button in EditorInterface.get_base_control().find_children("*", "Button", true, false):
		if button.text == "Bake Lightmaps":
			button.pressed.emit()
			await get_tree().create_timer(1).timeout
			for dialog in button.find_children("*", "EditorFileDialog", true, false):
				if dialog.visible:
					dialog.hide()
					dialog.file_selected.emit(DIR + "room.lmbake")
			await get_tree().create_timer(2).timeout
			if lightmap.light_data == null or lightmap.light_data.get_user_count() == 0:
				push_error("Gallery bake produced no lightmap users")
				get_tree().quit(1)
				return
			for light in room.find_children("*", "Light3D", true, false):
				light.get_parent().remove_child(light)
				light.queue_free()
			var error := EditorInterface.save_scene()
			if error != OK:
				push_error("Saving baked room failed: " + error_string(error))
				get_tree().quit(1)
				return
			print("BAKE_OK users=", lightmap.light_data.get_user_count())
			get_tree().quit()
			return
	push_error("Godot Bake Lightmaps control not found")
	get_tree().quit(1)
