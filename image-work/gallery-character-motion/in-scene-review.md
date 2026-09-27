# Experimental visitor in-scene visual check

Agent inspection, 2026-09-26. `humanReviewed: false`, `certified: false`. This is the owner's approved experimental application import; the source tool Run remains failed.

Viewed actual Compatibility-renderer captures, not source-sheet previews:

- `/tmp/gallery-navigation/01-entrance.png` and `01b-entrance-walking.png`: idle and walking entrance.
- `/tmp/gallery-navigation/02-white-far.png`: rear view against the white navigation room.
- `/tmp/gallery-entry-final/dollhouse_shot/01-dollhouse-baked.png` and `04-other-wall.png`: opposite side profiles inside the desktop gallery.
- `/tmp/gallery-entry-final/navigation_check/03-return-door-far.png`: side profile against white floor/door.

The character occupies roughly one third of the game viewport height, with feet near 80% down, consistent with the prior composition target. Entrance idle/walk apparent heights stay close (visually about 241 vs 244 pixels in the 720-pixel capture); there is no obvious scale collapse when switching from the 800-pixel still cell to a 480-pixel motion cell. Shoes meet the contact-shadow area. Both side profiles are centred and readable after fixed registration. No visible saturated green border or rectangular matte is apparent at the actual displayed size, including against the white room.

One entrance issue was reported to the navigation owner: the initial waiting still faced backward but the incoming walk faced forward, producing a 180° direction pop on starting. This is heading initialization in the host, not a reason to mirror or redraw the character. The navigation agent owns its correction.

No visitor pixel or registration fix was necessary from these captures. The source still is relatively level/profile against a steep room camera; the figure remains a sprite interpretation, not a recovered 3D character. This set of stills establishes composition, matte and approximate foot registration, **not temporal proof of a seamless gait or absence of small loop resets**. The independent motion review retains those limitations. Native `visitor_check.gd` separately proves actual frame changes and cancellation logic; it does not replace visual judgment.
