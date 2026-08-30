"""Per-icon palette: the icon's own colours, plus the accents that are always rare.

Two failures got us here, and the fix has to avoid both.

* **Sampling the anchors loses the subject.** Locking every icon to a palette taken from
  the five hand-drawn originals turns them into a colour law. Reid, 2026-08-30: those
  images are a style guide, not a palette. It is why the painting icon came back with a
  solid blue canvas — there was no other colour available to paint with.
* **Sampling the icon alone loses rare accents.** Median-cut drops a minority colour, and
  a gilt frame corner is a minority colour inside its own icon: extracting 16 from the
  painting's own image still gave zero gold.

So the palette is the icon's own colours *with* the handful of grammar accents forced in.
The subject keeps whatever it legitimately is; the accents survive being rare.
"""
from PIL import Image

# Forced in because the grammar makes them rare by design, never to constrain the subject.
ACCENTS = [
    (0x0D, 0x1E, 0x4D),  # the hard outline
    (0xF0, 0xB3, 0x23),  # gold, mid
    (0xFF, 0xE0, 0x8A),  # gold, lit
    (0xC8, 0x8A, 0x12),  # gold, shadow
]


def icon_palette(source: Image.Image, colors: int = 24) -> Image.Image:
    """A palette of `colors` slots: the icon's own, with the accents guaranteed present."""
    own = source.convert("RGB").quantize(
        colors=max(4, colors - len(ACCENTS)), method=Image.MEDIANCUT
    )
    flat = own.getpalette()[: (colors - len(ACCENTS)) * 3]
    for r, g, b in ACCENTS:
        flat += [r, g, b]
    pal = Image.new("P", (1, 1))
    pal.putpalette(flat + [0, 0, 0] * (256 - len(flat) // 3))
    return pal
