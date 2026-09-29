# Floor continuation against current architecture — #168

Candidate only; not integrated or visually accepted.

The prior floor candidate is af3eb976. Its existing capture-tool changes were preserved in f3d3d162 before resuming. The gallery source, selected visitor, portal cutaway and architecture bake were reconciled from build c9d2985c (runtime 4779e528). The selected floor geometry, local board UVs, atlas and shader remain from af3eb976. The gallery shader is now floor_oak.gdshader, preserving the separate oak.gdshader used by the portal transition. Bake preparation removes authored RGB occlusion while preserving the alpha channel used to select atlas faces.

Current architecture source, hashes, provider/cost and reviews remain recorded at [c9d2985c](https://github.com/Reid-Surmeier/risd-godot/tree/c9d2985c/docs/evidence/architecture-167). The floor atlas provenance and prior visual review remain in this directory and image-work/floor-168-board-v2. No new generated image or paid call.

Import, scripts/check.sh and owner_repair_check.gd passed before baking. A fresh bake and native/Web image-only review remain required. The wall and skylight gates remain open.

## Rebake and initial checks

Godot 4.7.2 bake returned exit 0, 127 users, 333.56 seconds. Its editor logged a list erase condition and get_node outside-tree error during shutdown; a subsequent fresh import, native capture and export completed without errors. Repository checks and whitespace passed after bake. This is technical evidence only; independent review and browser checks are pending.

- `room.tscn` SHA256 `4f88dd6f63b4d0988676370d84dbaafebc3753236c93444f6d14f3a280affaaf`
- `room.exr` SHA256 `dcf72860e9192a049e0e5bb143ffaedebfe8c8df4e5ec8f761acada813e3b5b3`
- `room.lmbake` SHA256 `c5bd899fe946ddbaa47df032f8dbd98b9d7e6111b2c2c162057c7f3f31e8cc97`

## Current outcome: rejected

Both native sizes and exported-browser sizes completed; browser errors were empty for before and after. The independent image-only review failed close-detail grain; matching browser-before images preserve frame identity, while native-before import/capture discrepancy remains unresolved. Exact review and all images are in [current-architecture/](current-architecture/). No build integration or issue closure. The earlier floor pass does not override this current review.

Next bounded repair: inspect a source-backed board input with irregular grain/pores and localized variation before another bake. Repeating broad colour/UV tuning on this fine-line atlas is not sufficient evidence. Resolve the native control difference with the same import settings before attributing any painting regression. No new paid request in this continuation.

## Controlled native baseline

Re-rendering exact c9d2985c geometry/materials/lightmap inside the candidate's imported project (then restoring the candidate files) produces the same smooth layered left frame as both browser packets. The earlier before-native came from the build cache, whose frame imports disable compression/mipmaps; the candidate's imported frames use compressed mipmaps. Texture bytes, resource paths, frame mesh bounds and transforms are equal. The apparent frame change is a capture/import confound; no frame pixels or geometry were changed by the floor pass. Original images remain retained alongside before-native-controlled. Navigation passes23 paintings; cutaway floor/coverage passes49.9895%.
