# df-os-skills — DF Labs apps, from any Claude Code session

One marketplace for the plugins that put DF Labs' apps in the terminal. Each
plugin is a pure client of its app: nothing here holds the brain or a secret,
and every write is a commit signed with your name, made by Metis through the
app. They sign in the same way, at DF-OS, once for all of them.

| Plugin | App | What it does |
|---|---|---|
| `clio` | https://clio.dflabs.id | the board: orient, check in, report, mint a task, edit one, note off-board work, set a project's focus |
| `calliope` | https://calliope.dflabs.id | find pages, files and tasks; show the page tree; read a page or a recording's transcript; write a page or a folder, a comment; edit, move, reorder, archive; upload a file; attach to a task |

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
| What it says | **Who is here, and on what.** Attendance and intent. | **What happened.** Progress, with proof when it is finished. |
| Where it lands | Your own day file | The task's trail (or your day file, if no task) |
| Changes a task? | Never. Taking an unclaimed task puts your name on it, nothing more. | Yes. A report on waiting work starts it; a report with proof finishes it. |
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
- **Last line wins.** Changing your mind at 2pm is another check-in, not an
  edit.
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
- **Finishing carries the receipt.** "Done" makes your line the proof, so it
  names what exists now that did not this morning: a link, a file, a number.
  If you cannot name it, it is not done — report the progress instead. A task
  with no done-test cannot be closed; the skill will ask for one.
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
| `/clio:orient` | "what's going on in DF", "show the board" | The whole board: this week's sprint, what is moving, what has gone quiet, what is homeless, each project's focus. Read-only. |
| `/clio:mine` | "what's on my plate" | Your live tasks, with projects. Read-only. |
| `/clio:today` | "who checked in today", "what happened today" | Today across the team, check-ins and reports apart. Read-only. |
| `/clio:task` | "what happened on T-041" | One task in full, with its trail. Read-only. |
| `/clio:new` | "new task: poster public" | Mint a task. Title names the result; add a done-test when the work is concrete. |
| `/clio:edit` | "assign T-041 to budi", "move it to this sprint" | Properties: project, assignee, sprint, done-test, title. Never status — that is a report. |
| `/clio:focus` | "set the focus for events to …" | A project's one-line current focus. This is the board's prioritisation. |

Every write comes back with the commit hash the server made. The assistant
shows it to you; that hash is your receipt.

### What the board holds you to

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

## Troubleshooting

- **"sign-in failed (401)"**: wrong slug or DF-OS password. Check
  `~/.config/dfos/slug`; delete `~/.config/dfos/pass` if you set one and try again.
- **"that pass is not valid"**: an old pass in `~/.config/dfos/token`. Ask an
  admin for a new one, or remove the file to sign in with your password.
- **"a viewer reads the board — it does not write to it"**: your account is a
  viewer. Ask an admin for a member account.
- **"done-test required"**: you tried to finish a task that has none. Give one
  in the same report: "…done, test: poster is public and registration is live".
- **Skills do not appear**: restart the session after install, or run
  `/plugin list` to confirm `clio@df-os-skills` and `calliope@df-os-skills` are enabled.
