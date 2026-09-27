# Square Stage prototype for #155

**Question:** Which 1080-square frame best fits all seven existing Tenants before the owner directs individual window sizes?

This is throwaway code on `Reid-Surmeier/prototype-square-stage`. No production module interface, error type, or acceptance test changes.

Run the Godot scene:

```sh
~/.local/opt/godot-4.7.2/Godot_v4.7.2-stable_linux.x86_64 --path . res://modules/shell/prototype/square_stage/demo.tscn --display-driver x11 --rendering-driver opengl3 --resolution 1080x1080
```

Use the floating arrows or Left/Right keys to switch layouts. The bottom Start button opens all seven Tabs; each fixed Tab selects its Tenant; Home selects Map. The shared Top Bar shows the current Page and has working previous/next Tab controls. The original Shell tab strip and placeholder header are hidden in this prototype; the seven Tenant factories remain the current ones.

| Variant | Behavior | Tradeoff |
| --- | --- | --- |
| A · Full bleed | Page fills the space between Top Bar and bottom strip | Most room, least surrounding structure |
| B · Inset window | Page scales uniformly to 94% inside a framed margin | Clear frame, smaller controls |
| C · Side desk | Page scales uniformly to 83% beside a persistent Page label | Context rail, much smaller controls and unused lower space |

`evidence/` holds 21 actual Godot screenshots at 1080×1080, a state record, and a browser gallery with `?variant=A|B|C&tab=<key>` links. Capture again with:

```sh
~/.local/opt/godot-4.7.2/Godot_v4.7.2-stable_linux.x86_64 --path . --script res://modules/shell/prototype/square_stage/capture.gd --display-driver x11 --rendering-driver opengl3 --resolution 1080x1080 -- --out-dir=modules/shell/prototype/square_stage/evidence
```

No winner is claimed. Owner visual review decides the frame and per-window follow-up work.

Verification: `scripts/check.sh` passes. The existing `scripts/playtest.sh shell` has one failing resize assertion: it expects the Tenant to fill the full area above the strip, but the current shared header occupies 28 px there. This prototype changes no production Shell code or frozen test.
