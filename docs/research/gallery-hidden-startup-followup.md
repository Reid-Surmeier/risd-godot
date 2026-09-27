# Gallery stalls: bounded follow-up to #137 / #141

**Decision (2026-09-27): no additional runtime fix is justified by the available evidence.** Inspected integrated source `f14d8dc` in isolated branch `Reid-Surmeier/gallery-hidden-startup`. The retained pack reduction is useful; the owner's M3 movement report remains unresolved. No new GPU benchmark, Mac measurement, paid call, art change, or frozen-test change was made in this follow-up.

## What the trace proves

The [existing performance report](gallery-load-performance.md), [aligned correlation](../evidence/gallery-load-performance/late-stall-correlation.json), and [raw trace](../evidence/gallery-load-performance/late-stall-chrome-trace.json.gz) concern a run that **visited Flowers before returning to the gallery**. A 374.911 ms Ruffle main-thread function falls within a 431.7 ms Godot process gap; the 15.24 MB Ruffle WASM request finishes immediately beforehand. The page is visible, focused, and on gallery tab 4. Minor GC is at most 1.802 ms in that sample.

A CPU-only replay of the raw trace finds that function and fails an explicit `duration <= 50 ms` assertion. This reproduces the recorded violation, not a fresh live stall or a tested remedy. Existing Linux input tests receiving every transition do not rule out update stalls between transitions. Flowers is not boot-warmed, so this event cannot explain an otherwise identical run where Flowers was never opened.

Ranked hypotheses and discriminating evidence:

| Hypothesis | Evidence / next falsifier |
| --- | --- |
| Pending Flowers initialization completes after leaving the tab. | Supported in this trace. Hold the Ruffle WASM response until after gallery return; a lifecycle fix must prevent hidden initialization, then resume correctly on revisiting Flowers. |
| Already-loaded hidden Flowers continues running. | CSS-only hide leaves the player unpaused in source. Measure callbacks before/after hiding an initialized game; this is separate from initial WASM construction. |
| M3 input receipt or gallery update/rendering stalls independently. | Unresolved. Reproduce with Flowers unvisited and compare DOM keys, Godot keys, held state, positions, process intervals and browser trace. |
| GC dominates the recorded stall. | Contradicted by this sample's timing; do not generalize to another device/run. |

## Why the tempting small fixes do not solve the observed event

Primary source is the exact shipped code, not a current upstream API assumption: [embed](../../modules/flowers_page/flowers_embed.gd), [pinned loader](../../modules/flowers_page/web/ruffle/ruffle.js), and [pinned WASM glue](../../modules/flowers_page/web/ruffle/core.ruffle.4592c196d36da0816efa.js). The files are minified, so search the following exact function/variable strings.

- The embed creates a `div` in the main document. `flowersEmbed(null)` only sets `display:none`; it does not unload an iframe or stop pending work.
- `async ensureFreshInstance()` awaits loader function `h`. That loader caches its initialization promise in module variable `m` (`let m=null`), fetches WASM, initializes it, then constructs the instance. The public `pause()` and `destroy()` act only when `this.instance` exists. They do not cancel that pending promise.
- Guarding `script.onload` against hidden state misses the traced case: script execution and `player.load()` had already occurred; WASM completion was late. Removing the connected player does not cancel the cached engine initialization either.
- Aborting the fetch without a supported reset risks retaining a rejected cached promise and breaking the next visit. Editing vendored minified internals or intercepting global WebAssembly calls is not a bounded repair. Gating response completion also cannot guarantee that initialization stops when visibility changes during compilation.
- Pausing after `load()` resolves could reduce subsequent hidden playback but happens after the observed expensive initialization. It must not be presented as a fix for that event. Destroying an initialized game also violates preserved bouquet state.

Boot has a different constraint: the previous zero-fade experiment moved roughly two seconds into the final gallery return. Skipping warmup would change first-click behavior. No new boot change is supported by this trace.

## Exact M3 evidence needed

Use the same integrated export for each pair, record its source SHA and build timestamp, and append `qa-perf=1&qa-crt=1` to its shared review URL. Do not substitute Linux CPU throttling for M3 evidence. Record macOS/browser versions, M3 variant and RAM, browser zoom, viewport, DPR, power mode, display refresh rate, and whether the actual renderer is hardware accelerated. Start with the browser/device where the owner sees the failure; if it is Safari, retain that capture before comparing Chrome.

