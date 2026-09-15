# RISD search connection (issue #78, incomplete)

This is a working metadata-route probe, not the finished Collection screen.
Search/sort/page the labelled cached corpus through the same origin as Godot.
The frozen contract is `docs/specs/collection-data-74.md`; only create/search/state
are implemented here. Save operations belong to #80.

## Run

Node 22.23+ and Godot 4.7.2:

```
npm ci
mkdir -p modules/collection_data/server/cache
cp docs/evidence/collection-search/corpus.json modules/collection_data/server/cache/corpus.json
npm run collection:serve -- build/web-search-probe
```

The optional `--refresh` performs one official Monet page request (maximum 25
records, 15 seconds, no challenge retry) before listening. It validates before
atomically replacing the disk corpus. Server requests never crawl the museum.
The default snapshot has five official records, two paintings, and no verified
painting images. One painting's metadata was freshly fetched on September 15.
`upstream_status=unavailable` records the challenged broader query. Coverage is
partial and never represents the whole museum.

The composition creates `http_adapter.gd`, sets the game base URL, and passes
its dispatch Callable to `CollectionDataInterface.create`. Existing game Tenants
are untouched. No direct museum request is made by the browser.

## Checks

```
npm run test:collection
godot --headless --path . --script testing/collection_data_test.gd
DISPLAY=:0 godot --path . res://modules/collection_data/playtest/probe.tscn
scripts/check.sh
```

Export Web to `build/web-search-probe/index.html`, then set GODOT_CONFIG.args to
`["res://modules/collection_data/playtest/probe.tscn"]` in that generated HTML.
This runs the probe without changing the product's startup scene. The browser
publishes `window.risdSearchProbe`; native writes `/tmp/risd-search78/native-report.json`.
`playtest/verify.py` deliberately requires two rendered image hashes and **does
not pass yet**. Do not describe this checkpoint as completed painting ingestion.

Still required: object-page/carousel/image linkage, two permission-verified
painting images and real image rendering, additional invalid-response/transport
checks, and exact-candidate independent review. Museum object pages returned
403 at this checkpoint. No guessed URLs or substitute sculpture images were used.
