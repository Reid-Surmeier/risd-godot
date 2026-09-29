# Compatibility doorway dissolve — #167

Candidate12 replaces unsupported Alpha Hash with screen-space opaque discard during the brief doorway transition. All group8 surfaces use the same coverage mask, so depth writes remain correct. Original StandardMaterials return at full opacity. Temporary shader carries the existing texture, UV scale, tint, vertex color, cutout threshold and unshaded flag; no geometry, pixels, bake or paid generation changed.

The private rendered regression measures half-fade background coverage: candidate11 Alpha Hash reproducer fails with 0%; candidate12 passes with 49.98% across 19,129 changed samples. Native floor/orbit/side-camera checks and scripts/check.sh pass. Native probe frames are diagnostic, not independent acceptance. Browser movement/review pending. Not integrated.

Upstream renderer limitation: https://github.com/godotengine/godot/issues/103094 . Existing Alpha Hash value checks passed despite opaque rendering; the new check inspects actual image coverage.
