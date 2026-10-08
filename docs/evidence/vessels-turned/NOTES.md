# Turned vessels: measurements and review

Started 8 October 2026, 19:22 UTC, on `feat/vessels-turned` in `wt-medieval`. Sources only; no room bake or install. No paid calls. Deadline and scope are the owner’s task beside #263; no interface, errors, frozen tests, doors or route trials are in scope.

## 1. Measurement and plan

1. **VERIFIED from records:** 32 one-view blobs, all Rockefeller. Ten vessels/bowl-and-handle objects, 22 figures or figural ornaments; see LIST.md. The figural bear jugs, candlesticks and branching sconces stay blobs. The European gallery’s 24 shortfalls are other representation types, outside this instruction.
2. **VERIFIED from source:** the accepted dish path is `dish_asset()` in prepare_remodel.py: a faceted hollow ring profile, catalogue metres, photograph-derived outline/UVs. `build_catalogue_objects()` in remodel_room.gd draws its triangles. `build_tureen()` also contains an unused 16-sided turned example. Reuse the ring-profile idiom, with measured body/lid/stand rows and separate open handles/spouts, in a private vessels additions file.
3. **Catalogue measurement:** exemplar `tureen`, 2017.74.39.18a-c, 45.7 cm high × 55.9 cm wide × 35.6 cm deep. Current blob is 32 × 42 × 26.7 cm. Correct those three dimensions at its existing origin and yaw. This has the largest bounding volume among the turned works (0.091 m³; the sauce tureen is taller at 48.3 cm but narrower in depth, 0.082 m³). No placement changes. Silhouette pixel measurements and error will be added before the exemplar commit.
4. **Draft review plan:** museum photograph left, old blob centre, new turned vessel right, front and three-quarter; also its actual display beside the accepted visitor. Inspect body/foot/lid/handle shapes, hollow openings and texture stretching. Record faults, then push the exemplar alone before extending to the other works.
5. **Census checklist:** objects census’s vessel blobs and Rockefeller 32 shortfalls are ours only for the ten in LIST.md. Room census Rockefeller findings 1–7 (ceiling, ghost shadow, lighting, wall colour, door trim, cuboid bases and labels) and European findings 1–9 are other jobs. In this draft their deficiencies must not be mistaken for vessel acceptance.

## 2. Scope and edits

Planned shared edits: one named ADDITIONS entry in remodel_room.gd; a separate preparation block in prepare_remodel.py; authored representation declarations only. rebuild_rooms.sh explicitly preserves objects.json and representation.json as authored records although their directory contains generated rooms. No generated room scenes, textures or bake files will be edited or committed.

Doors and route trials added/moved: none. Works moved: none. Sizes changed only to the catalogue dimensions, listed per work below.

## 3. Inherited integration checks

After a local editor import, the baseline has no Godot script/import errors. `scripts/check.sh` exits 1 at REPRESENTATION_CHECK (the owner explicitly authorizes these inherited differences; it does not print `checks passed`). Built/declared count: 177/177. The exact inherited failures are:

- `recamier (Rockefeller) is in the build and not declared`
- `06.057 is declared as mesh but no place_mesh() put it there`
- `83.152 is declared as mesh but no place_mesh() put it there`
- `37.201 is declared and not in the build`

The first pre-import run also lacked cached GLB and JPEG imports and reported 13 representation failures. `timeout 420 godot --headless --editor --import --path .` resolved those local cache errors; the four above remain. No generated room was changed. `python3 scripts/check_museum_records.py` passes: 177 works, 58 shortfalls. The draft architecture check remains pending on the host lock.
