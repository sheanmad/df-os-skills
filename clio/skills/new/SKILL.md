---
name: new
description: Mint a new DF Labs (Clio) task. Use when the member says "new clio task", "add a task to DF", "buat task", or a brainstorm produces work worth tracking. Writes a signed commit and returns the new task id.
---

# Mint a task

```
bash "${CLAUDE_PLUGIN_ROOT}/scripts/clio.sh" new "<title — name the result, not the activity>"
bash "${CLAUDE_PLUGIN_ROOT}/scripts/clio.sh" new "<title>" project=website sprint=2026-W38 doneTest="<how we will know it is done>"
bash "${CLAUDE_PLUGIN_ROOT}/scripts/clio.sh" new "<title>" assignee=ana brief="<one paragraph of context>"
```

Fields (all optional after the title): `project` (slug), `sprint` (id),
`assignee` (slug — defaults to you), `doneTest`, `brief`, `unit`
(`task` or `question`).

- The title names the result. "Poster public" beats "work on poster".
- A task with no done-test cannot be finished, so ask for one when the work
  is concrete enough to have it. A `question` unit is for open questions.
- Work you take on yourself is born `self-added`; work minted for someone
  else is born `planned`. The gate decides from the assignee.
- Confirm the title and fields before sending. Surface the returned id.

<!-- AUTH: calls go through the plugin's script, which signs in the way every DF Labs plugin does: if ~/.config/dfos/token (or $DFOS_TOKEN) exists it is used as a terminal pass; otherwise it signs in at DF-OS once with the member's slug and DF-OS password (from ~/.config/dfos/{slug,pass} or $DFOS_PASSWORD, else asked) and keeps the session under ~/.config/dfos/ for 30 days, shared by every plugin. On a sign-in error, tell them to set ~/.config/dfos/slug and give their DF-OS password once; dfos defaults to https://os.dflabs.id. Never echo the password, the pass, or the cookie. -->
