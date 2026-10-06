#!/usr/bin/env bash
# calliope.sh — thin HTTP client for Calliope, the DF Labs docs app.
#
# Every call is made as you, through Calliope, and saved by Metis as a signed
# commit "<you> via calliope". Sign-in is DF-OS's, shared by every DF Labs
# plugin (the block marked below): your DF-OS password once, or a terminal pass.
# Nothing here holds the brain: state lives on the server.
#
# Usage:
#   calliope.sh me                                         who you are
#   calliope.sh find    <words>                            search the brain: ids, titles, text
#   calliope.sh tree                                       the page tree as indented text (folders end in /)
#   calliope.sh card    <id>                               one item's card and links (D-, M-, T-)
#   calliope.sh read    <id> [page]                        its words, 16,000 characters a page
#   calliope.sh links   <id>                               what it is attached to, and what hangs on it
#   calliope.sh page    <title> [under=D-012] [field=value ...]   write a page, at the top or under a page or folder
#   calliope.sh folder  <name> [under=D-012]               make a folder, at the top or under a page or folder
#       fields: body=<text> | body=@<file> | body=-  (stdin)   summary=<one line>   labels=a,b
#               attach=T-118 (a Clio task)   under=D-002 (the page or folder above it)
#               reason=<why a blocked line may go in>
#   calliope.sh edit    <id> [field=value ...]             change title, summary, labels or body (same fields, note=<what changed>)
#   calliope.sh move    <id> [under=D-002|top] [after=D-013|before=D-013|first]   where a page sits, and its place among its siblings
#   calliope.sh archive <id>                               put a page away
#   calliope.sh upload  <file> [attach=T-118|D-012] [home=<slug>] [title=...]   add a file (M-); home is needed unless attach=D-...
#   calliope.sh comments <id>                              the threads on a page
#   calliope.sh comment <id> <text>  |  reply <C-id> <text>  |  resolve <C-id>
#   calliope.sh attach  <T-id> <item>  |  detach <T-id> <item>
#   calliope.sh raw     <METHOD> <path> [jsonBody]         escape hatch
#
# Config: ~/.config/dfos/ (see the sign-in block); Calliope's address in its file `calliope`.
set -euo pipefail

APP=calliope
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

jget() { python3 -c 'import json,sys; v=json.load(sys.stdin)
for k in sys.argv[1].split("."): v=v[k]
print(v if not isinstance(v,(dict,list)) else json.dumps(v))' "$1"; }
upper() { echo "$1" | tr a-z A-Z; }

# field=value pairs → JSON object. body=@file reads a file, body=- reads stdin,
# attach→attachTo, under→part_of, reason→override.reason.
fields() {
  local -a parts=()
  for kv in "$@"; do
    local k="${kv%%=*}" v="${kv#*=}"
    case "$k" in
      body) case "$v" in @*) v="$(cat "${v#@}")";; -) v="$(cat)";; esac ;;
      attach) k=attachTo ;;
      under) k=part_of; v="$(upper "$v")" ;;
      labels) parts+=("labels=$(python3 -c 'import json,sys; print(json.dumps([x.strip() for x in sys.argv[1].split(",") if x.strip()]))' "$v")"); continue ;;
      folder) parts+=("folder=true"); continue ;;
      reason) parts+=("override=$(jobj "reason=$(jenc "$v")")"); continue ;;
    esac
    parts+=("$k=$(jenc "$v")")
  done
  jobj "${parts[@]}"
}
rev_of() { req GET "/api/things/$1" | jget rev; }
merge() { python3 -c 'import json,sys; a=json.loads(sys.argv[1]); a.update(json.loads(sys.argv[2])); print(json.dumps(a))' "$1" "$2"; }

cmd="${1:-me}"; shift || true
case "$cmd" in
  me)       ensure_auth; req GET /api/me ;;
  find)     ensure_auth; req GET "/api/find?q=$(python3 -c 'import urllib.parse,sys; print(urllib.parse.quote(" ".join(sys.argv[1:])))' "$@")&limit=20" ;;
  card)     ensure_auth; req GET "/api/things/$(upper "$1")" ;;
  read)     ensure_auth; req GET "/api/read/$(upper "$1")?page=${2:-1}" ;;
  links)    ensure_auth; req GET "/api/links-of/$(upper "$1")" ;;
  tree)     ensure_auth; req GET /api/pages | python3 -c '
import json,sys
cards=json.load(sys.stdin).get("pages",[])
kids={}
for c in cards: kids.setdefault(c.get("part_of") or "",[]).append(c)
ids={c["id"] for c in cards}
# a card whose parent is not in the list is shown at the top
for k in [k for k in kids if k and k not in ids]: kids.setdefault("",[]).extend(kids.pop(k))
def key(c): return (c.get("order") if c.get("order") is not None else 1e18, (c.get("title") or "").lower())
def walk(pid,depth,seen):
    for c in sorted(kids.get(pid,[]),key=key):
        if c["id"] in seen: continue
        print("  "*depth+c["id"]+"  "+(c.get("title") or "")+("/" if c.get("folder") else ""))
        walk(c["id"],depth+1,seen|{c["id"]})
