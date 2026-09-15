## Playtest harness for the shell: builds the Shell the way the game's main scene does — with its
## own registry: the dummy tenant in four Tabs, a grey Callable-built tenant in playground (so a page
## cross-fade is visible in pixels), nothing in video_player — six fixed Tabs since the Phone Tab folded
## into the Playground desktop (owner correction 2026-09-14, ticket #62); and plays it the way a person does,
## reporting what it did, what happened, and whether the interface responded. Real
## InputEventMouseButton and InputEventKey events through Input.parse_input_event — never a direct
## call into the strip for the gestures; the interface is called only for what the Shell's caller
## would call. Args: --out-dir=<path>. Writes numbered screenshots, the launch and switch films
## (frames/), and report.json there.
extends "res://testing/harness_base.gd"

const Shell := preload("res://modules/shell/interface.gd")
const TabStrip := preload("res://modules/tab_strip/interface.gd")
const DummyTenant := preload("res://modules/shell/playtest/dummy_tenant.gd")
const GREY := Color8(160, 160, 160)


static func _grey_tenant(deps: Dictionary) -> Dictionary:
	var t := ColorRect.new()
	t.name = "GreyTenant_" + deps.get("key", "")
	t.color = GREY
	t.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return {"ok": true, "value": t, "error": null}


func _state(shell: Control, label: String) -> Dictionary:
	var s: Dictionary = Shell.state(shell).value
	var tabs := []
	for t in s.tabs:
		tabs.append({"key": t.key, "label": t.label, "fixed": t.fixed, "page_visible": t.page_visible,
				"frozen": t.frozen, "tenant": t.tenant, "rect": _rect(t.rect), "close_rect": _rect(t.close_rect)})
	var entry := {"t_ms": _ms(), "event": "state", "label": label, "count": s.count, "active": s.active,
			"opening": s.opening, "pressed": s.pressed, "switching": s.switching, "fixed_count": s.fixed_count,
			"bar_rect": _rect(s.bar_rect), "stub_rect": _rect(s.stub_rect), "tabs": tabs,
			"window": [shell.size.x, shell.size.y]}
	_log.append(entry)
	return entry


func _tenant(shell: Control, key: String, label: String) -> Dictionary:
	var r: Dictionary = Shell.tenant_state(shell, key)
	var entry := {"t_ms": _ms(), "event": "tenant", "label": label, "key": key, "ok": r.ok,
			"code": r.error.code if not r.ok else "",
			"ticks": r.value.get("ticks", -1) if r.ok else -1, "inputs": r.value.get("inputs", -1) if r.ok else -1,
			"size": [r.value.size.x, r.value.size.y] if r.ok and r.value.has("size") else [0, 0]}
	_log.append(entry)
	return entry


## The film of a gesture: every frame for `ms`, saved as frames/<prefix>-NNNN.png with its time and
## the Shell's state (the clicked tab's rect and the flags) logged.
func _film(shell: Control, out_dir: String, prefix: String, ms: int, tab_index: int) -> void:
	var t0 := _ms()
	var n := 0
	while _ms() - t0 < ms:
		await process_frame
		var img := get_root().get_texture().get_image()
		var file := "frames/%s-%04d.png" % [prefix, n]
		img.save_png(out_dir.path_join(file))
		var s: Dictionary = Shell.state(shell).value
		var strip_state: Dictionary = TabStrip.state(shell.get_node("TabStrip")).value
		_log.append({"t_ms": _ms(), "event": "frame", "film": prefix, "n": n, "file": file, "opening": s.opening,
				"pressed": s.pressed, "switching": s.switching, "active": s.active,
				"tint": strip_state.tabs[tab_index].tint,
				"tab_rect": _rect(s.tabs[tab_index].rect), "page_visible": s.tabs[tab_index].page_visible,
				"tenant": s.tabs[tab_index].tenant})
		n += 1


