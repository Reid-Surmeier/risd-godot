# Portal floor visibility — reproduced failure

Command (native Compatibility renderer):

```sh
godot --path . --rendering-method gl_compatibility --script modules/shell/prototype/gallery_walk4/doorway_check.gd -- --out-dir=docs/evidence/architecture-167/portal-doorway-check
```

Before the backing-floor height repair, process exit 1:

```text
DOORWAY_FLOOR 1152-baked-arch clear_samples=0/9
DOORWAY_FLOOR 1152-baked-far clear_samples=9/9
DOORWAY_FLOOR 1152-original-arch clear_samples=0/9
DOORWAY_FLOOR 1152-original-far clear_samples=9/9
DOORWAY_FLOOR 588-baked-arch clear_samples=0/9
DOORWAY_FLOOR 588-baked-far clear_samples=9/9
DOORWAY_FLOOR 588-original-arch clear_samples=0/9
DOORWAY_FLOOR 588-original-far clear_samples=9/9
DOORWAY_FAILURES 4
```

After changing only the backing-floor height from +0.002 to -0.002,
same command with output `/tmp/risd-167-portal-floor-probe`, process exit 1:

```text
DOORWAY_FLOOR 1152-baked-arch clear_samples=0/9
DOORWAY_FLOOR 1152-baked-far clear_samples=9/9
DOORWAY_FLOOR 1152-original-arch clear_samples=9/9
DOORWAY_FLOOR 1152-original-far clear_samples=9/9
DOORWAY_FLOOR 588-baked-arch clear_samples=0/9
DOORWAY_FLOOR 588-baked-far clear_samples=9/9
DOORWAY_FLOOR 588-original-arch clear_samples=9/9
DOORWAY_FLOOR 588-original-far clear_samples=9/9
DOORWAY_FAILURES 2
```

The stale saved bake still contains the occluding +0.002 floor. The live
original geometry passes immediately, with no camera, layer, threshold,
sampling position, or acceptance threshold change. Final rebake verification
follows below; the intermediate result was not a pass.

After rebaking (113.92 seconds, `BAKE_OK users=120`) and fresh import/export,
the original command exits 0:

```text
DOORWAY_FLOOR 1152-baked-arch clear_samples=9/9
DOORWAY_FLOOR 1152-baked-far clear_samples=9/9
DOORWAY_FLOOR 1152-original-arch clear_samples=9/9
DOORWAY_FLOOR 1152-original-far clear_samples=9/9
DOORWAY_FLOOR 588-baked-arch clear_samples=9/9
DOORWAY_FLOOR 588-baked-far clear_samples=9/9
DOORWAY_FLOOR 588-original-arch clear_samples=9/9
DOORWAY_FLOOR 588-original-far clear_samples=9/9
DOORWAY_FAILURES 0
```

The exported browser at both 720 and 1600 reports:

```text
DOORWAY_FLOOR clear_samples=9/9
DOORWAY_GAMEPLAY_READY
NAV_SPACE gallery -> arch
NAV_SPACE arch -> gallery
```

Both error arrays are empty in `portal-walk-browser/browser.json`, with
approach/inside/return PNGs and actual-keyboard roundtrip WebM evidence.
Native navigation also passes both portals by route, key and click, plus
drag/easing/pan/wheel/picking/cancel, retaining 23 paintings. The final
cornice geometry/material check and far-door profile check pass unchanged.
`scripts/check.sh`, `git diff --check`, and bake failure-recovery check pass.
The prior failed PNGs are preserved at
`/tmp/risd-167-portal-intermediate.v4qe6z/portal-doorway-check/`.
