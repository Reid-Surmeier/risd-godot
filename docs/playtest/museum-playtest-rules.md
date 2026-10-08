# Museum playtest rules

What "played through" means for the Collection museum. A build has not been playtested until every
rule below has been run against it and its results looked at. The harness is
`modules/shell/playtest/museum_playtest.gd`; the room list comes from the build itself
(`modules/shell/collection_rooms/geometry.json` plus the Main Hall), so a new room is covered the day it is added.

## Run it

```bash
source ~/promo-lab/gpu-env.sh          # the RTX through Mesa d3d12; llvmpipe is ten times slower
export DISPLAY=:99
godot --fixed-fps 60 --path . --script res://modules/shell/playtest/museum_playtest.gd \
  --display-driver x11 --rendering-driver opengl3 -- --out-dir=res://build/museum-playtest
```

`--fixed-fps 60` makes each frame one sixtieth of a second of game time, so two runs of the same
commit give the same result. The run writes `report.json`, one picture per view and one per opened
object, and exits non-zero if any rule failed. `--only=doors,rooms,views,objects,interaction,light` runs part of it.
`--objects=E1,21.482` drives only the named works (by tag, or by the accession before its `#`).

## The rules

1. **Every doorway, both ways, on foot.** The visitor is put just inside one side and the keys a
   player would hold carry it through to just inside the other, then back. It must arrive, in the
   room the doorway claims to lead to, without a jump of more than 0.25 m in one frame, playing its
   walk clip and landing footsteps.
2. **Every room, from every door, by clicking.** A click on the middle of the room must walk the
   visitor there round whatever furniture is in the way. The middle is the free floor nearest it,
   on each level the room has: in the Skylight Gallery the visitor is walked to the landing and
   down the stair to the lower floor, and back to the door from each. Walls and doorways are
   clicked, views photographed and works clicked from those same standpoints.
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
   height, no footsteps in the air; one stride carried through every change of gait with each foot sounding in turn, a landing
   after every jump that hands back to the gait the keys ask for, and a sprint thrown into
   reverse that skids at once and only once (#259). A floor click made while a movement key is
   held gives way to the key: one walking speed on every frame, never the key's travel added to
   a click route (#280).
6. **Inspection shows the work.** When a work opens, the work that opened is the one clicked, it
   is drawn (the camera's cut-away has not hidden it), all of it is inside the picture, and the
   visitor's body does not overlap it on screen. A second
   click on it opens its zoom page from wherever the visitor ended up standing, including just
   through a doorway. (Objects pass.) Further (#272): the caption panel covers none of
   the work (no more than two hundredths of its rectangle); a flat work, a photo card or a
   cut-out, shows at least six tenths of its face, standing or lying; and at five points of
   the work's rectangle no other work is met before it by the lens's ray. Where the museum
   gives a work a face (a card at any angle, a slab lying down, the front of a cabinet) the
   lens leans at least 0.6 towards it, and the work is drawn in its own inspection. The
   visitor does not crowd the lens: its box takes no more than a tenth of the picture. And
   nothing else that is drawn stands before the work: at those five points no mesh is met more
   than 0.8 m before it, nor a thin pane more than 1.5 m before it (nearer is the glass of its
   own case, and so is a pane with no floor between it and the work). A work whose catalogue
   row names no photograph has no zoom page: the second click leaves it being read, and the
   pass allows that for those rows only, never by a list of names. Once the inspection closes
   and the camera is back, the visitor is in sight: a ray from the lens to its chest and one
   to its head each meet nothing drawn (a pane thinner than 5 cm is glass).
7. **The same hop at any frame rate.** The jump is run at 15, 30, 60 and 120 frames a second and
   must rise the same height within 3 cm. (`visitor174_check.gd`.)
8. **No script errors.** The run's log must contain no `SCRIPT ERROR`; `build/run-playtest.sh`
   prints any it finds. A click on floor nobody can reach is one way to cause one and must do
   nothing.
9. **Captions read and zoom pages show the work.** (Objects pass, #271.) The record behind every
   caption has a title, a maker and a museum number, and is a catalogue record, not a working
   name. Every character of the caption has a glyph in the caption font itself: the Web build has
   no system font to fall back on. In the photograph of the inspection panel and of the zoom page
   each caption line is letters, not solid blocks and not nothing. The zoom page's picture is not
   a blank rectangle, and its caption lies clear of the picture, also when the page is magnified
   (one wheel notch, then fully), where it is put away and comes back at the fitted size. A run that fails only on "drew
   as solid blocks" or "did not draw" is run again before it is believed: one capture on
   7 October drew 19 captions that way and no later run of the same build has.
10. **What a player found by playing stays fixed.** (Interaction pass, #280.) Each fault is
    replayed with real pointer events. "Other wall" is not offered while a work is being read or
    while the camera glides back from it, so the visitor never walks off under an open caption;
    the button is back once the reading has closed. Nor is it shown, or does it answer, from
    the moment a room change starts until it has finished. Each case is run as at launch, when
    only the Hall is built, and again once the rooms are. A reading is a camera shot: the
    camera reaches the inspection shot, and on no frame of its glide in or back does a wall
    of the Hall stand in the lens. Read, a Hall work's rectangle on screen lies inside the
    picture, stands at least a quarter of its height, and has none of itself under the
    caption panel (five works: one per wall and the three round 4 named). A wall is not floor: in every room, facing
    each wall in turn, a click on the drawn wall starts no walk, and a click in a doorway of
    that wall, low or high in its dark, sends the visitor through that door: at least 1.4 m past
    its sill where the floor goes that far (past the doorway's own thickness, as the keys carry
    it), and no further than 3.8 m. The work under the pointer is the one that opens: where
    two works' boxes overlap on screen (the carved diptych 22.201 and the book cover 34.016 in
    one case) a click on either selects that one, from both ends of the case.

10. **Every room is lit, and lit the same way.** (Light pass, #274.) Each room's bake lists at
   least one lamp, every catalogued work in an added room has a spot aimed at it, and in the
   room's four dollhouse views the wall beside its works is brighter than the same walls a
   metre or more from any work. The pass also prints, per room, the colour and brightness of
   the floor, the walls, the skirting and the works as the picture shows them (0 to 255). Those are pictures, not
   light: the Hall's floor reads about 143 and its paintings about 79, so "works brighter
   than the floor" is not a rule.

Round 1's reviewer asked for four more that the harness does not have yet; until it does, the
reviewer checks them by hand and says so:

- Things the camera has cut away must not answer a click (probe hidden works in each room).
- Each room's displays are compared with `docs/research/2026-10-01-museum-object-manifest.md`,
  not with the build's own object list, which cannot show what is missing.
- Shift held through reading, zoom, focus loss and a tab change still sprints or stops correctly.
- Turns, view changes and doorway crossings are recorded as continuous frames: no cut, no camera
  inside the visitor's head, no shadow left behind by a hidden painting.
  `modules/shell/playtest/locomotion_record.gd` records the movement itself this way: real keys,
  one picture and one log row (clip, clip phase, speed, jump state) per frame.

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
