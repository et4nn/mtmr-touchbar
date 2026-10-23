#!/bin/bash
D=$HOME/.config/mtmr/sessions; N=$HOME/.config/mtmr/names; mkdir -p "$D" "$N"
IFS='|' read -r sid cwd pr perm < <(python3 -c '
import sys,json
try: j=json.load(sys.stdin)
except Exception: j={}
p=" ".join((j.get("prompt") or "").split()).replace("|","/")
p=p[:14]+("…" if len(p)>14 else "")
m=(j.get("message") or "")
print("|".join([j.get("session_id",""),(j.get("cwd") or "").replace("|","/"),p,"1" if "permission" in m.lower() else "0"]))
')
[ -z "$sid" ] && exit 0
F="$D/$sid"
if [ "$1" = end ]; then rm -f "$F" "$N/$sid"; exit 0; fi
if [ "$1" = ask ] && [ "$perm" != 1 ]; then exit 0; fi
if [ ! -s "$N/$sid" ]; then echo "${pr:-$(basename "${cwd:-session}")}" > "$N/$sid"; fi
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
