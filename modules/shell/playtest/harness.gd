## Playtest harness for the shell: builds the Shell the way the game's main scene does — with its
## own registry, the dummy tenant in five Tabs and nothing in phone — and plays it the way a person
## does, reporting what it did, what happened, and whether the interface responded. Real
## InputEventMouseButton and InputEventKey events through Input.parse_input_event — never a direct
## call into the strip for the gestures; the interface is called only for what the Shell's caller
## would call. Args: --out-dir=<path>. Writes numbered screenshots and report.json there.
extends "res://testing/harness_base.gd"

const Shell := preload("res://modules/shell/interface.gd")
const DummyTenant := preload("res://modules/shell/playtest/dummy_tenant.gd")


func _state(shell: Control, label: String) -> Dictionary:
	var s: Dictionary = Shell.state(shell).value
	var tabs := []
	for t in s.tabs:
		tabs.append({"key": t.key, "label": t.label, "fixed": t.fixed, "page_visible": t.page_visible,
				"frozen": t.frozen, "tenant": t.tenant, "rect": _rect(t.rect), "close_rect": _rect(t.close_rect)})
	var entry := {"t_ms": _ms(), "event": "state", "label": label, "count": s.count, "active": s.active,
			"opening": s.opening, "fixed_count": s.fixed_count, "stub_rect": _rect(s.stub_rect), "tabs": tabs,
			"window": [shell.size.x, shell.size.y]}
	_log.append(entry)
	return entry


func _tenant(shell: Control, key: String, label: String) -> Dictionary:
	var r: Dictionary = Shell.tenant_state(shell, key)
	var entry := {"t_ms": _ms(), "event": "tenant", "label": label, "key": key, "ok": r.ok,
			"code": r.error.code if not r.ok else "",
			"ticks": r.value.ticks if r.ok else -1, "inputs": r.value.inputs if r.ok else -1,
			"size": [r.value.size.x, r.value.size.y] if r.ok else [0, 0]}
	_log.append(entry)
	return entry


func _initialize() -> void:
	var root := get_root()
	var shell: Control = Shell.create({"map": DummyTenant, "sketchbook": DummyTenant, "3d_viewer": DummyTenant,
			"video_player": DummyTenant, "collection": DummyTenant}).value
	var out_dir := await _mount(shell, Vector2i(1920, 1080), "/tmp/shell-playtest")

	# 1. launch: six fixed tabs in order, Collection active and its tenant created, the rest waiting
	_state(shell, "launch")
	for key in Shell.FIXED_TABS:
		_tenant(shell, key, "launch")
	await _shot(out_dir, "01-launch.png")

	# 2. click the Map tab: its tenant is created on first show and runs
	var st: Dictionary = _state(shell, "pre-map")
	await _click(_center(shell, st.tabs[0].rect), "map tab")
	_state(shell, "map")
	var a := _tenant(shell, "map", "map-shown")
	await _frames(20)
	var b := _tenant(shell, "map", "map-after-20-frames")
	await _shot(out_dir, "02-map.png")

	# 3. click the Sketchbook tab: the Map page is frozen (its _process and input stop), Sketchbook runs
	await _click(_center(shell, st.tabs[1].rect), "sketchbook tab")
	_state(shell, "sketchbook")
	var c := _tenant(shell, "map", "map-hidden")
	var sk0 := _tenant(shell, "sketchbook", "sketchbook-shown")
	await _key(KEY_SPACE, "space key while map is hidden")
	await _frames(20)
	var d := _tenant(shell, "map", "map-hidden-after-20-frames")
	var sk1 := _tenant(shell, "sketchbook", "sketchbook-after-20-frames")
	await _shot(out_dir, "03-sketchbook.png")

	# 4. back to Map: it resumes with its count intact
	await _click(_center(shell, st.tabs[0].rect), "map tab (again)")
	_state(shell, "map-again")
	var e := _tenant(shell, "map", "map-resumed")
	await _frames(20)
	var f := _tenant(shell, "map", "map-resumed-after-20-frames")

	# 5. a fixed tab does not close: click where its close button would be, then ask the interface
	var r: Dictionary = st.tabs[0].rect
	var scale: float = r.h / 123.0
	await _click(_center(shell, {"x": r.x + r.w - (80 + 22) * scale, "y": r.y + (24 + 22) * scale,
			"w": 22 * scale, "h": 22 * scale}), "where the close button of the map tab would be")
	await create_timer(0.9).timeout
	var refused: Dictionary = Shell.close_tab(shell, 0)
	_log.append({"t_ms": _ms(), "event": "close_fixed", "ok": refused.ok,
			"code": refused.error.code if not refused.ok else ""})
	_state(shell, "fixed-kept")
	await _shot(out_dir, "04-fixed-kept.png")

	# 6. the stub still opens a Blank Page with a close button; closing it lands on the Phone tab,
	#    which has no tenant yet and shows a plain white page
	await _click(_center(shell, st.stub_rect), "new-tab stub")
	await create_timer(1.8).timeout
	_state(shell, "stub-blank")
	await _shot(out_dir, "05-stub-blank.png")
	var sb: Dictionary = _state(shell, "stub-blank")
	await _click(_center(shell, sb.tabs[sb.count - 1].close_rect), "close button of the blank tab")
	await create_timer(0.9).timeout
	_state(shell, "phone")
	_tenant(shell, "phone", "phone-shown")
	await _shot(out_dir, "06-phone.png")

	# 7. resize the window to the 1440x900 minimum: the bar re-fits, the visible tenant fills its page
	await _click(_center(shell, st.tabs[4].rect), "collection tab")
	root.size = Vector2i(1440, 900)
	await _frames(3)
	_state(shell, "resized")
	_tenant(shell, "collection", "resized")
	await _shot(out_dir, "07-resized.png")
	root.size = Vector2i(1920, 1080)
	await _frames(3)
	_state(shell, "restored")
	_tenant(shell, "collection", "restored")
	await _shot(out_dir, "08-restored.png")

	_finish(out_dir)
