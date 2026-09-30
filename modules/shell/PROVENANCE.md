# Shell visual provenance

## Square chrome (#164)

Selected treatment A from `prototype/156-square-chrome` at `89b0e39c4e4451b2b6e7b7031412c52249320777`.
Accepted runtime copies live in `assets/square_chrome/`; their source/output SHA-256,
crop rectangles and binary-mask recipes remain in `assets/square_chrome/provenance.json`.
The reproducible recut source remains on that preserved prototype branch at
`modules/shell/prototype/chrome/recut.py`.

Seven transparent icons reuse the Muse compact toolbar icons. Start is a recut of
its stars, Home a recut of its house, and Search a recut of the owner's top-header
screenshot. Stripe/selected-face crops reuse the existing compact toolbar.
Historical generation: OpenRouter `meta/muse-image`, pass 16,
`run-b443ade33509293fc5b17b6b`, USD 0.01 for the output / USD 0.09 edit loop.
Flowers retains its separate record in `image-work/flowers-tab-label/`.
The complete stripe raster is also copied into Shell's runtime assets with its
source and output hash in the same manifest; chrome loads no other module's art.
No generation for this integration: 0 calls, USD 0.

The Collection frame remains `assets/collection_frame/page.png` with original
source records in `image-work/collection-frame/`; the old clock is covered by the
same white mask accepted in treatment A. Atlas owns its accepted MINI MAP label
and clock treatment internally. No runtime asset depends on prototype evidence.

## #167 selected architecture — September 29, 2026

