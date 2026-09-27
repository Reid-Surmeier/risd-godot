# ADR 0001: Icons are generated, reduced, and certified — never drawn by code

Status: accepted
Date: 2026-08-30

## Context

The game needs fifty icons, each in four interaction states, in the idiom of five that Reid drew by hand: 64 pixels, a cobalt-marble-gold grammar, hard stair-stepped edges, one hard light from the upper left.

Drawing fifty by hand is weeks. Generating them is minutes, but no diffusion model draws a pixel-exact 64-pixel icon: it draws a picture *of* one, at whatever resolution it likes, in however many colours it likes.

## Decision

Three stages, and each may only do its own job.

1. **Generation.** Qwen draws the still; Seedance performs the states. Models make every pixel. No procedurally drawn icon art, ever.
2. **Reduction.** Deterministic code snaps to the 64 grid with NEAREST, locks the palette taken from the Anchor with no dithering, and reassembles at held cadence. This is the only code permitted to touch generated pixels, and it may only *reduce* — never invent.
3. **Certification.** A conformed run is measured against its Anchor. Uncertified output is evidence, kept as evidence. It never ships.

The still is approved by a person looking at it at magnification beside the five originals. That approved still becomes the **Anchor**, and nothing animates before its Anchor exists.

## Consequences

**The still brief stops asking for pixel art.** At 1024 pixels the generated candidates look far too smooth to be sprites — near-photographic faces, pixel steps a fraction of the originals'. That looked like failure and is not: reduction turns all four candidates into genuine 64-pixel icons in 13 colours. So the brief asks for a well-drawn icon in the right palette, light and proportion, and lets reduction make the pixels. That is a cheaper thing to ask for and a more reliable one.

**Certification has to compare against the Anchor, not only against itself.** A run whose frames are stable relative to each other can still have drifted into a different picture — and in practice the drifted states were the *steadiest*. Measured on two takes: states a person accepted scored 0.955 and 0.979 against the Anchor; states a person rejected scored 0.466 and 0.529.

**An Anchor may not sit on an opaque background.** If it does, the shape being measured is that rectangle, and every state certifies no matter what it drew. Caught on the first take, where all four states passed and two were visibly wrong.

**Cost is knowable in advance.** Video calls are priced strictly by duration and size — seventeen four-second calls all cost $0.05432 exactly, and a twelve-second call cost 3.0x that. One Asset Pass of four candidates is $0.163. A first-try icon is about $0.33 all in.

## Alternatives rejected

**Prompt for pixel art and ship the output.** Produces fake pixel art: soft edges, hundreds of colours, no grid. Cannot meet "exact to these".

**Use the model as a sketch engine and draw the final pixels by hand.** Honest and highest quality, but fifty icons is weeks of work, which is the problem this exists to solve.

**Draw the icons procedurally.** Ruled out by the owner. It would also produce a set that looks like code wrote it, which is the one thing the hand-drawn five prove matters.

## Amendment, 2026-08-30: framing and references

Two rules from the owner, both after seeing the first takes.

**The key colour locks the square; it is not the ground.** A generated icon fills its tile, and `#00FF00` marks the tile's edge — a thin border, never a field the icon floats in. The reason is behavioural rather than aesthetic: given empty key-coloured space, the video model treats it as somewhere to go. Asked for a two-pixel shift it moved roughly fifteen, in two takes under two very different briefs. An icon that fills its tile has nowhere to travel.

This costs the silhouette metric, which is the price of the rule: a filled tile has the same outline in every frame whatever is drawn inside it, so fidelity becomes per-pixel identity against the Anchor instead. The reduction step therefore takes a frame mode, and the framing decides which metric can see anything at all.

**Every Motion Pass carries a video reference** — the actual animation as an HTTPS URL, not a citation in the brief, so the model sees the cadence rather than reading about it. Each icon's motion is paired with a real game animation that behaves the same way. It is also cheaper: a video input moves the call to a different price band, $0.1361 against $0.2268 estimated for the same twelve seconds.

## Amendment, 2026-08-30: the palette is declared, not sampled

The original decision said reduction locks each icon to a palette extracted from its own Anchor. The first generated icons show that cannot work here, and the reason is in the grammar rather than in the tooling.

The set allows at most one gold element per icon. Gold is therefore always a small minority of any icon's pixels, and median-cut quantisation always discards it: a gold star of 16,850 pixels reduced to grey, and gilt frame corners of 19,518 pixels did the same. No choice of source image fixes it — the five-anchor strip contains 28,934 gold pixels and still yields no gold entry at sixteen colours, because gold is a minority there too.

So the set's ramps are written down instead: four cobalt steps, four marble, three gold, one outline, one ground, one matte. A palette sampled from an image cannot protect a colour the grammar defines as rare.

One icon is a known exception. MED-10 Colour palette is specified as the one icon carrying hues outside the grammar, and the declared palette will clip it; it needs its own palette, extended with its own chips.

## Amendment, 2026-09-15: selected-tab face only

