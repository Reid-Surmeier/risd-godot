# Playground repair proof — issue #106

Question: can a real input test expose a missing Playground interaction, can Jev route that observation, and can an agent repair and retest the real page without replacing its art?

**Yes for this bounded slice.** Baseline failed selection, filter-control and scroll-control checks. One live Jev request routed to `repair_code` with confidence 0.99. The agent implemented native controls inside the existing frames, then corrected an empty-filter bug exposed by the same tests. Final native checks pass 7/7, existing frozen Playground checks pass 52/52, and Chrome passes selection/filter/zero-results/clear/wheel without console or page errors. `scripts/check.sh` and `git diff --check` also pass. Visual output was inspected, not merely scored.

This is not autonomous discovery of every visual control. Tests and repair were written by the coding agent; Jev classified the recorded findings, not screenshots or source code. Muse was not needed or called for this slice. The six original image assets remain byte-for-byte unchanged. No generation or regeneration success is claimed. Earlier palette experiments are unrelated and excluded.

The demo runs the actual `playground_page` module with 12 synthetic, in-memory saved artworks. No live museum record, IndexedDB save or network mutation is used. Phone keys, window-close icons, decorative gifts and blank options/chat interiors remain outside the repaired interaction surface. Do not mistake a passing scoped suite for complete UI coverage. This branch is throwaway, not a production release.

## Run from the repository root

```sh
DISPLAY=:99 godot --path . --display-driver x11 --rendering-driver opengl3 res://modules/playground_page/prototype/demo.tscn
DISPLAY=:99 godot --path . --script res://modules/playground_page/prototype/test.gd --display-driver x11 --rendering-driver opengl3 -- --out-dir=/tmp/playground-check
scripts/playtest.sh playground_page /tmp/playground-regression
bash modules/playground_page/prototype/export.sh
```

The export isolates the real module and fixture scene in a temporary project, without changing the game's launch scene. Output: `build/playground-proof/playground.html`. Use the share skill for an owner-accessible URL. The browser harness takes that HTML URL and an output directory; `PLAYWRIGHT_MODULE` may point to the already-installed Playwright `index.mjs`. A read-only Web probe is enabled only with `?qa=1` in this prototype scene.

## Evidence and spend

`evidence/` contains before/after reports, screenshots, the regression transcript, browser evidence and the real Jev request/response/receipt. OpenRouter reported 470 input tokens, 51 output tokens and **$0.00001974**, one request, model `typesafe/jev-1.13`. Its confidence is one model decision, not measured classification accuracy. The runner creates a reservation before dispatch and refuses reuse; an ambiguous result is never retried automatically.

The call uses the existing [OpenRouter Decisions API](https://openrouter.ai/docs/api/api-reference/alphadecisions/submit-a-decisions-questions-and-answers-request). No new test framework or pipeline service was introduced: Godot's existing input harness plus the installed Playwright handle execution, stdlib HTTP handles one classification call. Future autonomous discovery and asset regeneration need separately defined acceptance tests; this proof does not validate them.
