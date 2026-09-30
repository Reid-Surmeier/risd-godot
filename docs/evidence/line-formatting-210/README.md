# Authorized line formatting — #210

Runtime `ba6b3c05`, fixed source `04eb31a9`, September 30, 2026. This issue names 122 authored GDScript files, including frozen interfaces, errors and acceptance files, for layout-only formatting. No callable, literal, assertion, ordering, seam, asset or runtime behavior change is authorized.

The installed gdtoolkit4.5.0 formatter ran without `--fast`: normalized tree, comment persistence and stable formatting checks enabled. It changed112 trial files. Native Godot rejected the square_pages multiline lambda indentation; the expanded Playground main introduced a file-length lint violation. Independent Spec review additionally caught duplicate comments in two playtest harness lambdas. All four files were restored byte-for-byte to04eb31a9; rejected outputs/logs are retained. Final108 accepted files pass native parsing and independent normalized-tree and exact ordered-comment comparison. No runtime helper/dependency or lint exception was added.

[Manifest](manifest.json) distinguishes trial before/after hashes from final current hashes and dispositions. [Native parser results](parser-results.json) records the trial; rejection records override trial PASS where necessary. [Final source review](source-review.json), [comment rejection](comment-rejected-files.json) and [file-length rejection](lint-rejected-files.json) preserve the correction evidence.

Tracked installed-tool lint remains **FAIL485**, including374 line-length findings:788 findings removed from the1273 fixed-point baseline, no new non-line rule finding retained. This is partial remediation. Remaining long literals/comments and inherited naming/order/other findings are not waived. Hosted Verify previously failed with no steps/runner/log; the cause remains unverified. No CI or whole-map ship claim.

Native `scripts/check.sh` without optional lint passes Godot/seam checks with13 ObjectDB shutdown warnings. Direct CollectionData, SavedDestinations and SoundCues assertions pass; Saved/Sound logs include anchors/resource shutdown errors, so logs are not called clean. These checks supplement source equivalence; they do not clear historical frozen Shell/Video playtest failures.

The exact exported build and its bootstrap/game/wasm gzip bytes were checked over HTTPS in [integrity](https-integrity.json). Allfour original GLBs, saved room/EXR/LMBake and five movies match [source integrity](source-integrity.json). Museum metadata was not edited. No generation, provider, bake or spend.

https://windows-wsl.taile06c45.ts.net/risd-format-current-01a0f078/
Use the complete app: select scans, resize windows, try movies and walk the gallery. Final hands-on owner approval remains outstanding.

Exact-build Web checks PASS: all18 proportional windows/grips, retention, painting X/Escape, fullscreen, movement-release/Hair36/23paintings and F8/F9; full33-state seven-Tab/four-main-hover-scan/Playground/five-shape capture errors[]. [Actual input](browser-input/results.json), [captured states](browser-integrated/states.json) and pictures preserve the results. Root inspected Viewer/main-hover and gallery floor/frame pictures; fresh independent image review is recorded separately. Installed-tool full `scripts/check.sh` correctly FAILs488 (485tracked plus3original untracked findings); no lint acceptance claimed. #210/#209/#162/map149 stay open; automation stays enabled. Source review cannot replace owner approval.

Fresh [Astra medium image-only review](visual-review.md) passes visible seven Tabs, four-scan/main-catalogue-hover composition, square containment and gallery/frame/visitor. Small-format text legibility FAIL remains explicit. Continuous motion and owner approval remain NEEDS-EVIDENCE. Ten current images and a finite-duration motion clip are available separately:

https://windows-wsl.taile06c45.ts.net/risd-format-pictures-01a0f078/
View the exact current capture, with the review limits above.
