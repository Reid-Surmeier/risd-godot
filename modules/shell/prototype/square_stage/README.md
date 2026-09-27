# Square Stage prototype for #155

**Question:** Which 1080-square frame best fits all seven existing Tenants before the owner directs individual window sizes?

This is throwaway code on `Reid-Surmeier/prototype-square-stage`. No production module interface, error type, or acceptance test changes.

Run the Godot scene:

```sh
~/.local/opt/godot-4.7.2/Godot_v4.7.2-stable_linux.x86_64 --path . res://modules/shell/prototype/square_stage/demo.tscn --display-driver x11 --rendering-driver opengl3 --resolution 1080x1080
```

Use the Top Bar arrows or Left/Right keys to switch layouts. The bottom Start button opens all seven Tabs; each fixed Tab selects its Tenant and shows a blue selected state; Home selects Map. The shared Top Bar shows the current Page and has working previous/next Tab controls. Prototype-only overlays cover clock imagery in Map and Collection; the accepted Tenant files are unchanged.

| Variant | Behavior | Tradeoff |
| --- | --- | --- |
| A · Full bleed | Page fills the space between Top Bar and bottom strip | Most room, least surrounding structure |
| B · Inset window | Page scales uniformly to 94% inside a framed margin | Clear frame, smaller controls |
| C · Side desk | Page scales uniformly to 83% beside a non-overlapping Page label | Context rail, smaller controls and unused lower space |

`evidence/` holds 21 actual Godot screenshots at 1080×1080, a state record, and a browser gallery with `?variant=A|B|C&tab=<key>` links. Capture again with:

```sh
~/.local/opt/godot-4.7.2/Godot_v4.7.2-stable_linux.x86_64 --path . --script res://modules/shell/prototype/square_stage/capture.gd --display-driver x11 --rendering-driver opengl3 --resolution 1080x1080 -- --out-dir=modules/shell/prototype/square_stage/evidence
```

No winner is claimed. Owner visual review decides the frame and per-window follow-up work.

The current Shell playtest exercises the production route and fails five pre-existing visual assumptions: white launch Page, full-width Tenant, grey Flowers Page, Collection press tint, and full-height Tenant after resize. Its interaction checks, including seven Tabs, freeze, selection, Start stub, and resize dimensions, pass. The prototype capture runner checks the square Page fit, selected Tab, non-overlapping switcher and side card, clock masks, Start's seven entries, and Home→Map without editing frozen tests. Flowers' pale lettering is in the accepted Tenant imagery and remains for visual review.
