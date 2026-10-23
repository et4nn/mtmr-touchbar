#!/bin/bash
export LC_ALL=en_US.UTF-8
pgrep -x "Google Chrome" >/dev/null || { echo ""; exit; }
y=$(osascript <<'AS' 2>/dev/null
tell application "Google Chrome"
  repeat with w in windows
    repeat with tb in tabs of w
      if URL of tb contains "youtube.com/watch" then
        try
          set ps to execute tb javascript "(document.querySelector('video')&&!document.querySelector('video').paused)?'1':'0'"
        on error
          set ps to "?"
        end try
        if ps is "1" then return title of tb
      end if
    end repeat
  end repeat
end tell
AS
)
y=$(printf '%s' "$y" | sed 's/^([0-9]*) //; s/ - YouTube$//')
echo "${y:0:30}"
