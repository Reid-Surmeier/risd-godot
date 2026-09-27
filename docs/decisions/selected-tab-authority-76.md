# Selected-tab artwork and motion authority

Decision for [source-preserving UI Assembly and selected-tab motion](https://github.com/Reid-Surmeier/risd-godot/issues/76), a child of [find, save and study RISD artworks](https://github.com/Reid-Surmeier/risd-godot/issues/65). Recorded 2026-09-15 against application `d9d3b13551aac1da7c385b4164d034befc108156`.

**Status: decision under the owner's delegated defaults; application policy amendment still required.** This document does not itself change `AGENTS.md` or ADR 0001, approve an Anchor, or permit a paid submission. No human visual review occurred. The decision is limited to the selected-tab face in this map; the fifty-icon Foundry rules remain in force.

## Source and existing result

![Authoritative tab geometry and chrome](https://raw.githubusercontent.com/Reid-Surmeier/risd-godot/8f16172/image-work/selected-tab/references/tab-region.png)

![Existing Muse donor study; rejected as a full-frame Anchor](https://raw.githubusercontent.com/Reid-Surmeier/risd-godot/8f16172/image-work/selected-tab/blue-01.webp)

Both images were inspected again during this decision. The source is 1600×240; the donor is 3840×576 and visibly changes the framing, tab edge, label and icons. Blue is useful evidence, but the whole generated result remains rejected. Copying the whole donor or scaling it into the toolbar would not preserve the source.

| Input | SHA-256 |
| --- | --- |
| Source PNG | `52b8670039387b9d212b9423cf5ed2969c23647b5ee3b562a90fd1575e2c2f1d` |
| Muse donor WebP | `19ae8f850cc247af955b2a23c43fcbc897a7000162c5828e890380ea99f38c08` |

The [portable study and Run Record](https://github.com/Reid-Surmeier/risd-godot/blob/8f16172/image-work/selected-tab/README.md) are the evidence source, not a production import. Keep that Run Record and application identity; do not resubmit its completed Objective.

## Delegated grilling decisions

The owner explicitly approved recommended/default grilling answers in the automation instruction and [map Notes](https://github.com/Reid-Surmeier/risd-godot/issues/65). The following answers are agent recommendations adopted through that delegation, **not quotes from a human review**.

| Question | Adopted default | Reason |
| --- | --- | --- |
| Can Assembly preserve original chrome around a generated face? | Yes, through a selected-tab-only policy amendment and a locked binary face mask. | Repeated full-frame generation needlessly risks already accepted pixels. |
| Can this new motion use inference without a historical video? | Yes, through the tool's explicit two-anchor inference record and the same application amendment. | No authoritative video of the requested colour entrance is known; grow/slide reconstructions depict different behavior. |
| Who can approve this tab Anchor? | An inspecting agent under owner delegation, with an independent visual review, only after the scoped policy amendment lands. Record reviewer identity and `humanReviewed: false`. | The current icon ADR requires a person. A silent change to the meaning of approval would be false evidence. |
| What should play? | One approximately 0.4-second face-colour entrance, then steady blue. | Implements the owner's brief without continuous distraction. |
| Should another still be bought now? | No. Evaluate the existing donor after policy integration. | A compliant crop may suffice; generation does not repair policy or provenance. |

### Assembly: exact allowed operations

Assembly means placing retained source pixels and generated donor pixels in a declared layout. For this exception it may only select/crop existing pixels, place them at recorded integer coordinates, and hard-copy them through a binary mask. Nearest-neighbour grid reduction and declared-palette locking remain the existing retro-conformance operations. No new drawing, colour fill, tint, interpolation, feathering, inpainting, gradient synthesis, or reconstructed label/icon/outline is permitted by this exception.

Before Assembly, lock the source, donor, working canvas, mask and operation recipe by hash. The mask must describe only the tab-face interior; it must exclude the outline, label glyphs, icons, stripes and neighbouring tabs, including their edge pixels. Review the visible mask against the authoritative source before accepting the result. A mask is selection metadata, not permission to paint replacement art. If the donor cannot supply a clean face without carrying its shifted text or icons, reject that crop; do not widen the mask or erase those features with procedural paint.

For the assembled still and **every assembled Motion Pass frame**, compare decoded RGBA pixels to the same locked source at equal native dimensions: changed-pixel count outside the mask must be exactly zero. Record count, dimensions, hashes and a difference image. Independently validate the mask's exclusions; an all-canvas mask cannot pass. Within the mask, retain the donor crop/coordinate mapping and any retro-conformance settings so pixels can be traced to generated input. A uniform blue fill sampled from the donor is still procedurally drawn and is not allowed.

These are native artwork checks before Godot scaling/CRT. Compare runtime screenshots at matching layout separately; moving tabs deliberately changes screen positions and cannot satisfy an unchanged whole-screen assertion. Existing source raster labels/icons are placed by the application; the historical Windows Live source does not replace the six Collection Browser tab names.

### Motion authority and behavior

Use the maintained `image-pipeline animation` route. With no authoritative video, lock exactly two image references named `first-frame` and `last-frame`, both carrying the same explicit `inferred-motion/v1:` authority reason. Use the tool's validated schema, not a freeform approximation. Its record must state provenance, behavior, timing, spatial permissions, cancel/restart behavior, and `historicalFidelity: false`. The provenance points to this owner-requested new selection behavior and the resolved policy ticket, never to an invented historical video.

The current validator requires exactly the keys `provenance`, `behavior`, `timing`, `spatialPermissions`, `cancelRestart`, `historicalFidelity`; image payload destinations are `/input_references/0/image_url/url` and `/input_references/1/image_url/url`, in first/last order. Its Video Plan admits only `assembly.required: false` and `pixelOwnership: "none-authoritative"`. Keep those truthful: the raw generated video owns no source pixels. Source-preserving Assembly and its checks are application-side downstream work; this decision does not invent a supported video-Assembly procedure in the tool.

The first frame is the accepted source face; the last frame is the accepted blue Assembly. Only face colour changes: no translation, camera movement, shape change, sheen, shimmer or loop. Re-selecting the active tab does not replay. Switching away cancels immediately; selecting that tab again starts once. Reduced motion shows the certified final blue frame immediately. Existing application press feedback remains its own behavior; it cannot stand in for the new generated entrance.

The provider clip's duration is distinct from playback duration. Refresh capabilities, use the smallest supported single video, select the short entrance from its returned frames, conform those frames and hold the last certified frame. Do not invent tweened colour frames or claim a provider generated a native 0.4-second clip. If no suitable entrance exists in the returned clip, that attempt is failed evidence, not a deliverable.

### Approval, certification and cost gates

1. Land the narrowly scoped policy amendment before applying Assembly or the inferred-motion exception. Then lock and inspect the resulting still at native size and magnification beside its source, in the selected-tab geometry. Independent visual review must confirm readable original labels, obvious blue selection and untouched chrome. Only the exact reviewed hash becomes the tab Anchor; the existing donor is not approved by this decision.

   This is delegated application Anchor acceptance, not a tool-level human Approval record. Preserve the tool's pending/human-review fields; never turn a successful check or agent review into a claim that a human approved it. If an actual downstream tool gate requires human Approval, it remains an access gate unless separately authorized through that tool's reviewed workflow.
2. Before spending, obtain current tool identity/capabilities, an explicit OpenRouter model, exact planned one-run price, and an application contract covering that procedure. The prior contract allows only one Muse still at $0.01; it does not already admit animation. A deliberate contract/Tool Lock update must preserve existing identity, provenance and completed Run Records.
3. Reserve the exact planned charge against the map's $5 aggregate before dispatch. Recorded map spend is $0.01, leaving at most $4.99 before new or unresolved reservations. The tool's old `spendState: unknown` is retained alongside its $0.01 receipt; it never authorizes a retry. Reconcile live records/other claims first. If the new plan does not fit, record the concrete shortfall and do other authorized work. No automatic model/provider substitution.
4. Submit once through the durable Run Record and exact-cost acknowledgement. Continue only that persisted job after an ambiguous result; count unresolved liability as spent and never resubmit blindly. Keep provider, model, count, price, input/output hashes, inferred authority and receipt with the application. No paid call is made by this decision.
5. Before import, require independent video verification, retro-conformance, per-frame source-preservation checks and visual review against the Anchor. For a filled tab, a rectangular silhouette alone proves nothing: verify changed face content against the intended endpoint and inspect the entrance sequence. Lock certification thresholds/settings before submission in the prototype's acceptance record; do not lower them to pass a returned clip. The held endpoint must be the approved blue Anchor, with the join from the generated entrance visually accepted; copying this existing endpoint is permitted, synthesizing a corrective transition is not. Raw or uncertified frames stay evidence. A later runtime ticket owns real-input timing/cancellation/reduced-motion checks, all six tabs at 1920×1080 and 720×486, preserved white CRT/no bars, and a fresh inspected Web export.

## Policy implementation handoff

Create a native map child to amend exactly `AGENTS.md` (Generated pixels), `docs/adr/0001-icon-foundry.md` (a dated selected-tab exception), and `CONTEXT.md` (the scoped Assembly, Anchor and Motion Pass definitions/relationships). The glossary currently requires a whole four-state State Set per Motion Pass; explicitly permit this selected-tab entrance and held endpoint without changing the Foundry's four-state definition. The ticket must encode the decisions above without relaxing Foundry icon rules, real-video requirements elsewhere, provider/spend gates, or certification. No module interface, error type, acceptance test, generated image or runtime code changes belong in that policy ticket.

Make that policy ticket a native blocker of [smaller tabs and clear blue selection](https://github.com/Reid-Surmeier/risd-godot/issues/70) before resolving this decision. Resolution clears the policy question; the explicit implementation prerequisite remains. The geometry-sensitive frozen tests and runnable implementation still need their own scoped acceptance issue after the prototype. No old study branch is merged wholesale.

## Primary sources

- [Application pixel and human-Anchor rules](https://github.com/Reid-Surmeier/risd-godot/blob/d9d3b13551aac1da7c385b4164d034befc108156/docs/adr/0001-icon-foundry.md): reduction-only rule, actual video reference, filled-tile metric caveat. This decision proposes a later narrow amendment; it does not claim the current rule already permits Assembly or delegated Anchor approval.
- [Muse procedure](https://github.com/Reid-Surmeier/Image-generation-pipline/blob/21fb5c514b1e4623e36523031ec95dd5624d33eb/procedures/muse/README.md) and [Conductor animation ADR](https://github.com/Reid-Surmeier/Image-generation-pipline/blob/21fb5c514b1e4623e36523031ec95dd5624d33eb/docs/adr/0009-route-seedance-submission-through-conductor.md): edit procedure, locked reference authority and public submission route. Tool capability does not supersede application policy.
- [Video Plan validator](https://github.com/Reid-Surmeier/Image-generation-pipline/blob/21fb5c514b1e4623e36523031ec95dd5624d33eb/modules/run-contract/run-contract.ts#L379): exact inferred-authority schema and non-authoritative video ownership. Installed tool identity matches this commit, artifact SHA-256 `391f712d72495b9b48442c427d34e4f95c5dff69846bb2e0c3648df8e9ea6cde`.
- [Muse/playtest research](https://github.com/Reid-Surmeier/risd-godot/blob/c8f325a4228ceffae67afcc45e14bda5b821fd58/docs/research/muse-playtest-workflow.md) and [prepared motion behavior](https://github.com/Reid-Surmeier/risd-godot/blob/8f16172/image-work/selected-tab/motion-contract.md): no authoritative selection-colour video found; historical grow/slide files are procedural reconstructions.
- [Playtest-Godot runtime](https://github.com/Reid-Surmeier/Playtest-Godot/blob/ae0a1c746332795b0b6b90f32a3940236bc28ef1/modules/godot-runtime/MODULE.md): real input, independently checked evidence, decoded-pixel comparisons. This decision is documentation; those gameplay checks have not been run for a new tab implementation.

No production behavior or image changed in this tick. Spend: $0, zero submissions. The next tick can implement the policy ticket, then resume the existing donor/prototype without another paid still by default.
