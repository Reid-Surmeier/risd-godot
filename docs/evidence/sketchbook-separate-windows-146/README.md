# Separate painting and image viewer — #146

The original mountain/church painting is again a standalone movable window in the selected gold frame. The Finder-like blue/silver Cover Flow is a different movable window containing its six original unframed images. The palette v7 correction from #145 remains intact, saved Collection records remain stored, and the retired saved-card strip remains hidden.

Review `desktop.png` for the default layout and `compact.png` for the smaller viewport. The focused browser journey verifies six viewer images, absence of viewer-frame state, the separate painting and frame assets, independent dragging of both windows, palette pencil/eraser and mixing, viewer controls, drawing/page retention, window stacking, tab freeze/resume and resizing.

The same run recorded the existing slow-load behavior: the compressed Web payload is about 123 MB, and the loader eagerly warms every tab before reveal. On this machine the game pack mounted in about 4 seconds, while hidden tab warmup and the progress animation delayed reveal to roughly 70 seconds. Startup optimization remains scoped by #141.

No source bitmap was edited and no paid generation occurred.
