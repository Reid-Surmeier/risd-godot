---
name: testing
purpose: The harness, fixtures, and test doubles every other module's acceptance tests use
interface: testing/interface.gd + testing/harness_base.gd
errors: testing/errors.gd
tests: testing/*_test.gd
depends-on: []
---

# testing

## What callers get

One support seam for acceptance tests. `interface.gd` provides deterministic collection adapters; `harness_base.gd` is the public base for Godot interaction harnesses. Fixtures live under `testing/`. None of these files ship as a runtime module.

## Frozen

The public support files named above and the tests. Changing their behavior is an Issue.

## Inside

`harness_base.gd` is the SceneTree every module's playtest harness extends: the `--out-dir` arg, the clock and log, real clicks and keys through `Input.parse_input_event`, screenshots of the root, and `report.json`; `scripts/playtest.sh <module>` runs one harness on the X display and then the module's `verify.py`.

Keep test doubles here, not scattered in modules. A double only one module needs still lives here, named for that module. A test that asserts on a screenshot the implementation itself produced is not a test — the harness must perform the interaction.

Issue #78 creates the terminal fixture and collection-data seam test. Issue #88 exposes the
asynchronous Collection Page adapter used for success, failure, stale completion, pagination and
the accepted WebP-image path.
