"""Play the Flowers Tab in the Web export in headless Chromium with real mouse input, and check it.
Opens the build with ?qa-crt=1 (crt_display.gd publishes the Shell's state and the active Tenant's),
clicks the Flowers tab on the bar, waits for the Ruffle player to load the game, then plays the
site's flow: title -> Start New -> instructions -> Next -> the garden and the vase; picks a flower;
moves the mouse; leaves the tab (the player hides) and comes back (the game is where it was); then
the steps that needed the site's PHP, answered by the page's stand-in: sends the bouquet (form,
preview, submit -> a flower number), enters that number (the card comes back), views a sample.
Screenshots and report.json go to OUTDIR. Exit 1 when a check fails.
usage: uv run --with playwright --with pillow python browser_play.py BUILD_URL OUTDIR   (BUILD_URL: the folder with index.html)
With GALLIUM_DRIVER set (source ~/promo-lab/gpu-env.sh) Chromium renders on the GPU through ANGLE; otherwise
SwiftShader, which composites a spurious black band under the player once the game leaves its title
screen (not seen on the GPU path)."""
import asyncio, json, os, re, sys, urllib.request
from pathlib import Path
from playwright.async_api import async_playwright
from PIL import Image, ImageChops, ImageStat

base, out = sys.argv[1].rstrip("/") + "/", Path(sys.argv[2])
out.mkdir(parents=True, exist_ok=True)
sha = re.search(r"url=([^\"]+)\.html", urllib.request.urlopen(base + "index.html").read().decode()).group(1)
GAME = (750, 422)
checks, log = [], []


def check(name, ok, detail=""):
    checks.append({"name": name, "ok": bool(ok), "detail": str(detail)}); print("PASS" if ok else "FAIL", name, detail)


def region(path, r):  # a page-px rect of a screenshot
    return Image.open(path).convert("RGB").crop(tuple(int(v) for v in (r["x"], r["y"], r["x"] + r["w"], r["y"] + r["h"])))


def changed(a, b):  # mean abs difference, 0..255
    return sum(ImageStat.Stat(ImageChops.difference(a, b)).mean) / 3


TO_PAGE = """([x, y]) => {  // logical px -> page px, through the CRT warp's inverse (as flowers_embed.gd)
  const box = document.getElementById('canvas').getBoundingClientRect(), crt = window.crtQaState;
  const [vw, vh] = window.shellCrtQa.logical_size;
  const warp = (x, y) => { if (!crt || !crt.enabled) return [x, y]; const a = vh / vw;
    const u = (x - 0.5) / crt.screen_scale / a, v = (y - 0.5) / crt.screen_scale, k = 1 - (u * u + v * v - 0.25) * crt.curve;
    return [u / k * a + 0.5, v / k + 0.5]; };
  const t = [x / vw, y / vh], d = [t[0], t[1]];
  for (let i = 0; i < 8; i++) { const s = warp(d[0], d[1]); d[0] += t[0] - s[0]; d[1] += t[1] - s[1]; }
  return [box.left + d[0] * box.width, box.top + d[1] * box.height]; }"""


