## Error values of the video_player module. Frozen: changing this file is an Issue.
class_name VideoPlayerErrors
extends RefCounted

## A pixel file, a control manifest or a font the player loads is not in
## the project (detail: its path).
const ASSET_MISSING := "video_player.asset_missing"
## One of the five preview videos in media/ is not there (detail: its path). Nothing is built.
const MEDIA_MISSING := "video_player.media_missing"


static func err(code: String, detail: String = "") -> Dictionary:
	return {"ok": false, "value": null, "error": {"code": code, "detail": detail}}


static func ok(value = null) -> Dictionary:
	return {"ok": true, "value": value, "error": null}
