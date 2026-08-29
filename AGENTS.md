# Agent operating contract

How any coding agent works in this repository. Vocabulary is in `CONTEXT.md`; decisions in `docs/adr/`; what to do is in the GitHub Issue.

## Read first

1. The Issue and its acceptance criteria.
2. This file.
3. `MODULES.md` — the map. Then the `MODULE.md` of every module the Issue names.
4. `CONTEXT.md` and the ADRs that apply.

## Modules

- A module is a folder with an interface (`interface.gd`), its error types (`errors.gd`), its acceptance tests, and a `MODULE.md`. Say module, interface, seam, adapter, depth — never "boundary".
- **Frozen:** the interface file, the error types, the acceptance tests. **Free:** everything else inside the folder — choose the best solution there.
- Changing a frozen file, adding a dependency between modules, or moving a seam is a new Issue, never a side effect.
- Modules talk to each other only through `interface.gd`. `scripts/check.sh` fails otherwise; CI runs it.
- **The host forces GDScript**, so Effect does not apply. Every public function returns an explicit result — `{ ok: bool, value: Variant, error: Variant }` — and never raises across a seam; errors are values declared in `errors.gd`; dependencies are passed in by the caller, never constructed inside. The rule Effect was enforcing still holds: errors and dependencies are visible in the interface.
- After adding or renaming a module, update `MODULES.md` by hand; CI fails if a `MODULE.md` has no row.

## Workflow

`wayfinder → to-spec → to-tickets → implement → code-review`. Triage an Issue, write the decided scope into it, label `ready-for-agent`, continue. Pause only when the owner applies `needs-human-review`; never apply it yourself.

## Verify before a PR

```bash
scripts/check.sh
git diff --check
```

## Generated pixels

Icons and their motion are model output, never hand-authored and never procedurally drawn. Qwen produces the still; Seedance produces the Motion Pass; the only code permitted to touch generated pixels is the retro-conformance reduction, which snaps to grid and locks the palette. An uncertified conformed run is evidence, not a deliverable. Vocabulary is in `CONTEXT.md`.

## Pull requests are releases

One PR per whole version, written in plain words, with screenshots or exported images attached (clear exports for anything generated). Real command output after the pictures. The template asks for each.

## Secrets and identity

Never a secret value in a file, argument, log, or chat; values come from Bitwarden Secrets Manager through the `access-bitwarden-secrets` runner. GitHub as `Reid-Surmeier` only. Paid actions only via OpenRouter — judgment under 5 USD with the spend recorded, approval above.

## Stop and ask when

Acceptance criteria are unclear; an ADR conflicts; a secret shows up; a change would cross a seam the Issue didn't name; Git identity is missing.
