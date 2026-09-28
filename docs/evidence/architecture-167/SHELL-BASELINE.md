# Shell playtest — pre-existing failure, not waived

After portal7, the frozen public Shell playtest exits 1. The failing visual
and layout checks reproduce using an isolated archive of cornice checkpoint
`c424cb35`, before the portal changes. Shell implementation, interface, errors,
playtest, tab_strip and testing files have no diff from that checkpoint.

Current evidence: `portal7-shell/`; isolated baseline evidence:
`portal7-shell-baseline/`. Both include screenshots, frame sequences, report
and independently re-run `verification.txt`. Baseline fixture:
`/tmp/risd-167-shell-baseline.fUMcjx`; files extracted with `git archive`, not a
new implementation worktree. Import completed before the baseline playtest.

Shared failures include non-white launch Page, tenant inset, grey-Page mean
165, absent collection dip and resized tenant
1368×825. Timing-sensitive checks vary between runs. No architecture scene is
mounted by this harness. These are evidence of an existing Shell/test mismatch,
not permission to change frozen acceptance tests under #167.

No claim is made that the public Shell baseline passes. Repository and private
architecture checks are reported separately; the independent portal7 visual
gate also remains FAIL for its own reasons.
