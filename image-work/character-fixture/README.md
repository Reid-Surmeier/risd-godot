# Throwaway Blender bake/animation fixture

For [Prototype: texture and animation baking on one existing rigged fixture](https://github.com/Reid-Surmeier/risd-godot/issues/230). Visual decision remains open for the owner. This uses the existing authored visitor, not the supplied horned design and not a Muse/3D-generator result.

The fixture has a saved Blender source, grayscale source texture, color/AO bake, skinned GLB, rest/idle/walk renders and a one-second walk preview. Inspected rest/walk/atlas/motion-sheet images show the shirt stripes and moving arms/feet. The old fixture uses rigid segmented pieces, so this proves transfer rather than smooth elbow/knee deformation or target quality. At 8 samples, the film is a pose/motion check rather than a gait evaluation.

`evidence.json` records the **native** bake/export/reimport: Blender4.3.2 CPU; one skin/41joints/76clips; all10primitives have UV+joint+weight attributes; two embedded maps; both reimported maps512²; animated foot matrix changes. `mcp-smoke.json` separately records a successful **actual MCP stdio** connection through mcp-for-blender2.0.0 to BlenderGUI4.3.2, protocol7, telemetryoff; it selected Walking_A_Rig and frame8 and queried41bones76clips. The temporary GUI used existing DISPLAY:99, loopback127.0.0.1:9876, registered the installed add-on only in-process, and was stopped afterwards. Native renders were not driven through MCP. The current Codex session still has no loaded project MCP tools; project configuration/fresh session remains separate setup work.

No Godot/browser gameplay import was attempted here. The target needs its own shape/topology/deformation/camera evidence. Unpaid cost: $0. No runtime asset or managed configuration was changed. GUI initialization printed EGL_BAD_MATCH warnings, but its event loop/socket and MCP calls succeeded.

Run from the repository root (requires existing Blender4.3.2 and ffmpeg):

```bash
/home/reidsurmeier/.local/opt/blender-4.3.2/blender --background --factory-startup --threads 1 --python-exit-code 1 --python image-work/character-fixture/build.py
/home/reidsurmeier/.local/opt/blender-4.3.2/blender --background --factory-startup --threads 1 --python-exit-code 1 --python image-work/character-fixture/render_check.py
ffmpeg -y -framerate 8 -pattern_type glob -i 'image-work/character-fixture/frames/walk-*.png' -c:v libx264 -pix_fmt yuv420p -movflags +faststart image-work/character-fixture/walk.mp4
```

The stage writes only this fixture folder and reads the existing `modules/shell/prototype/gallery_walk4/identity/Rogue.source.glb`. `build.py` copies the reviewed earlier trial recipe with local output paths, CPU explicitly set, RGB-only nonblank checks, current Actions export, and save-blend. It retains the authored 29-part body and source skeleton/clips. See [earlier trial recipe](https://github.com/Reid-Surmeier/risd-godot/blob/0f690ea63245c633b04cb2dbb35ac28ff0bb710e/modules/shell/prototype/gallery_walk4/identity/build.py).

For the isolated unpaid MCP proof, first ensure9876 is unused; do not replace another session's server. Run a temporary GUI (no `--background`) with the existing display:

```bash
/home/reidsurmeier/.local/opt/blender-4.3.2/blender --factory-startup --threads 1 --python-exit-code 1 --python image-work/character-fixture/mcp_bootstrap.py
```

In another terminal, run `mcp_smoke.py` with an existing Python environment containing the MCP SDK. The captured run used `/home/reidsurmeier/.cache/uv/archive-v0/obgwABUdN8LrCiCW/bin/python`; that cache path is host-specific. The script launches the same pinned `uvx --from mcp-for-blender==2.0.0 mcp-for-blender` definition and calls real `get_addon_status` and `execute_blender_code` tools. It saves a sanitized proof. Close only this temporary GUI after the call and confirm9876 is no longer listening; the checked-in proof records that completed cleanup. It does not activate any paid provider or save user preferences.

Open `index.html` via the root agent's private share. The raw source modulation map versus baked atlas comparison is between stages: stripes/tint come from authored material colors, not from the grayscale source image alone. Visuals are inspectable; acceptance of a character design is not inferred.
