"""Load and first-click performance of the Web export, in headless Chrome over CDP with the network
throttled. Writes OUT/report.json and prints a summary.

usage: perf_web.py URL OUT [--mbit 40] [--gpu] [--size 1920x1080] [--dpr 1]

  --mbit N   download bandwidth (default 40; 0 = unthrottled). The cache is disabled: a cold load.
  --dpr N    device pixel ratio (2 = a retina Mac: twice the pixels to render)
  --gpu      WebGL on the NVIDIA card under WSL (ANGLE gl-egl -> Mesa d3d12); default is SwiftShader,
             which is much slower than any real browser and so a worst case.

What it measures:
  stages   the marks web/loading_shell.html and modules/shell/boot_loader.gd push to window.loadPerf
  bar      the loading bar's value over time (window.loaderProgress, sampled ten times a second)
  freezes  every page main-thread stall over 50 ms during the load (requestAnimationFrame gaps);
           the loading animation runs in a Web Worker so it should not stop during them
  loader   the loading animation's own stalls over 50 ms, reported by its worker (window.loaderGaps):
           what the viewer sees as the dots stopping
  tabs     for each fixed tab's first click: the longest stall in the 3 s after it, and how long
           until the Shell reports that tab active with its cross-fade settled (?qa-crt state)
"""
import asyncio, json, os, subprocess, sys, time, urllib.request
from pathlib import Path
import websockets

args = sys.argv[1:]
url, out = args[0], args[1]
opt = lambda name, default: args[args.index(name) + 1] if name in args else default
MBIT = float(opt("--mbit", 40)); GPU = "--gpu" in args
W, H = (int(v) for v in opt("--size", "1920x1080").split("x")); DPR = float(opt("--dpr", 1))
os.makedirs(out, exist_ok=True)

# The strip's tab rects from the accepted native playtest, re-based on this window (as browser_play.py does).
EV = Path(__file__).resolve().parents[3] / "docs/evidence"
launch = next(e for e in json.loads((EV / "shell/report.json").read_text())["log"] if e["event"] == "state" and e.get("label") == "launch")
S = W / 1920.0; BAR_H = 161 * W / 4180.0; PAGE_H = H - BAR_H; BAR_TOP_LOG = 1080 - 161 * 1920 / 4180.0
def tab(i):
    r = launch["tabs"][i]["rect"]
    return r["x"] * S + r["w"] * S / 2, PAGE_H + (r["y"] - BAR_TOP_LOG) * S + r["h"] * S / 2
TAB_NAMES = [t["key"] for t in launch["tabs"][:6]]

env = dict(os.environ)
flags = ["--use-angle=swiftshader", "--enable-unsafe-swiftshader"]
if GPU:
    env.update(GALLIUM_DRIVER="d3d12", MESA_D3D12_DEFAULT_ADAPTER_NAME="NVIDIA",
               LD_LIBRARY_PATH="/usr/lib/wsl/lib:" + env.get("LD_LIBRARY_PATH", ""))
    flags = ["--use-gl=angle", "--use-angle=gl-egl", "--ignore-gpu-blocklist"]
