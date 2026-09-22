## Error values for the sound_cues seam. Frozen by Issue #108.
class_name SoundCuesErrors
extends RefCounted

const ASSET_MISSING := "sound_cues.asset_missing"
const UNKNOWN_CUE := "sound_cues.unknown_cue"


static func err(code: String, detail: String = "") -> Dictionary:
	return {"ok": false, "value": null, "error": {"code": code, "detail": detail}}


static func ok(value = null) -> Dictionary:
	return {"ok": true, "value": value, "error": null}
