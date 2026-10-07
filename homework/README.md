# Homework homepage

Scope: [Issue 234](https://github.com/Reid-Surmeier/risd-godot/issues/234).

Live homepage: https://homework.reidsurmeier.wtf/

- Week 1: https://shader.reidsurmeier.wtf/
- Week 2 (Loading dots): https://ctchomework.reidsurmeier.wtf/
- Week 3: https://homework.reidsurmeier.wtf/week-3/
- Week 4 (Otani room): https://homework.reidsurmeier.wtf/week-4/ ([Issue 248](https://github.com/Reid-Surmeier/risd-godot/issues/248))

`index.html` is plain HTML with three native blue links; no CSS, build step or dependencies. `homework.nginx` preserves the existing Booth static root and portrait adapter and adds the root homepage and Week 3 prefix. Requests beneath `/week-3/` reuse the existing static/API routes; the bare week URL redirects with a relative Location so public HTTPS stays HTTPS. Existing engine, tracking and root API URLs remain compatible.

## Deployment

Host: `droplet` SSH alias (`ubuntu-color`). Homepage installed at `/srv/sites/homework.reidsurmeier.wtf/homepage/releases/f2bc0a61a04e`; `homepage/current` selects it independently of the existing Booth release. The index SHA-256 is `f2bc0a61a04ec546c698511aa075b132e6634332e0f72c68fdddf78b864e92da`. The nginx configuration is installed at `/etc/nginx/sites-available/homework.reidsurmeier.wtf`; validate with `nginx -t` and reload nginx after installation. No Booth restart, credential, provider, ledger or DNS change.

The original local shader worktree path is no longer present. The unchanged Week 1 live shader build was recovered to `/home/reidsurmeier/risd-godot/output/homework-week-2-recovered/` on this PC, from `/srv/sites/shader.reidsurmeier.wtf/current/`. Its index SHA-256 is `d7654f74ddba69c51b67e645959dae99ec6891981bda3d5db970126c4cf3bc23`. This is recovery evidence; the Week 1 link uses its established public site.

## Verification

Run `node homework/check.mjs` for public links, absence of CSS, keyboard focus and desktop/mobile layouts; screenshots go to `/tmp/homework-review/`. The test supplies a Chromium DNS mapping because the host's tailnet resolver currently maps the shader domain to loopback. Both Week 1 and Week 2 return HTTP 200 through public Cloudflare addresses, and the shader preview was inspected.

Run the existing `webcam-booth/deploy/check.mjs` from the `webcam-booth-195` worktree with `https://homework.reidsurmeier.wtf/week-3/` and `BOOTH_DEPLOY_EVIDENCE=/tmp/homework-review/week-3`. It intercepts generation and uses a synthetic camera. The full camera → portrait → explosion → camera loop passed: 12,869 ms cold startup at 10 Mbps, compressed engine 10,084,286 bytes; zero paid requests. Prefixed invalid capture returned 400, unknown status 404, foreign origin 403. WASM returned 200 with application/wasm. Physical webcam fidelity was not tested.

`scripts/check.sh` and `git diff --check` passed on the build tree. See `docs/evidence/homework-234/` for inspected public screenshots and the Booth check receipt. Rollback is a reversible nginx routing change: restore the prior site configuration from the existing Booth deployment source, validate and reload nginx. The original Booth release and state are unchanged.

## Week 4

`week-4/index.html` is a plain page with the comparison image (`week-4/otani-room-comparison.png`) and a download link for `otani-room.blend`. The Blender file is 416 MB and has a purchased texture pack packed inside, so it is copied to the host by hand and is never committed; it comes from the `otani-clay-room` repository (`save_blend` in its scene description).

Deployed on 2026-10-07 to the CM3588 (`ssh cm3588`), which replaced the droplet named above: release `homepage/releases/bff56ebb420d` (named after the first 12 hex digits of the homepage's SHA-256), holding `index.html`, `week-4/` and `homework.nginx.before` (the live site file as it was). The live site file there listens on `127.0.0.1:8088` behind the Cloudflare tunnel, not on the ports in this folder's `homework.nginx`; only the two `week-4` lines were added to it. Rollback: point `homepage/current` back at `releases/f2bc0a61a04e` and restore `homework.nginx.before`, then `nginx -t` and reload.
