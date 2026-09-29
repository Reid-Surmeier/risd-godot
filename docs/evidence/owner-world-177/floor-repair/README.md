# Browser floor repair — #177 / #162

The black speckles were background showing through plank T-junctions, not texture or lighting noise. With only the preview background changed to magenta, the same 11 crop pixels became magenta. The corrected mesh has zero; the normal browser capture also has zero isolated dark crop pixels (native/reference had one).

Each plank edge is split at its neighbor corners. Vertices share canonical lattice coordinates; attributes and lighting UVs are interpolated. Only the saved floor mesh changed, with the same lightmap and source materials. No rebake or generation/spend.

`godot --headless --path . --script modules/shell/prototype/gallery_walk4/floor_edges_check.gd` reports 6062 unmatched interior edges on the old saved mesh and zero after repair. `python3 docs/evidence/owner-world-177/floor-repair/speckle-check.py <720-view-12.png>` fails the old browser image and passes the new one. Pixel counts supplement visual review.

![Before: background holes](before-magenta.png)
![After: closed edges](after-magenta.png)
![Browser room](browser-720.png)

## Independent image review

GPT-6 Astra medium, fresh reviewer, reference `../selected.png` plus native/browser720 and1600 candidates only. No code, rationale or earlier verdicts.

**PASS** for floor, wall and couch material appearance in all four candidates. Warm brown parquet and lighting retained; dark floor specks absent. Wall/baseboard/upholstery, tufting and buttons match. Browser and native agree at both sizes without visible holes, broken patches or texture seams. Candidates retain a dark couch leg beneath the right edge absent from the reference; appearance is not an exact silhouette rollback. Stills do not verify motion stability.

Repository checks pass with existing 13 ObjectDB shutdown warnings. Source geometry/cushion/camera checks pass. Full-app export and final owner approval remain separate gates.
