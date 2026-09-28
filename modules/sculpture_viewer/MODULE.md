---
name: sculpture_viewer
purpose: The 3D Viewer Tab's retained catalogue and live Buddha viewer windows
interface: modules/sculpture_viewer/interface.gd
errors: modules/sculpture_viewer/errors.gd
tests: modules/sculpture_viewer/playtest/harness.gd + modules/sculpture_viewer/playtest/verify.py
depends-on: [sound_cues]
---

# sculpture_viewer

Issue #173 restores the two-window desktop from `1a1fd69c`, including independent dragging, stacking and the visible live Buddha viewport. The catalogue from #170 is uniformly fitted inside the retained setup window; its data and truthful scan availability remain unchanged. The live Buddha is the retained separate viewer, not a claim that one of the four source scans passed its asset gate. Five rows of four cards contain four source-scan thumbnails, followed by the sixteen retained image-only entries. Issue #169 adds four source-backed museum titles, record summaries, and URLs after exact image comparison: the skull group (73.148), pale bust (59.050), and two Aphrodite figures (26.117 and 06.331). The other sixteen labels remain explicitly visual descriptors; their museum title, description, and source are unknown. Every department is explicitly unknown. [CATALOGUE.md](CATALOGUE.md) pins the twenty ordered source hashes, verified fields, and explicit unknowns. The detail panel replaces the project placeholder paragraph with the selected object's description and source. The RISD wordmark is cropped from the existing approved panel.

A single enlarged preview occupies the lower left below the details, clear of all cells and text. Source scans always say “3D preview unavailable”; image-only objects show their existing animation where one exists, labelled as an animated thumbnail with no linked scan. No candidate GLB from #154 is loaded or accepted by this catalogue. Live scan orbit remains gated by #154 and #157.

The Shell creates the Tenant lazily and freezes its input, processing and hover animation when hidden. Returning preserves selection. Pointer coordinates are transformed through the Tenant's fitted canvas; the CRT host supplies the screen-to-Page transform.

## Interface and frozen scope

`create(deps)` returns the full-rect Tenant. `state(tenant)` reports the selected and hovered indices, source identifier, provisional visual name, unverified department, twenty global card rectangles, scale and processing counters. Issue #170 authorizes reconciliation of this probe and the catalogue acceptance tests. `errors.gd` is unchanged.

`embedded_viewer()` is unchanged: it builds the separate 800×680 live Buddha viewer used by Sketchbook. Its scan, orbit, zoom, transport controls, rendering and assets remain in `viewer.gd`; it is never presented as one of the selected catalogue scans.

## Inside and checks

`desktop.gd` owns fitting, lifecycle counters and the embedding factory. `catalogue.gd` owns selected layout C, image drawing, pointer hit testing and retained thumbnail motion. `PROVENANCE.md` records the source and hashes of the four accepted 2D thumbnails.

`scripts/playtest.sh sculpture_viewer` mounts the complete square application, drives all seven tabs and all twenty cards through real native input, verifies hover and freeze/return, and captures the result. The Python verifier independently checks the recorded geometry, selection identifiers, counters and changed detail/preview pixels. Earlier `hover_turn.gd` and `close_zoom.gd` are historical diagnostics for the superseded desktop and are not the current acceptance fixture.

`playtest/record_selection.gd` extends that native harness for #169 and checks the actual displayed detail Labels for all twenty selections, including unknown cards immediately following each verified record. It preserves the frozen state probe's provisional `selected_name` and `department: "unverified"`; these legacy fields are not the museum metadata model. Run with `godot --path . --script res://modules/sculpture_viewer/playtest/record_selection.gd --resolution 1080x1080 --windowed --display-driver x11 --rendering-driver opengl3 -- --out-dir=/tmp/viewer-records-169`. No frozen interface, errors, or existing acceptance fixture changed.
