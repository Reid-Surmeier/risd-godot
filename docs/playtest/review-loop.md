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
| 1 | `a29ad9e9` | not done | 10: missing rooms and displays, visitor covering inspected works, an unreachable click throwing, hidden works stealing clicks and the lion's zoom, lighting and label colour, seam check failing, Shift latch, doubled pose, cut view changes, rate-dependent jump with working-note captions and a doubled sound | Objects pass now fails when a different work opens, when the work is not wholly in the inspection picture, and when the visitor covers it. The jump is checked at four frame rates. Rules 6-8 and four hand checks added to `museum-playtest-rules.md`. | None yet; the eight room builders and the Hall re-light landed after this commit and are what round 2 reviews. | Round 2 reviews the integrated build, is given this report, and is told to check each finding closed or still open before looking for new ones. |
