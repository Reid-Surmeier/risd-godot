# Triage labels

Labels say who acts next. They are gates, not priorities.

| Label | Who applies it | Meaning | Exit |
| --- | --- | --- | --- |
| `needs-triage` | the issue form | New. An agent may investigate and post a triage brief; no branch, no edits, no sync yet. | The agent posts the brief and applies `ready-for-agent`. |
| `ready-for-agent` | the agent, after its brief | The Issue body holds the decided scope, acceptance criteria, verification, tools affected, and whether `sync.py --apply` is allowed. Work continues. | The release PR merges. |
| `needs-human-review` | **the owner only** | Pause. The agent stops until the owner removes it. An agent never applies this label. | The owner removes it (optionally after editing the Issue). |
| `needs-info` | anyone | A missing fact would change the result. | The fact is added. |
| `ready-for-human` | anyone | A step only the owner can do (rotate a token, pay, pair a device). | The owner does it and says so. |
| `blocked` | anyone | Waiting on a named dependency (another Issue, a merge). | The dependency lands. |
| `wontfix` | the owner | Not doing it. | Closed with the reason. |

An agent decides open questions with judgment and writes the decision into the Issue. If the owner disagrees, the pause label is the brake.
