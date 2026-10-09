## Sculpture Viewer seam; #170 authorizes the square catalogue and updated state probe.
## The Tenant lays out from its own Page size and freezes with the Shell.
## #157 owner correction accepts four current scans in the retained player and sidebar.
## All functions return { ok, value, error }; errors remain defined in errors.gd.
class_name SculptureViewerInterface
extends RefCounted

const Errors := preload("res://modules/sculpture_viewer/errors.gd")
const _IMPL := preload("res://modules/sculpture_viewer/desktop.gd")


## Build the five-row, four-column catalogue Tenant, recording deps.key.
static func create(deps: Dictionary) -> Dictionary:
	return _IMPL.create(deps)


## Unchanged live Buddha viewer for the approved embedding host (Sketchbook).
## This diagnostic model is separate from the twenty catalogue selections.
static func embedded_viewer() -> Dictionary:
	return _IMPL.embedded_viewer()


## ok({ key, ticks, inputs, size: Vector2, desktop_scale,
## rows: 5, columns: 4, cards: Array[Rect2] (global Page coordinates),
## selected, hovered (-1 outside cells), selected_id, selected_name,
## department: "unverified", hover_tick, "3d_preview_available": bool (selected scan index < 4) }).
## ticks, inputs and hover_tick stand still while the Shell freezes this Page.
static func state(tenant: Control) -> Dictionary:
	return tenant.state()