Architecture is source-led authored geometry, not a scan or surveyed reconstruction. Official RISD portal photographs, source crops/hashes, rejected trials and all independent review records remain on [prototype/167-cornice at 1e42d5a5](https://github.com/Reid-Surmeier/risd-godot/tree/1e42d5a5/docs/evidence/architecture-167). The recipe and generation records are retained in `image-work/architecture-167/`.

- Cornice, ivory trim and EXIT artwork: local Godot/SVG authoring, USD0. Independent native/browser review accepted pale molded profile and continuous joins.
- Portal: six source-led supports, carved relief fields and continuous stone UVs. Local authored geometry, no image-derived displacement. Rejected Muse modeling guide is excluded from runtime. Recorded modeling guide call: OpenRouter meta/muse-image, one image, reported USD0.01; actual reconciliation unknown. Official source links and photo hashes: prototype `PORTAL-CLOSER-SOURCES.md`; authored relief source: `portal_sculpt_relief_prepare.gd` and `portal-capital-relief.json`.
- Bench cloth: OpenRouter `meta/muse-image`, one image, run `run-88c6ecd80fdd005ff1c6ce34`. Reported reservation/cost USD0.010000; reconciliation unknown, no blind resubmission. Cloth SHA256 `4e87afbd59fec5004a36506934a30b62cc0f58500e07829572a9007ac13ffe51`. Prompt, ordered source references/hashes and recipe: `image-work/architecture-167/bench-material/`. Soft tufts, cushion edges and slender frame are local authored geometry; source proportions are visual interpretation.
- Bake8: 127 lightmap users; runner exited0. Both bench/native browser batches accepted at720/1600. Vault end normals face inward; no additional image generation. Final evidence in `docs/evidence/architecture-167/owner-repairs/bake8/`.
- Doorway camera retains selected perspective/FOV. A transient opaque dissolve avoids Compatibility renderer Alpha Hash failure; original materials return at full opacity. Private rendered regression checks actual background coverage. Floor cutaway removes baked shadows belonging to culled stone. No source texture/lightmap modified by this repair.

Historical #167 assets at that integration (later updates below supersede the room files):

| Runtime asset | SHA-256 |
| --- | --- |
| `baked/room.tscn` | `fa1bd9ad9c1ef89279225e91bfcfb30990c9fc5d85949e37d4256cd5a514923c` |
| `baked/room.lmbake` | `87529c49d38174870633da01f8654c2eceafdc2c8da40fd1be3a096914a130e7` |
| `baked/room.exr` | `19ec1364ff612f120b336de96f3f84ed7d4f67b62ab863a546d45c8a250abbbb` |
| `portal-capital-relief.json` | `25c7f5b414e6f519d81c29a2d6c0434a4a683a5b72dfb222b323a7af1574ec1b` |

Owner final hands-on acceptance remains separate and pending. No paid calls for integration or the dissolve repair.

Additional authored source hashes for the selected architecture:

| Source | SHA-256 |
| --- | --- |
| `textures/cornice-ivory.svg` | `69a315944cfca068373c0220beda9134b87df87b272607deb6bb48e736264bff` |
| `textures/ivory-trim.svg` | `89a3ccde5dfb4d78c4023e35e1ae9b3cc457ecb240b67994ba3af7612951c776` |
| `textures/exit-sign.svg` | `7f15231b789fb9539d2affcb90fcc593735f446191877a9427179ddfec9a1e07` |
| `portal_sculpt_relief_prepare.gd` | `88b95549164040aae8758c34ed79286b39fdf0ce8112247a6941c9bd2395bbeb` |


## Surface update #168

Current architecture source comes from build c9d2985c; see its architecture-167 records for unchanged portal, cornice, bench and visitor sources. Reconciled floor aa144f72/7f0d9f6c failed fresh close-detail review. One new OpenRouter meta/muse-image source-guided atlas request: run3d3e631edf2e83b935bb12cb, count1, actual recorded USD0.01, counted spent despite spendStateunknown; neverresubmit. Ordered Site Specific gallery2456/2447 reference URLs/hashes retained in image-work/floor-168-board-v2/README.md, new prompt/plan/receipt in image-work/floor-168-board-v3. Native atlas2240×1120 SHA25665ba2455f048c900562678cc42dcc55d89b608deef763e5e35e7d708e3d8a9ff, runtime textures/oak-board-atlas-168-v3.webp byte-identical. Unequal rows handled in UV crop, no edited image pixels. Final saved-bake native/browser floor review PASS at720/1600; exact records in docs/evidence/surfaces-168-current. Selected for build integration after source macro dependency removal.

## Native wall and skylight candidate #168

See docs/evidence/surfaces-168-current/README.md. Wall now uses native matte #6f83a3 with no image dependency. Skylight SVG is authored vector source, SHA256 fe3627efa8da494eaeba99fbd9c9e1182c023dc640cfd491be348950093ae50b, source-led from the recorded Site Specific gallery2447/2456 photos; 8×8 thin pale grid, square UV scale, stepped modeled surround. Provider none/count0/USD0 for this group. Floor macro texture dependency removed. All three separate saved-bake native/browser visual gates PASS at720/1600; recorded caveats remain in docs/evidence/surfaces-168-current.

## #176 final world correction (2026-09-29)

Source candidate2670002d corrects portal supports/joins, bench upholstery/underframes and photo-visible wall vents, joints and caption plates. Uses the existing recorded gallery photographs and accepted textures; no generation or additional spend. Rounded bench geometry and correct side UVs; flush wall divisions; closed portal relief edges and circular collar transitions. Both benches retain their locations; all23paintings and traversable openings retained. Third saved bake137users. Separate independent Astra medium image-only re-reviews: bench/walls PASS on secondcandidate, portalPASS onthird. Exact records and remaining fidelity limits in docs/evidence/world-176. No museum measurement or final owner approval is implied.

## #177 owner-selected appearance restoration (2026-09-29)

Owner-uploaded screenshot exactly matches6bdf721c architecture-167/owner-repairs/bake8/browser-12.png (SHA25624b88e74f55d557735c31b0df77f67ecba369539fac48ebbf6d1a96acbbeb969). Restore existing oak-muse.webp and wall-muse.webp with that floor mapping/plank size and slimmer cushion crown/rails. Existing bench-cloth-muse.webp retained; no new generation or spend. Later UV/rim correctness, portal/cutaway, character and containment repairs retained. Owner visual selection supersedes the later agent-selected floor/wall/cushion appearance.


## #177 browser floor edge repair — 2026-09-29

The restored warm parquet had rasterization holes at plank T-junctions. A magenta-background Web control exposed the same floor pixels as background. Each authored plank now has matching split edges, with shared lattice vertices quantized to 0.1 mm before world rotation. The saved floor ArrayMesh alone was retessellated; interpolated source colors, texture UVs and lightmap UVs remain. The existing lightmap, materials, source textures and scan hashes are unchanged. No rebake, provider request or spend. `floor_edges_check.gd` rejects the old mesh (6062 unmatched interior edges) and passes the repaired mesh (0). Browser/native matched close-ups and independent image review are recorded under `docs/evidence/owner-world-177/floor-repair/`.

## #186 lighter floor selection (2026-09-29)

Owner screenshot SHA256488e207d35b839603ee3d35cf1630f62a23bc800f4a03eadba61c862237b4a3f exactly matches world-176/integrated/details/bench.png, runtime c614b5ed. This supersedes #177's warm floor only. Restore existing oak-board-atlas-168-v3.webp, floor_oak.gdshader and 1.9×0.36 herringbone layout with #177's conformed shared edges. Current couch/walls/passage and lighting remain. Saved floor lighting UVs verified against the existing world-space mapping; lightmap EXR/LMBake hashes unchanged. No new generation, spend or bake. Evidence: docs/evidence/floor-selection-186.

## #187 warm floor and room light (2026-09-29)

Owner requested the older honey tone on the accepted #186 grain/layout, warmer lamp light and less skylight. Existing atlas pixels and 1.9×0.36 plank layout retained; floor shader tint adjusted, baked daylight reduced from 0.8 to 0.35, fill warmed and increased from 0.4 to 0.55, painting spots from 6.0 to 6.8. Doorway reveal and passage-facing normals corrected; shared panel winding now agrees with supplied normals. New offline lightmap is authored from this geometry and lighting. No image generation/provider calls or spend. Evidence and bake device/timing: `docs/evidence/warm-room-187/`.

Current #187 saved lightmap hashes (unchanged by #189):

| Runtime asset | SHA-256 |
| --- | --- |
| `baked/room.exr` | `e68c711f84cf22d1563475686d5359bc6b8d676aa9a7bf6e9288e9bcaab3eea2` |
| `baked/room.lmbake` | `6679c1971971046501aa48dcfd82aea7e4038d1897ace19226f3af5dc7de1bdf` |

Local Godot 4.7.2 offline bake on llvmpipe: 333.80 seconds, 137 lightmap users, provider none, USD0. Source geometry/lighting is recorded in runtime `dbfe2393` and `docs/evidence/warm-room-187/bake-final.log`.

## #189 white baseboard visibility (2026-09-29)

Owner screenshot `Screenshot 2026-09-29 at 3.39.58 PM.png` showed the left wall baseboard disappearing into shadow. Existing board geometry retained; its two saved merged materials now receive neutral emission fill (0.55), matching the cornice treatment. Source recipe remains in bake/prepare.gd, keyed by baseboard metadata. Saved room SHA256 `cec2c8fc7c555b46115c40a4752ae03bb1f40ff23129b8770dfd27c4c1f027a1`. All139 mesh geometry/normal/UV arrays and transforms match #187; EXR/LMBake unchanged. No generation, provider, spend or rebake. Native left-board luminance rises from0.272 to0.605; visual evidence in docs/evidence/collection-interaction-189.


### #177 passage-floor shared edges — September30

The current saved passage Surface010 had two visible interior Web pixels that changed from dark to magenta with only the background changed. Native edge check measured989 unmatched interior edges. Shared endpoint canonicalization/subdivision reduces that to0; the720/1600 Web background comparisons have0 interior background pixels. New source generation uses the same local passage helper; it preserves UV/color/UV2 interpolation. Only four serialized ArrayMesh data lines change, retaining all other scene bytes, materials/textures and saved EXR/LMBake hashes. No new generation, provider action, bake or spend (USD0).

Current `baked/room.tscn` SHA256 `0fe3d246ec52d848d3ba8a686b12dc831dabc85da4f85216dcb5254f93b1a9a8`. Source input is build477b34b5; reproducible source-geometry/private checks, rejected first repair and fixture-packaging failure are recorded under `docs/evidence/owner-world-177/passage-current/`. The passage-only quadratic scan measured200536µs in a native invocation; this is not a startup-performance acceptance. Full-app review and final hands-on owner approval remain required.
