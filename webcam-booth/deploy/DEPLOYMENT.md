# Homework booth — 2026-09-30

Scope and acceptance: [Issue 212](https://github.com/Reid-Surmeier/risd-godot/issues/212).

The standalone Booth runs on `ubuntu-color`, reached with the private `droplet` SSH alias. Public HTTPS is `https://homework.reidsurmeier.wtf/`. The existing Tailscale preview forwards to the same droplet instance through the WSL user service; it no longer runs a second paid adapter.

## Release and state

- Runtime release: `ec3e911dd8375be712157921b11f77d564de7843`, installed at `/srv/sites/homework.reidsurmeier.wtf/releases/ec3e911d`. Runtime source and the exported game are unchanged from the finished Booth; the deployment configurations are in this folder.
- `/srv/sites/homework.reidsurmeier.wtf/current` selects the release. Code and the pinned tool distribution are root-owned. `homework-booth.service` is enabled at boot and restarts on failure; its credential launcher drops to `reidsurmeier` before executing Node.
- Mutable ledger, reservations, receipts and pipeline records live under `/srv/sites/homework.reidsurmeier.wtf/state/`. Systemd bind mounts them into the application's regular directories; the maintained tool refuses configuration symlinks. There is one writable ledger. The obsolete WSL ledger is retained as migration evidence and must not be used to restart paid generation.
- The unchanged Muse tool has artifact SHA-256 `ba0bdabf5c009f2d48362779b131a6b7c65fa16660576946cad18fac72c0d66c` and source commit `3dfb74d44f492adadae916cda942b0d40e8bf386`. Every distribution file was hash-verified on both hosts. Its existing callable path is installed on the droplet; Python Pillow was the only new application dependency.
- The OpenRouter credential was injected by the Bitwarden runner into SSH stdin, then encrypted with the droplet host key at `/etc/credstore.encrypted/homework-openrouter.cred`. The launcher decrypts into process memory. No plaintext credential file, browser key or WSL dependency is required for the public service.

## Routing and startup

Cloudflare's existing tunnel `3d22252d-c86a-44ab-9476-f6fd6b4c128d` has one new DNS hostname and ingress entry: `homework.reidsurmeier.wtf` → `http://127.0.0.1:80`. The explicit IPv4 origin avoids the pre-existing default IPv6 site. Other ingress entries were preserved. Nginx serves the Web export and proxies only `/api/portrait` to the loopback adapter on port 8130. Port 8129 is a loopback nginx listener for the SSH preview.

Nginx serves deterministic gzip sidecars and revalidates cached files using ETags. The engine transfer fell from 39,514,754 to 10,054,758 bytes. On the fixed 10 Mbps cold-browser check, startup fell from 36,052 ms to 12,405 ms on public HTTPS and 12,288 ms on the Tailscale preview. A conditional public engine request returned HTTP 304 and zero body bytes. These are controlled test timings, not a promise for every device.

Normal public and tailnet DNS resolve the hostname. The tailnet resolver had cached NXDOMAIN from before DNS creation; its cache was refreshed by restarting AdGuard after all three upstreams returned the correct record. No filtering rules changed.

## Verify

```bash
node webcam-booth/deploy/check.mjs https://homework.reidsurmeier.wtf/
ssh droplet 'nginx -t && cloudflared tunnel ingress validate'
ssh droplet 'systemctl is-active homework-booth nginx cloudflared AdGuardHome'
```

The browser check uses a cold Chromium context at 10 Mbps, intercepts the portrait API with a historical test result, asserts compressed engine transfer/startup and exercises synthetic camera, native-video fuse/explosion and reset without a paid request. It writes a screenshot and JSON to `/tmp/webcam-deployment.*`; set `BOOTH_DEPLOY_EVIDENCE` to choose another prefix. `BOOTH_DEPLOY_RESOLVE` optionally supplies a temporary Chromium DNS mapping while a newly created record propagates.

The four native Generation checks passed on the droplet, including accounting and failed-save lock retention. Same-origin invalid input returned the validation error; a foreign origin was rejected. Existing classroom and RISD endpoints were also checked. Host snapshots are ignored machine evidence in Workspace Operations; the added runtime reconciles with 45 registered components and zero missing/unmanaged components. `certbot.service` was already failed before this change and is outside this deployment; Cloudflare's public certificate passed HTTPS validation.

## Rollback and future deployments

Keep the state directories and encrypted credential independent of releases. Never initialize a new allowance or recover an ambiguous submission by repeating it. The migrated ledger contained 11 entries and 266 reserved cents before deployment validation, within the original $10 ceiling.

To select a known prior code release, first confirm that no `state/private/paid.lock` is present, create a temporary `current` symlink to that existing release, atomically replace the current selector, then restart `homework-booth.service` and validate/reload nginx. The state mounts stay unchanged. Exercise local HTTP, public HTTPS and the browser check before handing it over.

First-install rollback takes down only this application: stop/disable `homework-booth.service`, unlink its nginx site link, validate/reload nginx, remove only the `homework.reidsurmeier.wtf` ingress entry, validate/restart cloudflared, and remove only its Cloudflare DNS record. Preserve the release, state and credential for recovery. The Tailscale user service is now an SSH forward; restoring the old WSL paid adapter requires first reconciling and transferring the latest droplet ledger, never its stale local copy.

Do not restart or change code while a paid operation is pending. Public captures share the existing serialized adapter and aggregate $10 ceiling; exhausting it leaves the camera preview available, with no further generation. Physical webcam fidelity remains unverified on this SSH host.

## Portrait timeout repair (Issue214)

The browser formerly aborted generation at120seconds while the synchronous proxy connection also had a finite lifetime. New browser captures request asynchronous acceptance and poll the same-origin status route once per second; paid work is submitted once. Both HTTP paths are proxied to the same adapter. Existing synchronous callers still work. Results expire15seconds after delivery, at most60seconds unattended. Reset cancels polling without repeating paid work. Run `node webcam-booth/deploy/timeout-check.mjs` for the unpaid delayed-adapter HTTP/browser check.

Muse validator upgrade: tool issue103 replaces redundant canonical raster walks with native JSON serialization while retaining exact canonical bytes, dimensions/channels and receipt protections. Same droplet, public validator:4760ms before,774ms after (84% lower). The explicit tool lock now selects source8683520ce90e1df15ba5be0344141d2e01e013ea, artifacte6d0a4befe3533e90a257d927c449f035dcdd7fc0e8824d1f432854d279b8075. Full deterministic tool baseline passed. Previous artifact and lock remain recoverable from git and the installed immutable distribution.

Production verification: active runtime release52155bc2c3ad9f5a36bc3a0182b40dadfaea35c9. A fresh synthetic-fixture capture through public HTTPS completed in55742ms, compared with113667ms before (51% shorter). One submission and53short polls; generated portrait, fuse, explosion and camera reset passed; screenshot inspected. Runrun-ded2660c3e9d6b9d319f33af, captureaf7c25d8-3ea0-4d93-8c74-8ee030e0ec97. OpenRouter meta/muse-image,1image,$0.01reserved with actual spend unknown. Receipt retains input/output hashes; ephemeral native payload cleanup verified; delivered result expired with HTTP404; foreign-origin polling403. Aggregate reserved allowance is272cents, below existing1000cent ceiling. Physical webcam not tested.

Host reconciliation after repair:45components, zeroissues. Both tool baselines (precommit/integrated), app scripts/check.sh, strict TypeScript, four accounting tests and the delayed-adapter HTTP/browser regression pass. The first fixture test was stopped before network dispatch because it captured before the preview updated; no paid attempt occurred. The corrected fresh test waited for the injected preview and verified all submitted pixels before allowing dispatch.

## Efficiency audit (Issue218)

Native export exclusions remove server/authoring-only glove-frame-reference.png and portrait-fixture.png from the browser pack, while retaining both repository inputs (including the Muse style input on the server). Pack falls3,932,496 to2,574,456bytes (34.5%). Native canvas resize policy replaces the HTML patch. The provider removes one redundant dry-plan subprocess measured2,075ms on this droplet; its execute command still plans/validates before submission. No provider, resolution, privacy, accounting or tool-lock change. See review/PONYTAIL-AUDIT.md for ranked findings and verification.

Deployed runtime7fb36533c6da756c5105f12fcc047d7c04abae8f. The current selector was switched with no pending paid operation; release copying excluded mutable/private state. State and encrypted credential mounts remain shared and tool identity unchanged. Public cold10Mbps startup12,396ms before versus11,507ms after; compressed pack3,895,077 versus2,540,457bytes. Public sample and three responsive HTTPS layouts pass. One fresh source-verified Muse capture completed51,722ms with49short polls; portrait/explosion/reset passed. OpenRouter meta/muse-image,1output,$0.01reserved, actual cost unknown; runrun-ac1efe05828e395543c22e06. Native ephemeral cleanup verified. Host45components, zeroissues. Rollback: select prior52155bc2 after confirming no paid.lock, retaining the same state/tool/credential.

## Camera-only presentation repair (Issue220)

Current runtime `bede95af792ce23e5b60f1fa32923849f810b9db`, release `/srv/sites/homework.reidsurmeier.wtf/releases/bede95af`. The original blue shutter is the sole camera control, enabling permission then taking a photo; demo/sample assets are excluded from the browser pack. Native shaders place retro video under the hat and stars; photo source pixels remain unchanged. Native video position 10 seconds triggers the burst cut; finished resets the clip. See review/PRESENTATION.md and evidence/presentation-220 for before/after and checks.

Public camera-only loop passed without a paid request; startup 11,012 ms at 10 Mbps. Public mobile/landscape keyboard and 44px controls passed. Host 45 components, zero issues; ledger hash unchanged and no paid lock. Existing encrypted credential, pinned tool distribution and mutable state mounts preserved. Rollback selects 7fb36533, retaining state; that old release still uses its own sample-based checker.

Before activating any new release, normalize **only its public static export**: directories 0755, files 0644, owner root:root; verify nginx can traverse it as www-data. Local tar extraction can preserve 0700 export directory permissions. Never recursively change a running release's bind-mounted private/pipeline/artifact state. Copy releases excluding mutable directories, extract with --no-same-owner, then verify loopback nginx with the public Host header. After activation check the same nginx endpoint as well as port 8130 before testing public HTTPS. This release's initial static 403 was corrected and the complete public checks rerun.

## Subtle camera / visible blue shutter (Issue221)

Current frontend `ddacfdea0c1f44a4bde986e9eebac0f00d3858da`, release `/srv/sites/homework.reidsurmeier.wtf/releases/ddacfdea`. Removed the CRT/palette/pixelation shader; existing320×240 JPEG bridge supplies subtle compression. Original blue icon stays in the frame, with interactive sprite at least44px wide on phones, foreground ordering and hover/press animation. Export versions controls.js by content hash. Original assets and native-video timing remain.

Static export permissions were checked as www-data before atomic activation. The backend code is unchanged, so service PID3218959 stayed running with its previous release cwd/state mounts; public and Tailscale static content follows current. On the next service restart, systemd uses the selected current release and existing shared state. Never initialize/copy a new ledger. Current-task ledger hash1e149dfd48752cff151d31073e008e308929822d6e76137a20b89aede842821a unchanged before/after.

Public no-CRT/blue-sprite/fallback tests and three viewport camera/capture/reset checks passed. Public cold10Mbps startup11,429ms; full portrait/explosion/reset test used an intercepted result, zero provider calls. Host45components/zeroissues. Rollback selectsbede95af with the same backend/state; that release includes the earlier CRT filter. Detailed reference inspection and evidence: review/SUBTLE-CAMERA.md and evidence/subtle-221. Physical webcam untested.
