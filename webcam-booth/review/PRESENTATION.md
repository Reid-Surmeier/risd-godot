# Camera presentation repair — Issue220

Runtime bede95af792ce23e5b60f1fa32923849f810b9db, droplet release bede95af. Public https://homework.reidsurmeier.wtf/ and the existing Tailscale preview reach the same service. No provider call or spending change.

The live regression initially failed with white RGB255 at both sides of the opening. The old preview occupied only(135,235,755,285), drew above an opaque original frame and used aspect-fit. It now fills(113,65,805,438) with native aspect-cover; the original frame draws above it. A shader opens the near-white background while retaining the cream hat and its white face highlight. Original PNG bytes remain unchanged. One CSS crop of the original blue48×49icon enables permission, then takes the photo. Hover/press animation, keyboard focus,44px minimum touch target and reduced-motion support are checked. Demo/fixture runtime branches, buttons and example photos are absent from the pack; historical fixtures remain server/test assets.

The preview shader uses160×120 nearest pixel cells,31-level channels and subtle alternating scanlines. Every submitted PNG pixel equals the decoded raw camera JPEG; display effects are not baked into Muse's identity source. No camera, loader, provider, privacy or accounting dependency is added.

The old portrait/reset cuts used wall time independently of the native video. The portrait now clears at native stream position10seconds, matching the existing first burst frame; the native finished signal resets the11second clip. The four-times CPU-throttled loop passed: cut at10.028775native seconds, versus10.004667normally. Explosion screenshot covers the former portrait; capture memory and tracking clear.

## Verification

- Local exported browser:12checks, including two complete camera loops, CPU slowdown, pixel identity, repeated capture, cancel, delayed/failure recovery, pagehide, ended tracks, stale permission and denial. Existing expression and pinned478-landmark worker/no-face/recovery acceptance passed unchanged.
- Public presentation test: full aperture coverage, opaque hat highlight, nearest blocks/scanlines, correct original blue-button position, hover/press/reduced-motion, no demo. Public intercepted camera→portrait→explosion→camera passed. Public portrait image is the historical fixture fulfilled by Playwright; no generated response was claimed.
- Public cold10Mbps startup11,012ms; compressed WASM10,084,286bytes, decoded39,514,754. Three public viewports390×844,844×390,1024×700 passed keyboard and44px touch assertions. Tailscale HTTP200. Pack2,574,456→1,838,164bytes; separate original camera icon source PNG is served for the browser shutter.
- Five Generation/accounting tests, strict TypeScript, delayed-adapter timeout check, scripts/check.sh and git diff --check passed. Repository import retains the known eight ObjectDB exit warnings, with no script errors.
- Fresh host reconciliation45components, zeroissues; nginx/Cloudflare ingress valid and four relevant services active. Ledger SHA256 eb4f570ac172096e42f0349a3e6c5df4c75bf1eedac0ef38999aacadfea24cae unchanged before/after; no pending paid.lock. Existing tool lock/artifact, encrypted credential and state mounts preserved.

The first post-activation public read returned403 because the local export directory's0700mode was retained by tar. Set only the release's public static directories0755/files0644 and code ownershiproot:root; reran nginx-originHTTP200, both public browser regressions and host reconciliation. Future deployment instructions now require this check before activation. Initial unsuccessful availability checks made no paid requests.

Evidence: evidence/presentation-220/before.png and public-camera.png; public-portrait.png;04-explosion.png; two mobile camera screenshots; browser/expression/tracking/responsive/public/public-presentation JSON. Synthetic cameras only; physical webcam fidelity remains untested on this SSH host. Historical sample inputs are test/provenance assets, absent from the public runtime/demo flow.

Rollback: wait for no state/private/paid.lock, stop service, atomically select previous7fb36533, start homework-booth.service, validate/reload nginx and run the browser check matching that release. Preserve the same mutable state, ledger, credential and tool. Next action: owner opens the public site and presses the blue shutter. No blocker remains.
