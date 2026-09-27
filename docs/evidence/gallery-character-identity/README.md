# Original visitor prototype evidence (#142)

The [native gallery warm](native-warm.png), [cool](native-cool.png), [probe-disabled](native-probe-disabled.png), and [white-room](native-white-room.png) captures use the same #139 rig adapter with `GALLERY_CHARACTER=identity`. Godot Compatibility reported Mesa llvmpipe. The fixed head sample was warm RGB `(0.247, 0.086, 0.094)`, cool `(0.192, 0.059, 0.059)`, and probe-disabled `(0, 0, 0)`; original-lighting mode was `(0.443, 0.200, 0.243)`. The [native log](native-render.log) ends with `RIG_RENDER_FAILURES 0`. Bounded per-surface albedo gains on skin, cream and oxblood improved the visible face/stripes in the same [warm](native-warm-gain.png) and [white-room](native-white-room-gain.png) poses. The [gain log](native-gain.log) still passes warm/cool/probe-off checks; the head sample lands on the unchanged cap, so those identical sampled values do not quantify the face gain. Command:

```bash
GALLERY_CHARACTER=identity godot --rendering-method gl_compatibility --path . --script res://modules/shell/prototype/gallery_walk4/rig/render_check.gd -- --out-dir=/tmp/gallery-identity-render
```

The exported Web [entry](browser-entry.png), [mid-gallery](browser-mid.png), and [white arch](browser-white-arch.png) screenshots are actual Chrome captures, not composited art. The [continuous motion recording](browser-motion.webm) shows the browser's W/D/S key sequence and mouse turn. [Browser events](browser.json) confirm gallery→arch→gallery and gallery→far→gallery roundtrips. The test returned zero, though its console also logged existing `arrow_cursor` metadata errors and a missing resource; those are retained in the JSON and need separate triage if they affect use. Command:

```bash
scripts/export-web.sh
node modules/shell/prototype/gallery_walk4/rig/browser_check.cjs '<served exported HTML>?character=identity' /tmp/gallery-identity-browser
```

At the steep dollhouse angle, red cap, stripes and eyes remain visible. The cap top occupies much of the head; the shoes and face are dark in the gallery capture. The white-room rear silhouette is clearer. This is **not** a visual acceptance verdict. The generated Muse turnaround is a direction reference, not certified identity.

The first cold Chrome identity run reported 110,111,896 transferred bytes and `game-shown` at 75.84 s. Downloads completed at 2.11 s, Godot became ready at 9.61 s, launch settled at 50.20 s, and tab warmup ended at 71.95 s. A [same-export software-renderer pair](software-load-pair.json) used identical cache-disabled 1600×900 Chrome settings and found **Rogue default 74.86 s, identity 71.81 s** to `game-shown`, with equal 109,831,146-byte core resource transfer. Both runs reported `ANGLE (Mesa, llvmpipe ... OpenGL ES 3.2)`. The earlier #141 16.32 s baseline used a different renderer/runtime; this pair rules out a 60-second identity-specific startup cost on this host, but does not establish hardware/browser performance. An earlier Rogue-first run timed out at 180 s before `game-shown`, so the host also shows software-renderer variability. Machine-wide ClamAV scanning ran concurrently and may contribute; its effect was not isolated.
