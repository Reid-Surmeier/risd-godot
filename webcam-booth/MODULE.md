# Booth

Standalone Godot Web runtime in its own project. It owns preview, capture, loader, ephemeral portrait, fuse/explosion and later expression display. No RISD Tenant or runtime module depends on it.

Interface: `interface.gd` (`capture`, `reset`, `{ok,value,error}` results). Errors: `errors.gd`. Acceptance: `testing/browser.mjs` and explicit paid `testing/paid-loop.mjs`. Implementation: `main.gd`; browser adapter `camera.js`. Dependencies supplied by composition: same-origin Generation HTTP service. Interface, errors and acceptance scope were authorized by ticket 201; motion/tracking acceptance additions are expressly scoped by tickets 202–204.

Generation is the standalone TypeScript/Effect adapter: `server/interface.ts`, errors in `server/errors.ts`, acceptance `server/generation.test.ts`; native HTTP composition in `server/server.ts`. One owner session, one paid operation at a time, persistent reservations, no ambiguous retries. Existing `repos/effect` is exact 3.22.2 source reference.

Testing/review are standalone workflow support folders; evidence is not a runtime dependency. Ephemeral capture bytes are transient private files; the browser has no gallery, saved result or download flow. Ledger retains only hashes, run identity and costs. OpenRouter's retention is not a deletion guarantee.
