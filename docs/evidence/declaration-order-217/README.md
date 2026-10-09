# Declaration placement — #217

Runtime `6cb7e87e` moves complete declarations and comments in 14 named files. Every initialized instance field keeps its evaluation sequence. Function bodies, constants, signals, static fields, comment text/types, value syntax, and frozen seams remain intact. See the [focused check](check.py), [manifest](manifest.json), [preservation and 14 native parses](preservation.json), [independent source review](source-review.json), and [actual lint counts](lint-summary.json).

Run `/tmp/risd-gdtoolkit-211/bin/python docs/evidence/declaration-order-217/check.py` from the build worktree. The installed gdtoolkit 4.5.0 check still fails: 55 authored tracked findings plus three original untracked findings, 55 fewer than before. Thirty initialized public/private order cases are [retained](retained-order-findings.json): moving them would violate #217's required initializer sequence. [#219](https://github.com/Reid-Surmeier/risd-godot/issues/219) scopes independently proven pure-value interleaving next. The other 25 authored findings remain outside both scopes. No lint rule or target was weakened.

The exact runtime passes [18 browser input/window checks](browser-input/results.json) and [33 states covering seven Tabs, four main/hover scans and five fits](browser-integrated/states.json), with no recorded errors. Native import exits 0 with 13 known ObjectDB shutdown instances; export Dummy/RID warnings remain in export.log. [Five HTTPS files match](https-integrity.json). [Twelve protected assets, museum records and square173 remain unchanged](source-integrity.json). [Consumer references](consumer-references.json) are recorded.

[Ten fresh PR attachments and API readback](pr-attachments.json) and the [private gallery with ten images and a finite 6.867-second playing clip](picture-gallery-check.json) pass. [Clip provenance](clip-provenance.json) records the remux without re-encoding. Independent follow-up verified build/PR/map/checkpoint publication and the enabled automation with reused session.

https://windows-wsl.taile06c45.ts.net/risd-order-current-01a0f327/
Complete private build. Use scans, windows, movies and gallery; final hands-on owner approval remains outstanding.

https://windows-wsl.taile06c45.ts.net/risd-order-pictures-01a0f327/
Current pictures and visitor clip, retained for the requested three-day review period.

Fresh [Astra medium blind image review](visual-review.md) passes the specified compositions, subjects, fits, gallery joins and contacts. Fine text and Flowers contrast fail; continuous quality and owner approval need evidence. An initial literal 40-object comparison was corrected to #173/#157's explicit 20-entry scope; both reports are retained. The renderer is ANGLE D3D12/AMD, with no performance or GPU-bake claim.

[Hosted Verify 36746828043](hosted-status.json), bound to `04ffdac4`, fails before steps, with runner_id 0. Its cause is unknown; no retry or settings/billing change was made. Full #162 remains needs-work. #217 and the final #149/#173/#174/#177 owner gates remain open. No generation, provider action, spend, bake, release, public redistribution or owner acceptance occurred. [Automation remains enabled](automation-status.json).
