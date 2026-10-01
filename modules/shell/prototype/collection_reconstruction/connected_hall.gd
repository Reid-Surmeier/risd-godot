## #182/#183 reuse only the existing Hall's geometry/assets inside the connected prototype.
extends "res://modules/shell/prototype/gallery_walk4/walk4.gd"

# The room owner builds real shared doorway walls and a continuous clipped floor.
# These replace the old standalone demonstration's photo cards and fictitious vestibules.
func _build_floor() -> void:
	pass

func _arch_end() -> void:
	pass

func _far_end() -> void:
	pass
