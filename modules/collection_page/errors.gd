## Error values of the collection_page module. Frozen: changing this file is an Issue.
class_name CollectionPageErrors
extends RefCounted

## data/collection.json (or the path in deps) is not there or cannot be read.
const DATA_MISSING := "collection_page.data_missing"
## The data file is not the shape the interface documents (not JSON, no records array, a record
## without id/title/maker/department/medium/year, a flag that is not a bool).
const DATA_INVALID := "collection_page.data_invalid"
## A sliced pixel file (header, Info box, a thumbnail) or the page font cannot be loaded.
const ASSET_MISSING := "collection_page.asset_missing"
## set_filter was given a key the filter does not have, or a value outside its range.
const FILTER_INVALID := "collection_page.filter_invalid"


static func err(code: String, detail: String = "") -> Dictionary:
	return {"ok": false, "value": null, "error": {"code": code, "detail": detail}}


static func ok(value = null) -> Dictionary:
	return {"ok": true, "value": value, "error": null}
