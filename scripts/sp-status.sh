#!/bin/bash
export LC_ALL=en_US.UTF-8
pgrep -x Spotify >/dev/null || { echo ""; exit; }
s=$(osascript -e 'tell application "Spotify" to if player state is playing then return (artist of current track) & " – " & (name of current track)' 2>/dev/null)
echo "${s:0:30}"
