#!/usr/bin/env python3
"""The preview set of the Video Player's five videos, from the originals kept out of Git.

  prepare.py --check                 hash the checked-in previews against manifest.json
  prepare.py --check-originals       hash the originals under runs/ against manifest.json
  prepare.py --prepare [--originals DIR]
                                     verify the originals, transcode them to 480 wide / 24 fps
                                     Ogg Theora/Vorbis into this folder, report the hashes

The originals (1280x720, 30 fps, 410 MB) are the issue-18 prepared files; they live under the
repository's gitignored runs/ folder, by default runs/issue-18-vimeo-media/prepared/. The
recorded preview hashes were produced by the prototype's ffmpeg build (see manifest.json); a
different build encodes different bytes, so --prepare prints what it made and whether it matches.
"""
import argparse
import hashlib
import json
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
MANIFEST = json.loads((HERE / "manifest.json").read_text())


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def check(kind: str, base: Path) -> bool:
    ok = True
    for v in MANIFEST["videos"]:
        rec = v[kind]
        path = base / (rec["file"] if kind == "preview" else Path(rec["path"]).name)
        if not path.exists():
            print(f"MISSING  {path}")
            ok = False
            continue
        got = sha256(path)
        good = got == rec["sha256"] and path.stat().st_size == rec["bytes"]
        print(f"{'ok      ' if good else 'MISMATCH'} {path.name}  {got[:16]}  {path.stat().st_size} bytes")
        ok = ok and good
    return ok


def prepare(originals: Path) -> bool:
    if not check("original", originals):
        print("originals do not match manifest.json; not transcoding", file=sys.stderr)
        return False
    ok = True
    for v in MANIFEST["videos"]:
        src = originals / Path(v["original"]["path"]).name
        out = HERE / v["preview"]["file"]
        args = [a.replace("<original>", str(src)).replace("<preview>", str(out))
                for a in MANIFEST["preview"]["ffmpeg_arguments"]]
        subprocess.run(["ffmpeg", "-hide_banner", "-loglevel", "error", "-nostdin", "-y", *args], check=True)
        got = sha256(out)
        same = got == v["preview"]["sha256"]
        print(f"{'same    ' if same else 'differs '} {out.name}  {got[:16]}  {out.stat().st_size} bytes")
        ok = ok and same
    return ok


if __name__ == "__main__":
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--check-originals", action="store_true")
    ap.add_argument("--prepare", action="store_true")
    ap.add_argument("--originals", type=Path, default=REPO / MANIFEST["originals"]["dir"])
    a = ap.parse_args()
    if a.check:
        sys.exit(0 if check("preview", HERE) else 1)
    if a.check_originals:
        sys.exit(0 if check("original", a.originals) else 1)
    if a.prepare:
        sys.exit(0 if prepare(a.originals) else 1)
    ap.print_help()
