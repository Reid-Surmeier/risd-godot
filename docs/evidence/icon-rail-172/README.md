# Desktop icon captions — Issue #172

The shared Shell reserved 72 Page pixels while its widest original icon and
baked caption occupy 87 pixels, starting 14 pixels from the edge. Tenant
content therefore overpainted the right end of the captions. The fix reserves
115 pixels: the same 87-pixel art plus two 14-pixel margins. No asset, Tenant,
stage width, public interface or frozen test changed.

Native reproduction on the actual 1080×1080 square application:

```sh
DISPLAY=:99 godot --path . --script res://modules/shell/playtest/icon_rail_capture.gd \
  --display-driver x11 --rendering-driver opengl3 -- --out-dir=/tmp/icon-172-final
```

At 72 pixels the Map, Viewer and Video Player reproduction exited 1 with
`RAIL_OVERLAP_FAILURES=21`. At 115 pixels the expanded seven-tab run exited 0
with `RAIL_OVERLAP_FAILURES=0` across 42 icon rectangles. Real single clicks
selected and real double clicks emitted the existing opened signal on Map,
Sketchbook, Viewer, Video Player and Flowers. Playground owns its full Page
without a Shell rail. Collection's rail is already hidden inside its clipped
gallery host and is not an available click target; its selection failure was
reproduced separately at the old 72-pixel baseline before excluding that
hidden target. No changes were made to Collection.

`before/` contains three captures of the failing state; `after/` contains all
seven final Tabs. Each directory has its native log and interaction/geometry
report. All seven images were visually inspected; Viewer, Playground and
Collection remain fitted. The final baseline check and `git diff --check`
passed. Existing Mesa/OpenGLES, Sketchbook MSAA and headless exit warnings
remain unchanged.

The existing Viewer acceptance was also repeated after the rail fix:
`scripts/playtest.sh sculpture_viewer /tmp/icon-172-viewer-regression` passed
all seven tabs, all twenty selections, hover, freeze/return and pixel checks.
Its output is retained in `viewer-regression.log`.

All captures are local Godot 4.7.2 Compatibility renders, USD 0. Original icon
assets and their existing provenance remain unchanged.
