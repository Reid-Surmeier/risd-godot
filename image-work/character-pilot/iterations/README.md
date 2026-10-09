# Throwaway character iteration #231

The newest pass compares YouTube GameCube footage with source-curve WALK/DASH trials: start with [video-match/README.md](video-match/README.md) and [the measured report](../../../docs/research/character-video-matched-iterations.md). The older contact-solved result below remains a separate proof; its world-foot-lock claims do not apply to the newer source-pose trials.

Review `gameview-final-45/loop.gif` first, then `walk-comparison-45/loop.mp4` for the full30FPS before/after film. Movies evaluate every frame; the GIF previews use15FPS. Representative PNGs and full movies are retained; replay regenerates all frames. Original eight-pose footage stays in the earlier proof folder.

Selected rig/motion: `motion-diagnosis/footplant-candidate.glb` and compressed editable `.blend`. `motion-diagnosis/contact-manifest.json` owns the0.52m/s walk, contact phases and native sampled gates. `rigid-head.glb` is the preceding head-only repair. `rig-diagnosis/review-rest-{front,side,back}.png` shows the T-pose. The private provider source files are unchanged.

`texture-projection/` contains rejected512/1024 face projection comparisons and the tested color-only replacement helper. No retexture provider request or new generation was made. Additional API fees:$0; aggregate liability remains$1.54 of$4.

From the prototype worktree, with the existing Blender MCP bridge available:

```bash
/home/reidsurmeier/.cache/uv/archive-v0/obgwABUdN8LrCiCW/bin/python -P image-work/character-pilot/bake_mcp.py --stage image-work/character-pilot/iterations/rigid_head.py
/home/reidsurmeier/.cache/uv/archive-v0/obgwABUdN8LrCiCW/bin/python -P image-work/character-pilot/bake_mcp.py --stage image-work/character-pilot/iterations/motion-diagnosis/correct.py --completion image-work/character-pilot/iterations/motion-diagnosis/correction.json
python3 image-work/character-pilot/iterations/motion-diagnosis/validate.py
python3 image-work/character-pilot/iterations/preview.py image-work/character-pilot/iterations/gameview-final-45.json
```

MCP scheduling returns before the native worker finishes. Verify the completion JSON/output hash and native log before advancing. The pinned worker is Blender4.3.2; Godot4.7.2 imports into disposable projects and disables the perAnimationPlayer optimizer. The client uses`-P` to avoid the neighboring inspect.py shadowing stdlib inspect. An existing temporary bridge bootstrap is `image-work/character-fixture/mcp_bootstrap.py`; no global configuration change is required.

For a native-only replay, run pinned Blender `--background --factory-startup --threads 1 --python-exit-code 1 --python <stage>` instead of the MCP launcher. The same saved stage is executed; this replay alone is not MCP evidence.

Each camera/config can be replayed with `preview.py <config.json>`. Before/after35/45/55, idle, dust control, transition lift and final game-size framing are separate configs. Native Animation method tracks trigger the dust; the closing idle control suppresses outgoing walk keys. `native-effect-idle-failure.*` preserves the failing attempt. `transition-unclamped-45/` retains the failed blend and `transition-grounded-45/` the limited floor correction.

The part masks, gait and ground plane are specific to this character. No terrain, turning, general blend foot lock, run repair, runtime integration or automatic likeness acceptance is claimed. `summary.py` checks the published receipts and media; embedded/native assertions test the actual poses and events.
