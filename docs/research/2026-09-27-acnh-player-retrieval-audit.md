# New Horizons human source: retrieval audit for ticket 150

Checked 2026-09-27. This extends [the earlier source survey](2026-09-27-character-asset-sources.md); it does not claim a usable character or animation. The New Horizons authored human remains the first source to evaluate.

## Exact candidate and evidence

The [original ACNH 2.0.0 export author](https://www.reddit.com/r/ac_newhorizons/comments/qtmv3x/all_models_textures_ripped_for_acnh_200_daepng/) says the Switch-Toolbox export contains rigged COLLADA models and PNG textures, but **no animation clips**. The author publishes archive MD5 `4c42817aa486e124169ff721534eb2bc`. The [Internet Archive item](https://archive.org/details/acnh-2.0.0-models) identifies the 8,511,887,414-byte `ACNH_2.0.0_Exported_Model_DAE+PNG.7z`. The MD5 is source metadata; we have not computed it over a complete local archive.

I parsed the saved sparse 7z header at `/tmp/acnh-character-header.7z` using `7z l -slt`; its logical size is 8,511,887,414 bytes but disk use is about 1.9 MB. The corresponding full index is `/tmp/acnh-character-listing.txt`. The index verifies these precise members (uncompressed size; archive CRC32):

| Member | Bytes | CRC32 |
| --- | ---: | --- |
| `Model/PlayerBody.Nin_NX_NVN/PlayerBody.dae` | 494,520 | `1AA31D18` |
| `Model/PlayerHair00.Nin_NX_NVN/PlayerHair00.dae` | 135,124 | `5676DAF9` |
| `Model/PlayerBottomsPantsNormal.Nin_NX_NVN/PlayerBottomsPantsNormal.dae` | 96,833 | `8455BD92` |
| `Model/PlayerTopsTopTshirtsN.Nin_NX_NVN/PlayerTopsTopTshirtsN.dae` | 63,964 | `8EAA2F5B` |

`PlayerBody` also lists skin albedo/mix/normal, three cheek albedos, cheek mix/normal, nose albedo/mix/normal, paint albedo and sock albedo. `PlayerHair00` lists hair albedo/mix/normal. The shirt and pants geometry names are a **candidate component set**, not proof that their textures, skeletons, or joint names join correctly; clothing textures may live in separate `TopsTex*` folders. Archive CRC32 is an integrity field, not a SHA-256 of downloaded source bytes.

Direct per-member requests subsequently retrieved all four listed DAE files plus `PlayerBody/mSkin_Alb.png`. Each computed CRC32 matches its archive index entry. These are the computed SHA-256 hashes of the **downloaded bytes**:

| File | SHA-256 |
| --- | --- |
| `PlayerBody.dae` | `c56b5be056e686b1c7e2655ae2d689f0e0152f67ae87f29ae1634ec5d1a7087f` |
| `PlayerHair00.dae` | `61e48df34dc0ceb91c6fc355b04fee2e6873f5fc2e58ae4424531e45077d5bc6` |
| `PlayerBottomsPantsNormal.dae` | `2ef48a03aa704f2d269139fa1fb63f99c7f354ec0800807c5efd7eda94e5a10d` |
| `PlayerTopsTopTshirtsN.dae` | `14019bcd39ae39c5dc25130478dabc235c5a6c923223811515ecb2d671418123` |
| `mSkin_Alb.png` | `24ce132ea390875407eee37440cd43f221a2221272a71c9218d35df86e691baa` |

The direct [archive member route](https://archive.org/download/acnh-2.0.0-models/ACNH_2.0.0_Exported_Model_DAE%2BPNG.7z/Model/PlayerBody.Nin_NX_NVN/PlayerBody.dae) returned `PlayerBody.dae` after about 90 seconds; the other four requests took about 86–100 seconds. This replaces the earlier survey's 45-second timeout as the observed retrieval result. These five members total 802,935 bytes; no 2.66 GB block was downloaded. The PNG is a valid 384×384 image. The local copies are temporary inspection evidence, not committed runtime assets.

All four DAE files fall in the archive's third solid LZMA2 block. From the parsed 7z packed sizes, that block occupies archive bytes `5,850,552,258–8,509,980,675` (2,659,428,418 bytes). That is the **local 7z extraction** cost. Internet Archive's per-member URL did serve `PlayerBody.dae` after about 90 seconds, so the smaller direct retrieval route works and should be preferred before any block download.

XML parsing found 11 body geometries, 11 skin controllers, 46 `JOINT` nodes, UV and normal inputs for all 11 geometries, and 11 scene controller instances. The body skins reference 30 unique joints, including waist, spine, neck, head, both legs and arms. The pants file's 13 skin joints all share names and **identical inverse bind matrices** with body joints. The shirt shares eight such joints; its six skirt joints are additional. Hair has a separate `Root`/bangs/hair rig with no shared joint names, so its attachment to the body head needs an assembly check. All four DAEs have zero `animation` elements. This proves authored skinned geometry and a compatible body/pants/shirt bind pose at the XML level, while leaving hair parenting, material combination, appearance, and Godot import open. The DAEs omit explicit asset unit and up-axis tags, so orientation and scale need a measured import check.

The shirt and pants DAEs refer to `mTops_*` and `mBottoms_*` images that are **not in their geometry directories**. The parsed index lists separate `TopsTexTopTshirtsN*` and `BottomsTexPantsNormal*` folders. One concrete candidate is `TopsTexTopTshirtsNBorder0` plus `BottomsTexPantsNormalChino0`; selecting the actual appearance and verifying its texture maps remains open.

Blender 4.0.2 is installed here, but its `bpy.ops.wm.collada_import` operator is absent; a headless import attempt failed before any model data was read. Do not treat that tool failure as a defective DAE.

Godot 4.7.2's direct COLLADA import also failed in a fresh scratch project containing only the untouched `PlayerBody.dae` and its skin albedo. Its importer logged `!collada.state.visual_scene_map.has(collada.state.root_visual_scene)` and marked the scene import `valid=false`. A second fresh project with only the UTF-8 byte-order mark removed failed identically. XML inspection confirms the DAE does have a `visual_scene` named `Scene` and a `scene` reference to it, so the exact converter incompatibility remains undiagnosed. Godot's [scene format guide](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/available_formats.html) lists DAE support, but this file did not import here. This is a conversion gate, not evidence that the authored skeleton is absent.

## GameCube alternative

The [ACreTeam GameCube decompilation](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/README.md) requires the owner's game disc and explicitly ships no game assets. Its [keyframe definitions](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/include/c_keyframe.h) and [player draw implementation](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player_draw.c_inc) are evidence of an original articulated rendering path, not a ready DAE or GLB. No GameCube disc or extracted GameCube player model was found in the checked project ingestion and gallery worktree folders. This route is therefore a reference/contingency path, not a substitute for the selected New Horizons geometry.

## Rights and next gate

[Nintendo's content-sharing guidelines](https://www.nintendo.co.jp/networkservice_guideline/en/index.html) address gameplay images and videos; they do not grant this project permission to redistribute extracted model files. Permission remains unresolved, separately from whether the model can be imported. The converter's license cannot resolve Nintendo asset rights.

**Ticket status: open.** The four geometry files and one body texture are retrieved and hash-verified, and the body/pants/shirt bind pose is compatible at the XML level. The exact texture set, hair attachment, GLB assembly, and Godot Compatibility import are still unverified; direct DAE import currently fails. Retrieve only the chosen appearance's texture members, use a converter that demonstrably preserves skin and UV data, assemble an untouched GLB with its original skeleton, and record a visual/source proof before customization. The separate motion ticket owns finding clips.

## 2026-09-27 follow-up: bounded conversion and incomplete appearance proof

The direct DAE failure is **not a dead end for the authored mesh and rig**. A locally extracted Ubuntu `assimp-utils`/`libassimp5` 5.3.1 package ([upstream source](https://github.com/assimp/assimp/tree/v5.3.1)) read the unmodified `PlayerBody.dae` and exported glTF 2.0 binary with `assimp export PlayerBody.dae PlayerBody.glb -fglb2`. `assimp info` reported 11 meshes, 6,571 expanded vertices, 3,774 faces, 44 referenced mesh bones, and no animations. The exported GLB's JSON has 11 meshes, one 30-joint skin, inverse bind matrices, and `POSITION`, `NORMAL`, `TEXCOORD_0`, `JOINTS_0`, and `WEIGHTS_0` on its primitives. The different bone counts refer to per-mesh references versus the deduplicated skin joint list, not a missing skeleton. SHA-256 of the local body GLB: `5acbd131a012581bed1ae7fee8d158d2bd27e7784d37c1c368592bae4f4e803c`.

A fresh Godot 4.7.2 **Compatibility** scratch project imported that GLB; `load()` returned a PackedScene with one `Skeleton3D` (30 bones) and 11 skinned `MeshInstance3D` nodes. Missing external image references logged warnings, so that import proves mesh, UV, weights, and skeleton structure, **not material fidelity or playback**. This follows [Godot 4.7's preferred glTF 2.0 interchange path](https://docs.godotengine.org/en/4.7/tutorials/assets_pipeline/importing_3d_scenes/available_formats.html). No runtime project file or accepted character asset changed.

The same converter read the three other verified DAEs. In a temporary Blender 4.0.2 scene, their source meshes, UVs, weights, and separate armatures were retained; the hair armature was attached at the body head bone's rest transform. A trial combined GLB imported in Godot with 15 meshes and three skeletons (38, 13, and 14 bones). The body and hair join the 38-bone armature; pants and shirt still have separate armatures. This is **structural import proof, not motion-safe assembly**: shared body/clothing bind matrices from the preceding XML audit do not prove that three rigs will animate together. The trial GLB SHA-256 is `6023c7d613ebbefdccaca72143eda11ce66e42425fad3c2401578f0853dd1a3d`; it stays in local scratch, outside the runtime and this branch.

Individual members of the [original archive](https://archive.org/details/acnh-2.0.0-models) supplied a matching `PlayerHair00/mHair_AlbGry.png` (SHA-256 `bbb893b19e1cf0e3106c2744617104c5697f608df90fa6d2707025591f993234`) and `BottomsTexPantsNormalChino0/mBottoms_Alb.png` (`473c6b707af05675e23789843786f412920f51a0c56e618d7d1a58cde06a1d67`). The body cheek, nose, and orange-sock albedos were also retrieved and are available in local scratch. All five retrieved albedos matched their exact archive member size and CRC32. The selected `TopsTexTopTshirtsNBorder0/mTops_Alb.png` request returned HTTP 504 twice; no file was saved. The DAE also names `mEye_Alb.0.jpg` and `mMouth_Alb.0.jpg`, but neither exact name appears in the archive member index. This does not prove that the game lacks those textures; it means this exported archive does not supply them under the paths the DAE expects. The assembled render is visibly incomplete: the face is black, the shirt has a placeholder color, and missing normal/mix maps were not assessed. [The inspected render](2026-09-27-acnh-incomplete-assembly.png) records that failure, not an approved look.

**Next decisive gate:** locate source-compatible eye/mouth appearance data, retrieve one matching shirt albedo without a bulk archive download, and bind body/pants/shirt to a single proven animation route while preserving the six extra shirt skirt joints. Then inspect a textured front/side/back render and a Godot Compatibility movement capture at gallery scale. The source geometry remains primary; no generated substitute or GameCube replacement was introduced. Nintendo asset redistribution permission remains unverified. Research spend: USD 0.
