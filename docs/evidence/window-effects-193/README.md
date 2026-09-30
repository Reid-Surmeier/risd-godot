# Proportional windows and restored effects — #193

Runtime: `3bc7029d`. Export: `3bc7029d-dirty`; the dirty suffix is from three existing documentation/provenance edits left untouched. No runtime source differs from the commit.

Drag a bottom-right grip to scale a complete window without stretching its contents. Map, Sketchbook and Playground retain their existing dragging. Collection scales its complete frame, and its painting preview restores the chosen scale when closed. CRT is visible over Collection; Squigglevision starts on. F8/F9 toggle them independently.

## Evidence

- `browser.cjs` / `browser.log` / `web/results.json`: all 18 windows shrink and grow through browser pointer events with both presentation effects enabled. Proportions, tab-return persistence, F8/F9 toggles and a 486×720 browser resize pass; no browser page errors. Browser screenshots were inspected.

- `input_check.gd` / `native.log`: all 18 visible windows shrink and grow via real pointer events with equal X/Y scale and unchanged internal sizes. Map collapse/restore, locked resize rejection and wheel zoom pass. Drawing on the resized book passes. Collection preview and Escape restore the chosen frame scale. Zero failures.
- `shader_check.gd` / `shaders.log`: static isolated presentation, default effects and F8/F9 controls. `shaders/metrics.json` records visible pixel changes from each effect; restoring both produces the exact original image. No extra screen-copy pass was needed.
- `checks.log`: `scripts/check.sh` passes. `git diff --check` passes.
- `legacy-comparison.json`: unchanged frozen module fixtures were run against both the baseline `0a58dc7e` and the changed tree. Sketchbook and Playground have exactly the same eight and three failures respectively. Map has ten baseline failures and twelve additional assertions expecting independent-axis resizing or resetting the reference layout after resizing. The focused input check above verifies the replacement behavior, including collapse and lock. The legacy fixtures are **not passing** and were not rewritten.

## Reproduce

```bash
DISPLAY=:99 godot --path . --rendering-method gl_compatibility --script docs/evidence/window-effects-193/input_check.gd -- --out-dir=/tmp/windows193
DISPLAY=:99 godot --path . --rendering-method gl_compatibility --script docs/evidence/window-effects-193/shader_check.gd -- --out-dir=/tmp/shaders193
node docs/evidence/window-effects-193/browser.cjs "$GAME_URL" /tmp/browser193
scripts/check.sh
```

Native screenshots are captured without the presentation filters for precise pointer checks. Browser screenshots retain the restored filters. No generated assets, paid services, lightmap changes or frozen module interfaces were introduced.
