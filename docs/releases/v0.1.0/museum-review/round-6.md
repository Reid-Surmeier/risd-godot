VERDICT: NOT DONE

Build: `431f5921` — the latest URL redirected to this build at 10:12 EDT on Friday 9 October 2026. Review branch starts at `431f5921d453917be966e7e0a465fa31ddb51d2c` from `origin/build/v0.1.0`.

# Independent museum playtest, round 6

Reviewer: Codex, working alone. Review window: 10:10–11:25 EDT; owner deadline 13:00 EDT. GPU headless Chrome, actual exported Web game, real keyboard and pointer input. No game code or assets changed. Scratch: `build/review-round-6/`.

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

| Owner claim | Result so far | Browser evidence |
| --- | --- | --- |
| 1. Warm umber beyond rooms; blinds; medieval slab removed | **PARTLY · VERIFIED** | Umber surrounds and warm sills replace the sampled straight doorway voids; the medieval free-standing slab is gone. [Gallery A blinds](../../../evidence/review-round-6/09-claim-blinds.jpg) are fitted. Black areas remain at the lower Skylight door and the stair deck at the Impressionist entry (findings 3–4). Both A and B windows have blinds. |
| 2. Warm pools at every work, including the Hall | **YES in the walked rooms and inspected sample · VERIFIED** | [Warm work pools](../../../evidence/review-round-6/14-warm-work-pools.jpg). The Hall paintings now have clear amber pools above/around them; the sampled sculptures and works in the later rooms are also warmed. This is a walkthrough plus 22 readable work inspections, not an exhaustive 177-object lighting audit. |
| 3. Warm medieval room | **YES · VERIFIED** | [Medieval and subsequent rooms](../../../evidence/review-round-6/04-room-lighting-in-motion.jpg). Warm floor, amber pools around wall works and door sills in the medieval walkthrough; dark wall colour remains. |
| 4. Soft warm haze and inviting doorway sill | **YES · VERIFIED** | [Continuous Hall crossing](../../../evidence/review-round-6/02-warm-haze-and-arrival.jpg); warm haze also closes and opens on the later room changes; same-stage connectors stay continuous. The warm veil is opaque at its midpoint but is not black. |
| 5. Walk 1.9 m/s, run 4.5 m/s | **YES · VERIFIED** | [Walk and run](../../../evidence/review-round-6/03-walk-run-speed.jpg). Sustained browser probe velocity is 1.900 and 4.500 m/s in recordings 10, 13 and 14; the gait changes in motion. |
| 6. Turn to face camera on arrival | **YES at Renaissance arrival · VERIFIED** | [Arrival picture](../../../evidence/review-round-6/02-warm-haze-and-arrival.jpg). Release the crossing key, let arrival finish; the visitor turns to the lens. |
| 7. Impressionist entry beside fireplace and re-hung B | **YES for the requested route and hanging · VERIFIED** | [Entry, Le Repos and B walls](../../../evidence/review-round-6/10-impressionist-route-and-B.jpg). Walked the cased opening beside the fireplace, passage and A; *Le Repos* is on the far wall. B has the two landscapes by the A door, river/tree wall, three southern works by the modern door and Cassatt between blinds, checked against IMG_6343 180–222s. The under-stair EXIT is not the route. The declared extra depths/length are KNOWN and not remeasured; entry camera obstruction is finding 3. |
| 8. Small-room follow camera outside visitor's head | **YES in Rockefeller and modern · VERIFIED** | [Original/follow view, still and moving](../../../evidence/review-round-6/05-follow-camera-rockefeller.jpg). The visitor remains in front of the lens while walking beside cases and turning by a wall; no inside-head frame seen. [Smaller modern room in motion](../../../evidence/review-round-6/12-follow-camera-modern.jpg), actual `VIEW original` mode, also keeps the lens outside the head while approaching a wall and turning. |

## Coverage and timing

