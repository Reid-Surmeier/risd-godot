# Doorway-only transition — #167

Cutaway10's broad alpha fade failed visual readability. Candidate11 scopes interpolation to masonry group8, resolves orbit masks immediately, uses native alpha-hash coverage for the remaining entry/return transition, and keeps masonry hidden at side-on passage angles. No image, geometry or lightmap change; no paid generation. Private native floor/transition/orbit checks and repository baseline pass. Browser numeric movement passed at 1600/720: 236 samples with FOV23 and visitor visible, zero errors. Independent image-only review FAIL for doorway continuity: wall dims then abruptly disappears. Containment, floor repairs and removal of orbit overlays PASS. Not integrated.

Godot material reference: https://docs.godotengine.org/en/stable/tutorials/3d/standard_material_3d.html#transparency describes alpha blending's overlapping-surface sorting limits and alpha-hash dithered coverage. This documents the choice; actual native/browser images remain the acceptance evidence.

## Independent motion review

Reviewer owner_camera_skylight_review inspected all eight stills and samples spanning both complete clips, including 5fps entry sampling. Visitor stays visible and consistently framed. Black L-shaped floor patches, raised-looking planks, striped ghost arches and gray planes across the visitor are absent. Entry still dims and removes the wall abruptly; return restores it. This does not approve character design or prove every frame.

## Diagnosis

Fixed-position opacity captures reproduce dimming without coverage loss with Alpha Hash in the Compatibility renderer. Godot upstream issue https://github.com/godotengine/godot/issues/103094 documents this missing implementation. Ordinary alpha blending reveals overlapping internal surfaces. Candidate12 tests opaque screen-space discard, preserving depth writes and existing texture/lightmap inputs. No rebake or generation.
