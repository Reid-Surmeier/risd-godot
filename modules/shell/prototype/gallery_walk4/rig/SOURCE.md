# 3D visitor provenance — #139

Kay Lousberg, KayKit Adventurers Character Pack 1.0, CC0 (included LICENSE.txt).
Source revision: `672074b73ba276876a19e8816ecdc5241817ab47`.

[Original Rogue.glb](https://raw.githubusercontent.com/KayKit-Game-Assets/KayKit-Character-Pack-Adventures-1.0/672074b73ba276876a19e8816ecdc5241817ab47/addons/kaykit_character_pack_adventures/Characters/gltf/Rogue.glb)

Original SHA-256: `e825437cd4d2ee9c1960b517a74a69101e33eb409ae7fa8cedc7134a998fbb7d` (3,616,284 bytes).

`prepare.py` checks this hash, removes weapons/cape, joins the six body meshes without changing their skin weights or texture, and exports only Idle, Walking_A and Interact. Blender 4.0.2, glTF 2.0. This is a licensed 3D asset derivative, not generated pixels. No Muse/Seedance call or new spend. Original experimental sprite provenance remains intact; `?character=sprite` selects that comparison.

The runtime uses actual-distance gait, a smoothly turning 3D root, two-bone leg correction and native head/hand poses. Boot toes retain the supplied idle pose while feet contact the floor; retaining authored toe flex after forcing a flat boot caused measured mesh penetration, so that conflicting rotation is not layered onto the contact solver. A small constant knee reserve allows idle/walk blending without stretching legs.

LightmapGI probes contain indirect illumination only. The gallery and white navigation space have separate offline captures. No live lights/shadows are introduced. A bounded albedo multiplier of 1.6 compensates the indirect-only exposure while retaining spatial probe response; this is an art-direction adjustment, not a reconstruction of direct lamp illumination. A contact blob follows the visible footprint. The mesh sits 0.18 world units behind its navigation anchor at floor height; this aligns the initial screen baseline without changing the camera. Stationary direction changes use a turn-driven stepping cycle rather than dragging an idle pose. No claim of final Animal Crossing character identity or exact console rendering.

Derivative SHA-256: `dcedfffbe3576b8bb6d279dc0e51b35cebb1f9890c7aea20c579587d13cd35d2`. Two independent executions produced the same bytes (364,020 bytes; 4,263 triangles, one mesh/material, 41 bones, three clips).

Godot extracts the embedded unchanged atlas to `visitor_rogue_texture.png` (16,670 bytes); that texture and its importer settings are included because the imported scene references it. No texture repaint or generation.
