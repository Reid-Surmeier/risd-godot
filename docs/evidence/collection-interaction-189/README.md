# Collection interaction — #189

Runtime `583db13f`, after completed warm room #187. No generation, spend or rebake.

Painting clicks now replace the ornate game frame with only the artwork and its own frame. X/Escape restore the visitor position and camera. Full screen uses the browser/window API, retaining the square desktop's uniform fit. Dollhouse camera distance is 11 instead of 14.2; native projected character height is 0.280 of the viewer instead of 0.207. The left baseboard existed but disappeared into baked shadow; neutral material fill makes its white paint visible.

## Evidence

- `before/`, `after/`: native full-app composition. New interaction check fails four assertions before changes, passes afterward. Actual click/X, own-frame aspect, restored frame/position/camera and closer composition.
- `web/`: exact exported runtime, actual clicks and keyboard input. Fullscreen/restore API, proportional 1600×1000 resize, zoom/pan, X, 486×720 portrait Escape, movement/release, fixed FOV, Hair36 and23 paintings all pass. No browser errors. Headless viewport resize is explicitly emulated after actual fullscreen entry; no claim of physical display testing.
- `dollhouse.log`: all23 real painting clicks open the correct artwork. Tall paintings are clicked within the viewer-clipped polygon. Two unrelated checks remain failing: outdated flat-colour bench selector and two-second footstep count10 against expected6–9.
- `legacy-baseline.log`: both failures reproduced using `b8b8b152` walk/demo/check sources, replacing the Desktop/Content script before mounting, and stopping after cadence. Frozen acceptance files untouched.
- `baseline.log`: `scripts/check.sh` passes (existing shutdown ObjectDB warning).
- `baseboard-before*`, `baseboard-after*`: inspected native views; left-board sampled luminance0.272→0.605. Right0.555→0.757. `geometry.log` verifies all139 saved mesh arrays (vertices/normals/UVs) and transforms identical; EXR/LMBake unchanged.

## Repeat

```bash
DISPLAY=:99 godot --path . --rendering-method gl_compatibility --script res://modules/shell/playtest/collection_preview_check.gd -- --out-dir=/tmp/collection-preview
node docs/evidence/collection-interaction-189/browser.cjs http://127.0.0.1:8787/583db13f.html /tmp/collection-preview-web
scripts/check.sh
git diff --check
```

`geometry_check.gd` compares current saved room to `git show b8b8b152:modules/shell/prototype/gallery_walk4/baked/room.tscn > /tmp/room-before-189.tscn`.

Earlier legacy Shell timing/layout fixture failures remain documented in #187 evidence. This is scoped interaction verification, not a whole-app release claim. GPU baking #184 remains unresolved; no GPU bake was needed for #189. Room-transition research #185 remains separate.
