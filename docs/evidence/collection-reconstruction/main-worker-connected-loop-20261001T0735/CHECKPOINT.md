# Collection checkpoint — 2026-10-01 08:18 UTC

Prototype v40. Sole main worker; heartbeat disabled. Goal active and unfinished. Collection only; no production integration, Viewer/frozen seam changes or ticket closure.

1. Wide6382 85.25–89.25s corrects the medieval wall: two gold panels belong north; projecting display is not the corner. Joined the six-room circuit with23 existing Hall works, frames, vault/skylight and benches. Both Hall doors centred as original Hall177.50 shows. Dimensions remain authored/provisional: Hall10×26.3m, medieval wall10m, purple connector2.15m. Source-relative object shifts preserve grouping, not verified offsets. Official2020 schematic supports topology only.
2. Corrected culled carved portal front, retained plain closed reverse. Native face/oblique/room/plan and actual walking views inspected.769 native lightmap users; CPU Vulkan fallback200.66s, RTX rendering. Dark/warm walls, golden white trim, support/frame heights, offsets, portal profile and staircase silhouette remain unaccepted. Fixed extended browser check's CDP protocol timeout; failed import/render/test attempts retained.
3. Native RTX154/154,p9531.481ms. Chrome RTX154/154 plus real WASD round trip,p9530.200ms,ready5592ms,errors[]. Both cover33 circuit segments with32 transitions without resets.60fps target unmet. Shell repeat46/50; 4 frozen failures below. First run43/50 had3 additional timing failures that did not recur; both films/logs preserved. scripts/check.sh and git diff --check passed. Full film/logs archived; all180 source hashes and50 original pending hashes verified. No new paid generation; total$0.72 actual/$0.73 conservative.
4. Six medieval identities verified against official API/photos and actual source: angel37.114, Bartolo Madonna20.207, Virgin of Annunciation57.301, Magdalene21.250, Taking of Peter22.047, Anthony Abbot16.243. All six need actual asset geometry and placement. North panels were misidentified; recorded rejection57.300. No proxy substituted for a missing object. Gallery objects/case contents, stairs, auditorium and modern gallery remain incomplete.
5. Next: native close/wide references and support dimensions for north Magdalene21.250 and Taking of Peter22.047; fit their spacing relative to the40.014 portal, then one Muse gabled-frame pass and separate authentic art. Place all four west/north panels; validate reciprocal wide shots before accepting offsets. Continue architecture/lighting calibration and remaining objects. No external blocker; source occlusions/uncalibrated room metres and missing assets are real remaining work, not completed acceptance. Failed head and ambiguous river-deities run remain unaccepted without blind retry.

Owning Shell failures:

FAIL launch_page_area_white
FAIL tenant_fills_page_area [1848.0, 979.999816894531]
FAIL flowers_page_is_the_grey_tenant mean [165, 165, 165]
FAIL resize_refits_bar_and_tenant window [1440.0, 900.0], bar {'h': 46.964771270752, 'w': 1440.0, 'x': 0.0, 'y': 853.035217285156}, tenant [1368.0, 824.999816894531]

https://windows-wsl.taile06c45.ts.net/risd-frame-review-01a0ee18/progress/

Reproduce: prepare_remodel.py NEW_OUTPUT; Godot import; saved bake wrapper (769 users); RTX review/selfcheck; Web export and saved browser wrapper. GPU checks run sequentially. Native/source comparison camera is approximate, not a held-out calibrated metric validation. Diagnostic headless fixed-step timings are excluded from performance claims.

The readable first Shell log has terminal trailing spaces trimmed; the original bytes remain in shell-first-run.tar.gz.
