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

**State Set** _(new)_: the four states every interactive element carries — idle, hover, pressed, settled. Hover is added in the set's own style even where the source game has none. _Avoid_: variants, versions.

**Motion Pass** _(new)_: one video-model invocation that performs a whole State Set in sequence in a single longer take, from which the four states are cut. _Avoid_: animation, render.

**Retro-conformance** _(new)_: the deterministic reduction of a Motion Pass into held pixel frames — temporal subsample, dedupe, NEAREST grid-snap, palette lock without dither, held-cadence reassembly. It is the only thing permitted to change generated pixels. _Avoid_: post-processing, cleanup.

**Certification** _(new)_: the gate's verdict on a conformed Motion Pass — silhouette IoU against the Anchor, frame count, palette purity. Uncertified output is evidence, never a deliverable. _Avoid_: approval, pass.

## Relationships

- Every module has exactly one interface and one `MODULE.md`.
- `MODULES.md` is the map, not a store; it is hand-maintained here because the host forces GDScript.
- Modules depend on each other only through seams.
- An Icon is produced by an Asset Pass, approved, and only then becomes an Anchor.
- A Motion Pass is conformed against exactly one Anchor and yields exactly one State Set.
- Certification is a property of a conformed Motion Pass, never of raw model output.

## Flagged ambiguities

- "Animation" is not a term here: a moving Icon is a conformed Motion Pass. Say which.
- "Asset" is not a term here: say Icon, or say the file.

## The Collection Browser shell _(new, map #23)_

**Shell**: the tab strip and the page area beneath it; the one window the game runs in. _Avoid_: app frame, container.

**Tab**: one entry in the strip; it owns exactly one Page. The five fixed Tabs at launch are Map, Sketchbook, 3D Viewer, Video Player, Collection. _Avoid_: screen, view.

**Page**: the surface a Tab shows in the page area; built lazily on first open, kept alive while the game runs. _Avoid_: scene, panel.

**Tenant**: the module that lives in a Page (the Pixel Atlas is the Map Tab's Tenant). A Tenant may own draggable windows inside its Page; the Page is that Tenant's desktop. _Avoid_: plugin, embed, widget.

**Page seam**: the interface every Tenant implements so the Shell can create, show, hide, resize and query it; the only way Shell and Tenant talk. _Avoid_: API, host contract.
