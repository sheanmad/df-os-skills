---
name: edit
description: Edit a DF Labs (Clio) task's properties — set its project, assignee, sprint, done-test, brief, or rename it. Use when the member says "assign T-0xx to ...", "set the project", "add a done-test", "rename the task", "pindah ke sprint ini". Properties only — moving status is a report, not an edit.
---

# Edit a task's properties

```
bash "${CLAUDE_PLUGIN_ROOT}/scripts/clio.sh" edit T-041 project=events
bash "${CLAUDE_PLUGIN_ROOT}/scripts/clio.sh" edit T-041 assignee=budi
bash "${CLAUDE_PLUGIN_ROOT}/scripts/clio.sh" edit T-041 sprint=2026-W38
bash "${CLAUDE_PLUGIN_ROOT}/scripts/clio.sh" edit T-041 doneTest="poster public and registration live"
bash "${CLAUDE_PLUGIN_ROOT}/scripts/clio.sh" edit T-041 title="<new title>" brief="<context>"
```

- Properties: `title`, `brief`, `project`, `sprint`, `assignee`
  (comma-separated slugs allowed — shared work is one task), `unit`, `doneTest`.
- **Status is refused here.** Moving a task is a report, because every move on
  this board carries the words that justify it — use `report`.
- Putting your own name on an unclaimed task is `claim` in `checkin`.
- Each edit is a signed commit; surface the hash.

<!-- AUTH: calls go through the plugin's script, which signs in the way every DF Labs plugin does: if ~/.config/dfos/token (or $DFOS_TOKEN) exists it is used as a terminal pass; otherwise it signs in at DF-OS once with the member's slug and DF-OS password (from ~/.config/dfos/{slug,pass} or $DFOS_PASSWORD, else asked) and keeps the session under ~/.config/dfos/ for 30 days, shared by every plugin. On a sign-in error, tell them to set ~/.config/dfos/slug and give their DF-OS password once; dfos defaults to https://os.dflabs.id. Never echo the password, the pass, or the cookie. -->
