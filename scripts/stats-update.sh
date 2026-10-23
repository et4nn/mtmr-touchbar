#!/bin/bash
export LC_ALL=C
export PATH=$PATH:/usr/local/bin:/opt/homebrew/bin:$HOME/.config/mtmr
C=/tmp/mtmr-stats.cache
idle=$(top -l 2 -s 1 -n 0 2>/dev/null | awk '/CPU usage/{v=$7} END{print v}')
idle=${idle%\%}
page=$(sysctl -n hw.pagesize 2>/dev/null); tot=$(sysctl -n hw.memsize 2>/dev/null)
ram=$(vm_stat 2>/dev/null | awk -v p="$page" -v t="$tot" '/Pages active/{a=$3}/Pages wired down/{w=$4}/occupied by compressor/{c=$5}END{if(t>0)printf "%d",(a+w+c)*p/t*100}')
if [ -n "$idle" ] && [ -n "$ram" ]; then
  cpu=$(awk -v i="$idle" 'BEGIN{printf "%d", 100-i}')
  out="C${cpu}% · R${ram}%"
  t=$(osx-cpu-temp 2>/dev/null | sed 's/[^0-9.].*//' | cut -d. -f1)
  [ -n "$t" ] && [ "$t" != 0 ] && out="$out · ${t}°"
  echo "$out" > "$C.tmp" && mv "$C.tmp" "$C"
fi
