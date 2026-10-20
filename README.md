# df-os-skills — DF Labs apps, from any Claude Code session

One marketplace for the plugins that put DF Labs' apps in the terminal. Each
plugin is a pure client of its app: nothing here holds the brain or a secret,
and every write is a commit signed with your name, made by Metis through the
app. They sign in the same way, at DF-OS, once for all of them.

| Plugin | App | What it does |
|---|---|---|
| `clio` | https://clio.dflabs.id | the board: orient, check in, report, mint a task, edit one, note off-board work, set a project's focus; from Clio T-158 release 1, due dates, domains and projects |
| `calliope` | https://calliope.dflabs.id | find pages, files and tasks; show the page tree; read a page or a recording's transcript; write a page, a sheet or a folder, a comment; edit, move, reorder, archive, delete to Trash and restore; upload a file; attach to a task |

## Install

```
/plugin marketplace add sheanmad/df-os-skills
/plugin install clio@df-os-skills
/plugin install calliope@df-os-skills
```

Restart the session once. The skills are then there as `/clio:…` and
`/calliope:…`, and they fire on plain sentences like "check in", "report this
to clio", "what's on my plate", "where is the Northwind budget", "save this as a
page", "put this on T-118".

Had the old Clio plugin from `eferist/clio-skill`? Remove it (`/plugin
uninstall clio@clio`) and install this one; it replaces it.

## Sign in

You need a DF Labs account (DF-OS). The first time any plugin talks to its app
it asks for your **slug** and your **DF-OS password**, in the terminal. It
signs in at os.dflabs.id the way the website does and keeps the session under
`~/.config/dfos/` for 30 days, for every plugin: sign in once, use both. It
never stores the password.

An admin can instead give you a terminal pass (`hub token <slug>`, 90 days):
put it in `~/.config/dfos/token` and no password is asked.

