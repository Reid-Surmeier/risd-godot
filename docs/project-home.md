# Project home and preservation

This is the September 27, 2026 consolidation record for [#143](https://github.com/Reid-Surmeier/risd-godot/issues/143). The owner-approved physical cleanup and canonical-home migration followed verified private backups. The primary project home is now the sole Git worktree.

## One current build

| Location or ref | Role |
| --- | --- |
| GitHub `Reid-Surmeier/risd-godot`, branch `main`, merged PR #38 | Accepted current version |
| `/home/reidsurmeier/risd-godot` | Canonical checkout on `main`, primary Git repository and Orca registration; original assets remain here |
| `asset-authoring/build-integrated/` beneath that home | Unique originals moved from the removed integration checkout; locally ignored through `.git/info/exclude` and excluded from Godot import by `.gdignore` |
| `build/integrated` at `407828a` | Archived historical integration ref in the verified all-ref bundle; removed from the live branch list |
| `prototype/gallery-walk` at `dd6948a` | Archived gallery source merged into the version build; removed from the live branch list |
| `preservation/preconsolidation-build-20260927` at `84dd741` | Previously uncommitted Playground journal study, saved without claiming acceptance |
| `/home/reidsurmeier/risd-godot-ingestion` | Original museum scans, photographs and walkthrough media; private source data |
| `/home/reidsurmeier/runs/risd-godot-preservation/2026-09-27` | Inventory, backup registry, checksums, dirty-tree patches and verification receipts |

Merge `72d95bc` combines the latest Sketchbook branch (`9a19174`) with the retained gallery (`dd6948a`). Merge `407828a` joins the older version-build ancestry while retaining newer Sketchbook corrections. Export exclusions retain assets needed by both. No new character, generated art or retro effect was made in this consolidation.

The audit found **185 Git worktree records, 178 existing directories and five dirty worktrees**. After backup and per-path live-process checks, cleanup removed 183 obsolete worktrees and pruned seven missing records. The canonical checkout is the only remaining worktree. Available disk space rose from 13,356,580,864 to 116,638,490,624 bytes, a gain of 103,281,909,760 bytes (96.2 GiB). Future scheduled work should target the canonical workspace; Orca’s repository-targeted automation mode creates a fresh worktree for every run.

## Where work belongs

| Material | Home and preservation |
| --- | --- |
| Source, recipes, accepted small assets, provenance, docs | Git in the existing module or `image-work/` location; commit intentional files explicitly |
| Large original scans, source media, generated candidates and run receipts | Original directories retained; hashed preservation catalog and private Proton archives |
| Issue scope and Wayfinder decisions | GitHub, linked from [work/index.md](work/index.md); issue/comment snapshot in private recovery metadata |
| Review images and check results | `docs/evidence/`; identify the exact tested commit |
| Exports, `.godot/`, dependency environments and search indexes | Rebuildable; excluded from original-asset backup where classified as such |
| Temporary archives | RAM staging under `/dev/shm`, removed only after upload/download verification |

The catalog distinguishes Git-backed files from authoring originals. It does not pretend generated originals are reproducible from their prompts. Avoid dumping large originals into ordinary Git or creating another complete project copy. Orca's repository base ref is `main`; the Collection server on port 8142 runs from the canonical checkout.

Godot ignores the authoring roots `artifacts/`, `image-work/` and singular `prototype/` through committed `.gdignore` files. This matters when the canonical checkout also holds originals: generation-output JSON had inflated the game pack to 2,043,114,320 bytes. Excluding authoring artifacts reduced it to 126,225,688 bytes (105,142,583 compressed). Package inspection confirmed those roots are absent while plural `prototypes/painting-coverflow/web/` and `modules/shell/prototype/gallery_walk4/` remain included. Source originals were not deleted or changed.

## Backup record

Private destination: **Proton Drive `/my-files/Backups/projects/risd-godot/`**. Each immutable snapshot has a manifest-hash folder with `<backup-id>-<manifest-sha256>.tar` and `<backup-id>-<manifest-sha256>.manifest.json`. The existing Workspace Operations backup runner uploads, downloads, checks both hashes and verifies every archived member. An upload alone is not a verified backup.

Local audit files in the preservation directory:

- `repository-history.bundle`: all local refs before consolidation, including unpublished branches; `git bundle verify` passed.
- `hashed-inventory.json` and `selected-originals.json`: source paths, SHA-256 hashes and deduplicated selections. The selected set is 9,068 unique original files, 12,906,945,296 bytes. Duplicate paths are retained in the full inventory.
- `recovery/`: staged/unstaged binary patches, tracked-file inventories, worktree identity and GitHub issue/comment export.
- `backup-registry.toml`, `run-backups.py`, `receipts/` and `backup-progress.log`: exact upload allowlist and verification evidence. Rebuildable exclusions are recorded in `excluded-rebuildable.json`.

All 35 original-object batches and the initial Git history verified after download; the final recovery metadata also verified. See the [committed receipt catalog](evidence/project-consolidation-2026-09-27/preservation.json). The final metadata folder is `101c3ca1e45d83d10a08f427ea91c6684bbcb36b4018a3f2a601c76c5759de5c` under the Proton destination above. The subsequent incremental Git bundle is identified by `receipts/risd-consolidated-history.json` and issue #143. Do not remove sources based on this document alone. This is a point-in-time preservation run, not a claim that future edits are automatically backed up. Re-inventory new originals and make a fresh Git bundle before a later cleanup.

## Restore without overwriting current work

1. Use the installed `proton-drive` CLI with `PROTON_DRIVE_CREDENTIALS_STORE=pass`. Obtain credentials through the existing encrypted store; never put values in a command or document. Download the history and metadata snapshots identified by the receipts into a new recovery directory. Check `archive_sha256` and every member against the downloaded manifest (the existing `workspace_ops.backups.verify_archive_contents` accepts that manifest). The folder hash identifies the canonical manifest payload, not the formatted JSON file. Before extraction, inspect TAR member paths and reject absolute paths or `..` traversal.
2. Run `git bundle verify repository-history.bundle` from a Git repository, then clone the bundle into a new checkout. Fetch all branch/tag refs from the bundle if the default clone does not create the local branch names you need. Import any subsequent history bundle in chronological order; incremental bundles require the base history.
3. Download original-object batches. Each member is `objects/<sha256>/<original-basename>`. Match it with `selected-originals.json`; use `hashed-inventory.json` to recover every original location, including duplicate paths. Restore beneath a separate recovery root first, not directly over the current home directory. Recheck SHA-256 after writing.
4. Recreate a dirty worktree at the recorded base commit and apply its saved staged and unstaged patches in that order. Restore untracked objects from the inventory separately. Preservation branches are archival source, not automatically approved changes to the game.
5. Import the recovered Godot project, run `scripts/check.sh`, and inspect the current Sketchbook and gallery before replacing any working directory. Register only the recovered canonical repository in Orca; do not recreate 178 historical worktrees.

## Cleanup gate

The final pre-cleanup snapshot is `receipts/risd-final-standard-55a22b26.json`: **8,096 files, 7,728,195,562 bytes**, downloaded and verified member by member. Its manifest folder is `3c75042c1e561b2fb0d6ef688aebaaf91f4c5efa1c1cd2050c0274193e2ed9cc`. It includes a self-contained all-ref Git bundle; an independent mirror restore passed `git fsck --full` and exactly matched all 262 saved refs. Bundle SHA-256: `abe492a5dd4ea1c539b9e7d596bce31e83a556bf77759e419d87e2e5e265de18`. RAM staging was removed only after verification. This snapshot predates this documentation commit; current build history is also pushed to GitHub.

Migration rechecked all 7,965 original-bearing paths against their saved hashes. Eight primary-checkout collisions were moved into `final-standard/primary-checkout-collisions/` in the preservation run directory before switching branches with `--no-overwrite-ignore`. This includes both differing `.qwen-pipeline` configuration files. From the integration checkout, 1,760 unique files moved into `asset-authoring/build-integrated/`; one identical file was deduplicated and no relative-path conflicts remained. `final-standard/migration-originals.json` records every source, destination and hash; its SHA-256 is `23b087f52941e988ead510263fcc037ec2ea898139bd36f88cff8c8e55b5159b`.

The subsequent untracked-folder cleanup moved 9,253 files (3,889,473,507 bytes) from untracked portions of `.qwen-pipeline/`, `image-work/` and singular `prototype/` into `asset-authoring/primary-legacy/<original-relative-path>`. All 5,450 original files matched the verified preservation inventory before relocation; the other 3,803 files are generated import/UID sidecars. Renames overwrote nothing and every destination hash was checked. The mapping is `final-standard/untracked-cleanup-authoring-map.json`, SHA-256 `e543ab30dc4b30e91864ef222e8b199e679b9890d61ae6088807c695ff025e9e`. Tracked source stayed in place. Five dated research notes were secret-scanned and retained in Git, and source UID sidecars were committed with their tracked scripts/shaders. Only `.orca/` machine state was added to the local Git excludes; authoring storage was already excluded. The superseded blue-gallery-window and white-shelf image shares were stopped; the accepted game share remains.

The detached integration checkout was removed through Orca only after proving its sole remaining original was a verified duplicate and no process, open file or share referenced that checkout. `git worktree list` now contains only `/home/reidsurmeier/risd-godot`. Branch cleanup retained exactly seven local and seven remote branches: `main`, `build/v0.1.0`, and five dated preservation branches. Tag `accepted/2026-09-27` remains. The verified all-ref bundle preserves the 247 deleted branch refs and their exact object IDs. Ingestion media was not removed. The [earlier cleanup proposal](evidence/project-consolidation-2026-09-27/cleanup-proposal.md) is historical; executed gates and results live under `final-standard/` in the preservation run directory.

Before any later cleanup, re-inventory new originals and preserve a fresh Git bundle. Branch history alone does not preserve ignored or untracked assets. Keep the existing private receipts and relocation map with any restore: authoring paths are deliberately outside Git and must be recovered from their original paths in the snapshot using that map.
