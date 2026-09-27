# Sound sources

Sound effects from Animal Crossing: Wild World (Nintendo DS, 2005), © Nintendo. For the private prototype only.

Each clip starts 7 ms before the sound, fades out over 15 ms, is normalized to about -3 dBFS peak, and is saved as mono 44.1 kHz Vorbis (`-q:a 5`). No clip has music under it.

## Sources

**A. Wild World capture.** "Animal Crossing: Wild World – 1 Hour of Relaxing No Commentary Gameplay [DS]", from the channel Cozy Classic Games.
https://www.youtube.com/watch?v=GgR0ZqG0o5E
It was recorded from an original DS game through a capture card. Every clip from A was matched to its action by looking at video frames at that moment. The clips from inside the house sit in digital silence. The outdoor clips have a quiet wind and wave bed about 15–20 dB below the effect.

**B. Mixed compilation.** "Animal Crossing Sound Effects! (from Animal Crossing and Animal Crossing Wild World !)", from the channel yuus9912.
https://www.youtube.com/watch?v=WwSkCuRGGAI
Between effects the audio is digital silence. The recording has a steady 15.734 kHz whine (the NTSC line rate), which suggests an analog capture, probably from the GameCube. That whine was notched out. A clip from B is only used when its waveform shows up in source A: its normalized cross-correlation with A is 0.75–0.85 at several separate moments. That is the same sample Wild World plays.

## Files

| File | Src | Start–end (s) | What it is |
|---|---|---|---|
| step_wood_01.ogg | A | 299.503–299.738 | Player walking on the wooden floorboards inside their house (the first house), step 1 |
| step_wood_02.ogg | A | 299.901–300.059 | same walk, step 2 (other foot, shorter sample) |
| step_wood_03.ogg | A | 300.347–300.618 | same walk, step 3 |
| step_wood_04.ogg | A | 301.249–301.409 | same walk, step 4 |
| step_wood_05.ogg | A | 301.653–301.888 | same walk, step 5 |
| step_wood_06.ogg | A | 302.005–302.165 | same walk, step 6 |
| step_ground_01.ogg | B | 342.687–342.835 | Footstep on grass. From B's "Footstep" section (5:30), 5th group of 4. Correlates 0.75 with the player walking on grass in A (e.g. 993.3 s, 2159.8 s, 3391.3 s) |
| step_ground_02.ogg | B | 343.110–343.243 | same group, step 2 |
| step_ground_03.ogg | B | 343.560–343.792 | same group, step 3 |
| step_ground_04.ogg | B | 344.000–344.135 | same group, step 4 |
| pickup.ogg | A | 444.322–444.540 | Player bends and picks up a fallen apple (the apple disappears at 444.5–444.6 s). Outdoors, with a faint ambient bed |
| menu_open.ogg | A | 303.205–303.660 | Touch-screen panel swoosh as a bottom-screen panel opens, recorded inside the house. The pocket opens with the same sound (outdoor instance at 282.51 s, correlation 0.84) |
| menu_close.ogg | A | 304.841–305.296 | The same panel closing (the pocket closes with it too: 284.41 s, correlation 0.93). The game uses nearly the same sound for opening and closing |
| cursor.ogg | A | 1445.379–1445.449 | Keyboard key tap while writing a letter, in digital silence. It stands in as the cursor tick |
| item_select.ogg | A | 1649.051–1649.282 | Tapping an item in the pocket, which opens its "Give This / Never Mind" pop-up. Same sample as B 38.83 s (the "Pocket" section) |
| select.ogg | B | 41.220–41.520 | Confirming a choice. Matches A where the player picks "Delivery!" (1645.55 s) and "Swap it" (3290.02 s) |
| cancel.ogg | B | 46.520–46.830 | Backing out. Matches A where the player picks "Never Mind" (3296.24 s) and "I'm done!" at Nook's (2064.61 s) |
| door.ogg | A | 296.415–298.283 | Player opens their house door and goes in, through the circle-wipe transition. Outdoors, with a faint ambient bed |

Times are seconds into each YouTube video.
