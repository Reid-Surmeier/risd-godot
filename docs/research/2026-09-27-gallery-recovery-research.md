# Gallery recovery research — September 27, 2026

Research for the owner's rejection of the character, unfinished room details, doorway floor, camera visibility and weak retro presentation in `22089e5.html`. Parent: [Wayfinder #116](https://github.com/Reid-Surmeier/risd-godot/issues/116). No runtime changes or paid generation in this investigation.

## Conclusion

Replace the rejected character with a source model, prove its animation separately, and complete the room's missing material work. Another shader adjustment cannot repair these silhouettes, plain-color furnishings or overlapping doorway constructions. The supplied ACNH archive is now the leading source to evaluate; it explicitly omits animation clips. Preserve the RISD architecture and paintings rather than replacing the museum with Animal Crossing furniture.

The current game **does have a shader**, but **the requested retro look remains undelivered**. Its RGB6 quantization, raster dither and vertical filtering are subtle, and previous controlled reviews found no decisive visual winner. Shader existence was demonstrated; the requested appearance was not accepted. The owner's follow-up explicitly rejects treating this as incidental or omitting it from the work. A visibly reference-driven rendering pass is a required deliverable alongside character, materials and navigation. Its controlled prototype can start on the current scene; its final acceptance must use the integrated replacement character and finished room.

## What I checked

- Owner screenshot: `/home/reidsurmeier/risd-godot/.orca/drops/Screenshot 2026-09-27 at 11.30.43 AM.png` (actual filename uses a narrow space before AM). It visibly shows the faceted cap/assembled-looking body, plain doorway surround, featureless light recess and dark floor patch.
- Fetched the exact shared HTML successfully. It boots Godot executable `22089e5`; it is not a Three.js scene.
- Read map #116 and the history/acceptance of #130, #135, #140 and #142; reviewed the prior session through memory retrieval and then verified against source, reports and issue comments. The memory summary was incomplete, so it was not used as proof of missing implementation.
- Actual implementation is `/home/reidsurmeier/risd-godot-worktrees/gallery-walk-prototype`, branch `prototype/gallery-walk`, inspected HEAD `dd6948a`. The supplied working directory is an older prototype branch. Neither worktree's existing changes were altered.
- Compared `walk4.gd`, `gamecube.gdshader` and `identity/visitor_identity.glb` byte-for-byte against commit `22089e5`: all equal to the inspected current files. This supports using those source files to explain the linked build; it does not certify every exported pack byte.

Source links below point into that implementation worktree. Findings labeled **verified** are direct file/image observations; **prior evidence** refers to existing reports, not newly repeated tests; **hypothesis** needs a controlled reproduction.

## Why the current character looks wrong

**Verified:** [identity/build.py](/home/reidsurmeier/risd-godot-worktrees/gallery-walk-prototype/modules/shell/prototype/gallery_walk4/identity/build.py) constructs a new skin from primitive pieces on the KayKit rig. It does not import an Animal Crossing player. Direct inspection of the GLB JSON found:

| Property | Current character |
| --- | --- |
| File | `identity/visitor_identity.glb`, 3,809,432 bytes |
| Embedded texture images | **0** |
| Materials | 10 |
| Skeleton | 41 joints |
| Animation entries | 76, inherited from the source rig |
| SHA-256 | `8ae841b87653190979e198e43c7cc4aec45c8c6d66d43746d023cc03be1afe5c` |

The [identity report](/home/reidsurmeier/risd-godot-worktrees/gallery-walk-prototype/docs/research/gallery-character-identity-next.md) records 29 authored pieces, 5,104 triangles and rigid one-bone weights that can expose joins. The Muse turnaround was a visual guide, not the character's texture. The later [UV-bake trial](/home/reidsurmeier/risd-godot-worktrees/gallery-walk-prototype/docs/research/gallery-visitor-uv-bake-trial.md) used an authored placeholder shirt and found no clear improvement; it was not integrated. Repeating a shirt texture pass would not correct the head, face, cap, hands or silhouette.

**Verified motion coupling:** [rig/visitor.gd](/home/reidsurmeier/risd-godot-worktrees/gallery-walk-prototype/modules/shell/prototype/gallery_walk4/rig/visitor.gd:130) samples KayKit `Walking_A`, blends with idle, advances phase from distance and applies a sole solver. It assumes specific bone names and source dimensions. A Nintendo mesh is not a drop-in replacement for this adapter. Preserve the navigation/controller behavior, but map and test the imported skeleton, forward axis, stride and feet explicitly. Godot's [AnimationTree](https://docs.godotengine.org/en/stable/tutorials/animation/animation_tree.html) can blend existing clips; it does not invent absent animations.

