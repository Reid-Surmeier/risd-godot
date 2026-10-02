# Review loop

How the museum is driven to "done" (Issue #238). A round is: build, playtest, independent review,
then change the loop itself before the next round.

## One round

1. **Build.** Fix the open findings. Rebuild the rooms if any mesh changed (`scripts/rebuild_rooms.sh`).
2. **Playtest.** Run every pass of `museum_playtest.gd` and the three quick checks. Look at the
   pictures, not only the counts.
3. **Review.** An independent reviewer (Codex `gpt-6.1-sol`, highest reasoning effort) gets the
   round's brief, runs the playtest itself, plays the build, compares every room with the footage,
   and returns `VERDICT: DONE` or `VERDICT: NOT DONE` with numbered findings. Its report is kept in
   `docs/releases/v0.1.0/museum-review/round-N.md`, bound to the commit it ran on.
4. **Verify the findings.** Each finding is reproduced before it is acted on. A finding that does
   not reproduce is answered in the next brief with the evidence, not silently dropped.
5. **Refine the loop.** Before the next round:
   - every confirmed defect class becomes a rule in `museum-playtest-rules.md` and a check in the
     harness, so the same class cannot pass again unseen;
   - the reviewer's brief is rewritten: what was fixed and how to confirm it, what it missed last
     time and why, and at least one area it has not been pointed at before;
   - anything the round showed nobody knows (a measurement, a reference, a renderer limit) gets a
     research pass with primary sources, recorded in `docs/research/`;
   - the playtest grows a new area, not just more of the old ones.

A round that changes nothing in the rules, the harness or the brief was not a round.

## Round log

| Round | Commit | Verdict | Findings | New rules and checks | New research | Brief changes |
| --- | --- | --- | --- | --- | --- | --- |
