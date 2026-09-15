# RISD search connection (issue #78)

This is a working metadata-route probe, not the finished Collection screen.
Search/sort/page the labelled cached corpus through the same origin as Godot.
The frozen contract is `docs/specs/collection-data-74.md`; only create/search/state
are implemented here. Save operations belong to #80.

## Run

Node 22.23+ and Godot 4.7.2:

```
npm ci
npm run collection:serve -- build/web-search-probe
```

The optional `--refresh` performs one official Monet page request (maximum 25
records, 15 seconds, no challenge retry) before listening. It validates before
atomically replacing the disk corpus. Server requests never crawl the museum.
The bundled snapshot has five official records and two Monet paintings. Their
public-domain object-page carousel entries, exact image bytes, dimensions and
hashes were verified on September 15. Coverage is partial and never represents
the whole museum. A newer complete cache wins; incomplete cache files do not
hide the bundled verified images.

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

Run `modules/collection_data/playtest/export_probe.sh`. It exports an isolated
probe project from the exact module files; release Web templates reject command-line
scene overrides. The product startup scene remains unchanged. The browser
publishes `window.risdSearchProbe`; native writes `/tmp/risd-search78/native-report.json`.
`playtest/verify.py` requires two rendered image hashes. The native and browser
probes both fetch images from the same-origin hash route, verify the bytes, decode
the JPEGs and render them. No guessed URLs or substitute sculpture images are used.
