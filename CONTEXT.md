# RISD Museum collection browser

The small vocabulary needed to navigate this repository.

## Codebase

**Module**: a cohesive capability with an interface and implementation. Runtime modules live under `modules/`; `testing/` and `review/` are support modules.

**Interface**: everything a caller must know to use a module correctly: callable surface, dependencies, invariants, errors, and lifecycle.

**Seam**: the location of a module's interface. Runtime modules reference one another through seams.

**Adapter**: a concrete implementation supplied at a seam, such as browser storage or an in-memory test adapter.

**Depth**: how much useful behavior a module hides behind its interface. Prefer a small interface and local implementation.

**Frozen**: a runtime module's `interface.gd`, `errors.gd`, and acceptance tests. An Issue must explicitly authorize changing them.

**Composition root**: `modules/shell/demo.gd`, where the game creates shared adapters and maps fixed Tab keys to Tenant interfaces.

## Game

**Shell**: the Page area and bottom tab strip; the one Control the game runs in.

**Tab**: one fixed entry in the strip. Launch order is Map, Sketchbook, 3D Viewer, Video Player, Collection, Playground, Flowers. Collection starts active.

**Page**: the surface owned by one Tab, created on first use and retained for the game session.

**Tenant**: the runtime module displayed in a Page. A Tenant lays itself out from its own size and exposes state through its interface.

**Switch**: the tab press and Page cross-fade, followed by freezing hidden Pages.

**Room Survey**: measured positions and dimensions of the museum room, derived from reference material.

**Placement**: one surveyed object's position, orientation, and size in the room.

**Painting Asset**: one painting's approved image, frame geometry, detail image, provenance, and Placement.

## Generated visuals

**Render Pass**: one recorded image-model invocation with fixed inputs and instructions.

**Anchor**: an accepted still used as the visual reference for later work.

**Motion Pass**: one recorded video-model invocation derived from an Anchor.

**Retro-conformance**: the deterministic grid, palette, and cadence reduction applied to generated pixels.

**Certification**: the recorded result of checking conformed output against its Anchor. Uncertified output is evidence, not a runtime asset.

Module-specific behavior, sound mappings, exceptions, and provenance belong in the owning `MODULE.md`, ADR, or `PROVENANCE.md` rather than this glossary.
