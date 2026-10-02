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

## Where things are

| What | Where |
| --- | --- |
| Room sources (edit here) | `modules/shell/prototype/collection_reconstruction/` (`SRC`) |
| Inputs for generation | `image-work/collection-room-remodel/`; your new files under `image-work/collection-room-remodel/additions/<room>/` become `res://assets/additions/<room>/` |
| Generated rooms the game loads (do not edit) | `collection_rooms/` |
| Footage | `/home/reidsurmeier/risd-godot-ingestion/collection-expansion/IMG_6378.MOV` … `IMG_6387.MOV`; survey frames two per second in `.../survey-2fps/<clip>/NNNNNN.jpg` (frame number = 2 × seconds + 1); Hall visit frames in `/home/reidsurmeier/risd-godot-ingestion/sfm-6344/images/` |
| What is missing or wrong | `docs/research/2026-10-01-museum-inventory-audit.md`; when present, `2026-10-01-museum-architecture-audit.md` and `2026-10-01-museum-artwork-size-audit.md` in the same folder of `consolidate-character-236` (read them there; they may land after you start) |
| Finish standard | `docs/research/2026-10-01-acnh-museum-polish-spec.md` (labels, plinth contact, nothing invented that the footage does not show) |
| Earlier evidence | `git show HEAD:docs/evidence/collection-reconstruction/<path>` (hidden by the sparse checkout) |

## Build and look

```bash
ROOMS_TRIAL=/home/reidsurmeier/risd-godot-ingestion/collection-expansion/rebuild-$NAME scripts/rebuild_rooms.sh --draft
```

That regenerates the room project in about 30 s and prints its path (`.../extension`) after the
architecture check. `--draft` stops before the bake. Without it the script bakes (about 4 minutes)
and installs into your worktree's `collection_rooms/`. Keep one trial directory, at most 2 GB, and
delete it when you finish.

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
   `room` is the room scene (`remodel_room.gd`): use its `solid()`, `panel()`, `moulding()`,
   `look()`, the `Painting` helpers it preloads, and read an existing builder for the idiom.
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
7. No paid calls of any kind in this round. If something cannot be represented without image
   generation, build the best catalogue-photograph version and list it.
8. Any write to `res://` in a room script needs an `if file != null:` guard.

Catalogue records: saved copies under `image-work/collection-room-remodel/` first; then the RISD
Museum collection site (`risdmuseum.org/art-design/collection/...`), which refuses plain requests but
has answered the Scrapling tools. Record every URL you take a picture or a dimension from in
`image-work/collection-room-remodel/additions/<room>/SOURCES.md`, with the credit line. Keep each
picture under 600 KB (JPEG, 1600 px on the long side).

## Finish

1. `scripts/rebuild_rooms.sh` (full, with bake) must end with `BAKE_OK` and install without error.
2. Put 6 to 12 before/after pictures, each beside its footage frame, in
   `docs/evidence/museum-238/<name>/` as JPEGs under 300 KB each, with a `NOTES.md`: what you built,
   what you measured and from which frame, what is provisional, what you could not do.
3. Commit everything on your branch in your worktree (`git add` only your scope; `git add -f` new
   `.import` files under `collection_rooms/`). Do not push, merge or rebase. Do not edit
   `modules/shell/PROVENANCE.md`, `MODULES.md`, `main_build_walk.gd`, `walk4.gd` or any check script:
   list in `NOTES.md` what those need.
4. Delete your trial directory. Leave the worktree in place.
5. Report: branch, commit, what is built versus the audit's list, what you looked at, what is left.
