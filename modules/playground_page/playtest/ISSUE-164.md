# Issue #164 validation

Final seam cleanup: Shell now always leaves Playground undecorated. Re-running
the legacy fixture improves its result to 49/52; only the old six-tab assertion
and two Page-size expectations remain. No frozen test was changed.

Native square acceptance passed on 2026-09-27 with Godot 4.7.2, X11 and the OpenGL compatibility renderer. The harness uses actual mouse and key input and asserts Explore chronology, all 37 blocks, four page navigation, public channel contents, typed search, unknown-page stability, and RISD saves read back through collection-data. The captured Explore, All Blocks, Channels, Search and search-results images were visually inspected; final design acceptance belongs to the independent integrated blind review.

Command: `DISPLAY=:99 godot --path . --resolution 1080x1080 --windowed --script res://modules/playground_page/playtest/square_harness.gd --display-driver x11 --rendering-driver opengl3 -- --out-dir=/tmp/playground-square-164`.

`scripts/check.sh` and `git diff --check` passed. Godot's startup check reports the existing eight ObjectDB instances at exit, with no script errors.

The original `scripts/playtest.sh playground_page` reports 44/52 on both the integrated tree and an untouched archive of main `55e7c3b7f048a5a7a27b71fc962c040e7aa5893e`. The eight failure lines are identical: obsolete six-tab expectation, phone pixel comparison, two old Page size expectations, and four frame pixel comparisons. This slice introduces no additional legacy fixture failure. The baseline used generated import descriptors and the existing imported texture cache, while every tracked source file came from main. Logs: `/tmp/playground-legacy-164.log` and `/tmp/playground-main-164-baseline.log`; baseline evidence: `/tmp/playground-main-164-baseline`.
