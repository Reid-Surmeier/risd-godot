# Webcam booth: source fuse and explosion motion

Checked 2026-09-30 using the research skill. No paid call, credential read, Git mutation, tracker mutation or tool-source edit. The supplied [portrait fixture](../../webcam-booth/assets/portrait-fixture.png) was visually inspected, followed by actual gameplay footage. Scope: one reusable fuse/explosion animation, an ephemeral portrait reset, and the same $10 aggregate allowance as the existing Muse pilot.

## Source findings

The board image shows a faceted sleeping Wario with goggles, a slapping hand, blue morning sky and spiral sun. Its bottom-left timer is an outlined Wario head attached to a horizontal pale fuse. Its visual authority and exact Figma origin are recorded in [prototype provenance](../../webcam-booth/PROVENANCE.md), which explicitly calls this fixture an image, not a mesh.

An original gameplay recording, [Rayque3's WarioWare: Smooth Moves — All Microgames at 1:15:00](https://www.youtube.com/watch?v=sx-WcbT9Lu0&t=4500s), lists that chapter as **Rude Awakening**. A 4498–4517-second excerpt was downloaded without credentials and visually inspected at two-second intervals, then six frames per second around the timer ending. It contains the exact Wario goggles, slap, polygon facets, spiral sun and lower-left fuse seen in the fixture. This is direct observed game footage; its uploader is Rayque3, **not Nintendo**. The upload metadata was independently read through [YouTube oEmbed](https://www.youtube.com/oembed?url=https%3A%2F%2Fwww.youtube.com%2Fwatch%3Fv%3Dsx-WcbT9Lu0&format=json). No third-party article is used to prove the motion.

| Inspected temporary evidence | Identity |
| --- | --- |
| `/tmp/webcam-booth-rude-awakening-research.mp4` | Original upload interval 4498–4517 seconds; H.264, 640×360, 19.049967 seconds, silent selected video stream; SHA-256 `060eeee0aaa70073c11fce18ee012c144df8db6722cc2fbb35e21c8c24e82c03` |
| `/tmp/webcam-booth-rude-awakening-contact.png` | Two-second contact sheet; inspected exact visual match |
| `/tmp/webcam-booth-fuse-end-contact.png` | Six-frame-per-second contact sheet around first timer ending; inspected |

Temporary files are discovery evidence, not a committed runtime asset. Preserve original upload URL, interval, excerpt hash, crop, time mapping and resulting asset hash if this evidence is adopted. Source claims about the observed timer come from the actual inspected gameplay recording above.

The observed fuse burns **right to left**, towards the small outlined Wario-head bomb. Its moving end is an orange/yellow spark. Near timeout, small `3`, `2`, `1` digits appear above the lower-left bomb; it ends in a **small comic starburst at the bomb**, followed by the game's scene transition. The head/slap background remains a separate scene. Neither a native ten-second viewing period nor a full portrait/frame explosion was observed. Those are authored booth behavior, even if source timer pixels are reused.

[Nintendo's official game page](https://www.nintendo.com/en-gb/Games/Wii/WarioWare-Smooth-Moves-283850.html) verifies the game and publisher. Its live HTML embeds this first-party trailer resource:

```text
https://production.smedia.lvp.llnw.net/81d5fd2a308b4f5c981628b17e9fcadd/cV/9Z5pUw_a9v-59MjtYKe-wdNPo0tITUc2_rngEh208/wii_warioware-smooth-moves-trailer-engb.mp4
```

Both that bare URL and the page's query-bearing variant failed DNS resolution from this host. It was not possible to inspect or certify it as the desired donor. [Nintendo's original Japanese game site](https://www.nintendo.co.jp/wii/rodj/index.html) and [product description](https://www.nintendo.co.jp/wii/rodj/soft_info/index.html) are live; the inspected pages expose no matching downloadable bomb animation. Nintendo describes approximately five-second microgames, which also rules out treating the requested ten-second booth interval as original game timing.

## Minimal motion route

Reuse a single overlay for all portraits; never request a new explosion for each visitor. Two viable source roles remain distinct:

1. **Literal timer adaptation:** mechanically crop/key the original timer, preserve its sparks/starburst and retime to the booth's ten-second interval. This is inexpensive and matches the observed source, but requires inspecting the keyed result and recording the adaptation. It does not supply a full-screen portrait explosion.
2. **Generated larger explosion:** use the source still/crop to author an opening anchor, then one Seedance 2.5 clip with an explicit inferred-motion contract. Record the source as appearance evidence and the full-frame burst/timing as inferred. The runtime composites that overlay over any portrait and clears the portrait at its ending.

The original gameplay clip is retrievable locally, but its YouTube watch page is not a raw MP4 provider URL. Extracted Googlevideo URLs are signed, temporary and query-bearing. The installed public Seedance adapter requires a locked, public HTTPS video URL with no credentials, query or fragment. Therefore no directly usable provider donor URL has been verified. A source excerpt can become an authoritative donor only after the exact hashed MP4 is made publicly fetchable and its intended movement/crop are inspected; a tailnet-only link does not establish provider access. Sources: [installed Seedance host](/home/reidsurmeier/Image-generation-pipline/seedance/src/seedance_icons/adapter_host.py), [reference planner](/home/reidsurmeier/Image-generation-pipline/modules/reference-planning/reference-planning.ts).

No public hosting prerequisite is needed for the two-image inferred route. It requires exactly two hashed PNG image references, `first-frame` and `last-frame`, carrying the **identical** `inferred-motion/v1:` authority string. The following is a concrete authorable contract for the delegated booth work; it asserts no historical motion fidelity:

```json
{
  "provenance": "Owner-delegated webcam-booth work, 2026-09-30. Figma node 1:5 supplies WarioWare-style appearance. Rayque3 gameplay at 1:15:00 verifies the original timer, but no publicly fetchable exact MP4 donor is available to this request. The booth's ten-second/full-portrait burst is an authored adaptation.",
  "behavior": "A lower-left Wario-outline bomb remains fixed while the horizontal fuse burns from its far-right spark toward the bomb. A comic explosion grows from that bomb into an opaque faceted burst covering the portrait area, then clears to the flat matte.",
  "timing": "One ten-second clip: 0.0-0.4 hold; 0.4-8.8 progressively consume fuse; 8.8-9.2 final spark; 9.2-9.7 explosion expands; 9.7-10.0 clears to matte. No explosion before 9.2 seconds.",
  "spatialPermissions": "Camera and matte remain fixed. Only spark, shrinking fuse and explosion move. No face, hand, character, ornate frame, text, floor, camera movement or background texture is generated. Burst may cover the entire portrait rectangle.",
  "cancelRestart": "Runtime cancellation hides the overlay and discards the current portrait. Reset returns to camera. A new completed portrait starts the same recorded clip at its first frame. Late provider results do not restart an old portrait.",
  "historicalFidelity": false
}
```

Prefix the compact serialized JSON with `inferred-motion/v1:` and use the exact same string in both references. Opening anchor must depict the intended fuse/bomb on the chosen solid matte; ending anchor must depict the final flat matte. Prepare and inspect those anchors before planning; the full frame/portrait fixture is not an acceptable overlay anchor because it contains the unwanted face and hand. Native video alpha is not promised: key a solid matte after generation and inspect spark edges, opaque burst coverage and disappearance. Sources: [ADR 0009](/home/reidsurmeier/Image-generation-pipline/docs/adr/0009-route-seedance-submission-through-conductor.md), [inferred-motion validation](/home/reidsurmeier/Image-generation-pipline/modules/run-contract/run-contract.ts), [alpha ADR](/home/reidsurmeier/Image-generation-pipline/seedance/docs/adr/0003-no-native-alpha-claim.md).

## Exact existing application contract

Use `webcam-booth/` as the application root. Its existing [Project Contract](../../webcam-booth/.qwen-pipeline/project-contract.json) already has application ID `app-91a1aa4f67da`, artifact root `artifacts/image-generation`, output root `generated`, maximum count `1`, maximum budget `10.00`, and correction runs `0`. Preserve these fields, its Tool Lock, the Muse procedure and all recorded runs. Append a new procedure and two new reference-root paths; do not initialize a second application or replace this contract. The existing Muse pilot is counted once as $0.01 in [provenance](../../webcam-booth/PROVENANCE.md).

Append this procedure record to `procedures` and add the two anchor paths to `referenceRoots`:

```json
{
  "id": "booth-fuse-explosion-v1",
  "version": "1",
  "mode": "seedance-video",
  "provider": "openrouter",
  "model": "bytedance/seedance-2.5",
  "maximumCount": 1,
  "unitCostUsd": "2.32",
  "referenceRequirements": [
    {"slot":"first-frame","kind":"image","payloadDestination":"/input_references/0/image_url/url"},
    {"slot":"last-frame","kind":"image","payloadDestination":"/input_references/1/image_url/url"}
  ]
}
```

Write an application-relative `motion-work/objective.json` with the following shape, replacing the prompt, hashes and authority string with actual inspected inputs:

```json
{
  "schemaVersion": "1",
  "id": "booth-fuse-explosion-v1-objective",
  "summary": "EXACT SAVED BEAT-BY-BEAT MOTION PROMPT",
  "procedureId": "booth-fuse-explosion-v1",
  "requestedCount": 1,
  "budgetCeilingUsd": "2.32",
  "videoPlan": {
    "assembly": {"required":false,"pixelOwnership":"none-authoritative"},
    "expectedMedia": {"width":1280,"height":720,"durationSeconds":10,"audioExpected":false}
  },
  "references": [
    {
      "slot":"first-frame","path":"motion-work/references/fuse-first.png","sha256":"ACTUAL_SHA256",
      "kind":"image","payloadDestination":"/input_references/0/image_url/url",
      "authorityReason":"inferred-motion/v1:IDENTICAL_COMPACT_JSON_RECORD",
      "declaredMedia":{"width":1280,"height":720}
    },
    {
      "slot":"last-frame","path":"motion-work/references/fuse-last.png","sha256":"ACTUAL_SHA256",
      "kind":"image","payloadDestination":"/input_references/1/image_url/url",
      "authorityReason":"inferred-motion/v1:IDENTICAL_COMPACT_JSON_RECORD",
      "declaredMedia":{"width":1280,"height":720}
    }
  ]
}
```

`declaredMedia` must match the actual reference dimensions, even when different from expected output. There is no video `prepare` command that appends this procedure automatically: authoring the additive application contract and Objective is required. Existing working examples are [visitor-motion Objective](../../image-work/gallery-character-motion/objectives/study.json) and [kid-walk Objective](../../image-work/grand-gallery-v2-motion/objectives/kid-walk.json). Video `sourceInputs` are not supported by this contract schema; hashes in `references`, the canonical request and separately retained capability/prompt evidence carry those facts. Sources: [run contract implementation](/home/reidsurmeier/Image-generation-pipline/modules/run-contract/run-contract.ts), [public command](/home/reidsurmeier/Image-generation-pipline/scripts/image-pipeline.ts).

## Exact command flow and budget

From the isolated repo worktree, after the additive contract, Objective and actual anchors exist:

```bash
/home/reidsurmeier/Image-generation-pipline/bin/image-pipeline identity
/home/reidsurmeier/Image-generation-pipline/bin/image-pipeline animation capabilities --output webcam-booth/motion-work/capabilities.json
/home/reidsurmeier/Image-generation-pipline/bin/image-pipeline animation --application webcam-booth --objective motion-work/objective.json
```

These commands are unpaid. The capabilities command requires the destination parent directory to exist. The third command should return `Planned`, exactly one output, the locked references, expected ten-second media and estimated ceiling `2.32`. Refresh capabilities before spending: the public Objective planner does not independently establish current provider prices from the declared `unitCostUsd` value. Source: [CLI](/home/reidsurmeier/Image-generation-pipline/seedance/src/seedance_icons/cli.py), [public command](/home/reidsurmeier/Image-generation-pipline/scripts/image-pipeline.ts).

Current [OpenRouter video metadata](https://openrouter.ai/api/v1/videos/models) identifies `bytedance/seedance-2.5-20260807`; 10 seconds and 1280×720 are supported. Silent/no-video-input rate is `0.0000107` USD/video token. Formula `(1280 × 720 × 10 × 24) / 1024 = 216000` tokens gives **$2.3112**, so reserve **$2.32**, rounding upwards to the tool's mandatory two decimal places. A video donor would select `0.0000064`, totaling $1.3824, but that discount does not apply to the proposed still-only request. Sources: live metadata and [cost helper](/home/reidsurmeier/Image-generation-pipline/seedance/src/seedance_icons/capabilities.py).

Only after recording the aggregate reservation and passing the unpaid plan, the secret runner may invoke:

```bash
/home/reidsurmeier/Image-generation-pipline/bin/image-pipeline animation --application webcam-booth --objective motion-work/objective.json --execute --acknowledge-cost 2.32
```

The logical `OPENROUTER_API_KEY` belongs solely in the runner-supplied process environment. Repeating that exact public command reconciles/polls the same hashed Run; never make a changed Objective to retry an ambiguous submission. Legacy `seedance-icons submit` is retired. Sources: [maintained skill](/home/reidsurmeier/.codex/skills/image-generation-pipeline/SKILL.md), [ADR 0009](/home/reidsurmeier/Image-generation-pipline/docs/adr/0009-route-seedance-submission-through-conductor.md).

**Aggregate-budget limitation:** inspected Run Record code reserves a single request and persists application ownership, but contains no cumulative application-budget summation. Keeping `maximumBudgetUsd: "10.00"` does not itself prevent many separately allowed requests exceeding $10. Preserve one application-level ledger and serialize paid requests. Current pilot plus this reservation is **$2.33** against $10, leaving **$7.67** until the motion receipt reconciles. An ambiguous motion submission holds its full $2.32 reservation and is not retried; final actual cost replaces that reservation only with evidence. The pilot's native receipt states actual $0.01 while retained diagnostic `spendState` is unknown; do not charge that same pilot twice. Sources: [reservation code](/home/reidsurmeier/Image-generation-pipline/modules/run-record/run-record.ts), [file store](/home/reidsurmeier/Image-generation-pipline/modules/run-record/file-store.ts), [pilot record](../../webcam-booth/PROVENANCE.md).

Inspect the generated video, matte-keyed exported frames and a complete in-booth ten-second loop before acceptance. Verify no early burst, no face/hand/frame baked into overlay, spark position/right-to-left burn, full portrait coverage at deletion, no remnant after reset, and stale-response isolation. Actual style, fidelity, source keying and final motion cost remain unverified until these outputs exist.
