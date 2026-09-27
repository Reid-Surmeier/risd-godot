---
name: review
purpose: The packet an independent blind reviewer receives, and the acceptance contract it judges against
interface: review/MODULE.md + docs/releases/<version>/REVIEW.md
errors: n/a
tests: repository release-evidence checks
depends-on: []
---

# review

## What callers get

This support module defines the review record rather than a shipped GDScript interface. `docs/releases/<version>/REVIEW.md` records the candidate commit, acceptance source, evidence, Standards findings, Spec findings, Ponytail findings, and verdict. Verdicts are bound to one SHA.

For generated pixels the packet carries the Anchor and the conformed frames side by side, at magnification, plus the certification report. A reviewer judging an Icon or a Motion Pass is judging it against its Anchor, never against the brief that produced it.

## Frozen

The review record format and release-evidence checks. Changing them is an Issue.

## Inside

Visual work includes the accepted reference and candidate evidence. A new commit invalidates the verdict. Review has no runtime implementation or error surface.
