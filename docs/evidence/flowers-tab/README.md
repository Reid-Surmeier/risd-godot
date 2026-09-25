# Flowers tab evidence (build 2eefab0)

`modules/flowers_page/playtest/browser_play.py` on the Web export, headless Chromium on the GPU
(ANGLE D3D12, RTX 4070 SUPER), 1920x1080, real mouse input; `report.json` is its log (11/11 pass).

- `01-launch.png` — Collection at launch; the Flowers tab after Playground.
- `02-flowers-title.png` … `08-flowers-again.png` — click the tab; the title screen; Start New →
  instructions; Next → garden and vase; a blossom dragged (`05`) into the vase (`06`, with its
  rotate and scale handles); Collection (`07`, the player hidden); back to Flowers (`08`, as it was).
  `sheet.png` puts 02–08 side by side.
- `site-01-title.png`, `site-02-instructions.png` — the same two screens on ferryhalim.com.
- `native-placeholder.png` — the desktop build: the title frame as a still.
- `taskbar-before.png` / `taskbar-after.png` — the bar before and after (native Shell playtest).
- `view-samples-without-server.png` — View Samples waits for the site's PHP (see docs/research/flowers-tab.md).
