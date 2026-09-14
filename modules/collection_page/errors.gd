## Error values of the collection_page module. Frozen: changing this file is an Issue.
class_name CollectionPageErrors
extends RefCounted

## A pixel file the desktop loads (the viewer's reference sheet, a window screenshot) is not in the
## project (detail: its path).
const ASSET_MISSING := "collection_page.asset_missing"


static func err(code: String, detail: String = "") -> Dictionary:
	return {"ok": false, "value": null, "error": {"code": code, "detail": detail}}


static func ok(value = null) -> Dictionary:
	return {"ok": true, "value": value, "error": null}