async def main():
    async with async_playwright() as p:
        gl = ["--use-gl=angle", "--use-angle=gl-egl"] if os.environ.get("GALLIUM_DRIVER") else ["--enable-unsafe-swiftshader"]
        browser = await p.chromium.launch(args=gl + ["--ignore-gpu-blocklist", "--autoplay-policy=no-user-gesture-required"])
        page = await browser.new_page(viewport={"width": 1920, "height": 1080})
        page.on("console", lambda m: m.type == "error" and log.append(m.text[:300]))
        failed = []
        page.on("response", lambda r: r.status >= 400 and failed.append(f"{r.status} {r.url}"))
        await page.goto(f"{base}{sha}.html?qa-crt=1", wait_until="load")
        await page.wait_for_function("(window.loadPerf || []).some((e) => e.name === 'game-shown')", timeout=300000)  # the loading screen is gone
        await page.wait_for_function("window.shellCrtQa && window.shellCrtQa.shell.active === 4 && !window.shellCrtQa.shell.switching", timeout=30000)
        await page.wait_for_timeout(1000)
        await page.screenshot(path=out / "01-launch.png")
        qa = await page.evaluate("window.shellCrtQa")
        keys = [t["key"] for t in qa["shell"]["tabs"]]
        check("flowers_is_the_seventh_fixed_tab_after_playground", keys[:7] == ["map", "sketchbook", "3d_viewer", "video_player", "collection", "playground", "flowers"], keys)
        check("collection_is_still_the_launch_tab", qa["shell"]["active"] == 4)
        r = qa["shell"]["tabs"][6]["rect"]
        tab_xy = await page.evaluate(TO_PAGE, [r[0] + r[2] * 0.5, r[1] + r[3] * 0.5])
        await page.mouse.click(*tab_xy)
        await page.wait_for_function("window.shellCrtQa.shell.active === 6 && window.shellCrtQa.tenant.placement !== 'null'", timeout=20000)
        await page.wait_for_function("(() => { const p = document.querySelector('#flowers-game ruffle-player'); return p && p.metadata; })()", timeout=120000)
        await page.wait_for_timeout(4000)  # the loader SWF reads hstflowers.txt, then loads flowersmain.swf
        await page.screenshot(path=out / "02-flowers-title.png")
        frame = await page.evaluate("(() => { const r = document.getElementById('flowers-game').getBoundingClientRect(); return {x: r.x, y: r.y, w: r.width, h: r.height}; })()")
        meta = await page.evaluate("(() => { const m = document.querySelector('#flowers-game ruffle-player').metadata; return {width: m.width, height: m.height, swfVersion: m.swfVersion, frameRate: m.frameRate}; })()")
        tenant = (await page.evaluate("window.shellCrtQa"))["tenant"]
        w = json.loads(tenant["placement"])["rect"]  # the window in the Shell's logical px, as handed to the page
        corners = [await page.evaluate(TO_PAGE, pt) for pt in ([w[0], w[1]], [w[0] + w[2], w[1] + w[3]])]
        log.append({"renderer": await page.evaluate("(() => { const c = document.createElement('canvas').getContext('webgl2'); const d = c.getExtension('WEBGL_debug_renderer_info'); return c.getParameter(d.UNMASKED_RENDERER_WEBGL); })()")})
        check("ruffle_loaded_the_site_swf", meta["width"] == 750 and meta["height"] == 422, meta)
        check("player_sits_on_the_window", abs(frame["x"] - corners[0][0]) < 1 and abs(frame["y"] - corners[0][1]) < 1
              and abs(frame["x"] + frame["w"] - corners[1][0]) < 1 and abs(frame["y"] + frame["h"] - corners[1][1]) < 1, f"frame {frame} window corners {corners}")
        s = frame["w"] / GAME[0]
        at = lambda gx, gy: (frame["x"] + gx * s, frame["y"] + gy * s)
        title = region(out / "02-flowers-title.png", frame)
        # the title screen: its menu text and the vase are drawn (not a blank or white player)
        check("title_screen_renders", ImageStat.Stat(title.convert("L")).stddev[0] > 8, f"stddev {ImageStat.Stat(title.convert('L')).stddev[0]:.1f}")

        await page.mouse.click(*at(513, 274)); await page.wait_for_timeout(2500)  # Start New
        await page.screenshot(path=out / "03-instructions.png")
        instr = region(out / "03-instructions.png", frame)
        check("start_new_opens_the_instructions", changed(title, instr) > 10, f"diff {changed(title, instr):.1f}")

        await page.mouse.click(*at(725, 410)); await page.wait_for_timeout(3000)  # NEXT
        await page.screenshot(path=out / "04-garden.png")
        garden = region(out / "04-garden.png", frame)
        check("next_opens_the_garden_and_vase", changed(instr, garden) > 2, f"diff {changed(instr, garden):.1f}")

        # pick a flower: press on a blossom in the (randomly planted) garden, drag it into the vase, let go
        g = garden.resize(GAME)
        pink = [(x, y) for y in range(60, 330, 3) for x in range(10, 340, 3)
                if (lambda c: c[0] > 235 and c[1] < 175 and c[2] < 175)(g.getpixel((x, y)))]
        vase = {"x": frame["x"] + 355 * s, "y": frame["y"], "w": 390 * s, "h": 395 * s}
        before = region(out / "04-garden.png", vase)
        placed_ok, tries = False, 0
        for gx, gy in pink[::7][:25]:
            tries += 1
            await page.mouse.move(*at(gx, gy)); await page.wait_for_timeout(60)
            await page.mouse.down(); await page.wait_for_timeout(80)
            for i in range(1, 9):
                await page.mouse.move(*at(gx + (550 - gx) * i / 8, gy + (200 - gy) * i / 8)); await page.wait_for_timeout(40)
            if tries == 1 or not placed_ok:
                await page.screenshot(path=out / "05-dragging.png")
            await page.mouse.up(); await page.wait_for_timeout(700)
            await page.screenshot(path=out / "06-placed.png")
            if changed(before, region(out / "06-placed.png", vase)) > 1:
                placed_ok = True; break
        check("dragging_a_blossom_puts_a_flower_in_the_vase", placed_ok, f"{tries} tries of {len(pink)} pink points")

        await page.mouse.click(*(await page.evaluate(TO_PAGE, [qa["shell"]["tabs"][4]["rect"][0] + qa["shell"]["tabs"][4]["rect"][2] / 2,
                                                               qa["shell"]["tabs"][4]["rect"][1] + qa["shell"]["tabs"][4]["rect"][3] / 2])))
        await page.wait_for_timeout(1500)
        hidden = await page.evaluate("getComputedStyle(document.getElementById('flowers-game')).display")
        await page.screenshot(path=out / "07-collection-again.png")
        check("player_hides_with_the_page", hidden == "none", hidden)
        await page.mouse.click(*tab_xy); await page.wait_for_timeout(2000)
        await page.screenshot(path=out / "08-flowers-again.png")
        back = region(out / "08-flowers-again.png", frame)
        placed = region(out / "06-placed.png", frame)
        check("game_is_where_it_was_after_coming_back", changed(placed, back) < 3, f"diff {changed(placed, back):.2f}")
        # the steps that needed the site's PHP, now answered in the page (flowers_embed.gd)
        await page.mouse.click(*at(710, 409)); await page.wait_for_timeout(2500)  # NEXT: the send form
        for (gx, gy), text in (((226, 32), "Reid"), ((226, 56), "reid@example.com"), ((226, 93), "Ana"),
                               ((226, 117), "ana@example.com"), ((226, 230), "Hello from the Flowers tab")):
            await page.mouse.click(*at(gx, gy)); await page.wait_for_timeout(200)
            await page.keyboard.type(text, delay=30)
        await page.screenshot(path=out / "09-send-form.png")
        await page.mouse.click(*at(660, 410)); await page.wait_for_timeout(2500)  # CONTINUE TO PREVIEW
        await page.screenshot(path=out / "10-preview.png")
        await page.mouse.click(*at(725, 410)); await page.wait_for_timeout(4000)  # SUBMIT
        await page.screenshot(path=out / "11-delivered.png")
        number = await page.evaluate("(Object.keys(localStorage).find((k) => k.startsWith('orisinal-flowers:')) || ':').split(':')[1]")
        answered = await page.evaluate("window.flowersLog")
        check("submit_gives_a_12_digit_flower_number", re.fullmatch(r"\d{12}", number or "") and any(a.endswith("reply=" + number) for a in answered), f"{number} {answered}")
        await page.mouse.click(*at(692, 410)); await page.wait_for_timeout(2500)  # MAIN MENU
        await page.mouse.click(*at(513, 303)); await page.wait_for_timeout(2000)  # Enter Flower Number
        await page.mouse.click(*at(375, 199)); await page.keyboard.type(number, delay=30)
        await page.mouse.click(*at(328, 228)); await page.wait_for_timeout(4000)  # SUBMIT
        await page.screenshot(path=out / "12-your-flowers.png")
        card = region(out / "12-your-flowers.png", {"x": frame["x"], "y": frame["y"], "w": 350 * s, "h": 200 * s})
        check("the_number_brings_the_card_back", (await page.evaluate("window.flowersLog"))[-1].endswith("reply=1")
              and ImageStat.Stat(card.convert("L")).stddev[0] > 5, (await page.evaluate("window.flowersLog"))[-1])
        await page.mouse.click(*at(715, 409)); await page.wait_for_timeout(2500)  # BACK TO MENU
        await page.mouse.click(*at(513, 333)); await page.wait_for_timeout(4000)  # View Samples
        await page.screenshot(path=out / "13-sample.png")
        last = (await page.evaluate("window.flowersLog"))[-1]
        check("view_samples_shows_a_players_bouquet", last.endswith("reply=1") and "&total=" in last, last)
        check("no_failed_requests", not failed, failed)
        await browser.close()
    report = {"build": sha, "checks": checks, "console_errors": log}
    (out / "report.json").write_text(json.dumps(report, indent=1))
    print("VERDICT", "PASS" if all(c["ok"] for c in checks) else "FAIL")
    sys.exit(0 if all(c["ok"] for c in checks) else 1)

asyncio.run(main())
