# Reuse the character mesh and transfer Muse's appearance

Research requested September 30, 2026 after the owner reported a large difference between the Muse reference and the 3D texture. Context: [Muse-to-3D character prototype](https://github.com/Reid-Surmeier/risd-godot/issues/231) and [the asset map](https://github.com/Reid-Surmeier/risd-godot/issues/226). No paid calls, texture edits or asset generation were performed by this investigation. The root owns the shared ledger; its current remaining authorization is **$2.46 of the $4 aggregate cap**, subject to final receipts and unknown liabilities. The owner's latest priority is posing, rigging, motion and effects; the texture comparison comes afterward.

## Recommendation

**Keep the existing mesh, UVs, skin and animation. Later compare its current color with a Blender projection of the accepted Muse pixels onto that same mesh.** Use matching front/profile/back views, visibility masks and a saved camera calibration. This is a texture change, so it does not require regenerating the whole character. Direct projection offers explicit control of where the visible pixels land; guided AI retexturing interprets a reference and can still change facial details.

The prototype issue reports 7,719 triangles, UVs, 24 bones and four clips, with separate raw and derived materials. It also reports idle floating and walk floor penetration. Those are existing observations, not independently repeated tests in this research. The texture investigation should retain those geometry/rig artifacts while the motion investigation fixes grounding. [Dated pilot evidence](https://github.com/Reid-Surmeier/risd-godot/blob/84768b81808d71cff1d3fcddeaba9533e4d1b044/docs/research/character-pilot-results.md).

## A render is not a UV atlas

A character image maps surface points into camera pixels and contains only the visible surfaces. A UV atlas maps every intended mesh surface into a texture. Unwrapping the existing **mesh** provides those UVs; unwrapping a single Muse image cannot reveal its hidden surfaces or uniquely recover its camera/depth. This distinction follows from the documented projection and UV workflows below. The proposed method is camera projection followed by UV baking, not recovering original Nintendo UVs.

Alignment is the practical constraint. If Muse's arms slope differently from the mesh, eyes sit at a different height or horns have a different outline, direct projection produces stretched features, background spill or gaps. First align each view's camera and character pose; use local image warping/masks for modest mismatches. If the silhouette differs substantially, a texture cannot repair the geometry. Matching every pixel from one camera can also degrade side views; assess the whole turntable.

## Native Blender projection routes

Blender's texture-paint **Quick Edit** captures a view for external editing; **Apply** projects the edited image back onto the object, and **Apply Camera Image** projects an edited camera render. The same documented options include geometry occlusion, backface culling and seam bleed. These are an existing native workflow for a later Muse-assisted paint pass: export a calibrated view of the actual mesh, let Muse edit its appearance while preserving the silhouette, then reproject. Its view capture must remain the same size, pose and camera. [Official manual source: texture-paint options](https://projects.blender.org/blender/blender-manual/src/branch/main/manual/sculpt_paint/texture_paint/tool_settings/options.rst).

For repeatable saved scripts, **UV Project** writes a chosen UV map from projector objects, including orthographic or perspective cameras. Multiple projectors select per face by alignment; low-poly perspective projection has known interpolation limitations. Use a temporary named projection UV layer, preserving the existing final UV layer. The modifier does not supply occlusion-aware multi-image compositing by itself. [Official manual source: UV Project](https://projects.blender.org/blender/blender-manual/src/branch/main/manual/modeling/modifiers/modify/uv_project.rst).

Proposed later comparison, without a new mesh:

1. Duplicate the accepted material and texture, keep the mesh in the chosen matching pose, and save front/profile/back cameras. Mask out background, accessories/parts that occlude other surfaces and features absent from a given view.
2. Project the matching reference onto visible surfaces. Use front for the face/front clothing, rear for rear clothing, and profile where it has useful unoccluded information. Keep the prior color as a fallback for uncovered undersides; do not project the front face through the back of the head.
3. Composite masked projected color in a temporary material, then **Emit-bake into the original final UV layer** and a new atlas. This preserves the skin and geometry. Camera-based UVs are a transfer aid; they are not the exported runtime UV layout.
4. Reopen the saved atlas on the unchanged skinned asset; inspect front/side/back, moving shoulders and UV seams with matched lighting and camera before judging fidelity. Preserve current materials as the comparison control.

Cycles baking requires UVs and an active target Image Texture node; Emit bakes material emission, while Diffuse with only Color excludes direct/indirect lighting. These provide a native image-to-final-UV transfer. A source render may already contain highlights/shadows: Emit baking retains those source pixels rather than separating physical albedo. Prefer neutral/color-only source views, and compare unlit or equal lighting before blaming the texture. [Official manual source: Cycles bake](https://projects.blender.org/blender/blender-manual/src/branch/main/manual/render/cycles/baking.rst).

These stages are a proposed implementation, not a tested projection of this pilot. Use the existing Blender MCP stage scripts and native Blender jobs; no new paint library or orchestration framework is needed. The official manual HTML was inaccessible during research, so its first-party repository source was retrieved directly.

## What Muse can contribute

Muse can edit a calibrated render, supply matching views or paint a UV-layout guide. Its saved local edit procedure keeps ordered PNG references, input/prompt hashes, one output and a separate review state; it does **not** guarantee exact output size, deterministic seed or exact pixel preservation. [Maintained Muse procedure](/home/reidsurmeier/Image-generation-pipline/procedures/muse/README.md), [OpenRouter model contract](https://openrouter.ai/meta/muse-image).

Blender exports a UV layout as an image guide for texture painting. [Official UV-layout documentation](https://docs.blender.org/manual/id/5.0/addons/import_export/mesh_uv_layout.html). Asking Muse to paint that guide is possible, but **correct island correspondence and seamless edges remain unverified**: the checked Muse contract is general image editing and supplies no mesh/UV constraints. A stretched head island is harder to interpret than a front render; a shifted eye crossing an island edge becomes a runtime defect. Treat a full AI-painted atlas as a later experiment, not the first standardized route.

Recommended Muse role: start from the actual mesh's calibrated color render, with the accepted turnaround as identity reference. Request appearance-only repair with the exact camera, silhouette, feature placement and canvas retained; inspect and align the output before projection. Do not assume that asking for preservation establishes it. For crisp facial features and clothing markings, deterministic local compositing of accepted reference patches may be more reliable than another unconstrained generation; this is a proposed comparison.

## Exact current fal/Meshy retexture contract

Unpaid live fal model search (`q=meshy`, all returned entries, `has_more: false`) found only **`fal-ai/meshy/v5/retexture`** as Meshy retexturing. It accepts existing `model_url` (GLB/glTF/OBJ/FBX/STL or data URI), `image_style_url` or `text_style_prompt`, `enable_original_uv` (default true), `enable_pbr` and safety checking. Image guidance takes precedence if both style inputs are supplied. It returns a model and texture files. This is image-guided texture generation, **not a promise of exact pixel projection**. [fal schema](https://fal.ai/models/fal-ai/meshy/v5/retexture/api).

The authenticated unpaid pricing API returned HTTP 200, **$0.30 per generation**, matching the public request-price page. However the official endpoint page states **deprecation on October 1, 2026**. Guessed `meshy/v7.1/retexture`, `meshy/v7/retexture` and `fal-ai/meshy/v6/retexture` pages returned 404 during this investigation; no supported successor fal route was established. Do not build the standard pipeline around tomorrow's deprecated v5 route or infer that the warning names a callable replacement. [fal price and deprecation](https://fal.ai/models/fal-ai/meshy/v5/retexture), [pricing API](https://fal.ai/docs/platform-apis/v1/models/pricing).

For a deliberately chosen, still-available single v5 trial, the checked request shape would be:

```json
{
  "model_url": "<existing unrigged mesh GLB URL or data URI>",
  "image_style_url": "<accepted Muse front PNG URL or data URI>",
  "enable_original_uv": true,
  "enable_pbr": false,
  "enable_safety_checker": true
}
```

This is research documentation, not a submission or recommendation to spend before motion review. Using the already-derived rigged file as a vendor round-trip is unnecessary: prefer the existing unrigged source as input and transfer returned color onto the retained rigged mesh if UV correspondence passes checks. The schema supports applying textures to existing geometry and retaining UVs; it does **not** guarantee preservation of skins, bone hierarchy, animation, vertex ordering or byte-identical geometry. Hash the original arrays and validate output positions/indices/UV correspondence before any texture swap. If UVs changed, bake the returned appearance back to the retained mesh; keep its current skin/clips.

Meshy's direct upstream retexture API has `model_url`, `image_style_url`, optional UV reuse, model selection and resolution. Its documented multiview guidance requires explicit **`ai_model: "meshy-7"`** and cannot be mixed with single-image/text guidance; rollout may differ by account. Retexture's current `latest` is documented as Meshy 7, distinct from generation's Meshy 7.1. Geometry/reference mismatch reduces image-guidance quality. These upstream controls are **not present in the checked fal v5 wrapper**. [Direct retexture contract](https://docs.meshy.ai/en/api/retexture). Meshy describes retexture as updating textures without rebuilding the mesh. [First-party workflow guide](https://www.meshy.ai/tutorials/image-to-3d-model-complete-guide). Direct Meshy paid use is outside the current fal/OpenRouter exception and was not executed.

## Decision and evidence still needed

Continue the owner's motion-first investigation on the one retained mesh. The next texture experiment should be **local masked projection into its existing UV**, with matched renders and the current texture as a control. AI retexture is an optional second comparison only after a supported endpoint and exact reservation are verified. UV painting by Muse comes after explicit island/seam checks establish it is useful.

Pass criteria: recognizable eyes/headwear/clothing at gameplay size, no front design accidentally repeated on the back, no new background pixels, no seams or stretched markings, and identical geometry/UV/skin/clip inventory for the material-only result. A texture win does not settle foot contact, joint deformation or animation timing. This note establishes documented routes and their limits; it does not claim that projection or retexturing has solved this character.
