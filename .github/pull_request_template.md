## What is this release?

<!-- One or two plain sentences a non-engineer would understand. -->

## What changed?

<!-- Plain words. Which modules, what is different now, why. -->

## Look at these

<!--
Required. Screenshots or exported images committed under docs/releases/<version>/ and embedded here:
![what it shows](docs/releases/<version>/<file>.png?raw=true)
Before/after for anything visible. Clear exports for anything generated. A PR without images is not ready.
-->

## Linked Issue

Closes #

## Modules touched

<!-- Name each module. State whether any frozen file (index.ts, errors.ts, acceptance tests) or seam changed — if so, link the Issue that allowed it. -->

-

## Checks run

```text
command: npm run check
result:
```

## What the owner decides

-

## Review checklist

- [ ] A whole release, not a fragment.
- [ ] Plain language; the images show the result.
- [ ] No frozen file or seam changed without its own Issue.
- [ ] `MODULES.md` is current (`npm run map:check`).
- [ ] `npm run check` passed; no secret value recorded.
