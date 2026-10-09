## Problem or desired outcome
Map149 verification must retain the licensed Mixbox SDK byte-for-byte while enforcing all existing GDScript rules on authored code.

## Evidence or current behavior
After215, tracked lint has119findings:8line and1constant-name finding belong to unchanged upstream modules/sketchbook/mixbox/mixbox.gd;110findings belong to authored code. The SDK hash is5d10a98ffb8fab237fea7dbd03e2bb0bf95edca5357fa75429097776a8eb0a14, matching MODULE provenance and main55e7c3b7. Owner rules forbid editing third-party source. scripts/check.sh currently sends this SDK to authored-style lint using explicit find paths; gdtoolkit excluded_directories cannot filter explicit file arguments.

## Expected behavior
Exclude exactly that unchanged upstream file from authored-style lint. Continue module/seam discovery and native Godot compilation/runtime coverage of the SDK. Do not change lint rules, omit any authored file, alter SDK/license/provenance, or claim repository PASS while authored findings remain.

## Acceptance criteria
1. Change only the lint target selection in scripts/check.sh to omit exactly ./modules/sketchbook/mixbox/mixbox.gd, with a brief explanation. No gdlint rule/config exception or broad-directory exclusion; every other previous target remains present. Native/seam routes remain unchanged. Verify before/after target sets and prove excluded bytes match recorded source hash and main baseline, with license/resource unchanged.
2. Run actual installed scripts/check.sh and tracked-target lint; exactly9upstream style findings disappear, leaving110authored findings plus original untracked findings. Retain FAIL honestly and git diff --check. Native check-only for Mixbox and current full runtime still pass with known shutdown diagnostics; no public/commercial-rights approval inferred.
3. Integrate into existing build/v0.1.0/PR166, update map149/checkpoint and read back before closure. Reuse exact current244be7e2 runtime/private Web/picture proof because no runtime source/asset changes; preserve all12assets/museumrecords/square173. Final162 and hands-on owner approval remain open; automation stays enabled.

## In scope
scripts/check.sh exact third-party lint target, existing baseline/native checks and narrow evidence. No runtime module API/error/test changes or new dependency is needed.

## Out of scope
Changing upstream Mixbox/license/lookup table/provenance, authored lint rules/targets,110authored findings, owner untracked files, interfaces/errors/frozen acceptance behavior, UI/assets/generation/provider/spend/bakes/settings/billing/hosted retry/releases/public redistribution, other worktrees.

## Verification
Compare original/new find target sets: only the exact upstream file is removed from lint; module/seam paths unchanged. Recorded SDK/resource/license hashes and main byte equality, native SDK/current parse/import, installed pinned gdtoolkit4.5.0 check outputs/remaining counts, whitespace, exact latest244 private hashes/Web/pictures plus PR166/map149/checkpoint readback.

## Platforms affected and sync authorization
Existing integrate-square-164/build/v0.1.0 only under ongoing full map149 implementation authority. The one build PR166 holds this correction; main and square-containment-173 remain unchanged.

## Dependencies and approvals
Follows215's exact-string source remediation. Unpaid reversible check correction is authorized by owner continuation. Preserve all remaining110authored findings, hosted209 failure of unknown cause, full162/owner gate and unresolved Mixbox commercial/attribution rights. Nothing releases/publishes publicly or infers owner approval.
