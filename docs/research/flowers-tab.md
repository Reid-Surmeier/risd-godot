# Flowers tab — how ferryhalim.com runs Orisinal Flowers, and what the tab ships

Owner's request (2026-09-25): "https://www.ferryhalim.com/orisinal/flowers/index.html — make a
flowers tab that's this exact flow in a new tab. I have permission from the owners."

Everything below was observed on 2026-09-25 with curl and headless Chromium (Playwright), unless
marked *inferred*.

## The page

- `https://www.ferryhalim.com/orisinal/flowers/index.html` answers **302 → `http://www.ferryhalim.com/`**
  (a banner page); the server redirects every missing path there. The game page is the folder,
  **`https://www.ferryhalim.com/orisinal/flowers/`** (title "Orisinal.com - Flowers").
- It is Flash, run by **Ruffle**. The page loads `../ruffle.js` (twice) and sets
  `window.RufflePlayer.config = { autoplay: "on", splashScreen: false, unmuteOverlay: "hidden" }`, then
  has a classic `<object>/<embed src=flowers.swf width=750 height=422 bgcolor=#FFFFFF quality=high menu=false>`,
  which Ruffle's polyfill replaces. The rest of the page is ads, Google Analytics and the Orisinal header.
- Console: `New Ruffle instance created (Version: nightly 2024-03-09 | WebAssembly extensions: ON | Used renderer: wgpu-webgl)`.

## Requests the game makes

| Request | Size | What |
| --- | --- | --- |
| `/orisinal/ruffle.js` | 399,886 B | Ruffle self-hosted entry |
| `/orisinal/core.ruffle.4592c196d36da0816efa.js` | 80,612 B | Ruffle core (the extensions build) |
| `/orisinal/904b38d7fb3b9f71670a.wasm` | 15,244,211 B | Ruffle engine, WebAssembly extensions build |
| `/orisinal/flowers/flowers.swf` | 3,198 B | SWF v4 loader |
| `/orisinal/flowers/hstflowers.txt` | 7 B | `hst=./&` — the base the game uses for its server calls |
| `/orisinal/flowers/flowersmain.swf` | 219,929 B | SWF v4, 30 fps, 750x422 — the game |

A browser without WebAssembly extensions would take `core.ruffle.b88c2160eb044000f0a3.js` and
`969503d697a34c34e4b7.wasm` instead (*inferred* from `ruffle.js`, which names both).

Server calls, found in the SWF strings and by playing:

- **View Samples** → `GET flowersread.php?sample=999&ran=<n>` → e.g.
  `&s=celena&bgc=11&m=hi&ft1=10&fx1=182&…&total=1&reply=1` — a random arrangement other players
  made (two identical requests returned different answers).
- **Enter Flower Number** and **Send** (sender's and recipient's e-mail) → `flowersmake.php`
  (`load`, `load2`, `save`; "SUCCESSFUL! YOUR NUMBER IS:"). The server says `X-Powered-By: PHP/5.2.17`
  and sends **no CORS headers**. Not exercised: a real send would e-mail a stranger.

## The flow (the site, then the tab)

