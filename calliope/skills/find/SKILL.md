---
name: find
description: Search the DF Labs brain through Calliope — pages, folders, recordings, tasks — by id, title or words, or show the page tree. Use when the member asks "where is the budget proposal", "cari dokumen tentang Northwind", "is there a recording of the kick-off", "find D-012", "show me the tree". Read-only; it points, it never guesses.
---

# Find what is in the brain

```
bash "${CLAUDE_PLUGIN_ROOT}/scripts/calliope.sh" find Northwind budget proposal
bash "${CLAUDE_PLUGIN_ROOT}/scripts/calliope.sh" find T-118
bash "${CLAUDE_PLUGIN_ROOT}/scripts/calliope.sh" tree
```

`find` answers with `results`: each has `id`, `kind` (page, media, task…),
`title`, `status`, and `why` (matched the id, the title, or the words). An id
in the question comes first; then titles; then words, including words that
live in Drive (long bodies, transcripts).

`tree` prints the page tree as indented text, one line per item: `D-012  Title`
for a page, `D-003  Clients/` for a folder, children indented two spaces.

- Show the top few as `id · kind · title (status)`; say what matched. Never
  dump raw JSON.
- Nothing found: say that, and offer `tree` to look around, rather than
  inventing an answer.
- To read one, use `read`. For what hangs on a task, use `links <id>`.

<!-- AUTH: calls go through the plugin's script, which signs in the way every DF Labs plugin does: if ~/.config/dfos/token (or $DFOS_TOKEN) exists it is used as a terminal pass; otherwise it signs in at DF-OS once with the member's slug and DF-OS password (from ~/.config/dfos/{slug,pass} or $DFOS_PASSWORD, else asked) and keeps the session under ~/.config/dfos/ for 30 days, shared by every plugin. On a sign-in error, tell them to set ~/.config/dfos/slug and give their DF-OS password once; dfos defaults to https://os.dflabs.id. Never echo the password, the pass, or the cookie. -->
