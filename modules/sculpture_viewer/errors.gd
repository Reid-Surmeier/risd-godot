## Error values of the sculpture_viewer module. Frozen: changing this file is an Issue.
class_name SculptureViewerErrors
extends RefCounted

## A file the viewer loads — the Buddha GLB, its texture, a chrome plate, a control atlas, a shader
## or the catalogue picture — is not in the project (detail: its path).
const ASSET_MISSING := "sculpture_viewer.asset_missing"


static func err(code: String, detail: String = "") -> Dictionary:
	return {"ok": false, "value": null, "error": {"code": code, "detail": detail}}


static func ok(value = null) -> Dictionary:
	return {"ok": true, "value": value, "error": null}
