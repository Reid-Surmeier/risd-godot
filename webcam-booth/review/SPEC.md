# Authoritative specification snapshot

Source: https://github.com/Reid-Surmeier/risd-godot/issues/200

## Problem Statement
The FigJam webcam booth must work as its own Godot project. A visitor should see their camera inside the supplied retro window, become a faceted portrait, watch a ten-second fuse explode, and return to the camera. The existing prototype uses a sample portrait and an empty explosion placeholder.

## Solution
Complete an ephemeral HTTPS booth in the owner's separate worktree. Capture one photo, show the existing dots/bar loader while OpenRouter Muse edits that photo with the supplied low-poly style reference, then display the portrait in a glove-held frame. Run a ten-second fuse and a reusable explosion, remove the portrait and return to the live camera. After this basic loop works, add on-device expression tracking and bounded 2D portrait deformation.

## User Stories
1. As a visitor, I want to grant camera permission and see a retro preview, so I can compose a photo.
2. As a visitor, I want a sample-photo option, so I can inspect the experience without camera hardware.
3. As a visitor, I want my actual capture transformed with the reference's facets, sun and blue background, so the result represents me.
4. As a visitor, I want loading feedback and cancellation, so a slow provider does not trap me.
5. As a visitor, I want the supplied frame and white-glove visual direction, so the booth matches the board.
6. As a visitor, I want a ten-second fuse followed by an explosion, so each portrait is ephemeral.
7. As a visitor, I want to return to the camera automatically, so I can take another picture.
8. As a visitor, I want smiles, blinking and head movement to affect the portrait, so it feels alive.
9. As a visitor, I want a neutral portrait when tracking is unavailable, so the basic experience still works.
10. As a visitor, I want recoverable permission, network and generation errors, so I can try again deliberately.
11. As the owner, I want keys confined to the server, bounded request sizes, idempotent submissions and aggregate spend accounting, so browser requests cannot exhaust the budget silently.
12. As the owner, I want provenance, viewed exports, test evidence and an independent review, so completion is supported by evidence.

## Implementation Decisions
- Standalone Godot Compatibility Web project; no RISD runtime integration or changes to existing frozen interfaces.
- One Booth runtime interface and one Generation adapter interface, with explicit error values and acceptance checks written first. Browser tests remain the highest seam. The native HTTP adapter uses TypeScript and Effect; camera and tracking run locally in the browser.
- State sequence: camera → loading → portrait (ten seconds by wall time) → explosion → camera. Cancellation invalidates stale results. Reset releases capture/result references; there is no gallery or download flow. Provider retention is not represented as guaranteed deletion.
- Generation uses maintained Muse tooling, ordered subject/style references, immutable per-request records and a serialized aggregate ledger. A request reserves funds before submission and never retries an ambiguous call. Maximum total spend is $10 including the existing $0.01 pilot and reusable assets. Only the owner session is served; no public anonymous launch.
- Actual source gameplay identifies the Rude Awakening visual. A ten-second full-portrait explosion is an authored adaptation, recorded as historicalFidelity:false. OpenRouter Seedance 2.5 or better is used for reusable motion; matte removal is allowed when native alpha is unavailable.
- Expression tracking uses pinned MediaPipe assets in a worker. 478 landmarks and blendshapes control a bounded 2D textured face mesh; this is not a reconstructed or rigged 3D head. No-face and worker failures restore neutral geometry.
- Existing-workspace heartbeat continues only this scope. Owner has delegated seam, ticket and visual decisions and instructed no questions.

## Testing Decisions
- Test user-visible state transitions, cancellation, camera track loss, denial and repeated loops in Chromium against the actual Godot export.
- Test the Generation adapter's validation, concurrency, idempotency, reservation and uncertain-failure behavior with an unpaid deterministic provider; separately verify the real Muse route with a single paid capture.
- Inspect actual exported screenshots and motion. Record exact hashes, provider/model/count/cost and distinguish synthetic camera tests from physical hardware.
- Verify worker inference on supplied photo and blank input, then geometry response to expression inputs and failure fallback. Run repository baseline and independent gpt-6.1-sol/high review at the final candidate.

## Out of Scope
RISD integration, galleries/downloads, identity storage, public multi-user service, custom 3D reconstruction, other paid providers, spending above $10, and claims of physical webcam verification on this SSH host.

## Further Notes
Planning map: https://github.com/Reid-Surmeier/risd-godot/issues/195 . Prototype candidate 09f6d316 verifies eight browser checks and a real $0.01 Muse sample. The owner requests all tickets completed autonomously overnight. Delivery remains on the separate project branch; main stays unchanged.


## Recorded refinements

Implementation refinement from verified tracking research: use one native CanvasItem UV-deformation shader on the existing portrait instead of constructing a Polygon2D grid. The same bounded2D blink/smile/jaw/pose behavior and no-face fallback remain required; this does not reconstruct a3D head or change the Booth interface.

## Ticket 205: receipt scope

## Parent

https://github.com/Reid-Surmeier/risd-godot/issues/200

## What to build

Keep the booth's aggregate allowance truthful when actual provider cost differs from its estimate, and refuse paid generation if its durable ledger is missing. The real Seedance receipt was2.55195 against2.55 estimated; its manual ledger is already corrected. Runtime Muse receipts should also reconcile actual charges before the next capture.

## Acceptance criteria

- [ ] Explicit scope: extend the frozen Generation success/error value with optional costCents, and add receipt acceptance alongside the existing tests. Existing callers may omit it to represent unknown cost; absence retains the full reservation.
- [ ] Actual receipt charges round upward to cents, replace lower estimates, persist before releasing the paid lock, and gate every subsequent request. Uncertain failures retain at least their reservation.
- [ ] The production server refuses to start a paid adapter if the ledger disappeared; restarting never silently grants a new10USD allowance.
- [ ] Unpaid success-overrun/failure-overrun/missing-ledger checks and strict TypeScript pass. No paid calls needed.

## Blocked by

https://github.com/Reid-Surmeier/risd-godot/issues/201
