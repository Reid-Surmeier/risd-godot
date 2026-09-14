## The tab_strip seam. Other modules reference this file only. Frozen: changing it is an Issue.
##
## A TabStrip is a Control that reproduces the Windows Live / IE7 toolbar from sliced
## source pixels and opens new tabs the way the 2008 tab-strip idiom did: press the
## blank New Tab stub, the stub grows into a full tab over 400 ms (ease-out) with the
## fresh stub riding on its right edge, the tab reads "Connecting..." then swaps to
## "Blank Page" in one frame. Every open tab owns one page in a PageStack; selecting a
## tab shows its page. A fixed tab (open_fixed_tab) is titled from the labels map, owns the
## caller's page Control, draws no close button and never closes (seam Issue #39).
##
## Every public function returns { ok: bool, value: Variant, error: Variant }.
## Errors are the values in errors.gd. The strip raises nothing across this seam.
class_name TabStripInterface
extends RefCounted

const Errors := preload("res://modules/tab_strip/errors.gd")
const _Impl := preload("res://modules/tab_strip/tab_strip.gd")

## Label keys the strip has source pixels for.
const LABEL_WINDOWS_LIVE := "windows_live"
const LABEL_CONNECTING := "connecting"
const LABEL_BLANK_PAGE := "blank_page"

## Timing of the open gesture, in seconds. The values every acceptance test asserts against.
const PRESS_SECONDS := 0.1
const GROW_SECONDS := 0.4
const CONNECTING_SECONDS := 0.95


## Build a strip with one "Windows Live" tab and its stub, plus the PageStack it drives.
## `page_stack` is the Control that receives one page child per tab; the caller owns it
## and passes it in (dependencies are passed, never constructed inside).
## Returns ok(TabStrip node) or err(ASSET_MISSING).
static func create(page_stack: Control) -> Dictionary:
	return _Impl.create(page_stack)


## Open a new tab exactly as a click on the stub does (animation included) and open its page.
## Returns ok(new index) or err(OPEN_IN_PROGRESS | NO_ROOM).
static func open_new_tab(strip: Control) -> Dictionary:
	return strip.open_new_tab()


## Open a fixed, titled tab at once: no grow animation, no signals. Its label is
## `label_<label_key>.png` from the `labels` map in layout.json; a key with no label (phone,
## until #34) shows the page icon alone and logs it. The tab owns `page`, the caller's Control
## (added hidden to the PageStack, full-rect, shown by select_tab); a fixed tab has no close
## button and close_tab on it returns TAB_FIXED. Returns ok(new index) or err(OPEN_IN_PROGRESS | NO_ROOM).
static func open_fixed_tab(strip: Control, label_key: String, page: Control) -> Dictionary:
	return strip.open_fixed_tab(label_key, page)


## Make tab `index` the active tab and show its page. Returns ok(index) or err(INDEX_OUT_OF_RANGE).
static func select_tab(strip: Control, index: int) -> Dictionary:
	return strip.select_tab(index)


## Close tab `index` exactly as a click on its close button does: its page goes with it, the row
## re-lays out, the left neighbour (or the first tab) becomes active. Every tab can close, the last
## one too (the stub then sits at the first tab's place); a fixed tab refuses with TAB_FIXED.
## Returns ok(remaining count) or err(INDEX_OUT_OF_RANGE | TAB_FIXED | OPEN_IN_PROGRESS).
static func close_tab(strip: Control, index: int) -> Dictionary:
	return strip.close_tab(index)


## Make the bar `width` source pixels wide: stars stay left, the icon cluster stays right,
## pinstripes fill the middle, tabs get the room between. Called by the owner on resize.
static func set_bar_width(strip: Control, width: float) -> void:
	strip.set_bar_width(width)


## Number of tabs, the active index, and each tab's current label key, pixel rect, whether it is
## fixed, whether its label is truncated with "...", and its close button rect (empty on a fixed tab).
## Returns ok({ count, active, tabs: [{ label, rect, page_visible, fixed, truncated, close_rect }],
## opening: bool, bar_width }).
static func state(strip: Control) -> Dictionary:
	return strip.state()


## The stub's rectangle in the strip's coordinates, so a harness can click it with a real mouse event.
static func stub_rect(strip: Control) -> Rect2:
	return strip.stub_rect()


## Signals on the strip node (connect to them on the returned node):
##   tab_opened(index: int)       — the new tab exists and its grow has started
##   tab_settled(index: int)      — grow finished, label is "Connecting..."
##   tab_titled(index: int)       — label swapped to "Blank Page"
##   tab_selected(index: int)     — active tab changed; its page is visible
##   tab_closed(index: int)       — a tab and its page were removed
