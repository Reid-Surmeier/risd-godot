extends "res://trial.gd"
## Separate geometric audit: same 540 poses, shirt edge-length change versus rest.

var shirt: MeshInstance3D
var rest_edges := []
var garment_min := INF
var garment_max := 0.0

func setup() -> Node3D:
	var stage := super.setup()
	for mesh in model.find_children("*", "MeshInstance3D", true, false):
		if str(mesh.name) == "Body__mTops":
			shirt = mesh
	assert(shirt != null)
	var points := skin_points(shirt)
	var indices: PackedInt32Array = shirt.mesh.surface_get_arrays(0)[Mesh.ARRAY_INDEX]
	for i in range(0, indices.size(), 3):
		for offset in 3:
			var a := indices[i + offset]
			var b := indices[i + (offset + 1) % 3]
			var length := points[a].distance_to(points[b])
			if length > 0.00001:
				rest_edges.append([a, b, length])
	return stage

func transfer(poses: Array, look: float) -> void:
	super.transfer(poses, look)
	var points := skin_points(shirt)
	for edge in rest_edges:
		var ratio: float = points[edge[0]].distance_to(points[edge[1]]) / edge[2]
		garment_min = minf(garment_min, ratio)
		garment_max = maxf(garment_max, ratio)

func _exit_tree() -> void:
	var report := {"shirt_edges": rest_edges.size(), "minimum_edge_ratio": garment_min,
		"maximum_edge_ratio": garment_max, "poses": 540}
	FileAccess.open("res://garment-audit.json", FileAccess.WRITE).store_string(JSON.stringify(report))
	print("GARMENT ", JSON.stringify(report))
