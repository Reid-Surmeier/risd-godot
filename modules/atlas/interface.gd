## The atlas seam. Other modules reference this file only. Frozen: changing it is an Issue.
##
## The Pixel Atlas is the Map Tab's Tenant (map #23, port order first). It satisfies the Shell's
## Tenant contract (modules/shell/interface.gd): create(deps) returns a full-rect Control that lays
## itself out from its own size / resized, and state() is the harness probe. The Page is the
## prototype's whole desktop (map #23, owner correction): four supplied raster panels — minimap,
## itinerary, chat, notification — around one map window, all draggable, a press raising the
## pressed one; the map window is also resizable, collapsible and lockable, sliced from the
## prototype's frame pixels, and its body is a SubViewport holding the zoomable pixel atlas: the
## world terrain, ten regional sheets with their Muse-drawn labels and badges, GeoNames close-city
## names in PixelMplus, and Natural Earth coastline tiles at close zoom. The composition is the
## prototype's 1950x1280 desktop scaled to fit the Page and centred; a Page resize restores it.
## Its SubViewport stops updating while the Page is hidden, so a frozen Page renders nothing.
##
## Inside the map (only while its Page is shown): drag pans, wheel zooms at the pointer,
## double-click zooms in, Home/Esc reset, + and - zoom, arrows pan, F toggles the region's full
## sheet; the HUD picks a region. The frame drags by its title bar, resizes by its edges, collapses
## by its left button and locks by its right one (the lock holds the frame only). A panel drags from
## anywhere on it; a wheel over a panel is swallowed, so the map beneath does not zoom.
##
## Every public function returns { ok: bool, value: Variant, error: Variant }; errors are the
## values in errors.gd; nothing is raised across this seam.
class_name AtlasInterface
extends RefCounted

const Errors := preload("res://modules/atlas/errors.gd")
const _IMPL := preload("res://modules/atlas/atlas_window.gd")


## Build the Map Tenant. `deps` is what the Shell passes, { "key": String }; the key is recorded.
## The two data files (atlas.json, close-cities.json) are checked first: returns ok(Control) or
## err(ASSET_MISSING, path). A missing pixel sheet, font or shader is reported by load() as it is
## reached.
static func create(deps: Dictionary) -> Dictionary:
	return _IMPL.create(deps)


## The harness probe, in the Tenant's own pixels unless said otherwise:
## ok({ key, ticks, inputs, size: Vector2, frame: Rect2, frame_global: Rect2
## (global), map_rect: Rect2 (global),
##      chrome_scale, locked, collapsed, action: "" | "drag" | "resize", viewport_update_mode,
##      panels: { minimap | itinerary | chat | notification: Rect2 }, stack: [String] (child order,
##      bottom to top: the four panel names and "map"), moving_window: "" | String,
## mode: "atlas" | "sheet", region, zoom, zoom_ratio, zoom_min, zoom_max, position: [x, y] (world),
## viewport: [w, h] (the SubViewport), vertical_pan_locked, visible_cities, visible_close_cities,
##      visible_labels, visible_annotations, terrain_tiles, shown_cities,
##      controls: { name: [x, y, w, h] }, popup: { visible, position, size } }).
## `controls` and `popup` are in the SubViewport's own global pixels
## (the map's HUD), not the Page's;
## `panels` are in the Tenant's own pixels like `frame`.
## `ticks` counts the window's _process frames and `inputs` its _input events: both stand still
## while the Page is frozen.
static func state(tenant: Control) -> Dictionary:
	return tenant.state()
