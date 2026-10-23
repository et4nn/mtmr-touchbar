#!/bin/bash
D=$HOME/.config/mtmr/sessions; N=$HOME/.config/mtmr/names; mkdir -p "$D" "$N"
IFS='|' read -r sid cwd pr perm title < <(python3 -c '
import sys, json, subprocess
try: j = json.load(sys.stdin)
except Exception: j = {}
def cut(s):
    s = " ".join((s or "").split()).replace("|", "/")
    return s[:14] + ("…" if len(s) > 14 else "")
t = ""
try:
    out = subprocess.run(["grep", "-a", "custom-title", j.get("transcript_path") or "/nonexistent"],
                         capture_output=True, text=True).stdout.splitlines()
    for line in reversed(out):
        try: o = json.loads(line)
        except Exception: continue
        if o.get("type") == "custom-title":
            t = o.get("customTitle") or o.get("title") or next(
                (v for k, v in o.items() if isinstance(v, str) and k not in ("type", "sessionId", "uuid", "timestamp")), "")
            break
except Exception: pass
m = j.get("message") or ""
print("|".join([j.get("session_id", ""), (j.get("cwd") or "").replace("|", "/"), cut(j.get("prompt")),
                "1" if "permission" in m.lower() else "0", cut(t)]))
')
[ -z "$sid" ] && exit 0
F="$D/$sid"
if [ "$1" = end ]; then rm -f "$F" "$N/$sid"; exit 0; fi
if [ "$1" = ask ] && [ "$perm" != 1 ]; then exit 0; fi
if [ -n "$title" ]; then echo "$title" > "$N/$sid"
elif [ ! -s "$N/$sid" ]; then echo "${pr:-$(basename "${cwd:-session}")}" > "$N/$sid"; fi
nm=$(cat "$N/$sid")
st=idle; cnt=0; tm=0
[ -f "$F" ] && read -r st cnt tm _ < "$F"
case "$1" in
  work) st=work ;;
  ask)  st=ask ;;
  ans)  st=ans; cnt=$((cnt + 1)); tm=$(date +%s) ;;
esac
echo "$st $cnt $tm $nm" > "$F"
exit 0
