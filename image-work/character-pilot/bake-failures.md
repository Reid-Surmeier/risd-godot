# Unpaid bake attempts and corrections

These were local trials, not paid-provider retries. All provider source files remain unchanged.

1. GUI timer import initially failed because the glTF armature-display importer required `bpy.context.object`. Added a VIEW_3D window/area/region context override and kept the GUI screen alive rather than resetting factory UI during the callback.
2. `NlaStrips.new` rejected a floating-point start argument. Converted the known frame start to int.
3. The RGB-only bake guard rejected blank diffuse color. The raw rigged provider material omits `metallicFactor`, whose glTF default is1. Setting imported Principled Metallic to0 **before** baking made the native Diffuse/Color pass nonblank. GUI asynchronous behavior was initially suspected; that was not established as the cause of the black pixels. The retained route is the simpler reproducible one: actual MCP launches a pinned headless bpy stage and returns its process ID; a separate completion record proves success.
4. Export initially gathered7clips, including unused source actions imported from the temporary rigs. Removed only those temporary imported actions after copying the clips onto the checked matching rig; the final export has4clips.
5. The first framing measurement used a stale posed mesh bounding box after switching to REST. Updated the view layer and measured evaluated vertices. Final source rest height is1.898063m, excluding the 80-triangle importer bone-display helper.

Default forced animation sampling also truncated fractional-frame Idle/Walk endpoints. A temporary source-Idle export proved that the supported `export_force_sampling=False` preserved the endpoint to floating-point precision. Both final actual MCP-controlled native stages use that setting; the final motion clips retain source durations. The placeholder `clip0` remains slightly trimmed, explicitly recorded in `target-clip-timings.json`.

Final bake and separate normalization completion records have `success:true`. Their stdout/process logs are `bake-native.log` and `normalize-native.log`. The raw material's emission/specular factors and Idle Hips scale are separately repaired only in derived artifacts and disclosed in `bake-report.md`; passing these stages does not accept foot contact or motion quality.
