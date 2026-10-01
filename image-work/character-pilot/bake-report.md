# Actual MCP-controlled target color bake

The supplied character pilot now has a local512² color bake and a saved Blender source. **Animation contact remains unaccepted.** This is a throwaway proof, not a runtime replacement.

## What passed

Actual Python MCP SDK stdio calls reached pinned mcp-for-blender2.0.0 and installed protocol7 add-on in BlenderGUI4.3.2 on existing DISPLAY:99. `execute_blender_code` launched the saved native Blender4.3.2 CPU stage as a subprocess and returned promptly with its PID. The paid-provider route was not invoked. The native process wrote a separate completion record only after assertions and exported renders succeeded; launch success alone was never treated as bake success. The two owned temporary GUIs were stopped, and127.0.0.1:9876 was checked absent at handoff. No managed configuration or saved user preferences changed. See `target-mcp-launch.json`, `target-bake-completion.json`, `target-mcp-normalization-launch.json` and `target-idle-normalization.json`.

`target-baked.glb` keeps one character mesh,7,719triangles,24joints and the existing UVs/rest skeleton. The original source clip stays, and Idle/Walk/Run clips are copied only after bone names, parents, local rest matrices and rig world matrices match exactly. The derived GLB has four clips: `Armature|clip0|baselayer`, `idle`, `run`, `walk`. Temporary rig-import actions are removed to avoid extra orphan clips. The80-triangle Icosphere created for Blender bone display is not treated as the character and is excluded by selecting only the skinned character and its rig.

The saved512² PNG contains nonblank RGB (`max0.7960785`) and is the only embedded image in the884,452-byte derived GLB; the source rigged GLB is5,573,992bytes. This reduction is a file-size observation, not a measured load-time claim. Existing UVs and the24-bone rest skeleton were compared before/after in memory. Source rest height measured from refreshed evaluated vertices is1.898063m.

## Material changes are explicit

The raw rigged provider material omits glTF `metallicFactor`, which defaults to1; it also emits the source texture and uses `KHR_materials_specular` color factor[2,2,2]. A Diffuse/Color bake can be black on that fully metallic material. The derived stage sets Metallic0 and Roughness1 **before** the color-only bake. Afterward it connects the baked texture as Base Color, disconnects emission, sets EmissionStrength0 and SpecularIORLevel0, and resets SpecularTint to white. Thus this result changes the atlas and the material response, not just the texture resolution. Raw provider files are untouched.

The stage bakes `DIFFUSE` with only `COLOR`, on the existing UVs, with8px margin; it does not add lighting, AO or normal maps to this target. See Blender's [baking documentation](https://docs.blender.org/manual/en/4.3/render/cycles/baking.html) and the [glTF material defaults/specification](https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html).

Default forced sampling initially trimmed Idle4.03333→4.0s and Walk1.06667→1.04167s. The final saved stages set the supported `export_force_sampling=False` for these already keyed Actions. Final Idle4.03333346049s and Walk1.06666676203s match provider endpoints within floating-point precision; Run remains0.666666667s. The provider's placeholder `clip0` still shortens0.3→0.291666667s, so exact timing preservation is not claimed for every clip. Source and both final derived timings are recorded in `target-clip-timings.json`.

## Idle correction is a separate artifact

`target-baked.glb` preserves the raw copied Idle behavior. Its Hips scale is about1.1764706, while Walk uses1.0. `target-baked-normalized-idle.glb` changes only the three Idle Hips scale curves: six keys and their handles become1.0. Source/provider files and the raw baked file remain unchanged. Both derived files keep7,719triangles,24bones,four clips and the baked flat material.

Native measurements at the first Idle frame give raw Idle height2.06530m and minimumZ−0.0101m; normalized Idle height1.75551m and minimumZ+0.07625m. The smaller height also reflects the pose, so it is not itself a head-scale metric. The normalized feet float about7.6cm above the rest-sole plane. Walk frame8 reaches minimumZ−0.0807m in this native evaluation. These native values are not interchangeable with the separately calibrated Godot floor measurements. **Normalizing scale proves a repair of that channel; it does not produce accepted foot contact.** The Godot motion investigation records raw and derived runtime measurements separately.

Images inspected: `baked-rest.png`, `baked-walk.png`, `baked-idle-raw.png`, `baked-idle-normalized.png`. The colored shirt/hat and face survive the bake; raw/normalized Idle visibly differ in size under the same camera. A new character's identity, joint deformation and intended game camera still need owner review.

## Reproduce

Use the existing temporary GUI bootstrap described in `../character-fixture/README.md`. Do not replace an existing9876 server. With that local GUI active, execute the following with an existing MCP-SDK Python environment (the captured host path is shown; its cache location can change):

```bash
/home/reidsurmeier/.cache/uv/archive-v0/obgwABUdN8LrCiCW/bin/python -P image-work/character-pilot/bake_mcp.py
/home/reidsurmeier/.cache/uv/archive-v0/obgwABUdN8LrCiCW/bin/python -P image-work/character-pilot/bake_mcp.py --normalize-idle
```

Run the second command **after** the first native job's completion file says success and its process has exited. `-P` prevents the neighboring project `inspect.py` from shadowing Python's stdlib inspect module. The launcher starts the pinned absolute Blender binary with `--background --factory-startup --threads1 --python-exit-code1`, using `bake_stage.py` or `normalize_idle.py`. Native stdout goes to separate local logs. Follow the completion files and process state; a stale record must not be treated as the current run's result. Close only the temporary GUI after all jobs finish.

`target-baked.blend` saves the original-scale combined clips and flat baked material before preview cameras are added. The normalized GLB is regenerated by its separate saved stage. Local bake/control/normalization spend:$0. Paid generation provenance belongs to the pilot's original request receipts; these local derivations made no new paid calls. `target-bake-hashes.json` records the source/output/stage SHA-256 values; `bake-failures.md` preserves the local failures and corrections.
