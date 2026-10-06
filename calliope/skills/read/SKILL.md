---
name: read
description: Read one item from the DF Labs brain through Calliope — a page, a recording's summary and transcript, or a task — by id. Use when the member says "read D-012", "what does the Northwind handbook say", "show me the transcript of M-003", "bacain T-118". Read-only.
---

# Read one item

```
bash "${CLAUDE_PLUGIN_ROOT}/scripts/calliope.sh" card D-012        # the card: title, summary, status, by, created, where the body lives, links
bash "${CLAUDE_PLUGIN_ROOT}/scripts/calliope.sh" read D-012        # the words, page 1 (16,000 characters)
bash "${CLAUDE_PLUGIN_ROOT}/scripts/calliope.sh" read D-012 2      # page 2
bash "${CLAUDE_PLUGIN_ROOT}/scripts/calliope.sh" links T-118       # what hangs on a task, and what a page is attached to
```

- Card first when you only need what it is; `read` only when the
  words are needed. `read` says `page` of `pages`: read on only if asked.
- Ids: `D-` is a page or a folder, `M-` a file or recording, `T-` a task
  (tasks belong to Clio), `C-` a comment.
- A recording (`M-`) reads as its summary, then its transcript, when one
  exists. A task (`T-`) reads as its file: brief, done-test, trail.
- A page with status `cold` is archived and lives in Drive; `read` still
  returns it.
- Quote what matters, in order; never paste the whole thing back.

<!-- AUTH: calls go through the plugin's script, which signs in the way every DF Labs plugin does: if ~/.config/dfos/token (or $DFOS_TOKEN) exists it is used as a terminal pass; otherwise it signs in at DF-OS once with the member's slug and DF-OS password (from ~/.config/dfos/{slug,pass} or $DFOS_PASSWORD, else asked) and keeps the session under ~/.config/dfos/ for 30 days, shared by every plugin. On a sign-in error, tell them to set ~/.config/dfos/slug and give their DF-OS password once; dfos defaults to https://os.dflabs.id. Never echo the password, the pass, or the cookie. -->
