# Video comparison trials for issue231

Start with `youtube-front-v6/comparison.gif` and `youtube-profile-v6/comparison.gif`. Source: Mutch Games, https://www.youtube.com/watch?v=EwwW4Rk1wMU&t=1015s . Short clips, manual crop anchors, source hashes, and attribution are in `youtube/`. The star outfit, exact game state and source phase are unverified. No exact-match claim.

Selected: `authored-walk-v5/` (0.8s WALK), `authored-fast-v6/` (14/30s DASH). `authored-fast-v5/` retains the0.4s comparison. Each GLB temporarily stores fast motion in its `walk` clip slot; source/profile names distinguish the trials. No runtime naming contract is implied. Current baked mesh has24bones/7,719triangles and original textures.

Actual MCP replay, with the temporary Blender bridge available:

```bash
/home/reidsurmeier/.cache/uv/archive-v0/obgwABUdN8LrCiCW/bin/python -P image-work/character-pilot/bake_mcp.py --stage image-work/character-pilot/iterations/video-match/refine.py --profile image-work/character-pilot/iterations/video-match/authored-fast-v6.json --completion image-work/character-pilot/iterations/video-match/authored-fast-v6/correction.json
```

Wait for `mcp-native.log` to end in `Blender quit`; scheduling alone is not completion. Substitute `authored-walk-v5` for the WALK replay. For native replay only, Blender4.3.2 `--background --factory-startup --threads 1 --python-exit-code 1 --python refine.py -- --profile <absolute-profile-path>` runs the same stage but is not MCP evidence.

```bash
python3 image-work/character-pilot/iterations/motion-diagnosis/validate.py image-work/character-pilot/iterations/video-match/authored-fast-v6 --reference
python3 image-work/character-pilot/iterations/preview.py image-work/character-pilot/iterations/video-match-game-fast-v6.json
python3 image-work/character-pilot/iterations/preview.py image-work/character-pilot/iterations/video-match-profile-fast-v6.json
python3 image-work/character-pilot/iterations/video-match/compare.py v6
python3 image-work/character-pilot/iterations/video-match/check.py
```

Validation imports at240fps with the optimizer disabled and samples257poses. It checks penetration/endpoints and reports retained velocity changes; it does not assert world stance lock. Preview uses30FPS native playback and actual method keys. `check.py` binds native receipts, movies, reference clips, unchanged source hashes and the$1.54 aggregate liability. `independent-review/` holds mathematical and visual audits; `import-floor-failures/` preserves failed import/timing observations.

Storage: keep full short MP4s and representative poses. Replay recreates full frame sequences in disposable projects. Removed36MB of redundant new frames; no unrelated cleanup. Additional paid calls:$0.
