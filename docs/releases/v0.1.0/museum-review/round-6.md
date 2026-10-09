VERDICT: NOT DONE

Build: `431f5921` — the latest URL redirected to this build at 10:12 EDT on Friday 9 October 2026. Review branch starts at `431f5921d453917be966e7e0a465fa31ddb51d2c` from `origin/build/v0.1.0`.

# Independent museum playtest, round 6

Reviewer: Codex, working alone. Review: 10:10–11:23 EDT (75-minute cap at 11:25); owner deadline 13:00 EDT. GPU headless Chrome, actual exported Web game, real keyboard and pointer input. No game code or assets changed. Scratch: `build/review-round-6/`.

The complete requested loop is playable on this GPU browser, with no confirmed BLOCKS PLAY. **NOT DONE refers to the remaining visual/interaction faults, not an inability to walk the loop.** VERIFIED means reproduced in this browser; INFERRED means a conclusion not directly reproduced. BLOCKS PLAY means a crash, persistent black screen, inaccessible room, or a work that cannot be closed. Other faults are ordered by the owner's first five minutes and then condensed.

## BLOCKS PLAY

**None confirmed.** Every required room was entered and left; all 22 opened works closed. There was no crash, persistent black screen or trapped room. This is the pinned build on one GPU browser, not a guarantee for another device.

## First five minutes

### 1. Startup takes almost fifty seconds before the owner can play.

**VERIFIED · POLISH · KNOWN slow-load class, current measurement.** A fresh browser load reaches `window.loadPerf`'s `game-shown` at **48.64 s**; downloads finish at 2.25 s, engine starts at 4.18 s, launch settles at 46.65 s. Steps: (1) open the pinned build in fresh GPU Chrome; (2) wait for the Collection game to appear. This is a wait, not a persistent black screen. The first Hall → medieval doorway subsequently works: its largest game draw/process gap is **0.242 s**, with no round-5 quarter-minute freeze. [Picture and timing](../../../evidence/review-round-6/01-load-48-seconds.jpg). Raw marks: `build/review-round-6/initial.json`; continuous doorway capture and samples: `01-hall-first-door/`, `01-first-door.json`.

## The rest, one line each

2. **VERIFIED · POLISH · NEW:** on the Skylight lower floor, a herringbone surface hides the visitor's body near the landing, leaving the hat; click *Pile*, close its caption and walk to (0, -35.84); [picture](../../../evidence/review-round-6/07-skylight-floor-covers-visitor.jpg), recordings 39–47; the clear return uses x=-0.5, z=-38.1 then the east stair, and all three flights work; **INFERRED:** the surface belongs to another room.
3. **VERIFIED · POLISH · KNOWN slab class, NEW entry check:** at the correct Impressionist entry, the stair deck fills almost the whole default view; approach the fireplace door at (6.88, -27.41), turn toward +z and pause; [picture](../../../evidence/review-round-6/08-marble-entry-obstructed.jpg), continuous recording 51; continuing through clears it and enters A.
4. **VERIFIED · POLISH · KNOWN doorway class, NEW lower-floor check:** the lower Skylight door under the landing reads as a cool black rectangle; descend the three flights and look beside lift “4”; [picture](../../../evidence/review-round-6/06-lower-skylight-dark-door.jpg); this decorative door is outside the required loop.
5. **VERIFIED · MINOR · NEW:** clicking a work with a movement key held does not select it; face the large modern *Mountaineers Attacked by Bears*, hold W and click its centre, then release W and click again to open the caption; recordings 67/69 have `NAV_PICK` only for the stationary click; [picture](../../../evidence/review-round-6/11-click-while-walking.jpg); Escape closes normally.

## Eight owner claims

