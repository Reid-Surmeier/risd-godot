## The flowers_page seam. Other modules reference this file only. Frozen: changing it is an Issue.
##
## The Flowers Tab's Tenant: Ferry Halim's Orisinal "Flowers" (2001, used with the owners'
## permission), the same SWFs the site serves at ferryhalim.com/orisinal/flowers/, run by the same
## Ruffle build the site uses, self-hosted beside the Web export
## (web/, copied to <build>/flowers/ by
## scripts/export-web.sh). The game sits in one window centred on a white Page, at the site's
## 750x422 aspect, scaled to fit. On the Web the Ruffle player is HTML over the canvas at that
## window's place (carried through the CRT warp's inverse), hidden with the Page; elsewhere the
## window shows the game's own title frame as a still.
##
## Tenant contract (shell/interface.gd): create(deps) returns a full-rect Control that lays itself
## out from its own size / resized; state() is the harness probe; the Shell freezes the Page while
## hidden and resumes it intact.
##
## Every public function returns { ok: bool, value: Variant, error: Variant }; errors are the
## values in errors.gd; nothing is raised across this seam.
class_name FlowersPageInterface
extends RefCounted

const Errors := preload("res://modules/flowers_page/errors.gd")
const _IMPL := preload("res://modules/flowers_page/flowers_page.gd")


## Build the Page. `deps` is the Shell's { key }. Returns ok(Control) or err(ASSET_MISSING, path).
static func create(deps: Dictionary) -> Dictionary:
	return _IMPL.create(deps)


## The harness probe: ok({ key, ticks, window: Rect2, factor, web: bool, placement: String }),
## `placement` the JSON last handed to the page ("null" while hidden or off the Web).
static func state(tenant: Control) -> Dictionary:
	return tenant.state()
