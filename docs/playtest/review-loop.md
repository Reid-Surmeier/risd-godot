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
| 2 | `fbb57bcc` | not done (draft: the reviewer ran out of time before filing) | Of round 1's ten: 4 closed, 6 partly. New: 14 hidden works still answer a click and seven European case pieces are in no registry; inspections that pass the harness but show a covered, absent or back-facing work; view glides that pass through walls; 21 of 23 Hall hang centres off by over 10 cm and room and door dimensions still wrong; seven galleries where the floor is the brightest large area; title overflow; controls resuming before the camera returns; two cues on a first click; no bench seating. | The brief gained a close-out table for the previous round, a wall-by-wall manifest comparison, measured sizes, and five checks round 1 could not do (hidden picks, frame-by-frame continuity, brightness by surface, geometry seams, recorded sound). Harness: visitor never photographed inside a case; stubs under 2.2 m exempt from the flat-wall rule; follow-view fallback for high works. | The reviewer's own measurements: brightness by surface per room, 23 Hall hang heights, a wall ledger per room (kept with its evidence). | Round 3 must be given a time budget and told to write its report file first and extend it as it goes, so a stop never loses the verdict; and its checkout must be the commit of the shared build. |
