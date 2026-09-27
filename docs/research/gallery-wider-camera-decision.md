# Wider dollhouse camera decision

The default dollhouse camera now uses a 23° field of view and aims 0.30 m higher. Pitch, follow distance, orbit input, geometry and visitor are unchanged. This two-value change reveals more of both entry paintings and the white doorway. At the art wall it includes the tall painting's top and more of its neighbors, with less empty floor. The visitor and each artwork appear about 9–13% smaller at 720 pixels.

| Pose | Before | After |
| --- | --- | --- |
| 720 entry | [image](../evidence/gallery-camera-integrated/baseline-720-entry.png) | [image](../evidence/gallery-camera-integrated/candidate-720-entry.png) |
| 720 art wall | [image](../evidence/gallery-camera-integrated/baseline-720-art.png) | [image](../evidence/gallery-camera-integrated/candidate-720-art.png) |
| 1600 art wall | [image](../evidence/gallery-camera-integrated/baseline-1600-art.png) | [image](../evidence/gallery-camera-integrated/candidate-1600-art.png) |

An [anonymous independent review](../evidence/gallery-camera-integrated/blind-verdict.md) selected the wider view (A=candidate, B=baseline), while noting the smaller character and residual right-edge crop. The camera agent's isolated evidence branch `Reid-Surmeier/gallery-camera-wider` at `64421fd` includes full 1600/720, white-room and motion comparisons plus raw timing/input logs. On that branch, native navigation, both portal roundtrips, rig contact, repository checks, and exported RTX browser motion passed. Median/p95 browser frame intervals stayed at about 16.7/16.8 ms; a sequential load comparison does not establish a load-speed change.

The “Other wall” button was then moved from the upper-right artwork to the lower-right floor area ([1600 entry](../evidence/gallery-camera-integrated/button-bottom-1600.png), [720 motion view](../evidence/gallery-camera-integrated/button-bottom-720.png)). Its exported RTX browser check passed after the input check's click coordinates followed the new placement. It remains in the image but no longer covers the upper painting; right-edge artwork can still be cropped by camera composition.
