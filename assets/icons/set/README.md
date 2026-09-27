# The generated set

Finished 64x64 icons, one file per icon, reduced from a Qwen Asset Pass with the
per-icon palette in `tools/icon_palette.py`.

**The palette is declared, not sampled, and that correction matters.** ADR 0001 and
[risd-godot#4](https://github.com/Reid-Surmeier/risd-godot/issues/4) originally said the
palette is extracted per-Icon from its Anchor. The grammar defeats that: it allows *at
most one gold element per icon*, so gold is always a minority colour and median-cut
quantisation always drops it. Measured 2026-08-30 — the favourite icon returned from
Qwen with 16,850 gold pixels and reduced to grey, and the painting's gilt corners with
19,518 went the same way. Even the five-anchor strip, which holds 28,934 gold pixels,
yields zero gold entries at 16 colours.

A palette sampled from an image cannot protect a colour the grammar defines as rare.

## What is here

| Icon | Notes |
| --- | --- |
| `ACT-01-favourite.png` | Gold star seated in a cobalt tray, as specified. |
| `ACT-04-more-like-this.png` | Front bust has a face and the satellites are flat blue, as specified. The busts read lumpy, and it grew a plinth that belongs to the department family. |
| `DEP-01-painting.png` | Gilt corners and cobalt plinth are right. The canvas is empty blue and the stretcher bars that were its Tell never appear. |

Three of fifty. The rest are specified and their briefs are generated; the upstream image
provider began refusing at a hard 300 s deadline on 2026-08-30 and the run was stopped.
