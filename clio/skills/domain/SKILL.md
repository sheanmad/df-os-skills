---
name: domain
description: List or open DF Labs (Clio) domains, the areas of work that hold projects (DF-OS, Sales & Business). Use when the member says "what domains are there", "show projects by domain", "how are the projects doing", "which project is late", "new domain". Lists every domain with its projects and their health.
---

# Domains

```
bash "${CLAUDE_PLUGIN_ROOT}/scripts/clio.sh" domain
bash "${CLAUDE_PLUGIN_ROOT}/scripts/clio.sh" domain new "Sales & Business" orange "<optional description>"
```

- `domain` answers every domain with its projects: dates, goal, people,
  health (On track, At risk, Late, Done) and done / doing / total task counts.
  Summarise it; never dump the JSON. A domain is never done and has no due
  date; it clusters projects, and its tasks with no project are counted as
  "No project".
- A new domain needs a name and a colour: `violet`, `orange`, `teal`,
  `pink`, `blue`, `olive`, `brown`, `green` or `slate`. The description is
  optional. Clio answers its slug.
- A domain has no owner and no person. Do not ask for one.
- Confirm the name and colour before sending; surface the hash.

<!-- AUTH: calls go through the plugin's script, which signs in the way every DF Labs plugin does: if ~/.config/dfos/token (or $DFOS_TOKEN) exists it is used as a terminal pass; otherwise it signs in at DF-OS once with the member's slug and DF-OS password (from ~/.config/dfos/{slug,pass} or $DFOS_PASSWORD, else asked) and keeps the session under ~/.config/dfos/ for 30 days, shared by every plugin. On a sign-in error, tell them to set ~/.config/dfos/slug and give their DF-OS password once; dfos defaults to https://os.dflabs.id. Never echo the password, the pass, or the cookie. -->
