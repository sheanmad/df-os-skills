# df-os-skills

Claude Code plugins (marketplace `df-os-skills`) that put DF-OS apps in the
terminal: `clio/` and `calliope/`, each a `skills/` folder and one thin HTTP
script in `scripts/`. Read README.md first.

- The plugins are pure clients. Every command is an existing app route; a new
  command needs the route live first. The `DF-OS sign-in` block is the same
  lines in every script: change it in all of them or none.
- A skill states only what the app does today. If the app has a screen action
  with no route, record it as an AI-first gap; do not paper over it.
- How to release: README.md § How to release. Bump the plugin's
  `.claude-plugin/plugin.json` version on every change; merge to `main` only
  after the apps it depends on are deployed (DF-OS `docs/SYSTEM.md`
  § How to deploy). `main` is what members get.
