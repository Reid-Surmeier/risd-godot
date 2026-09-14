## Playtest harness for collection_page: builds the Shell with this page as the Collection Tenant
## and nothing in the other Tabs, then plays it the way a person does — real InputEventMouseButton
## events through Input.parse_input_event on the filter controls, a card and the tabs — and reports
## what it did and what the interfaces said. The interface is called only for what a caller would
## call (state, one invalid set_filter). Args: --out-dir=<path>. Writes numbered screenshots and
## report.json there.
extends "res://testing/harness_base.gd"

const Shell := preload("res://modules/shell/interface.gd")
const Page := preload("res://modules/collection_page/interface.gd")


func _shell_state(shell: Control, label: String) -> Dictionary:
	var s: Dictionary = Shell.state(shell).value
	var tabs := []
	for t in s.tabs:
		tabs.append({"key": t.key, "page_visible": t.page_visible, "frozen": t.frozen, "tenant": t.tenant,
				"rect": _rect(t.rect)})
	var ts: Dictionary = Shell.tenant_state(shell, "collection")
	var entry := {"t_ms": _ms(), "event": "shell", "label": label, "active": s.active, "count": s.count,
			"tabs": tabs, "tenant_ok": ts.ok, "tenant_code": ts.error.code if not ts.ok else ""}
	_log.append(entry)
	return entry


func _page_state(page: Control, label: String) -> Dictionary:
	var s: Dictionary = Page.state(page).value
	var cards := []
	for c in s.cards:
		cards.append({"id": c.id, "title": c.title, "rect": _rect(c.rect)})
	var controls := {}
	for n in s.controls:
		controls[n] = _rect(s.controls[n])
	var entry := {"t_ms": _ms(), "event": "page", "label": label, "total": s.total, "count": s.count,
			"filter": s.filter, "mediums": s.mediums, "cards": cards, "controls": controls,
			"size": [s.size.x, s.size.y]}
	_log.append(entry)
	return entry


func _click_control(page: Control, name: String) -> void:
	var s: Dictionary = Page.state(page).value
	await _click(_center(page, s.controls[name]), "control " + name)
	await _frames(2)


func _initialize() -> void:
	var root := get_root()
	var shell: Control = Shell.create({"collection": Page}).value
	var out_dir := await _mount(shell, Vector2i(1920, 1080), "/tmp/collection_page-playtest")
	var page: Control = shell.find_child("CollectionPage", true, false)
	page.card_selected.connect(func(record: Dictionary) -> void:
		_log.append({"t_ms": _ms(), "event": "signal", "signal": "card_selected", "id": record.id,
				"title": record.title, "keys": record.keys()}))

	# 1. launch: Collection is the active tab and its tenant is this page, every record on a card
	_shell_state(shell, "launch")
	_page_state(page, "launch")
	await _shot(out_dir, "01-launch.png")

	# 2. click the Has-image filter: the grid narrows to the records with a photograph
	await _click_control(page, "has_image")
	_page_state(page, "has-image")
	await _shot(out_dir, "02-has-image.png")

	# 3. click Medium once (the first medium), then Has-image off, then Medium round to Video
	await _click_control(page, "medium")
	_page_state(page, "medium-first-with-image")
	await _shot(out_dir, "03-medium-first.png")
	await _click_control(page, "has_image")
	_page_state(page, "medium-first")
	var s: Dictionary = Page.state(page).value
	var steps: int = s.mediums.find("Video") - s.mediums.find(s.filter.medium)
	for i in steps:
		await _click_control(page, "medium")
	_page_state(page, "medium-video")
	await _shot(out_dir, "04-medium-video.png")

	# 4. Sort by date: newest, then oldest; then Medium wraps round to All
	await _click_control(page, "sort")
	_page_state(page, "video-newest")
	await _click_control(page, "sort")
	_page_state(page, "video-oldest")
	await _click_control(page, "medium")
	_page_state(page, "all-oldest")
	await _shot(out_dir, "05-all-oldest.png")

	# 5. click the first card: card_selected(record) and nothing else changes
	var before: Dictionary = _page_state(page, "before-card")
	var first: Dictionary = before.cards[0]
	await _click(_center(page, Rect2(first.rect.x, first.rect.y, first.rect.w, first.rect.h)), "card " + first.id)
	await _frames(2)
	_page_state(page, "after-card")
	await _shot(out_dir, "06-after-card.png")
	# a click on the white ground between the grid and the Info box emits nothing
	var ps: Dictionary = Page.state(page).value
	await _click(page.get_global_transform() * Vector2(ps.size.x / 2.0, ps.size.y - 4.0), "white ground")
	await _frames(2)
	_page_state(page, "after-ground")

	# 6. an invalid filter through the interface is refused and changes nothing
	var refused: Dictionary = Page.set_filter(page, {"medium": "Marble"})
	_log.append({"t_ms": _ms(), "event": "set_filter_invalid", "ok": refused.ok,
			"code": refused.error.code if not refused.ok else ""})
	_page_state(page, "after-invalid")

	# 7. switch to the Map tab and back: the page is frozen while hidden and resumes with its filter
	var sh: Dictionary = _shell_state(shell, "pre-map")
	var map_rect: Dictionary = sh.tabs[0].rect
	await _click(_center(shell, Rect2(map_rect.x, map_rect.y, map_rect.w, map_rect.h)), "map tab")
	await _frames(2)
	_shell_state(shell, "map")
	await _shot(out_dir, "07-map.png")
	var col_rect: Dictionary = sh.tabs[4].rect
	await _click(_center(shell, Rect2(col_rect.x, col_rect.y, col_rect.w, col_rect.h)), "collection tab")
	await _frames(2)
	_shell_state(shell, "collection-again")
	_page_state(page, "collection-again")
	await _shot(out_dir, "08-collection-again.png")

	# 8. the 1440x900 minimum: the page lays out from its own size, the Info box stays at the bottom
	root.size = Vector2i(1440, 900)
	await _frames(3)
	_page_state(page, "resized")
	await _shot(out_dir, "09-resized.png")

	_finish(out_dir)
