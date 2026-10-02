# Collection reconstruction progress — 2026-09-29

Evidence snapshot for #182 and #183. Prototype only; no production integration.

- Joined calibrated model: 475 registered views, 43,253 points; fitted reprojection error 0.639588 px.
- Held-out validation: 49/69 initially supported; 46/69 pass the stricter split-point check. These are nearby frames from the same recordings, not independent capture sessions.
- Plan shows observed points and camera positions, not accepted floor/wall/collision surfaces. Bookcase scale remains provisional.
- Decorative room dense reconstruction: 299,237 points.
- Muse frame treatment has owner approval. The sculpture front/rear sheet is generated but not mapped/baked into an accepted 3D mesh.
- Higher-resolution head trial still has holes and missing side/back coverage; rejected as a finished asset.
- A later bounded joined-room depth trial failed with an image decoder error; diagnosis is ongoing. Navigation, collisions, gameplay performance and final bake gates remain open.

Generation provenance: saved Muse workflow via OpenRouter; one frame image and one sculpture sheet, recorded cost $0.01 each ($0.02 total). Source runs and full records reside in image-work/collection-expansion-frame and image-work/collection-expansion-sculpture and the owning module PROVENANCE.md. The sculpture run retains unknown spend state / never-resubmit; no blind retries. Images here are copies, not new generation. See manifest.json for exact source paths and SHA-256.

Collection-only scope. 3D Viewer unchanged.
