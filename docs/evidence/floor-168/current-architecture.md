# Floor continuation against current architecture — #168

Candidate only; not integrated or visually accepted.

The prior floor candidate is af3eb976. Its existing capture-tool changes were preserved in f3d3d162 before resuming. The gallery source, selected visitor, portal cutaway and architecture bake were reconciled from build c9d2985c (runtime 4779e528). The selected floor geometry, local board UVs, atlas and shader remain from af3eb976. The gallery shader is now floor_oak.gdshader, preserving the separate oak.gdshader used by the portal transition. Bake preparation removes authored RGB occlusion while preserving the alpha channel used to select atlas faces.

Current architecture source, hashes, provider/cost and reviews remain recorded at [c9d2985c](https://github.com/Reid-Surmeier/risd-godot/tree/c9d2985c/docs/evidence/architecture-167). The floor atlas provenance and prior visual review remain in this directory and image-work/floor-168-board-v2. No new generated image or paid call.

Import, scripts/check.sh and owner_repair_check.gd passed before baking. A fresh bake and native/Web image-only review remain required. The wall and skylight gates remain open.
