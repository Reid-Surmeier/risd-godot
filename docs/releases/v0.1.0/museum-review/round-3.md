VERDICT: NOT DONE

# Independent museum playtest, round 3 — 8 October 2026

Review in progress. Reviewer: Codex, working alone. No game code or assets changed. Acceptance source: Issue #238 and `docs/playtest/museum-playtest-rules.md`; owner deadline: Friday 9 October, 13:00 America/New_York.

Candidate checkout: `8348b28a1767ed42737c7bce6bb5a71ccdfbf507` on `review/round-3`. Browser candidate: `https://windows-wsl.taile06c45.ts.net/museum-latest-75d82bf6/`. VERIFIED: the served index identifies `3b460c1c` and redirects to its HTML page; Godot changes the document title to `risd-godot`. `git diff 3b460c1c 8348b28a -- modules project.godot` is empty: the runtime source matches. The share suffix is not a git SHA. Documentation commits do not change the candidate game.

VERIFIED means reproduced and inspected by this reviewer. INFERRED identifies a conclusion that has not been reproduced. NEW means absent from both 8 October censuses; KNOWN means the class or instance is already documented. Findings are ordered by what a visitor encounters, with the final repair priority list at the end.

## Findings

### 1. The first stone doorway interrupts walking with a freeze, then replaces the whole room and darkens the visitor.

**VERIFIED · BLOCKS · NEW** for the measured freeze and visitor lighting switch; **KNOWN** for the static black cut-away already in room census area 2. Where: Main Hall ↔ dark medieval room, central stone portal, WASD and Shift. Reproduce: (1) From the starting position, hold W into the medieval room. (2) Hold S back through the same door, with Shift for the return. The first captured entry has a 0.986 s gap between rendered frames; a second session has a 0.455 s entry gap and a 0.600 s return gap. The game's own performance probe reports a 388.7 ms process gap at visitor position `(0, 0.178)`, immediately across the portal. Other measured Hall/grey crossings do not show comparable gaps. The cut replaces the Hall facade with the medieval set while the visitor changes from lit to dark. INFERRED: room visibility/lightmap work is responsible; the cause was not isolated, and concurrent GPU jobs make these timings host-specific.

Evidence: [continuous portal frames](../../../evidence/review-round-3/01-portal-crossing.jpg); scratch `01-hall-medieval-walk.mp4`, `02-hall-medieval-repeat.mp4`, their `*-frames.json`, and `02-path.json`. The missing timestamps are disclosed in the sheet, not filled with duplicated frames.

## Coverage and measurements

VERIFIED: fresh engine harness `--only=doors` completed 38 doorway legs with zero failures. A separate real-key probe recorded 76 walk/sprint legs at one JPEG per six fixed-60-FPS frames and logged camera/body positions each frame; its endpoint classification needs correction before treating it as a sprint pass. Chrome uses the requested ANGLE GL/EGL GPU flags. Its first two loads reached `game-shown` at 49.54 s and 48.82 s; downloads finished at 2.42 s on the first load. These are shared-host observations, not isolated benchmarks. Continuous recordings, frame timing, browser console output and scratch probes stay under `build/review-round-3/` (ignored). Selected JPEG evidence is committed under `docs/evidence/review-round-3/`.

## Ten findings to fix before Friday 13:00

Pending confirmed findings and prioritization.

## What could not be tested

Pending final coverage accounting.

## What the harness should learn

Pending confirmed motion and interaction failures. This review will not modify the harness.
