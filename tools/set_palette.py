"""The set's palette, declared rather than sampled.

Ticket #4 answered "per-Icon, extracted from the Anchor" and that answer is wrong for
this set, for a reason the grammar itself guarantees. The grammar says *at most one gold
element per icon* — so gold is always a small minority of the pixels, and median-cut
quantisation always drops it. Measured 2026-08-30: the favourite icon came back with
16,850 gold pixels and the painting with 19,518, and both reduced to grey because the
palette had been taken from a bust that contains no gold at all. Even the five-anchor
strip, which holds 28,934 gold pixels, yields zero gold entries at 16 colours.

A palette sampled from an image cannot protect a colour the grammar defines as rare. So
the ramps are written down instead, taken from the hand-drawn originals.
"""
from PIL import Image

COBALT = [(0x0E, 0x24, 0x5E), (0x12, 0x30, 0x7E), (0x20, 0x59, 0xD8), (0x58, 0xA3, 0xF5)]
MARBLE = [(0x8D, 0x85, 0x74), (0xB6, 0xAC, 0x99), (0xDA, 0xD3, 0xC4), (0xEF, 0xE9, 0xDD)]
GOLD   = [(0xC8, 0x8A, 0x12), (0xF0, 0xB3, 0x23), (0xFF, 0xE0, 0x8A)]
OUTLINE = [(0x0D, 0x1E, 0x4D)]
GROUND  = [(0xFE, 0xFE, 0xFD)]
MATTE   = [(0x00, 0xFF, 0x00)]

SET_PALETTE = COBALT + MARBLE + GOLD + OUTLINE + GROUND + MATTE  # 14 of 16 slots


def set_palette_image() -> Image.Image:
    """A P-mode image carrying the declared palette, shaped for ``snap_and_lock``."""
    pal = Image.new("P", (1, 1))
    flat: list[int] = []
    for r, g, b in SET_PALETTE:
        flat += [r, g, b]
    flat += [0, 0, 0] * (256 - len(SET_PALETTE))
    pal.putpalette(flat)
    return pal


if __name__ == "__main__":
    print(f"{len(SET_PALETTE)} declared colours: "
          f"{len(COBALT)} cobalt, {len(MARBLE)} marble, {len(GOLD)} gold, "
          f"1 outline, 1 ground, 1 matte")
