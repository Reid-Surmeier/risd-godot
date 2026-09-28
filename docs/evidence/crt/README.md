# Refined CRT across the Collection Browser — #64

![CRT on](collection-crt.png)
![Unfiltered comparison](collection-off.png)
![Small browser, all edges filled](fit-720x486.png)
![Painting and window drag](sketchbook-painted.png)

The supplied Flight Simulator CRT reference guides fine neutral phosphor lines, soft detail and subtle static grain. This owner-requested display treatment leaves source images untouched. The final preset is a 30% neutral grille, .03-pixel colour separation, .20 grain strength and .018 curvature. Whites remain white, with no vignette, monitor casing or black surround. F8 toggles without recreating pages; crt=0 bypasses the effect.

The Shell demo presents its original content in a SubViewport and maps pointer positions through the same curve. A minimum-sized logical desktop scales uniformly to the browser, so the entire page and bottom bar remain reachable at smaller sizes. Entry/exit notifications preserve the tenants' hover behavior. All existing module interfaces, error types and frozen tests remain unchanged.

## Verification

- scripts/check.sh: checks passed (Godot 4.7.2 headless); git diff --check passed. Existing gdlint is not installed; no claim of clearing the separately tracked lint backlog.
- Godot Web import/export succeeded without script/shader errors.
- Focused browser run passed on candidate `d91add3d`: six tabs, exact 35px window-drag destination within 2px, sketchbook stroke, F8 state preservation, Viewer idle/hover/idle pixels, CRT bypass, no console/runtime errors.
- Screenshots inspected at full and small sizes. White exterior difference is zero; near-white luminance is unchanged. No dark edge bars at 1920×1080, 720×486 or 1200×600; the bottom bar remains clickable at every size.
- Candidate PCK SHA-256: `ffec14ea62d185de23dfa3d50744cfaf61b04c258e961a4c48784922c748c4f9`.

Run: `PLAYWRIGHT_MODULE=/path/to/playwright/index.mjs node modules/shell/playtest/crt_display_browser.mjs <candidate URL>`. This uses the already installed browser tooling; no dependency or paid generation was added. The candidate export is scratch evidence, not a release.

## Review

### Standards

Independent review found missing SubViewport mouse-entry/exit notifications. Fixed with window exit forwarding and a guard against repeated entry; browser hover comparison now passes. No remaining hard standards findings.

### Spec

Independent review found coloured moire and insufficient near-white/pointer checks. Replaced the coloured grille with a neutral grille, lowered colour separation, added the near-white mean check and exact drag destination assertion. Updated screenshots reviewed; no remaining spec blockers. The revised browser run passed.

Source: Harrison Allen, CC0, [CRT with Luminance Preservation](https://godotshaders.com/shader/crt-with-luminance-preservation-no-scanlines/), adapted from the previously accepted painting prototype. No spend.