Initial load: **48.64 s to `game-shown`**. Hall → medieval, medieval ↔ Renaissance, Renaissance ↔ European and European → Rockefeller have been walked and continuously captured at 11.9–19.1 fps; no permanent black screen, crash or unclosable work so far. Two medieval works (59.131, 69.196), two Renaissance works (21.398, 58.196) and two European works (44.674, 53.349) have opened readable captions and closed. The latter Renaissance work's zoom page shows the correct photograph and caption and closes. Rockefeller (2017.74.31.1, 2017.74.27.1), grey French (23.005, 73.120) and Skylight (2000.17, 2026.3) also have two readable inspections closed again. The Pile zoom page opens and closes. Connector has no registered work. Three Skylight stair flights have been descended and ascended; the clear return avoids the piano. Rockefeller ↔ connector and connector ↔ grey have been crossed both ways at walk and sprint. Grey ↔ Skylight, grey ↔ marble, marble ↔ passage and passage ↔ A have now been crossed both ways at walk and sprint. The fireplace surround 83.152 caption was read and closed; the known chandelier limitation prevents a second marble-hall caption. A (41.012, 59.027) and B (2010.57, 60.095) each have two readable captions closed; A ↔ B and B ↔ modern are crossed both ways at walk and sprint. Modern (67.089, 1995.043) captions and the single lion relief (34.652) also read and close. Modern ↔ lion and lion ↔ medieval pass both ways at walk and sprint, including a jump by the lion doorway. The requested museum loop has reached its final medieval room; Main Hall 33.204 and 62.064 have readable captions and close again; 62.064 also opens the correct zoom photograph and closes. The 22-work reading sample is complete, with zero unclosable works. Hall ↔ grey and the final Renaissance ↔ European sprint checks are complete. All 15 required/tested openings, including continuous openings, were traversed in both directions at walk and sprint. Map → Collection returned to the same room and allowed movement; its frame gaps are excluded because repository checks were running concurrently. [Modern and lion evidence](../../../evidence/review-round-6/13-modern-and-lion-lighting.jpg). Portrait 800 × 1280 and small 800 × 600 browser resizes preserved a readable grey-gallery caption and let it close.

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

These are maxima from recorded doorway windows across the tested walk/sprint legs, including approach and opening; they are from this GPU browser, not promises for the owner's device. The isolated connector → grey sprint gap (0.302 s) is the largest measured browser frame in those windows. The later walk back to Renaissance had a 138.6 ms browser gap somewhere in its longer multi-room route; it is not assigned to a door without an exact window. Captures are looked at as contact sheets. The earlier, unsuccessful attempts to walk through case furniture are retained in scratch and are not counted as doorway crossings.

Console so far: no JavaScript exception or Godot SCRIPT ERROR; one non-game failed resource, `favicon.ico` (404), and invalid-UID fallback warnings. The Web build remains responsive.

## Deadline triage and remaining limits

**No confirmed fault meets the Round 6 exception for a fix before 13:00.** There are five reproduced faults, not ten; their priority for later work is: startup wait, Skylight floor covering the visitor, stair deck hiding the corrected entrance, lower decorative black door, ignored click while walking. The first four are POLISH and the last MINOR. No code or asset fix was made.

Not tested: the owner's device/network; deliberate network throttling; all 177 works; every camera mode in every room; every possible diagonal/door-cheek angle; listening to audio; the upper marble stair destinations and off-loop stub galleries. The two works per room rule is fulfilled in the ten rooms with at least two inspectable works (20 reads), plus the fireplace and lion (22 total). Connector and Impressionist passage have no works; lion has one; marble's second object is the known non-clickable chandelier. No full 24-minute engine census was rerun. Native repository checks are being rerun after a local cache import; results will be recorded below.

## What the harness should learn

Add browser acceptance for fresh `game-shown` time and the largest frame through each door, measured independently of resize/tab changes. Walk the Skylight lower floor after closing an inspection and assert that the visitor remains visible beneath raised floors; a route that only visits the upper landing misses this fault. Add the correct fireplace doorway to camera-occlusion checks and compare moving-key clicks with stationary clicks. Keep the empty-passage and one-work-room exceptions explicit, wait for a real caption before counting a read, and exercise Escape from zoom and inspection separately. Visual capture remains necessary: a successful traversal does not show whether the visitor is covered by a floor or stair.

