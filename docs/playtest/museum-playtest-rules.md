# Museum playtest rules

What "played through" means for the Collection museum. A build has not been playtested until every
rule below has been run against it and its results looked at. The harness is
`modules/shell/playtest/museum_playtest.gd`; the room list comes from the build itself
(`collection_rooms/geometry.json` plus the Main Hall), so a new room is covered the day it is added.

## Run it

```bash
source ~/promo-lab/gpu-env.sh          # the RTX through Mesa d3d12; llvmpipe is ten times slower
export DISPLAY=:99
godot --fixed-fps 60 --path . --script res://modules/shell/playtest/museum_playtest.gd \
  --display-driver x11 --rendering-driver opengl3 -- --out-dir=res://build/museum-playtest
```

`--fixed-fps 60` makes each frame one sixtieth of a second of game time, so two runs of the same
commit give the same result. The run writes `report.json`, one picture per view and one per opened
object, and exits non-zero if any rule failed. `--only=doors,rooms,views,objects` runs part of it.

## The rules

1. **Every doorway, both ways, on foot.** The visitor is put just inside one side and the keys a
   player would hold carry it through to just inside the other, then back. It must arrive, in the
   room the doorway claims to lead to, without a jump of more than 0.25 m in one frame, playing its
   walk clip and landing footsteps.
2. **Every room, from every door, by clicking.** A click on the middle of the room must walk the
   visitor there round whatever furniture is in the way.
3. **Every area, looked at from every side.** One standpoint per seven metres of each room's long
   axis; at each, the dollhouse view facing north, east, south and west and the follow view are
   photographed. A view fails when one flat surface fills more than 45% of the picture (a wall in
   the lens) or when the visitor cannot be seen in it.
4. **Every object, clicked.** Each of the Hall's paintings and each catalogued work in the added
   rooms is clicked with a real mouse press from in front of it. The click must select that object,
   the visitor must walk up and face it, its detail must open with its picture and caption, and it
   must close again. The opened detail is photographed.
5. **Movement.** Walk, sprint (Shift) and jump (Space) are exercised by
   `modules/shell/playtest/visitor174_check.gd`: clip choice, step cadence, floor contact, jump
   height, no footsteps in the air.

## What a person or reviewer still has to do

The harness finds what can be counted. It cannot tell whether a room looks right. After a run:

- Open every picture in the output folder. For each room compare against the reference footage
  frames named in `docs/research/2026-10-01-museum-architecture-audit.md` and
  `docs/research/2026-10-01-museum-inventory-audit.md`: walls, doors, floor pattern, ceiling,
  every object present and in its place, nothing floating, intersecting or missing a face.
- Check lighting room by room against `docs/research/2026-10-01-acnh-museum-polish-spec.md`.
- Play the exported Web build by hand through the whole loop at least once, with sound on.

## Reviewer verdicts

An independent reviewer gets this file, the run's `report.json`, the pictures and the reference
frames, and must run the harness itself rather than trust the report. It answers per room:
PASS or FAIL with the picture and the reason, and a first line `VERDICT: DONE` or `VERDICT: NOT DONE`.
A verdict is bound to the commit it was run on.
