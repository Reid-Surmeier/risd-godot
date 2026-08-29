# Issue tracker: GitHub Issues

GitHub Issues are the authoritative work tracker for this repository. Local notes are temporary and never replace or contradict an Issue.

## Issue types

- configuration changes (a platform's settings, identity file, MCP servers, approval posture),
- skill additions, updates, or removals,
- automation changes (cron jobs, timers, services, heartbeat signals),
- audits and investigations,
- bugs in the scripts or in a sync,
- documentation and repository chores.

## Required content

```markdown
## Problem or desired outcome
## Evidence or current behavior
## Expected behavior
## Acceptance criteria
## In scope
## Out of scope
## Verification
## Platforms affected and sync authorization
## Dependencies and approvals
```

## Triage, then go

While an Issue has `needs-triage`, an agent may investigate and comment but must not create a branch, modify files, or run a sync. The comment uses this structure:

```markdown
## Agent triage brief

### 1. Interpretation
### 2. Open decisions
### 3. Proposed scope
### 4. Proposed acceptance and verification
### 5. Recommendation
```

The recommendation is one of: proceed, revise, split, investigate first, or do not pursue. After commenting, the agent decides the open questions with judgment, writes the result into the Issue body (the canonical specification; comments stay as history), replaces `needs-triage` with `ready-for-agent`, and continues. The owner pauses work by applying `needs-human-review`; the agent never applies it.

## Linking work

Branches are named after the Issue; the PR uses `Closes #<n>` when it fully resolves it. Work discovered mid-PR becomes a new Issue.

See [`repository-workflow.md`](repository-workflow.md) for the lifecycle and [`triage-labels.md`](triage-labels.md) for the labels.
