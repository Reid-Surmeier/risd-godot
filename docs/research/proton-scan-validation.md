# Proton scan candidate audit — Issue #154

27 September 2026. [Issue #154](https://github.com/Reid-Surmeier/risd-godot/issues/154) asks for verification of four source triplets and their existing GLBs. [Map #149](https://github.com/Reid-Surmeier/risd-godot/issues/149) calls for four live scans and sixteen thumbnail-only entries in a 5×4 catalogue. No candidate was regenerated or moved into the game.

## Result

All four local OBJ/MTL/JPG triplets match their recorded SHA-256 hashes. Their selected GLBs match the manifests, carry 119,999–120,000 triangles and an embedded JPEG Base Color texture, and import through Godot 4.7.2 as one textured mesh. Existing source/reduced captures show no obvious decimation loss at four angles. None needs reconversion for polygon count or material preservation.

The candidates are **not visually accepted in the game**. The initial camera shows the back of two models, all four look much darker than the shipped Buddha in available captures, and no comparable Godot candidate captures exist. Human object identities and departments remain unverified.

![Four source/reduced orbit comparisons, source left and GLB right](proton-scan-validation/source-vs-glb.png)

The sheet uses 32 existing 512×512 Blender renders in the four manifests. Every render hash was independently recomputed. The [Buddha Godot capture](../evidence/sculpture-viewer/01-viewer.png) is a visual baseline, but its lighting/framing differ; this comparison cannot prove in-game parity.

## Local files and hashes

Sources are at /home/reidsurmeier/risd-godot-ingestion/proton/<ID>/<ID>.obj, .mtl and .jpg. Selected GLBs and manifests are in each ID's candidate-120k directory, except 20260811121459/candidate-120k-rerun and 20260820133334/prototype. The original first 20260811121459 candidate also passes structural checks, but has a different GLB hash (cac3f6f0a7e02d79c7666ad68344331d97bb800a0d80ee31d3c4f4e0f8a73839). The rerun hash is the explicit choice here.

| Source ID | OBJ SHA-256 | MTL SHA-256 | JPG SHA-256 |
| --- | --- | --- | --- |
| 20260811121459 | ccb7bf5347add65d7c152e2675f7565e97d879b6cc0be9414c4ddc1f2766e4ed | 3b86d45f9070e7e90ad0a07b7e7869b956a2212f8fb1737dee73eca8a34ed61b | 08e09af5f7560322ed86d1f6d5c27cad78a49fde19ee11a2254e2ced7e371bf9 |
| 20260811122415 | 9f5fda816915b8e02620f64da22450158f683b05e24014fde9732141416f1d48 | d1bea301850754678ffb2a297411fd6d75c062fc1fcbd1a498d6ed0b12554557 | 61914b89aa686765d9cf92ce994b66193d42e4e3493e3a4e467278887af2b2ea |
| 20260811123051 | bd8b66a479d9f7c6dacbb36cd3b2db4c081f01af0f1fff77685a8196a55a6a71 | 7363cb9574afed80bb8ae95c7f312f11064369544201e0bb2dfa529529c37ea6 | fb25726c8e7c2ceda0c007d6e30e183989c020a0524b8a60ee159a5b7da3162c |
| 20260820133334 | af49afcfecff54f7715b3c15872252e96cfb51c8d8eca48755f8a080db913f1e | 4b1479cd567f2aeb354b06c4c36f3c148d4b920a52a6141f6879b35a733f3265 | 95c778b9c52f8eaa73e89aa3b1f72c34b37026dceb3583b99a436b8bf036e8ab |

Every 104-byte MTL declares _texture and map_Kd <ID>.jpg. [Earlier read-only Proton inventory](https://github.com/Reid-Surmeier/risd-godot/blob/de67e90fd80e7faaa85df2526fa42027cc32cb74/docs/research/painting-and-proton-sources.md) recorded matching cloud sizes; this audit did **not** re-query cloud revisions. This check proves local-byte-to-manifest integrity. All recorded source, GLB and render hashes were recomputed.

| Source ID | Selected GLB SHA-256 | Bytes | Triangles | Godot AABB size X/Y/Z | Embedded JPEG |
| --- | --- | ---: | ---: | --- | --- |
| 20260811121459 | 86c2c80bc05489b12bec1a03216d8765c66baaf3f8f89cf1f018004cba152193 | 4,785,248 | 119,999 | 4.502 / 3.733 / 4.109 | 2048×1960 |
| 20260811122415 | da7480355f1c384ed8588e44cd2f1bf9c666d03c2bd7a9017f958f3d5ee08a41 | 4,822,044 | 119,999 | 2.962 / 4.500 / 2.631 | 2048×1989 |
| 20260811123051 | faaece8dd2b1b25f6d2a7d96671db37ea810ede3bdc5441099f18f96ffc50d74 | 5,596,984 | 119,999 | 4.499 / 4.345 / 2.813 | 2048×1962 |
| 20260820133334 | 94e634a0554b6925fe26be4bbe5b3df2e53a19088883e733f4f9bcffed626d9e | 4,239,608 | 120,000 | 2.574 / 4.500 / 2.536 | 2048×2012 |

Parsing each GLB header and JSON/BIN chunks found one indexed triangle primitive with POSITION and UV attributes. Counts above are index accessor counts divided by three. The one buffer has no external URI; image 0 has bufferView 4, image/jpeg and no URI; material Base Color texture 0 resolves through texture 0 to image 0. These fields prove the GLB embeds its texture. The [glTF specification](https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html) defines those structures, Y-up coordinates and meter units. The embedded JPEG is resized, so it is not byte-identical to the source JPG.

A separate temporary project used Godot 4.7.2 [GLTFDocument.append_from_file and generate_scene](https://docs.godotengine.org/en/stable/classes/class_gltfdocument.html) on each GLB. All four returned OK and produced one MeshInstance3D, one surface, an active material and a non-null albedo texture at the dimensions above. This does not exercise the actual game viewer, export or network loading. The [current viewer loader](../../modules/sculpture_viewer/viewer.gd) still hardcodes Buddha and its separate JPG. The shipped Buddha GLB hashes 3944df2113c8f642a103e3609d9a6f92671ca5e2ea59d69616521a975ab273e9, matching [module provenance](../../modules/sculpture_viewer/PROVENANCE.md).

## Orientation and visual quality

All candidate node transforms are identity, Y is vertical and the lowest Y is about zero. The converter's 4.5-unit target is the **longest extent**, not always height. At 0°, 20260811121459 shows the back of a sculptural group and 20260811123051 shows the back of a bust; recognizable fronts are near 180°. The relief in 20260811122415 is visible at 0°, and 20260820133334 gives a usable three-quarter front at 0°. A per-model yaw is needed before first-row use. This can be a viewer setting without changing the GLBs.

Source/reduced pairs retain silhouettes and material appearance at all four angles. Normalized RGB RMSE across 0°, 90°, 180° and 270° is 0.00759–0.00837, 0.00490–0.00759, 0.01267–0.01570 and 0.00498–0.00769 in table order. The third scan has conspicuous cyan flecks and missing lower-body areas in **both** source and reduced renders. The second and fourth show bright white wedges at 270° in **both**. These are source-present artifacts, not evidence of decimation failure. All four are darker than the Buddha baseline. Comparable in-game captures, framing, lighting and owner visual acceptance remain open.

## Identity, department and sixteen thumbnails

The four stable technical identities are proton-scan:<ID>. Files and manifests contain no museum accession, human title or department. The [old viewer capture](../evidence/sculpture-viewer/01-viewer.png) includes visually similar labels “Child with Skulls”, “Seated Figure Relief”, “Bearded Figure Bust” and “Seated Marble Figure”; resemblance does **not** establish a file-to-record link. [Prototype #81](https://github.com/Reid-Surmeier/risd-godot/issues/81) also kept 20260820133334 provisional. Use Scan <ID> until an authoritative museum record links each file to a title and department.

The current [panel](../../modules/sculpture_viewer/assets/setup/panel-2x.png) is a single 40-item raster (SHA-256 d6cdb4c2c3ff042ea3380868184d297ea608f733bd377723cc71fd792f5b99d5). The [desktop](../../modules/sculpture_viewer/desktop.gd) overlays hover art on 18 cells, but has no per-item ID, department, separate thumbnail path or 5×4 selection. To identify sixteen specific image-only candidates without inventing museum metadata, use original panel cells **5–17 and 19–21**: bust, bowl, bull, pale bowl, dark curved object, colored bust, standing figure, guardian lion, small dark figure, rider, dancing figure, standing figure, terracotta figure, mask, blue stone and bird. These descriptions identify the pixels, not museum objects. Cell 18 depicts the existing live Buddha, so classifying it “3D unavailable” would be false.

That list is a **provisional selection from the panel**, not an accepted catalogue order or verified metadata inventory. Four truthful scan thumbnails, Buddha placement, the final sixteen picks and any displayed museum names/departments still need a content decision. The raster itself cannot serve as sixteen independently selectable catalogue records.

## Remaining checks before closing #154

1. Capture all four GLBs in the actual Godot 4.7.2 viewer beside Buddha at matched camera/light settings. Inspect front, side and back; record yaw and framing.
2. Link each scan ID and chosen thumbnail to an authoritative collection record if a human title or department is displayed. Otherwise retain provisional names and no department.
3. Resolve the final sixteen thumbnail-only entries and Buddha placement, then verify real 5×4 rows.

No paid action, source modification or candidate regeneration occurred. The large source and GLB files stay outside the repository; this report and sheet are review evidence.

## Verification record

Local audit: Python SHA-256 of all twelve sources, five candidate GLBs, five manifests' listed outputs and forty source/reduced render paths; glTF JSON/BIN inspection; normalized RGB RMSE of the captured pairs; Godot 4.7.2 headless GLTFDocument scene/material probe. The first scripts/check.sh invocation failed because this fresh worktree lacked generated Godot resource imports; godot --headless --editor --import --path . exited 0, then scripts/check.sh exited 0 with “checks passed” and an ObjectDB leak warning. git diff --check exited 0. No runtime assets were changed.