Title (vase and stem; Start New · Enter Flower Number · View Samples · Credits) → **Start New** →
instructions ("pick the flowers from the garden.. and arrange them here", "you can rotate the
flowers.. and scale them") → **Next** → the garden (randomly planted each time) beside the vase:
press on a blossom and drag it into the vase, where it gets rotate and scale handles; background
swatches and patterns 1–6 along the bottom → **Next** → the send step.

## Route chosen

**Vendor the site's own files and run them exactly as the site does**, as HTML over the canvas in
the Web build (the precedent is `modules/playground_page/arena_embed.gd`):

- The three game files are byte-identical copies of the site's:
  `flowers.swf` sha256 `feae48e1…a506`, `flowersmain.swf` `158f462b…b7bf`, `hstflowers.txt` `7933f255…b0a5`.
- Ruffle is the official GitHub release the site itself serves:
  `ruffle-nightly-2024_03_09-web-selfhosted.zip` (sha256 `b6d3ae32…3881`) from
  github.com/ruffle-rs/ruffle, tag `nightly-2024-03-09`. Its `ruffle.js`, `core.ruffle.4592…js` and
  `904b…wasm` hash identical to ferryhalim.com's (`02dd1f24…`, `55ff71cd…`, `d2aa4a89…`). Shipped:
  both core/wasm pairs, `LICENSE_MIT`, `LICENSE_APACHE`, `ruffle.js.LICENSE.txt`, `README.md`,
  `package.json`; the source maps are left out. Licence: Ruffle is MIT OR Apache-2.0.
- Same config as the site (autoplay on, no splash, unmute overlay hidden, white background, high
  quality) and the same folder shape (the SWFs and `hstflowers.txt` beside each other, relative
  loads resolved against that folder).
- No third-party fetch at run time: every file comes from the build's own `flowers/` folder.

Why not the alternatives: an `<iframe>` of the site pulls its ads and analytics and depends on
ferryhalim.com staying up; a newer Ruffle could play differently from what the owner saw; a port
to GDScript would not be "this exact flow".

## The site's two PHP scripts, rebuilt in the page (owner, 2026-09-25: "rebuild those")

The protocol, read from the SWFs' own actions (a Flash 4 action dump of `flowers.swf` and
`flowersmain.swf`):

- **Send** (the form: your name and e-mail, recipient's name and e-mail, message, "send a copy to
  myself" `c`, "notify me when the recipient got the flowers" `n`; then Preview, Submit): the loader
  POSTs `reply, s, se, r, re, c, n, ran, data, x` to `flowersmake.php`. `data` is `url_full`:
  `s|se|r|re|<bg><pattern>|m|` then `type|x|y|xscale|yscale|rotate|` per flower, spaces as `+`,
  line breaks as `%0D%0A`, the last `|` cut; `ran` is a checksum (2 x the sum of the character codes
  of s+se+r+re+c+n+url_full, minus 371). It waits up to 60 s for a non-empty `reply`, which the game
  shows as "DELIVERY SUCCESSFUL! YOUR FLOWER NUMBER IS: <reply>".
- **Enter Flower Number** accepts 12 or more digits only, then GETs `flowersread.php?code=<n>&nt=<0|1>`.
  `reply=2` shows "Sorry, the number you have entered doesn't exist in the flowers database."
- **View Samples** GETs `flowersread.php?sample=999&ran=<0..887>`.
- Both reads answer `&s=…&se=…&r=…&re=…&bgc=<bg><pattern>&m=…&ft1=…&fx1=…&fy1=…&fxs1=…&fys1=…&fr1=…
  …&total=<n>&reply=1` (samples leave out `se`, `r`, `re`).

`flowers_embed.gd` answers those URLs in the page, through `window.fetch` (what Ruffle's
loadVariables calls), in exactly that format:

- `flowersread.php?sample=…` → a random line of `web/samples.txt`: **84 distinct replies captured
  from the site** on 2026-09-25 (200 read-only requests at 1/s), byte for byte. They are other
  players' public samples; the game shows only "created by" and the bouquet.
- `flowersmake.php` → the bouquet is stored in the browser's `localStorage` under a new random
  12-digit number, answered as `reply=<number>`.
- `flowersread.php?code=…` → that bouquet (`reply=1`), or `reply=2`.

What stays different from ferryhalim.com: **no e-mail is sent** (the recipient, the copy to
yourself and the notification need a mail server), and a number only opens in the browser that made
it (no shared database). The sample pool is a snapshot, not the live pool.

## Where things are

- `modules/flowers_page/` — the Tenant (`interface.gd`, `errors.gd`, `flowers_page.gd`,
  `flowers_embed.gd`), `web/` (the vendored files, `.gdignore`d), `assets/title.png` (the title
  frame Ruffle drew, 2x, shown off the Web and while Ruffle loads), `playtest/browser_play.py`.
- `scripts/export-web.sh` copies `web/` to `build/web/flowers/`.
- Tab label and icon: `image-work/flowers-tab-label/README.md` (one Muse pass, 0.01 USD).
- Evidence: `docs/evidence/flowers-tab/`.
