---
name: collection_data
purpose: Validated RISD artwork search plus browser-local saved works shared by Collection, Playground and Sketchbook
interface: modules/collection_data/interface.gd
errors: modules/collection_data/errors.gd
tests: testing/collection_data_test.gd, testing/saved_destinations_test.gd, modules/collection_data/server/acceptance.test.ts
depends-on: []
---

# Collection data

Issues #78 and #80 freeze create/search/save/saved/state and their wire contracts. Dispatch
acceptance and terminal results are separate; completions happen once. Composition injects one
search adapter, storage adapter and clock into the shared handle used by all three destinations.

`http_adapter()` exposes the production adapter without making composition import a private file;
composition injects its search and image-fetch Callables. It selects same-origin Web or localhost.
`storage_adapter()` uses the fixed `risd-collection-browser` IndexedDB database on Web and volatile
memory in native playtests. Saves are insert-once, ordered by first save time, bounded to 1,000 works
and 4 MiB, and survive browser restarts without an account.

The internal TypeScript/Effect server searches a labelled, immutable corpus. All-word
query, category and verified-image filters precede deterministic sorting and pagination.
A missing cache is unavailable. A museum challenge cannot erase valid cached records.
Only manifest hashes resolve images. No request accepts an upstream URL.

Run `npm run test:collection`, `testing/collection_data_test.gd`, and
`testing/saved_destinations_test.gd`; browser acceptance covers reload persistence.
