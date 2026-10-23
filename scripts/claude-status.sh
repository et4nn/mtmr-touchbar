#!/bin/bash
D=$HOME/.config/mtmr/sessions
out=""
for f in "$D"/*; do
  [ -f "$f" ] || continue
  [ $(( $(date +%s) - $(stat -f %m "$f") )) -gt 21600 ] && { rm -f "$f"; continue; }
  read st cnt tm nm < "$f"
  case "$st" in
    work) item="$nm ⏳" ;;
    ask)  item="$nm ❗" ;;
    ans)  item="$nm ✓$cnt" ;;
    *)    continue ;;
  esac
  out="${out:+$out │ }$item"
done
echo "${out:-Idle}"
