---
name: flowers_page
purpose: The Flowers Tab's Tenant — Ferry Halim's Orisinal "Flowers" as ferryhalim.com/orisinal/flowers/ runs it (the same SWFs on the same self-hosted Ruffle build), in one window on a white Page
interface: modules/flowers_page/interface.gd
errors: modules/flowers_page/errors.gd
tests: modules/flowers_page/playtest/browser_play.py (the Web export in headless Chromium)
depends-on: []
---

# flowers_page

## What callers get

`FlowersPageInterface.create(deps)` returns a full-rect Control: a white ground and one window, the
game at the site's 750x422 aspect, centred and scaled to fit (at most 2x, 48 px margin). On the Web
build the window is covered by a Ruffle player (HTML over the canvas, placed through the CRT warp's
inverse like `playground_page/arena_embed.gd`, hidden while the Page is hidden) that plays the game
from its title screen: Start New → instructions → pick flowers from the garden and arrange, rotate
and scale them in the vase → background and pattern → send; Enter Flower Number; View Samples;
Credits. Off the Web the window shows the game's own title frame as a still.

Owner's request (2026-09-25): "make a flowers tab that's this exact flow in a new tab. I have
permission from the owners."

## Inside

- `web/` (a `.gdignore` keeps Godot out) is copied to `<build>/flowers/` by `scripts/export-web.sh`:
  `flowers.swf` (the 3 KB loader), `hstflowers.txt` (`hst=./&`, the server base the loader reads),
  `flowersmain.swf` (the game), byte-identical to ferryhalim.com's; `ruffle/` is the official
  `ruffle-nightly-2024_03_09-web-selfhosted.zip` from github.com/ruffle-rs/ruffle (the build the site
  itself serves, byte-identical), less its source maps, with its MIT and Apache-2.0 licences.
- `assets/title.png` is the game's title frame rendered by that Ruffle at 2x (the window picture).
- The research, the file hashes and the one thing that cannot work off ferryhalim.com are in
  `docs/research/flowers-tab.md`: View Samples (`flowersread.php`), Enter Flower Number and Send
  (`flowersmake.php`) call the site's PHP beside the SWF, which a static host does not have; View
  Samples then waits on "SEARCHING FLOWERS ..." for good.

## Frozen

`interface.gd`, `errors.gd`, the browser playtest.
