---
name: review
purpose: The packet an independent blind reviewer receives, and the acceptance contract it judges against
interface: review/interface.gd
errors: review/errors.gd
tests: review/*_test.gd
depends-on: []
---

# review

## What callers get

`packet()` builds the review packet for a candidate commit: contract path, hash-locked references, candidate evidence paths, launch and reset commands. The blind reviewer sees only this — never the implementer's narrative. Verdicts are bound to one SHA.

For generated pixels the packet carries the Anchor and the conformed frames side by side, at magnification, plus the certification report. A reviewer judging an Icon or a Motion Pass is judging it against its Anchor, never against the brief that produced it.

## Frozen

`interface.gd`, `errors.gd`, the tests. Changing them is an Issue.

## Inside

Mirror the blind-review gate from `Reid-Surmeier/Qwen-3-pro-Pipeline` (`docs/agents/blind-review.md`): one verdict per round, evidence on disk, a new commit invalidates a verdict.
