## Opt-in real-export evidence (#141). No node or per-frame collection without ?qa-perf.
extends Node

var samples: Array = []
var keys: Array = []
var drawn: Array = []
var publish_at := 0
var last_draw := 0
var last_process := 0


func _ready() -> void:
	process_priority = 1000  # observe the gallery after its movement update
	RenderingServer.frame_post_draw.connect(_drawn)


func _input(event: InputEvent) -> void:
	if (
		event is InputEventKey
		and event.keycode in [KEY_W, KEY_A, KEY_S, KEY_D, KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT]
	):
		keys.append(
			{
				"us": Time.get_ticks_usec(),
				"key": OS.get_keycode_string(event.keycode),
				"pressed": event.pressed,
				"echo": event.echo,
				"browser_ms": JavaScriptBridge.eval("performance.now()")
			}
		)
		if keys.size() > 512:
			keys.pop_front()


func _drawn() -> void:
	if not can_process():
		last_draw = 0
		last_process = 0  # a frozen tab is not a simulation stall
		return
	var now := Time.get_ticks_usec()
	if last_draw != 0:
		drawn.append({"us": now, "ms": (now - last_draw) / 1000.0})
		if drawn.size() > 1800:
			drawn.pop_front()
	last_draw = now


func _process(delta: float) -> void:
	var gallery := get_parent()
	var now := Time.get_ticks_usec()
	var pos: Vector3 = gallery.get("_pos")
	var velocity: Vector3 = gallery.get("_velocity")
	samples.append(
		{
			"us": now,
			"delta_ms": delta * 1000.0,
			"wall_ms": (now - last_process) / 1000.0 if last_process else 0.0,
			"held": gallery.get("_held").keys(),
			"position": [pos.x, pos.z],
			"velocity": [velocity.x, velocity.z],
			"space": gallery.get("_space")
		}
	)
	last_process = now
	if samples.size() > 1800:
		samples.pop_front()
	if now >= publish_at:
		publish_at = now + 250000
		(
			JavaScriptBridge
			. eval(
				(
					"""
(function(batch) {
 const state = window.galleryPerf ||= {samples: [], keys: [], drawn: []};
 for (const name of ['samples', 'keys', 'drawn']) {
  state[name].push(...batch[name]);
  if (state[name].length > 1800) state[name].splice(0, state[name].length - 1800);
 }
 state.process_ms = batch.process_ms;
 state.draw_calls = batch.draw_calls;
 state.video_memory_bytes = batch.video_memory_bytes;
 state.published_ms = performance.now();
})(%s)
"""
					% JSON.stringify(
						{
							"samples": samples,
							"keys": keys,
							"drawn": drawn,
							"process_ms":
							Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0,
							"draw_calls":
							Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
							"video_memory_bytes":
							Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)
						}
					)
				)
			)
		)
		samples.clear()
		keys.clear()
		drawn.clear()