PORT = 9344
chrome = subprocess.Popen(["google-chrome", "--headless=new", "--no-sandbox", *flags, "--disable-gpu-sandbox",
    "--autoplay-policy=no-user-gesture-required", f"--remote-debugging-port={PORT}", f"--window-size={W},{H}",
    f"--user-data-dir={os.path.join(out, 'profile')}", "about:blank"], env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
time.sleep(2.5)
ws_url = next(t["webSocketDebuggerUrl"] for t in json.load(urllib.request.urlopen(f"http://127.0.0.1:{PORT}/json")) if t["type"] == "page")

MONITOR = """
window.__gaps = []; window.__bar = [];
(function frame(last) { requestAnimationFrame(function (t) {
    if (last && t - last > 50) window.__gaps.push([Math.round(last), Math.round(t - last)]);
    frame(t); }); })(0);
setInterval(function () { if (window.loaderProgress !== undefined) window.__bar.push([Math.round(performance.now()), +window.loaderProgress.toFixed(3)]); }, 100);
"""


async def main():
    async with websockets.connect(ws_url, max_size=50_000_000) as ws:
        n = [0]
        async def send(method, **params):
            n[0] += 1; await ws.send(json.dumps({"id": n[0], "method": method, "params": params}))
            while True:
                m = json.loads(await ws.recv())
                if m.get("id") == n[0]: return m.get("result", m)
        async def js(expr):
            r = await send("Runtime.evaluate", expression=expr, returnByValue=True)
            return r.get("result", {}).get("value")
        await send("Page.enable"); await send("Runtime.enable"); await send("Network.enable")
        await send("Network.setCacheDisabled", cacheDisabled=True)
        if MBIT > 0:
            await send("Network.emulateNetworkConditions", offline=False, latency=20,
                       downloadThroughput=MBIT * 1e6 / 8, uploadThroughput=1e6)
        await send("Emulation.setDeviceMetricsOverride", width=W, height=H, deviceScaleFactor=DPR, mobile=False)
        await send("Page.addScriptToEvaluateOnNewDocument", source=MONITOR)
        sep = "&" if "?" in url else "?"
        await send("Page.navigate", url=url + sep + "crt=0&qa-crt")
        t0 = time.time()
        while time.time() - t0 < 180:  # until the loading screen has freed itself
            await asyncio.sleep(0.5)
            marks = await js("JSON.stringify(window.loadPerf || [])")
            if marks and '"game-shown"' in marks:
                break
        await asyncio.sleep(1.0)
        report = {"url": url, "mbit": MBIT, "gpu": GPU, "size": [W, H], "dpr": DPR,
                  "webgl": await js("(function(){const g=document.createElement('canvas').getContext('webgl');const e=g&&g.getExtension('WEBGL_debug_renderer_info');return e?g.getParameter(e.UNMASKED_RENDERER_WEBGL):'?'})()"),
                  "stages": json.loads(await js("JSON.stringify(window.loadPerf || [])") or "[]"),
                  "bar": json.loads(await js("JSON.stringify(window.__bar)") or "[]"),
                  "freezes": json.loads(await js("JSON.stringify(window.__gaps)") or "[]"),
                  "loader_stalls_ms": json.loads(await js("JSON.stringify(window.loaderGaps || [])") or "[]"),
                  "tabs": []}
        await asyncio.sleep(2.0)
        for i in list(range(6)):
            if i == 4:
                continue  # Collection is the launch tab: already shown
            x, y = tab(i)
            start = await js("performance.now()")
            for kind in ("mousePressed", "mouseReleased"):
                await send("Input.dispatchMouseEvent", type=kind, x=x, y=y, button="left", clickCount=1)
            settled = None
            for _ in range(60):
                await asyncio.sleep(0.1)
                s = await js("JSON.stringify(window.shellCrtQa && window.shellCrtQa.shell)")
                s = json.loads(s) if s else {}
                if s.get("active") == i and not s.get("switching"):
                    settled = round(await js("performance.now()") - start); break
            await asyncio.sleep(max(0.0, 3.0 - (await js("performance.now()") - start) / 1000))
            gaps = [g for g in json.loads(await js("JSON.stringify(window.__gaps)")) if g[0] >= start - 20]
            report["tabs"].append({"tab": TAB_NAMES[i], "settled_ms": settled, "longest_freeze_ms": max([g[1] for g in gaps], default=0)})
        return report

report = asyncio.run(main())
chrome.terminate()
Path(out, "report.json").write_text(json.dumps(report, indent=1))

# summary
print(f"{report['url']}  {report['mbit']:g} Mbit/s  {'GPU' if report['gpu'] else 'SwiftShader'}  {report['webgl']}")
print("stages (s from page start):")
for m in report["stages"]:
    print(f"  {m['t'] / 1000:7.2f}  {m['name']}")
shown = next((m["t"] for m in report["stages"] if m["name"] == "game-shown"), None)
long = [f for f in report["freezes"] if shown is None or f[0] <= shown]
print(f"freezes over 50 ms before the game showed: {len(long)}; longest {max([f[1] for f in long], default=0)} ms at "
      f"{next((f[0] / 1000 for f in long if f[1] == max([g[1] for g in long], default=0)), 0):.2f} s")
for f in sorted(long, key=lambda f: -f[1])[:6]:
    print(f"  {f[0] / 1000:7.2f} s  {f[1]} ms")
ls = report["loader_stalls_ms"]
print(f"loading animation stalls over 50 ms (worker): {len(ls)}; longest {max(ls, default=0)} ms")
bar = report["bar"]; stalls = []
for (ta, va), (tb, vb) in zip(bar, bar[1:]):
    if vb <= va and va < 0.999:
        if stalls and stalls[-1][1] == ta: stalls[-1][1] = tb
        else: stalls.append([ta, tb])
stalls = [s for s in stalls if s[1] - s[0] >= 1000]
print(f"bar standing still for 1 s or more (before full): {[(round(a / 1000, 1), round((b - a) / 1000, 1)) for a, b in stalls]}")
print("first click per tab:")
for t in report["tabs"]:
    print(f"  {t['tab']:<14} settled {t['settled_ms']} ms   longest freeze {t['longest_freeze_ms']} ms")
