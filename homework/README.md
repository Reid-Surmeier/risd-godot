# Homework homepage

Scope: [Issue 234](https://github.com/Reid-Surmeier/risd-godot/issues/234).

Live homepage: https://homework.reidsurmeier.wtf/

- Week 1: https://ctchomework.reidsurmeier.wtf/
- Week 2: https://shader.reidsurmeier.wtf/
- Week 3: https://homework.reidsurmeier.wtf/week-3/

`index.html` is the complete homepage; no build step or dependencies. `homework.nginx` preserves the existing Booth static root and portrait adapter and adds the root homepage and Week 3 prefix. Requests beneath `/week-3/` reuse the existing static/API routes; the bare week URL redirects with a relative Location so public HTTPS stays HTTPS. Existing engine, tracking and root API URLs remain compatible.

## Deployment

Host: `droplet` SSH alias (`ubuntu-color`). Homepage installed at `/srv/sites/homework.reidsurmeier.wtf/homepage/releases/c97f39e21061`; `homepage/current` selects it independently of the existing Booth release. The index SHA-256 is `c97f39e210611c6a1ddc1d504c1946dc78cd8d07cba31156b96ab71dbdd5b9c2`. The nginx configuration is installed at `/etc/nginx/sites-available/homework.reidsurmeier.wtf`; validate with `nginx -t` and reload nginx after installation. No Booth restart, credential, provider, ledger or DNS change.

The old local shader worktree has been removed. The unchanged live shader build was recovered to `/home/reidsurmeier/risd-godot/output/homework-week-2-recovered/` on this PC, from `/srv/sites/shader.reidsurmeier.wtf/current/`. Its index SHA-256 is `d7654f74ddba69c51b67e645959dae99ec6891981bda3d5db970126c4cf3bc23`. This is recovery evidence; the Week 2 link uses its established public site.

## Verification

Run `node homework/check.mjs` for public links, keyboard focus and desktop/mobile layouts; screenshots go to `/tmp/homework-review/`. The test supplies a Chromium DNS mapping because the host's tailnet resolver currently maps the shader domain to loopback. Both Week 1 and Week 2 return HTTP 200 through public Cloudflare addresses, and the shader preview was inspected.

Run the existing `webcam-booth/deploy/check.mjs` from the `webcam-booth-195` worktree with `https://homework.reidsurmeier.wtf/week-3/` and `BOOTH_DEPLOY_EVIDENCE=/tmp/homework-review/week-3`. It intercepts generation and uses a synthetic camera. The full camera → portrait → explosion → camera loop passed: 12,869 ms cold startup at 10 Mbps, compressed engine 10,084,286 bytes; zero paid requests. Prefixed invalid capture returned 400, unknown status 404, foreign origin 403. WASM returned 200 with application/wasm. Physical webcam fidelity was not tested.

`scripts/check.sh` and `git diff --check` passed on the build tree. See `docs/evidence/homework-234/` for inspected public screenshots and the Booth check receipt. Rollback is a reversible nginx routing change: restore the prior site configuration from the existing Booth deployment source, validate and reload nginx. The original Booth release and state are unchanged.
