# Flowers tab evidence (build 376c518)

`modules/flowers_page/playtest/browser_play.py` on the Web export, headless Chromium on the GPU
(ANGLE D3D12, RTX 4070 SUPER), 1920x1080, real mouse input; `report.json` is its log (14/14 pass).

- `01-launch.png` — Collection at launch; the Flowers tab after Playground.
- `02-flowers-title.png` … `08-flowers-again.png` — click the tab; the title screen; Start New →
  instructions; Next → garden and vase; a blossom dragged (`05`) into the vase (`06`, with its
  rotate and scale handles); Collection (`07`, the player hidden); back to Flowers (`08`, as it was).
  `sheet.png` puts 02–08 side by side.
- `site-01-title.png`, `site-02-instructions.png` — the same two screens on ferryhalim.com.
- `native-placeholder.png` — the desktop build: the title frame as a still.
- `taskbar-before.png` / `taskbar-after.png` — the bar before and after (native Shell playtest).
- `09-send-form.png` … `13-sample.png` (`sheet-send.png`) — the steps that needed the site's PHP, answered
  in the page: the send form, preview, "DELIVERY SUCCESSFUL! YOUR FLOWER NUMBER IS", that number
  entered (the card comes back), View Samples (a player's bouquet from the captured samples).
