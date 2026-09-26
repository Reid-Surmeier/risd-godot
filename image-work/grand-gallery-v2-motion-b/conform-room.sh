#!/bin/bash
# usage: conform-room.sh <mp4> <out-dir>   12 fps held frames, the stills' retro reduction, 960x640 jpg
set -e
T=$(mktemp -d); mkdir -p "$2"; rm -f "$2"/*.jpg
ffmpeg -v error -i "$1" -vf fps=12 "$T/%03d.png"
i=0; G=~/risd-godot-worktrees/gallery-walk-prototype/image-work/grand-gallery-v2
for f in "$T"/*.png; do
  python3 $G/degrade.py "$f" "$T/d.png" --match $G/references/style-grand-gallery-final.png --out-w 960
  convert "$T/d.png" -quality 92 "$2/$(printf %03d $i).jpg"; i=$((i+1))
done
rm -rf "$T"; echo "$i frames -> $2"
