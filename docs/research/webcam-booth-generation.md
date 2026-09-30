# Webcam booth: OpenRouter generation decision

Research for [Research: OpenRouter portrait and bomb-animation routes within ten dollars](https://github.com/Reid-Surmeier/risd-godot/issues/197), checked 2026-09-29. No credentials were read and no paid requests were made. The owner authorized autonomous work with a $10 aggregate OpenRouter ceiling, an ephemeral explosion/reset loop first, and expression tracking afterwards. Design authority is the [FigJam board, node 1:623](https://www.figma.com/board/T3TSj0MQ2a26sdSLDB6l7A/Untitled?node-id=1-623); nodes 1:6 and 1:7 are supplied design inputs, not provider capability evidence.

## Decision

Use the installed Muse procedure for the intended two-reference portrait and Seedance for a reusable explosion asset. Keep all paid work server-side behind the existing application Run Record and $10 reservation ledger. However, the exact Muse Image API route is currently **unverified**: its model is advertised and its general endpoint exists, but dedicated image endpoint discovery returns no endpoints. Native transparency is also **unverified**, and the installed Muse adapter cannot send an explicit transparent-background parameter. These are capability gaps to expose honestly; do not replace Muse with Qwen, OpenAI, or a direct provider call. The basic capture/display/explode/reset loop and reuse of the existing loader can proceed without paid generation. This decision follows the [maintained image-generation skill](/home/reidsurmeier/.codex/skills/image-generation-pipeline/SKILL.md) and the inspected [Muse adapter](/home/reidsurmeier/Image-generation-pipline/qwen_ui_pipeline/muse_adapter.py).

## Installed tool and exact routes

`/home/reidsurmeier/Image-generation-pipline/bin/image-pipeline identity` returned:

```json
{
  "release": "v0.3.0",
  "commit": "3dfb74d44f492adadae916cda942b0d40e8bf386",
  "artifactSha256": "ba0bdabf5c009f2d48362779b131a6b7c65fa16660576946cad18fac72c0d66c",
  "procedureVersion": "1",
  "runSchemaVersion": "3",
  "adapterProtocolVersion": "1"
}
```

The installed `.tool-current` Muse adapter, Seedance adapter host, and capability helper were byte-identical to their corresponding source files when inspected. Source/tool SHA-256 pairs respectively were `58c4fbd5f5950bd36da624e2c8a38404f817f1b601bc9399b1b40951e3a2bc30`, `f0593678538c9b821810112ac8cb8bd778ce56eddf33d5e39537b5180d911f19`, and `7fb71bf6f0b4b9ac634271745069d9308cef4b7013729bd1f1182a198acb2b94`. The launcher uses that inventoried distribution, not arbitrary current source. Sources: [launcher](/home/reidsurmeier/Image-generation-pipline/bin/image-pipeline), [Muse adapter](/home/reidsurmeier/Image-generation-pipline/qwen_ui_pipeline/muse_adapter.py), [Seedance host](/home/reidsurmeier/Image-generation-pipline/seedance/src/seedance_icons/adapter_host.py), [capability helper](/home/reidsurmeier/Image-generation-pipline/seedance/src/seedance_icons/capabilities.py).

| Route | Live identity observed | Verified capability or limitation |
| --- | --- | --- |
| Muse portrait/still | alias `meta/muse-image`; canonical `meta/muse-image-1.0-eval-20260824` | Catalogue and current model page advertise image generation/editing and multi-image composition; dedicated Image API endpoint metadata is empty. |
| Seedance study | alias `bytedance/seedance-2.0-mini`; canonical `bytedance/seedance-2.0-mini-20260811` | 4–15 seconds; 480p/720p; 10 seconds and `1280x720` explicitly listed. |
| Seedance final | alias `bytedance/seedance-2.5`; canonical `bytedance/seedance-2.5-20260807` | 4–30 seconds; 480p/720p; 10 seconds and `1280x720` explicitly listed. |

The identities and duration/size lists come directly from the unauthenticated [general image catalogue](https://openrouter.ai/api/v1/models?output_modalities=image) and [video catalogue](https://openrouter.ai/api/v1/videos/models). Do not infer Seedance 2.5 1080p/4K support from generic price tables; the live supported-resolution list excludes them.

The [Muse model page](https://openrouter.ai/meta/muse-image-1.0-eval-20260824) currently lists $0.01 per image and supports multi-image style/subject composition. The [general Muse endpoint record](https://openrouter.ai/api/v1/models/meta/muse-image-1.0-eval-20260824/endpoints) returned a Meta endpoint with status `0` and recent uptime data. It exposes image token/output pricing `0.00000239520958083832`, rather than a dedicated output-image price line. The [dedicated Muse discovery endpoint](https://openrouter.ai/api/v1/images/models/meta/muse-image/endpoints) returned exactly:

```json
{"id":"meta/muse-image","endpoints":[]}
```

The canonical-name variant of that dedicated URL returned the same empty result. The [dedicated image catalogue](https://openrouter.ai/api/v1/images/models) nevertheless lists Muse with text/image inputs, image output, and `supported_parameters: {}`. This inconsistency proves missing Image API metadata; it does **not** prove the model is unavailable globally or that an authenticated generation would fail. No such paid test was attempted.

## Two-image portrait and transparent artwork

The installed `edit` recipe preserves an ordered `inputs` list with per-file hashes. Use image one as the captured face, neck, and shoulders; image two as the board's Wario-like low-poly style reference. The exact prompt should explicitly assign those roles and preserve the person's identity and framing. Each request produces one output (`n=1`); two references do not mean two outputs. The [saved Muse recipe adapter](/home/reidsurmeier/Image-generation-pipline/qwen_ui_pipeline/muse_recipe.py) and [provider adapter](/home/reidsurmeier/Image-generation-pipline/qwen_ui_pipeline/muse_adapter.py) preserve order and send each image to `/input_references/<index>/image_url/url` as a hash-checked data URL. The saved edit format expects PNG references; the provider adapter accepts decoded PNG/JPEG/WebP.

The [OpenRouter Image API documentation](https://openrouter.ai/docs/guides/overview/multimodal/image-generation) says reference counts and supported fields vary by endpoint. The dedicated Muse record supplies no current limit or accepted-parameter list, so exactly two references on the installed `/images` route remain unverified despite the model's advertised multi-image capability. Establish that exact route before calling it a working portrait generator.

For glove/frame artwork, retain an actual transparent source if supplied by Figma. If newly generated, preserve the native image bytes and inspect decoded alpha; asking for transparency in prose is not evidence. The Image API documents `background: "transparent"` with PNG/WebP, but that generic option does not establish Muse support. The installed adapter accepts **only** `size` in its parameters and would reject an added `background` field. A flat-matte donor followed by measured background removal is a possible application-owned preparation step, not a claim of native Muse alpha. Neither new generation nor such cleanup was performed here. Sources: [Image API](https://openrouter.ai/docs/guides/overview/multimodal/image-generation), [closed Muse adapter](/home/reidsurmeier/Image-generation-pipline/qwen_ui_pipeline/muse_adapter.py), [saved procedure](/home/reidsurmeier/Image-generation-pipline/procedures/muse/README.md).

## Fuse/explosion donor video

Make one reusable clip for all portraits, rather than paying for each portrait to explode. A genuine donor clip can carry the fuse timing and explosion sequence; a locked still carries style. The installed public Seedance host forwards a video reference as its recorded public HTTPS `providerUrl`, and optional stills as data URLs in `input_references`. In this mode it does not also send `frame_images`; reference guidance does not promise an exact first frame. Its URL must have no credentials, query, or fragment. A tailnet-only share is not sufficient evidence that OpenRouter can fetch it. Sources: [public adapter host](/home/reidsurmeier/Image-generation-pipline/seedance/src/seedance_icons/adapter_host.py), [reference planner](/home/reidsurmeier/Image-generation-pipline/modules/reference-planning/reference-planning.ts).

No matching bomb/fuse/explosion donor was identified in the installed reference collection. Existing registered clips depict coin rotation, party-icon pulsing, item-get bouncing, status flashing, and textbox-arrow bobbing; do not present those as an authentic explosion reference. Sources: [reference inventory](/home/reidsurmeier/Image-generation-pipline/seedance/docs/evidence/board-icons-test/references/README.md), [reference provenance](/home/reidsurmeier/Image-generation-pipline/seedance/docs/evidence/board-icons-test/references/provenance.json).

If no authoritative video exists, the public route permits exactly two locked stills called `first-frame` and `last-frame` only with the same explicit `inferred-motion/v1:` record declaring provenance, behavior, timing, spatial permissions, cancellation/restart behavior, and `historicalFidelity: false`. Do not invent a waiver or treat general autonomous-work authorization as an authored motion contract. The owner can delegate writing an honest inference contract, but historical fidelity must still remain false. Sources: [ADR 0009](/home/reidsurmeier/Image-generation-pipline/docs/adr/0009-route-seedance-submission-through-conductor.md), [Seedance README](/home/reidsurmeier/Image-generation-pipline/seedance/README.md).

Compatibility planning additionally checks a resolving motion reference, at least eight words of motion/era basis, a compiled prompt of at least 350 words, and local first/last anchors. Default retro-sprite grammar requires no more than 32 non-matte colors and exact integer nearest-neighbor blocks; explicit smooth grammar skips that pixel-only check. Multi-state movement must enumerate its poses. These retained gates are separate from the public Run Record path. `seedance-icons submit` is retired and refuses; use `image-pipeline animation` through Conductor. Sources: [strategy implementation](/home/reidsurmeier/Image-generation-pipline/seedance/src/seedance_icons/strategy.py), [run contract](/home/reidsurmeier/Image-generation-pipline/seedance/docs/run-contract.md).

Native alpha video is not promised. Use a solid matte, key and inspect the edges, and keep the original transparent artwork as authority. A requested ten-second output also does not prove exactly when the explosion occurs: inspect frame timing before accepting the asset. Sources: [Seedance alpha ADR](/home/reidsurmeier/Image-generation-pipline/seedance/docs/adr/0003-no-native-alpha-claim.md), [verification guide](/home/reidsurmeier/Image-generation-pipline/seedance/docs/verification.md).

## Current cost and spending gates

Live video rates from the [video models endpoint](https://openrouter.ai/api/v1/videos/models) are Mini `0.0000035` USD/video token, or `0.0000021` with video input; 2.5 `0.0000107`, or `0.0000064` with video input. Both list the same rate with or without generated audio. The installed helper computes `(width × height × seconds × 24) / 1024` tokens and selects the video-input SKU only when a video reference is submitted. These are estimates, not an invoice. Source: [cost helper](/home/reidsurmeier/Image-generation-pipline/seedance/src/seedance_icons/capabilities.py).

| One ten-second output | Mini, video donor | Mini, no video donor | 2.5, video donor | 2.5, no video donor |
| --- | ---: | ---: | ---: | ---: |
| `854x480` | $0.2017575 | $0.3362625 | $0.61488 | $1.0280025 |
| `1280x720` | $0.4536 | $0.7560 | $1.3824 | $2.3112 |

At 720p, one donor-guided Mini study plus one donor-guided 2.5 final totals $1.8360. One advertised-price Muse portrait trial and one Muse artwork trial add $0.02, for $1.8560 planned total. Without a donor video, the equivalent estimate is $3.0872. This is a conditional budget, not authorization to send a request while its route/reference checks remain unresolved. For fractional estimates reserve upward rather than rounding below the calculated amount. The project's $10 ceiling covers **all** runs and unknown/possibly-spent reservations, not each command separately. Sources: live catalogue above, [Muse price page](https://openrouter.ai/meta/muse-image-1.0-eval-20260824), [application command](/home/reidsurmeier/Image-generation-pipline/scripts/image-pipeline.ts).

`identity`, `prepare`, and plan commands are unpaid. A Project Contract, matching Tool Lock, hash-locked Objective, reference evidence, and one durable Submission Permit precede execution. Animation also requires the exact `--acknowledge-cost` amount emitted by its plan. Each public animation command produces one video. Repeating a recorded run reconciles its persisted provider identity; an ambiguous response remains possibly spent and must not trigger a new request. Use the access-bitwarden-secrets runner to provide the logical `OPENROUTER_API_KEY` to one server command. Sources: [maintained skill](/home/reidsurmeier/.codex/skills/image-generation-pipeline/SKILL.md), [application command](/home/reidsurmeier/Image-generation-pipline/scripts/image-pipeline.ts), [Conductor contract](/home/reidsurmeier/Image-generation-pipline/modules/conductor/MODULE.md).

## Minimal server route and ephemeral lifecycle

Recommendation: one same-origin server endpoint accepts a bounded, decoded camera PNG plus a fixed server-owned style reference. It chooses the locked recipe, invokes the maintained tool, and returns only sanitized progress and the generated image. Keep the credential solely in the Bitwarden-provided process environment. Do not accept browser-selected models, paths, arbitrary provider URLs, prompts, or budgets. One active request and an aggregate durable reservation ledger are enough for this booth; no new queue service is needed. This is an implementation recommendation derived from the installed closed adapter and Run Record contract, not an existing implemented endpoint.

The browser clears the captured/generated image on explosion completion and returns to camera; late responses must not revive an old portrait after reset. Private per-run media and receipts stay outside static/public directories and Git; retain hashes and cost/provenance evidence. Decide deliberate private-media retention separately from runtime disappearance, because replay needs locked inputs and provider receipts can contain generated pixels. Never describe the loop as provider-level deletion: OpenRouter's asynchronous video route explicitly requires temporary retention and is ineligible for ZDR. Source: [OpenRouter video guide](https://openrouter.ai/docs/guides/overview/multimodal/video-generation). Live expression tracking stays out of the first loop as instructed by the owner.

## Existing RISD loader sources to reuse

These are procedural source assets, not a pre-rendered movie or image sequence. Copy/adapt their source into the isolated application and record source commit/hash; do not import RISD modules across their frozen seams. Sources: [Shell module](../../modules/shell/MODULE.md), [HTML loader](../../web/loading_shell.html), [video loader shader](../../modules/video_player/loading.gdshader).

| Existing path | What it contains | SHA-256 at inspected RISD commit `55e7c3b7f048a5a7a27b71fc962c040e7aa5893e` |
| --- | --- | --- |
| `web/loading_shell.html` | Browser GLSL `loading-frag`, four colored soft rings, progress bar, worker and tape treatment | `4ab1f1181036e2fa98bb47b17a8d3bfca704faea1de43fefc872d8d2bacdb860` |
| `modules/video_player/loading.gdshader` | Smallest Godot copy: standalone rings/bar shader with `progress` uniform | `872e26851dbad2f27776b001732cd3be4613818791aa7821e09efb18ed15858f` |
| `modules/shell/boot_loader.gd` | Desktop procedural loader and exit animation; includes game-specific boot logic | `eebb97600cbfac0a852590772e342c5d991fba47cbd58d2423c6bc6decb62f15` |
| `modules/shell/tape_screen.gdshader` | Loader's separate tape treatment | `4d535efde03ab3e9cf1f1f229ae979d924111db398b8c295e7af4f5825fab1fa` |

## Unresolved facts and next concrete check

The exact Muse `/images` endpoint's two-reference acceptance, size interpretation, native alpha and final charge remain unverified. Seedance generation quality, fuse/explosion timing and public donor accessibility also remain unverified until a real plan/output is inspected. The next unpaid check is resolving Muse's missing dedicated endpoint metadata and obtaining a genuine explosion donor or an explicitly recorded inferred-motion contract. Preserve the model selection and proceed with the unpaid booth loop while these provider capabilities are unresolved.

## Follow-up pilot, 2026-09-30

The authenticated dedicated metadata read still returned zero endpoints, but one explicitly funded maintained-tool submission succeeded. Run `run-c7bee15e9bbcf76387025838` records exactly two ordered hashed references and one OpenRouter Muse image. Native output is a 1600×1600 WebP despite requested 1024×1024. The receipt records actual cost $0.01 while tool spendState remains unknown/never-resubmit; count that same liability once and preserve the receipt. Independent gpt-6.1-sol/high review accepts the image as the supplied-photo prototype sample only. This verifies that route's two-image submission, not native alpha, live-visitor generation or expression-driven geometry. [Pilot provenance](../../webcam-booth/PROVENANCE.md).
