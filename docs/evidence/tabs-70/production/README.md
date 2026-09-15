# Compact selected tabs — production candidate

![Collection selected after launch](01-collection-selected.png)
![Map selected](02-map-selected.png)
![Collection selected again](03-collection-reselected.png)
![Browser at 1920×1080](selected-1920x1080.png)
![Browser at 720×486](selected-720x486.png)
![Held blue Collection face](reveal-steady.png)

The Shell's six fixed tabs stop at 380 source pixels, retain complete labels and
page icons at 65 percent, and leave more of the toolbar visible before the
right-hand icon cluster. Selection reveals the independently reviewed blue face
from left to right over 0.2 seconds, then holds it. Selecting an already active
tab does not replay it; reduced-motion browsers receive the endpoint directly.

The native Shell playtest passed every tab, page, timing, freeze, resize, pressed
state and pixel check. Its film records intermediate reveal values and a steady
blue endpoint for both Map and Collection. The reusable non-Shell tab strip
keeps its original geometry and passed its existing playtest unchanged.

The exact `dab7341` Web export selected all six tabs at 1920×1080 and
720×486, measured each at 380 source pixels, returned to Collection, and found
the settled blue crop unchanged after another 160 ms. No browser or network
errors were observed.

Muse produced the recorded blue donor through OpenRouter. Both one-output
Seedance requests are preserved as unreconciled and possibly spent; neither was
retried, and no generated video is used. Production playback is the deterministic
mask reveal into the exact reviewed still endpoint.
