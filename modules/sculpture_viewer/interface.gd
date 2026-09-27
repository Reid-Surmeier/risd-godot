## The sculpture_viewer seam. Other modules reference this file only. Frozen: changing it is an Issue.
##
## The Sculpture Viewer is the 3D Viewer Tab's Tenant (map #23, ticket #32: two Tenants sharing
## nothing but the Shell). It satisfies the Shell's Tenant contract (modules/shell/interface.gd):
## create(deps) returns a full-rect Control that lays itself out from its own size / resized, and
## state() is the harness probe. Its Page is the prototype's whole desktop (owner correction on
## map #23): the 1440x972 white desktop scaled to fit the Page, with the catalogue window (the
## sidebar picture, drag only) and the 800x680 3D sculpture viewer window — a SubViewport holding
## the Buddha scan under its studio light; drag orbits, the wheel zooms, previous / next step 30
## degrees, play / pause runs the 8 deg/s autoplay orbit, the scrubber sets the yaw, audio and
## menu play their motion. Windows drag by their handles, raise on click and stack as the
## prototype's desktop.gd does; a hidden Page freezes the desktop and its SubViewport goes quiet.
##
## Every public function returns { ok: bool, value: Variant, error: Variant }; errors are the
## values in errors.gd; nothing is raised across this seam.
class_name SculptureViewerInterface
extends RefCounted

const Errors := preload("res://modules/sculpture_viewer/errors.gd")
const _Impl := preload("res://modules/sculpture_viewer/desktop.gd")


## Build the 3D Viewer Tenant. `deps` is what the Shell passes, { "key": String }; the key is
## recorded. Every file the desktop and the viewer load is checked first: returns ok(Control) or
## err(ASSET_MISSING, path).
static func create(deps: Dictionary) -> Dictionary:
	return _Impl.create(deps)


## Build the live 800x680 viewer without its catalogue desktop for an approved embedding host.
static func embedded_viewer() -> Dictionary:
	return _Impl.embedded_viewer()


## The harness probe. Rects are global pixels unless said otherwise:
## ok({ key, ticks, inputs, size: Vector2 (the Tenant), desktop_scale, pointer_scale (global px per
##      viewer px: desktop_scale x the window's 0.985), front_window, dragging,
##      catalogue_rect: Rect2, viewer_rect: Rect2, viewport_rect: Rect2 (the 3D SubViewport's
##      container), controls: { previous, next, play-pause, scrubber, audio, menu: Rect2 },
##      viewport_update_mode, yaw, pitch, distance, progress, playing, muted, active_view,
##      interaction_count, animation_count, last_animated_control, model_loaded }).
## `ticks` counts the desktop's _process frames and `inputs` its _input events: both stand still
## while the Page is frozen. `viewport_update_mode` is the 3D SubViewport's render_target_update_mode.
static func state(tenant: Control) -> Dictionary:
	return tenant.state()
