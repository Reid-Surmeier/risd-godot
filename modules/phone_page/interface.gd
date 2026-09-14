## The phone_page seam. Other modules reference this file only. Frozen: changing it is an Issue.
##
## The Phone Tab's Tenant, shown as a draft mockup (map #23, owner correction 2026-09-13): the
## owner's reference picture of the Nokia handset — a byte-identical copy of
## docs/evidence/phone/reference.png (269x537), see PROVENANCE.md — at its native size,
## centred on a white Page. It satisfies the Shell's Tenant contract (modules/shell/interface.gd):
## create(deps) returns a full-rect Control that lays itself out from its own size / resized, and
## state() is the harness probe. Nothing in it reacts to input; it only counts what reaches it.
##
## Every public function returns { ok: bool, value: Variant, error: Variant }; errors are the
## values in errors.gd; nothing is raised across this seam.
class_name PhonePageInterface
extends RefCounted

const Errors := preload("res://modules/phone_page/errors.gd")
const _Impl := preload("res://modules/phone_page/phone_page.gd")


## Build the Tenant. `deps` is what the Shell passes, { "key": String }; the key is recorded.
## Returns ok(Control) or err(ASSET_MISSING, path) when the reference picture cannot be loaded.
static func create(deps: Dictionary) -> Dictionary:
	return _Impl.create(deps)


## The harness probe, in the Tenant's own pixels:
## ok({ key, ticks, inputs, size: Vector2, image_size: Vector2 (the picture's native size),
##      image_rect: Rect2 (where it is drawn, centred in size) }).
## `ticks` counts _process frames and `inputs` counts _unhandled_input events: both stand still
## while the Page is frozen.
static func state(tenant: Control) -> Dictionary:
	return tenant.state()
