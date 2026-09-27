## Error values of the shell module. Frozen: changing this file is an Issue.
class_name ShellErrors
extends RefCounted

## The registry has no Tenant for this key; the Tab shows a plain white Page.
const TENANT_MISSING := "shell.tenant_missing"
## The Tenant's create(deps) returned an error or something that is not a Control.
const TENANT_FAILED := "shell.tenant_failed"
## close_tab was asked to close one of the six fixed Tabs; they never close.
const TAB_FIXED := "shell.tab_fixed"


static func err(code: String, detail: String = "") -> Dictionary:
	return {"ok": false, "value": null, "error": {"code": code, "detail": detail}}


static func ok(value = null) -> Dictionary:
	return {"ok": true, "value": value, "error": null}
