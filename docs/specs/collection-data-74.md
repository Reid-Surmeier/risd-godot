# Find, save and study: data contract

Specification for [shared artwork/search/save seams](https://github.com/Reid-Surmeier/risd-godot/issues/74), under [the Collection Browser map](https://github.com/Reid-Surmeier/risd-godot/issues/65). Source baseline: `ba528ec8d3510a496f042706cc1e667e57d0bb2e`. Status: proposed frozen contract; no runtime implementation or acceptance is claimed by this document.

## Problem and outcome

Collection currently shows seven cut-out pictures and decorative search controls. Saving and shared references do not exist. A visitor needs to find real RISD artworks, keep them in this browser, and study them in Playground and beside the original Sketchbook.

The [resolved interaction decision](https://github.com/Reid-Surmeier/risd-godot/issues/69#issuecomment-5682054801) remains authoritative for form behavior. Recommendations below are adopted under the owner's delegated-default authority, not a new human interview or visual review. The [RISD route findings](https://github.com/Reid-Surmeier/risd-godot/blob/623879dc8d0da072931e665fddeea8f206d61950/docs/research/risd-search-route.md) are the source for ingestion; their two-painting-image gap remains implementation acceptance.

### User journeys

1. Search with editable text, category, ordering and image availability; apply or cancel deliberately; distinguish no matches from unavailable search.
2. Select a result, inspect its attribution, and save it once; see the same artwork in both destinations even if neither was opened yet.
3. Reopen this browser after a restart or build update and recover saved metadata, including artworks whose upstream record or image disappeared.
4. Choose a saved reference while retaining strokes, spread, pigment and the original book window; keep the reference visible while drawing.
5. Receive an honest storage error when saving fails, with previous saves preserved and no false Saved indication.

## Module and injection decision

One new game data module, `collection_data`, owns record validation and access to search and saved artwork adapters. Collection owns draft/applied form state and selected result. Each study Tenant owns its reference selection. No Tenant owns another Tenant's saved collection.

Use the existing Shell registry's Callable factories: the composition in `modules/shell/demo.gd` constructs one data handle, captures it in three factories, and passes `{key, collection_data: handle}` to Collection, Playground and Sketchbook. Factory calls still return the existing result shape. The data handle lives with the composition, outside frozen Pages. No autoload, event bus, second copy of the saves, or new public Shell method is needed.

| Seam | Explicit scope for later build tickets |
| --- | --- |
| New `modules/collection_data/interface.gd`, `errors.gd`, `MODULE.md`, `playtest/harness.gd`, `playtest/verify.py` | Freeze the operations, wire records, errors and acceptance below before implementation. All cross-module calls use this interface. |
| `modules/shell/interface.gd`, `errors.gd` | No change. Existing Callable registry is sufficient. Add `collection_data` to composition dependencies in its MODULE/map; production composition imports only the new interface. |
| `modules/collection_page/interface.gd`, `errors.gd`, `playtest/harness.gd`, `playtest/verify.py` | Authorize live controls/results, injected data dependency, data error states and extended state probe. Replace only obsolete decorative-control/seven-card/footer assertions; retain dragging, sizing and freeze checks. |
| `modules/playground_page/interface.gd`, `errors.gd`, `playtest/harness.gd`, `playtest/verify.py` | Authorize injected data, saved items/empty state and removal of decorative contents inside retained frames. Geometry changes wait for the drawing-desk prototype. |
| `modules/sketchbook/interface.gd`, `errors.gd`, `playtest/harness.gd`, `playtest/verify.py` | Authorize injected data, picker/reference selection and probe additions. Preserve drawing, palette and book assertions; any accepted source-variant/layout changes require the separate drawing-desk ticket. |
| `testing/interface.gd`, `testing/errors.gd`, `testing/collection_data_test.gd` | These files do **not** exist at baseline despite MODULES.md naming the interface. Explicitly create the smallest fixture factory seam for recorded search, delayed/out-of-order responses, fixed time, storage denial/corruption and abort. Keep adapters here per testing/MODULE.md. Existing harness_base.gd needs no change. |
| `modules/shell/playtest/harness.gd`, `playtest/verify.py` | Existing acceptance remains frozen and unchanged. A new map-scoped browser journey may use Shell.tenant_state and the extended Tenant probes. `review` frozen files remain unchanged. |

Add new dependency rows to MODULES.md and affected MODULE.md files in the tickets that introduce them. The server transport is an internal adapter of collection_data, with its HTTP contract documented in interface.gd; it is not a second public game module. New server/browser adapter source is TypeScript with Effect on public functions and explicit dependencies; only Godot-hosted code is GDScript. Pin/vendor any new library before writing against it. Reuse old RISD normalization/resolver concepts, not the unrelated site's Next UI or cross-museum search.

### Proposed public operations

All GDScript operations return `{ok: bool, value: Variant, error: null | {code: String, detail: String}}`. A handle is opaque to callers. Proposed operations on `CollectionDataInterface`:

| Operation | Result and contract |
| --- | --- |
| `create(deps)` | `ok(handle)`. Requires injected `search(query, done)`, `load_saves(done)`, `save_if_absent(artwork, saved_at_ms, done)` and `now_ms()` Callables. No network or storage constructed inside the module. Missing/invalid dependencies return `collection_data.invalid_dependency`. |
| `search(handle, query, done)` | Starts one query. Synchronous result is dispatch acceptance only; terminal `done(Result<SearchPage>)` is delivered once, including transport/validation failure. Immediate dispatch error means no callback. Consumers never label success from dispatch acceptance. |
| `saved(handle, done)` | Loads and validates the durable document. Same dispatch/completion convention. Returns `SavedCollection` on completion, or storage error. |
| `save(handle, artwork, done)` | Validates a complete record, supplies injected time, calls atomic save-if-absent. Completion returns `{record: SavedArtwork, inserted: bool, revision: int}` only after commit. A duplicate returns its existing snapshot/time/order, with inserted=false. |
| `state(handle)` | Read-only `ok({pending, saved_revision, storage_status, last_error})`, for diagnostics; not a substitute for querying durable saves. |

The adapter callbacks carry the same explicit result envelope. Catch exceptions in each host adapter, sanitize details, and terminate on timeout/abort; do not throw across the seam. Add errors `invalid_query`, `invalid_record`, `unavailable`, `invalid_response`, `snapshot_expired`, `storage_unavailable`, `storage_corrupt`, `storage_version`, `storage_write_failed`, each prefixed `collection_data.`. Corrupt JSON/wire data is not a zero-result success. Missing upstream images are record-level states, not a failed query.

### Artwork and saved schemas

`Artwork` fields (all required; nullable fields explicitly marked):

| Field | Validation / meaning |
| --- | --- |
| `id`, `web_id` | `id = "risd:" + web_id`; web_id is an unchanged nonempty official string, at most 128 UTF-8 bytes, no controls, slashes, query or fragment delimiters. Never derive it from title, accession or an array position. |
| `title`, `makers`, `dating`, `year_from`, `accession`, `category`, `materials` | Plain decoded text; makers is an array of names; year_from is an integer or null. Category is normalized official `type`; materials preserves official `medium`. Missing display text is an empty string, displayed as Unknown/Untitled as appropriate. |
| `source_url`, `credit`, `rights` | Verified HTTPS RISD object URL; credit string; rights `{status: public_domain|licensed|unknown, evidence_url: String|null, observed_at: UTC timestamp|null}`. Null upstream publicDomain means unknown; retain image-specific permission evidence separately. |
| `image` | Null or `{id, source_url, evidence_url, sha256, mime, width, height, verified_at, rights}` for a verified display image. Hash is 64 lowercase hex, sizes positive integers, MIME one of image/jpeg, image/png, image/webp. No guessed URL or unrelated fallback. |
| `upstream_checked_at`, `availability` | UTC timestamp and `available|unavailable|unknown`. Saved snapshots remain valid when current availability is unknown/unavailable. |

Text fields cap at 4096 UTF-8 bytes each, at most 32 makers, URLs at 2048 bytes, record serialized size at 64 KiB. Sanitize source HTML into text; render as text, never executable HTML or BBCode. Unknown category strings remain their trimmed official value; the explicit map includes `Paintings → Painting`, `Sculpture → Sculpture`. The All option is a filter, never a record category. Case-insensitive category aliases must be recorded with provenance in the normalizer and fixture; do not infer categories from titles.

`SavedArtwork = {artwork: Artwork, saved_at_ms: nonnegative safe integer}`. `SavedCollection = {schema_version: 1, revision: nonnegative safe integer, items: SavedArtwork[]}`. Require unique artwork IDs, at most 1000 items and at most 4 MiB serialized document. Exceeding the limit is a visible storage_write_failed result, never truncation. Display newest saved first, ties by artwork ID ascending. No metadata refresh changes the first-save snapshot/order in this scope. No remove, clear, import, account or sync operation is introduced.

## Search adapter and snapshots

The game uses paths relative to its stable game base: `api/collection/search` and `api/collection/image/<verified-sha256>`. Both are same-origin, GET-only. Browser-supplied URLs are never proxy targets.

Search fields are `q` (trimmed, whitespace-collapsed text, at most 256 Unicode codepoints), `category` (All or a current corpus category, at most 128 bytes), `sort` (`date_asc`, `date_desc`, `title_asc`, `title_desc`), `has_image` (literal true/false), `page` (one-based integer 1..50000), and optional `snapshot` (64 lowercase hex). Reject unknown or repeated fields, malformed encoding, invalid enum/range/oversized requests with HTTP 400 / invalid_query before upstream access. Page size is always 20. Success is `Result<SearchPage>`; failures retain a typed envelope, HTTP 503 for unavailable, 409 for snapshot_expired, 502 for invalid_response.

`SearchPage = {query, query_id, corpus: {snapshot, count, coverage, fetched_at, upstream_status}, total, page, page_size: 20, items: Artwork[], categories: String[]}`. Snapshot is the SHA-256 of the canonical normalized corpus, including its declared coverage and fetch timestamp. Query ID is SHA-256 of canonical ordered query fields plus snapshot. The response echoes the normalized query and requested page. Each page describes the whole indexed corpus, not a museum-wide total.

Filter all corpus records before sorting/pagination. Match every normalized query word, case-insensitively, against concatenated title, makers, accession, dating and materials. Title order uses normalized lowercase Unicode codepoint order (not browser locale); date uses year_from. Unknown dates go last in both directions; all ties use ID ascending. Has Image means verified image metadata exists; false includes both kinds. Failed image loading leaves a selectable metadata record. Categories come from the whole snapshot before query filtering.

An initial Apply takes the latest completed snapshot; pagination pins that snapshot. New official metadata is staged separately and published only for a later explicit Apply. The adapter may start one bounded metadata refresh on Apply without holding up cached results; if no cache exists, it waits up to 15 seconds for initial ingestion then returns unavailable. Retain the current and preceding snapshots for at least one hour; an older unavailable snapshot gives snapshot_expired and a user-triggered Apply action, never silently resets pagination. A cached response always shows indexed coverage, fetch time and cached/upstream-unavailable status. An empty indexed corpus is labelled as such; a failed ingestion is never a successful empty corpus.

Initial ingestion uses the official collection route and a small recorded scope (for example Monet metadata plus the verified painting records), not an incidental full-museum crawl. Scope and actual record count are visible. Request at most one upstream fetch at a time, with 15-second timeout, 5 MiB metadata/HTML cap and 20 MiB image cap; no automatic retry of a challenge. Upstream collection parameters are only documented ones; medium and sort remain local. Follow pagination only on the exact official origin/path and enforce a bounded page budget recorded per refresh. A truncated refresh can publish only with explicitly partial coverage. Preserve the previous valid snapshot on malformed/challenged responses.

Allow upstream HTTPS `risdmuseum.org` for collection JSON and object-page evidence, and `risdmuseum.cdn.picturepark.com` for verified media. Validate parsed URL host, port (443/default), path, absence of credentials, and every redirect before fetching; reject other hosts, IP literals and local/private destinations. Image paths resolve to verified manifest entries by hash, not to arbitrary filesystem paths. Capture record ID → object page/carousel → media URL → downloaded hash linkage. Image permission unknown means metadata may be shown/saved but no new display image is ingested without image-policy evidence. The two Monet IDs in research are candidates, not certified images.

## Applying results and sharing saves

Collection exposes, through its existing state probe, draft and last-successful queries, request generation, loading/error status, result IDs, selected ID, snapshot, coverage, total/page and save status. Its controls remain real focusable Godot controls with the prototype-approved font appearance. The [search-control prototype](https://github.com/Reid-Surmeier/risd-godot/issues/75) owns the visual comparison.

OK/Enter increments a monotonically increasing request generation; previous successes remain labelled as previous while loading. Only a completion matching the current generation and normalized request may replace results. Cancel/Escape invalidates the generation and restores the last successful query/results; before any success it restores defaults. Failure leaves the draft retryable. Popup and composition key handling follow the resolved interaction decision. Pagination uses the applied query, not draft edits. Selecting an artwork is separate from saving it.

Pages read saves on creation and on becoming visible. A successful save updates the shared data revision; the active Collection marks Saved only on terminal commit success. Hidden Pages do not process, poll, redraw or accept input. On show, the destination reloads durable saves before presenting them; already-created and lazily-created destinations converge without Tenant-to-Tenant calls. A save finishing after a Tab switch commits to the data handle; any hidden Tenant UI update waits until it is shown. Ignore completions for freed nodes. Destination probes report saved IDs/revision; Sketchbook also reports selected reference ID/image state alongside its existing stroke/brush/spread fields.

## Browser persistence and delivery identity

Use native IndexedDB, with one database `risd-collection-browser`, database version 1, object store `collection`, key `saved`, containing the versioned SavedCollection above. One readwrite transaction reads, validates, adds only if absent and writes the whole small document. Concurrent browser windows therefore cannot overwrite unrelated saves. Resolve success on transaction complete, not request success. Request strict durability where supported; restart persistence must be tested on the actual browser. This is browser-local commit confirmation, not protection against browser-data clearing, eviction or disk failure. See [IndexedDB transactions](https://w3c.github.io/IndexedDB/#transaction-concept).

A denied/open/blocked/version/quota/abort/invalid-document condition returns the corresponding storage error. Existing documents are never deleted, reset, downgraded or overwritten on validation failure. No missing-record fallback after an error. An absent key alone is the valid empty collection. Preserve raw malformed bytes/values; allow read-only diagnostic export during manual recovery, with no automatic repair in this map. A repeat save of a valid existing ID returns its original record. A test/native adapter exercises the same contract; native persistence is not claimed as a product feature.

Why this adapter: a whole-document localStorage read/modify/write would require additional locking across browser windows; [Web Storage explicitly provides no locking guarantee](https://html.spec.whatwg.org/multipage/webstorage.html#introduction-16). IndexedDB supplies the transaction required here without a storage library. Browser-adapter functions and the Godot bridge must serialize data as arguments/JSON, never interpolate artwork text into executable JavaScript.

**Pinned intended delivery identity:** origin `https://windows-wsl.taile06c45.ts.net`, game base `/risd-collection-browser/`, landing page `/risd-collection-browser/index.html`, database/namespace as above. This is an implementation target, **not a currently published preview**. Storage is scoped to the origin/database name, never the asset SHA or URL pathname. The landing page must remain at this path; SHA-named HTML/JS/PCK/WASM may change beneath it. HTTP responses for the landing page use no-store, versioned assets immutable. A new build never calls deleteDatabase or renames the namespace. Use an isolated browser profile for test saves.

**Delivery gate discovered during specification:** share.py currently appends the session ID and removes session shares at handoff; it has no stable-path option. A session gallery does not fulfill the stable-game-path acceptance. Before a persistence build is accepted, resolve a supported stable publishing route through the approved share workflow, scoped to this map, without editing another checkout, spoofing session identity, adopting another worker's mount or hand-writing Tailscale state. Track this explicitly as a child decision; data/query work can proceed independently. Temporary review links remain valid for visual inspection only. No currently live preview is repointed by this specification.

## Acceptance and evidence

Freeze these journeys in the implementing tickets before implementation. Assertions use public results/probes and observed inputs, not private implementation calls.

| Journey | Required evidence |
| --- | --- |
| Search semantics | Recorded corpus >20 items spanning Painting/Sculpture, mixed materials, equal/unknown dates, entities and missing images. Four orders, All/category, all-word query, image checkbox, empty and page 2 verified across the entire stated snapshot. |
| Live painting ingestion | Two actual RISD Painting records with independently verified object-to-image chains, decoded images, hashes, rights evidence and successful rendering through the real same-origin route. Fresh official metadata fetch plus explicit cached/challenged evidence; sculpture fixtures alone cannot pass. |
| Form lifecycle | Actual mouse/keyboard typing, dropdown choice, Tab/Shift+Tab, Space, OK/Cancel, Enter/Escape, popup handling and composition. A succeeds; B fails; Cancel restores A. Out-of-order requests and canceled pending request cannot replace newer state. |
| Snapshot/outage | Refresh cannot reorder an existing page; next-page uses same snapshot. Snapshot expiry is explicit. Upstream outage retains labelled prior/cached data; zero-match success differs visibly from failure. Broken image remains selectable with title/credit. |
| Save and destinations | Save same ID from two searches; first saved time/order unchanged. Save before either destination exists; both later list the same ID. Repeat with destinations already created, hidden, then shown. |
| Persistence and errors | Close/reopen a persistent browser profile; install a second SHA build at the same canonical path; retained IDs/metadata. Denied, quota, abort, malformed and newer-version records preserve originals, with no false Saved. Two browser windows saving different IDs retain both; duplicate IDs retain first committed snapshot. |
| Study behavior | Real reference selection, paint stroke, reference switch, spread turn/back, Tab switch/resume: strokes, pigment, brush and spread remain intact; reference is visible while drawing. Frames/layout retained in Playground; empty state exists. |
| Presentation/integration | Native and actual-browser tests at 1920×1080 and small-window 720×486; accepted CRT, white brightness, no black bars. Fresh cache-safe export, decoded/inspected screenshots, served asset hashes, before/after images and plain changelog on the existing whole-version PR; independent Standards/Spec review of exact candidate. |

Reuse `testing/harness_base.gd`, the module playtests, and `modules/shell/playtest/browser_play.py`/`crt_browser.mjs`. Playtest-Godot's `text_field_probe.gd` and `toggle_probe.gd` demonstrate real input events and captured results; read under `/home/reidsurmeier/Playtest-Godot/Playtest-Godot/modules/godot-runtime/godot/`. Screenshots must be inspected visually and record source hashes/provenance. Run `scripts/check.sh` and `git diff --check`; keep failing checks visible. No paid generation is required for data work.

## Ticket order and limits

Create native map children: (A) same-origin verified search adapter and data seam, verifiable through real HTTP and a native/browser probe; (B) functional Collection form/results, blocked by A and the search-control prototype; (C) durable Save plus both study destinations, blocked by B, the drawing-desk prototype and stable publishing decision. A and C explicitly authorize the new testing seam; B/C authorize only the existing frozen files listed above that they touch. The delivery decision can resolve in parallel with A.

The stable-publishing decision remains open, so this document alone does not resolve all of the specification ticket's acceptance. The complete map build specification also waits for selected-tab, drawing-desk and scan decisions. Accounts/sync, full-resolution offline downloads, removal/repair UI, unrelated tabs, new generated icons and changes to the original drawing engine are out of scope. Do not release, merge unrelated branches or disable the automation from this partial specification.
