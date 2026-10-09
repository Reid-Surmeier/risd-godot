# Current integrated review packet — runtime 9f7ff4c0

The current build includes #192 scan windows, #193 proportional desktop windows/restored effects and #199's centered Collection correction. Old `current-0a58dc7e` evidence remains historical. No source scan, painting identity, frame art or saved lightmap changes in this correction; provider none, spend USD0.

- [Source review and corrected findings](source-review.md).
- [Independent Collection image review](collection-image-review.md): center/identity/proportion/containment/preview PASS; narrow readability and web grid/softness FAIL; continuous motion NEEDS-EVIDENCE. Scope dispositions are explicit and separate.
- `native-red.log`: two real-pointer center assertions fail before the one-line pivot fix; `native-green.log`: all18 windows plus map/drawing/preview and center pass.
- `windows-web/results.json` and `windows-browser.log`: actual pointer shrink/grow on all18 windows, every changed Page's tab return, painting click/X/Escape, chosen Collection scale/center, fullscreen, movement/release/Hair36/23paintings, F8/F9 and portrait fitting pass; errors[]. [Resized centered Collection](windows-web/page-4-after.png), [preview](windows-web/preview-click.png), [return](windows-web/preview-return.png), [portrait](windows-web/portrait.png).
- `baseline-fixed.log`: repository checks pass;13 existing ObjectDB shutdown warnings. `export-integrity.json`: immutable HTTPS html/boot/game/wasm hashes and all4 source GLBs match. Runtime export `9f7ff4c0`; archive game hash is recorded exactly.

Fresh complete seven-tab/gallery/five-shape visual capture and group reviews are in progress. The first entry-page run lost QA flags at its meta-refresh redirect; its240s wait and certificate-startup error are retained in capture logs. A separate gl-egl1080startup attempt timed out at240s and is retained in `capture-gl-egl-failed.log`; no GPU success or universal startup claim. Current repeat uses the known software renderer, starts at800×600 and captures at actual1080 square afterward. #141 remains separate and unresolved.

https://windows-wsl.taile06c45.ts.net/risd-map149-current-01a0f078/

Stable private owner test build; frame, windows, scans, paintings, warm room, visitor and restored effects. Final owner hands-on approval remains required; #162/#173/#174/#149 remain open. Automation stays enabled. No new bake, assets or paid generation.
