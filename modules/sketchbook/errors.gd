## Error values of the sketchbook module. Frozen: changing this file is an Issue.
class_name SketchbookErrors
extends RefCounted

## A pixel file the sketchbook loads — a frame slice, an arrow button, the page or the pencil —
## is not in the project (detail: its path).
const ASSET_MISSING := "sketchbook.asset_missing"


static func err(code: String, detail: String = "") -> Dictionary:
	return {"ok": false, "value": null, "error": {"code": code, "detail": detail}}


static func ok(value = null) -> Dictionary:
	return {"ok": true, "value": value, "error": null}
