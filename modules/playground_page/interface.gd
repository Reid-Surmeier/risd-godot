## The playground_page seam. Other modules reference this file only. Frozen: changing it is an Issue
## (last changed under the owner's correction of 2026-09-14, ticket #62: the mockup became the
## composite desktop and the Phone Tab folded into it).
##
## The Playground Tab's Tenant is the owner's 2026-09-14 layout picture as a working desktop
## (docs/evidence/playground/layout-reference.png): the Digital Playground (PostPet) window on the
## left; a middle column of the options, Search filters and trade windows, with the Global Chatroom
## at the bottom; the Nokia phone on the right. Every window is a raster (PROVENANCE.md) — the four
## RO HUD windows are the Collection Tab's own screenshots with their magenta border keyed out.
## Every window drags by its title bar (the phone by its whole surface), a press raises the topmost
## window under the pointer, and a drag stops at the Page's edge.
##
## Layout (ticket #63). The desktop is `desktop` px natively. From the Page's size S the art scale is
## factor = min(S.x / desktop.x, S.y / desktop.y), uniform for every window. The leftover on the other
## axis goes to the PostPet window, whose rect runs to the middle column and to the bottom margin;
## the middle column and the phone anchor to the right edge, the chat window to the bottom edge.
## Re-laid out (drags reset) on every resize.
##
## Tenant contract (shell/interface.gd): create(deps) returns a full-rect Control that lays itself
## out from its own size / resized; state() is the harness probe; the Shell freezes the Page while
## hidden (no _process, no input) and resumes it intact. No font is used.
##
## Every public function returns { ok: bool, value: Variant, error: Variant }; errors are the
## values in errors.gd; nothing is raised across this seam.
class_name PlaygroundPageInterface
extends RefCounted

const Errors := preload("res://modules/playground_page/errors.gd")
const _Impl := preload("res://modules/playground_page/playground_page.gd")


## Build the desktop. `deps` is what the Shell passes, { "key": String }; the key is recorded.
## Every pixel file is checked first: returns ok(Control) or err(ASSET_MISSING, path).
static func create(deps: Dictionary) -> Dictionary:
	return _Impl.create(deps)


## The harness probe, in the Tenant's own pixels:
## ok({ key, ticks, inputs, size: Vector2, factor, desktop: Vector2, margin, action: "" | "drag",
##      windows: [{ name, rect: Rect2, drag_height (-1: the whole surface), order }] }), the windows
## postpet, options, filters, trade, chat, phone in stacking order (the last is on top).
## `ticks` counts _process frames and `inputs` counts _input events: both stand still while the
## Page is frozen.
static func state(tenant: Control) -> Dictionary:
	return tenant.state()
