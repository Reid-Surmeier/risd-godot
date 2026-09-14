"""Drive the Web export of the game (the Shell with the real Tenants) in headless Chrome over CDP with real
mouse events; save screenshots and a toolbar sheet. The click targets are the rects the native playtests
logged at 1920x1080 (docs/evidence/shell/report.json): the bar scales with the window width, so the
targets hold at any window size.
usage: browser_play.py URL OUTDIR [width height]"""
import asyncio, base64, json, subprocess, sys, time, urllib.request, os
from pathlib import Path
import websockets
from PIL import Image, ImageDraw
url, out = sys.argv[1], sys.argv[2]; W, H = (int(sys.argv[3]), int(sys.argv[4])) if len(sys.argv) > 4 else (1920, 1080)
os.makedirs(out, exist_ok=True)
EV = Path(__file__).resolve().parents[3] / "docs/evidence"
shell_log = json.loads((EV / "shell/report.json").read_text())["log"]
S = W / 1920.0; BAR_H = 161 * W / 4180.0
launch = next(e for e in shell_log if e["event"] == "state" and e["label"] == "launch")
blank = next(e for e in shell_log if e["event"] == "state" and e["label"] == "stub-blank")
def mid(r, sx=S, sy=S, dy=0.0): return r["x"] * sx + r["w"] * sx / 2, dy + r["y"] * sy + r["h"] * sy / 2
def tab(i): return mid(launch["tabs"][i]["rect"])
STUB = mid(launch["stub_rect"]); BLANK_CLOSE = mid(blank["tabs"][6]["close_rect"])
PAGE_CENTRE = (W / 2, BAR_H + (H - BAR_H) / 2)  # inside the atlas window, which fits the page

chrome = subprocess.Popen(["google-chrome", "--headless=new", "--no-sandbox", "--use-angle=swiftshader", "--enable-unsafe-swiftshader",
    "--ignore-gpu-blocklist", "--disable-gpu-sandbox", "--remote-debugging-port=9333", f"--window-size={W},{H}", "--hide-scrollbars", "about:blank"],
    stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
time.sleep(2.5)
targets = json.load(urllib.request.urlopen("http://127.0.0.1:9333/json"))
ws_url = next(t["webSocketDebuggerUrl"] for t in targets if t["type"] == "page")
shots = []

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
        async def wheel_up(x, y, n):
            await send("Input.dispatchMouseEvent", type="mouseMoved", x=x, y=y); await asyncio.sleep(0.2)  # Godot Web reads the wheel at the last mousemove
            for _ in range(n):
                await send("Input.dispatchMouseEvent", type="mouseWheel", x=x, y=y, deltaX=0, deltaY=-120); await asyncio.sleep(0.1)
            await asyncio.sleep(0.5)
        await send("Page.enable"); await send("Runtime.enable")
        await send("Emulation.setDeviceMetricsOverride", width=W, height=H, deviceScaleFactor=1, mobile=False)
        await send("Page.navigate", url=url); await asyncio.sleep(15)
        r = await send("Runtime.evaluate", expression="document.title + ' | canvas ' + (document.querySelector('canvas')?.width) + 'x' + (document.querySelector('canvas')?.height)"); print(r.get("result", {}).get("value"))
        await shot("w01-launch.png")                                    # Collection active, the Image Viewer desktop
        await click(*tab(0), 1.5); await shot("w02-map.png")            # the Map tab: the atlas window on its page
        await wheel_up(*PAGE_CENTRE, 3); await shot("w03-map-zoomed.png")   # wheel up x3 at the page centre: zoom in
        await click(*tab(4)); await shot("w04-collection.png")          # back on Collection, the Map frozen behind
        await click(*STUB, 0.0)                                         # the stub opens a Blank Page as the seventh tab
        for i in range(6):
            await asyncio.sleep(0.08); await shot(f"w05-grow-{i}.png")
        await asyncio.sleep(1.5); await shot("w06-blank-page.png")
        await click(*BLANK_CLOSE, 1.5); await shot("w07-after-close.png")   # its close works; Phone becomes active
asyncio.run(main()); chrome.terminate()

# the toolbar sheet: the bar band of every settled screenshot, stacked, labelled
band = int(BAR_H) + 8
rows = [n for n in shots if "grow" not in n]
sheet = Image.new("RGB", (W, (band + 18) * len(rows)), "white"); d = ImageDraw.Draw(sheet)
for i, n in enumerate(rows):
    y = i * (band + 18); d.text((4, y + 2), n, fill="black")
    sheet.paste(Image.open(os.path.join(out, n)).crop((0, 0, W, band)), (0, y + 16))
sheet.save(os.path.join(out, "sheet-bar.png")); print("sheet", os.path.join(out, "sheet-bar.png"))