Accepted through [the scoped policy issue](https://github.com/Reid-Surmeier/risd-godot/issues/86), implementing [the Assembly and motion decision](../decisions/selected-tab-authority-76.md) under the owner's delegated defaults in [the Collection Browser map](https://github.com/Reid-Surmeier/risd-godot/issues/65). This exception applies only to that map's selected-tab face. It preserves the fifty-icon Foundry rules, including human still approval and actual video references elsewhere. No human visual review or acceptance of the existing rejected donor study is implied.

### Generation and Assembly

Use Muse (`meta/muse-image`) via OpenRouter for the still, and Seedance through the maintained public `image-pipeline animation` OpenRouter route for motion. Consult the decision's primary tool sources and refresh installed identity/capabilities before planning; never substitute a provider silently.

Assembly may only select/crop existing pixels, place them at recorded integer coordinates, and hard-copy through a binary mask. Existing NEAREST grid reduction and declared-palette retro-conformance remain permitted. Drawing, fills, tints, blending, interpolation, feathering, reconstructed art and expanding the mask to hide donor defects are prohibited. A blue fill sampled from the donor is still drawn art.

Hash-lock the source, donor, working canvas, binary mask and operation recipe before Assembly. Independently review the mask against the source: only face-interior pixels belong in it. Exclude labels, icons, outlines, stripes, neighbouring tabs and surrounding chrome, including their edge pixels. Reject a donor crop carrying shifted text/icons; preserve crop coordinates and reduction settings so every changed pixel is traceable.

For the still and **every assembled video frame**, require identical native dimensions and exact decoded-RGBA equality to the locked source outside the reviewed mask: zero changed pixels. Record dimensions, hashes, changed-pixel counts and a difference image. Validate mask exclusions independently; an all-canvas mask cannot qualify. These checks precede application scaling/CRT; runtime layout comparisons are separate.

Assembly is downstream application work. The tool's Video Plan retains `assembly.required: false` and `pixelOwnership: "none-authoritative"`: raw model video owns no source pixels. This exception does not add a video-Assembly procedure to the tool.

### Motion authority and playback

Use exactly two hash-locked image references, `first-frame` then `last-frame`, with payload destinations `/input_references/0/image_url/url` and `/input_references/1/image_url/url`. Both carry the identical `inferred-motion/v1:` reason validated by the tool: a JSON object with exactly `provenance`, `behavior`, `timing`, `spatialPermissions`, `cancelRestart` (non-empty strings) and `historicalFidelity: false`. Cite the owner-requested new behavior and this policy; never invent historical footage or substitute procedural motion.

The first reference is the accepted source face, the last the accepted blue Assembly. Permit face-colour change only, with no translation, shape/camera movement, shimmer or loop. Play one approximately 0.4-second entrance, then hold the accepted blue Anchor. Deselecting cancels immediately; selecting an already active tab does not replay; a new selection starts once. Reduced motion shows the certified blue endpoint immediately. Existing press feedback remains separate.

Provider duration is separate from playback duration. Choose the smallest supported single clip from current capabilities, select a suitable returned entrance, then conform it. Do not claim a native 0.4-second generation or synthesize missing transition frames. A clip with no suitable entrance remains failed evidence.

### Anchor acceptance, certification and spend

1. Before an Anchor exists, compare the assembled still with its source at native size and magnification in the selected-tab geometry. Independent visual review must confirm readable original labels, clear blue selection and untouched chrome on the exact hash. Record reviewer identity, owner delegation and `humanReviewed: false`. This delegated application acceptance is distinct from tool human Approval: retain pending human fields and honor genuine tool gates.
2. Lock content-aware certification settings and thresholds in the later prototype acceptance record **before submission**. A filled tab's rectangular silhouette cannot certify its content. Measure face content against the intended endpoint and inspect the entrance sequence against the Anchor. Require independent video verification, retro-conformance, per-frame source preservation and visual acceptance before import. Hold the exact accepted blue Anchor with a visually accepted join from the generated entrance; copying that endpoint is allowed, synthesizing a corrective transition is not. Uncertified frames remain evidence; thresholds cannot be lowered to pass a returned clip.
3. Before any paid call, record current tool identity/capabilities, explicit OpenRouter model, exact one-run price and an application contract covering the procedure. Deliberately update the application contract/Tool Lock when necessary while retaining identity, provenance and completed Run Records. An image-only contract does not authorize animation.
4. Reconcile live receipts and reservations, then durably reserve the exact planned charge within this map's **$5 aggregate ceiling** before dispatch. Record provider, model, count, cost, hashes, authority and receipt. Submit once with exact-price acknowledgement. Count unknown liability as spent; resume only the persisted job after an ambiguous result, never blindly retry. Existing unknown-spend fields remain alongside receipts. If budget or a genuine tool gate prevents the call, record the concrete need and advance other authorized work.

This policy change spends nothing and accepts no asset. The later prototype owns the actual mask, locked thresholds, application contracts and generated evidence. A scoped runtime ticket must cover geometry-sensitive frozen tests, real-input selection/cancellation/reduced-motion behavior, all six tabs at 1920×1080 and 720×486, preserved white CRT/no bars and a fresh inspected Web export.
