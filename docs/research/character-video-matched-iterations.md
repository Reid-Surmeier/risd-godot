# Character pilot: comparison against GameCube gameplay

Issue [231](https://github.com/Reid-Surmeier/risd-godot/issues/231), map [226](https://github.com/Reid-Surmeier/risd-godot/issues/226). This remains a native Blender/Godot prototype, before the owner's `$to-spec`. Additional paid calls: **0**. Aggregate provider liability remains **$1.54 of the approved $4**, with final billing unverified.

Review the [YouTube front comparison](../../image-work/character-pilot/iterations/video-match/youtube-front-v6/comparison.gif) and [profile comparison](../../image-work/character-pilot/iterations/video-match/youtube-profile-v6/comparison.gif). Each includes a short attributed excerpt from [Mutch Games' GameCube longplay](https://www.youtube.com/watch?v=EwwW4Rk1wMU&t=1015s), alongside actual native animation playback. The source hat differs from the supplied star hat. Crops follow the character using recorded manual anchors; phase, aspect correction and exact executable state are **not** fitted. The source turns outside the short clear view windows. These are comparisons, not a certification of exact likeness.

The reference research, precise timestamps, original source samples and limitations are in [the source note](character-video-reference-2026-09-30.md). Outdoor dust first appears near 1016.200, 1016.433 and 1016.667 seconds: approximately 7/30 seconds between alternating events, 14/30 seconds per full cycle, with a conservative 0.40–0.533-second range. The newer 0.467-second DASH trial follows this estimate. The 0.400-second alternative stays available; the separate 0.800-second WALK trial is not falsely identified as the footage's movement state.

## What the loop found and changed

| Iteration | Actual finding | Result |
|---|---|---|
| Earlier selected rig | Idle inherited a roughly 130° head turn; lower jaw vertices escaped the original rigid-head mask | Forward idle; an inspected 287-vertex jaw extension includes coincident UV seam vertices. Reviewed jaw seam pairs stay closed. |
| Source curves v2 | Transferring rotations alone left target limb directions biased by their generated rest angles | v3 calibrates shoulder/arm/forearm/thigh/shin anatomical axes. Independent quarter-pose checks reduce actual segment-direction error from up to 15.95° to at most 0.00108°. This verifies the reconstruction's directions, not observed game geometry. |
| v3 engine import | Rendered key frames looked grounded, but dense sampling found 3.55 mm WALK / 15.38 mm fast penetration at import30; import60 still left 5.28 mm fast penetration | v4 uses bake/import240 with the per-AnimationPlayer optimizer disabled. WALK and fast angular curves remain authored; target-specific root grounding is sampled more densely. |
| Arm skin v5 | Upper-arm vertices carried unrelated hip and leg weights. Same-region point extent compressed 11.33% during fast motion | Squared and normalized existing weights on 739 inspected vertices. Comparable extent compression falls to 1.06% fast / 1.37% idle. This is a point-cloud shape metric, not whole-mesh volume. Eight front/profile before/after views and a standard GLB roundtrip were inspected. |
| Cadence/effects v6 | YouTube cadence differs from the earlier 0.400-second trial; the dust was brown, followed the current foot, and wrap callbacks could arrive one frame late | Selected fast trial is 14/30 seconds. White dash-style puffs keep their birth position in world space and sit behind the foot. A 1-microsecond initial advance prevents float accumulation from postponing zero-phase method keys. Native assertions check each callback time. |

The public [authored animation curves](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/data/model/player_anim.c) are reconstructed and adapted to the generated rig. Source rendering uses joint-associated parts, whereas this target uses smooth linear skinning. Blender preserve-volume/DQ is not carried by this standard exported GLB; enabling it in Blender alone does not repair engine deformation. [The arm note](character-arm-weight-refinement-2026-09-30.md) and native receipt describe the portable weight correction.

Ordinary grass WALK/RUN should not emit the generic dash puff in this source: [WALK effects](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/effect/ef_walk_asimoto.c) handle surface/weather cases, while [DASH effects](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/effect/ef_dash_asimoto.c) dispatch dust on ordinary ground and use other effects for sand, water and bushes. This prototype demonstrates the ordinary dash case; it does not implement the complete surface/weather dispatcher.

## Selected artifacts and measured gates

- WALK: [v5 editable Blender file](../../image-work/character-pilot/iterations/video-match/authored-walk-v5/footplant-candidate.blend), [GLB](../../image-work/character-pilot/iterations/video-match/authored-walk-v5/footplant-candidate.glb), [game-camera movie](../../image-work/character-pilot/iterations/video-match-game-walk-v5/loop.mp4).
- Fast locomotion: [v6 editable Blender file](../../image-work/character-pilot/iterations/video-match/authored-fast-v6/footplant-candidate.blend), [GLB](../../image-work/character-pilot/iterations/video-match/authored-fast-v6/footplant-candidate.glb), [game-camera movie](../../image-work/character-pilot/iterations/video-match-game-fast-v6/loop.mp4).
- [Idle before/after](../../image-work/character-pilot/iterations/video-match-idle-v5/loop.gif), [jaw before/after](../../image-work/character-pilot/iterations/video-match/jaw-review/frame24-after-profile.png), [arm before/after receipt](../../image-work/character-pilot/iterations/video-match/independent-review/arms/arm-core-receipt.json).

| Native Godot check, 257 poses/clip | WALK v5 | Fast v6 |
|---|---:|---:|
| Period | 0.800 s | 0.466667 s |
| Largest sampled penetration | 0.067 mm | 0.309 mm |
| Endpoint vertex displacement | 0.420 µm | 0.417 µm |
| Rigid shoe sole height at selected event | within 0.001 mm | within 0.001 mm |
| Skeleton / topology | 24 bones / 7,719 triangles | 24 bones / 7,719 triangles |

Actual Blender MCP launched both selected workers; completion is established by native exit logs and matching GLB hashes, separately from successful scheduling. Fast v6 records eight correctly timed callbacks across four loops, four across the profile's two loops, and zero after changing to idle. Movies evaluate every frame at30FPS; GIFs are approximately15FPS previews. The source original/provider files and textures are unchanged.

## Remaining differences: exactness is open

Generated head/horn shape, shoe shape, limb lengths, wrist placement, garment silhouette, atlas detail and lighting still differ from the source. The source video has a different outfit and motion ghosting. Some wrists/soles are hidden, and the profile turns away. Exact star-hat footage and exact game state have not been established.

The WALK contact order on this target reverses despite correct source ankle ordering: the rotated generated right boot reaches the plane first. An independent counterfactual isolates the boot geometry/foot-frame relationship, rather than merely unequal leg lengths. The selected fast trial's contact order agrees with the source. Event assignment follows measured target soles; this is not a claim of recovered original shoe geometry. Do not invent a foot basis from a toe direction that is not the source joint's anatomical axis.

Root grounding does **not** lock a stance foot to a world position. The former contact-solved walk remains a separate proof; its submillimeter world stance results are not transferred to these source-pose trials. Terrain, turning, transitions, continuous collision and complete effects dispatch are unverified. Source loop endpoints match, but authored/quantized velocity changes are retained rather than silently smoothed. A rendered high-speed pose is not proof of smooth velocity.

Storage is constrained: the host had22GB free at98% usage. Removed36MB of redundant newly generated PNGs, retaining complete short movies and representative poses. Intermediate GLBs and audit receipts preserve useful failures; duplicate intermediate Blender files are dispensable because the saved stages regenerate them. No owner files or unrelated caches were removed.

Replay and the small receipt assertion are documented in [the trial README](../../image-work/character-pilot/iterations/video-match/README.md). The open next research target is a supported shoe/sole calibration plus original proportions and phase/view alignment; this result is **not exact** and does not close visual acceptance.
