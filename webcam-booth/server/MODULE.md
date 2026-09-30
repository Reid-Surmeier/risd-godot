# Generation

Standalone TypeScript/Effect adapter for the Booth's same-origin `POST /api/portrait`. Public contract: `interface.ts` (Capture, Portrait, Generation callable Effect type) and `errors.ts`. Composition: `server.ts` owns native HTTP/static serving and provides maintained Muse tooling plus decoded-image validation to `generation.ts`.

Acceptance: `generation.test.ts` checks validation, duplicate reuse, locking, reservation and uncertain failures. Ticket205 explicitly authorizes optional costCents in success/error values and `receipts.test.ts` for actual-charge reconciliation and missing-ledger refusal. No other RISD module imports this adapter. Public types/errors and acceptance remain frozen after those scoped changes.

Provider/key/model/prompt/budget are server-owned. The durable ledger survives exports and must exist in production; losing it refuses paid operation. Request/result image payloads are transient; private native state/request/events plus hashes/costs survive mechanical payload cleanup. One owner session and one pending submission; completed duplicate response retained15seconds, ledger prevents later re-submission. Source reference is repos/effect at exact3.22.2; never import it.
