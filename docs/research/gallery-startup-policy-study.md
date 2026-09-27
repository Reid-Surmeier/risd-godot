# Gallery-first startup study — no runtime change

**Decision: keep the current warmup policy.** The measured startup can be partitioned more precisely, but no low-risk change is demonstrated that both reveals the gallery earlier and preserves responsive movement/first tab visits. This is read-only analysis of the recorded exported `105551c` run, checked against integrated source `b1fa810`. `boot_loader.gd`, `shell.gd`, `interface.gd` and `web/loading_shell.html` have no changes between those refs. No new browser/GPU run, Mac measurement, paid call or production edit was made.

## What the 9.827 seconds contains

The [original complete capture](../evidence/gallery-startup-policy/source-run.json.gz) is retained byte-for-byte, with SHA256 and recomputed intervals in [stages.json](../evidence/gallery-startup-policy/stages.json). It was hardware RTX4070SUPER Chrome at720×486, not an M3 capture.

| Measured interval | Elapsed |
| --- | ---: |
| `engine-started` → initial gallery `launch-settled` |4.359s|
| Initial gallery settled → `tabs-warm` |5.468s|
| **`engine-started` → `tabs-warm`** |**9.827s**|
| `tabs-warm` → `game-shown` |1.858s|

`engine-started` is the HTML promise-resolution mark after `engine.startGame()`, **not the beginning of all engine work**. `warmup-start` occurs344.4ms earlier. The actual warmup start→initial launch interval is4.703s; total warmup start→tabs warm is10.172s. This ordering matters when attributing work rather than reporting a user-facing timestamp.

After the initial gallery, boot selects the other five legacy tabs and finally returns to the gallery:

| Tab | Inside synchronous `Shell.select_tab()` | After selection through settle/two drawn frames | Total |
| --- | ---: | ---: | ---: |
| Map |717.8ms|192.0ms|909.8ms|
| Sketchbook |585.8ms|1480.8ms|2066.6ms|
| 3D Viewer |915.7ms|434.1ms|1349.8ms|
| Video |147.0ms|236.1ms|383.1ms|
| Playground |212.7ms|270.7ms|483.4ms|
| Gallery return |1.1ms|273.9ms|275.0ms|

The select calls total**2.580s**; after-select waits/draw work total**2.888s**, with the remaining fraction of a millisecond between marks. These are wall-clock intervals. The selected calls contain synchronous tenant construction/attachment and signal handling; the latter column combines fade waits and rendering/driver work. They do not isolate individual texture upload or shader compilation calls. Sketchbook's1.481s after-select interval is much larger than its configured0.2s fade, so treating that whole interval as removable animation would be incorrect.

## Exact call chain and seam constraint

The shipped primary sources are [HTML loader](../../web/loading_shell.html), [boot implementation](../../modules/shell/boot_loader.gd), [Shell implementation](../../modules/shell/shell.gd), and its [frozen interface](../../modules/shell/interface.gd).

1. HTML downloads/decompresses the game pack alongside engine initialization, then calls `engine.startGame()`. The boot scene mounts the pack, requests the demo scene with threaded resource loading, instantiates it and calls `_warm_up()`.
2. Shell creates the fixed tab/page structure. The Collection launch tab grows, then `select_tab()` triggers `_on_tab_selected()`. `_create_tenant()` synchronously calls the registered factory; adding the Control runs its ready/tree setup. The Collection factory in `demo.gd` builds the actual gallery. The fade finishes and hidden pages are frozen.
3. `_warm_up()` observes public `Shell.state()`, waits for the launch to settle, then calls public `Shell.select_tab()` for indexes0,1,2,3,5,4. That API **makes each tab active**, rather than invisibly preparing it. It waits for switching to finish and two process frames. Flowers index6 is not warmed; the six-tab loop predates that seventh tab.
4. `tabs-warm` enables the loader's completion path. HTML removes the overlay after its1.8s exit. On first later tab clicks, the already-created tenants resume rather than paying the same construction cost again.

The Shell interface exposes creation, selection, closing and state. It has **no budgeted prewarm or partially-ready tenant operation**. Its documented show/hide rule freezes hidden pages, and its tenant factory returns a fully constructed Control synchronously. Calling private `_create_tenant()` or temporarily rendering hidden pages from boot would bypass this seam. Changing the frozen contract is a separate scoped design, not a boot-loop tweak.

## Why gallery-first is not a proven small improvement

Showing the existing initial gallery before other tabs could remove approximately**5.468s of this run's initial waiting**, if other work and the loader exit stayed the same. That is a counterfactual upper-level subtraction, not a tested time-to-interactive result.

- Continuing the current warmup loop after revealing the page would visibly select other tabs and freeze the gallery. It cannot satisfy “gallery remains interactive.”
- Running the same synchronous constructors in an idle callback merely delays when their717.8/585.8/915.7ms calls start; it does not split those calls. Movement arriving during them could still pause. The recorded after-select render cost also remains.
- Skipping warmup makes the gallery available earlier but transfers the first-visit cost to Map/Sketchbook/3D Viewer. The existing policy was introduced after measured1.8s/1.1s first-click freezes. This is an explicit product tradeoff, not a cost-free optimization.
- Removing fades or the two draw waits is not supported by the existing trial: the zero-fade experiment moved about2s to the final gallery return and yielded only about0.3s net warmup gain. See [the measured earlier result](gallery-load-performance.md). Shaders/uploads still had to become ready.
- Reordering tabs cannot eliminate their measured work. Flowers' separate asynchronous stall after a visit is unrelated to this boot span; it is not warmed and cannot explain an unvisited-gallery report. See [the pinned-source diagnosis](gallery-hidden-startup-followup.md).

The1.858s final loader exit is presentation after tabs are warm, outside the9.827s question. Shortening that animation would be a separate visible behavior change, not proof that tenant warmup is faster. No such change was made here.

## A concrete next study, if startup policy is reopened

Keep this ticket's result as no-change. A separate preparation/seam design would need to identify which expensive factory work can be loaded in advance and which must be drawn on the main thread, with a real work budget rather than a deferred monolithic call. First collect constructor/first-draw attribution in the actual exported browser, preserving existing marks. Then define readiness and first-click behavior explicitly before adding a prewarm operation or changing tenant creation.

A candidate must beat the same-export cold visible-start time while real input continues during all delayed work, without a new process/presentation stall above50ms or slower first visits. Check the gallery before any other tab, each first tab visit, return to gallery, and a late Flowers visit separately. Repeat on the owner's M3/browser; Linux RTX and CPU throttling cannot certify that device. Do not call an earlier overlay removal a performance improvement unless actual movement remains responsive through the deferred work.

## Verification and cost

Read and recomputed the exact recorded marks; verified relevant source is identical between105551c andb1fa810; all local report links resolve and `git diff --check` passes. No new runtime assertion or frozen test was added, and no benchmark was repeated merely to restate unchanged source. Paid cost**$0**; no GPU slot used or contact-shadow trial interrupted. The latest owner's unvisited-gallery Mac lag remains unresolved.
