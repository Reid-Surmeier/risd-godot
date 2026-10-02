## Headless: the helper loads beside the root helper copies and every object instantiates into a tree.
extends SceneTree
func _initialize() -> void:
	var Asset = load("res://medieval_ceramic_ivory_assets.gd")
	for key in ["queens", "christ"]:
		var node: Node3D = Asset.build(key)
		root.add_child(node)
		print(node.name, ": ", node.get_child_count(), " meshes, ", node.get_meta("catalogue_accession"), ", ", node.get_meta("catalogue_identity"))
	var laid: Node3D = Asset.christ_on_wedge()
	root.add_child(laid)
	print(laid.name, ": children ", laid.get_children().map(func(c): return c.name), ", ivory origin ", laid.get_node("Christ").position)
	quit(0)
