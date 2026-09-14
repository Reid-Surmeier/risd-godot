"""Drive the Web export of the game (the Shell with the Collection page as its launch Tenant) in headless
Chrome over CDP with real mouse events; save screenshots. The click targets are the control and tab rects
the native playtest logged (docs/evidence/collection-page/report.json, 1920x1080), which the browser
renders at the same pixels: the Shell lays out from the window, not the host.
usage: browser_play.py URL OUTDIR [width height]"""
import asyncio, base64, json, subprocess, sys, time, urllib.request, os
from pathlib import Path
import websockets
url, out = sys.argv[1], sys.argv[2]; W, H = (int(sys.argv[3]), int(sys.argv[4])) if len(sys.argv) > 4 else (1920, 1080)
os.makedirs(out, exist_ok=True)
log = json.loads((Path(__file__).resolve().parents[3] / "docs/evidence/collection-page/report.json").read_text())["log"]
page = next(e for e in log if e["event"] == "page" and e["label"] == "launch")
shell = next(e for e in log if e["event"] == "shell" and e["label"] == "launch")
def control(name): r = page["controls"][name]; return r["x"] + r["w"] / 2, r["y"] + r["h"] / 2  # the page starts at row 0 (bar at the bottom)
def tab(i): r = shell["tabs"][i]["rect"]; return r["x"] + r["w"] / 2, r["y"] + r["h"] / 2
def card(i): r = page["cards"][i]["rect"]; return r["x"] + r["w"] / 2, r["y"] + r["h"] / 2

chrome = subprocess.Popen(["google-chrome", "--headless=new", "--no-sandbox", "--use-angle=swiftshader", "--enable-unsafe-swiftshader",
    "--ignore-gpu-blocklist", "--disable-gpu-sandbox", "--remote-debugging-port=9333", f"--window-size={W},{H}", "--hide-scrollbars", "about:blank"],
    stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
time.sleep(2.5)
targets = json.load(urllib.request.urlopen("http://127.0.0.1:9333/json"))
ws_url = next(t["webSocketDebuggerUrl"] for t in targets if t["type"] == "page")

async def main():
    async with websockets.connect(ws_url, max_size=50_000_000) as ws:
        mid = [0]
        async def send(method, **params):
            mid[0] += 1; await ws.send(json.dumps({"id": mid[0], "method": method, "params": params}))
            while True:
                m = json.loads(await ws.recv())
                if m.get("id") == mid[0]: return m.get("result", m)
        async def shot(name):
            r = await send("Page.captureScreenshot", format="png")
            open(os.path.join(out, name), "wb").write(base64.b64decode(r["data"])); print("shot", name)
        async def click(x, y):
            for t in ("mousePressed", "mouseReleased"):
                await send("Input.dispatchMouseEvent", type=t, x=x, y=y, button="left", clickCount=1)
            await asyncio.sleep(0.5)
        await send("Page.enable"); await send("Runtime.enable")
        await send("Emulation.setDeviceMetricsOverride", width=W, height=H, deviceScaleFactor=1, mobile=False)
        await send("Page.navigate", url=url); await asyncio.sleep(15)
        r = await send("Runtime.evaluate", expression="document.title + ' | canvas ' + (document.querySelector('canvas')?.width) + 'x' + (document.querySelector('canvas')?.height)"); print(r.get("result", {}).get("value"))
        await shot("w01-launch.png")                                   # Collection active: sixteen cards, filter open
        await click(*control("has_image")); await shot("w02-has-image.png")   # ten cards with a photograph
        await click(*control("medium")); await shot("w03-medium-first.png")   # Medium: Bronze, with image
        await click(*control("has_image")); await click(*control("sort")); await shot("w04-bronze-newest.png")
        await click(*card(0)); await shot("w05-after-card.png")        # the click emits card_selected and changes nothing
        await click(*tab(0)); await asyncio.sleep(1.0); await shot("w06-map.png")   # the Map tab: the atlas, Collection frozen
        await click(*tab(4)); await shot("w07-collection-again.png")   # back: the same filter, the same cards
asyncio.run(main()); chrome.terminate()