1. **Unvisited control:** fresh load, no other tab visits; wait for `game-shown`. Walk/stop, W+D diagonal, release W, reverse D→A, release both. Then use the actual wheel/trackpad navigation that exhibits the problem. Capture 10–15 seconds, including two seconds before and after the symptom. Mark the symptom time and whether it was movement, camera, or the entire page freezing.
2. **Flowers treatment:** fresh load of the same export; visit Flowers and immediately return to gallery, then repeat. Separately test a fully loaded Flowers game and return. Keep cold/warm-cache cases labeled. Do not call the difference causal until the timings identify the blocking task.
3. In browser developer tools, save a Performance/Timelines recording with screenshots and network activity covering the symptom. Chrome: include JS samples and retain the unfiltered trace; collect HAR for a boot-specific report. Also save console errors and the data below immediately after the event, because the existing probe retains only 1,800 samples (roughly 30 seconds at 60 fps).
4. Repeat the failing sequence once with diagnostic flags off and a screen recording. Instrumentation can affect timing; compare visible behavior, not just numbers.

For Chrome, run this console snippet after the page is shown, then click back into the gallery. It only observes movement keys and exports local diagnostic data. `galleryCaptureFinish()` copies the JSON to the DevTools clipboard through the final console command below; save that clipboard as `m3-gallery.json`. It records no other typed text.

```js
(() => {
  const events = [];
  const record = e => {
    if (e instanceof KeyboardEvent && !/^(w|a|s|d|ArrowUp|ArrowDown|ArrowLeft|ArrowRight)$/i.test(e.key)) return;
    events.push({type: e.type, key: e.key, repeat: e.repeat,
      ms: performance.now(), event_ms: e.timeStamp,
      focus: document.hasFocus(), visibility: document.visibilityState});
    if (events.length > 1800) events.shift();
  };
  const types = ['keydown', 'keyup', 'focus', 'blur', 'visibilitychange'];
  const started = performance.now();
  types.forEach(t => addEventListener(t, record, true));
  window.galleryCaptureFinish = () => {
    types.forEach(t => removeEventListener(t, record, true));
    return JSON.stringify({started, ended: performance.now(),
      browser: navigator.userAgent, viewport: [innerWidth, innerHeight],
      dpr: devicePixelRatio, events, godot: window.galleryPerf,
      load: window.loadPerf, shell: window.shellCrtQa,
      resources: performance.getEntriesByType('resource').map(r => ({
        name: r.name.split('/').pop().split('?')[0],
        start: r.startTime, end: r.responseEnd, bytes: r.transferSize
      }))}, null, 2);
  };
})();
// After reproducing, in the Chrome console:
// copy(galleryCaptureFinish());
```

Interpretation: missing DOM events indicate focus/browser/input delivery before Godot; DOM present but late/missing Godot callbacks localizes receipt; correct held state but stopped position isolates simulation/navigation; large process and main-thread gaps implicate CPU tasks; stable process with delayed presentation needs renderer/GPU investigation. Post-draw timestamps are submission cadence, not measured GPU completion. The JSON alone cannot attribute every presentation stall.

## Separate Flowers lifecycle ticket, if pursued

Scope the fix to hidden pending initialization and hidden playback while preserving the exact pinned game and in-progress bouquet. Acceptance must use the actual exported app and actual Ruffle, not only a mocked loader: delay the WASM response, leave Flowers, release the response, verify gallery keeps updating without hidden Ruffle construction, revisit Flowers successfully, then arrange a bouquet and confirm hide/show preserves it. Test leave-before-script, leave-during-WASM, rapid re-entry and network failure recovery. The unchanged baseline must fail the hidden-initialization assertion. Keep the existing frozen Flowers browser playtest unchanged and passing.

A separate document/worker architecture or an upstream-supported cancellable loader may be necessary; neither is demonstrated by this investigation. Do not claim that follow-up fixes the unvisited-Flowers Mac report. No runtime workaround was added here.

## Verification of this report

All local source/evidence links resolve; the console snippet passes `node --check`; `git diff --check` passes. `scripts/check.sh` passes after the fresh worktree's headless editor import. The initial check before asset import failed with missing resources, then the rerun reported only the existing six-instance exit warning. These checks validate the repository/document package, not M3 behavior or a performance improvement.
