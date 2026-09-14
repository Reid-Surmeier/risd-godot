"""Drive the Web export of the game (the Shell with every Tenant) in headless Chrome over CDP with real
mouse events; save screenshots, a toolbar sheet and a per-tab sheet. The click targets are the rects the
native playtests logged at 1920x1080 (docs/evidence/*/report.json): the bar sits along the bottom and
scales with the window width; each desktop re-fits to the page by its own rule (the same rule its
verifier checks), so the targets hold at any window size.
usage: browser_play.py URL OUTDIR [width height]"""
import asyncio, base64, json, subprocess, sys, time, urllib.request, os
from pathlib import Path
import websockets
from PIL import Image, ImageDraw
url, out = sys.argv[1], sys.argv[2]; W, H = (int(sys.argv[3]), int(sys.argv[4])) if len(sys.argv) > 4 else (1920, 1080)
os.makedirs(out, exist_ok=True)
EV = Path(__file__).resolve().parents[3] / "docs/evidence"
def entry(d, ev, label):
    return next(e for e in json.loads((EV / d / "report.json").read_text())["log"] if e["event"] == ev and e.get("label") == label)
S = W / 1920.0; BAR_H = 161 * W / 4180.0; PAGE_H = H - BAR_H; BAR_TOP_LOG = 1080 - 161 * 1920 / 4180.0; PAGE_H_LOG = BAR_TOP_LOG
launch = entry("shell", "state", "launch"); blank = entry("shell", "state", "stub-blank")
def bar(r): return r["x"] * S + r["w"] * S / 2, PAGE_H + (r["y"] - BAR_TOP_LOG) * S + r["h"] * S / 2  # a strip rect, re-based on this window's bar
def mid(r): return r["x"] + r["w"] / 2, r["y"] + r["h"] / 2
def tab(i): return bar(launch["tabs"][i]["rect"])
STUB = bar(launch["stub_rect"]); BLANK_CLOSE = bar(blank["tabs"][7]["close_rect"])

# the Map desktop (atlas_window.gd): the 1950x1280 prototype desktop scaled to fit the page and centred; the map body's rect scales with it
a = entry("atlas", "atlas", "map-shown"); mr = a["map_rect"]
def atlas_fit(w, h): s = min(w / 1950.0, h / 1280.0); return s, (w - 1950 * s) / 2, (h - 1280 * s) / 2
s1, ox1, oy1 = atlas_fit(1920, PAGE_H_LOG); s2, ox2, oy2 = atlas_fit(W, PAGE_H)
MAP_CENTRE = (ox2 + (mr["x"] + mr["w"] / 2 - ox1) / s1 * s2, oy2 + (mr["y"] + mr["h"] / 2 - oy1) / s1 * s2)
# the Collection desktop (desktop.gd): the 1944x1280 reference scaled by min(w/1944, h/1280) from the page's top-left
c = entry("collection-page", "page", "launch"); eq = next(w for w in c["windows"] if w["name"] == "equipment")["rect"]
cf = min(W / 1944.0, PAGE_H / 1280.0) / min(1920 / 1944.0, PAGE_H_LOG / 1280.0)
EQUIP_TITLE = (eq["x"] * cf + min(100.0, eq["w"] * cf / 2), eq["y"] * cf + 12.0)
# the Video Player (video_player.gd): the 1536x1632 canvas fitted with a 24 px margin and centred; tile 3 at its canvas offset
v = entry("video-player", "player", "shown"); vr = v["viewer"]["rect"]; t3 = v["tiles"][2]["rect"]
vs1 = v["viewer"]["scale"]; vs2 = min(1.0, (W - 48) / 1536.0, (PAGE_H - 48) / 1632.0)
vx2, vy2 = (W - 1536 * vs2) / 2, (PAGE_H - 1632 * vs2) / 2
TILE3 = (vx2 + (t3["x"] + t3["w"] / 2 - vr["x"]) / vs1 * vs2, vy2 + (t3["y"] + t3["h"] / 2 - vr["y"]) / vs1 * vs2)
# the Sketchbook and 3D Viewer desktops (desktop.gd): 1440x972 kept 1:1 and centred, shrunk to fit a smaller page
def desk_fit(w, h): s = min(1.0, w / 1440.0, h / 972.0); return s, (w - 1440 * s) / 2, (h - 972 * s) / 2
d1 = desk_fit(1920, PAGE_H_LOG); d2 = desk_fit(W, PAGE_H)
def desk(pt): return d2[1] + (pt[0] - d1[1]) / d1[0] * d2[0], d2[2] + (pt[1] - d1[2]) / d1[0] * d2[0]
b = entry("sketchbook", "book", "book-shown")["page_rect"]; PAPER = desk((b["x"] + b["w"] * 0.25, b["y"] + b["h"] * 0.5))
o = entry("sculpture-viewer", "viewer", "viewer-shown")["viewport_rect"]; ORBIT = desk(mid(o))

