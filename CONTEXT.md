# RISD Museum collection browser

The vocabulary of this repository. Module terms first, then the domain's own. Terms shared with `Reid-Surmeier/Qwen-3-pro-Pipeline` keep that repository's definitions exactly; new terms below are marked as such.

## Language

**Module**: anything with an interface and an implementation; here, one folder under `modules/`, plus `testing/` and `review/`. _Avoid_: component, service, unit.

**Interface**: everything a caller must know to use a module — `interface.gd`, its error types, invariants, and required services. _Avoid_: API, signature.

**Seam**: where a module's interface lives; the only place other modules may reference from. _Avoid_: boundary.

**Adapter**: a concrete thing that satisfies an interface at a seam (a live service, a test double). _Avoid_: mock (too narrow).

**Frozen**: the interface file, the error types, and the acceptance tests of a module — written first, changed only through an Issue.

**Render Pass**: one image-model invocation with a fixed Edit Brief, inputs, and seed. _Avoid_: attempt, random generation.

**Asset Pass**: a Render Pass that produces one isolated reusable interface element. _Avoid_: full-screen generation.

**Preservation Invariant**: a visual or semantic relationship that must remain unchanged during a Render Pass. _Avoid_: preference, suggestion.

**Fidelity Check**: a comparison of a Render Pass or Interactive Replica against the reference and its Preservation Invariants. _Avoid_: vibe check.

**Icon** _(new)_: the approved output of one Asset Pass, at 64x64, drawn in the set's grammar — marble is the object, cobalt is the verb, gold is attention. An Icon is one artwork; its four states are a State Set. _Avoid_: sprite, image, asset.

**Anchor** _(new)_: an approved Icon used as the reference a Motion Pass is conformed against. Every Icon becomes its own Anchor once approved; nothing animates before it has one. _Avoid_: keyframe, source.

For the selected-tab face only, **Anchor** also means the exact assembled blue still accepted under owner delegation after independent visual review. This is application acceptance, recorded with `humanReviewed: false`, not tool-level human Approval. The [selected-tab amendment](docs/adr/0001-icon-foundry.md#amendment-2026-09-15-selected-tab-face-only) defines its gates.

**Assembly** _(selected-tab exception)_: source-preserving selection/cropping, integer placement and binary-mask copying of existing source and generated donor pixels. The amendment defines its face mask, provenance and exact-preservation checks; Assembly does not draw new art.

**State Set** _(new)_: the four states every interactive element carries — idle, hover, pressed, settled. Hover is added in the set's own style even where the source game has none. _Avoid_: variants, versions.

**Motion Pass** _(new)_: one video-model invocation that performs a whole State Set in sequence in a single longer take, from which the four states are cut. _Avoid_: animation, render.

For the selected-tab face only, a **Motion Pass** yields one entrance followed by a held blue Anchor instead of a whole State Set, under the amendment's explicit inferred-motion record. The Foundry's four-state definition remains unchanged.

**Retro-conformance** _(new)_: the deterministic reduction of a Motion Pass into held pixel frames — temporal subsample, dedupe, NEAREST grid-snap, palette lock without dither, held-cadence reassembly. It is the only thing permitted to change generated pixels. _Avoid_: post-processing, cleanup.

**Certification** _(new)_: the gate's verdict on a conformed Motion Pass — silhouette IoU against the Anchor, frame count, palette purity. Uncertified output is evidence, never a deliverable. _Avoid_: approval, pass.

**Sound Cue** _(new)_: the owner-approved Mr. Baby Paint sound assigned to a game event. These cues apply to every prototype unless its Issue explicitly replaces one. The canonical resources live in `prototype/mr-baby-paint-audio/sounds/`.

| Event | Sound Cue |
| --- | --- |
| Any menu or button activation without a more specific cue | `fill_stop5.wav.res` |
| Refill paint from the paintbrush | `fill_stop3.wav.res` |
| Save an image or sculpture | `screenshot7.wav.res` |
| Close a menu | `stop_fill_spacebar.wav.res` |
| Splash screen | `splash_screen.wav.res` |

## Relationships

- Every module has exactly one interface and one `MODULE.md`.
- `MODULES.md` is the map, not a store; it is hand-maintained here because the host forces GDScript.
- Modules depend on each other only through seams.
- An Icon is produced by an Asset Pass, approved, and only then becomes an Anchor.
- A Motion Pass is conformed against exactly one Anchor and yields exactly one State Set.
- The selected-tab exception instead uses two locked first/last image references and yields an entrance/held endpoint, certified against its accepted blue Anchor; it does not change the Foundry relationship above.
- Certification is a property of a conformed Motion Pass, never of raw model output.
- A specific Sound Cue overrides the default menu/button cue; one event plays one cue unless an Issue explicitly says otherwise.

## Flagged ambiguities

- "Animation" is not a term here: a moving Icon is a conformed Motion Pass. Say which.
- "Asset" is not a term here: say Icon, or say the file.

## The Collection Browser shell _(new, map #23)_

**Shell**: the page area and the tab strip along the bottom of the window beneath it (owner correction 2026-09-13; it sat on top before); the one window the game runs in. _Avoid_: app frame, container.

**Tab**: one entry in the strip; it owns exactly one Page. The six fixed Tabs at launch are Map, Sketchbook, 3D Viewer, Video Player, Collection, Playground, Collection active. The Phone is no longer a Tab: it is a window on the Playground desktop (owner correction 2026-09-14, #62). _Avoid_: screen, view.

**Page**: the surface a Tab shows in the page area; built lazily on first open, kept alive while the game runs. _Avoid_: scene, panel.

**Tenant**: the module that lives in a Page (the Pixel Atlas is the Map Tab's Tenant). A Tenant may own draggable windows inside its Page; the Page is that Tenant's desktop. _Avoid_: plugin, embed, widget.

**Page seam**: the interface every Tenant implements so the Shell can create, show, hide, resize and query it; the only way Shell and Tenant talk. _Avoid_: API, host contract.

**Switch** _(new)_: what a tab click does — the clicked Tab dips (the stub's pressed tint, 0.1 s) and the new Page cross-fades in over 0.2 s while the old one fades out; the Shell's freeze rule applies once the fade has settled. At launch the Collection Tab grows in like a stub-opened tab before its Page fades in. _Avoid_: transition, animation (see "Animation" above).
