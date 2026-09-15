# Browser-local RISD saves

![Two saved works in Playground](01-playground-saved.png)

![Saved works selectable above Sketchbook](02-sketchbook-reference.png)

![Saved works after closing and reopening Chrome](03-reopened-sketchbook.png)

Exact tested build: `59bac9d.html` on the retained `risd-desktop-godot-f57d02de` origin.

The Playwright journey opened two game pages, saved a different RISD artwork from each at the same
time, verified both committed records and images in Playground and Sketchbook, closed Chrome, then
reopened the same browser profile and verified both records again. `report.json` records the IDs,
destinations, restart result and zero unexpected browser errors.

Run:

```bash
PLAYWRIGHT_MODULE=/path/to/playwright/index.mjs \
  node modules/collection_data/playtest/saves_browser.mjs URL OUT_DIR
```
