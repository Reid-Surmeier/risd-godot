# Throwaway Muse face → retained UV comparison

**Transfer works, but both 512 and 1024 replacements are rejected as defaults: neither establishes a clear visual improvement. The before asset remains selected.** Native Blender 4.3.2 projects the already-generated Muse face features into the existing UV layout. No paid calls, mesh generation, rig repair or runtime replacement.

Look at [before face](before-face.png) and [after face](after-face.png), then [before profile](before-profile.png) and [after profile](after-profile.png). The transferred eyes and smile are broader, closer to the source feature shapes, but source blur remains. Camera/feature alignment is approximate; the textured nose cannot change the existing triangular nose geometry. The thin left cheek seam is visible in the before capture too. These stills establish neither gameplay-size likeness nor a motion verdict.

The native job used the normalized-idle GLB in its rest pose, orthographic camera `(0,-4,1.42)`, target `(0,0,1.42)`, scale `1.25`, and identical Standard color management/emission materials before/after. Projection maps source x=450..1158 to world x=-.46..+.46, and source y=470..900 to world z=1.40...86. Original reference arms slope while the mesh's rest pose is T: **whole-body transfer was excluded**.

The source mask contains four feathered ellipses covering eyes, nose and smile, not the white background or the entire cheek. Front-only geometry and smooth normal weighting limit projection at grazing angles. Native Cycles Emit baking makes projection-color and coverage maps on the original UVs. Only covered atlas pixels change; the final report and checks record exact counts, and the rendered back remains pixel-identical. See [the final report](report.json) and [encoded-pixel check](check-result.json).

The temporary projection UV/color layer is removed. The GLB is constructed by replacing only its embedded PNG reference and appending PNG bytes; source mesh, UV, skin, bone/node and animation accessor bytes remain byte-identical. Its 7,719 triangles, 24 bones and four clips are retained. The output still has the original foot-contact/motion defects.

Files: [derived atlas](projected-albedo512.png), [original atlas](before-atlas512.png), [source mask](source-mask.png), [baked coverage](uv-coverage512.png), [derived GLB](face-projection.glb), [native Blender review](face-projection-review.blend), [stage script](projection.py), [assertion check](check.py).

Run from the project:

```bash
/home/reidsurmeier/.local/opt/blender-4.3.2/blender --background --factory-startup --threads 1 --python-exit-code 1 --python image-work/character-pilot/iterations/texture-projection/projection.py
python3 image-work/character-pilot/iterations/texture-projection/check.py
```

No new dependencies. The saved mask is an input; its four ellipse boxes and 15-source-pixel feather are recorded. The render/bake job ran directly in native Blender, not through a new MCP call. Its output is evidence for a later texture decision while posing, grounding and effects remain the priority.

## One 1024 comparison

The [1024 atlas](atlas1024/projected-albedo1024.png) uses Blender's native upsampling of the existing 512 color outside feature masks. Both the upsampled baseline and baked candidate are saved/reloaded as PNG before rendering, so their comparison includes the actual encoded export rather than unlike float/byte texture buffers. [Before front](atlas1024/before-face.png), [after front](atlas1024/after-face.png), [before 45-degree yaw crop](atlas1024/before-quarter-gameview.png) and [after crop](atlas1024/after-quarter-gameview.png) use the same camera. These are head/body review crops, not a full gameplay scene.

Inspection: 1024 retains slightly more edge sampling, but the source eyes are already soft and the projected face remains soft at the 45-degree view. More atlas pixels do not establish an overall likeness improvement. **Keep the original material; retain both trials only as evidence.** The [1024 checks](atlas1024/check-result.json) preserve 1,008,405 zero-coverage atlas pixels, the original geometry/UV/skin/animation arrays and the full back render. The existing pose/grounding defects remain.

```bash
# Free native variant and check:
/home/reidsurmeier/.local/opt/blender-4.3.2/blender --background --factory-startup --threads 1 --python-exit-code 1 --python image-work/character-pilot/iterations/texture-projection/projection.py -- --resolution1024
python3 image-work/character-pilot/iterations/texture-projection/check.py --resolution1024
# Apply a color PNG to a separately repaired mesh, preserving its entire BIN prefix:
python3 image-work/character-pilot/iterations/texture-projection/replace_color.py INPUT.glb COLOR.png OUTPUT.glb
```

The replacement helper requires one shared embedded base-color image and a new output path. It changes the embedded image reference/buffer length only; it does not export Blender geometry or rebuild animations. Its assertions ran against the 1024 candidate and produced the same output as the native projection script.
