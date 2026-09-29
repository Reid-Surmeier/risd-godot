# Animal Crossing room transitions

Research for [#185](https://github.com/Reid-Surmeier/risd-godot/issues/185), 2026-09-29. Scope: design evidence; no runtime change.

The useful pattern is **commit the doorway transition, obscure the view, change rooms while obscured, reveal the destination**. Keep camera and wall visibility changes inside the obscured interval. The wipe shape is secondary.

## What the source verifies

The evidence below is the community decompilation of **GameCube Animal Crossing, USA revision 0**, pinned at `09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c`. It is reconstructed game implementation, not Nintendo-published source and not New Horizons. [Repository scope](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/README.md).

| Stage | Verified behavior |
| --- | --- |
| Trigger and guard | `Player_actor_check_nextgoto` checks a warp item in front of the player, collision conditions, and `WIPE_MODE_NONE`, then requests an exit-scene demo. `goto_other_scene` independently refuses to start another change during an active wipe. [Trigger](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player_other_func.c_inc#L156-L203), [scene request](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_scene.c#L491-L526). |
| Movement ownership | Physical doors have a dedicated player state: align to a requested position/direction, use door animation movement, stop ordinary movement. Generic room warps request `Invade`, whose movement brakes. This does **not** establish that every doorway uses the same autowalk. [Door state](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player_main_door.c_inc#L21-L70), [Invade state](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player_main_invade.c_inc). |
| Cover before swap | The play loop waits for the wipe's `isfinished_proc` before calling `Game_play_change_scene_move_end`. The latter changes the scene number and schedules the next play instance. This is a covered scene change, not visible travel of the camera through a doorway. [Wipe completion and scene change](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_play.c#L203-L317). |
| Destination and reveal | Scene setup copies the door's exit position and orientation into player data. The next play instance starts with `FADE_TYPE_IN` and carries over the transition wipe type. [Destination](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_scene.c#L397-L415), [reveal](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_play.c#L445-L458). |
| Wipe appearance varies | The engine supports black, white, and circular wipes. **Museum entrance door records explicitly use type 2, which is white fade.** The generic normal door type is converted to black fade. It would be inaccurate to describe every Animal Crossing room change as a black iris. [Museum data](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/data/scene/museum_entrance.c#L77-L121), [type enum](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/include/m_play.h#L43-L53), [default conversion](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_scene.c#L497-L503). |

The dedicated door camera centers on the door actor and has its own process. This supports purposeful doorway framing, but does not establish a universal camera offset or angle. [Door camera](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_camera2.c#L1793-L1830).

## Recommended Collection behavior

This is a proposed adaptation, not a claim about Nintendo's exact implementation:

1. Commit only when the visitor crosses an inset doorway trigger toward its destination. Latch the destination once; pause ordinary movement and further doorway checks. Optionally guide a short step to the doorway center if alignment needs it.
2. Hold the current room/camera and fade the Collection viewport fully to black. Start before the visitor or camera reaches clipping geometry. A plain fade is sufficient for the first implementation; an iris is optional polish.
3. While fully covered, switch room, wall visibility/cutaway state, camera position and target, and visitor spawn/facing together. Reset camera smoothing so it cannot sweep through walls after reveal. Place the visitor inside the destination, clear of the return trigger.
4. Reveal the settled destination, then restore movement. Rearm that doorway only after the visitor leaves its trigger; preserve reverse traversal afterward. A spatial rearm condition is preferable to a guessed cooldown.
5. Verify both directions, held movement during arrival, backing away before commit, diagonal approaches, and different viewport shapes. Capture frames around the swap: no exposed geometry change, camera sweep, one-frame old-room view, or immediate return trip.

No source-derived duration is prescribed. Tune cover/reveal times in the prototype; do not mistake the decompiled frame counters for measured New Horizons timings. Changing a white flash into black alone cannot fix a swap that happens before the cover becomes opaque.

## New Horizons evidence limit

Nintendo publishes [Museum Scavenger Hunt footage](https://play.nintendo.com/media/videos/animal-crossing-new-horizons-museum-scavenger-hunt/), but the page text does not establish frame-by-frame doorway timing or input behavior. No New Horizons executable/source or unedited doorway capture was inspected here. Consequently this report makes no claims about its exact trigger distance, control lock duration, wipe shape for every room, or arrival cooldown. The GameCube evidence supports the covered-swap pattern; a pixel-matched New Horizons reproduction would require a separately inspected recording.
