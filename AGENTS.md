# Agent operating contract

The GitHub Issue defines the work. Read it, this file, `MODULES.md`, and the named modules' `MODULE.md` files before editing.

## Runtime modules

- Godot 4.7.2 and GDScript are the runtime. TypeScript is used only by the collection-data server and browser checks.
- A runtime module lives under `modules/<name>/` and has `MODULE.md`, `interface.gd`, `errors.gd`, and acceptance tests.
- Other runtime modules may reference it only through `interface.gd`. Dependencies are passed by the caller.
- Public interface functions return `{ ok: bool, value: Variant, error: Variant }`; errors cross a seam as values from `errors.gd`.
- The interface, errors, and acceptance tests are frozen. Changing one, adding a dependency, or moving a seam requires Issue scope that names the change.
- `modules/shell/demo.gd` is the composition root. It may import Tenant interfaces to build the registry; `shell.gd` itself depends only on `tab_strip`.

## Support modules

- `testing/` and `review/` support the workflow; they are not shipped runtime modules.
- Their public files are listed in their `MODULE.md`. Tests may extend `testing/harness_base.gd` and use fixtures declared there.
- `MODULES.md` is the hand-maintained map for both runtime and support modules.

## Project rules

- Use the vocabulary in `CONTEXT.md`: module, interface, seam, adapter, depth, Shell, Tab, Page, Tenant.
- Generated visual files keep their source, provider, cost, and hash in the owning module's `PROVENANCE.md`. Accepted runtime assets live with that module; trials and review evidence do not become runtime dependencies.
- The current build is `build/v0.1.0`; `main` moves only through the release workflow.

## Verify

```bash
scripts/check.sh
git diff --check
```

For visible changes, also run the owning module's playtest and inspect the exported result.
