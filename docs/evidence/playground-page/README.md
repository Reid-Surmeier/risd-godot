# playground_page playtest evidence

The Playground tab as a draft mockup: the owner's Digital Playground reference (`../collection-page/reference.png`, ticket #26; the byte-identical copy is `modules/playground_page/assets/reference.png`, see the module's `PROVENANCE.md`) at its native 859x803, centred on white.

One run of `scripts/playtest.sh playground_page` on Godot 4.7.2 (X display, 1920x1080 then 1440x900, real mouse and key events through `Input.parse_input_event`; the harness builds the Shell with this module in the Playground Tab and nothing in the other Tabs), verified by `modules/playground_page/playtest/verify.py`, which re-reads the reference itself, re-hashes every screenshot and checks the logged states and pixels against the interface contract. `verify.json` is the verdict (21/21 pass); `report.json` is the harness log.

What they show: `01-launch` Collection active, no Playground tenant yet; `02-playground` after a click on the Playground tab — the picture centred at native size, matching the reference composited over white pixel for pixel, white around it; `03-hidden` the Playground page frozen behind the white Phone tab (a key and a click aimed at it changed nothing); `04-resumed` back on Playground, identical pixels, counters resumed; `05-resized` the 1440x900 minimum, the picture re-centred and still exact; `06-restored` back at 1920x1080.
