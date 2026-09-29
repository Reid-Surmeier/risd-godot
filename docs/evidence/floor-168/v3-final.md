# Final floor v3 saved bake — #168

Candidate on the existing floor prototype; not yet integrated. One Muse atlas, actual USD0.01, recorded in image-work/floor-168-board-v3. Unequal atlas rows are cropped inside their separators; mipmaps/VRAM compression pinned. Same geometry, selected visitor, portal cutaway, bench, vault and painting sources as reconciled architecture.

The offline renderer cannot evaluate dynamically indexed vectors in this path; equivalent explicit row branches removed that diagnostic. First attempt was stopped and restored by the bake wrapper. Retry returned0, BAKE_OK127 users,335.03 seconds. It logged list erase and out-of-tree get_node messages during shutdown; fresh import, native captures and Web export were clean.

- `room.tscn` SHA256 `f5c4c974ee9f8ce532d7c6d9ccae5a1ba3bcd53314a7b0cce8cea248dba51cd1`
- `room.exr` SHA256 `644b9daa0715f77c3e7ceeaa300c1f517c32f5efbd815de25d038e748540c504`
- `room.lmbake` SHA256 `322af2cca39b99b902953fd7b6731dc75946a3813b370bc3ea40d89745afc347`

Final image-only PASS at720/1600 native/browser; browser errors empty, navigation23 paintings and cutaway49.9895% coverage pass. No build fold yet: audit found the older floor.png still supplies a low-frequency macro-colour sample. Its source chain is not fully verified, so remove that dependency and recapture before claiming the source gate. The newer board atlas itself has the complete recorded source chain.
