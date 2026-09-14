"""Drive the Web export of the shell in headless Chrome over CDP with real mouse events; save screenshots.
usage: browser_play.py URL OUTDIR [width height]"""
import asyncio, base64, json, subprocess, sys, time, urllib.request, os
import websockets
url, out = sys.argv[1], sys.argv[2]; W, H = (int(sys.argv[3]), int(sys.argv[4])) if len(sys.argv) > 4 else (1920, 1080)
os.makedirs(out, exist_ok=True)
chrome = subprocess.Popen(["google-chrome", "--headless=new", "--no-sandbox", "--use-angle=swiftshader", "--enable-unsafe-swiftshader",
    "--ignore-gpu-blocklist", "--disable-gpu-sandbox", "--remote-debugging-port=9333", f"--window-size={W},{H}", "--hide-scrollbars", "about:blank"],
    stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
time.sleep(2.5)
targets = json.load(urllib.request.urlopen("http://127.0.0.1:9333/json"))
ws_url = next(t["webSocketDebuggerUrl"] for t in targets if t["type"] == "page")

# the shell's geometry, from layout.json and tab_strip.gd's _fitted_width: the 4180 px bar fitted to the window
S = W / 4180.0
MAX_RIGHT = 4180 - 1920 + 456 - 40; ROOM = MAX_RIGHT - 261 - 180 + 60; OVERLAP = 640 - 573  # gap_from_tab_right is -60, so the stub overlaps the last tab
def tab_w(n): return round(min(640, (ROOM + OVERLAP * (n - 1)) / n))
def tab_x(i, n): return 261 + i * (tab_w(n) - OVERLAP)
def tab_center(i, n): return S * (tab_x(i, n) + tab_w(n) / 2), S * (33 + 123 / 2)
def stub_center(n): return S * (tab_x(n - 1, n) + tab_w(n) - 60 + 90), S * (49 + 107 / 2)
def close_center(i, n): return S * (tab_x(i, n) + tab_w(n) - 80 - 11), S * (33 + 24 + 22 + 11)  # tab y + label y + close offset

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
        await send("Page.enable"); await send("Runtime.enable")
        await send("Emulation.setDeviceMetricsOverride", width=W, height=H, deviceScaleFactor=1, mobile=False)
        await send("Page.navigate", url=url); await asyncio.sleep(12)
        r = await send("Runtime.evaluate", expression="document.title + ' | canvas ' + (document.querySelector('canvas')?.width) + 'x' + (document.querySelector('canvas')?.height)"); print(r.get("result", {}).get("value"))
        await shot("w01-launch.png")                         # six fixed tabs, Collection active
        await click(*tab_center(0, 6)); await asyncio.sleep(0.5); await shot("w02-map.png")
        await click(*tab_center(1, 6)); await asyncio.sleep(0.5); await shot("w03-sketchbook.png")
        await click(*close_center(1, 6)); await asyncio.sleep(1.0); await shot("w04-fixed-close-refused.png")  # nothing happens
        await click(*stub_center(6))                          # the stub opens a Blank Page as the seventh tab
        for i in range(6):
            await asyncio.sleep(0.08); await shot(f"w05-grow-{i}.png")
        await asyncio.sleep(1.5); await shot("w06-blank-page.png")
        await click(*close_center(6, 7))                      # its close button works; Phone becomes active
        for i in range(6):
            await asyncio.sleep(0.08); await shot(f"w07-close-{i}.png")
        await asyncio.sleep(1.0); await shot("w08-after-close.png")
asyncio.run(main()); chrome.terminate()
