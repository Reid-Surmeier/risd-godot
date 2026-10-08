# Room builder guide

For an agent changing one room of the Collection museum (Issue #238). Read this, then
`docs/research/2026-10-01-museum-room-pipeline-runbook.md` sections 7 and 8, then your brief.

## Your own checkout

Several builders work at once. Each has its own git worktree and branch, cut from the same commit.
Never edit, stage or run git in anyone else's checkout, including
`~/orca/workspaces/risd-godot/consolidate-character-236`.

```bash
NAME=<your name from the brief>
BASE=<base commit from the brief>
cd /home/reidsurmeier/risd-godot
git worktree add --no-checkout ~/orca/workspaces/risd-godot/wt-$NAME -b room/$NAME $BASE
cd ~/orca/workspaces/risd-godot/wt-$NAME
git sparse-checkout init --no-cone
printf '/*\n!/docs/evidence/\n!/repos/\n!/image-work/character-pilot/\n!/image-work/character-fixture/\n' > "$(git rev-parse --git-dir)/info/sparse-checkout"
git checkout room/$NAME
```

Check `df -h /` first: stop and report if under 40 GB is free or `~/DISK-LOW.txt` exists.

## The floor

Every work is one of three things in the museum, and the build shows it accordingly.

| In the museum | Shown as |
| --- | --- |
| Flat: a painting, print, drawing, textile | Its photograph on a flat face, in its own frame. |
| Relief: a carved panel, a plaque, a roundel | A mesh or modelled surface with real depth, its back cut flat. |
| Volume: a sculpture, vessel, piece of furniture, fitting | A mesh of that object, or geometry modelled or turned in the round. |

Declare each work you add or change in `modules/shell/collection_rooms/representation.json`, under the
key a click reports: its `room`, its `form` (`flat`, `relief`, `volume`) and what it is shown `as`
(`flat`, `extruded_photo`, `one_view_blob`, `box`, `profile`, `modelled`, `stand_in_mesh`, `mesh`).
`scripts/check.sh` fails when a volume is a flat card, an extruded photograph, a one-view blob, a box
or another object's mesh, and when a relief's face is a flat photograph. The works still below the
floor are the file's `shortfalls` list. It only shrinks: build a listed work as a mesh, change its
`as` to `mesh` and take it off the list. The check prints the count by room; that number is the
work left.

## Where things are

| What | Where |
| --- | --- |
| Room sources (edit here) | `modules/shell/prototype/collection_reconstruction/` (`SRC`) |
| Inputs for generation | `image-work/collection-room-remodel/`; your new files under `image-work/collection-room-remodel/additions/<room>/` become `res://assets/additions/<room>/` |
| Generated rooms the game loads (do not edit) | `modules/shell/collection_rooms/` |
| Footage | `/home/reidsurmeier/risd-godot-ingestion/collection-expansion/IMG_6378.MOV` … `IMG_6387.MOV`; survey frames two per second in `.../survey-2fps/<clip>/NNNNNN.jpg` (frame number = 2 × seconds + 1); Hall visit frames in `/home/reidsurmeier/risd-godot-ingestion/sfm-6344/images/` |
| What is missing or wrong | `docs/research/2026-10-01-museum-inventory-audit.md`; when present, `2026-10-01-museum-architecture-audit.md` and `2026-10-01-museum-artwork-size-audit.md` in the same folder of `consolidate-character-236` (read them there; they may land after you start) |
| Finish standard | `docs/research/2026-10-01-acnh-museum-polish-spec.md` (labels, plinth contact, nothing invented that the footage does not show) |
| Earlier evidence | `git show HEAD:docs/evidence/collection-reconstruction/<path>` (hidden by the sparse checkout) |

## Build and look

```bash
ROOMS_TRIAL=/home/reidsurmeier/risd-godot-ingestion/collection-expansion/rebuild-$NAME scripts/rebuild_rooms.sh --draft
```

That regenerates the room project in about 30 s and prints its path (`.../extension`) after the
architecture check. `--draft` stops before the bake. Without it the script bakes (about 8 minutes)
and installs into your worktree's `modules/shell/collection_rooms/`. One rebuild runs on the host at
a time and yours waits its turn, drafts included, so run it in the background with a long timeout
and bake once, when the draft looks right. Keep one trial directory, at most 2 GB, and delete it
when you finish.

Look at your room. Write a small capture script in your trial project (the runbook's
`remodel_review.gd` shows how cameras are placed) and run it on the GPU path:

```bash
env DISPLAY=:99 GALLIUM_DRIVER=d3d12 MESA_D3D12_DEFAULT_ADAPTER_NAME=NVIDIA LD_LIBRARY_PATH=/usr/lib/wsl/lib \
  godot --path <extension> --display-driver x11 --rendering-method gl_compatibility --script <your capture.gd>
```

Open every picture you take and put it beside the footage frame of the same wall. An edit you have
not looked at is not done. A stale bake hides an edit without any error: after the bake, look again.

## How to add things

1. New objects go in your own `SRC/<name>_additions.gd`, a script with `func build(room) -> void`.
   `room` is the room scene (`remodel_room.gd`). A relief or a volume is one line:

   ```gdscript
   room.place_mesh(DIR + "head-59131.glb", room.wall_point(ROOM, "south", 8.62, 1.50, .43), PI, Vector3(.508, .813, .508), "59.131")
   ```

   The file, the point its base centre stands on, its turn about the vertical, the catalogue
   width, height and depth in metres, the accession number. The mesh comes out at the catalogue
   height, drawn at full brightness like every other work, casting in the bake, solid to walk
   into, cut away with the camera and clickable. `medieval_additions.gd` shows it standing on a
   pedestal. Flat works use the `Painting` helpers the room preloads; architecture, plinths and
   plain cases use `solid()`, `panel()`, `moulding()` and `look()`.
2. Place from the walls, never with bare coordinates: `room.room_bounds(label)`,
   `room.wall_point(label, side, along, height, out)`, and re-parent wall-hung work to
   `room.wall_body(label, side, at)` so it leaves with the wall when the camera cuts it away.
3. Every artwork's top node carries metadata, which is what makes it clickable and captioned:
   `catalogue_accession` (the RISD number; leave it off if unknown), `catalogue_asset` (a short
   key, required when there is no accession), `catalogue_title`, `catalogue_maker`,
   `catalogue_date`, `catalogue_medium`, `catalogue_dimensions`, and `catalogue_image`
   (`res://assets/additions/<room>/<file>`: the front photograph the detail view shows).
4. Sizes come from the catalogue record. Say in your notes whether the record is framed or unframed
   and what frame allowance you added, with the footage frame that supports it.
5. Solid things a visitor cannot walk through are built with `solid(..., true)`.
6. Never invent an identification, a title or a room connection. An unidentified work may be built
   from a rectified crop of the footage, marked `catalogue_identified=false`, with a plain
   descriptive title, and listed in your notes with what would settle it.
7. Generation is part of the work. Muse stills go through OpenRouter, up to 5 USD on
   your own judgment; Flora (meshes) up to 20 USD a session; ask in the Issue before going over
   either. Write every call in the owning module's `PROVENANCE.md`: provider, model, count, cost,
   and the hash of what you kept.
8. Any write to `res://` in a room script needs an `if file != null:` guard.
9. A value you measured and a reviewer confirmed is recorded, not left provisional: set its
   `_accepted` flag true in the room code and add a record to `SRC/acceptance.json` under
   `<subject>.<flag>` with `value`, `measured_from`, `evidence` (a file in the repository),
   `reviewed_by` and `commit`. The architecture check prints the keys and fails a true flag without
   its record, and a record without its flag.

Catalogue records: saved copies under `image-work/collection-room-remodel/` first; then the RISD
Museum collection site (`risdmuseum.org/art-design/collection/...`), which refuses plain requests but
has answered the Scrapling tools. Record every URL you take a picture or a dimension from in
`image-work/collection-room-remodel/additions/<room>/SOURCES.md`, with the credit line and the
picture's pixel size. Everything under `additions/<room>/` ships: put there only what the room
loads, cut from the full-size source, with the detail picture a click opens at 2048 px on its long
side.

## Making a mesh

How a mesh of an object is made (which pictures go in, which generator, how many tries) is ticket
#263's recipe: follow its resolution. This guide starts where you hold a GLB.

1. Blender, in one command: metallic 0, normals, decimate, catalogue size, base at the origin.

   ```bash
   blender -b -P SRC/prepare_mesh.py -- in.glb image-work/collection-room-remodel/additions/<room>/<name>-<number>.glb \
     --height 0.813 [--depth 0.508] [--yaw 180] [--triangles 1500 --texture 256]
   ```

   Give `--depth` for a relief or a work that stands against a wall. Name the file without dots
   apart from `.glb`. Render the result and look at it from all sides before placing it. It must
   bring its texture: a mesh without one is lit by the lightmap alone and reads dim.
2. Place it (the line above), declare it in `representation.json`, copy the script's last line
   into `PROVENANCE.md` with what the mesh cost, rebuild.
3. After the install, in the new `.glb.import` set `meshes/generate_lods=false` and
   `meshes/create_shadow_meshes=false`, and in its texture's `.import` set `compress/mode=1`,
   `compress/lossy_quality=0.8` and `mipmaps/generate=true`; then
   `godot --headless --editor --import --path .` and `git add -f` both `.import` files.

## What a mesh may cost

The Web pack is the whole download and has about 11 MB left under its 260 MB budget
(`scripts/export-web.sh` stops over it). A placed mesh costs 87 bytes a triangle (21 as the imported
scene, 66 as its baked copy), plus its texture (256 px: 21 KB, 512 px: 64 KB, 1024 px: 197 KB),
plus its share of the lightmap (about 90 KB for a work 0.8 m tall).

| Work | Triangles | Texture | In the pack |
| --- | --- | --- | --- |
| Under 0.5 m on its longest side | 1,500 | 256 px | about 160 KB |
| 0.5 m and over | 3,000 | 512 px | about 415 KB |

At those sizes the 69 works below the floor come to about 15 MB, and the pictures they replace
give about 6 MB back. A work that needs more is the owner's decision: say in the Issue what it
costs from the prices above.

## Finish

1. `scripts/rebuild_rooms.sh` (full, with bake) must print `BAKE_OK` and end with `installed`;
   then `scripts/check.sh` must pass, which includes the floor.
2. Put 6 to 12 before/after pictures, each beside its footage frame, in
   `docs/evidence/museum-238/<name>/` as JPEGs under 300 KB each, with a `NOTES.md`: what you built,
   what you measured and from which frame, what is provisional, what you could not do.
3. Commit everything on your branch in your worktree (`git add` only your scope; `git add -f` new
   `.import` files under `modules/shell/collection_rooms/`). Do not push, merge or rebase. Do not edit
   `modules/shell/PROVENANCE.md`, `MODULES.md`, `main_build_walk.gd`, `walk4.gd` or any check script:
   list in `NOTES.md` what those need.
4. Delete your trial directory. Leave the worktree in place.
5. Report: branch, commit, what is built versus the audit's list, what you looked at, what is left.