chrome = subprocess.Popen(["google-chrome", "--headless=new", "--no-sandbox", "--use-angle=swiftshader", "--enable-unsafe-swiftshader",
    "--ignore-gpu-blocklist", "--disable-gpu-sandbox", "--autoplay-policy=no-user-gesture-required", "--remote-debugging-port=9333",
    f"--window-size={W},{H}", "--hide-scrollbars", "about:blank"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
time.sleep(2.5)
targets = json.load(urllib.request.urlopen("http://127.0.0.1:9333/json"))
ws_url = next(t["webSocketDebuggerUrl"] for t in targets if t["type"] == "page")
shots = []; TABS = []  # (tab title, the screenshot that shows it settled)

async def main():
    async with websockets.connect(ws_url, max_size=50_000_000) as ws:
        mid_ = [0]
        async def send(method, **params):
            mid_[0] += 1; await ws.send(json.dumps({"id": mid_[0], "method": method, "params": params}))
            while True:
                m = json.loads(await ws.recv())
                if m.get("id") == mid_[0]: return m.get("result", m)
        async def shot(name):
            r = await send("Page.captureScreenshot", format="png")
            open(os.path.join(out, name), "wb").write(base64.b64decode(r["data"])); shots.append(name); print("shot", name)
        async def click(x, y, settle=0.5):
            for t in ("mousePressed", "mouseReleased"):
                await send("Input.dispatchMouseEvent", type=t, x=x, y=y, button="left", clickCount=1)
            await asyncio.sleep(settle)
        async def drag(x, y, dx, dy, steps=8, settle=0.5):
            await send("Input.dispatchMouseEvent", type="mouseMoved", x=x, y=y); await asyncio.sleep(0.1)
            await send("Input.dispatchMouseEvent", type="mousePressed", x=x, y=y, button="left", clickCount=1, buttons=1)
            for i in range(1, steps + 1):
                await send("Input.dispatchMouseEvent", type="mouseMoved", x=x + dx * i / steps, y=y + dy * i / steps, button="left", buttons=1); await asyncio.sleep(0.05)
            await send("Input.dispatchMouseEvent", type="mouseReleased", x=x + dx, y=y + dy, button="left", clickCount=1)
            await asyncio.sleep(settle)
        async def wheel_up(x, y, n):
            await send("Input.dispatchMouseEvent", type="mouseMoved", x=x, y=y); await asyncio.sleep(0.2)  # Godot Web reads the wheel at the last mousemove
            for _ in range(n):
                await send("Input.dispatchMouseEvent", type="mouseWheel", x=x, y=y, deltaX=0, deltaY=-120); await asyncio.sleep(0.1)
            await asyncio.sleep(0.5)
        async def open_tab(i, name, title, settle=2.0):
            await click(*tab(i), settle); await shot(name); TABS.append((title, name))
        await send("Page.enable"); await send("Runtime.enable")
        await send("Emulation.setDeviceMetricsOverride", width=W, height=H, deviceScaleFactor=1, mobile=False)
        await send("Page.navigate", url=url); await asyncio.sleep(20)
        r = await send("Runtime.evaluate", expression="document.title + ' | canvas ' + (document.querySelector('canvas')?.width) + 'x' + (document.querySelector('canvas')?.height)"); print(r.get("result", {}).get("value"))
        await shot("w01-launch.png"); TABS.append(("Collection (launch)", "w01-launch.png"))   # Collection active: the Image Viewer desktop
        await click(*tab(0), 0.0)                                       # the Map tab: the dip and the cross-fade, then the atlas desktop
        for i in range(4):
            await asyncio.sleep(0.06); await shot(f"w02-switch-{i}.png")
        await asyncio.sleep(2.0); await shot("w02-map.png"); TABS.append(("Map", "w02-map.png"))
        await wheel_up(*MAP_CENTRE, 3); await shot("w03-map-zoomed.png")   # wheel up x3 at the map body's centre: zoom in
        await open_tab(1, "w04-sketchbook.png", "Sketchbook")            # the sketchbook desktop
        await drag(*PAPER, 90, 40, 12); await shot("w05-sketchbook-drawn.png")   # a stroke across the left page
        await open_tab(2, "w06-3d-viewer.png", "3D Viewer")              # the sculpture desktop, the orbit running
        await drag(*ORBIT, -120, 40, 10); await shot("w07-3d-viewer-orbited.png")  # drag-orbit inside the viewport
        await open_tab(3, "w08-video.png", "Video Player", 3.0)          # the Fly Through player, the first video playing
        await click(*TILE3, 3.0); await shot("w09-video-tile-3.png")     # tile 3: its video loads and plays
        await open_tab(4, "w10-collection.png", "Collection")            # back on Collection, every other page frozen behind
        await drag(*EQUIP_TITLE, 160, 120, 10); await shot("w11-collection-dragged.png")  # drag the equipment window by its title
        await open_tab(5, "w12-playground.png", "Playground")            # the Playground mockup
        await open_tab(6, "w13-phone.png", "Phone")                      # the Phone mockup
        await click(*STUB, 0.0)                                         # the stub opens a Blank Page as the eighth tab
        for i in range(6):
            await asyncio.sleep(0.08); await shot(f"w14-grow-{i}.png")
        await asyncio.sleep(1.5); await shot("w15-blank-page.png"); TABS.append(("Blank Page", "w15-blank-page.png"))
        await click(*BLANK_CLOSE, 1.5); await shot("w16-after-close.png")   # its close works; Phone becomes active
asyncio.run(main()); chrome.terminate()

# the toolbar sheet: the bar band (the bottom of the window) of every settled screenshot, stacked, labelled
band = int(BAR_H) + 8
rows = [n for n in shots if "grow" not in n and "switch" not in n]
sheet = Image.new("RGB", (W, (band + 18) * len(rows)), "white"); d = ImageDraw.Draw(sheet)
for i, n in enumerate(rows):
    y = i * (band + 18); d.text((4, y + 2), n, fill="black")
    sheet.paste(Image.open(os.path.join(out, n)).crop((0, H - band, W, H)), (0, y + 16))
sheet.save(os.path.join(out, "sheet-bar.png")); print("sheet", os.path.join(out, "sheet-bar.png"))
# the per-tab sheet: one settled screenshot per tab, at a third, labelled
tw, th = W // 3, H // 3; cols = 3; rows_n = -(-len(TABS) // cols)
sheet = Image.new("RGB", (cols * (tw + 8), rows_n * (th + 24)), "white"); d = ImageDraw.Draw(sheet)
for i, (title, n) in enumerate(TABS):
    x, y = (i % cols) * (tw + 8), (i // cols) * (th + 24); d.text((x + 4, y + 4), f"{title} — {n}", fill="black")
    sheet.paste(Image.open(os.path.join(out, n)).resize((tw, th), Image.LANCZOS), (x, y + 20))
sheet.save(os.path.join(out, "sheet-tabs.png")); print("sheet", os.path.join(out, "sheet-tabs.png"))
