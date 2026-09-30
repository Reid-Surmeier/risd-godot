# Ephemeral webcam booth prototype

Independent Godot 4.7.2 project in the `webcam-booth-195` Orca worktree. Open **this folder's** `project.godot`, not the RISD root project. No RISD runtime module is imported. The outer `.gdignore` keeps it out of root Godot discovery.

```bash
./webcam-booth/export.sh
node webcam-booth/testing/browser.mjs
```

The exported page is in `webcam-booth/build/web/`. The camera works through browser `getUserMedia` on HTTPS. Use “Try sample photo” for the supplied board fixture. Loading uses a byte-identical copy of the existing four-dot/bar shader. Then a declared reference portrait appears for ten seconds, an **empty explosion placeholder** removes it, and the camera returns. The timer uses wall time so backgrounding the page does not grant extra viewing time.

This answers whether the isolated Godot Web camera/state flow works. It does not establish Muse generation, likeness, transparent gloves, fuse animation, an explosion animation, physical-webcam behavior or face tracking. The sample is the reference character, not a generated version of the captured face. No photo is uploaded, saved or sent to a provider in this prototype. Preview frames stay in memory; the capture reference is cleared on reset. Camera tracks stop when leaving the page or selecting the fixture.

Acceptance evidence lives in `review/evidence/browser.json` and its screenshots. Run on the export, it checks two complete ten-second loops, cancellation, real getUserMedia with Chromium's synthetic camera, bridge decoding, permission denial and stale-camera-stream cleanup. Synthetic-camera proof is labelled separately from a real webcam test.

Source and hashes: [PROVENANCE.md](PROVENANCE.md). Route decisions: [browser research](../docs/research/webcam-booth-browser.md), [generation research](../docs/research/webcam-booth-generation.md). Canonical next work: [Map: build an isolated retro webcam portrait booth](https://github.com/Reid-Surmeier/risd-godot/issues/195). Spend ceiling $10; spent $0.
