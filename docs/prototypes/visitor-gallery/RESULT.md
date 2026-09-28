# #159 — sourced visitor in the Grand Gallery

Status: technical prototype running; final independent visual gate pending.
This is a throwaway branch, not a runtime or release asset selection.

![Front at gallery gameplay size](evidence/front.png)
![Profile at gallery gameplay size](evidence/profile.png)
![Back at gallery gameplay size](evidence/back.png)

## Question and scope

Can the actual sourced New Horizons body, UVs and skeleton replace the current
visitor while preserving the gallery and its 23 works? Yes at the integration
level: the replacement uses the existing navigation, camera, collision, picking
and artwork-detail controller. Visual acceptance is not inferred from that fact.

The branch starts at build `8606d87d09692357a8b86173b1e8f6537277be6d`.
`visitor159/gallery.gd` subclasses the existing gallery and replaces only its
visitor; the original room/controller file and all paintings remain unchanged.
The dedicated Web export feature selects the throwaway scene. This branch's
viewport width is 1080 for square Movie Maker evidence, not a build integration.

Exact source pins, local input hashes, non-authentic motion labeling, material
adaptation and repeat commands are in
[PROVENANCE.md](../../../modules/shell/prototype/gallery_walk4/visitor159/PROVENANCE.md).
The character input is byte-identical to #163's candidate; animated transforms
and material overrides do not rewrite geometry, UVs, weights or inverse binds.
Native game clips were not recovered: only pinned KayKit Idle, Walking_A and
Interact are used. No Nintendo redistribution right or authentic animation is
claimed. No provider generation or spend was used.

## Corrections found by this prototype

1. The source emissive export has metallic=1. Disabling emission alone made the
   visitor black under gallery diffuse probes. Nonmetallic material copies fix
   that, retain source textures, and leave an untouched source-emissive route.
2. The initial controller adapter omitted #171's short settling interval when
   transitioning from walking/turning to idle. The stronger whole-plant-interval
   check exposed 3.17 cm drift. Restoring that settling behavior and correcting
   hip reach before leg solving reduced the measured drift to micrometers.
3. A look request at the instant reverse input was released was canceled by
   normal braking movement. The evidence now stops first, then invokes looking;
   it does not bypass the controller's gesture-cancellation behavior.

## Technical evidence

The capture uses real key-event handling and pointer press/release over W5;
`NAV_PICK W5` confirms picking before the normal approach, turn, gesture and
detail flow. Front/profile/back, straight/diagonal walk, stop, reversal, look,
and artwork interaction all appear in one continuous sequence. The headless
controller check verifies all stages, both look and wave, 23 works, and 42 bones.

Light probe negative control: warm hair pixel RGB
`[0.333333, 0.188235, 0.098039]`; cool `[0.317647, 0.176471, 0.086275]`;
GI-disabled `[0,0,0]`. This is a subtle spatial response, not a claim of dramatic
color variation. The probe test also checks that all 23 painting records have
positive dimensions. No room lighting or global finishing change was made.

![Warm spatial light](evidence/warm.png)
![Cool spatial light](evidence/cool.png)
![Probe-disabled negative control](evidence/disabled.png)

Final native movie, final Web clock/frame-time evidence, exact checked metrics
and independent image/video-only verdict will be appended after capture.
Native software-rendered Movie Maker output is deterministic 30 fps evidence,
not a measurement of live hardware performance. Browser live frame pacing is
recorded independently; preliminary runs are approximately 22–25 fps on this
software-rendered shared host, and do **not** establish a 60 fps guarantee.

Repository `scripts/check.sh` and `git diff --check` passed during development.
They will be rerun on the final checkpoint. No frozen module interface changed.
