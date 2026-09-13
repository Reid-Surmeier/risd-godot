## Error values of the tab_strip module. Frozen: changing this file is an Issue.
class_name TabStripErrors
extends RefCounted

## A tab index that does not exist.
const INDEX_OUT_OF_RANGE := "tab_strip.index_out_of_range"
## A label key the strip has no source pixels for (labels are sliced source pixels, not fonts).
const UNKNOWN_LABEL := "tab_strip.unknown_label"
## A new tab was requested while the previous open animation is still running.
const OPEN_IN_PROGRESS := "tab_strip.open_in_progress"
## The strip cannot fit another tab at its minimum width.
const NO_ROOM := "tab_strip.no_room"
## An asset listed in layout.json is missing or failed to load.
const ASSET_MISSING := "tab_strip.asset_missing"


static func err(code: String, detail: String = "") -> Dictionary:
	return {"ok": false, "value": null, "error": {"code": code, "detail": detail}}


static func ok(value = null) -> Dictionary:
	return {"ok": true, "value": value, "error": null}
