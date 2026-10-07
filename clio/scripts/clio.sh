#!/usr/bin/env bash
# clio.sh — thin HTTP client for Clio, the DF Labs board.
#
# Every write is made as you, through Clio, and saved by Metis as a signed
# commit "<you> via clio"; it comes back with its hash. Sign-in is DF-OS's,
# shared by every DF Labs plugin (the block marked below): your DF-OS password
# once, or a terminal pass.
#
# Usage:
#   clio.sh board                                   the whole board (JSON)
#   clio.sh mine                                    your live tasks
#   clio.sh task    <id>                            one task, with its trail
#   clio.sh checkin <text> [id,id,...]              check in: what you're on today
#   clio.sh off     [text]                          check in as off today
#   clio.sh claim   <id>                            put your name on an unclaimed task
#   clio.sh report  <id> <text> [status] [doneTest] the verb (status: done|dropped|doing|todo)
#   clio.sh note    <text>                          off-board report → your day file
#   clio.sh new     <title> [field=value ...]       mint a task (project|sprint|assignee|doneTest|brief|unit)
#   clio.sh edit    <id> field=value ...            task properties (title|brief|project|sprint|assignee|unit|doneTest)
#   clio.sh focus   <slug> <line>                   set a project's current focus
#   clio.sh raw     <METHOD> <path> [jsonBody]      escape hatch
#
# Config: ~/.config/dfos/ (see the sign-in block); Clio's address in its file `clio`.
set -euo pipefail

APP=clio
# ---- BEGIN DF-OS sign-in: the same lines in every DF Labs plugin ----
# One sign-in for every plugin, as in the apps (only DF-OS signs anyone in):
# your DF-OS password once, or a terminal pass from an admin (`hub token
# <slug>`, 90 days). Kept in ~/.config/dfos/ (or $DFOS_CONFIG), shared by
# every plugin; one session serves them all.
#   slug     your member slug     (or $DFOS_SLUG)
#   token    a terminal pass      (or $DFOS_TOKEN) — used if present
#   pass     password, chmod 600  (or $DFOS_PASSWORD; else asked once)
#   dfos     DF-OS's address      (default https://os.dflabs.id)
#   <app>    an app's address, e.g. a file `clio` (default https://<app>.dflabs.id)
#   ca       a CA certificate, only for a local stack with its own CA
#   cookie   the cached session   (managed here — do not edit)
CFG="${DFOS_CONFIG:-$HOME/.config/dfos}"
mkdir -p "$CFG"; chmod 700 "$CFG" 2>/dev/null || true
DFOS="$(cat "$CFG/dfos" 2>/dev/null || echo 'https://os.dflabs.id')"; DFOS="${DFOS%/}"
URL="$(cat "$CFG/$APP" 2>/dev/null || echo "https://$APP.dflabs.id")"; URL="${URL%/}"
SLUG="${DFOS_SLUG:-$(cat "$CFG/slug" 2>/dev/null || true)}"
TOKEN="${DFOS_TOKEN:-$(cat "$CFG/token" 2>/dev/null || true)}"
JAR="$CFG/cookie"
CURL=(curl -sS --max-time 60)
[ -f "$CFG/ca" ] && CURL+=(--cacert "$CFG/ca")

# JSON-encode one argument safely (quotes, newlines, unicode).
jenc() { python3 -c 'import json,sys; sys.stdout.write(json.dumps(sys.argv[1]))' "$1"; }
# Build a JSON object from key=value pairs whose values are already JSON.
jobj() { python3 - "$@" <<'PY'
import json,sys
o={}
for kv in sys.argv[1:]:
    k,_,v=kv.partition('=')
    o[k]=json.loads(v)
sys.stdout.write(json.dumps(o))
PY
}

req() { # METHOD PATH [JSONBODY]
  local m="$1" p="$2" body="${3:-}"
  local -a auth=()
  if [ -n "$TOKEN" ]; then auth=(-H "Authorization: Bearer $TOKEN"); else auth=(-b "$JAR"); fi
  if [ -n "$body" ]; then
    "${CURL[@]}" "${auth[@]}" -X "$m" "$URL$p" -H 'Content-Type: application/json' -d "$body"
  else
    "${CURL[@]}" "${auth[@]}" -X "$m" "$URL$p"
  fi
}

signed_in() { req GET /api/me 2>/dev/null | grep -q '"slug"'; }

# DF-OS remembers a sign-in for 30 days: a visit to /login with that cookie
# hands out a fresh 12-hour pass. Only when that fails is the password needed.
renew() { [ -f "$JAR" ] && "${CURL[@]}" -b "$JAR" -c "$JAR" -o /dev/null "$DFOS/login" 2>/dev/null && signed_in; }

