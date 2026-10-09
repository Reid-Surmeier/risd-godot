## Error values of the playground_page module. Frozen: changing this file is an Issue.
class_name PlaygroundPageErrors
extends RefCounted

const INVALID_DEPENDENCY := "playground_page.invalid_dependency"
const PAGE_UNKNOWN := "playground_page.page_unknown"

## A pixel file the desktop loads (a window picture under assets/, PROVENANCE.md) is not in the
## project (detail: its path).
const ASSET_MISSING := "playground_page.asset_missing"


static func err(code: String, detail: String = "") -> Dictionary:
	return {"ok": false, "value": null, "error": {"code": code, "detail": detail}}


static func ok(value = null) -> Dictionary:
	return {"ok": true, "value": value, "error": null}
