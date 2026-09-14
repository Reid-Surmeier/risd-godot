## Playtest harness for playground_page: builds the Shell with this mockup as the Playground Tenant and nothing
## in the other Tabs, then plays it the way a person does — real InputEventMouseButton events through
## Input.parse_input_event on the tabs — and reports what it did and what the interfaces said. The
## Tenant is reached only through ShellInterface.tenant_state. Args: --out-dir=<path>. Writes
## numbered screenshots and report.json there.
extends "res://testing/harness_base.gd"

const Shell := preload("res://modules/shell/interface.gd")
const Page := preload("res://modules/playground_page/interface.gd")
const INDEX := 5


func _shell_state(shell: Control, label: String) -> Dictionary:
	var s: Dictionary = Shell.state(shell).value
	var tabs := []
	for t in s.tabs:
		tabs.append({"key": t.key, "page_visible": t.page_visible, "frozen": t.frozen, "tenant": t.tenant, "rect": _rect(t.rect)})
	var entry := {"t_ms": _ms(), "event": "shell", "label": label, "active": s.active, "count": s.count,
			"switching": s.switching, "bar_rect": _rect(s.bar_rect), "tabs": tabs, "window": [shell.size.x, shell.size.y]}
	_log.append(entry)
	return entry


func _page_state(shell: Control, label: String) -> Dictionary:
	var r: Dictionary = Shell.tenant_state(shell, "playground")
	var entry := {"t_ms": _ms(), "event": "page", "label": label, "ok": r.ok, "code": r.error.code if not r.ok else "",
			"ticks": r.value.ticks if r.ok else -1, "inputs": r.value.inputs if r.ok else -1,
			"size": [r.value.size.x, r.value.size.y] if r.ok else [0, 0],
			"image_size": [r.value.image_size.x, r.value.image_size.y] if r.ok else [0, 0],
			"image_rect": _rect(r.value.image_rect) if r.ok else _rect(Rect2())}
	_log.append(entry)
	return entry


func _initialize() -> void:
	var root := get_root()
	var shell: Control = Shell.create({"playground": Page}).value
	var out_dir := await _mount(shell, Vector2i(1920, 1080), "/tmp/playground_page-playtest")
	await create_timer(1.0).timeout  # the launch grow and fade

	# 1. launch: Collection is active, this Tenant does not exist yet
	var st: Dictionary = _shell_state(shell, "launch")
	_page_state(shell, "launch")
	await _shot(out_dir, "01-launch.png")

	# 2. click the Playground tab: the Tenant is created on first show; the picture sits centred at native size
	await _click(_center(shell, st.tabs[INDEX].rect), "playground tab")
	await create_timer(0.45).timeout
	_shell_state(shell, "shown")
	var a := _page_state(shell, "shown")
	await _frames(20)
	var b := _page_state(shell, "shown-after-20-frames")
	await _shot(out_dir, "02-playground.png")

	# 3. click the Phone tab (no Tenant there): this Page is frozen; keys and clicks do not reach it
	await _click(_center(shell, st.tabs[6].rect), "phone tab")
	await create_timer(0.45).timeout
	_shell_state(shell, "hidden")
	var c := _page_state(shell, "hidden")
	await _key(KEY_SPACE, "space key while hidden")
	await _click(Vector2(960, 400), "click on the page area while hidden")
	await _frames(20)
	var d := _page_state(shell, "hidden-after-20-frames")
	await _shot(out_dir, "03-hidden.png")

	# 4. back: it resumes with its counters intact from the moment the fade starts, and the same picture
	await _click(_center(shell, st.tabs[INDEX].rect), "playground tab (again)")
	var e := _page_state(shell, "resumed")
	await create_timer(0.45).timeout
	_shell_state(shell, "resumed")
	await _frames(20)
	_page_state(shell, "resumed-after-20-frames")
	await _shot(out_dir, "04-resumed.png")

	# 5. the 1440x900 minimum: the picture re-centres in the smaller Page
	root.size = Vector2i(1440, 900)
	await _frames(3)
	_shell_state(shell, "resized")
	_page_state(shell, "resized")
	await _shot(out_dir, "05-resized.png")
	root.size = Vector2i(1920, 1080)
	await _frames(3)
	_shell_state(shell, "restored")
	_page_state(shell, "restored")
	await _shot(out_dir, "06-restored.png")

	_finish(out_dir)
