---
name: report
description: Report progress on a DF Labs (Clio) task, or close it. The one verb the board has - a report on a waiting task starts it, a report carrying the proof marks it Done. Use when the member says "report to clio", "log progress on T-0xx", "T-0xx is done", "close this task", "lapor ke clio", "mark done", "drop T-0xx", or realizes something in the current session is reportable (backfill). Writes a signed commit on the task. NOT for saying what you're on today - that is checkin.
---

# Report on a Clio task — the verb

A report is one line about what actually happened, on one task, recorded
forever and never edited. Status is its shadow: a report on a `todo` task
starts it (`doing`); a report with `done` closes it and its words become the
receipt. The reporter's word is final — no approval step.

```
# progress (starts a todo, or adds a trail line to a doing task)
bash "${CLAUDE_PLUGIN_ROOT}/scripts/clio.sh" report T-041 "<what happened>"

# Done — the words are the receipt; a done-test is optional and, if given, is written in the same commit
bash "${CLAUDE_PLUGIN_ROOT}/scripts/clio.sh" report T-041 "<what exists now that did not this morning>" done
bash "${CLAUDE_PLUGIN_ROOT}/scripts/clio.sh" report T-041 "<what exists now that did not this morning>" done "<done-test>"

# drop / reopen / unstart (closed work is always `done`, never archived: Clio refuses archived)
bash "${CLAUDE_PLUGIN_ROOT}/scripts/clio.sh" report T-041 "<why>" dropped
bash "${CLAUDE_PLUGIN_ROOT}/scripts/clio.sh" report T-041 "<note>" doing
bash "${CLAUDE_PLUGIN_ROOT}/scripts/clio.sh" report T-041 "<note>" todo
```

How to do it well:
1. **Do not launder the day.** If the plan said X and the day produced Y, the
   report says Y. Never rewrite the member's words into something rosier, and
   never invent progress they did not claim.
2. **One report per task that moved.** Several in a day is the design.
3. **Done asks for proof.** `done` makes the line the receipt, so it has
   to name what exists now — a link, a file, a number — concrete enough that
   someone else could check it. If they cannot name it, it is not done;
   report the progress instead.
4. **Backfill.** If the member realizes mid-conversation that something here is
   reportable, draft the line from what you both just discussed, show it with
   the target task, and CONFIRM before sending. A report is a signed commit;
   never fire one they have not seen.
5. **Say Done, never Finished.** It is the board's one word for a closed task.
6. Surface the commit hash the server returns. Relay refusals as-is (e.g.
   "T-099 is not a task on this board", "a report needs words — what happened?").

If the task id is unclear, run `mine` and let them pick.

**Report or check out.** Report is for one task, any time of day: it stays on
the task's row, in the drawer, and here. The end of the day is \`checkout\`
(Home's Check out button): it asks about each of the day's tasks and sends
those reports in one commit. Report words are permanent either way.

**Not this skill:** "today I'm on T-041", "I'm off today" — that is attendance.
Hand it to `checkin`.

<!-- AUTH: calls go through the plugin's script, which signs in the way every DF Labs plugin does: if ~/.config/dfos/token (or $DFOS_TOKEN) exists it is used as a terminal pass; otherwise it signs in at DF-OS once with the member's slug and DF-OS password (from ~/.config/dfos/{slug,pass} or $DFOS_PASSWORD, else asked) and keeps the session under ~/.config/dfos/ for 30 days, shared by every plugin. On a sign-in error, tell them to set ~/.config/dfos/slug and give their DF-OS password once; dfos defaults to https://os.dflabs.id. Never echo the password, the pass, or the cookie. -->