The sign-in is the same lines in every plugin's script (marked `DF-OS
sign-in`); DF-OS's laptop check compares them.

## Clio

### The two verbs

The board has two ways to write to it, and the skills keep them apart. Get
this right and the Thursday report writes itself.

| | Check-in | Report |
|---|---|---|
| What it says | **Who is here, and on what.** Attendance and intent. | **What happened.** Progress, with proof when it is Done. |
| Where it lands | Your own day file | The task's trail (or your day file, if no task) |
| Changes a task? | Never. Taking an unclaimed task puts your name on it, nothing more. | Yes. A report on waiting work starts it; a report with proof marks it Done. |
| How often | Once a day, every day — working or resting | Every time something moves |
| Skill | `/clio:checkin` | `/clio:report` |

#### Check in — `/clio:checkin`

Say what the day is for. Tasks, words, or both. Or say you are off.

> "check in — today I'm on T-041 and T-043, the deck first"
> "hari ini aku ngerjain T-055"
> "I'm off today"
> "check in on T-060, I'm taking it"  ← an unclaimed task from this week's sprint

- **Every day.** On the days you work and on the days you rest. An off day is
  a check-in too. This is how the record tells resting from vanishing.
- **One check-in a day, edited in place.** Checking in again replaces it.
  The same words again change nothing.
- **No proof, no status.** It is planning and presence. Nothing on the board
  flags anyone for it; the Thursday report reads it from the brain.

#### Report — `/clio:report`

One line about what actually happened, on one task. Recorded forever, never
edited. Your word is final; nobody approves it.

> "report on T-041: outline locked, three candidates left"
> "T-041 is done — the deck is at drive/…/deck-v3.pdf"
> "drop T-052, we decided against it"

- **A report starts the work.** Nobody sets "in progress" by hand; reporting
  on a waiting task is what starting means.
- **Done carries the receipt.** "Done" makes your line the proof, so it
  names what exists now that did not this morning: a link, a file, a number.
  If you cannot name it, it is not done — report the progress instead. A done
  needs only the words, which become the receipt. A done-test is optional; one
  sent with the report is written in the same commit.
- **Do not launder the day.** If the plan said X and the day produced Y, the
  report says Y. The gap is signal, not failure.
- **Backfill is the point.** Realise mid-conversation that something you just
  did is reportable? Say so. The assistant drafts the line from what you
  discussed, shows it with the task, and sends only when you confirm.

#### Off the board — `/clio:note`

Work you did that no task covers. It lands in your day file as a report with
no task. If the same kind of note keeps appearing, that is a task asking to be
minted.

### The rest

| Skill | Say | Does |
|---|---|---|
| `/clio:orient` | "what's going on in DF", "show the board" | The whole board: this week's sprint, what is moving, what has gone quiet, the backlog (live work not planned into the open week), each project's focus. Read-only. |
| `/clio:mine` | "what's on my plate" | Your live tasks, with projects. Read-only. |
| `/clio:today` | "who checked in today", "what happened today" | Today across the team, check-ins and reports apart. Read-only. |
| `/clio:task` | "what happened on T-041" | One task in full, with its trail. Read-only. |
| `/clio:new` | "new task: poster public" | Mint a task. Title names the result; add a done-test when the work is concrete. |
| `/clio:edit` | "assign T-041 to budi", "move it to this sprint" | Properties: project, assignee, sprint, due date, done-test, title. Never status — that is a report. |
| `/clio:due` | "T-041 is due Friday", "push T-041 to next week" | Set or move a task's due date. A later date needs a reason. From Clio T-158 release 1. |
| `/clio:domain` | "show the domains", "which project is late" | Every domain with its projects and their health; open a new domain (name, colour, description). From Clio T-158 release 1. |
| `/clio:project` | "new project for the Calliope prototype" | Open a project in a domain with start, due date and goal; edit it. A later due date needs a reason. From Clio T-158 release 1. |
| `/clio:focus` | "set the focus for events to …" | A project's one-line current focus. This is the board's prioritisation. |

Every write comes back with the commit hash the server made. The assistant
shows it to you; that hash is your receipt.

### What the board holds you to

- **A task in a week has a due date** (from Clio T-158 release 1). Clio
  refuses a task in a week without one; a backlog task may have none. Reports
  are never blocked by it.
- **A later due date carries a reason** (from Clio T-158 release 1). Setting a
  first date or moving it earlier needs none. Moving it later writes the reason
  on the trail, for good. The same holds for a project's due date.
- **Done, never Finished.** One word for a closed task or project, everywhere.

- **The alarm lives on the work, never on a person.** A live task whose trail
  has gone quiet for days is dying and the board says so. A quiet human is
  never marked. The check-in exists so that quiet can be read.
- **Only promises that can die go on the board.** Client work and knowledge
  work get a task the day they start, or the Thursday report will not credit
  them.
- **The reporter's word is final.** No approval, no seal, no ranks.
  Accountability is provenance: every line is a commit with your name on it.

## Calliope

### What the terminal may do

The same as you in the app, as you: it is your hand. The checks are the same
too: a key, a password, an NIK, an NPWP or a bank account number in a save is
refused and names the line; you can save anyway with a reason, which goes into
the commit. What an AI wants to add on its own is not Calliope's business:
that comes with the assistant and its own app.

## How to release

A change reaches people only once it is merged to `main`: the marketplace
follows the repo's default branch, and `/plugin` updates from there. A branch,
however finished, reaches no one.

1. Bump `version` in the plugin's `.claude-plugin/plugin.json` (patch for a
   skill or script fix, minor for a new command or field). Without a bump,
   installed copies are not updated.
2. Merge to `main` only after the apps it depends on are deployed (see DF-OS
   `docs/SYSTEM.md` § How to deploy). A skill that sends a field or calls a
   route the live app does not know yet is a skill that fails, or worse,
   whose write is silently dropped.
3. Members run `/plugin marketplace update df-os-skills` and restart the
   session.

For calliope 0.3.x (T-148: `layout`, `cols`, `choices`, `delete`, `restore`):
merge only after the Metis and Calliope deploy. Old Metis drops `layout`,
`cols` and `choices` from a save without saying so.

For clio 0.3.x (T-158 release 1: `due=`, `due`, `domain`, `project`): merge
only after Clio's release 1 is deployed (Metis, Iris and Clio, in that order).
Older Clio has no `/api/domains` and does not keep `due`.

## Change log

- 2026-10-20 — clio 0.3.1: `claim <id> [YYYY-MM-DD]`: claiming a live task in a week with no due date needs the date, sent in the same PATCH (Clio refuses the claim without it); the script stops with a clear message when it is missing, and the checkin skill asks for it. `edit due=` with no value clears the date (`"due": null`).
- 2026-10-20 — clio 0.3.0, from Clio T-158 release 1: `due=` on `new` and `edit`; `due T-NNN <date> ["reason"]` (PATCH `/api/tasks/:id`); `domain` (GET `/api/domains`) and `domain new` (POST `/api/domains`); `project new` with domain, start, due, goal and people (POST `/api/projects`) and `project edit` (PATCH `/api/projects/:slug`). Skills `due`, `domain`, `project`; the due-date rules and "Done, never Finished" in `new`, `edit`, `report` and the README. Not on `main` until Clio's release 1 is deployed.

## Troubleshooting

- **"sign-in failed (401)"**: wrong slug or DF-OS password. Check
  `~/.config/dfos/slug`; delete `~/.config/dfos/pass` if you set one and try again.
- **"that pass is not valid"**: an old pass in `~/.config/dfos/token`. Ask an
  admin for a new one, or remove the file to sign in with your password.
- **"a viewer reads the board — it does not write to it"**: your account is a
  viewer. Ask an admin for a member account.
- **"T-041 changed since you opened it"** on a claim: someone took the task a
  moment before you. Look at the board again and pick another.
- **Skills do not appear**: restart the session after install, or run
  `/plugin list` to confirm `clio@df-os-skills` and `calliope@df-os-skills` are enabled.