walk("",0,set())
' ;;
  page)     ensure_auth
            [ $# -gt 0 ] || { echo "usage: page <title> [under=D-012] [field=value ...]" >&2; exit 2; }
            title="$1"; shift
            req POST /api/items "$(merge "$(fields "$@")" "$(jobj "title=$(jenc "$title")")")" ;;
  folder)   ensure_auth
            [ $# -gt 0 ] || { echo "usage: folder <name> [under=D-012]" >&2; exit 2; }
            name="$1"; shift
            req POST /api/items "$(merge "$(fields "$@")" "$(jobj "title=$(jenc "$name")" "folder=true")")" ;;
  move)     ensure_auth
            id="$(upper "$1")"; shift
            body="$(jobj "rev=$(jenc "$(rev_of "$id")")")"
            for kv in "$@"; do case "$kv" in
              under=top) body="$(merge "$body" '{"part_of":null}')" ;;
              under=*)   body="$(merge "$body" "$(jobj "part_of=$(jenc "$(upper "${kv#*=}")")")")" ;;
              after=*)   body="$(merge "$body" "$(jobj "after=$(jenc "$(upper "${kv#*=}")")")")" ;;
              before=*)  body="$(merge "$body" "$(jobj "before=$(jenc "$(upper "${kv#*=}")")")")" ;;
              first)     body="$(merge "$body" '{"first":true}')" ;;
            esac; done
            req PUT "/api/items/$id/move" "$body" ;;
  archive)  ensure_auth; req POST "/api/items/$(upper "$1")/cold" '{}' ;;
  upload)   ensure_auth
            [ $# -gt 0 ] || { echo "usage: upload <file> [attach=T-118|D-012] [home=<slug>] [title=...]" >&2; exit 2; }
            file="$1"; shift
            [ -f "$file" ] || { echo "no such file: $file" >&2; exit 2; }
            attach=""; home=""; utitle=""
            for kv in "$@"; do case "$kv" in
              attach=*) attach="$(upper "${kv#*=}")" ;;
              home=*)   home="${kv#*=}" ;;
              title=*)  utitle="${kv#*=}" ;;
            esac; done
            case "$attach" in D-*) ;; *) [ -n "$home" ] || { echo "home=<slug> is needed unless attach=D-... is given" >&2; exit 2; } ;; esac
            ctype="$(file --mime-type -b "$file" 2>/dev/null || true)"; [ -n "$ctype" ] || ctype=application/octet-stream
            q="$(python3 -c 'import urllib.parse,sys
a=sys.argv[1:]
print(urllib.parse.urlencode({k:v for k,v in zip(("home","title","name","attachTo"),a) if v}))' "$home" "$utitle" "$(basename "$file")" "$attach")"
            if [ -n "$TOKEN" ]; then auth=(-H "Authorization: Bearer $TOKEN"); else auth=(-b "$JAR"); fi
            "${CURL[@]}" "${auth[@]}" -X POST "$URL/api/media?$q" -H "Content-Type: $ctype" --data-binary "@$file" ;;
  comments) ensure_auth; req GET "/api/comments/$(upper "$1")" ;;
  comment)  ensure_auth; id="$(upper "$1")"; shift; req POST /api/comments "$(jobj "on=$(jenc "$id")" "text=$(jenc "$*")")" ;;
  reply)    ensure_auth; id="$(upper "$1")"; shift; req POST "/api/comments/$id/reply" "$(jobj "text=$(jenc "$*")")" ;;
  resolve)  ensure_auth; req POST "/api/comments/$(upper "$1")/resolve" '{}' ;;
  edit)     ensure_auth
            id="$(upper "$1")"; shift
            [ $# -gt 0 ] || { echo "usage: edit <id> field=value ...  (title|summary|body|reason)" >&2; exit 2; }
            req PUT "/api/items/$id" "$(merge "$(fields "$@")" "$(jobj "rev=$(jenc "$(rev_of "$id")")")")" ;;
  attach)   ensure_auth; req POST /api/links/attach "$(jobj "target=$(jenc "$(upper "$1")")" "item=$(jenc "$(upper "$2")")")" ;;
  detach)   ensure_auth; req POST /api/links/detach "$(jobj "target=$(jenc "$(upper "$1")")" "item=$(jenc "$(upper "$2")")")" ;;
  raw)      ensure_auth; req "$1" "$2" "${3:-}" ;;
  *)        echo "unknown command: $cmd (see the header for usage)" >&2; exit 2 ;;
esac
echo
