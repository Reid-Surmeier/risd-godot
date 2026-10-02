# Museum room pipeline runbook

How the connected-museum rooms of the Collection page are generated, baked, attached to the Main Hall and checked, so that a room can be changed and rebuilt. Written 2026-10-01 against commit `32d3ba8c` on `Reid-Surmeier/consolidate-character-236`, Godot 4.7.2, on the WSL2 host with the RTX 4070 SUPER.

Every command below was run on that date unless it is marked **not run**. The run regenerated the room project from the repository sources, baked it, relocated it, and compared the result with the tracked `modules/shell/collection_rooms/`. The proof and the timings are in [section 10](#10-proof-and-timings).

## What is verified, inferred and unknown

| | |
| --- | --- |
| Verified by running | Steps 1 to 5 end to end; the three worked examples including their re-bakes; every trap marked "seen". |
| Inferred from reading | Anything marked "inferred": mostly which checks hold positions that a layout change would break, and the Web export notes taken from the CHECKPOINT files. |
| Not known | Whether the Web export still works after a rebuild (not run here). Whether the bake works with `--headless` (not tried). How long the full 105-shot atlas takes on this host (only two rooms were timed). |

## The pipeline at a glance

```text
image-work/collection-room-remodel/        modules/shell/prototype/collection_reconstruction/
  Muse outputs, catalogue photos, JSON       prepare_remodel.py, remodel_room.gd, *_assets.gd, ...
            \                                   /
   prepare_main_build_reference.py  ->  Hall snapshot (362 files of gallery_walk4 at HEAD)
   prepare_main_build_extension.py  ->  room project: a standalone Godot project
            |   import, architecture check, walking self-check, review captures
            |   remodel_bake.gd + editor bake plugin -> addition_baked/room.{tscn,lmbake,exr}
   relocate (res:// paths -> res://modules/shell/collection_rooms/, lightmap to text)
            v
   modules/shell/collection_rooms/   <- loaded by main_build_walk.gd, which extends the Hall's walk4.gd
```

Two metre frames are used. **Room-scene metres** are what `geometry.json` and `remodel_room.gd` use; the Hall occupies x 0.55..10.55, z 1.8..28.1. **Hall-local metres** are what `walk4.gd`, `main_build_walk.gd` and the repo checks use: room-scene plus `(-5.55, 0, -28.1)` (`ATTACH` in `main_build_walk.gd`).

## 1. Before you start

```bash
CK=/home/reidsurmeier/orca/workspaces/risd-godot/consolidate-character-236   # your checkout
SRC=$CK/modules/shell/prototype/collection_reconstruction
ING=/home/reidsurmeier/risd-godot-ingestion/collection-expansion
T=$ING/pipeline-trial-20261001            # new trial directory; delete it when you finish
EXT=$T/extension                          # the room project
TOOLS=$CK/build/pipeline-trial/tools      # scratch; build/ is git-ignored and Godot-ignored
SW="env DISPLAY=:99 LIBGL_ALWAYS_SOFTWARE=1 GALLIUM_DRIVER=llvmpipe"                # software GL
RTX="env DISPLAY=:99 GALLIUM_DRIVER=d3d12 MESA_D3D12_DEFAULT_ADAPTER_NAME=NVIDIA LD_LIBRARY_PATH=/usr/lib/wsl/lib"   # GL on the RTX
LVP="$SW VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/lvp_icd.json"                     # software Vulkan, for the bake

df -h /                                   # one trial needs up to 1.7 GB if you keep everything
DISPLAY=:99 xdpyinfo | head -1            # the virtual display must answer
git -C $CK diff HEAD --stat -- modules/shell/prototype/gallery_walk4 modules/shell/assets/collection_frame/page.png   # must print nothing
ls -l $ING/room-route-walk-v5/geometry.json                                        # the one input outside the repo
/usr/bin/python3 -c "import cv2, numpy, PIL"                                       # prepare_remodel.py needs these
mkdir -p $TOOLS $T
```

Three scripts of this pipeline are tracked but hidden in this checkout, because its sparse checkout leaves out `docs/evidence/collection-reconstruction/`. Read them from git:

```bash
E=docs/evidence/collection-reconstruction
git -C $CK show HEAD:$E/opus-main-build-adapter-20261001/relocate_lightmap.gd > $TOOLS/relocate_lightmap.gd
git -C $CK show HEAD:$E/opus-main-build-adapter-20261001/make_local_fullapp.py > $TOOLS/make_local_fullapp.py
git -C $CK show HEAD:$E/main-build-attachment-review-20261001/collection-v49c-bake.py > $TOOLS/collection-v49c-bake.py
```

`relocate_lightmap.gd` is needed in step 4. The other two are the previous agent's originals, kept for reference: the bake commands in step 3 are the ones `collection-v49c-bake.py` runs, and `make_local_fullapp.py` no longer runs on this tree (see step 4).

## 2. Step 1: regenerate the room project

```bash
/usr/bin/python3 $SRC/prepare_main_build_reference.py $CK $T/reference     # 1.4 s
/usr/bin/python3 $SRC/prepare_main_build_extension.py $T/reference $EXT    # 15.9 s
godot --headless --editor --import --path $EXT                             # 12.2 s
```

| Script | Reads | Writes |
| --- | --- | --- |
| `prepare_main_build_reference.py MAIN OUT` | `git archive HEAD` of `modules/shell/prototype/gallery_walk4` and `modules/shell/assets/collection_frame/page.png` in MAIN. Refuses if those paths have uncommitted tracked changes. | The Hall snapshot: 362 files, 92 MB, plus `main-build-source.json` with the commit and every file's hash. |
| `prepare_main_build_extension.py REFERENCE OUT` | The snapshot; `git show` of the same commit for `.import` files and `testing/harness_base.gd`. Runs `prepare_remodel.py OUT` itself. | The room project: 611 files, 247 MB (447 MB after import). |
| `prepare_remodel.py OUT` (run by the line above) | `image-work/collection-room-remodel/` (Muse outputs under `trial/`, catalogue photographs, the JSON fits and inventories), `image-work/collection-expansion-frame/`, the scripts in `$SRC`, the Hall's `walk4.gd`, frames, canvases and textures, and `$ING/room-route-walk-v5/geometry.json`. | `assets/` (cut-out textures, meshes as JSON, catalogue photographs), `presentation/`, `geometry.json`, the room scripts copied unchanged, `bake/plugin.gd`, `project.godot`, `manifest.json` with the hash of every input (622 once the extension step has added the Hall files). |

The extension step then makes three kinds of small text change to the copied scripts. They are the difference between the files in `$SRC` and the files in the room project:

1. `remodel_room.tscn` runs `retained_hall_room.gd` instead of `remodel_room.gd`. That subclass loads the Hall's own saved bake (139 meshes) as `ConnectedHall` instead of rebuilding the Hall.
2. `remodel_room.gd` and `remodel_bake.gd` skip every mesh marked `retained_main_hall`, so the room bake never touches the Hall.
3. The bake paths in `remodel_room.gd`, `remodel_bake.gd` and `bake/plugin.gd` change from the Hall's `baked/` folder to `res://addition_baked/`.

Nothing here costs money: `prepare_remodel.py` only cuts and re-lays images that are already in the repo. It is deterministic. Of the 553 files compared with the previous agent's last project (`main-build-extension-v49x`), 546 were byte-identical. The other seven are the two manifests, `project.godot`, the three Hall files that changed since, and `remodel_room.gd` with its two write guards.

## 3. Step 2: self-check and review captures

```bash
godot --headless --path $EXT --script $SRC/architecture_check.gd           # 3.6 s
mkdir -p $EXT/evidence/selfcheck
$SW godot --path $EXT --display-driver x11 --rendering-method gl_compatibility \
    -- --selfcheck --out=$EXT/evidence/selfcheck                            # 513 s, exits 1
timeout 500 $RTX godot --path $EXT --display-driver x11 --rendering-method gl_compatibility \
    --script res://remodel_review.gd                                        # see below
```

What each one tells you:

1. **`architecture_check.gd`** builds the room scene without a renderer and checks ownership and positions of the Renaissance works, cases, reveal leaves, lift panels and casings. Expect `ARCHITECTURE_CHECK {... "failures":[] ...}` and exit 0. This is the fast gate; run it after every edit.
2. **The walking self-check** (`--selfcheck` on the project's main scene) drives a physics capsule through the 87 walk trials in `geometry.json`, 3.5 s each, and writes `walk-result.json` and one picture per trial. On the current sources it gives **83 of 87 walk trials and 87 of 87 camera checks, exit code 1**. The four failures are old expectations, not new damage. Judging by where the capsule stopped, `medieval_between_cases_clear`, `medieval_stairs_aisle_clear` and `loop_16` run into the retained Hall's portal guards, and `loop_11` runs into Renaissance east case A. The last recorded clean run is `lowpoly-room-v40-loop` (77 of 77), before the real Hall was attached. Treat any failure outside those four as yours.
3. **`remodel_review.gd`** writes about 100 pictures into `$EXT/evidence/`. As shipped it stops after 19 pictures at `remodel_review.gd:65` (`Renaissance, medieval and modern ceilings must exist`) and then **hangs**, because the room now has five opaque ceilings: the two door reveals added later each have a soffit. Always run it under `timeout`.

To get all the pictures I changed two lines in the trial copy only (`$EXT/remodel_review.gd`), then put the original back before relocating:

```diff
-	assert(ceilings.size()==3,"Renaissance, medieval and modern ceilings must exist")
+	assert(ceilings.size()==5,"Renaissance, medieval and modern ceilings and both reveal soffits must exist")
-			assert(copies==3,"Baked ceiling copies must follow the walking camera cutaway")
+			assert(copies==ceilings.size(),"Baked ceiling copies must follow the walking camera cutaway")
```

With that, the review finishes in 28 s on the RTX GL path and writes 104 pictures, before the bake and again after it. Move them out of `evidence/` (or out of the project) before the next import, or Godot imports every picture as a texture.

## 4. Step 3: bake the lightmap

The bake is Godot's own LightmapGI, started by a small editor plugin that presses "Bake Lightmaps". It needs the **editor with a window** and a **Vulkan device**. On this host the only Vulkan device is lavapipe, the CPU one (`vulkaninfo --summary` lists `llvmpipe`, type CPU; the NVIDIA driver file fails to load under WSL2). So the RTX is not used for baking. It is usable for OpenGL only, through `$RTX`.

```bash
# 3a. unwrap every room surface, add lights and probes, save addition_baked/room.tscn    20.4 s
$SW godot --path $EXT --display-driver x11 --rendering-method gl_compatibility --script res://remodel_bake.gd
godot --path $EXT --headless --editor --import                                           # 3.1 s
# 3b. open the scene once under the bake renderer so new textures get their 3D reimport   36.7 s
$LVP godot --path $EXT --editor --rendering-method mobile --quit-after 120 res://addition_baked/room.tscn
godot --path $EXT --headless --editor --import                                           # 3.3 s
# 3c. enable the plugin, bake, put project.godot back                                    182 s
ORIGINAL="$(cat $EXT/project.godot)"
printf '\n[editor_plugins]\nenabled=PackedStringArray("res://bake/plugin.cfg")\n' >> $EXT/project.godot
timeout 1700 $LVP godot --path $EXT --editor --rendering-method mobile
printf '%s\n' "$ORIGINAL" > $EXT/project.godot
```

The whole step took 4 min 6 s. The bake itself ("Done baking lightmaps in ...") took between 2 min 12 s and 3 min 20 s over four bakes. Step 3b is from the recorded recipe; I skipped it on three re-bakes of an already primed project without trouble, and did not test skipping it on a fresh project.

A good bake looks like this:

| Sign | Good | Failed |
| --- | --- | --- |
| 3a output | `BAKE_PREPARE surfaces=1358` | an assertion; no `room.tscn` |
| 3c output | `BAKE_OK users=1358`, the same number as the surfaces, exit 0 | `Gallery bake produced no lightmap users`, `Bake scene was replaced during editor startup`, or `Godot Bake Lightmaps control not found`, exit 1 |
| Files in `addition_baked/` | `room.lmbake` 274,691 bytes, `room.exr` 4,597,416 bytes, `room.exr.import` with `importer="2d_array_texture"`, `room.tscn` about 9.9 MB with 1358 meshes, 237 probe nodes and no lights | `room.lmbake` or `room.exr` missing |
| Probes, read with a real renderer | 350 (the 237 placed probes plus the ones Godot generates) | 0 means you read it with `--headless`, not that the bake failed |
| Room scene start | `REMODEL_READY {... "native_lightmap_users":1358 ...}` | the key is absent |

Two lines after `BAKE_OK` are normal: `ERROR: Condition "p_I->data != this" is true` and `ERROR: Can't use get_node() with absolute paths`. The first `Done baking lightmaps in 00:00:00.00.` line is normal too.

The bake is deterministic. From unchanged sources `room.exr` (sha256 `73dd17bb...f9b7`) and `room.lmbake` (`aae4e8a4...492b`) came out byte-identical to the previous agent's, and `room.tscn` differed only in Godot's random ids.

Then look at it: run the review again (or your own capture) and open the pictures. Numbers do not show a dark wall.

## 5. Step 4: attach to the Main Hall and produce `modules/shell/collection_rooms/`

### What "attach" means

Nothing is merged into the Hall. `main_build_walk.gd` extends `gallery_walk4/walk4.gd`, loads `res://modules/shell/collection_rooms/remodel_room.tscn` into the Hall's viewport, lets it build at the origin, moves it by `ATTACH`, and removes its camera, visitor, body, label, contact shadow, Hall copy and environment. Movement outside the Hall comes from the rooms and openings in `modules/shell/collection_rooms/geometry.json`.

The one-time wiring is already in the tree (it is the diff of `317b8f3b..HEAD` on these files): `modules/shell/demo.gd` line 65 loads `main_build_walk.gd`; `export_presets.cfg` includes `modules/shell/collection_rooms/geometry.json` and `modules/shell/collection_rooms/assets/*.json` and excludes `modules/shell/collection_rooms/evidence/*`; `project.godot` sets `export/convert_text_resources_to_binary=false`.

### The original script stops on this tree

`make_local_fullapp.py MAIN EXTENSION ADAPTER OUT` made a run copy of the whole app and put the room project under `modules/shell/collection_rooms/` with its paths adapted. Run against this checkout it stops at line 47:

```text
FileExistsError: [Errno 17] File exists: '.../fullapp-attempt/modules/shell/collection_rooms'
```

`modules/shell/collection_rooms/` is now tracked, so the archive it unpacks already contains it. Past that line it would also fail on `demo.gd` and `export_presets.cfg`, which it expects to patch and which are already patched (inferred from the script). It still works on its original inputs: against the `integrate-square-164` worktree at `317b8f3b` and the `main-build-extension-v49x` project it ran in 4.4 s and reported the same two changed tracked files it always did, `export_presets.cfg` and `modules/shell/demo.gd`.

### The relocation that does work here

Only the part of that script that builds `modules/shell/collection_rooms/` is still needed. Save this beside `relocate_lightmap.gd` as `$TOOLS/relocate_rooms.py`. It is that part, unchanged in what it does:

```python
"""Turn a baked room project into a modules/shell/collection_rooms/ folder with adapted res:// paths.

Run: python3 relocate_rooms.py EXTENSION OUTPUT
  EXTENSION  baked output of prepare_main_build_extension.py (read only)
  OUTPUT     new directory that becomes modules/shell/collection_rooms/; must not exist

Section 2 of make_local_fullapp.py without the full-app copy, for a tree that already
tracks modules/shell/collection_rooms/. relocate_lightmap.gd must sit beside this file. Stdlib only.
"""
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys

extension, rooms = (Path(p).resolve() for p in sys.argv[1:3])
sha = lambda path: hashlib.sha256(path.read_bytes()).hexdigest()
move = lambda text: re.sub(r"res://(?!modules/)", "res://modules/shell/collection_rooms/", text)
scripts = sorted(p.name for p in extension.iterdir() if p.suffix in [".gd", ".tscn"])
assert {"doorway_walk.gd", "remodel_room.gd", "retained_hall_room.gd", "remodel_room.tscn"} <= set(scripts)
assert (extension / "addition_baked/room.lmbake").exists(), "Bake the room project first"
rooms.mkdir()
for name in scripts + ["geometry.json"]:
    shutil.copyfile(extension / name, rooms / name)
for folder in ["assets", "presentation", "textures", "addition_baked"]:
    shutil.copytree(extension / folder, rooms / folder, ignore=shutil.ignore_patterns("*.import", "*.uid"))
# EXR atlases must keep their Texture2DArray importer, rather than the default Texture2D.
for metadata in (extension / "addition_baked").glob("*.exr.import"):
    (rooms / "addition_baked" / metadata.name).write_text(
        metadata.read_text().replace("res://addition_baked/", "res://modules/shell/collection_rooms/addition_baked/"))
# Godot serializes the binary lightmap as text; the headless dummy renderer would drop the probes.
env = dict(os.environ, DISPLAY=":99", LIBGL_ALWAYS_SOFTWARE="1", GALLIUM_DRIVER="llvmpipe")
subprocess.run(["godot", "--display-driver", "x11", "--rendering-method", "gl_compatibility",
                "--path", str(extension), "--script", str(Path(__file__).with_name("relocate_lightmap.gd")),
                "--", "res://addition_baked/room.lmbake", str(rooms / "addition_baked/room.tres")],
               check=True, timeout=90, env=env)
(rooms / "addition_baked/room.lmbake").unlink()
for path in [rooms / "addition_baked/room.tscn", rooms / "addition_baked/room.tres"]:
    path.write_text(move(path.read_text().replace("room.lmbake", "room.tres")))
path = rooms / "remodel_room.gd"
path.write_text(path.read_text().replace("addition_baked/room.lmbake", "addition_baked/room.tres"))
rewritten = {}
for name in scripts:
    moved, count = re.subn(r"res://(?!modules/)", "res://modules/shell/collection_rooms/", (rooms / name).read_text())
    (rooms / name).write_text(moved)
    rewritten[name] = {"paths_moved": count, "source_sha256": sha(extension / name), "sha256": sha(rooms / name)}
assert 'path="res://modules/shell/collection_rooms/retained_hall_room.gd"' in (rooms / "remodel_room.tscn").read_text()
assert not re.search(r"res://(?!modules/|modules/shell/collection_rooms/)", "".join((rooms / n).read_text() for n in scripts))
reference = json.loads((extension / "main-build-source.json").read_text())
summary = {"main_build_tip": reference["source_tip"], "hall_files_unchanged": len(reference["source_sha256"]),
           "room_scripts": rewritten, "relocated_by": "relocate_rooms.py"}
(rooms / "main-build-adapter.json").write_text(json.dumps(summary, indent=2) + "\n")
print(json.dumps({k: v["paths_moved"] for k, v in rewritten.items()}))
```

```bash
/usr/bin/python3 $TOOLS/relocate_rooms.py $EXT $T/modules/shell/collection_rooms         # 0.7 s
```

Expect `LIGHTMAP_TEXT_COPY_OK users=1358 probes=350` and a line of path counts (`remodel_room.gd` 103, `remodel_review.gd` 13, `remodel_presenter.gd` 5, and so on). The folder is 170 MB and holds 246 files.

I checked this script against the original on the same input (`main-build-extension-v49x`): the two outputs were byte-identical except for the random resource id in `room.tres` and the summary JSON.

### Installing it in the repo

**Not run in this checkout** (I was not allowed to edit tracked files). Run on a scratch copy of the tracked folder inside an app-only copy of HEAD, where it behaved as described:

```bash
rsync -a --delete --exclude='*.import' --exclude='*.uid' $T/modules/shell/collection_rooms/ $CK/modules/shell/collection_rooms/   # 0.5 s
godot --headless --editor --import --path $CK                                                          # 22 to 41 s on the copy
git -C $CK status --short collection_rooms
```

The two `--exclude`s keep the 195 tracked `.import` and `.uid` files, so resource ids stay stable; after the import all 195 were still byte-identical. They are tracked although `.gitignore` lists `*.import`, so a new asset's `.import` needs `git add -f` (inferred from `git ls-files`).

### Which tracked files this step changes

| Change you made | Files under `modules/shell/collection_rooms/` that differ afterwards |
| --- | --- |
| None (rebuild from unchanged sources) | `addition_baked/room.tscn` and `addition_baked/room.tres`, in Godot's random ids only (1,598 and 2 lines), and `main-build-adapter.json`. The other 242 files are byte-identical. |
| The three worked examples together | Those three, plus `addition_baked/room.exr`, `geometry.json` and `remodel_room.gd`. |
| Any | Nothing outside `modules/shell/collection_rooms/`, apart from the source files you edited yourself in `$SRC` or `image-work/collection-room-remodel/`. `demo.gd`, `export_presets.cfg` and `project.godot` are not touched again. |

Do not create `modules/shell/collection_rooms/evidence/` in the repo. The room script writes two proof files there on every native run if the folder exists.

Add a line for the new bake to `modules/shell/PROVENANCE.md` (source commit, `room.exr` hash, cost 0), as the project rules ask for generated visual files.

## 6. Step 5: verify in the repo

All three need the project imported once (`.godot/` present). Pass the renderer on the command line: `project.godot` names none, so a native run would otherwise ask for Forward+ and Vulkan (inferred; not run without the flag).

```bash
cd $CK
$SW godot --path . --display-driver x11 --rendering-driver opengl3 \
    --script res://modules/shell/prototype/collection_reconstruction/main_build_check.gd            # 41 s
$SW godot --path . --display-driver x11 --rendering-driver opengl3 \
    --script res://modules/shell/prototype/collection_reconstruction/click_route_check.gd \
    -- $CK/build/pipeline-trial/repo-click-route                                                    # 47 s
$SW godot --path . --display-driver x11 --rendering-driver opengl3 \
    --script res://modules/shell/playtest/museum_atlas.gd \
    -- --out-dir=$CK/build/pipeline-trial/atlas --rooms=light-renaissance-room,modern-painting-gallery   # 82 s
```

| Check | Pass looks like | Notes |
| --- | --- | --- |
| `main_build_check.gd` | `MAIN_BUILD_ROOMS {"attached":true,"blocks":47,"cutaway_bodies":133,"rooms":14,...}` then `MAIN_BUILD_CHECK {"failures":[],"probes":350,"removed_demo_triangles":1298}`, exit 0 | Needs a real renderer. With `--headless` it fails with exactly `Addition probes lost in full-app conversion` (seen, 9.5 s). |
| `click_route_check.gd OUT_DIR` | `CLICK_ROUTE_CHECK {"failures":[],"tests":16}`, exit 0, and `click-route-check.json` in OUT_DIR | The output directory is the **first plain argument** after `--`, not `--out-dir=`. Also passes with `--headless` (16 s). Covers the Hall and grey-gallery door only. |
| `museum_atlas.gd` | `MUSEUM_ATLAS shots=10 ...` and one PNG per view plus `atlas.json` | Asserts nothing; it is for looking. Five views per standpoint (n, e, s, w, follow), one standpoint per 7 m of room. `--rooms=` takes labels in lower case with dashes. Without it the whole museum is 105 shots and 85 MB (from another session's earlier run in `build/atlas.log`; not timed here). |

`--rendering-method gl_compatibility` in place of `--rendering-driver opengl3` selects the same renderer; the room-project commands in steps 2 and 3 use that form.

Both checks passed three ways: in this checkout as it stood, in an isolated copy of HEAD with the tracked rooms, and in the same copy with the regenerated rooms.

`scripts/check.sh` **fails on this tree** (exit 1, 12 s), independent of any rebuild: its seam check reports the four `modules/shell/collection_rooms/*.gd` files that preload `res://modules/shell/prototype/gallery_walk4/painting_asset.gd`. Its Godot step is clean. That needs its own decision; see the follow-ups.

## 7. Worked examples

All three were made in the trial room project, checked, re-baked, relocated together and run through both repo checks in an app-only copy of HEAD. In the repo you make the same edit in `$SRC` (or `image-work/`), then repeat steps 1 to 5.

**The rule that decides re-baking.** What the player sees is the baked scene, not the authored one. `load_bake()` swaps every authored mesh for its baked copy and pairs them by order (`AuthoredSurface000`, `001`, ...). So:

1. Moving, resizing, adding or removing any mesh needs a re-bake. Without it the edit is **invisible and nothing reports an error** (seen in all three examples: 0 changed pixels). So does pointing a mesh at a different texture; replacing an image file under the same name does not, because the baked scene refers to textures by path (both inferred).
2. Adding or removing any mesh, even glass, shifts the pairing of everything built after it.
3. Only edits that leave every mesh alone need no re-bake: metadata, walk trials, the loop route, a `Label3D` text, a collision shape (inferred from `remodel_bake.gd` and `load_bake()`).

### (a) Move one wall-hung artwork 0.3 m along its wall

Goltzius 61.006 on the west wall of the European gallery. In `$SRC/remodel_room.gd`, `build_adjacent_gallery()`, line 996:

```gdscript
goltzius.position=Vector3(-3.48,1.75,14.7)    # -> Vector3(-3.48,1.75,15.0)
```

That wall runs along z, so z changes; on a north or south wall change x. The number is in the builder's own frame (see the frame table in section 8), but every frame is a plain shift, so 0.3 there is 0.3 in the room.

Result: architecture check passes; with the old bake the picture is unchanged; after the re-bake the painting sits 0.3 m along (users 1358, probes 350).

Other artworks have their position written in more than one place (inferred from reading; edit them together):

| Artwork | Also written in |
| --- | --- |
| The five modern paintings and the lion | `remodel_review.gd` lines 15 and 21 (asserted), `remodel_bake.gd` lines 142 and 159 (their spot lights) |
| Pietà, Saint Roch, north grille, piano leaf, reveal leaves | `architecture_check.gd` (asserted positions) |
| Edwards, both mirrors, Romany, Delacroix, the four medieval panels | `remodel_bake.gd` line 112 (their spot lights) |
| The three Renaissance wall works | `architecture_check.gd` lines 54 to 56 (height above the platform) |

### (b) Move a doorway, or change a room's size

The data structure is `geometry['rooms']` in `$SRC/prepare_remodel.py`. Each room is `{'label', 'bounds': [x0, x1, z0, z1], 'openings': {side: [lo, hi]}}` with optional `height`, `floor`, `stone_sides`, `column_sides`, `clear_heights`, `floor_void`, `boards_across`. `bounds` is the size; an opening is an interval along its wall.

| Lines | Rooms | Frame |
| --- | --- | --- |
| 413 to 424 | Rockefeller, European gallery, Renaissance, medieval, connector, grey gallery and its thresholds | Old metres. Lines 448 to 457 and 469 to 483 shift and refit them; read the result in `geometry.json`, not here. |
| 542 to 548 | Lion stair landing, modern gallery, white-gallery and adjoining thresholds | Room-scene metres, as written. |
| 565 to 571 | The two door reveals | Room-scene metres, as written. |

Example: the modern gallery's far doorway 0.3 m west. Three edits:

```python
# line 545, modern painting gallery:              'north':[15.10,16.40]  ->  'north':[14.80,16.10]
# line 547, the threshold room behind that door:  'bounds':[15.10,16.40,20.70,22.30],'openings':{'south':[15.10,16.40]}
#                                             ->  'bounds':[14.80,16.10,20.70,22.30],'openings':{'south':[14.80,16.10]}
# line 562, the two walk trials through it:       x 15.75  ->  15.45   (modern_far_opening_out, modern_far_opening_back)
```

The script's own assertions catch the usual mistakes: an opening must be identical on both rooms that share it, rooms must not overlap in plan, the European gallery and the Hall must end on the same line, and the grey gallery's west wall must stay 6.0 m.

What follows the room data by itself: walls, door headers, jambs, architraves, baseboards, floors, ceilings, the collision floor, and the adapter's walkable plan in the app.

What does not follow (inferred from reading unless noted):

1. Every object a builder places. They use fixed coordinates, not room corners.
2. The bake's lights and probes in `remodel_bake.gd`, and the review cameras in `remodel_review.gd`.
3. Positions written into checks: `architecture_check.gd`, `main_build_check.gd` lines 52 to 53, 61 and 80, and the Hall door in `click_route_check.gd`.
4. `main_build_check.gd` line 43 expects exactly 350 probes. A bigger layout change can alter that number (the previous agent recorded 352 for an earlier layout); it stayed 350 in all three examples here.
5. Room labels: `main_build_walk.gd` (`FAR_ROOMS`, `HALL_ROOM`) and `remodel_room.gd` match on them.

Result: the edited generator ran with every assertion passing and changed exactly two rooms, two trials and one floor patch in `geometry.json`. Both walk trials through the doorway pass. With the old bake the doorway is still drawn in the old place, although the wall collision is rebuilt from `geometry.json` at every start (that part is inferred from the code). After the re-bake the doorway, its casing and the room behind it are 0.3 m west.

### (c) Add one new object to a room

A plain plinth in the modern gallery. One line in `$SRC/remodel_room.gd`, `build_lion_modern_rooms()`, before the bench (line 1387):

```gdscript
solid(Vector3(12.2,.45,23.2),Vector3(.5,.9,.5),look(Color("eeeae2")),true)
```

`solid(centre, size, material, collide)` makes a box. The last `true` gives it collision and registers it in `casings`, which is all the app needs: the adapter then blocks walking through it and lets the camera cut it away (seen: `blocks` 47 to 48, `cutaway_bodies` 133 to 134).

Result: with the old bake the plinth does not appear at all. After the re-bake it is there and lit (surfaces and users 1359, probes 350).

Another copy of a catalogue object is a data edit instead (**not run**): add a row to `volume_instances` in `image-work/collection-room-remodel/video-inventory.json` with `asset`, `position`, `size_m` and optionally `yaw`, `pitch`, `shape`. Reusing an existing `asset` name costs nothing. A new one needs `trial/<asset>-original.webp`, a generated image, which is paid work and outside this runbook. Positions in that file are in the Rockefeller frame of section 8.

### What each kind of change forces

| Step | (a) move an artwork | (b) doorway or room size | (c) add an object |
| --- | --- | --- | --- |
| Regenerate and import (28 s) | yes | yes | yes |
| `architecture_check.gd` (4 s) | yes | yes | yes |
| Re-bake (3 to 4 min) | yes | yes | yes |
| Relocate and install (25 to 45 s) | yes | yes | yes |
| Repo checks (about 90 s) | yes | yes; check positions and the probe count may need editing | yes; the object becomes a walk block |
| Edit other files | lights or asserted positions, for the artworks in the table above | objects, lights, probes, checks | none for a plain solid |

## 8. Map of `remodel_room.gd`

It extends `doorway_walk.gd` (the visitor, the camera, the floor collision from `geometry.json`, the walking self-check). `retained_hall_room.gd` extends it in turn and replaces two functions. Line numbers are for `$SRC/remodel_room.gd` at `32d3ba8c`; the copy in `modules/shell/collection_rooms/` has the same line numbers.

### Main functions

| Line | Function | What it does |
| --- | --- | --- |
| 33 | `_ready()` | The build order: rooms, Rockefeller contents, European gallery, Renaissance and medieval, grey gallery, Hall, landing and modern gallery; then names every mesh `AuthoredSurfaceNNN`, then `load_bake()`. |
| 111 | `shift_new(first, offset, z_before)` | Moves everything built since `first`. This is how old-frame builders land in the room. |
| 226, 250, 624 | `solid()`, `panel()`, `moulding()` | The three building blocks: a box (optionally with collision), a textured quad, a profiled trim. |
| 569 | `wall_face()` | Gives a wall body one inward face, so shared walls do not flicker. |
| 766, 777 | `update_baked_visibility()`, `load_bake()` | Swap authored meshes for their baked copies; hide ceilings and cut-away walls with the camera. |

### Per-room builders and where objects are declared

| Room | Builder (line) | Objects |
| --- | --- | --- |
| Every room's shell | `build_rooms()` 268, `build_parquet()` 584, `build_reveal()` 524 | Walls, headers, jambs, baseboards, floors, three flat ceilings, the two door reveals with their folded leaves. All from `geometry.json`. |
| Rockefeller | `build_bookcase()` 640, `build_mirrors()` 691, `build_displays()` 719, `build_furniture()` 811, `build_catalogue_objects()` 880 | Bookcase, two mirrors, cases and pedestals, Edwards and Romany portraits, wallpaper, settee and chairs. The 47 catalogue volumes come from data, not code: `video-inventory.json` (46 rows) plus the lion panel added in `prepare_remodel.py` line 266. That data also places the two apostles and the lion, which stand in other rooms. |
| European gallery | `build_adjacent_gallery()` 936 | Delacroix, Fetti, Goltzius, two piers, the far door leaves. |
| Renaissance and medieval | `build_sculpture_rooms()` 1056 with `build_gabled_frame()` 1581, `build_iron_grille()` 1504, `build_medieval_stair_door()` 1458, `build_renaissance_east_cases()` 1651, `build_renaissance_wall_art()` 1713 | Perugino, tracery arch, four medieval panels, Saint Roch, triptych, Pietà, the two east cases (6 and 5 objects), velvet, tapestry, Madonna, both medieval cases, benches, grilles. Shapes of the case objects live in the `*_assets.gd` files. |
| Connector and grey gallery | `build_grey_gallery()` 395 | Lift panels, the two Ionic columns, Courbet, Corot, Bertin, the piano door leaf. |
| Landing and modern gallery | `build_lion_modern_rooms()` 1286 | Stairs and guard, door leaves, two windows, bench, five modern paintings, the Seated Woman case, the lion's frame. |

The Hall itself is `build_connected_hall()` (line 116), replaced in `retained_hall_room.gd` by loading the real Hall bake and hiding its six stand-in meshes.

### Which frame a builder's numbers are in

| Builder | To get room-scene metres |
| --- | --- |
| `build_rooms`, `build_reveal`, `build_lion_modern_rooms` | Already room-scene metres. |
| The five Rockefeller builders, and `video-inventory.json` | x minus 1.95; z plus 2.2 if z is below 1.0; then z minus 0.76 if the result is below 1.8. |
| `build_adjacent_gallery` | x minus 1.95. |
| `build_sculpture_rooms` and the five builders it calls | z plus 9.25. |
| `build_grey_gallery` (columns, paintings, piano leaf) | x minus 4.6, z minus 0.76. |

Checked against the built scene: for example St George is written at (0.18, 1.62, -6.83) and stands at (-1.77, 1.62, -5.39).

### How `geometry.json` is produced and consumed

Produced by `prepare_remodel.py` lines 409 to 575. It starts from `$ING/room-route-walk-v5/geometry.json` (kept only for its survey notes), sets the room list, shifts and refits it, appends the walk trials and the 33-leg loop route, checks the plan, and writes `rooms`, `patches` (the collision floor), `trials`, `start`, `hall_reveal` and several notes.

| Consumer | Uses |
| --- | --- |
| `doorway_walk.gd` `_ready()` | `start`, `trials`, `trial_seconds`, `caption`, `patches` |
| `remodel_room.gd` `build_rooms()` | `rooms`, `hall_reveal` |
| `remodel_bake.gd`, `remodel_review.gd`, `architecture_check.gd` | `hall_reveal.wall_m` and `leaf_m`, to move lights, cameras and expected positions with the reveal |
| `main_build_walk.gd` `_attach_rooms()` | `rooms`: labels, bounds, openings, `floor_void`. This is the walkable plan in the app. |

### Metadata that marks artworks

Counts are from the built scene (the same in the tracked rooms and the regenerated ones).

| Key | Count | Meaning |
| --- | --- | --- |
| `catalogue_asset` | 45 | A catalogue volume from `video-inventory.json`; the value is the asset name, such as `st-george`. On the mesh. |
| `catalogue_accession` | 30 | The museum accession number. On the five modern paintings (set in `remodel_room.gd`) and on every object an `*_assets.gd` helper builds. |
| `renaissance_wall_object` | 3 | `velvet_23307x`, `woodcutters_29280`, `madonna_58196`; comes with `wall_side`. |
| `renaissance_case_object` | 11 | One per object in the two east cases; the value is the object's key. |
| `medieval_case_object` | 7 | The objects in the tall medieval case. |

Three more things to know:

1. **Fourteen paintings carry none of these.** Edwards, Romany, the wallpaper, Delacroix, Fetti, Goltzius, Courbet, Corot, Bertin, Perugino and the four medieval panels are built with `Painting.build_framed` or `build_shaped` and only show their accession in the texture file name (`assets/painting-<accession>.jpg`). Code that finds artworks by metadata misses them.
2. `room_wall` (94 bodies, value `<room label>:<side>` or `...:header`) marks walls. The camera cut-away and the adapter's room grouping depend on it; wall-hung work is re-parented to its wall body so it disappears with the wall.
3. `artwork_label_proxy` (18) marks blank label stand-ins. Keys ending in `_accepted` are acceptance flags; they are all false and `architecture_check.gd` fails if one turns true.

## 9. Known traps

Marked **seen** when it happened in this run, **recorded** when it comes from a CHECKPOINT file.

### Tools

1. **Seen.** The pipeline's helper scripts are tracked under `docs/evidence/collection-reconstruction/` but this checkout's sparse checkout hides that folder. Use `git show HEAD:<path>`.
2. **Seen.** `make_local_fullapp.py` stops with `FileExistsError` on any tree that tracks `modules/shell/collection_rooms/`. Use the relocation in step 4.
3. **Seen.** `remodel_review.gd` fails its ceiling assertion and then never exits. Use `timeout`.
4. **Seen.** The walking self-check exits 1 because of four out-of-date trials. Its first trial always starts from `start`, not from its own start point, so a shortened trial list fails its first entry.
5. **Seen.** `prepare_main_build_reference.py` refuses to run while the Hall folder has uncommitted tracked changes (`Main Hall has uncommitted tracked changes`). Another session edited `gallery_walk4/walk4.gd` in this checkout during this run; the snapshot here was taken before that, and the script refused afterwards.

### Bake

1. **Seen.** A stale bake hides your edit without any error. See the rule in section 7.
2. **Seen.** Vulkan here is lavapipe only, so the bake runs on the CPU. `--rendering-method mobile` must be on the command line; the plugin must be removed from `project.godot` afterwards, and the editor rewrites that file.
3. **Seen.** `room.tscn` differs in about 1,600 lines after every bake because Godot draws new random ids. Compare `room.exr` and `room.lmbake` instead.
4. **Recorded.** On the RTX GL path, 2x MSAA caused a D3D12 "device removed" failure, and it also happened with MSAA off. Software GL is the fallback. It did not happen in this run.
5. **Seen.** The room project grows from 247 MB to more than 700 MB through imports. Pictures left under `evidence/` get imported too (seen in `main-build-extension-v49x`).

### Probes and the app

1. **Seen.** With `--headless` the probe count reads 0. `relocate_lightmap.gd` refuses to convert and `main_build_check.gd` fails. Both need a real renderer; software GL is enough.
2. **Seen.** Every native run prints 157 `invalid UID ... using text path instead` warnings for `modules/shell/collection_rooms/addition_baked/room.tscn`. The ids were issued in the room project; the text paths are right. Harmless.
3. **Recorded.** On export, converting text resources to binary dropped the baked probes. `project.godot` now sets `export/convert_text_resources_to_binary=false`; keep it.
4. **Recorded.** In a packed app `res://` is read-only, and two proof-file writes in `remodel_room.gd` crashed the room build. They are now guarded with `if file!=null:` (lines 1553 and 1645). Any new write to `res://` in a room script needs the same guard.
5. **Recorded.** The room scene must build at the origin and be moved afterwards. Its floor test uses fixed Hall coordinates; positioning it before `_ready` empties the wrong floors.

### Checks and the machine

1. **Seen.** `scripts/check.sh` fails on the seam check for `modules/shell/collection_rooms/`.
2. **Seen.** `click_route_check.gd` takes its output directory as a plain argument. Passing `--out-dir=...` to a script that expects a plain one creates a folder literally named `--out-dir=` in the checkout; one is there now from an earlier run of another check.
3. **Inferred.** Native runs of the main project need `--rendering-driver opengl3`, because `project.godot` names no renderer. Every run here passed it.
4. **Seen.** Disk. One room project plus one app copy is about 1.7 GB. The ingestion directory already holds 111 earlier projects (`lowpoly-room-*`, `main-build-extension-v49*`, `main-build-rooms-v50*`) and was 72 GB in all at the start of this run. Delete your trial when you are done.
5. **Seen.** Other sessions edit this checkout while you work. `main_build_walk.gd` changed at least twice during this run. Take the commit you verify against from `git rev-parse HEAD`, and use an app-only copy when you need a fixed tree.

## 10. Proof and timings

### Is the regenerated folder equivalent to the tracked one?

Yes. Compared with `modules/shell/collection_rooms/` at `32d3ba8c`:

| Comparison | Result |
| --- | --- |
| Files | 242 of 245 authored and baked files byte-identical. `room.tscn` and `room.tres` identical once Godot's random ids are removed. `main-build-adapter.json` is a new summary. |
| Bake | `room.exr` and `room.lmbake` byte-identical to the previous agent's bake. 1358 users, 350 probes, 1358 baked meshes on both sides. |
| Scene census | Identical in every field: 5,441 nodes, 4,619 meshes, 159 static bodies, 141 casing bodies, 96 marked artworks at the same positions to the millimetre, the same count for every metadata key, the same inventory. |
| `main_build_check.gd` | Same output on both: 14 rooms, 47 blocks, 133 cut-away bodies, 350 probes, 1298 removed triangles, no failures. |
| `click_route_check.gd` | 16 of 16 on both, the same largest step (0.0416 m). |
| Atlas pictures, two rooms, ten views | One view bit-identical; the other nine differ in 0.10 to 0.16 percent of pixels, all inside the box around the visitor, whose script another session was editing. The rooms are the same. |

The census and comparison scripts, every log, the example pictures and the timings are in `build/pipeline-trial/` in this checkout (18 MB, untracked scratch). The trial directory itself is deleted.

### Timings

| Step | Time | Renderer |
| --- | --- | --- |
| Hall snapshot | 1.4 s | none |
| Room project (`prepare_remodel.py` included) | 15.9 s | none |
| Import | 12.2 s | headless |
| Architecture check | 3.6 s | headless |
| Walking self-check | 513 s | software GL (at least 305 s on any renderer: 87 trials of 3.5 s) |
| Review captures | 28 s with the two-line change; stops after about 9 s as shipped | RTX GL |
| Bake: prepare, import, prime, import, bake | 20.4 + 3.1 + 36.7 + 3.3 + 182 s | software GL, then software Vulkan |
| Re-bake without the prime step (three times) | 177 to 243 s | same |
| Relocate | 0.7 s | software GL |
| App-only copy of HEAD, and its import | 2.9 s, then 22 to 41 s | headless |
| `main_build_check.gd` | 41 to 43 s (57 to 65 s while a bake was running) | software GL |
| `click_route_check.gd` | 47 to 48 s (74 to 75 s while a bake was running); 16 s headless | software GL |
| `museum_atlas.gd`, two rooms, ten shots | 82 s | software GL |
| `scripts/check.sh` | 12.3 s | headless |

One rebuild from an edit to a verified folder, without the walking self-check and the atlas, is about seven minutes of machine time.

### What could not be reproduced as written

1. `make_local_fullapp.py` on this tree: stops at line 47. Replaced by the relocation in step 4, which was checked against it.
2. `remodel_review.gd` as shipped: stops at line 65 after 19 pictures. Completed only with a two-line change in the trial copy.
3. A clean walking self-check: 83 of 87, four out-of-date trials.
4. A bake on the GPU: there is no GPU Vulkan device on this host.

## 11. Follow-ups worth an Issue

1. Put `relocate_rooms.py` and `relocate_lightmap.gd` next to the other generation scripts, so step 4 does not depend on a code block in this page.
2. Fix the ceiling assertion in `remodel_review.gd` (the two lines in section 3) and make the script quit when an assertion fails.
3. Bring the four out-of-date walk trials and the loop route in `prepare_remodel.py` in line with the portal guards and the Renaissance east case.
4. Decide how `modules/shell/collection_rooms/` should pass the seam check in `scripts/check.sh`, which fails today.
5. Give the fourteen unmarked paintings a `catalogue_accession`, if artworks in the added rooms are going to be found by metadata.
