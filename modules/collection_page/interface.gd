## The collection_page seam. Other modules reference this file only. Frozen: changing it is an Issue.
##
## The Collection page is the Tenant of the Collection Tab (map #23, ticket #27): the RISD Museum
## "Collections page" look — sliced header and Info box from the owner's reference, object cut-outs
## on a white ground — over one static record file, data/collection.json. Every card is a real
## record { id, title, maker, department, medium, year, has_image, has_video, has_3d, thumbnail }
## and the page never invents one. Three filters work — medium, sort by date, has image — with a
## count that follows them. A card click emits `card_selected(record)` and changes nothing else;
## opening another Tab from a card is wired after the seam (the map's cross-tab item).
##
## Tenant contract (shell/interface.gd): create(deps) returns a full-rect Control that lays itself
## out from its own size; state() is the harness probe. Text inside the page uses a real font
## (Liberation Sans, assets/); the strip stays font-free.
##
## Every public function returns { ok: bool, value: Variant, error: Variant }; errors are the
## values in errors.gd; nothing is raised across this seam.
class_name CollectionPageInterface
extends RefCounted

const Errors := preload("res://modules/collection_page/errors.gd")
const _Impl := preload("res://modules/collection_page/collection_page.gd")


## Build the page: deps = { "key": String } is what the Shell passes and is not needed here.
## Loads data/collection.json and every sliced pixel file; returns ok(page Control) or
## err(DATA_MISSING | DATA_INVALID | ASSET_MISSING).
static func create(deps: Dictionary) -> Dictionary:
	return _Impl.create(deps)


## Change part of the filter: any of { "medium": String, "sort": "none"|"newest"|"oldest",
## "has_image": bool }; keys left out keep their value. The grid and the count update at once.
## Returns ok(state value) or err(FILTER_INVALID) with nothing changed.
static func set_filter(page: Control, filter: Dictionary) -> Dictionary:
	return page.set_filter(filter)


## Everything a harness needs, in the page's own pixels:
## ok({ total, count, filter: { medium, sort, has_image }, mediums: [String],
##      cards: [{ id, title, rect }] (every card that passes the filter, in grid order — not clipped
##      to the scroll view, so a rect may lie below the page),
##      controls: { medium, sort, has_image: rect }, size }).
static func state(page: Control) -> Dictionary:
	return page.state()


## Signals on the page node:
##   card_selected(record: Dictionary) — a card was clicked; the record as loaded from the data file
