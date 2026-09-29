# Cutaway-floor repair — #167

Independent browser8 motion review failed for black L-shaped floor footprints despite numeric traversal success. Magenta ID probe confirms continuous floor geometry; retaining portal stone makes shadows coherent but occludes the visitor deeper inside. The room lightmap includes occlusion beneath stone that the gameplay cutaway hides.

When the camera mask hides masonry layer8, only the passage floor uses its existing diffuse albedo without baked lighting. Intact/follow views retain the lightmap. Geometry, authored pixels, bake and visitor are unchanged; no paid call. Native render regression confirms exposed floor samples are not black and intact/follow lighting restores. Repository checks pass. Browser motion review pending; not integrated.
