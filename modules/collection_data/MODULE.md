---
name: collection_data
purpose: Validated RISD artwork queries over an injected same-origin search adapter
interface: modules/collection_data/interface.gd
errors: modules/collection_data/errors.gd
tests: modules/collection_data/playtest/harness.gd, modules/collection_data/server/acceptance.test.ts
depends-on: []
---

# Collection data

Issue #78 freezes create/search/state and the search wire contract before implementation.
Saving is a separate authorized extension in #80. Only `deps.search` is required for
this subset. Dispatch acceptance and terminal results are separate; completions happen
once. The composition constructs the HTTP adapter; the module never constructs it.

`http_adapter()` exposes the production adapter without making composition import a private file;
composition injects its search and image-fetch Callables. It selects same-origin Web or localhost.

The internal TypeScript/Effect server searches a labelled, immutable corpus. All-word
query, category and verified-image filters precede deterministic sorting and pagination.
A missing cache is unavailable. A museum challenge cannot erase valid cached records.
Only manifest hashes resolve images. No request accepts an upstream URL.

Run `npm run test:collection` and the native/browser probe described in README.md.
