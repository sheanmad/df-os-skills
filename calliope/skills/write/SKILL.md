---
name: write
description: Write to the DF Labs brain through Calliope as the member — write a page, a sheet or a folder at the top or under a page, edit, move, reorder, comment, archive; add a file. Use when the member says "save this as a page", "write this up on T-118", "catat ini", "update D-012", "put it under Clients", "move it to the top", "put it before D-013", "make a sheet of this table", "archive D-012", "comment on D-012". Every save is a signed commit, them via calliope.
---

# Write a page, a sheet or a folder

Calliope is one tree of folders, pages and sheets. A page sits at the top or under
another page or folder; the server works out its home from the top of its
branch, so you never send one.

```
bash "${CLAUDE_PLUGIN_ROOT}/scripts/calliope.sh" page "Northwind budget proposal" summary="Two options, one recommended." body=@/tmp/proposal.md attach=T-118
bash "${CLAUDE_PLUGIN_ROOT}/scripts/calliope.sh" page "Northwind contacts" under=D-003 body=- < notes.md          # under a folder; body from stdin
bash "${CLAUDE_PLUGIN_ROOT}/scripts/calliope.sh" folder "Clients"                                              # a folder at the top
bash "${CLAUDE_PLUGIN_ROOT}/scripts/calliope.sh" folder "Northwind" under=D-003                                  # a folder inside a folder
bash "${CLAUDE_PLUGIN_ROOT}/scripts/calliope.sh" sheet "Northwind costs" under=D-003 body=@/tmp/costs.csv        # a sheet; body is CSV
bash "${CLAUDE_PLUGIN_ROOT}/scripts/calliope.sh" edit D-012 summary="…" body=@/tmp/new.md note="added the budget table"
bash "${CLAUDE_PLUGIN_ROOT}/scripts/calliope.sh" move D-012 under=D-003                                        # under a page or folder; under=top for the top
bash "${CLAUDE_PLUGIN_ROOT}/scripts/calliope.sh" move D-012 after=D-013                                        # order among siblings: after=, before=, or first
bash "${CLAUDE_PLUGIN_ROOT}/scripts/calliope.sh" archive D-012
bash "${CLAUDE_PLUGIN_ROOT}/scripts/calliope.sh" upload ./kickoff.m4a attach=D-012                             # a file; home comes from the page
bash "${CLAUDE_PLUGIN_ROOT}/scripts/calliope.sh" upload ./logo.png home=northwind title="Northwind logo"           # without attach=D-…, home= is needed
bash "${CLAUDE_PLUGIN_ROOT}/scripts/calliope.sh" comments D-012                                                # the threads on a page
bash "${CLAUDE_PLUGIN_ROOT}/scripts/calliope.sh" comment D-012 "Is Net 30 still right?"                        # a new thread; reply <C-id> <text>; resolve <C-id>
```

Ids: `D-` pages, sheets and folders, `M-` files, `T-` tasks (they belong to Clio; a page
can be attached to one), `C-` comments.

Fields: `summary=` (one line, shown in search and on cards — always give
one), `body=` (text, `@file`, or `-` for stdin), `labels=a,b` (lower-case
words), `attach=T-118` (also hangs it on the task), `under=D-003` (the page
or folder it sits under; leave it out for the top). Markdown in the body; the
editor's forms work too: `> [!INFO]` panels, `[status: Done | green]`, tables,
`<details>`, and `<div align="center">` (a blank line, the words, a blank line,
`</div>`) to centre, right-align or justify a paragraph or heading.
`<span style="color:#c0392b">words</span>` gives words a colour, a highlight
(`background-color`), a size (`font-size:18px`) or a font (`font-family:Georgia, serif`). `edit` takes `note=` (what changed, kept in the history).

A sheet is a page whose body is CSV (made with `sheet`, or `sheet=true` on
`page`). One tab named Sheet1 is plain CSV, one line a row. More tabs: one
section a tab, a `## <Tab name>` heading with that tab's CSV in a fenced
block:

````
## Summary

```csv
Item,Total
Venue,=Costs!B4
```

## Costs

```csv
Item,Amount
```
````

A cell starting with `=` is a formula and may point at another tab
(`Costs!B2`, `'Budget 2026'!A1:B5`). `edit D-… body=@new.csv` replaces the
whole sheet; read it first and send every tab back.

A page's Page setup (how it is drawn and how it prints to PDF) is `layout=`:
`paper` (`a4` or `letter`), `margins` in mm (`t r b l`), `line` (1, 1.15, 1.5
or 2), `size` in px, a whole number from 10 to 24, `full` (true = full
width, no paper). Send all of it:
`edit D-… layout='{"paper":"a4","margins":{"t":25.4,"r":25.4,"b":25.4,"l":25.4},"line":1.15,"size":15,"full":false}'`.
`edit D-… layout=null` clears it (the page goes back to the default).
Pages only; not sheets or folders.

- Confirm title, summary and where it goes (`tree` shows the tree) with the
  member before sending; surface the returned `id` and `commit`.
- A refusal (422) names a line that looks like a key, a password, an NIK, an
  NPWP or a bank account number; on a sheet it also names the `cell`
  (`Summary!B2`). Show the reason (it is masked), ask the
  member to take it out, or, if they say it belongs there, send again with
  `reason="…"` (a few words; it goes into the commit).
- Long bodies are fine (over 256 KB goes to Drive by itself).
- `edit` and `move` fetch the item's current revision first; a 409 that says
  it was saved in between means someone else saved: read it again before
  changing it.
- A 409 that names people with unsaved changes on this page (or sheet) in
  Calliope means it is open there and being edited live. Stop; do not retry
  or work around it. Tell the member who has unsaved changes, and that they
  (or that person) must Save or Discard in Calliope first; send again only
  after they say so.
- The script exits 1 on any 4xx or 5xx and prints the server's error: read
  it, never report a refused save as done.

<!-- AUTH: calls go through the plugin's script, which signs in the way every DF Labs plugin does: if ~/.config/dfos/token (or $DFOS_TOKEN) exists it is used as a terminal pass; otherwise it signs in at DF-OS once with the member's slug and DF-OS password (from ~/.config/dfos/{slug,pass} or $DFOS_PASSWORD, else asked) and keeps the session under ~/.config/dfos/ for 30 days, shared by every plugin. On a sign-in error, tell them to set ~/.config/dfos/slug and give their DF-OS password once; dfos defaults to https://os.dflabs.id. Never echo the password, the pass, or the cookie. -->