login() {
  [ -n "$SLUG" ] || { printf 'Your DF Labs slug (e.g. ana): ' >&2; read -r SLUG; echo "$SLUG" > "$CFG/slug"; }
  local pw="${DFOS_PASSWORD:-$(cat "$CFG/pass" 2>/dev/null || true)}"
  if [ -z "$pw" ]; then printf 'DF-OS password for %s: ' "$SLUG" >&2; read -rs pw; echo >&2; fi
  local body; body="$(jobj "name=$(jenc "$SLUG")" "password=$(jenc "$pw")" "remember=true")"
  rm -f "$JAR"
  local code; code="$("${CURL[@]}" -c "$JAR" -o /dev/null -w '%{http_code}' \
    -X POST "$DFOS/api/login" -H 'Content-Type: application/json' -d "$body")"
  [ "$code" = "200" ] || { echo "sign-in failed ($code) — check your slug and DF-OS password, and dfos in $CFG" >&2; exit 1; }
  chmod 600 "$JAR" 2>/dev/null || true
  signed_in || { echo "signed in at DF-OS, but $URL does not know you yet — is your account switched on?" >&2; exit 1; }
}

ensure_auth() {
  if [ -n "$TOKEN" ]; then
    signed_in || { echo "that pass is not valid — ask an admin for a new one (hub token <slug>), or remove $CFG/token to sign in with your password" >&2; exit 1; }
  else
    signed_in || renew || login
  fi
}
# ---- END DF-OS sign-in ----

# A comma list of ids → JSON array, uppercased and trimmed.
jids() { python3 -c 'import json,sys; print(json.dumps([x.strip().upper() for x in sys.argv[1].split(",") if x.strip()]))' "$1"; }


cmd="${1:-mine}"; shift || true
case "$cmd" in
  board)   ensure_auth; req GET /api/board ;;
  mine)    ensure_auth; req GET "/api/tasks?mine=1" ;;
  task)    ensure_auth; req GET "/api/tasks/$(echo "$1" | tr a-z A-Z)" ;;
  checkin) ensure_auth
           text="${1:-}"; ids="${2:-}"
           req POST /api/commit "$(jobj "text=$(jenc "$text")" "tasks=$(jids "$ids")")" ;;
  off)     ensure_auth
           req POST /api/commit "$(jobj "text=$(jenc "${1:-off today}")" "tasks=[]" "off=true")" ;;
  claim)   ensure_auth
           me="$(req GET /api/me | python3 -c 'import json,sys; print(json.load(sys.stdin)["slug"])')"
           # refused (409) if someone took it since you looked, as in the web face
           req PATCH "/api/tasks/$(echo "$1" | tr a-z A-Z)" "$(jobj "assignee=$(jenc "$me")" 'expect={"assignee":""}')" ;;
  report)  ensure_auth
           id="$(echo "$1" | tr a-z A-Z)"; text="$2"; status="${3:-}"; dt="${4:-}"
           parts=("text=$(jenc "$text")")
           [ -n "$status" ] && parts+=("status=$(jenc "$status")")
           [ -n "$dt" ]     && parts+=("doneTest=$(jenc "$dt")")
           req POST "/api/tasks/$id/report" "$(jobj "${parts[@]}")" ;;
  note)    ensure_auth; req POST /api/report "$(jobj "text=$(jenc "$1")")" ;;
  new)     ensure_auth
           title="$1"; shift
           parts=("title=$(jenc "$title")")
           for kv in "$@"; do parts+=("${kv%%=*}=$(jenc "${kv#*=}")"); done
           req POST /api/tasks "$(jobj "${parts[@]}")" ;;
  edit)    ensure_auth
           id="$(echo "$1" | tr a-z A-Z)"; shift
           parts=()
           for kv in "$@"; do parts+=("${kv%%=*}=$(jenc "${kv#*=}")"); done
           [ ${#parts[@]} -eq 0 ] && { echo "usage: edit <id> field=value ...  (title|brief|project|sprint|assignee|unit|doneTest)" >&2; exit 2; }
           req PATCH "/api/tasks/$id" "$(jobj "${parts[@]}")" ;;
  focus)   ensure_auth; req PATCH "/api/projects/$1" "$(jobj "focus=$(jenc "$2")")" ;;
  raw)     ensure_auth; req "$1" "$2" "${3:-}" ;;
  *)       echo "unknown command: $cmd (see header for usage)" >&2; exit 2 ;;
esac
echo
