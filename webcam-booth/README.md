# Ephemeral webcam booth

Standalone Godot 4.7.2 project in the separate `webcam-booth-195` Orca worktree. Open this folder’s `project.godot`; the RISD root project is unchanged.

Enable the camera, take a picture, and wait for the dots/bar loader. OpenRouter Muse transforms the actual capture using the supplied low-poly style reference. The portrait appears in a white-glove gold frame for ten seconds, then the fuse explodes and returns to the camera. “Try sample photo” uses the declared pre-generated sample without spending money. There is no gallery or download flow.

Live smiles, blinks and small head movements deform the portrait through local MediaPipe inference and a bounded 2D shader. Unavailable tracking leaves a neutral portrait. This is not reconstructed 3D. Physical webcam behavior remains unverified on this SSH host; synthetic camera, actual worker inference and clearly labelled simulated deformation have separate evidence.

Only the picture deliberately captured is sent to OpenRouter. Preview and tracking stay on-device. The server removes temporary capture/output files; it retains hash/cost receipts and short-lived idempotency responses. Provider retention is outside the booth’s control.

## Build and verify

```bash
./webcam-booth/export.sh
node --experimental-strip-types --test webcam-booth/server/*.test.ts
node webcam-booth/testing/browser.mjs
node webcam-booth/testing/tracking.mjs
node webcam-booth/testing/expression.mjs
node webcam-booth/testing/responsive.mjs
scripts/check.sh
git diff --check
```

The browser checks are unpaid. `testing/paid-loop.mjs` is a separately authorized paid check, guarded by an exclusive attempt marker; do not rerun existing slots. Tests use the locally installed Playwright and Chromium. Root `npm ci` supplies pinned Effect for the TypeScript server.

## Serve

The exported page lives in `build/web`. Same-origin generation requires `server/server.ts`, Python Pillow, and the maintained `/home/reidsurmeier/Image-generation-pipline/bin/image-pipeline`. Run through the Bitwarden runner so the OpenRouter key stays in the process environment:

```bash
/home/reidsurmeier/.codex/skills/access-bitwarden-secrets/scripts/stored_bws.sh run OPENROUTER_API_KEY OPENROUTER_API_KEY -- /usr/bin/node --experimental-strip-types webcam-booth/server/server.ts
```

The durable `build/private/ledger.json` must exist. Restore its recorded reservations before restarting if it is missing; never initialize a fresh allowance. Total budget is $10 including generated assets and validation. Unknown submissions retain their reservation and are never retried automatically. A surviving `paid.lock` requires inspecting the existing Run before recovery.

The overnight instance runs as user service `webcam-booth-195.service` with restart-on-failure. Inspect with `systemctl --user status webcam-booth-195.service`. The owner’s HTTPS tailnet preview is recorded in [HANDOFF.md](review/HANDOFF.md); a tailnet connection is required.

Specification: [Issue 200](https://github.com/Reid-Surmeier/risd-godot/issues/200). Provenance, historical motion limits and native failed-video/accepted-assembly distinction: [PROVENANCE.md](PROVENANCE.md). Verification and visual evidence: [review/](review/).
