# Object meshes

One folder per museum object, named by its accession number. Each holds the mesh (`.glb`), the texture Godot writes out of it on import (`.jpg`), both `.import` files, the clean-up record (`.json`) and a `PROVENANCE.md`.

- Size: scaled to the catalogue's dimensions, in metres.
- Origin: bottom centre. For a piece that stands against a wall, the origin is on the wall plane and the piece faces +Z.
- Front: glTF +Z is the side the catalogue photograph shows.
- Nothing here is placed in a room. Ticket #264's mechanism does that.

How they are made: `image-work/mesh-pilot-263/` (`cut_photo.py`, `accept_mesh.sh`). Keep the `.jpg` and both `.import` files in git: without them a fresh Godot import fails or stores the texture lossless.