**Prior evidence:** very small measured stance drift and sole penetration establish contact mathematics, not an appealing gait, correct body silhouette, or natural reversal. The morning report and open #139/#142 already distinguish those claims. The owner's current rejection supersedes earlier acceptance of the experimental sprite animation.

## The user-supplied ACNH archive

The [u/nimaid source post](https://www.reddit.com/r/ac_newhorizons/comments/qtmv3x/all_models_textures_ripped_for_acnh_200_daepng/) links [ACNH 2.0.0 models on Internet Archive](https://archive.org/details/acnh-2.0.0-models). The author describes rigged COLLADA DAE models and PNG textures exported with Switch-Toolbox, about 7.9 GB compressed / 11.9 GB unpacked, and explicitly says the animations were **not exported**. Those are uploader statements, not results of our own binary inspection. Retrieval findings and alternatives are in [the asset-source investigation](2026-09-27-character-asset-sources.md).

Use one human appearance first: body, head/face, hair/hat, clothing and matching maps. Keep the original mesh and UVs; do not regenerate the character with Muse. Check skin controllers, joint hierarchy, clothing binding, eye/mouth material behavior and scale. Export a self-contained GLB for the existing runtime. [Godot recommends glTF 2.0](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/available_formats.html); DAE support alone does not prove a particular conversion preserved skinning.

A working idle/walk/start/stop/turn set is a separate requirement. First inventory compatible source animation files; if unavailable, retarget a verified clip onto the imported skeleton and judge it in motion. Do not claim Nintendo gait from a Nintendo mesh running KayKit motion. ACNH is also a newer visual era than the GameCube/DS references; retain its useful authored proportions while evaluating texture/material treatment against the selected reference. No redistribution grant was established by finding this archive; provenance and asset permission remain separate from converter licenses.

## Room material coverage: what was actually finished

The source at [walk4.gd](/home/reidsurmeier/risd-godot-worktrees/gallery-walk-prototype/modules/shell/prototype/gallery_walk4/walk4.gd:317) and the existing Muse recipes show selective coverage, exactly as the owner suspected.

| Room element | Verified current treatment | Next bounded treatment |
| --- | --- | --- |
| Paintings and frames | Existing painting masters and frame recipes; previous integrated proof covers 23 artworks | Preserve these and their identities/placements. Use them as the quality reference. |
| Parquet, walls, skylight | Muse oak/wall/skylight inputs exist, with procedural placement and a baked lighting pipeline | Retain source work; inspect scale and repetition under the final camera instead of regenerating everything. |
| White baseboard, cornice, doorway casing | Repeated boxes/sloped pieces with `ps(null, WHITE)`; no albedo image on these elements | One reference-based ivory trim material/atlas, mapped onto correctly measured profiles; review a corner and doorway before applying throughout. |
| Bench upholstery and support | Bevelled seat mesh with `ps(null, #2f3a52)`; dark block frame and legs; no upholstery image | Use the actual RISD seating reference for one Muse upholstery/wood study; preserve dimensions, silhouette and collision. Add UVs and rebake affected lighting. |
| Doorway beyond-view | Original Muse doorway cards exist, but runtime explicitly hides them when configuring lighting | Resolve traversable geometry first, then shade it consistently. A background card is unsuitable as a walkable floor. |
| White recess and navigation room | Explicitly unshaded plain-color test geometry, outside the main static material bake | Finish a coherent threshold/recess; keep the white destination as a navigation test room unless scope expands. |

The [bake adapter](/home/reidsurmeier/risd-godot-worktrees/gallery-walk-prototype/modules/shell/prototype/gallery_walk4/bake/prepare.gd:22) copies source albedo/UV settings into the saved static room. Merely adding a source texture without regenerating/rebaking the saved room can leave the browser showing the old material. Bench construction currently lacks authored albedo UVs. Muse output alone does not solve that mapping step.

Proposed smallest material batch: ivory trim, upholstery, seating wood, each from the appropriate original reference and inspected at actual gameplay size. Generate only missing useful inputs; preserve provenance, hashes and spend through the established OpenRouter pipeline. No generation was run for this report.

## Doorway floor and camera

**Verified:** [the test-room builder](/home/reidsurmeier/risd-godot-worktrees/gallery-walk-prototype/modules/shell/prototype/gallery_walk4/walk4.gd:845) adds 1.1 m deep white recesses to both existing doorways, including floors at y=0 and small thresholds. [The old far vestibule](/home/reidsurmeier/risd-godot-worktrees/gallery-walk-prototype/modules/shell/prototype/gallery_walk4/walk4.gd:599) still defines a floor at y=0.004; the arch-side continuation has a floor at y=0.002. `_set_lighting()` hides the old textured cards, not all old vestibule geometry. The portal switches spaces at the doorway plane rather than walking continuously through the full depicted depth.

**Hypothesis:** retained baked vestibule floors can cover the new recess floor, explaining a dark or mismatched patch beside the white sides. A screenshot does not establish a literal missing floor, and this investigation has not isolated that patch with a per-surface visibility test. Before editing, reproduce the owner's doorway pose and toggle only the old floor/recess in a diagnostic. The fix should leave one deliberate floor surface, one threshold height, coherent side/ceiling depth and a transition aligned to the visible passage. Do not conceal it with bloom or another painted floor card.

**Verified camera behavior:** [the dollhouse branch](/home/reidsurmeier/risd-godot-worktrees/gallery-walk-prototype/modules/shell/prototype/gallery_walk4/walk4.gd:1347) places the eye outside the room and hides whole wall groups according to view direction. It returns before the legacy first-person-style wall-clearance clamp. Roof/cornice group 32 is excluded; wall groups change around direction thresholds. This intentionally permits cutaways, but it also means a character collision pass cannot prove camera containment.

**Prior controlled evidence:** [the cutaway diagnosis](/home/reidsurmeier/risd-godot-worktrees/gallery-walk-prototype/docs/evidence/gallery-cutaway-diagnosis/README.md) changed the environment to magenta and proved a previously reported dark corner was background beyond finite walls, not a missing mesh triangle. It also documented exposed floor edges at other angles. That does not prove every new see-through-wall report has the same cause.

Recommended camera work: define valid compositions over the allowed player positions/orbit range, keep a consistent cutaway policy, and prevent views past unfinished floor/wall extents. Test all four corners, both doorways and complete orbit sweeps. For a camera intended to remain inside walls, Godot's [SpringArm3D workflow](https://docs.godotengine.org/en/stable/tutorials/3d/spring_arm.html) supplies collision-aware shortening; it is not a drop-in fix for this deliberately external dollhouse camera.

## What the shader does, and why it is not enough

**Verified:** `_ready()` attaches `_post()` to the gallery SubViewportContainer. The default loads [gamecube.gdshader](/home/reidsurmeier/risd-godot-worktrees/gallery-walk-prototype/modules/shell/prototype/gallery_walk4/gamecube.gdshader), with `quantization_mode=2` and `copy_filter=0.5`. It quantizes native texels to six-bit RGB with a 2×2 raster pattern, applies vertical reconstruction filtering, and enlarges bilinearly. `?final_render=bypass` is a genuine no-quantization/no-copy-filter control; `original` still quantizes and must not be labeled shader-off.

The [primary-source renderer report](/home/reidsurmeier/risd-godot-worktrees/gallery-walk-prototype/docs/research/gamecube-reference-rendering-plan.md) preceded implementation. [Dolphin's PixelShaderGen](https://github.com/dolphin-emu/dolphin/blob/master/Source/Core/VideoCommon/PixelShaderGen.cpp) is engineering evidence for raster quantization; our final-image pass is an approximation of a different stage in the original pipeline. There is no demonstrated PS2-specific renderer here.

**Prior evidence:** #140's initial filter comparison and later integrated RGB6/dither comparison did not meet the two-scene visual-win requirement, so the previous finish was retained. This was a stop rule, not approval that the gallery resembled Animal Crossing. Low-resolution filtering also reduces dither visibility. The dominant remaining differences are model shape, texture motifs, light distribution and framing.

Required rendering work: establish a consistent internal resolution and enlargement; tune color quantization and visible ordered dither as separate controls; compare edge softness without erasing artwork; coordinate texture scale and baked light with the display treatment. Start a bounded prototype on the existing room rather than waiting for every asset. Compare actual bypass, retained finish and one clearly stronger static stylized variant with the same camera, materials, lighting and actor pose. Then repeat on the repaired integrated scene. Judge normal-speed movement and stills at 720 and 1600 widths. Preserve artwork detail, ivory whites and blacks; reject crawling texture/noise. If a stronger PS2-like presentation is selected, label it as deliberate art direction rather than GameCube accuracy. Do not silently stack another desktop CRT effect. Completion requires a perceptible, reference-supported improvement in the running viewer, not a shader file, arithmetic test or another inconclusive comparison labeled done.

## Implementation order and acceptance

1. **Character proof first.** Retrieve/assemble one source character, preserve its silhouette/UVs, and show front/profile/back plus idle, straight walk, diagonal, stop and full reversal in the actual gallery camera. Require matching outfit deformation and readable face; verify forward direction, no foot slide and no obvious joint seams. A rig without usable motion does not pass.
2. **Doorway and camera correctness.** Reproduce the screenshot floor patch and the reported wall visibility, isolate their surfaces/camera poses, then repair them. Both entrances must work by keyboard and click, with continuous visible floor, no outside-world gaps in allowed views, no traps and correct return placement.
3. **Complete missing room treatments.** Inspect one finished doorway/trim corner and one bench against original museum reference before propagation. Confirm generated input → UV material → baked scene → browser output, not merely a successful image-generation job.
4. **Deliver the retro rendering pass.** Prototype its controls early, then integrate and judge them on the repaired scene. Match camera, actor pose and light for bypass/current/stylized comparisons; record native viewport dimensions and actual Godot process/render timing. Supply visible shader-off/on stills and walking/orbit footage that demonstrate the requested finish without crawl or lost artwork detail. Existing rAF-at-60-Hz results do not measure GPU execution or establish Mac M3 performance. An inconclusive result leaves this requirement open.
5. **Integrate one reviewable result.** Preserve access to all 23 paintings and existing interactions; run existing repository, gallery, rig and exported-browser checks. Supply a short continuous entry/walk/turn/doorway recording and full-room stills. Require visual acceptance of the integrated result; numerical contact tests or an older reviewer DONE cannot stand in for it.

The prior overnight report's own verdict remains **NOT YET**. This research narrows the next work; it does not claim the character, doorway, camera or rendering is fixed.

## Fresh browser evidence and storage constraint

Ran the existing `scripts/gallery-browser-check.cjs` against the exact supplied URL. First launch failed before navigation with `ERR_CERT_VERIFIER_CHANGED`; a second normal launch succeeded. All six existing UI checks passed: visible entrance, drag without accidental click, horizontal wheel both ways, other-wall switching, camera selection and lighting selection. [Raw result](2026-09-27-gallery-recovery-evidence/browser.json), [1600px still](2026-09-27-gallery-recovery-evidence/browser-start.png), [720px still](2026-09-27-gallery-recovery-evidence/browser-shell-720.png), and [short movement capture](2026-09-27-gallery-recovery-evidence/browser.webm) are saved. Both stills were visually inspected: plain white doorway recess, assembled-looking visitor and a visible outside-wall wedge remain apparent. This smoke test does not assert their visual correctness or isolate the reported floor defect.

This run used **Mesa llvmpipe software rendering**, with rAF medians about 83.3–83.4 ms and p95 100 ms. It is neither an RTX nor a Mac M3 performance measurement. Recorded errors include a 404, unsupported GLES3 2D MSAA and `arrow_cursor` metadata messages. No claim of a clean console, production performance, or motion acceptance follows from the UI checks.

After the owner's storage warning, live `df -h` reported Linux root **99% used, 15 GB free**, and Windows C: **100% displayed, 8.8 GB free**. The existing sysmaint report separately warns: “WSL root filesystem at 99%” and “Windows C: has only 8.8 GB free (WSL cannot grow its disk below this)”. Full archive download plus approximately 11.9 GB unpacking is unsuitable here.

The asset inspection transferred only bounded archive headers. Scratch occupies approximately **49 MB**: 1.9 MB allocated for the sparse header file (8.0 GB apparent length), 41 MB for the text member listing, and 5.9 MB for the server listing. No full archive, solid data block or model payload was downloaded; all archive requests are finished. The saved browser evidence occupies 3.3 MB, with approximately 12 MB of temporary browser captures also retained.

Read-only cleanup inventory found about 20 GB in `~/.cache/uv` and 25 GB in `~/.cache/huggingface`. These are candidates for a separate targeted cache review, not a license to remove environments or downloaded models. No project, worktree, cache or existing evidence was deleted. Continue with bounded metadata/small model retrieval; establish storage headroom before any large extraction or rebuild.
