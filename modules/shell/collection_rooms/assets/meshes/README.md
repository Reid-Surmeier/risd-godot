# Object meshes

**Status, 8 October 2026: do not place these.** The owner looked at the pilot pictures and rejected the route these were made by (a mesh generated from the cut-out catalogue photograph): "these did not get it right, or high quality asset at all". The next route starts from Muse multi-view renders. These files stay as trials for comparison until that route replaces them.

One folder per museum object, named by its accession number. Each holds the mesh (`.glb`), the texture Godot writes out of it on import (`.jpg`), both `.import` files, the clean-up record (`.json`) and a `PROVENANCE.md`.

- Size: scaled to the catalogue's dimensions, in metres.
- Origin: bottom centre. For a piece that stands against a wall, the origin is on the wall plane and the piece faces +Z.
- Front: glTF +Z is the side the catalogue photograph shows.
- Nothing here is placed in a room. Ticket #264's mechanism does that.

How they are made: `image-work/mesh-pilot-263/` (`cut_photo.py`, `accept_mesh.sh`). Keep the `.jpg` and both `.import` files in git: without them a fresh Godot import fails or stores the texture lossless.