func _initialize() -> void:
	var root := get_root()
	var shell: Control = Shell.create({"map": DummyTenant, "sketchbook": DummyTenant, "3d_viewer": DummyTenant,
			"collection": DummyTenant, "playground": Callable(self, "_grey_tenant")}).value
	shell.switch_settled.connect(func(i: int): _log.append({"t_ms": _ms(), "event": "signal", "signal": "switch_settled", "index": i}))
	shell.tenant_created.connect(func(k: String): _log.append({"t_ms": _ms(), "event": "signal", "signal": "tenant_created", "key": k}))
	var out_dir := await _mount(shell, Vector2i(1920, 1080), "/tmp/shell-playtest")
	DirAccess.make_dir_recursive_absolute(out_dir.path_join("frames"))

	# 1. launch: the Collection tab grows in like a stub-opened tab, then its page fades in; six fixed
	#    tabs in order along the bottom, Collection active and its tenant created, the rest waiting
	await _film(shell, out_dir, "launch", 1000, 4)
	_state(shell, "launch")
	for key in Shell.FIXED_TABS:
		_tenant(shell, key, "launch")
	await _shot(out_dir, "01-launch.png")

	# 2. click the Map tab: the tab dips, the page cross-fades in, its tenant is created on first show and runs
	var st: Dictionary = _state(shell, "pre-map")
	await _click(_center(shell, st.tabs[0].rect), "map tab")
	await _film(shell, out_dir, "map", 350, 0)
	_state(shell, "map")
	var a := _tenant(shell, "map", "map-shown")
	await _frames(20)
	var b := _tenant(shell, "map", "map-after-20-frames")
	await _shot(out_dir, "02-map.png")

	# 3. click the Sketchbook tab: after the fade the Map page is frozen (its _process and input stop), Sketchbook runs
	await _click(_center(shell, st.tabs[1].rect), "sketchbook tab")
	await create_timer(0.45).timeout
	_state(shell, "sketchbook")
	var c := _tenant(shell, "map", "map-hidden")
	var sk0 := _tenant(shell, "sketchbook", "sketchbook-shown")
	await _key(KEY_SPACE, "space key while map is hidden")
	await _frames(20)
	var d := _tenant(shell, "map", "map-hidden-after-20-frames")
	var sk1 := _tenant(shell, "sketchbook", "sketchbook-after-20-frames")
	await _shot(out_dir, "03-sketchbook.png")

	# 4. back to Map: it resumes with its count intact from the moment the fade starts
	await _click(_center(shell, st.tabs[0].rect), "map tab (again)")
	var e := _tenant(shell, "map", "map-resumed")
	await create_timer(0.45).timeout
	_state(shell, "map-again")
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

	# 6. the stub still opens a Blank Page with a close button; closing it lands on the Playground tab,
	#    whose grey Callable-built tenant is created on that first show
	await _click(_center(shell, st.stub_rect), "new-tab stub")
	await create_timer(1.8).timeout
	_state(shell, "stub-blank")
	await _shot(out_dir, "05-stub-blank.png")
	var sb: Dictionary = _state(shell, "stub-blank")
	await _click(_center(shell, sb.tabs[sb.count - 1].close_rect), "close button of the blank tab")
	await create_timer(0.9).timeout
	_state(shell, "grey")
	_tenant(shell, "playground", "grey-shown")
	await _shot(out_dir, "06-grey.png")

	# 7. click the Collection tab from the grey Playground page: the film of the dip and the cross-fade
	await _click(_center(shell, st.tabs[4].rect), "collection tab")
	await _film(shell, out_dir, "switch", 350, 4)
	_state(shell, "collection")
	await _shot(out_dir, "07-collection.png")

	# 8. the Video Player tab has no tenant in this harness: a plain white page
	await _click(_center(shell, st.tabs[3].rect), "video player tab")
	await create_timer(0.45).timeout
	_state(shell, "untenanted")
	_tenant(shell, "video_player", "untenanted-shown")
	await _shot(out_dir, "08-untenanted.png")

	# 9. resize the window to the 1440x900 minimum: the bar re-fits along the bottom, the visible tenant fills its page
	await _click(_center(shell, st.tabs[4].rect), "collection tab (again)")
	await create_timer(0.45).timeout
	root.size = Vector2i(1440, 900)
	await _frames(3)
	_state(shell, "resized")
	_tenant(shell, "collection", "resized")
	await _shot(out_dir, "09-resized.png")
	root.size = Vector2i(1920, 1080)
	await _frames(3)
	_state(shell, "restored")
	_tenant(shell, "collection", "restored")
	await _shot(out_dir, "10-restored.png")

	_finish(out_dir)