| Owner claim | Result | Browser evidence |
| --- | --- | --- |
| 1. Warm umber beyond rooms; blinds; medieval slab removed | **PARTLY · VERIFIED** | Umber surrounds and warm sills replace the sampled straight doorway voids; the medieval free-standing slab is gone. [Gallery A blinds](../../../evidence/review-round-6/09-claim-blinds.jpg) are fitted. Black areas remain at the lower Skylight door and the stair deck at the Impressionist entry (findings 3–4). Both A and B windows have blinds. |
| 2. Warm pools at every work, including the Hall | **YES in the walked rooms and inspected sample · VERIFIED** | [Warm work pools](../../../evidence/review-round-6/14-warm-work-pools.jpg). The Hall paintings now have clear amber pools above/around them; the sampled sculptures and works in the later rooms are also warmed. This is a walkthrough plus 22 readable work inspections, not an exhaustive 177-object lighting audit. |
| 3. Warm medieval room | **YES · VERIFIED** | [Medieval and subsequent rooms](../../../evidence/review-round-6/04-room-lighting-in-motion.jpg). Warm floor, amber pools around wall works and door sills in the medieval walkthrough; dark wall colour remains. |
| 4. Soft warm haze and inviting doorway sill | **YES · VERIFIED** | [Continuous Hall crossing](../../../evidence/review-round-6/02-warm-haze-and-arrival.jpg); warm haze also closes and opens on the later room changes; same-stage connectors stay continuous. The warm veil is opaque at its midpoint but is not black. |
| 5. Walk 1.9 m/s, run 4.5 m/s | **YES · VERIFIED** | [Walk and run](../../../evidence/review-round-6/03-walk-run-speed.jpg). Sustained browser probe velocity is 1.900 and 4.500 m/s in recordings 10, 13 and 14; the gait changes in motion. |
| 6. Turn to face camera on arrival | **YES at Renaissance arrival · VERIFIED** | [Arrival picture](../../../evidence/review-round-6/02-warm-haze-and-arrival.jpg). Release the crossing key, let arrival finish; the visitor turns to the lens. |
| 7. Impressionist entry beside fireplace and re-hung B | **YES for the requested route and hanging · VERIFIED** | [Entry, Le Repos and B walls](../../../evidence/review-round-6/10-impressionist-route-and-B.jpg). Walked the cased opening beside the fireplace, passage and A; *Le Repos* is on the far wall. B has the two landscapes by the A door, river/tree wall, three southern works by the modern door and Cassatt between blinds, checked against the source ledger and spot frames from IMG_6343 181, 190, 195, 200, 205, 210 and 220s. The under-stair EXIT is not the route. The declared extra depths/length are KNOWN and not remeasured; entry camera obstruction is finding 3. |
| 8. Small-room follow camera outside visitor's head | **YES in Rockefeller and modern · VERIFIED** | [Original/follow view, still and moving](../../../evidence/review-round-6/05-follow-camera-rockefeller.jpg). The visitor remains in front of the lens while walking beside cases and turning by a wall; no inside-head frame seen. [Smaller modern room in motion](../../../evidence/review-round-6/12-follow-camera-modern.jpg), actual `VIEW original` mode, also keeps the lens outside the head while approaching a wall and turning. |

## Coverage and timing

**VERIFIED:** the complete requested loop, the Skylight descent/return and every required opening in both directions at walk and sprint; also the extra Hall ↔ grey doorway. Fourteen route openings plus that extra return were tested. Continuous captures average 11.9–20.0 fps and were inspected as contact sheets. No code, runtime asset or frozen acceptance file changed.

| Room | Readable captions opened and closed |
| --- | --- |
| Main Hall | 33.204 *The Ferry Boat*; 62.064 *Portrait of a Cavalier with his Hunting Dogs* |
| Medieval | 59.131 *Head of Christ or a Saint*; 69.196 *Christ in Majesty* |
| Renaissance | 21.398 *Saint Roch*; 58.196 *Madonna and Child with Saint Barbara and Saint Catherine* |
| European | 44.674 *River God*; 53.349 *A Caricature Group…* |
| Rockefeller | 2017.74.31.1 *Neptune as River Deity*; 2017.74.27.1 *Parrot* |
| Connector | No registered work |
| Grey French | 23.005 *The Hand of God*; 73.120 *Landscape* |
| Skylight | 2000.17 *Pile*; 2026.3 *Foreign Sign* |
| Marble stair hall | 83.152 *Fireplace Surround*; second chandelier caption not obtained from the tested floor views (known census limit) |
| Impressionist passage | No work |
| Impressionist A | 41.012 *Still Life with Apples*; 59.027 *Repose (Le Repos)* |
| Impressionist B | 2010.57 *Child in a Red Apron*; 60.095 *Simone in a Blue Bonnet* |
| Modern | 67.089 *Seated Woman*; 1995.043 *Mountaineers Attacked by Bears* |
| Lion landing | Its one work, 34.652 *Panel with Striding Lion* |

**22 reads, zero unclosable works.** Renaissance 58.196, Skylight *Pile* and Hall 62.064 also showed the correct photograph and caption on zoom pages and closed back to walking. The clear Skylight stair return avoids the piano. A jump by the lion doorway and the walk/run gait changes were exercised in motion; no restart snap or landing failure was seen in those samples. [Modern and lion evidence](../../../evidence/review-round-6/13-modern-and-lion-lighting.jpg).

Map → Collection preserved the current room and allowed input. Its frame gaps are excluded because repository checks were running concurrently. Portrait 800 × 1280 and small 800 × 600 browser resizes preserved a readable grey-gallery caption and let it close; resize gaps are also excluded from doorway timing.

Initial load: **48.64 s to `game-shown`**. Room timing follows.

