# Booth

Standalone Godot Web runtime in its own project. It owns preview, capture, loader, ephemeral portrait, fuse/explosion and local expression display. No RISD Tenant or runtime module depends on it.

Interface: `interface.gd` (`capture`, `reset`, `{ok,value,error}` results). Errors: `errors.gd`. Acceptance: `testing/browser.mjs`, `testing/tracking.mjs`, `testing/expression.mjs`, `testing/responsive.mjs` and explicit paid `testing/paid-loop.mjs`. Implementation: `main.gd`; browser adapter `camera.js`. Dependencies supplied by composition: same-origin Generation HTTP service. Interface, errors and acceptance scope were authorized by ticket 201; motion/tracking acceptance additions are expressly scoped by tickets 202–204.

Generation has its own [MODULE.md](server/MODULE.md), the standalone TypeScript/Effect adapter: `server/interface.ts`, errors in `server/errors.ts`, acceptance `server/generation.test.ts` and ticket205 `server/receipts.test.ts`; native HTTP composition in `server/server.ts`. One owner session, one paid operation at a time, persistent reservations, no ambiguous retries. Existing `repos/effect` is exact 3.22.2 source reference.

Testing/review are standalone workflow support folders; evidence is not a runtime dependency. Ephemeral capture bytes are transient private files; the browser has no gallery, saved result or download flow. Ledger retains only hashes, run identity and costs. OpenRouter's retention is not a deletion guarantee.

Issue220 explicitly scopes camera-only acceptance updates and `testing/presentation.mjs`: full preview opening below the original hat, retro display with unchanged source pixels, one animated blue shutter, native media-clock fuse/end synchronization and no sample runtime assets. Generation interface/errors/accounting and existing tracking/expression acceptance remain unchanged.

Issue221 supersedes the CRT-style part of Issue220: existing low-resolution JPEG bridge only, no preview shader. It explicitly scopes updated presentation/responsive acceptance for uniform exposure, original blue icon fallback and actual44px-visible shutter pixels/actions. Other acceptance/interfaces/errors remain unchanged.

Issue223 explicitly scopes camera-on-load and text-free Web controls, Escape cancellation, and native-stage loading. Existing browser/expression/responsive/presentation/paid-loop UI checks adapt to that flow; source-pixel, tracking, video-clock and accounting guarantees remain unchanged. Unpaid testing/clean-flow.mjs checks one automatic camera request, visible-copy removal, real-stage holds, full native loop and cancellation.
