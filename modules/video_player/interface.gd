## The video_player seam. Other modules reference this file only. Frozen: changing it is an Issue.
##
## The Fly Through video player is the Video Player Tab's Tenant (map #23, ticket #31): the
## issue-20 prototype's accepted desktop — one draggable viewer window, the owner's Fly Through v7
## screenshot as its chrome, eight original artwork tiles of which the first five play a RISD
## Museum video (the last three are visible but disabled), the controls always shown, Muse and
## Seedance frames for hover / pressed / settled on nine controls — on the Page's white desktop.
## Clicking a tile loads its video at 0:00 and autoplays; play/pause, the seek knob, the volume
## knob, mute, Save (this session) and fullscreen work; fullscreen fills the Page, never the OS
## window. Keys while the Page is shown: 1-5 pick a tile, Space play/pause, M mute, F fullscreen,
## Left/Right seek 5 s; with the title bar focused the arrows move the viewer.
##
## Tenant contract (shell/interface.gd): create(deps) returns a full-rect Control that lays itself
## out from its own size; the viewer opens fitted to the Page and re-fits on resize; state() is
## the harness probe. Hidden with its Page (the Shell freezes it), the video pauses; on show it
## resumes from the same position if it was playing. Text in the page uses the bundled Liberation
## Sans (assets/fonts/); the strip stays font-free.
##
## Every public function returns { ok: bool, value: Variant, error: Variant }; errors are the
## values in errors.gd; nothing is raised across this seam.
class_name VideoPlayerInterface
extends RefCounted

const Errors := preload("res://modules/video_player/errors.gd")
const _Impl := preload("res://modules/video_player/video_player.gd")


## Build the Video Player Tenant. `deps` is what the Shell passes, { "key": String }; the key is
## recorded. The five preview videos and the two control manifests are checked first: returns
## ok(Control) or err(MEDIA_MISSING | ASSET_MISSING, path). The first video is playing when the
## Control enters the tree.
static func create(deps: Dictionary) -> Dictionary:
	return _Impl.create(deps)


## The harness probe. Rects are global (root viewport pixels) unless said otherwise:
## ok({ key, ticks, size: Vector2 (the Tenant's own), viewer: { position: Vector2 (Tenant px),
##      scale, rect: Rect2 (global) }, selected_video, video_id, title, playing, paused,
##      hidden_paused, muted, volume, fullscreen, stream_position, stream_length, saved,
##      video_rect: Rect2 (global), thumbnail_count, linked_video_count,
##      tiles: [{ index, enabled, rect }], controls: { play, seek, seek_knob, timer, mute, volume,
##      volume_knob, fullscreen, save, minimize, title_bar: Rect2 }, generated_motion_controls,
##      motion_play_count, drag_intent_count, dragging_viewer, interaction_count, last_action }).
## `ticks` counts the Tenant's _process frames: it stands still while the Page is frozen.
## `hidden_paused` is true while the video is paused because the Page is hidden.
static func state(tenant: Control) -> Dictionary:
	return tenant.state()
