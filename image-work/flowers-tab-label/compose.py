"""Muse input for the Flowers tab: the game's own compact taskbar pieces laid out exactly as
tab_strip.gd draws them (Collection, Playground, then a seventh empty tab and the stub), cropped to
x0..x1 of the bar. Every pixel is copied from modules/tab_strip/assets/compact; nothing is drawn."""
import json
import sys
from PIL import Image

A = "../../modules/tab_strip/assets/compact/"
L = json.load(open(A + "layout.json"))
tex = lambda n: Image.open(A + n + ".png").convert("RGBA")
T, PITCH, W = L["tab"], L["tab_pitch"], L["tab"]["full_width"]
X0, X1 = 2480, 4480
CHECK = sys.argv[1:] == ["--check"]  # after slice.py: the seventh tab with its Flowers pieces
xs = [T["first_tab_x"] + i * PITCH for i in range(7)]
keys = ["map", "sketchbook", "3d_viewer", "video_player", "collection", "playground", "flowers" if CHECK else None]


def tab(key):
    im = Image.new("RGBA", (W, T["height"]))
    im.alpha_composite(tex("tab_left"), (0, 0))
    mid = tex("tab_mid")
    for x in range(T["left_w"], W - T["right_w"], mid.width):
        im.alpha_composite(mid.crop((0, 0, min(mid.width, W - T["right_w"] - x), mid.height)), (x, 0))
    im.alpha_composite(tex("tab_right"), (W - T["right_w"], 0))
    if key:
        p = L["place"][key]
        im.alpha_composite(tex("icon_" + key), tuple(p["icon"]))
        im.alpha_composite(tex("label_" + key), tuple(p["label"]))
    return im


bar = Image.new("RGBA", (X1, L["bar_height"]))
st = tex("bar_stripes")
for x in range(0, X1, st.width):
    bar.alpha_composite(st, (x, 0))
bar.alpha_composite(tex("stub_idle"), (xs[6] + W + L["stub"]["gap_from_tab_right"], L["stub"]["y"]))
for i in reversed(range(4, 7)):
    bar.alpha_composite(tab(keys[i]), (xs[i], T["y"]))
bar.crop((X0, 0, X1, L["bar_height"])).convert("RGB").save("check-seven-tabs.png" if CHECK else "input-seven-tabs.png")
print("flowers tab x in crop:", xs[6] - X0, "..", xs[6] + W - X0)
