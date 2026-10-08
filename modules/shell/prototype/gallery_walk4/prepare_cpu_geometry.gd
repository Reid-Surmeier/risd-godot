## Offline #281 geometry extraction; renderer reads are allowed here, never at launch.
## Run with Godot 4.7.2 --path . --script
## res://modules/shell/prototype/gallery_walk4/prepare_cpu_geometry.gd.
extends SceneTree

const Walk := preload("res://modules/shell/prototype/gallery_walk4/walk4.gd")
const Cpu := preload("res://modules/shell/prototype/gallery_walk4/cpu_geometry.gd")
const Kit := preload("res://modules/shell/character/demo.gd")
const HOME := "res://modules/shell/prototype/gallery_walk4/"


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var walk := Walk.new()
	walk._vp = SubViewport.new()
	walk.add_child(walk._vp)
	walk._build_room()
	walk._build_paintings()
	var primitives := {}
	for instance in walk._vp.find_children("*", "MeshInstance3D", true, false):
		if instance.mesh is PrimitiveMesh:
			var key := Cpu.primitive_key(instance.mesh)
			if not primitives.has(key):
				primitives[key] = instance.mesh.surface_get_arrays(0)
	var native := Resource.new()
	native.set_meta("arrays", primitives)
	assert(
		ResourceSaver.save(native, HOME + "native_cpu_arrays.res", ResourceSaver.FLAG_COMPRESS) == OK
	)
	walk.free()

	var model: Node3D = load("res://modules/shell/character/walk.glb").instantiate()
	var skeleton: Skeleton3D = model.find_children("*", "Skeleton3D", true, false)[0]
	var kit := Kit.new()
	kit.model = model
	kit.skeleton = skeleton
	kit.make_face()
	var records := []
	var feet := {"LeftFoot": [], "RightFoot": []}
	for mesh in model.find_children("*", "MeshInstance3D", true, false):
		var materials := []
		for surface in mesh.mesh.get_surface_count():
			materials.append(mesh.get_surface_override_material(surface))
			var arrays: Array = mesh.mesh.surface_get_arrays(surface)
			for vertex in arrays[Mesh.ARRAY_VERTEX].size():
				for influence in 4:
					if arrays[Mesh.ARRAY_WEIGHTS][vertex * 4 + influence] < 0.9999:
						continue
					var bind: int = arrays[Mesh.ARRAY_BONES][vertex * 4 + influence]
					var bone: int = mesh.skin.get_bind_bone(bind)
					if bone < 0:
						bone = skeleton.find_bone(mesh.skin.get_bind_name(bind))
					var name := skeleton.get_bone_name(bone)
					if feet.has(name):
						feet[name].append(mesh.skin.get_bind_pose(bind) * arrays[Mesh.ARRAY_VERTEX][vertex])
		records.append({"path": model.get_path_to(mesh), "mesh": mesh.mesh, "materials": materials})
	var visitor := Resource.new()
	visitor.set_meta("meshes", records)
	visitor.set_meta("feet", feet)
	assert(
		ResourceSaver.save(
			visitor, "res://modules/shell/character/launch_geometry.res", ResourceSaver.FLAG_COMPRESS
		) == OK
	)
	print(
		"CPU_GEOMETRY_READY primitives=", primitives.size(), " visitor_meshes=", records.size(),
		" feet=", feet.LeftFoot.size(), "/", feet.RightFoot.size()
	)
	model.free()
	kit.free()
	quit()
