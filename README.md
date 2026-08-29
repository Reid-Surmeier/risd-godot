# risd-godot

A Godot 4 game for browsing the RISD Museum collection: a windowed pixel interface where every object in the database is something you can find, look at, turn around, and keep.

This repository follows the [agentic-workflow](https://github.com/Reid-Surmeier/agentic-workflow) pattern: one module per folder, a frozen interface per module, a hand-maintained map. **The host forces GDScript**, so the TypeScript and Effect parts of the template do not apply here — see `MODULES.md`.

| Where | What |
| --- | --- |
| `MODULES.md` | The map of this codebase — read it first |
| `modules/<name>/` | One folder per module: `MODULE.md`, `interface.gd`, `errors.gd`, tests, then whatever the implementation needs |
| `testing/` | The testing module: harness, fixtures, contract tests |
| `review/` | The review module: the packet a blind reviewer gets, and the acceptance contract |
| `docs/adr/` | Decisions |
| `AGENTS.md` | How agents work here |

## Verify

```bash
scripts/check.sh       # map is current, seams hold, GDScript lints, tests pass
```

Nothing to install yet: the Godot project lands with the first module.
