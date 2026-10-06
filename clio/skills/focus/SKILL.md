---
name: focus
description: Set a DF Labs (Clio) project's current focus — the one line that says what matters most on it now. Use when the member says "set the focus for <project>", "the priority for this project is ...", "update project focus". This IS the board's prioritisation; it never ranks tasks.
---

# Set a project's current focus

```
bash "${CLAUDE_PLUGIN_ROOT}/scripts/clio.sh" focus website "<one line: what matters most on this project right now>"
```

- Project slugs come from `board` → `projects`.
- One line, present tense, about the project — not a task list.
- Signed commit; surface the hash.

<!-- AUTH: calls go through the plugin's script, which signs in the way every DF Labs plugin does: if ~/.config/dfos/token (or $DFOS_TOKEN) exists it is used as a terminal pass; otherwise it signs in at DF-OS once with the member's slug and DF-OS password (from ~/.config/dfos/{slug,pass} or $DFOS_PASSWORD, else asked) and keeps the session under ~/.config/dfos/ for 30 days, shared by every plugin. On a sign-in error, tell them to set ~/.config/dfos/slug and give their DF-OS password once; dfos defaults to https://os.dflabs.id. Never echo the password, the pass, or the cookie. -->
