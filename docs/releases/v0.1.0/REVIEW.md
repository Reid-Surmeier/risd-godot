# v0.1.0 review

verdict: needs-work

Reviewed 2026-09-27 against fixed point `main` at `b54016f74060723749b62d051b6c5563e59cddf6`. Visual baseline: owner-approved `8b26833af8397ee8df611977bc82795bc916849e`. This record also covers the consolidation changes committed alongside it; it is not a ship verdict for a subsequently changed commit.

## Standards

One unresolved contract discrepancy: `modules/tab_strip/interface.gd` says every public function returns `{ ok, value, error }`, but `set_bar_width` returns `void` and `stub_rect` returns `Rect2`. These are existing frozen API shapes, so this cleanup must not silently change callers or acceptance tests. Resolve through a scoped contract issue or an explicitly documented exception before release signoff.

## Spec

- **#35 remains incomplete.** The issue requires a rights record identifying source, license or permission, date and grantor in `docs/rights.md`. That file is absent; Video Player, Sculpture Viewer and Sketchbook provenance still explicitly record pending rights information. This is a missing specified record, not a finding that permission cannot exist.
- **#141 remains unproved on the integrated build.** Acceptance requires a reduced median cold-ready time across controlled repeats. Recent Sketchbook evidence records approximately 54–70 seconds to reveal, but does not establish a matched integrated before/after median. Different workloads cannot prove a regression or a performance pass. Owner-device acceptance also remains distinct from Linux proxy measurements.
- **#147 wording differs from accepted behavior.** `desktop.gd` retains responsive width growth, and `playtest/coverflow.mjs` checks that formula rather than a fixed 630:555 ratio. The owner's visual approval of `8b26833a` overrides the stale geometry wording. Preserve the approved appearance and reconcile the specification; this is not authority to resize the book again.

Issues #146–147 supersede #145's seven framed viewer images: six unframed images and a separate framed painting are intentional. No additional verified scope-creep finding is recorded. The source review was targeted; it was not an exhaustive line-by-line audit of vendored dependencies.

## Ponytail (ultra)

ponytail: 7 findings, 2 fixed, 5 accepted

1. **Fixed — superseded evidence:** removed the selected obsolete evidence from the current tree; retained history and preservation records provide recovery.
2. **Fixed — zero-caller prototypes:** removed the audited unused prototypes rather than maintaining parallel examples with no runtime consumer.
3. **Accepted — move Cover Flow out of its prototype location:** defer because the live Sketchbook loads assets and JSON there; moving it requires coordinated path/export verification and offers no immediate behavior improvement.
4. **Accepted — remove hidden saved-card machinery:** defer because it participates in saved-reference loading and state reporting; deleting it needs a focused persistence regression scope despite the cards being invisible.
5. **Accepted — remove gallery experiment switches:** retain the matched character/render comparison routes used by unresolved gallery acceptance; removing them would discard controls needed to verify the next candidate.
6. **Accepted — remove the tldraw throwaway window:** retain because its controls participate in the current Sketchbook composition and input flow; removal would change the owner-approved runtime rather than merely delete unused files.
7. **Accepted — extract shared paper-turn code:** defer because consolidating implementations across modules requires a separately scoped seam/dependency change and could alter accepted page-turn behavior.

The separate whole-repository audit additionally removed unused `tools/set_palette.py`; this is not an eighth diff-review finding.

## Verification limits

This review records the three completed review axes and the disposition of cleanup findings. It does not claim new browser, performance, clean-restore or CI passes. Re-run the repository and relevant Sketchbook/gallery checks on the final consolidated commit, inspect that export, and attach its exact evidence before reconsidering the verdict. Unresolved Standards and Spec items above prevent `ship` even when the accepted visual layout is preserved.