| Opening, either direction | Longest measured game gap | Longest browser frame gap |
| --- | ---: | ---: |
| Hall ↔ medieval | 241.8 ms | 239.1 ms |
| Medieval ↔ Renaissance | 82.7 ms | 38.3 ms |
| Renaissance ↔ European | 39.2 ms | 38.0 ms |
| European ↔ Rockefeller | 55.2 ms | 55.4 ms |
| Rockefeller ↔ connector | 41.2 ms | 41.1 ms |
| Connector ↔ grey, continuous | 301.4 ms | 301.6 ms |
| Grey ↔ Skylight | 49.4 ms | 36.5 ms |
| Grey ↔ marble, continuous | 238.3 ms | 237.3 ms |
| Marble ↔ Impressionist passage | 50.0 ms | 38.8 ms |
| Passage ↔ A, continuous | 56.5 ms | 32.0 ms |
| A ↔ B | 40.3 ms | 28.2 ms |
| B ↔ modern | 48.9 ms | 33.3 ms |
| Modern ↔ lion landing | 120.5 ms | 119.3 ms |
| Lion landing ↔ medieval | 49.0 ms | 30.4 ms |
| Hall ↔ grey, extra return | 52.8 ms | 36.7 ms |

These are maxima from recorded doorway windows across the tested walk/sprint legs, including approach and opening; they are from this GPU browser, not promises for the owner's device. The isolated connector → grey sprint gap (0.302 s) is the largest measured browser frame in those windows. The later walk back to Renaissance had a 138.6 ms browser gap somewhere in its longer multi-room route; it is not assigned to a door without an exact window. Raw doorway windows and capture inventory are `build/review-round-6/doorway-timing.json` and `capture-inventory.json`; captures were inspected as contact sheets. The earlier, unsuccessful attempts to walk through case furniture are retained in scratch and are not counted as doorway crossings.

Browser console: no JavaScript exception or Godot SCRIPT ERROR; one non-game failed resource, `favicon.ico` (404), and invalid-UID fallback warnings. The Web build remains responsive.

## Repository verification

**VERIFIED: checks passed**, after importing this worktree's missing Godot cache. Ran the commands from `scripts/check.sh`, with only its working directory and `/tmp` log destinations redirected into `build/review-round-6/check-repo.sh` to obey the scratch rule. `check-after-import.log` ends with `checks passed`: representation check **201 built / 201 declared, zero failures**, and placed-mesh check **zero failures**. These are representation counts, not the full 177-work browser census. Seven generic European props are reported as unregistered by that check. Native exit still prints an ObjectDB leak warning; no native SCRIPT ERROR or ERROR remains in the passing log. The first failed check is retained as `check-before-import.log`; its missing imported files were a local-cache issue, not a reproduced Web fault. `git diff --check` and the evidence/link audit pass. Fourteen JPEGs, each below 300 KB; [source and hashes](../../../evidence/review-round-6/PROVENANCE.md); scratch below 1 GB. 76 recordings hold 26,147 frames over about 27 minutes of captured interaction, including unsuccessful navigation attempts retained for audit.

## Deadline triage and remaining limits

**No confirmed fault meets the Round 6 exception for a fix before 13:00.** There are five reproduced faults, not ten; their priority for later work is: startup wait, Skylight floor covering the visitor, stair deck hiding the corrected entrance, lower decorative black door, ignored click while walking. The first four are POLISH and the last MINOR. No code or asset fix was made.

Not tested: the owner's device/network; deliberate network throttling; all 177 works; every camera mode in every room; every possible diagonal/door-cheek angle; listening to audio; the upper marble stair destinations and off-loop stub galleries. The two works per room rule is fulfilled in the ten rooms with at least two inspectable works (20 reads), plus the fireplace and lion (22 total). Connector and Impressionist passage have no works; lion has one; marble's second object is the chandelier. Its prior census says non-clickable; this round it stayed above the tested floor views, including four angles and Original/follow, so I could not obtain its caption (recordings 82–83). I did not test an upper-landing selection. No full 24-minute engine census was rerun. The native representation and placed-mesh checks above were run; no full room/object playtest census was run.

## What the harness should learn

Add browser acceptance for fresh `game-shown` time and the largest frame through each door, measured independently of resize/tab changes. Walk the Skylight lower floor after closing an inspection and assert that the visitor remains visible beneath raised floors; a route that only visits the upper landing misses this fault. Add the correct fireplace doorway to camera-occlusion checks and compare moving-key clicks with stationary clicks. Keep the empty-passage and one-work-room exceptions explicit, wait for a real caption before counting a read, and exercise Escape from zoom and inspection separately. Visual capture remains necessary: a successful traversal does not show whether the visitor is covered by a floor or stair.
