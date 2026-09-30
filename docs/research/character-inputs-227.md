# Coherent Muse references and the first image-to-3D pilot

Research for [Research: coherent Muse references and the first image-to-3D pilot](https://github.com/Reid-Surmeier/risd-godot/issues/227), September 30, 2026. Part of [Map: repeatable Muse character assets with Blender baking and animation](https://github.com/Reid-Surmeier/risd-godot/issues/226). Research spend: **$0**. No mesh or image generation was submitted by this investigation; generator quality on the supplied character remains untested.

## Recommendation

Prepare **one Muse front T-pose edit**, inspect identity and separated limbs, then submit **one textured Meshy 7.1 standard-resolution candidate with rigging disabled**. Use single-image initially if there are no accepted matching views. The multiview endpoint becomes preferable when front/back/profile views actually agree. This prioritizes establishing a reproducible first failure over spending on a whole turnaround before seeing any geometry. It is a proposed experiment, not an observed model ranking.

Keep Tripo P2 as one bounded comparison if Meshy's visible silhouette, separate limbs or topology fails after inspection. An inconsistent reference must be repaired before comparing models. If both outputs have the same deformation defect, investigate fitting the existing authored body/skeleton template instead of trying more providers. Baking alone will not fix silhouette or fused armpits.

## Muse preparation and current route

Use the maintained [image-generation-pipeline skill](/home/reidsurmeier/.codex/skills/image-generation-pipeline/SKILL.md) and [saved Muse procedure](/home/reidsurmeier/Image-generation-pipline/procedures/muse/README.md). `edit` preserves ordered PNG references and prompt/input hashes. The new application's saved plan uses `attempts: [{id, prompt, promptSha256, size, inputs: [{path, sha256}]}]`; its recipe names `procedure: "edit"`, the plan path and attempt ID. Paths are application-relative. `identity`, `prepare` and `image` without `--execute` are unpaid. Execution reserves first, retains a Run record and submits one output. A Tool Lock mismatch requires deliberate application upgrade; preserve earlier records. Muse does not guarantee exact requested dimensions or deterministic seeds. The README's cost example is an estimate and must not substitute for a current quote.

Use the complete screenshot plus a tight, unaltered crop as ordered identity inputs if the application preserves both; the crop helps expose the tiny face, while the screenshot records context. Remove the held tool through the requested edit, not by painting over the face or deciding unseen geometry silently. These are reference-design recommendations. The original image is not a texture atlas.

Proposed exact front prompt:

> Make one clean front modeling reference of the same character in the supplied gameplay image. Preserve the oversized rounded head, large painted eyes, small triangular orange nose, patterned pale headwear with dark blue horns, clothing colors, blue shoes, and very short chibi proportions. Full body, neutral T-pose: both arms straight horizontally at shoulder height, empty simple mitten hands, legs and shoes visibly separate. Preserve the simple painted GameCube-style appearance. Orthographic front view, neutral flat light, plain pale gray background, no cast shadow, no scenery, HUD, lettering, carried tool, realistic fingers, extra clothing detail, glossy material or perspective exaggeration. Leave clear space around both hands, horns and feet. Do not turn the headwear into exposed skin. Unseen details are a simple proposed continuation of the visible design.

Approve identity visually before turning this front into further views. For a later turnaround, pass the accepted front as the controlling reference, retain the original crop as secondary identity evidence, and ask for front/right/back/left with the same head-foot baseline, height, horn arrangement, outfit bands and T-pose. Extract each view separately and inspect matching silhouettes; do not feed a collage to a one-image endpoint. A tiny screenshot cannot establish the hidden back design.

Live unpaid OpenRouter checks returned HTTP 200 for `GET /api/v1/models?output_modalities=image` and `GET /api/v1/models/meta/muse-image/endpoints`: Muse is an image-only output model with text/image input and one Meta endpoint. The general model list omitted it; that omission did not mean the route was unavailable. The model page displays **$0.01/image**. Endpoint pricing lists prompt/completion zero and `image_output`/`image_token` at `0.00000239520958083832`; these token-unit fields must not be misread as the cost of a complete image. Model existence and documented reference support do not prove a successful new image request. [Muse model page](https://openrouter.ai/meta/muse-image), [image model catalog](https://openrouter.ai/api/v1/models?output_modalities=image), [Muse endpoints](https://openrouter.ai/api/v1/models/meta/muse-image/endpoints).

## Exact endpoint contracts

The fal **single-image** route is `meshy/v7.1/image-to-3d`: `image_url`, `model_type` (`standard`, `lowpoly`, `smart-topology`), `pose_mode`, remesh/topology/polycount, texture and optional rig/animation controls. `lowpoly` ignores the remesh controls. Smart topology accepts at most 15,000 polygons and defaults to 4,000 when its target is omitted. Standard geometry is sufficient for the initial small character; 2k/4k are supported but add no demonstrated value here. [Single-image schema](https://fal.ai/models/meshy/v7.1/image-to-3d/api).

The **multiview** route is `meshy/v7.1/multi-image-to-3d`: `image_urls` contains 1–4 views of one object; `pose_mode: "t-pose"`, `should_remesh`, `topology`, `target_polycount`, texture and rig/animation flags are supported. `model_type` is absent. Geometry accepts standard/2k, not 4k. Disabling remesh ignores the topology/target and returns triangles. Output includes model/texture files; rig and animation outputs are conditional. [Multiview schema](https://fal.ai/models/meshy/v7.1/multi-image-to-3d/api).

Meshy's upstream contract uses the first multiview image as front. It now deprecates `meshy-7`, `ultra_mode`, `hd_texture`, `is_a_t_pose`, and symmetry control; symmetry has no output effect. Its additional `image_enhancement`, `remove_lighting`, `save_pre_remeshed_model`, `texture_resolution`, and separate `texture_image_urls` controls are absent from the checked fal wrapper. Do not invent passthrough fields or treat fal's still-visible symmetry field as a guarantee. The upstream topology is quad-dominant, the polygon target may vary, and disabling remesh preserves more source detail. [Upstream multiview API](https://docs.meshy.ai/en/api/multi-image-to-3d). fal's old v7 page also explicitly points to v7.1. [Deprecated fal route](https://fal.ai/models/meshy/v7/image-to-3d/api).

**Tripo P2** is `tripo3d/p2/image-to-3d`, one `image_url`; `face_limit`, `quad`, `texture`, `pbr`, `texture_quality`, `texture_version`, `delight`, `export_uv`, geometry/texture seeds and sizing/orientation controls are available. PBR forces textures. Quad meshes support up to 25,000 faces. The checked endpoint has neither multiview nor rigging nor a T-pose field; supply the pose in the image. To disable textures, turn both `texture` and `pbr` off. [P2 schema](https://fal.ai/models/tripo3d/p2/image-to-3d/api).

Polygons, quad faces and exported triangles are different quantities. A 4,000-quad mesh can approach 8,000 triangles, and neither API face target promises animation-ready joint loops. Inspect the final GLB's triangle inventory and actual shoulder/hip deformation. Keep the generated GLB unchanged as the source; the checked fal wrapper does not expose upstream pre-remesh preservation.

## First request

Recommended single-image input, after the reference passes inspection:

```json
{
  "image_url": "<accepted-front PNG URL or data URI>",
  "model_type": "standard",
  "geometry_resolution": "standard",
  "pose_mode": "t-pose",
  "should_remesh": true,
  "topology": "quad",
  "target_polycount": 4000,
  "should_texture": true,
  "enable_pbr": false,
  "enable_rigging": false,
  "enable_animation": false,
  "enable_safety_checker": true
}
```

For accepted multiview references, replace `image_url` with `image_urls: [front, back, profile]` and omit `model_type`; keep the remaining settings. Preserve meaningful asymmetry through reference inspection rather than relying on deprecated symmetry controls. Four thousand faces is a trial starting value, not a measured runtime budget. Texture polish comes after a silhouette check.

After the mesh passes, `fal-ai/meshy/rigging/multi-animation` takes a textured humanoid GLB, measured `height_meters` and required `animation_action_ids`. Request `[0]` for one idle clip; walk/run basic clips come with rigging. IDs are 0–696, at most ten distinct, duplicates de-duplicated, outputs share one rig. [fal rig schema](https://fal.ai/models/fal-ai/meshy/rigging/multi-animation/api). Meshy says untextured models are unsuitable and uploaded GLB must face +Z for pose estimation. Large headwear and tiny limbs may defeat auto-rigging; never equate HTTP success with working weights. [Upstream rigging requirements](https://docs.meshy.ai/en/api/rigging).

## Exact live price observations and reservation bounds

Unpaid authenticated fal pricing returned HTTP 200 through the approved Bitwarden runner, injecting only `Fal-ai -NEW` into one trusted metadata request. The sanitized fields were:

| Endpoint | Catalog unit price | Billing unit |
| --- | ---: | --- |
| `meshy/v7.1/image-to-3d` | $0.80 | generations |
| `meshy/v7.1/multi-image-to-3d` | $0.80 | generations |
| `tripo3d/p2/image-to-3d` | $0.01 | credits |
| `fal-ai/meshy/rigging/multi-animation` | $0.08 | generations |

These are billing-unit rates, **not complete per-request totals**. fal documents account-specific rates and output-dependent billing. [Pricing API](https://fal.ai/docs/platform-apis/v1/models/pricing).

Direct retrieval of the public fal model pages on September 30 exposed their `pricingInfoOverride` text, omitted by the browser's extracted page text. Meshy single/multiview both display: untextured **$0.80**, textured **$1.20**, inline rigging **+$0.20**, inline animation **+$0.12**; textured + rig + animation **$1.52**. Keep the first trial at standard geometry, no inline extras; **reserve $1.20**. These are first-party displayed prices for that request configuration, not an actual billed receipt. [Single-image price](https://fal.ai/models/meshy/v7.1/image-to-3d), [multiview price](https://fal.ai/models/meshy/v7.1/multi-image-to-3d).

The standalone multi-animation page displays **$0.20/request + $0.12 per clip in `animation_action_ids`**. One idle is **$0.32**, not $0.08; three requested clips are $0.56. [Standalone rig price](https://fal.ai/models/fal-ai/meshy/rigging/multi-animation).

P2's page displays $1 untextured, $1.10 fast/standard, $1.20 detailed, $1.30 extreme; PBR uses the selected texture rate and quad adds no surcharge. The bounded comparison reserves **$1.10** with `texture: true`, `pbr: false`, `texture_quality: "standard"`, `texture_version: "v3.5-20260815"`, `quad: true`, `face_limit: 4000`, `export_uv: true`, `delight: true`; its input is the exact same accepted front. [P2 price](https://fal.ai/models/tripo3d/p2/image-to-3d).

Recommended budget arithmetic: one Muse edit $0.01 + one Meshy textured standard $1.20 + one standalone rig/idle $0.32 = **$1.53**. One further coordinated Muse turnaround $0.01 and one P2 comparison $1.10 would total **$2.64**, leaving $1.36 of the owner's **$4 aggregate cap**. This is a plan using observed listed rates; only explicit reservations, final receipts and uncertain liabilities determine the available spend. Do not automatically spend the remainder. The root agent owns all paid calls and the shared ledger. This investigator spends nothing.

## Stop and reconciliation rules

1. Stop before 3D submission if Muse changes identity, invents realistic anatomy, loses horns/outfit, leaves the tool attached or fails to separate the limbs. A paid regeneration is a new reservation, never an automatic retry.
2. Record silhouette/wireframe failures before one comparison. No bake can establish a valid skeleton or repair fused limbs. Delay rig spend until geometry passes.
3. Reserve the complete selected configuration first and hash source/prompt/reference bytes. Keep provider, endpoint, settings, request ID, output hashes and actual/unknown cost. Do not confuse API unit prices with full totals.
4. After timeout or unclear submission, retain the full possible cost; poll/reconcile the same request. Do not resubmit blindly, and do not infer refund from a failed or empty response.
5. Keep the visual prototype decision open until the owner reacts; a completed research issue answers what to test, not whether the new character is accepted. Runtime assets and frozen interfaces remain unchanged.

The broad [Muse-to-3D workflow note](2026-09-30-muse-character-3d-pipeline.md) supplies the Blender bake, rig, motion/effects and Godot gates. The next evidence is an actual front image, three-view mesh capture and deformation proof, not another model catalog comparison.

## Owner follow-up: Meshy subscription economics

Verified September 30 after the owner asked about the 50% offer: Pro is $20/month with 1,000 monthly credits and API access; new subscribers get 50% off their first month ($10). Monthly credits do not roll over. API calls use the shared credit balance. [Current plan comparison](https://help.meshy.ai/en/articles/12062933-which-meshy-plan-is-right-for-you-free-vs-pro-vs-premium-vs-ultra), [credits](https://help.meshy.ai/en/articles/9991981-how-do-meshy-credits-work).

The direct API lists textured Meshy-7 at30 credits, rigging5 and one animation3:38 credits, about26 such attempts per1,000 credits. Effective allocation is $0.38 first month/$0.76 later if the allowance is used; actual cash commitment is $10/$20 regardless of number used. A separately requested remesh adds5 credits:43 total, about23 attempts and allocated $0.43/$0.86. Extra clips are3 credits each. The docs still label the model family Meshy-7: this arithmetic is conditional on the actual7.1 checkout/task rate matching that family, and is not a submitted billing receipt. [API credit costs](https://help.meshy.ai/en/articles/16815622-how-many-credits-does-each-meshy-api-task-cost).

For one small trial fal has lower upfront cost; for repeated attempts direct subscription pricing can be lower. Meshy subscription credits cannot pay fal's requests. The approved $4 exception names fal only; no direct Meshy purchase or paid call was authorized or made. Include this provider choice before to-spec if the owner chooses ongoing volume.
