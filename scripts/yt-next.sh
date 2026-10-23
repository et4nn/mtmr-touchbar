#!/bin/bash
osascript <<'AS' >/dev/null 2>&1
tell application "Google Chrome"
  repeat with w in windows
    repeat with tb in tabs of w
      if URL of tb contains "youtube.com/watch" then
        execute tb javascript "var b=document.querySelector('.ytp-next-button'); if(b){b.click();}"
        return
      end if
    end repeat
  end repeat
end tell
AS
