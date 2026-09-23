## Playtest for the setup grid's hover turn (Issue #110): builds the Shell with this Tenant in the 3D
## Viewer Tab, opens the Tab by a real click, then for every turning cell moves the real pointer onto
## it (Input.parse_input_event), waits, and checks the cell reached its last frame, that the screen
## pixels under it changed, and that no other cell moved; then moves the pointer off and checks the
## cell is back on frame 0 with the screen pixel-identical to before. Args: --out-dir=<path>.
## Writes hover-turn.json, rest/peak screenshots, and prints PASS/FAIL lines and a VERDICT.
extends "res://testing/harness_base.gd"

const Shell := preload("res://modules/shell/interface.gd")
const Viewer := preload("res://modules/sculpture_viewer/interface.gd")
const PARKED := Vector2(1700, 900)  # white desktop, on no window


func _move(pos: Vector2) -> void:
	var ev := InputEventMouseMotion.new()
	ev.position = pos
	ev.global_position = pos
	Input.parse_input_event(ev)
	await process_frame


func _pixels(image: Image, r: Rect2) -> PackedByteArray:
	var region := image.get_region(Rect2i(r))
	region.convert(Image.FORMAT_RGB8)
	return region.get_data()


func _differs(a: PackedByteArray, b: PackedByteArray) -> float:
	var total := 0
	for i in range(0, a.size(), 3):
		total += absi(a[i] - b[i])
	return total / (a.size() / 3.0)


func _initialize() -> void:
	var shell: Control = Shell.create({"3d_viewer": Viewer}).value
	var out_dir := await _mount(shell, Vector2i(1920, 1080), "/tmp/sculpture_viewer-hover")
	await create_timer(1.0).timeout
	var st: Dictionary = Shell.state(shell).value
	await _click(_center(shell, st.tabs[2].rect), "3d viewer tab")
	await create_timer(0.6).timeout
	await _frames(6)
	await _move(PARKED)
	await _frames(2)
	await _shot(out_dir, "hover-00-rest.png")
	var cells: Array = shell.find_children("turn-*", "", true, false)
	var results := []
	var failed := 0
	for cell in cells:
		var r: Rect2 = cell.get_global_transform() * Rect2(Vector2.ZERO, cell.size)
		var before := get_root().get_texture().get_image()
		await _move(r.get_center())
		await create_timer(1.0).timeout
		await _frames(2)
		var during := get_root().get_texture().get_image()
		var peak_frame: int = cell.frame
		var others_still := cells.all(func(c): return c == cell or c.frame == 0)
		var changed := _differs(_pixels(before, r), _pixels(during, r))
		await _shot(out_dir, "hover-%s-peak.png" % String(cell.name).trim_prefix("turn-"))
		await _move(PARKED)
		await create_timer(1.0).timeout
		await _frames(2)
		var after := get_root().get_texture().get_image()
		var restored := _differs(_pixels(before, r), _pixels(after, r))
		var ok: bool = peak_frame == cell.frames - 1 and others_still and changed > 2.0 and cell.frame == 0 and restored == 0.0
		failed += 0 if ok else 1
		results.append({"cell": String(cell.name), "rect": _rect(r), "frames": cell.frames, "peak_frame": peak_frame,
				"screen_change_on_hover": snappedf(changed, 0.01), "others_still": others_still,
				"frame_after_leave": cell.frame, "screen_change_after_leave": snappedf(restored, 0.001), "pass": ok})
		print("%s  %-22s peak %d/%d  screen change %.2f  back to frame %d, residual %.3f" % [
				"PASS" if ok else "FAIL", cell.name, peak_frame, cell.frames - 1, changed, cell.frame, restored])
	var f := FileAccess.open(out_dir.path_join("hover-turn.json"), FileAccess.WRITE)
	f.store_string(JSON.stringify({"cells": results, "failed": failed}, " "))
	f.close()
	print("VERDICT %s  %d cells, %d failed" % ["PASS" if failed == 0 and cells.size() == 18 else "FAIL", cells.size(), failed])
	quit(0 if failed == 0 and cells.size() == 18 else 1)
