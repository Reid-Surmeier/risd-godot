# Gallery load and movement proxy on exported 105551c

This is a bounded follow-up to #137, using the exact `105551c` exported Web build on Linux/WSL Chrome with D3D12 RTX 4070 SUPER at 720×486. It is **not a Mac M3 measurement** and does not reproduce the owner's unvisited-gallery lag. No runtime change was justified or made.

## Reproducible proxy

The existing `scripts/gallery-performance-check.cjs` was run against the local export with its viewport set to 720×486 and its *post-load* all-tabs click loop removed for this small layout. The original all-tabs script loaded the game but timed out selecting a tab at 720; this is a harness coordinate limitation, not a measured game stall. Boot itself still warmed the same tabs. The valid proxy ran real gallery movement with W, W+D, D+S, opposed-key cancellation and reversal.

```bash
sed 's/width:1600,height:900/width:720,height:486/; s/for(const i of \[0,1,2,3,5,6,4\])/for(const i of [])/' scripts/gallery-performance-check.cjs > /tmp/gallery-performance-720-gallery.cjs
source /home/reidsurmeier/promo-lab/gpu-env.sh
PUPPETEER_MODULE=/home/reidsurmeier/promo-lab/node_modules/puppeteer-core node /tmp/gallery-performance-720-gallery.cjs http://127.0.0.1:18767/105551c.html /tmp/gallery-load-105551c-720.json
```

The one valid cold run showed the game at **14.931 s**, with download completion at **1.840 s**, Godot ready at **2.662 s**, engine started at **3.246 s**, tabs warm at **13.073 s**, and the final loader exit at **1.858 s**. The monolithic gzip game pack transferred **93.01 MiB** in **0.864 s** on the local network; the gzip WASM transferred **9.62 MiB** in **0.274 s**. At 40 Mbit/s, the earlier controlled pack-reduction result in [gallery-load-performance.md](gallery-load-performance.md) gives the more relevant transfer sensitivity: reducing the pack by 34.1% shortened visible cold start by 11.912 s. The current local run's **9.827 s from engine-started to tabs-warm** dominates local startup. Sequential launch and tab construction/upload/compile are the likely work within that interval; these marks alone cannot attribute one operation.

All **14/14** DOM key transitions reached Godot in order. Median/p95 receipt were **1.9/3.1 ms**; gallery process p95/max were **17.4/18.0 ms**, and post-draw p95/max **17.6/20.2 ms**. No sampled movement interval exceeded 50 ms. At the end, the Godot performance counter reported **101 draw calls** for the whole shell and about **997 MiB video memory** at 720. Peak observed Chrome JS heap was **372 MiB**. Those are partial counters, not total RAM/GPU residency or a measured Mac presentation time. Startup rAF p95/max were **283/2450 ms**, showing load-time main-thread pauses; the post-show movement sample is the relevant steady-state result. The raw run is [run.json.gz](../evidence/gallery-load-720/run.json.gz); [start](../evidence/gallery-load-720/start.png) and [end](../evidence/gallery-load-720/end.png) are actual export captures.

## Ranked causes and code decision

1. **Eager shell warmup** is measured as the largest local startup span. The boot scene deliberately shows every tab once to preserve first-click responsiveness. Earlier zero-fade and skip-warmup trials moved cost to the final return or first click and were rejected. No small change here improves both initial and first-click behavior.
2. **Large single game pack** matters when network is constrained. The retained export already excluded unused historical gallery prototypes, cutting the pack 34.1%. Source-tree sizes point to current gallery art (~63 MiB), sculpture viewer (~46 MiB) and atlas (~37 MiB) as large asset groups, but those are *source sizes*, not exact packed transfer contribution. Current gallery painting frames (~26 MiB source) and the skinned visitor are visible assets. The older sprite study (~18 MiB source folder) remains addressable through `?character=sprite`; deleting it from this shared pack would break a comparison route. Splitting optional packs or changing image data is a larger design change, not a safe export-filter tweak.
3. **Texture/GPU memory pressure on M3** is plausible from the ~997 MiB partial counter at 720, but unverified. The source and Web renderer must be profiled on that device before changing imported texture quality or startup policy.
4. **Hidden Flowers initialization** is a proven separate stall *after Flowers was visited*: the prior trace aligned a 374.9 ms Ruffle main-thread task with a 431.7 ms gallery gap. It cannot explain an unvisited-gallery M3 report. The pinned loader has no safe small cancellation seam; see [gallery-hidden-startup-followup.md](gallery-hidden-startup-followup.md).
5. **WASD delivery or gallery update bug** did not appear in this proxy. Ordered multi-key transitions, cancellation and movement passed. A Mac trace with `qa-perf=1&qa-crt=1` remains necessary to localize the owner's random lag.

The room already merges roughly 350 static meshes by material, and the whole 720 shell reports 101 draw calls. No isolated draw-call hotspot was demonstrated, so another geometry merge would be speculative. The measured current build should remain unchanged pending owner-device evidence or a scoped asset-pack redesign. This report does not certify M3 loading or motion.
