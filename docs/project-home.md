# Project home and preservation

This is the September 27, 2026 consolidation record for [#143](https://github.com/Reid-Surmeier/risd-godot/issues/143). No original directories were moved or deleted. Physical cleanup is a separate, explicitly approved step after verified backups.

## One current build

| Location or ref | Role |
| --- | --- |
| GitHub `Reid-Surmeier/risd-godot`, branch `build/v0.1.0`, PR #38 | Current version under construction |
| `/home/reidsurmeier/risd-godot-worktrees/build-integrated` | Current build checkout; use this existing folder |
| `/home/reidsurmeier/risd-godot` | Primary Git repository and Orca registration; legacy prototype checkout and original assets remain here |
| `build/integrated` at `407828a` | Historical integration ref; do not continue a competing build here |
| `prototype/gallery-walk` at `dd6948a` | Retained gallery source, merged into the version build |
| `preservation/preconsolidation-build-20260927` at `84dd741` | Previously uncommitted Playground journal study, saved without claiming acceptance |
| `/home/reidsurmeier/risd-godot-ingestion` | Original museum scans, photographs and walkthrough media; private source data |
| `/home/reidsurmeier/runs/risd-godot-preservation/2026-09-27` | Inventory, backup registry, checksums, dirty-tree patches and verification receipts |

Merge `72d95bc` combines the latest Sketchbook branch (`9a19174`) with the retained gallery (`dd6948a`). Merge `407828a` joins the older version-build ancestry while retaining newer Sketchbook corrections. Export exclusions retain assets needed by both. No new character, generated art or retro effect was made in this consolidation.

The audit found **185 Git worktree records, 178 existing directories and five dirty worktrees**. The remaining RISD overnight automation was already disabled when checked. Future scheduled work should target the existing current-build workspace; Orca’s repository-targeted automation mode creates a fresh worktree for every run. An Orca workspace and a Git worktree are different inventories. Do not treat an inactive Orca label as proof a directory can be deleted.

## Where work belongs

| Material | Home and preservation |
| --- | --- |
| Source, recipes, accepted small assets, provenance, docs | Git in the existing module or `image-work/` location; commit intentional files explicitly |
| Large original scans, source media, generated candidates and run receipts | Original directories retained; hashed preservation catalog and private Proton archives |
| Issue scope and Wayfinder decisions | GitHub, linked from [work/index.md](work/index.md); issue/comment snapshot in private recovery metadata |
| Review images and check results | `docs/evidence/`; identify the exact tested commit |
| Exports, `.godot/`, dependency environments and search indexes | Rebuildable; excluded from original-asset backup where classified as such |
| Temporary archives | RAM staging under `/dev/shm`, removed only after upload/download verification |

The catalog distinguishes Git-backed files from untracked originals. It does not pretend generated originals are reproducible from their prompts. Avoid dumping large originals into ordinary Git or creating another complete project copy. A future physical relocation must update Orca, Git worktree links, running services and asset references together.

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

First finish every verification receipt and preserve final consolidation commits. Then identify inactive worktrees with no live process, terminal, server or share, compare their current files against the saved inventory, and list exact paths and reclaimable space. Ask the owner before deleting or relocating them. Keep unique originals and the ingestion directory until their new home is verified. Branch history alone does not preserve ignored or untracked assets.

The [exact cleanup proposal](evidence/project-consolidation-2026-09-27/cleanup-proposal.md) lists 122 inactive automation worktrees, approximately 41.69 GB allocated. It is a proposal, not deletion authorization.
