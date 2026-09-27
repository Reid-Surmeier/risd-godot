# Blind generated visitor motion review

**Visual verdict:** there is a plausible short four-view walk extraction, but the complete eight-second sheet is not a consistent four-direction motion set. Both side cells turn front-facing at about 3.2–3.5 seconds and stay there through the gestures. No four-view gesture set is usable. The raw run remains failed and uncertified because of the reported 960-versus-720 resolution failure; this review does not override that gate.

## Chosen walk candidate

Use **2.125 seconds inclusive to 3.000 seconds exclusive**, zero-based **frames 51–71 at 24 fps**. This is **21 frames / 0.875 seconds**, with frame 72 serving as the comparison endpoint, not an extra held frame. This is the best practical shared interval found by inspecting exact source frames and comparing nearby repeated leg poses. It is a candidate for a loop review, not a claim of a perfect seamless loop.

The interval contains alternating foot/arm motion, retains front/back/left/right orientations, avoids the initial stand-to-walk transition, and ends before the side-view turn. A longer 0–4 second loop must be rejected: it includes startup, cumulative drift, deceleration and turning.

| Cell | Honest walking material | Chosen shared interval assessment |
| --- | --- | --- |
| Top left / front | Approximately 0.125–3.125 s | Recognizable front walk. Shoes advance/retreat and expose soles. Endpoint is close, but a slight horizontal/foot-height reset remains. |
| Top right / back | Approximately 0.125–3.125 s | Most stable of the four. Alternating soles remain clear. Minor position and limb-shape seam remains. |
| Bottom left / left | Approximately 0.125–3.125 s | Clear profile walking. Earlier material visibly drifts left; later chosen cycle is more contained. Feet change shape at overlap/contact and the seam has a small position reset. |
| Bottom right / right | Approximately 0.125–3.125 s | Clear opposite profile walking. Earlier material drifts right; chosen cycle reduces this but does not remove it. Small seam reset and foot-shape variation remain. |

The selected gait is brisk: approximately 1.14 complete cycles / 2.29 steps per second if played at source speed. It reads more like a brisk walk/light jog than a slow museum stroll.

## Drift and contact evidence

Measurements below are approximate image-space proxies, not recovered skeleton/root coordinates. Each raw cell is 480×480. Hat-color centroid tracks gross movement; lowest foreground pixel tracks the sole envelope. Measurements accompany visual inspection rather than replacing it.

Across selected frames 51–71, hat-centroid horizontal ranges are approximately **5.5 px front, 3.4 px back, 13 px left, 13 px right**. Lowest-foot ranges are **467–477 px front, 467–473 px back, 457–461 px left, 457–461 px right** in cell coordinates. Some vertical variation is intended stepping, but it means the lowest current foot is not a stable root anchor.

Between comparison frames 51 and 72, hat-centroid horizontal changes are about **−3.5 px front, +2.7 px back, −3.9 px left, +6 px right**; bottom-foot changes are **+2, 0, 0, +2 px**. Thus the cut is close but not exact. At small display size these become small shifts; at native cell size they are visible. The feet and shorts also deform modestly, so translation alone would not make a mathematically seamless loop.

The wider sequence has substantially worse drift: between frames 6 and 71 the left hat center moves roughly 52 px left and the right roughly 47 px right. This is why the later single cycle is preferable to retaining several seconds. No floor exists in the raw image, so precise planted-foot/no-slip behavior cannot be certified. In the profile cells, shoes overlap and soften at contact; they do not retain rigid, trackable sole geometry throughout.

## Gesture decisions

| Cell | Head look | Wave / greeting |
| --- | --- | --- |
| Front | **Visually usable one-shot candidate around 4.0–5.5 s.** Head turns while front torso remains readable. The mouth changes from the identity smile to an O expression; this is a curious/surprised reaction, not expression-neutral idle. The requested 5–6 s window contains mainly a return-to-front fragment, not the complete gesture. | **Reject 6–7.1 s:** this cell does not perform a readable wave. |
| Back | **Conditional one-shot candidate around 4.0–5.5 s.** Head turns far enough to show an eye/profile while torso remains back-facing. Large neck twist needs an artistic acceptance decision. 5–6 s alone is only the latter part. | **A raised-hand greeting is usable around 5.5–7.5 s**, including lift and lowering. **6–7.1 s alone is mostly the raised-arm hold**, not a convincing complete oscillating wave. Do not label it a full waving loop. |
| Left | **Reject as left-view gesture:** body/head have already turned toward the camera. | **Reject as left-view wave:** visible motion exists but is front-facing. |
| Right | **Reject as right-view gesture:** body/head have already turned toward the camera. | **Reject as right-view wave:** visible motion exists but is front-facing. |

**Answer to “any gesture usable?”** Yes, as limited visual salvage: front curious head-look and back raised-hand greeting. No complete four-direction head-look or wave set; no honest front-cell wave. These are one-shot candidates, not seamless loops or certified deliverables.

## Identity and evidence

The first walking section preserves the source's large round head, red cap, yellow leaf shirt, dark shorts and brown shoes well. The side-cell turn and later mouth-expression change are the major semantic deviations, rather than a wholesale character-identity collapse.

Inspected the actual 960×960, 24 fps, 8.041667-second MP4 and source identity image. Source contains video only; no audio was heard or assessed. Existing 2 fps extractions guided selection; exact source-frame extractions supplied timing and seam checks. No deliverable pixels were edited, no repository files were modified, and no generation was initiated.

Inspection sheets: `/tmp/blind-motion-visitor-exact.png`, `/tmp/blind-motion-visitor-loop-gestures.png`, `/tmp/blind-motion-visitor-five.png`. Source run: `image-work/gallery-character-motion/artifacts/image-generation/runs/run-b987214702e0dedab7819356/outputs/output.mp4`.
