# Gallery character and motion options

Research for the owner's September 26 request: check existing downloads first, then replace the current back-facing character through Muse and Seedance. Researched 2026-09-26; no paid requests, account sign-ins, runtime changes, or GitHub mutations.

**Recommendation:** use one Muse character identity based on the official GameCube human references below, then generate separately verifiable directional walk and interaction clips through the maintained Seedance pipeline. This is the smallest continuation of the existing sprite runtime. A single generated walking video cannot supply controllable head turns, hand gestures and every direction. A low-poly rig is the stronger eventual answer for independently blended motions, but the verified downloads do not provide the requested GameCube human and complete animation set together.

## Downloads checked before generation

| Candidate | Verified content and provenance | Fit / missing work |
|---|---|---|
| [SSlamon Animal Crossing Player Model](https://sketchfab.com/3d-models/animal-crossing-player-model-701a20b9786740378c2d67df3d810ef8) | Creator lists an editable player base; [primary API](https://api.sketchfab.com/v3/models/701a20b9786740378c2d67df3d810ef8) returned `isDownloadable: true`, 855 vertices, 1,706 triangles, `animationCount: 0`, CC Attribution 4.0. | Closest small human base found. Nose intentionally omitted; clothing/customization unfinished. Rig and downloadable archive formats were **not verified**. No walk/head/hand animations. The download listing is verified; an authenticated archive download was not performed. |
| [Godot Plush Character, gtibo](https://github.com/gtibo/Godot-Plush-Character) | MIT repository; actual [296,476-byte GLB](https://raw.githubusercontent.com/gtibo/Godot-Plush-Character/main/components/godot_plush/godot_plush_model.glb) fetched and JSON chunk inspected: one mesh, one skin, eight clips: `fall`, `idle`, `run`, `tilt_l`, `tilt_r`, `up`, `walk`, `wave`. [License](https://github.com/gtibo/Godot-Plush-Character/blob/main/license.md) includes Tibo's copyright notice. | Genuine immediately usable Godot rig and motion example; character is the Godot plush, not an Animal Crossing human. Replacing its appearance is substantial modeling/rig work, not a texture swap. Useful benchmark or independent rigging fallback, not the requested final character. |
| [Celeste by Ines](https://sketchfab.com/3d-models/celeste-animal-crossing-new-horizons-2f328b60753b4b88b246fe18963d98e5) | Creator lists downloadable CC-BY model, fully rigged, 19.8k triangles / 10k vertices, ready for animation. | New Horizons owl, not GameCube human. No included animation set verified; archive not downloaded. Its modern detailed body is a poor fit for this reference. |
| [City Folk frog villagers, SAB64](https://www.deviantart.com/sab64/art/MMD-Model-Frog-Villagers-Download-664578891) | Uploader describes twelve fully rigged MMD conversions with eye/mouth morphs; explicitly credits Random Talking Bush's game rips and Nintendo. | Actual character-rip provenance, not an original permissively licensed model. MMD conversion is not a Godot-ready GLB; no locomotion clips verified. Wrong species/era for the requested player. |
| [ACreTeam/ac-decomp](https://github.com/ACreTeam/ac-decomp), [ACGC port](https://github.com/Dimillian/ACGC-macOS-Port) | Both explicitly exclude game assets and require an existing game copy. | Valuable primary behavior/rendering code; **not a downloadable character library**. Repository source license does not supply missing character models. |

The Sketchfab license field records the uploader's model license; it is not evidence that Nintendo released the underlying character design under that license. We found useful options, **not proof that no suitable model exists anywhere**. We did not install a generic asset merely to claim the search was complete.

[Switch-Toolbox](https://github.com/KillzXGaming/Switch-Toolbox) can export rigged BFRES models and animation subsections, but is archived and requires source data. It is an extraction/conversion tool, not an included asset pack. That longer path offers little advantage for this prototype's next pass.

## Official reference images that can actually be fetched

Use the owner's exact game screenshot for composition, and Nintendo's original GameCube promotional art for the replacement character's identity/proportions. Avoid letting the easier-to-find New Horizons images silently select a different era.

- [Nintendo Doubutsu no Mori e+ game page](https://www.nintendo.co.jp/ngc/gaej/game/index.html) is the first-party source page.
- [Human pair 1, `chara01.gif`](https://www.nintendo.co.jp/ngc/gaej/game/chara01.gif): HTTP download verified, 4,193 bytes, visually inspected. Two short human villagers with large heads, small bodies, patterned hats/shirts and simple shoes.
- [Human pair 2, `chara02.gif`](https://www.nintendo.co.jp/ngc/gaej/game/chara02.gif): HTTP download verified, 3,967 bytes, visually inspected. Alternate same-era human identities.
- [In-game screenshot `ss01.jpg`](https://www.nintendo.co.jp/ngc/gaej/game/ss01.jpg): HTTP download verified, 15,111 bytes. Additional `ss02.jpg` through `ss08.jpg` are linked by the official page; only `ss01` was fetched in this research.

These are small official reference images, not runtime assets or high-resolution texture sheets. Downloaded temporary copies are `/tmp/chara01.gif`, `/tmp/chara02.gif`, `/tmp/ss01.jpg`. The original URLs and creator/owner attribution should accompany any generated Run Record. Do not upscale the tiny GIF and claim recovered geometric detail.

## Seedance capabilities and genuine limitations

Read the maintained local [Seedance README](/home/reidsurmeier/Image-generation-pipline/seedance/README.md), [run contract](/home/reidsurmeier/Image-generation-pipline/seedance/docs/run-contract.md), and [routing guide](/home/reidsurmeier/Image-generation-pipline/seedance/docs/model-routing.md). New paid work enters `image-pipeline animation`, not the retired `seedance-icons submit` command. The latter deliberately refuses submission. Current project instructions and the exact application cost gate govern execution; this research does not grant a submission permit.

Free live [OpenRouter video-model metadata](https://openrouter.ai/api/v1/videos/models) was queried during this research:

| Route | Canonical version | Supported durations | Resolution / anchors | Listed video-token price |
|---|---|---|---|---|
| `bytedance/seedance-2.0-mini` | `20260811` | integer 4–15 s | 480p/720p, first and last frame | $0.0000035/token; $0.0000021 with video input |
| `bytedance/seedance-2.5` | `20260807` | integer 4–30 s | 480p/720p, first and last frame | $0.0000107/token; $0.0000064 with video input |

These are **token rates, not total job estimates**. Capture current metadata and use the pipeline's exact plan estimate before submitting. Both profiles list seed/audio support; disable generated audio for character sheets so existing footstep timing remains deliberate. The general models endpoint also lists Wan 3.0/Prime, but switching provider/model would require a maintained adapter and fresh validation; there is no evidence it solves sprite consistency better.

OpenRouter's [video API](https://openrouter.ai/docs/guides/overview/multimodal/video-generation) returns an asynchronous video job, not a skeleton, mesh, or independent joint animation. First/last frame anchors guide image-to-video; reference inputs are guidance rather than exact frames, and anchors take precedence when mixed. Native transparent video is not promised by the local pipeline. Lock the matte, camera, light, silhouette, outfit and scale; verify keying edges and loop seams. Multi-view consistency and contact timing remain visual acceptance tasks.

## Smallest motion plan that meets the request honestly

1. **Identity first:** one Muse character reference sheet, showing front/back/left/right at the actual 45° downward camera pitch. Preserve the same face, hat, outfit, body size and floor baseline across views. A fixed orthographic-like crop prevents generated perspective drift. Have a still idle for every direction before integrating the replacement.
2. **Locomotion:** one in-place loop per distinct view; select the view from camera-relative movement direction and advance frames from actual displacement. A mirrored side view is acceptable only if the chosen character is symmetric. Do not mirror letters, asymmetric hair or accessories. Keep existing collision, floor contacts and navigation independent of image playback.
3. **Interactions:** distinct head-look/settle and hand-wave or art-inspection clips, starting/ending on their direction's idle. This lets an idle character look at art and gesture without pretending the back-view walk is a turn. Sprite playback cannot independently layer arbitrary head and arm motion unless separately generated layers exist; don't promise that capability from a whole-body clip.
4. **Entrance/exit:** use the same locomotion loop while the navigation controller moves through the doorway. It should finish inside the room and return control; changing rooms should preserve the arrival direction. No separate cinematic video is needed for a walking entrance.
5. **Acceptance:** inspect all views, loop seam, foot planting, no movement while collision-blocked, idle resume after interactions, exact footstep contacts, near/far room transitions, and crop/alpha stability. The final integration remains a trial until the generated motion passes these checks.

The longer-term rig path is technically cleaner for arbitrary turning and independent gestures. Godot's [AnimationTree](https://docs.godotengine.org/en/stable/tutorials/animation/animation_tree.html) natively supports blending, filtered tracks and one-shot motions over imported `AnimationPlayer` clips. A tiny skinned GLB could use a locomotion blend plus head/arm filters; no custom animation framework is necessary. But it requires an actual approved model/rig/clip set. Seedance video generation alone does not create that set, and a static Muse character image does not provide hidden back-side mesh geometry.

## Decision

Proceed with the authorized Muse identity and bounded directional/interaction Seedance studies, retaining the existing lightweight sprite seam. Record the result as generated sprite motion, not a rigged 3D character. If crisp direction changes or independently controllable head/hand motion cannot pass visual checks, stop expanding video batches and use an actual low-poly rig with native Godot animation instead. The search above establishes why that is a distinct modeling task rather than a forgotten one-click GitHub download.
