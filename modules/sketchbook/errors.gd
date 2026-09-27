## Error values of the sketchbook module. Frozen: changing this file is an Issue.
class_name SketchbookErrors
extends RefCounted

const INVALID_DEPENDENCY := "sketchbook.invalid_dependency"

## A file the sketchbook loads — a frame slice, an arrow button, the page, a paintbox picture, the brush
## shader or the Mixbox script — is not in the project (detail: its path).
const ASSET_MISSING := "sketchbook.asset_missing"


static func err(code: String, detail: String = "") -> Dictionary:
	return {"ok": false, "value": null, "error": {"code": code, "detail": detail}}


static func ok(value = null) -> Dictionary:
	return {"ok": true, "value": value, "error": null}
