# Square Shell integration — #164

Live Godot 4.7.2 production scene captures at 1080×1080, including the retained
CRT presentation. `tab-*.png` covers all seven Tabs; `playground-*.png` covers
Explore, All Blocks, Channels and Search. `start.png` and `top-search.png` show
the shared navigation controls. These are captured pixels, not generated art.
`playground-explore-scrolled.png` shows the lower Save controls after wheel input.

Run:

```sh
DISPLAY=localhost:165 godot --path . \
  --script res://modules/shell/playtest/square_capture.gd \
  --display-driver x11 --rendering-driver opengl3 --accessibility disabled
scripts/check.sh
git diff --check
```

The display for this run was an isolated Xvfb with GLX and MIT-SHM disabled;
Mesa used OpenGLES 3.2. Accessibility was disabled only for the capture process
because this host's AccessKit driver emitted an internal `other_ae` null error.
No production accessibility setting was changed.

`report.json` records actual mouse/key inputs: all seven Tabs, Start then Enter
on Map, Collection then Home, top Search, and each Playground page. Assertions
check selection, the 1080×972 Page extent, all seven Start entries, Search page
and keyboard focus. The run printed:

> PASS: seven Tabs, Start selection, Home, top Search focus, four Playground pages

`scripts/check.sh` passed (the existing eight ObjectDB exit-leak warning remains).
`git diff --check` passed. The separate native Playground acceptance exercise
also covers shared saved state, search, chronology and error values.

## Existing Shell fixture limitation

The frozen legacy Shell playtest was run on both untouched `main` (`55e7c3b7`)
and this integrated tree. Both fail the same four old geometry/pixel expectations:
`launch_page_area_white`, `tenant_fills_page_area`, `flowers_page_is_the_grey_tenant`,
and `resize_refits_bar_and_tenant`. Main additionally showed two variable dip
timing failures. The 72-pixel desktop-icon inset and older fixture expectations
predate this integration. Tab order, lazy creation, hidden-page freezing,
selection, close rejection and resume checks pass on the integrated tree.
The frozen Shell fixture was not changed to conceal those baseline failures.

Selected sources: chrome A at `89b0e39c` (#156), Playground A at `542f1394`
(#158). Runtime asset hashes and origins are retained in the owning modules'
`PROVENANCE.md` and asset manifests. New paid generation: zero calls, USD 0.

## Technical-review repairs

Atlas now owns its compact-layout clock heading. Shell omits its own Playground
desktop decorations before mounting; chrome no longer traverses either Tenant's
children. The stripe raster is Shell-owned, with source and output hashes recorded.
Four duplicate query assignments were removed; the input's text-change signal
remains the single update path.

After these repairs, the native Playground acceptance and full square mouse/key/
wheel capture passed again, and refreshed Map/Search captures were visually
inspected. `scripts/check.sh` and `git diff --check` passed. The Atlas playtest
reports 68/78 on both this tree and untouched main: all ten failure lines are
identical (`/tmp/risd-164-review-atlas.log` and
`/tmp/risd-164-review-atlas-main.log`). No frozen interface, error or acceptance
file changed in this repair.

The final seam repair removes the private `_square_stage` flag entirely: Shell
unconditionally omits its own decorations for Playground. The legacy Playground
fixture improves from 44/52 to 49/52; remaining failures are its obsolete six-tab
expectation and two old Page-size expectations. The demo's new Playground usage
is limited to public `create` and `show_page` calls; it traverses no Tenant nodes.
