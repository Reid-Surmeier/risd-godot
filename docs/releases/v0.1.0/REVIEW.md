# v0.1.0 review

verdict: needs-work

Reviewed candidate `0a58dc7ee2c1761619ba868d303b6e9662df6e8a` against `main` at `55e7c3b7f048a5a7a27b71fc962c040e7aa5893e`, September 29, 2026. Acceptance sources: map #149 and its implementation issues, including later owner corrections #187, #189 and #192. Three independent read-only source reviewers examined Standards, Spec and Ponytail separately. This is not a blind image-review or owner-acceptance verdict; any later runtime change requires review again.

## Standards

One introduced breach found and corrected in this review follow-up: the Shell provenance entry described #187's new offline lightmap but omitted its current hashes. The older #167 hash table was not labeled historical. `modules/shell/PROVENANCE.md` now distinguishes the historical table and records the independently verified current EXR/LMBake hashes, source runtime, device, timing, provider and zero cost. This changes documentation only.

No additional verified documented-standard breaches in the inspected runtime/tool hunks. Frozen Playground changes were explicitly authorized by #164; Viewer and structural changes have issue authority. #173 explicitly authorizes compact taskbar asset composition. No substantial baseline-smell finding was reported separately.

Carry-forward: the prior review's frozen `tab_strip` return-shape discrepancy and #35 rights-record finding were outside this diff-focused re-review and are not waived. Read the historical review at `55e7c3b7:docs/releases/v0.1.0/REVIEW.md`; no public redistribution or release authorization is inferred.

## Spec

1. **Current integrated blind review remains incomplete.** #162 requires re-review of changed groups and motion evidence where relevant. Earlier UI/visitor/gallery reports predate the newer Collection and Viewer changes. #192's successful interaction checks and implementer image inspection do not themselves establish fresh independent blind acceptance. Continuous-motion limits remain in the #161/#162 records.
2. **Final hands-on approval remains outstanding.** #149 requires Reid to personally use and approve the integrated build; #173 remains an acceptance record until that happens. Checks and implementation cannot authorize closing the map or disabling automation.

No verified runtime-correctness or scope-creep defect was found in the sampled coordinate mapping, Collection artwork/frame/fullscreen paths, Viewer drag/raise/uniform-resize/focus paths or disabled character gesture. #192 explicitly expands the older hover-only UI scope. #185 scopes diagnosis/design separately from implementation; this review does not misreport its proposed transition as an implemented feature.

#141's matched startup-performance acceptance remains unresolved, as already recorded in the prior review. Functional tests do not clear it.

## Ponytail (ultra)

ponytail: 2 findings, 0 fixed, 2 accepted

- **Accepted for this candidate:** `walk4.gd` retains permanently true `_generated_visitor`/`_rigged_visitor` flags and unreachable sprite/billboard branches after #174 selects Hair36 (approximately 24 removable lines). Defer this nonfunctional cleanup until the open #174 motion acceptance is resolved, so this review remains bound to the tested visitor implementation; preserve `_kid_t`, which navigation checks read.
- **Accepted for this candidate:** `_portal_stone` duplicates about six lines of interpolation already provided by `_portal_relief_sample`. Defer source-generator cleanup until a focused geometry-equivalence check can accompany it; it is not needed to validate the saved room currently shipped.

No dependency-removal opportunity was identified. These are cleanup findings, not missing requested features or correctness waivers.

## Verification and coverage

Fresh `scripts/check.sh` and `git diff --check` pass on the candidate; 13 existing ObjectDB shutdown warnings remain. Exact review baseline output is in `docs/evidence/final-review-162/current-0a58dc7e/baseline.log`. The published page identifies runtime `8694316e`, with evidence/provenance follow-up at the reviewed candidate. Scan-window and Collection interaction packets retain their native/browser input checks and images.

The old Shell fixture's timing/layout failures reproduce on its unchanged baseline, documented under #187; they are not silently called passing. Current source review covered the changed contracts, ADRs, provenance, composition/input, Playground, Viewer, gallery navigation/geometry, character, render diagnostics and shaders, plus bake recovery. It was not exhaustive line-by-line review of all 1,123 changed files, offline generators, generated meshes or bulk evidence. No reviewer made a ship claim.

See `docs/evidence/final-review-162/README.md` for the visual-review inventory and its exact outstanding dispositions. Standards: one introduced finding, fixed in documentation. Spec: two current integrated acceptance gates remain. Ponytail: two deferred cleanups, with reasons above. Release remains blocked by unresolved acceptance and carry-forward findings.
