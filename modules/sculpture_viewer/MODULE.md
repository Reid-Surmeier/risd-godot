---
name: sculpture_viewer
purpose: The 3D Viewer Tab's retained sidebar, live scans and enlarged hover preview
interface: modules/sculpture_viewer/interface.gd
errors: modules/sculpture_viewer/errors.gd
tests: modules/sculpture_viewer/playtest/harness.gd + modules/sculpture_viewer/playtest/verify.py
depends-on: [sound_cues]
---

# sculpture_viewer

Issue #173 restores the two-window desktop from `1a1fd69c`, including independent dragging, stacking and the live player. The owner's #157 correction (2026-09-28) removes the nested square catalogue page: the original setup header and chat remain, with five rows of four objects in the sidebar and selected-object fields below. Four existing Proton scans occupy the first row; sixteen image-only entries follow. Clicking a scan loads its unchanged GLB and embedded material into the main player. Clicking an image-only entry clears the model and explicitly reports no linked scan. Sketchbook retains its original Buddha default.

A single enlarged preview appears below the player, clear of the sidebar. Scan hover uses the same renderer with a separate camera and preserves the mesh's proportions; image-only entries use their existing animation where available. The owner accepted the current scans' defects for present use; no repair, generation, or new rights claim is implied.

Issue #169's verified titles, descriptions and source URLs remain for the skull group (73.148), pale bust (59.050), and two Aphrodite figures (26.117 and 06.331). Other identities and all departments remain explicitly unknown. [CATALOGUE.md](CATALOGUE.md) records the ordered sources and known metadata.

The Shell creates the Tenant lazily and freezes its input, processing and hover animation when hidden. Returning preserves selection. Pointer coordinates are transformed through the Tenant's fitted canvas; the CRT host supplies the screen-to-Page transform.

## Interface and frozen scope

`create(deps)` returns the full-rect Tenant. `state(tenant)` reports the selected and hovered indices, source identifier, provisional visual name, unverified department, twenty global card rectangles, scale and processing counters. Issue #157 records the owner-authorized probe and acceptance changes: four live scans, image-only unavailable states, and the retained sidebar layout. `errors.gd` is unchanged.

`embedded_viewer()` is unchanged: it builds the separate 800×680 live Buddha viewer used by Sketchbook. Its scan, orbit, zoom, transport controls, rendering and assets remain in `viewer.gd`; it is never presented as one of the selected catalogue scans.

## Inside and checks

`desktop.gd` owns fitting, lifecycle counters and the embedding factory. `catalogue.gd` owns the retained sidebar layout, image drawing, pointer hit testing and retained thumbnail motion. `PROVENANCE.md` records source and hashes for thumbnails and four runtime GLBs.

`scripts/playtest.sh sculpture_viewer` mounts the complete square application, drives all seven tabs and all twenty cards through real native input, verifies hover and freeze/return, and captures the result. The Python verifier independently checks the recorded geometry, selection identifiers, counters and changed detail/preview pixels. Earlier `hover_turn.gd` and `close_zoom.gd` are historical diagnostics for the superseded desktop and are not the current acceptance fixture.

`playtest/record_selection.gd` extends that native harness for #169 and checks the actual displayed detail Labels for all twenty selections, including unknown cards immediately following each verified record. It preserves the frozen state probe's provisional `selected_name` and `department: "unverified"`; these legacy fields are not the museum metadata model. Run with `godot --path . --script res://modules/sculpture_viewer/playtest/record_selection.gd --resolution 1080x1080 --windowed --display-driver x11 --rendering-driver opengl3 -- --out-dir=/tmp/viewer-records-169`. The #157 correction updates scan-availability assertions; errors.gd remains unchanged.

## Movable, proportional windows (#192)

Player, selection panel, Global Chatroom and friends panel each drag and raise independently. Bottom-right grips resize the complete window through a single uniform scale. The chat/friends artwork is cropped from the existing setup raster with AtlasTexture; these retain their existing display-only content. Scan cards consume selection clicks; other selection-panel clicks pass to its drag handler. Adjusted placements survive Page resizing and tab switches, clamped to the available desktop. The transient hover preview still follows the hovered card. `playtest/window_resize_check.gd` checks all four windows with real input, including selection/orbit after scaling and focus-loss cancellation.
