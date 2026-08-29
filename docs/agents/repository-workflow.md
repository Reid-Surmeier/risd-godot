# Repository workflow

```text
finding or need
  -> Issue (needs-triage)
  -> agent triage brief, decisions written into the Issue
  -> ready-for-agent (the agent continues; the owner may pause with needs-human-review)
  -> release branch: implement inside modules; a frozen file or a seam change is a new Issue
  -> npm run check (typecheck, seam lint, tests, map current)
  -> one release PR: plain words, images, checks
  -> owner reads the release
  -> merge
```

Read `MODULES.md` before anything else. Use the chain `wayfinder → to-spec → to-tickets → implement → code-review`. Labels are in `triage-labels.md`; the Issue format in `issue-tracker.md`.
