# Collection search controls prototype evidence (#75)

Base build: `aedd474`. Locked Collection layout reference SHA-256: `e51cbb294653573b43432f623df7277a86adbeddb0d2f0d7c31b36928592075d`.

The prototype retains the existing Search filters frame and title, covers only its raster body, and places native `LineEdit`, `OptionButton`, `CheckBox`, and `Button` controls in the existing opening. It uses the repository's `PixelMplus12-Regular.ttf` as a readable substitute at the target sizes; this is not an exact font-match claim. `02b-controls-draft.png` records mixed-case letters, numerals, the active text field, changed dropdown values, and a checked box. `02-sort-popup.png` records native popup focus.

The result window shows three explicitly labelled fixtures: two SHA-verified RISD painting images and one missing-image card. Title, maker/date, RISD source/accession, and credit stay visible. The run also captures prior results during loading, empty success, failed search/retry, selected details, Save, Saved, and save-error presentations.

Visual inspection at 1920×1080 and 1440×900: the controls remain readable and inside the original frame; the Image Viewer and surrounding windows retain their source chrome; the page edges are light and contain no black bars. The prototype deliberately leaves the old raster footer count unchanged because changing production Collection chrome belongs to #79.

Run:

```sh
DISPLAY=:99 /home/reidsurmeier/.local/opt/godot-4.7.2/Godot_v4.7.2-stable_linux.x86_64 \
  --path . --script res://prototypes/collection_search_controls/harness.gd \
  --display-driver x11 --rendering-driver opengl3 -- \
  --out-dir=/tmp/collection-search-controls
python3 prototypes/collection_search_controls/verify.py /tmp/collection-search-controls
```

The verifier passed 25 checks. See `verification.json` for screenshot hashes and `report.json` for the actual timed pointer/keyboard log.
