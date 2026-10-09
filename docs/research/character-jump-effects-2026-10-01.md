# Character jump and running effects — 2026-10-01

For [issue 231](https://github.com/Reid-Surmeier/risd-godot/issues/231), following the owner's reports of inaccurate running dust/audio and request for a jump animation. All public game-source findings use ACreTeam/ac-decomp `09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c`, a community decompilation of the USA GameCube game. This pass fetched small public source files only: no ROM, paid generation, or additional gameplay download.

## Dust: verified behavior, unavailable original pixels

The renderer declares **four 16×16 I4 intensity textures** (`ef_dust01_0..3`), two texture slots, mirrored addressing, and a four-vertex/two-triangle model. It interpolates texture intensity into alpha, multiplies by primitive alpha, and uses primitive color plus vertex shading for RGB. The transform helper applies the camera billboard matrix. Thus the current single radial disc and three puffs per contact cannot reproduce the authored texture animation. **The original cloud silhouette has not been recovered.** [Model/combiner](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/data/model/ef_dust01_00.c#L8-L41), [billboard helper](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/effect/ef_effect_lib.c#L74-L88).

The wrapper includes five extracted files: `ef_dust01_0.inc`, `ef_dust01_1.inc`, `ef_dust01_2.inc`, `ef_dust01_3.inc`, and `ef_dust01_00_v.inc`. **None exists in the complete, nontruncated 6,712-entry pinned Git tree.** The README explicitly excludes game assets. Therefore texture bytes, artwork hashes, vertex coordinates, physical quad dimensions, and exact decoded PNGs are unavailable from this repository. No PNGs were invented and labelled as originals. [Asset policy](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/README.md), [complete tree](https://api.github.com/repos/ACreTeam/ac-decomp/git/trees/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c?recursive=1), [absence/source-hash receipt](../../image-work/character-pilot/live-demo/effect-reference/provenance.json).

Dry outdoor DASH dispatch creates **one white dust effect per foot-contact**, argument 8. Its fixed scale is `.01`, initial local velocity `(0,1,-2)`, acceleration `(0,-.05,.075)`, and timer 18. Each update adds acceleration to velocity, then velocity to position. Unlike other dust arguments, DASH does not apply velocity damping or scale growth. At 60 updates/s the effect lives .30 s; drawing becomes transparent at update 16. The two-update texture schedule follows below. [Dispatch](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/effect/ef_dash_asimoto.c#L127-L153), [dust implementation](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/effect/ef_dust.c), [timer update](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/effect/ef_effect_control.c#L341-L360).

| Age in 60 Hz updates | Texture pair | Blend numerator /255 | Primitive alpha /255 |
| --- | --- | ---: | ---: |
| 0–1 | 0,0 | 0 | 255 |
| 2–3 | 0,1 | 128 | 200 |
| 4–5 | 1,1 | 255 | 200 |
| 6–7 | 1,2 | 128 | 200 |
| 8–9 | 2,2 | 0 | 200 |
| 10–11 | 2,3 | 128 | 200 |
| 12–13 | 3,3 | 255 | 200 |
| 14–15 | 3,3 | 128 | 200 |
| 16–17 | 3,3 | 0 | 0 |

The source chooses different effects for sand, rain/water, snow and bushes; floors emit none. Preserve this dispatch instead of tinting one cloud for every surface. Nonwinter dry grass/path DASH gets dust; ordinary dry grass WALK/RUN does not. Source contacts cross animation frames 1 and 9. [Surface/weather routing](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/effect/ef_dash_asimoto.c), [WALK effects](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/effect/ef_walk_asimoto.c), [DASH contacts](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player_main_dash.c_inc#L73-L96).

## Apply source motion at the accepted demo scale

The current controller uses `travel_gain=3.15/4.875`. Since original actor translation is half its speed each update, a compatible conversion is `k=travel_gain/(60*.5)=.0215384615` demo units per original world unit. This is **derived from the accepted prototype speed**, not meters or an independently measured original-game scale. Rotate local dust velocity and acceleration by the saved contact heading. Use fixed 60 Hz updates, or the exact discrete sum `p(n)=p0+k*(n*v0+n*(n+1)/2*a)` for integer update `n`. A continuous parabola loses the source's acceleration-before-position increment. At update 18: local height change `.20353846`, backward change `-.49915385` demo units. [Current controller](../../image-work/character-pilot/live-demo/locomotion.gd), [source translation](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_actor.c#L43-L62).

Texture size **16×16 does not reveal quad width**. Source `.01` multiplies unavailable model coordinates, so Godot quad dimensions must remain labelled visual calibration. An authored four-stage cloud atlas can test the verified schedule now, but its contour and shading remain an adaptation. The repository's [CC0 license](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/LICENSE) does not establish ownership or licensing of missing Nintendo artwork.

## Audio and jump limits

Original footstep dispatch retains frequency scale 1.0, separate surface banks, right/left/rare variants, DASH offset +40, and outdoor gains WALK .6, RUN .8, DASH 1.0. Skid is separate `0x4129`. These facts are implemented already; changing pitch or dust alone cannot repair synthetic timbre. [Sound selection](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/static/jaudio_NES/game/game64.c_inc#L2014-L2105), [skid](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player_sound.c_inc#L207-L209).

No clean original footstep, landing, or skid waveform was found in this public source tree; the repository excludes game assets. Existing bounded YouTube windows remain mixed with music/dialogue and have no input-labelled DASH cue. Filtering those windows is not verified isolation. Keep them as listening references and identify any replacement as local synthesis; exact sound remains an open listening comparison. [Earlier audio audit and clips](character-audio-correction-2026-09-30.md), [repository asset policy](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/README.md).

An additional primary lead is **WDLmaster's decoded GameCube sample bank**, posted September 7, 2024. The decoder states all samples were exported at 32000 Hz, without per-instrument tuning from the soundbank. The linked archive remains accessible. HTTP-range inspection of its 105,909-byte central directory verified **1,157 WAV entries across six tables**, named numerically `TnWm.wav`; there are no footstep/grass/DASH labels or readme. The complete 22,150,270-byte archive was not downloaded, and **zero new audio bytes were retained**. No `0x4201`/`0x4229` sound-to-wave mapping or rendered-cue envelope was established, so these are a promising source lead, not verified grass footsteps. [Decoder's own account](https://hcs64.com/mboard/forum.php?showthread=64579), [live archive](https://drive.google.com/file/d/1M2fUPjUmXV2UbGltqGcsNLrWXLBFbC27/view), [bounded metadata receipt](../../image-work/character-pilot/live-demo/audio-reference/decoded-bank-lead.json).

A search result titled GameCube theme with sound effects explicitly uses **New Horizons** effects and was rejected; a fresh GameCube no-commentary capture explicitly retains music. Neither settles clean original cue identity. [Uploader's title](https://www.youtube.com/watch?v=LX_75QAQJ5c), [capture uploader's description](https://www.youtube.com/watch?v=Z_tnpg89G_Y).

The player-state enum contains `PICKUP_JUMP` and `MAIL_JUMP`; inspection shows item-clearing/table-pickup and mail-confirmation state logic. These names do **not** verify a freely controlled gameplay jump. A new Space/touch jump is the owner's requested **prototype addition**, with authored anticipation/tuck/landing poses and collision-driven landing. Do not present its airtime, impact cue or landing dust as recovered GameCube behavior. [States](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/include/m_player.h), [pickup implementation](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player_main_pickup_jump.c_inc), [mail implementation](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player_main_mail_jump.c_inc).

## Acceptance checks for this pass

1. One dry DASH puff at each genuine contact; none during ordinary grass RUN/WALK, indoor movement, airborne movement, dialogue, blocked movement, or rest.
2. Fixed birth heading, source motion sum, nine texture/alpha states, .30-second cleanup, bounded live puff count; inspect oblique and game-camera clips.
3. Jump edge-triggered only on the floor, no air retrigger; no footsteps/dust in flight; landing emits once and clears before locomotion resumes. Check idle/moving/tool transitions and wrist alignment throughout.
4. Listen to synthesis beside the retained mixed source clips; report timbre mismatch honestly. Hash-source/proof receipts establish reproducibility, not original-game sound or silhouette fidelity.

## Implemented prototype and remaining comparison

The pilot now authors a one-second Godot skeletal hop on the imported rig: anticipation, tuck, extension and landing. Space and touch Jump launch only while grounded; ballistic launch speed is 3.6 demo units/s with gravity 9.8. These are local design choices. The camera follows ground travel instead of vertical jump height. Tests exercise native collision landing and actual keyboard/touch controls; jump has no claim to be an original-game clip.

Dry DASH emits one .75-unit billboard with four authored cloud masks, source texture/alpha schedule, fixed calibrated size and discrete source-scaled motion. Water, leaves, snow and sand use distinct authored payloads; their contours and trajectories remain approximations. Normal grass RUN/WALK, indoor, blocked and airborne movement suppress dust. Original asset pixels remain unavailable. The initial .32-unit calibration was mostly hidden behind the avatar. A paired visible/hidden rendered check caught it; .75 exposes the cloud in at least three sampled phases, without claiming the unavailable source quad width.

Sound retains source dispatch, constant pitch and gait gains, with shorter noise-based surface transients, a less dominant tonal body, extra DASH detail and stable PCM headroom. Original mixed gameplay excerpts, previous synthesis and current synthesis are auditionable in the evidence page. No listening or spectral result establishes exact original timbre. The jump landing cue is explicitly local and carries no original-game sound ID.

The wrist report also exposed an idle IK error (palm aimed from shoulder rather than forearm), a tool-attachment/palm axis mix-up, omitted constant rest channels, overlay pose carryover, and a frozen static skid blend. Native pose checks now include idle, movement, jump, tool changes and settled arm poses; visual before/after evidence is retained separately from the unchanged Muse/provider artifacts.

Tool orientations retain the prior source-informed socket on each prop instead of imposing it on the palm. Offsets were derived from the first RightHand rotation in the starting commit `ae160441` fitted AXE/NET GLBs relative to the shared RightHand rest transform: AXE 99.74817°, NET 57.01000°. These are attachment transforms, not wrist bends; palms inherit the forearm. The static skid clip now advances at normal playback rate so its crossfade can complete, while its authored pose remains constant.
