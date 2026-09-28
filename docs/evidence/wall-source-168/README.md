# #168 documented wall-source replacement, 2026-09-28

Throwaway branch `research/wall-source-168-20260928T0830`, based on `f0099b60`. The [source audit and reproducible recipe](../../research/2026-09-28-wall-source-168.md) replace the untraced `wall.png` with a restrained transform of the fully recorded Muse wall output. New texture SHA-256: `08f8bcd7522d1228016bae304085a66b1f6e223291425b68ceac0d025d56d769`. Godot 4.7.2 produced a fresh saved-room scene `2078ff59038d757482a1af82d25c991ea58a48c2b3a77879da6d259cfe8063c8`, EXR `f06fc21c8431209a697be5e882dbd556aec3235e1986ea69704f9985a4fd7a21`, and lightmap `1d107421a3d5ae70813d438c72cd83b73a09dc8f52015d53cbb39a3702230c8b`. The floor candidate from the parent prototype branch is unchanged.

[Reference photographs](reference/), [prior accepted native](before-native/) and [browser](before-web/) wall, and the new [native](native/) and [exported-browser](web/) 720/1600 square captures are inspectable in the [comparison page](index.html). Browser errors on the correct isolated prototype export were `[]`. The first attempt incorrectly exported the normal game pack; its browser captures were loading screens, and an independent reviewer failed that packet. Those captures were discarded; they provide no visual evidence. The corrected prototype export uses the repository's `Doorway Prototype` preset.

## Fresh independent blind review — GPT-6 Astra, medium

The reviewer received only the two reference photos and the final native/Web wall captures, without code, provenance, implementation narrative, or prior verdicts. Exact findings:

> PASS — the blue wall reads as a source-aligned game treatment at both sizes.
>
> 1. Muted slate blue, soft lighting variation, and darker upper shadow fit the reference gallery’s painted walls. No obvious repeating pattern or surface seams.
> 2. Artwork silhouettes and gold frames remain intact and distinct from the wall; the pale lower trim runs continuously across the view.
> 3. Native and browser captures match in composition, wall color, lighting placement, artwork placement, and trim.
> 4. Visible difference: native captures are noticeably softer, especially the artwork and frame detail at 1600; browser captures are sharper. This does not change the wall treatment’s visual reading.

This selects the documented wall candidate for later build integration. It does not pass the unchanged skylight/vault, which still has the dense grid and far-end dark patch from the prior review. No paid generation occurred in this tick. `BAKE_OK users=120`; `scripts/check.sh`, `scripts/check-gallery.sh`, and `git diff --check` passed; gallery failures were all zero and 23/23 paintings opened. Technical results do not prove skylight visual acceptance.
