---
name: write
description: Write to the DF Labs brain through Calliope as the member — write a page or a folder at the top or under a page, edit, move, reorder, comment, archive; add a file. Use when the member says "save this as a page", "write this up on T-118", "catat ini", "update D-012", "put it under Clients", "move it to the top", "put it before D-013", "archive D-012", "comment on D-012". Every save is a signed commit, them via calliope.
---

# Write a page or a folder

Calliope is one tree of folders and pages. A page sits at the top or under
another page or folder; the server works out its home from the top of its
branch, so you never send one.

```
bash "${CLAUDE_PLUGIN_ROOT}/scripts/calliope.sh" page "Northwind budget proposal" summary="Two options, one recommended." body=@/tmp/proposal.md attach=T-118
bash "${CLAUDE_PLUGIN_ROOT}/scripts/calliope.sh" page "Northwind contacts" under=D-003 body=- < notes.md          # under a folder; body from stdin
bash "${CLAUDE_PLUGIN_ROOT}/scripts/calliope.sh" folder "Clients"                                              # a folder at the top
bash "${CLAUDE_PLUGIN_ROOT}/scripts/calliope.sh" folder "Northwind" under=D-003                                  # a folder inside a folder
bash "${CLAUDE_PLUGIN_ROOT}/scripts/calliope.sh" edit D-012 summary="…" body=@/tmp/new.md note="added the budget table"
bash "${CLAUDE_PLUGIN_ROOT}/scripts/calliope.sh" move D-012 under=D-003                                        # under a page or folder; under=top for the top
bash "${CLAUDE_PLUGIN_ROOT}/scripts/calliope.sh" move D-012 after=D-013                                        # order among siblings: after=, before=, or first
bash "${CLAUDE_PLUGIN_ROOT}/scripts/calliope.sh" archive D-012
bash "${CLAUDE_PLUGIN_ROOT}/scripts/calliope.sh" upload ./kickoff.m4a attach=D-012                             # a file; home comes from the page
bash "${CLAUDE_PLUGIN_ROOT}/scripts/calliope.sh" upload ./logo.png home=northwind title="Northwind logo"           # without attach=D-…, home= is needed
bash "${CLAUDE_PLUGIN_ROOT}/scripts/calliope.sh" comments D-012                                                # the threads on a page
bash "${CLAUDE_PLUGIN_ROOT}/scripts/calliope.sh" comment D-012 "Is Net 30 still right?"                        # a new thread; reply <C-id> <text>; resolve <C-id>
```

Ids: `D-` pages and folders, `M-` files, `T-` tasks (they belong to Clio; a page
can be attached to one), `C-` comments.

Fields: `summary=` (one line, shown in search and on cards — always give
one), `body=` (text, `@file`, or `-` for stdin), `labels=a,b` (lower-case
words), `attach=T-118` (also hangs it on the task), `under=D-003` (the page
or folder it sits under; leave it out for the top). Markdown in the body; the
editor's forms work too: `> [!INFO]` panels, `[status: Done | green]`, tables,
`<details>`. `edit` takes `note=` (what changed, kept in the history).

- Confirm title, summary and where it goes (`tree` shows the tree) with the
  member before sending; surface the returned `id` and `commit`.
- A refusal (422) names a line that looks like a key, a password, an NIK, an
  NPWP or a bank account number. Show the reason (it is masked), ask the
  member to take it out, or, if they say it belongs there, send again with
  `reason="…"` (a few words; it goes into the commit).
- Long bodies are fine (over 256 KB goes to Drive by itself).
- `edit` and `move` fetch the item's current revision first; a 409 means
  someone else saved in between: read it again before changing it.

<!-- AUTH: calls go through the plugin's script, which signs in the way every DF Labs plugin does: if ~/.config/dfos/token (or $DFOS_TOKEN) exists it is used as a terminal pass; otherwise it signs in at DF-OS once with the member's slug and DF-OS password (from ~/.config/dfos/{slug,pass} or $DFOS_PASSWORD, else asked) and keeps the session under ~/.config/dfos/ for 30 days, shared by every plugin. On a sign-in error, tell them to set ~/.config/dfos/slug and give their DF-OS password once; dfos defaults to https://os.dflabs.id. Never echo the password, the pass, or the cookie. -->
