---
name: note
description: Log an off-board report in DF Labs (Clio) — work you did that no task covers. Lands in your own day file under Movements, as a report with no task. Use when the member says "log this to clio", "note what I did", "off-board report", "catat kegiatan", for work with no task behind it. Writes a signed commit.
---

# Off-board report

```
bash "${CLAUDE_PLUGIN_ROOT}/scripts/clio.sh" note "<what you did, in your words>"
```

- A report with no task to hold it. It counts as a report on the day, not as a
  check-in.
- If the same kind of off-board line keeps appearing, that is a task asking to
  be minted — say so, and offer `new`.
- Confirm the wording before sending; it is a signed commit.

<!-- AUTH: calls go through the plugin's script, which signs in the way every DF Labs plugin does: if ~/.config/dfos/token (or $DFOS_TOKEN) exists it is used as a terminal pass; otherwise it signs in at DF-OS once with the member's slug and DF-OS password (from ~/.config/dfos/{slug,pass} or $DFOS_PASSWORD, else asked) and keeps the session under ~/.config/dfos/ for 30 days, shared by every plugin. On a sign-in error, tell them to set ~/.config/dfos/slug and give their DF-OS password once; dfos defaults to https://os.dflabs.id. Never echo the password, the pass, or the cookie. -->
