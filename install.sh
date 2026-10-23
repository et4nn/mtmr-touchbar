#!/bin/bash
# Installs the Touch Bar config for MTMR. Safe to run more than once.
here=$(cd "$(dirname "$0")" && pwd)
dest=$HOME/.config/mtmr
cfg="$HOME/Library/Application Support/MTMR"

if [ ! -d /Applications/MTMR.app ]; then
  echo "MTMR is not installed. Get it from https://github.com/Toxblh/MTMR/releases and run this again."
  exit 1
fi

mkdir -p "$dest" "$cfg"
cp "$here"/scripts/*.sh "$dest"/
chmod +x "$dest"/*.sh

# night mode helper (private CoreBrightness class, needs the Xcode command line tools)
if clang -fobjc-arc -o "$dest/nightshift" "$here/nightshift/nightshift.m" -framework Foundation 2>/dev/null; then
  echo "built nightshift"
else
  echo "could not build nightshift (try: xcode-select --install)"
fi

# optional: cpu temperature
if [ ! -x "$dest/osx-cpu-temp" ]; then
  tmp=$(mktemp -d)
  ( cd "$tmp" \
    && curl -sL https://github.com/lavoiesl/osx-cpu-temp/archive/refs/heads/master.zip -o t.zip \
    && unzip -q t.zip && cd osx-cpu-temp-master && make >/dev/null 2>&1 \
    && cp osx-cpu-temp "$dest/" ) || echo "skipped cpu temperature"
  rm -rf "$tmp"
fi

python3 "$here/tools/make_icons.py" "$dest"

if [ -f "$cfg/items.json" ]; then
  cp "$cfg/items.json" "$cfg/items.backup.$(date +%Y%m%d%H%M%S).json"
fi
sed "s|__HOME__|$HOME|g" "$here/items.json" > "$cfg/items.json"

# claude code hooks (merged into ~/.claude/settings.json)
python3 - <<'PY'
import json, os, shutil
p = os.path.expanduser('~/.claude/settings.json')
os.makedirs(os.path.dirname(p), exist_ok=True)
try:
    s = json.load(open(p))
    shutil.copy(p, p + '.bak')
except Exception:
    s = {}
hooks = s.setdefault('hooks', {})
cs = os.path.expanduser('~/.config/mtmr/cs.sh')
events = {'UserPromptSubmit': 'work', 'PreToolUse': 'work',
          'Notification': 'ask', 'Stop': 'ans', 'SessionEnd': 'end'}
for event, arg in events.items():
    cmd = cs + ' ' + arg
    groups = hooks.setdefault(event, [])
    if any(h.get('command') == cmd for g in groups for h in g.get('hooks', [])):
        continue
    group = {'hooks': [{'type': 'command', 'command': cmd}]}
    if event == 'PreToolUse':
        group['matcher'] = '*'
    groups.append(group)
json.dump(s, open(p, 'w'), indent=2)
PY

killall MTMR 2>/dev/null; sleep 1; open -a MTMR
echo "done"
