#!/usr/bin/env bash
# Runs check.gd and its negative control in a disposable copy, on the CPU, and brings back the renders and logs.
# usage: run_check.sh <empty scratch dir>
set -uo pipefail
here=$(cd "$(dirname "$0")" && pwd)
copy=${1:?scratch dir}
rm -rf "$copy" && mkdir -p "$copy" && cp -r "$here"/. "$copy"/ && rm -rf "$copy/renders"
run() { env LIBGL_ALWAYS_SOFTWARE=1 GALLIUM_DRIVER=llvmpipe DISPLAY=:99 godot --path "$copy" --rendering-method gl_compatibility --script check.gd "$@" 2>&1; echo "exit=$?"; }
run | sed "s#$copy#<copy>#g" > "$here/native.log"
run -- open | sed "s#$copy#<copy>#g" > "$here/negative-control-open.log"
rm -rf "$here/renders" && cp -r "$copy/renders" "$here/renders" && cp "$copy/checks.json" "$here/checks.json"
tail -n 1 "$here/native.log" "$here/negative-control-open.log"
