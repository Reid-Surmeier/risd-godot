# Leopard Cover Flow motion reference

Checked 2026-09-26 before implementation. The requested historical reference is **Apple Mac OS X 10.5 Leopard Finder Cover Flow**. Apple announced the Finder addition in June 2007 and shipped Leopard on October 26, 2007. [Apple announcement](https://www.apple.com/newsroom/2007/06/11Apple-Unveils-Near-Final-Mac-OS-X-Leopard/), [Apple release announcement](https://www.apple.com/newsroom/2007/10/16Apple-to-Ship-Mac-OS-X-Leopard-on-October-26/).

## Video inspected

[Apple's Mac OS X Leopard Guided Tour, preserved in a third-party upload](https://www.youtube.com/watch?v=9RIJhdY6134&t=263s). This is Apple-produced footage, not an Apple-owned upload. Downloaded the 768×480, 24fps video with yt-dlp and visually inspected extracted sequential frames; auto-caption timing helped locate sections. Temporary inspection files: `/tmp/leopard-tour.mp4`, `/tmp/leopard-finder-sequence.jpg`, `/tmp/leopard-turn.jpg`.

| Timestamp | Observation |
| --- | --- |
| [4:20–4:25](https://www.youtube.com/watch?v=9RIJhdY6134&t=260s) | Finder changes into Cover Flow: a front-facing selected preview, angled neighbors, bottom scrubber, synchronized file list. |
| [4:26–4:28](https://www.youtube.com/watch?v=9RIJhdY6134&t=266s) | A portrait moves left and turns while the next document moves inward and straightens. Translation and rotation happen together. Eight sampled frames per second show continuous movement rather than image replacement. |
| [4:31–4:38](https://www.youtube.com/watch?v=9RIJhdY6134&t=271s) | Rapid traversal passes several files. Neighbors overlap into stacks, with nearest cards covering farther ones. Cards retain their aspect ratios and share a stable floor. |
| [4:44–4:51](https://www.youtube.com/watch?v=9RIJhdY6134&t=284s) | Small arrows browse pages inside the selected document; these are separate from changing selected files. |

The original floor is black with mirrored reflections. The requested white floor and soft shadows are an intentional adaptation. A sampled single-item transition occupies roughly half a second; the exact easing and angle are not recoverable from this footage alone. [Video](https://www.youtube.com/watch?v=9RIJhdY6134&t=266s).

## Implementation targets inferred for this gallery

These are practical design choices, not claims about Apple's source code:

1. Use one fractional selection position shared by every card. Compute each card's offset from that position, so changing direction mid-animation cannot leave independent animations disagreeing.
2. Keep the selected painting flat and readable. Rotate side paintings around their vertical axis, initially about 55–65 degrees, and stack farther paintings with smaller horizontal increments. Tune against the supplied image rather than claiming an exact historical angle.
3. Animate position and angle together, initially with approximately 400ms settling. Keep a fixed floor and preserve artwork aspect ratio. Paintings must remain recognizable while moving.
4. Attach a consistent soft floor shadow to each painting's moving position. Use the same light direction throughout; keep the blue window frame fixed around a clipped inner gallery.
5. Provide side-card click, previous/next buttons, arrow keys, wheel/trackpad navigation, and pointer drag. These inputs should all update the same selection. Offer a larger artwork view from the selected painting and respect reduced motion. The video confirms the visible scrubber and synchronized selection; exact wheel/keyboard bindings were not established by the inspected segment.

For the smallest faithful result, the surrounding Finder file table and document-page controls are unnecessary: the user requested paintings, their titles, and fluid browsing inside the supplied blue frame.
