# Current wall/skylight source repair — #168

Unselected candidate. Reference: two 2500×1667 Grand Gallery photographs on Site Specific’s Radeke Museum renovation page, URLs/hashes in image-work/floor-168-board-v2/README.md. Exact dimensions and photographic colour calibration are not claimed. Reference photos remain local evidence and are not copied into runtime.

- Wall: replaces the unverified wall-muse texture chain with native matte colour #6f83a3, manually chosen against the photos. Existing geometry, material lighting, room and painting placements retained. No source pixels are transformed or reused.
- Skylight: new authored SVG uses eight-by-eight pale panes and thin neutral ribs; UV longitude now uses the same length scale as the curved width, avoiding stretched foreground cells. Geometry adds a stepped white surround using the existing trim-profile function along both curved ends and long edges. Old inward-facing vault normals and distinct end caps are preserved.
- Floor: removes floor.png/parquet_macro from the accepted-v3 candidate shader/bake. Only source-verified atlas-v3 now supplies floor pixels. This change still requires a new rendered floor verdict.

SVG SHA256 `fe3627efa8da494eaeba99fbd9c9e1182c023dc640cfd491be348950093ae50b`. Authoring: local SVG/GDScript; provider none, count0, USD0 for wall/skylight. Floor atlas has its separately recorded single USD0.01 Muse request. The plain wall has no image/UV dependency; geometry receives the existing unique bake UV2. Skylight uses the new SVG through existing PS1 material in source and unshaded StandardMaterial in baked runtime, excluded from GI geometry/shadow casting. White trim retains cornice SVG material and native lightmap unwrap. All runtime remains without live lights.

Before native/browser 720/1600 poses2/3 are retained here. Source/import/repository checks passed before the combined bake. Final after captures, separate independent floor/wall/skylight reviews, navigation and build integration are pending.

Native capture rejected the first SVG because Godot imported its pattern fill as transparent black. Replaced it with explicit rect/path primitives; imported center pixel changed from RGBA(0,0,0,0) to (0.9373,0.9373,0.9373,1), and the saved-scene capture now shows the white grid. Glass is excluded from GI and shadows, so this texture-only repair does not change the saved lightmap. Final independent reviews remain pending.

All three fresh independent image-only reviews PASS at native/browser720/1600. Browser errors[] in both surface and floor capture runs; baseline, owner repair, navigation23paintings and cutaway coverage50.06% PASS. Build integration and integrated browser checks remain outstanding.
