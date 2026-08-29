---
name: <module-name>
purpose: <one line: what this module does for its callers>
interface: modules/<module-name>/index.ts
errors: modules/<module-name>/errors.ts
tests: modules/<module-name>/*.test.ts
depends-on: []
---

# <module-name>

## What callers get

<!-- The behaviour behind the interface, in plain words. Depth = lots here, little in index.ts. -->

## Frozen

`index.ts`, `errors.ts`, the tests. Changing them is an Issue.

## Inside

<!-- Notes for whoever works inside: shape, trade-offs, what was tried. Free to change. -->
