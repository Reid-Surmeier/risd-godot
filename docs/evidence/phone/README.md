# phone_page playtest evidence

`reference.png` is the owner's Nokia handset mockup (ticket #33, attached 2026-09-13); the byte-identical copy is `modules/phone_page/assets/reference.png` (see the module's `PROVENANCE.md`). The Phone tab shows it as a draft mockup at its native 269x537, centred on white.

One run of `scripts/playtest.sh phone_page` on Godot 4.7.2 (X display, 1920x1080 then 1440x900, real mouse and key events through `Input.parse_input_event`; the harness builds the Shell with this module in the Phone Tab and nothing in the other Tabs), verified by `modules/phone_page/playtest/verify.py`, which re-reads the reference itself, re-hashes every screenshot and checks the logged states and pixels against the interface contract. `verify.json` is the verdict (21/21 pass); `report.json` is the harness log.

What they show: `01-launch` Collection active, no Phone tenant yet; `02-phone` after a click on the Phone tab — the handset centred at native size, matching the reference composited over white pixel for pixel, white around it; `03-hidden` the Phone page frozen behind the white Playground tab (a key and a click aimed at it changed nothing); `04-resumed` back on Phone, identical pixels, counters resumed; `05-resized` the 1440x900 minimum, the handset re-centred and still exact; `06-restored` back at 1920x1080.
