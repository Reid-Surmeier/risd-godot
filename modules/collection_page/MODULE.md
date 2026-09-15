---
name: collection_page
purpose: Native RISD search controls and verified results inside the prototype-81 Image Viewer desktop
interface: modules/collection_page/interface.gd
errors: modules/collection_page/errors.gd
tests: modules/collection_page/playtest/harness.gd + modules/collection_page/playtest/verify.py
depends-on: [shell, collection_data]
---

# collection_page

## What callers get

`CollectionPageInterface.create(deps)` requires an injected `collection_data` handle and returns a full-rect Control that satisfies the Shell's Tenant contract. The production composition supplies the same-origin HTTP adapter through a Callable registry factory. The Tenant lays out from its own size and exposes its window and search state through `state()`.

The original Image Viewer desktop and draggable source windows remain. The Search filters body now contains native text, four-order/category dropdowns, Has Image, OK and Cancel controls. The Image Viewer renders validated RISD results, verified images, attribution, totals, coverage, freshness, missing-image state and selection details. Draft changes wait for OK/Enter; Cancel/Escape restores the last successful query. Loading retains prior results, failures stay distinct, and old completions are ignored. The source frame, dragging, stacking, resize and hidden-Page freeze behavior remain.

The desktop keeps prototype-81's draggable source windows and fill rule. The live controls cover the old Search-filter decoration and verified cards cover the old fixed artwork cuts and fake count. A press raises the topmost window under the pointer; title bars drag within the Page; the viewer resizes from its lower-right corner with a 531x250 minimum. Native text and controls use `PixelMplus12-Regular.ttf` and fit inside the filter frame down to the accepted 720x486 browser size.

Frozen while hidden: the Shell hides the Page (`visible = false`, `process_mode DISABLED`). Frame and input counters stand still. A search reply arriving while hidden is held and applied when the Collection Tab becomes visible again.

## Frozen

`interface.gd`, `errors.gd`, the playtest harness and its verifier. Changing them is an Issue.

## Inside

`viewer.gd` owns layout, dragging and composition; `desktop.gd` owns the source windows; `search_ui.gd` owns native controls and result presentation. It talks to `collection_data/interface.gd` only. The testing module supplies deterministic playtest replies through its public interface.

`scripts/playtest.sh collection_page` drives Unicode input, Tab/Shift+Tab/Space/popup keys, Enter/Escape, success, failure, retry invalidation, pending cancellation, retained image completion, stale completion, pinned pagination, empty, missing, broken and WebP images, snapshot-expired retry, keyboard selection, dragging, resize, hidden reply and 720x486 fit through real input events. The independent verifier checks exact requests and state plus screenshot hashes (46 checks). Browser evidence uses the production HTTP adapter and same-origin server. Accepted evidence is in `docs/evidence/collection-page-search/`.
