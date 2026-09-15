---
name: testing
purpose: The harness, fixtures, and test doubles every other module's acceptance tests use
interface: testing/interface.gd
errors: testing/errors.gd
tests: testing/*_test.gd
depends-on: []
---

# testing

## What callers get

One place to take test-time adapters from: a fixed clock, in-memory stores, recorded collection fixtures, and a headless harness that drives the game the way a person does — clicking a control, then reporting what it did, what happened, and whether the interface responded. Acceptance tests in every module take these instead of live services.

## Frozen

`interface.gd`, `errors.gd`, the tests. Changing them is an Issue.

## Inside

`harness_base.gd` is the SceneTree every module's playtest harness extends: the `--out-dir` arg, the clock and log, real clicks and keys through `Input.parse_input_event`, screenshots of the root, and `report.json`; `scripts/playtest.sh <module>` runs one harness on the X display and then the module's `verify.py`.

Keep test doubles here, not scattered in modules. A double only one module needs still lives here, named for that module. A test that asserts on a screenshot the implementation itself produced is not a test — the harness must perform the interaction.

Issue #78 creates the terminal fixture and collection-data seam test. Issue #88 exposes the
asynchronous Collection Page adapter used for success, failure, stale completion, pagination and
the accepted WebP-image path.
