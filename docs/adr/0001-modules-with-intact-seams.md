# Modules with intact seams

Status: accepted (inherited from `Reid-Surmeier/agentic-workflow` ADR 0005 on repo creation).

One folder per module. Its interface (`index.ts`), its error types (`errors.ts`), and its acceptance tests are written first and frozen; the implementation is free. Modules import each other only through `index.ts` — `npm run lint:seams` enforces it. Every public function returns `Effect<Success, Error, Requirements>`. `MODULES.md` is generated from the `MODULE.md` files and is the map. Changing a frozen part or moving a seam is an Issue.
