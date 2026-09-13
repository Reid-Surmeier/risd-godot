"""Drive the web build in headless Chrome over CDP with real mouse events; save screenshots.
usage: cdp_play.py URL OUTDIR [width height]"""
import asyncio, base64, json, subprocess, sys, time, urllib.request, os, signal
import websockets
url, out = sys.argv[1], sys.argv[2]; W, H = (int(sys.argv[3]), int(sys.argv[4])) if len(sys.argv) > 4 else (1440, 400)
os.makedirs(out, exist_ok=True)
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
        await send("Page.enable"); await send("Runtime.enable")
        await send("Emulation.setDeviceMetricsOverride", width=W, height=H, deviceScaleFactor=1, mobile=False)
        await send("Page.navigate", url=url); await asyncio.sleep(12)
        r = await send("Runtime.evaluate", expression="document.title + ' | canvas ' + (document.querySelector('canvas')?.width) + 'x' + (document.querySelector('canvas')?.height)"); print(r.get("result", {}).get("value"))
        await shot("w01-initial.png")
        # the stub sits right of the first tab: at scale 0.55 the stub spans x 0.55*(261+680-60)=485..584, y 27..86
        S = W / 3135.0                      # demo fits the 3135 px bar to the window
        sx, sy = S * (261 + 640 - 60 + 90), S * (49 + 50)
        await click(sx, sy)
        for i in range(6):
            await asyncio.sleep(0.08); await shot(f"w02-grow-{i}.png")
        await asyncio.sleep(1.5); await shot("w03-settled.png")
        await click(sx + S * 573, sy)   # the stub moved one pitch right
        await asyncio.sleep(2.0); await shot("w04-three.png")
        await click(S * (261 + 640 - 90 - 22 + 11), S * (33 + 24 + 33))   # close button of tab 0
        for i in range(6):
            await asyncio.sleep(0.08); await shot(f"w05-close-{i}.png")
        await asyncio.sleep(1.0); await shot("w06-after-close.png")
asyncio.run(main()); chrome.terminate()
