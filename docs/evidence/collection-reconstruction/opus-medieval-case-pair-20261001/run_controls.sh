#!/usr/bin/env bash
# Headless controls: bash run_controls.sh [root checkout]
# 1. the helper instantiates with no display; 2. three sabotaged copies must each make check.gd exit 1. Prints every exit code.
set -uo pipefail
here=$(cd "$(dirname "$0")" && pwd)
repo=$(cd "$here/../../../.." && pwd)
root=${1:-/home/reidsurmeier/orca/workspaces/risd-godot/collection-reconstruction}
helpers=modules/shell/prototype/collection_reconstruction
work=$(mktemp -d "${TMPDIR:-/tmp}/medieval-pair-controls.XXXXXX")
trap 'rm -rf "$work"' EXIT
project() {  # project <name> <sed expression or empty>
  mkdir -p "$work/$1/out"; touch "$work/$1/project.godot"
  cp "$root/$helpers/seated_woman_asset.gd" "$root/$helpers/medieval_metal_assets.gd" "$here/check.gd" "$here/smoke.gd" "$here"/decal-queens-*.png "$work/$1/"
  sed -e "${2:-}" "$repo/$helpers/medieval_ceramic_ivory_assets.gd" > "$work/$1/medieval_ceramic_ivory_assets.gd"
  if [ -n "${2:-}" ] && cmp -s "$repo/$helpers/medieval_ceramic_ivory_assets.gd" "$work/$1/medieval_ceramic_ivory_assets.gd"; then echo "sabotage $1 changed nothing"; exit 2; fi
}
status=0
project smoke
echo "## headless instantiate smoke"
godot --headless --path "$work/smoke" -s smoke.gd 2>&1 | grep -v '^$'; code=${PIPESTATUS[0]}
echo "exit $code (want 0)"; [ "$code" -eq 0 ] || status=1
while IFS='|' read -r name expression; do
  project "$name" "$expression"
  echo "## sabotage: $name"
  godot --headless --path "$work/$name" -s check.gd -- "$work/$name/out" --no-views >/dev/null 2>&1; code=$?
  python3 -c "import json; print('failures:', json.load(open('$work/$name/out/checks.json'))['failures'])"
  echo "exit $code (want 1)"; [ "$code" -eq 1 ] || status=1
done <<'CASES'
height-1cm-short|s/OBJECTS.queens.size.y - top/OBJECTS.queens.size.y - .01 - top/
missing-foot|s/^\tfor k in 4:$/\tfor k in 3:/
christ-marked-matched|s/"catalogue_id": "1197491", "identity": "probable"/"catalogue_id": "1197491", "identity": "matched"/
CASES
echo "## controls $([ $status -eq 0 ] && echo passed || echo FAILED)"
exit $status
