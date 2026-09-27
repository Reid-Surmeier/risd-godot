# GDScript modules with intact seams

Status: accepted

## Context

The repository template assumed TypeScript, Effect, `index.ts`, and a generated module map. This game runs in Godot 4.7.2, so that inherited decision did not describe the implementation.

## Decision

A shipped runtime module lives under `modules/<name>/`. Its seam is `interface.gd`; its errors are values in `errors.gd`; its acceptance tests exercise the same interface callers use. Public interface functions return `{ ok, value, error }`. Dependencies are supplied by callers, and runtime modules reference other runtime modules only through their `interface.gd` files.

`modules/shell/demo.gd` is the composition root. It imports Tenant interfaces and supplies their adapters. The Shell implementation remains independent of individual Tenants.

`testing/` and `review/` are support modules. Their `MODULE.md` files list their public workflow files; they do not need unused runtime interfaces. Acceptance harnesses may extend the declared `testing/harness_base.gd` support interface.

`MODULES.md` is maintained by hand because GDScript has no package manifest that can generate a complete module map. Each runtime and support module has one row.

The interface, errors, and acceptance tests of a runtime module are frozen. An Issue must explicitly authorize changing them, adding a dependency, or moving a seam.

## Consequences

The seam check inspects GDScript references. TypeScript/Effect rules apply only inside the collection-data server. Module dependencies and support-module exceptions must stay explicit in `MODULES.md` and the owning `MODULE.md`.
