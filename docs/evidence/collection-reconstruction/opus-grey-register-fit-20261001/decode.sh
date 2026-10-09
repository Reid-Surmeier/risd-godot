#!/usr/bin/env bash
# Native CPU decode of the six fit frames from the hash-verified originals (read only).
# Frame K (0-based) after an accurate seek to START; display rotation applied by ffmpeg.
set -euo pipefail
V=/home/reidsurmeier/risd-godot-ingestion/collection-expansion/verified
out="$(cd "$(dirname "$0")" && pwd)/frames"
dec() { ffmpeg -v error -y -ss "$3" -i "$V/IMG_$2.MOV" -vf "select=eq(n\,$4)" -fps_mode passthrough -frames:v 1 -pix_fmt rgb24 "$out/$1.png"; }
dec A1-6380-038.300 6380 38.30 0     # whole south end of the west wall
dec A2-6380-038.901 6380 38.30 18    # same pan 0.6 s later: north end
dec B1-6381-090.968 6381 89.40 47    # marble stair, other video (stored as decoded: upside down)
dec C1-6380-001.600 6380 1.20 12     # Courbet close, north-west corner
dec D1-6380-101.601 6380 100.60 30   # south-west corner and casing, close
dec F1-6380-240.268 6380 238.80 44   # Rockefeller end of the connector
