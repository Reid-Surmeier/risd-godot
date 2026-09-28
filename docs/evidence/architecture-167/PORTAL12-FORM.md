# Portal12 form diagnostic — not a visual acceptance gate

Status: source-only study at checkpoint `398a34ee`. A subsequent full-room bake
completed successfully (4m28.67s, `BAKE_OK users=120`) and six native 720/1600
views are in `portal12-native/`. Exported Web and independent acceptance remain
pending. Issue #167 remains open; benches are unchanged.

The official museum photographs in `PORTAL-CLOSER-SOURCES.md` now guide
authored relief rather than photo-luminance displacement. Distinct leaf,
scroll and figural masses occupy the six rounded capital bodies. Broader leaf
fields, carved upper triangular notches and a lower star/scroll tier replace
the narrow one-row impost. These are source-informed visual interpretations,
not a measured reconstruction or claims about uncertain iconography.

The private `portal_sculpture_probe.gd` copies only the source stone meshes into
an isolated scene with a flat stone-colored material and a frontal directional
light. There is no texture or baked gallery lighting to disguise weak form.
Its four 720/1600 square images are in `portal12-form/`. The probe does not show
the doorway interior, paintings, traversal, floor transition or final material.

The first directly lit versions exposed jagged highlight fringes on steep
carved edges. Sub-byte field precision alone did not remove them. Averaging
normals from actual neighboring triangles with Godot's
[`SurfaceTool.generate_normals()`](https://docs.godotengine.org/en/stable/classes/class_surfacetool.html#class-surfacetool-method-generate-normals)
removed the conspicuous fringes in the same camera/light capture. Independent
topology and normal-direction diagnostics remain in place:

```text
PORTAL_SOURCE stone_meshes=2 reversed_triangles=0 relief_winding=0 passage_floor=1
```

Self-inspection: the distinct forms and two-tier profile are legible at 720;
the 1600 close-up no longer shows the earlier jagged highlight edges. The
stylized carving and final material still need full-room inspection and a
fresh external image-only review. Nothing in this diagnostic is a PASS for
the architecture asset gate.

Additional paid generation: zero requests, USD 0. Rejected Muse output remains
excluded. Field/generator hashes are recorded in the Shell `PROVENANCE.md`.

## Subsequent saved-room bake

Native import/capture exited 0. Self-inspection finds the distinct relief and
two-tier profile still readable at 720, with soft stylization at 1600 requiring
independent judgment. No acceptance is inferred from the self-check. The bake
controller exited 0 despite inherited list/get-node teardown warnings after
lightmap completion. Saved-scene diagnostics and runtime checks remain queued.

| File | SHA-256 |
| --- | --- |
| `baked/room.tscn` | `e01173e21bf09b7e882da567df1a80ceadae3206d06d5cef5ba56f0943addc60` |
| `baked/room.exr` | `e769df1ab15ea734e53e0fe4a348340ff458dbfea70488987846afd0ff665565` |
| `baked/room.lmbake` | `2f02cf13900ad98f69607815faa5f3352f6fa87967d944122054b5167ec9672c` |
