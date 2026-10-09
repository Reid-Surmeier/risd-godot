## A test double Tenant: a plain white surface that counts its own frames and input events, so a
## playtest can prove the Shell freezes a hidden Page and resumes it. Satisfies the Tenant
## contract in interface.gd: static create(deps) -> {ok, value: Control, error}; state().
extends ColorRect

var key := ""
var ticks := 0
var inputs := 0


static func create(deps: Dictionary) -> Dictionary:
	var t = load("res://modules/shell/playtest/dummy_tenant.gd").new()
	t.key = deps.get("key", "")
	t.name = "DummyTenant_" + t.key
	t.color = Color.WHITE
	t.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return {"ok": true, "value": t, "error": null}


func _process(_delta: float) -> void:
	ticks += 1


func _unhandled_input(_event: InputEvent) -> void:
	inputs += 1


func state() -> Dictionary:
	return {
		"ok": true,
		"value": {"key": key, "ticks": ticks, "inputs": inputs, "size": size},
		"error": null
	}
