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

## Current project home

The current combined game is on **`build/v0.1.0`**, in [build PR #38](https://github.com/Reid-Surmeier/risd-godot/pull/38). It includes the latest Sketchbook desktop, painting Cover Flow, and the retained walkable gallery. The gallery character, room finish and retro rendering still need revision; consolidation does not approve their visual quality.

On this machine, work on that branch in `/home/reidsurmeier/risd-godot-worktrees/build-integrated`. The folder name predates consolidation. `/home/reidsurmeier/risd-godot` remains the primary Git/Orca registration and contains original work; it is not the current build checkout. Do not create another copy to resume work.

- [Project home, original assets, backup and recovery](docs/project-home.md)
- [Issues and Wayfinder maps](docs/work/index.md)
- [Preservation and consolidation #143](https://github.com/Reid-Surmeier/risd-godot/issues/143)

## Run and verify

Use Godot 4.7.2 with matching Web export templates. Import a fresh checkout before running checks:

```bash
godot --headless --editor --import --path .
scripts/check.sh       # map is current, seams hold, GDScript lints, tests pass
git diff --check
godot --path .         # open the current game
scripts/export-web.sh  # generated browser build in build/web/
```

Browser builds need the existing Collection server for same-origin collection requests: run `npm ci --ignore-scripts`, then `RISD_SEARCH_PORT=8142 npm run collection:serve -- build/web`. Publish that port with the `share` skill for access from another device. Exported files and `.godot/` are rebuildable; original images, scans, videos, generation records and uncommitted work are not. Follow the recovery guide before removing any worktree.
