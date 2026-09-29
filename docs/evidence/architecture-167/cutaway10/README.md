# Cutaway transition — #167

Cutaway9 passed floor/containment but failed visual continuity. This candidate fades the existing wall groups over intermediate opacity steps instead of dropping the full group in one frame. The passage floor mixes existing diffuse and baked contributions with the same masonry fade. Camera framing and geometry remain unchanged. Each cached baked material is duplicated per instance so fading cannot mutate the shared saved resource.

Private native regression verifies rendered floor samples, intact/follow lighting restoration and an intermediate wall/floor transition. Repository baseline passes. Exported browser roundtrip and independent motion review pending. No integration, owner approval or paid generation claimed.
