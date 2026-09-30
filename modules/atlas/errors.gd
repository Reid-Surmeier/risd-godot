## Error values of the atlas module. Frozen: changing this file is an Issue.
class_name AtlasErrors
extends RefCounted

## A pixel sheet, data file, font or shader the atlas loads is not in
## the project (detail: its path).
const ASSET_MISSING := "atlas.asset_missing"


static func err(code: String, detail: String = "") -> Dictionary:
	return {"ok": false, "value": null, "error": {"code": code, "detail": detail}}


static func ok(value = null) -> Dictionary:
	return {"ok": true, "value": value, "error": null}
