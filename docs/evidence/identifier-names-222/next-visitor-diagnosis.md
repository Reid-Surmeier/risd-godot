## Problem Statement

Fresh map149/#162 image review found fragmented green/tan visitor clothing in runtime2208eaba's full seven-Tab capture. A fresh matched fixed-pose baseline6d126/candidate2208 pair shows clean stripes in both. A later candidate Tab replay captured a black torso in its initial frame and clean stripes after every Tab return. Source assets and imported scene/fourtextures/import metadata are byte-identical. This is an unresolved rendering/capture-readiness finding, not a proven source-asset or identifier regression.

## Solution

Build one bounded, repeatable native/Web replay at the actual Collection gameplay size that distinguishes render readiness, animation/pose state, and persistent material/skin defects. Identify the cause before changing runtime behavior. Preserve the selected Hair36 identity, source mesh/UVs/skin weights/skeleton, striped clothing and accepted material treatment from174/163.

## User Stories

1. As the owner, I want the selected visitor to keep its accepted clothing during startup, idle, movement and Tab hide/resume, with evidence that catches black or fragmented torso frames.

## Implementation Decisions

Continue in integrate-square-164/buildv0.1.0 with one writer. Diagnostic evidence lives under docs/evidence; use existing render_diagnostics replay and174/native/Web paths. This Issue explicitly scopes additional private render_diagnostics.gd browser QA data for actual material resource paths, pose and renderer readiness if the minimal replay needs them; no shipped UI, functional dependency or frozen public interface/error/acceptance change. Name the proven runtime fix files and exact scope in this canonical Issue before any implementation. No asset edits or replacement gesture are authorized. Do not hide the failed frames, treat later clean stills as a universal pass, or call source/hash equality visual acceptance.

## Testing Decisions / acceptance criteria

1. Preserve the initial222/Astra finding,56%to28% pinned torso signal, identical15source files/character imported resources, fresh clean A/B pair, and initial-black/later-clean Tab replay as evidence. One runnable bounded replay reports timing, real readiness/pose/material state and identical framing, and catches the black/fragmented torso condition without asserting ordinary pose pixel changes are defects.
2. Run multiple baseline and candidate captures with the same renderer/settings and controlled inputs. Change one variable per causal probe; distinguish a screenshot-readiness defect from actual gameplay rendering. Report unknowns rather than repairing unchanged assets speculatively.
3. After a proven correction, rerun the original full sequence and native174 character checks, actual installed scripts/check.sh, git diff --check,18composed inputs/33states and source/hash/square173 protection. Preserve8tracked+3originaluntracked lint findings unless separately scoped.
4. Fresh independent GPT-6 Astra medium image/motion review of the affected group, current PR166 pictures and working private build, exact build/PR/map/checkpoint readback before scoped closure. Full162/149/173/174/177 and hands-on owner approval stay open; keep automation enabled until verified complete map.

## Out of Scope

Generated/provider/spend/bake/release/public redistribution, Nintendo-animation claims, source mesh/UV/skin/identity changes, artwork gesture, rights decisions,8remaining tracked lint findings, untracked owner files, other worktrees, main, hosted retry/settings/billing and inferred owner acceptance.

## Further Notes

Owner149 continuation authority; source and current exported evidence: docs/evidence/identifier-names-222. This diagnoses a real observed failure while leaving its cause unproven. Issue222 is the scoped17identifier-style correction; this follow-up and174/162 own the visitor visual finding.
