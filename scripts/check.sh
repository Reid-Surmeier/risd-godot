#!/usr/bin/env bash
# Repository checks. Grows as the Godot project lands; every check here must be real.
set -euo pipefail
cd "$(dirname "$0")/.."
fail=0

# 1. Every MODULE.md has a row in MODULES.md.
while IFS= read -r m; do
  d=$(dirname "$m"); d=${d#./}
  if ! grep -q "($d/MODULE.md)" MODULES.md; then
    echo "MODULES.md is missing a row for $d"; fail=1
  fi
done < <(find . -name MODULE.md -not -path "./.git/*" -not -path "./build/*" -not -path "./.godot/*" -not -name "MODULE.template.md")

# 2. Seams: a module may only reference another module through its interface.gd.
while IFS= read -r f; do
  owner=$(echo "$f" | cut -d/ -f2)
  if grep -nE 'preload\("res://(modules/)?[a-z0-9_]+/' "$f" 2>/dev/null \
     | grep -vE "res://(modules/)?$owner/" | grep -v 'interface\.gd'; then
    echo "seam violation in $f — reference another module only through its interface.gd"; fail=1
  fi
done < <(find . -name '*.gd' -not -path "./.git/*" -not -path "./build/*" -not -path "./.godot/*" 2>/dev/null)

# 3. GDScript lint, when the toolchain is present and there is anything to lint.
if command -v gdlint >/dev/null 2>&1 && [ -n "$(find . -name '*.gd' -not -path './.git/*' -not -path './build/*' -not -path './.godot/*' -print -quit)" ]; then
  # Keep the unchanged upstream Mixbox SDK outside authored-style lint (#216).
  gdlint $(find . -name '*.gd' -not -path "./.git/*" -not -path "./build/*" -not -path "./.godot/*" -not -path "./modules/sketchbook/mixbox/mixbox.gd")
fi

# 4. Godot headless tests, when a project exists.
if [ -f project.godot ] && command -v godot >/dev/null 2>&1; then
  godot --headless --quit-after 200 --path . 2>&1 | tee /tmp/godot-import.log
  grep -qiE "^ERROR|SCRIPT ERROR" /tmp/godot-import.log && { echo "Godot reported errors on import"; fail=1; } || true
fi

[ "$fail" -eq 0 ] && echo "checks passed"
exit "$fail"
