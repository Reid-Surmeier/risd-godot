# #174 selected visitor — private runtime asset

`visitor.gd` loads the source-preserving Hair36 model and a KayKit motion donor.
The inherited Collection room, paintings, picking, navigation and detail view
remain in `walk4.gd`.

## Rights and runtime inputs

The Hair36 body and textures are Nintendo-derived. These files are tracked only
to make this private educational repository buildable. This does not grant a
license or permit public redistribution, release or public hosting of the asset
or any export that contains it. The repository and preview remain private.

| Input | SHA-256 | Source |
| --- | --- | --- |
| `inputs/character.glb` | `a2e6e0948dafb5b0ac10ffdc7359c64fbe04371038f0265d9cb1e1af390e54c4` | #163 Hair36 static candidate, report `cf4a17ae` on `prototype/163-character-materials` |
| `inputs/character_risd-163-eye-baked.png` | `76c7f742c5762955f20ec2b73b6e3e8cd67be16b5d60544e51de457ba5aa233e` | #163 Hair36 face-material repair |
| `inputs/character_risd-163-hair36-source-tinted.png` | `3343dfb6121696acf2e684ffd24b5a1f3bc7553721ca01ccb774ba407cb3499c` | #163 Hair36 source tint |
| `inputs/character_risd-163-mouth-baked.png` | `c0df1123ec60316f19af09ca7c77018b35f149c52e4c4f7372d2fb138169f0b1` | #163 Hair36 face-material repair |
| `inputs/character_risd-163-shirt-baked.png` | `98088aa8132b11367d6f249b29d6e936438e7dd4e1bca29345e72fcf003737a2` | #163 Hair36 clothing-material repair |
| `inputs/donor.glb` | `e825437cd4d2ee9c1960b517a74a69101e33eb409ae7fa8cedc7134a998fbb7d` | KayKit Rogue, pinned upstream `672074b73ba276876a19e8816ecdc5241817ab47`, CC0 |

The four repaired Hair36 textures are embedded in `character.glb`; the two GLBs
are the files loaded at runtime. KayKit's `Idle` and `Walking_A` clips provide
non-authentic fallback motion only. The target keeps the selected Hair36
geometry, UVs, weights, skeleton and source identity. The gesture API always
returns false; no interaction or artwork-pointing gesture is implemented.

Source acquisition, texture repairs and original source hashes are documented
in #163 and `docs/research/2026-09-27-acnh-authored-hair-source.md` on that
branch. Transfer, blending and foot-contact corrections adapt the earlier
prototype; they do not make the motion authentic Nintendo animation.

## Verify

After a clean clone, run `godot --headless --editor --path . --import`, then
`scripts/check.sh` and the native/Web acceptance captures in
`modules/shell/playtest/visitor174_check.gd`, `visitor174_capture.gd` and
`visitor174_browser.mjs`. Do not publish this private runtime asset in a public
build.
