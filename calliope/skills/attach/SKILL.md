---
name: attach
description: Attach a page or a recording to a DF Labs task (or take it off) through Calliope. Use when the member says "put D-012 on T-118", "attach the handbook to that task", "this recording belongs to T-120", "lepas D-012 dari T-118". One link, one signed commit; the task's people hear about it from Iris.
---

# Attach to a task

```
bash "${CLAUDE_PLUGIN_ROOT}/scripts/calliope.sh" attach T-118 D-012
bash "${CLAUDE_PLUGIN_ROOT}/scripts/calliope.sh" detach T-118 D-012
bash "${CLAUDE_PLUGIN_ROOT}/scripts/calliope.sh" links  T-118
```

- The task first, then the item. Ids are not case-sensitive. Tasks belong to
  Clio; Calliope only holds the link.
- A link is never deleted, only marked detached, so `detach` is safe and
  reversible.
- Check with `links` after, and say what the task now carries.
- When writing a new page for a task, `page` with `attach=T-118` does both in
  one commit; `upload` takes `attach=` too.

<!-- AUTH: calls go through the plugin's script, which signs in the way every DF Labs plugin does: if ~/.config/dfos/token (or $DFOS_TOKEN) exists it is used as a terminal pass; otherwise it signs in at DF-OS once with the member's slug and DF-OS password (from ~/.config/dfos/{slug,pass} or $DFOS_PASSWORD, else asked) and keeps the session under ~/.config/dfos/ for 30 days, shared by every plugin. On a sign-in error, tell them to set ~/.config/dfos/slug and give their DF-OS password once; dfos defaults to https://os.dflabs.id. Never echo the password, the pass, or the cookie. -->
