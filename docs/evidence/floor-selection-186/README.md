# Exact lighter floor selection — #186

![Owner selection](selected.png)
![Native close-up](native.png)

The upload exactly matches `docs/evidence/world-176/integrated/details/bench.png` from runtime c614b5ed (SHA256488e207d35b839603ee3d35cf1630f62a23bc800f4a03eadba61c862237b4a3f). It selects the pale detailed board atlas and1.9×0.36 herringbone layout, superseding #177's warm floor only. Current slimmer couch, textured walls, portal and visitor remain. The 3D Viewer is unchanged.

Only Surface000 receives the selected floor mesh/material. Shared plank edges are conformed to preserve the later browser gap repair; the edge check passes with zero unmatched interior edges. Its interior check excludes the perimeter border overlay at y=0.002. Lighting UVs are verified against the same continuous world-space mapping and the existing EXR/LMBake hashes are unchanged. The floor remains an unshadowed planar receiver; no lighting bake or new paid generation was performed. `restore.gd` takes the saved c614b5ed room scene as its argument; `lightmap-before.sha256` verifies retained lighting assets.

Repository and private source checks pass (existing ObjectDB shutdown warning retained). Native close-up inspected: larger light boards with grain and intact current couch. The separate doorway pop remains diagnosed in #185; this floor selection does not repair transitions.

## Verified full application

![Applied floor in Collection](browser/bench.png)

https://windows-wsl.taile06c45.ts.net/risd-selected-floor-01a0ee18/

Runtime `a7a2a52d`. Browser bench/floor screenshots inspected against the selected screenshot. Real key movement/release, fixed FOV, retained visitor identity and23paintings pass; errors array empty. Browser loads at800×600 then captures at1080×1080 using SwiftShader. Export has no ERROR lines. HTTPS index and served game gzip verified; SHA256 `9233063ea999b3fa27162a01317edf54a41589634ec602a82c304d48c4157458` matches the local archive. Final hands-on approval remains the owner's.
