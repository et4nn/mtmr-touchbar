#!/bin/bash
C=/tmp/mtmr-stats.cache
L=/tmp/mtmr-stats.lk
if [ -s "$C" ]; then cat "$C"; else echo "C-- · R--"; fi
find "$L" -maxdepth 0 -mmin +1 -exec rmdir {} \; >/dev/null 2>&1
( mkdir "$L" 2>/dev/null && { "$HOME/.config/mtmr/stats-update.sh"; rmdir "$L"; } ) >/dev/null 2>&1 </dev/null &
exit 0
