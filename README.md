# risd-godot

A Godot 4 game for browsing the RISD Museum collection: a windowed pixel interface where every object in the database is something you can find, look at, turn around, and keep.

Runtime modules use frozen GDScript seams; `testing/` and `review/` are workflow support modules. `MODULES.md` is the hand-maintained map.

| Where | What |
| --- | --- |
| `MODULES.md` | The map of this codebase — read it first |
| `modules/<name>/` | Runtime module: `MODULE.md`, `interface.gd`, `errors.gd`, tests, and implementation |
| `testing/` | Support harnesses, fixtures, and deterministic adapters |
| `review/` | Support contract for SHA-bound release review records |
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
scripts/check.sh       # map, seams, GDScript lint, and project import
git diff --check
godot --path .         # open the current game
scripts/export-web.sh  # generated browser build in build/web/
```

Browser builds need the existing Collection server for same-origin collection requests: run `npm ci --ignore-scripts`, then `RISD_SEARCH_PORT=8142 npm run collection:serve -- build/web`. Publish that port with the `share` skill for access from another device. Exported files and `.godot/` are rebuildable; original images, scans, videos, generation records and uncommitted work are not. Follow the recovery guide before removing any worktree.
