"""Grey gallery west wall: where the connector doorway sits, from two views of one wall.

Not a reconstruction and not a calibration. Each frame is rectified from the wall's
own long straight lines (ceiling, baseboard, door head; casing and corner uprights),
then scaled by the Courbet canvas (catalogue 0.733 x 0.597 m) hanging on that wall.
Positions along the wall need only the lines and the canvas width; the lens focal
length enters only where a height is used as the ruler.

    python3 fit.py            # writes fit.json, overlays/ and plan.png, prints the table
    python3 fit.py --check    # same, then asserts the claims in REPORT.md

System Python with numpy, Pillow and OpenCV (OpenCV only for the failure case).
"""
import hashlib, json, sys
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw

here = Path(__file__).resolve().parent
picks = json.loads((here / "picks.json").read_text())
CW, CH = picks["ruler"]["canvas_m"]
PP = picks["camera"]["principal_point_px"]
F0, F_SD = picks["camera"]["focal_px"]
SIG = picks["sigma_px"]
# v49c geometry.json, sha256 d59bdada...b78f3: rooms as [x0, x1, z0, z1], doors as z or x intervals.
AUTHORED = {"wall_z": [-5.8, 1.8], "door_z": [-2.8, -1.2], "courbet_z": -4.35,
            "rooms": {"Rockefeller": [-4.7, 1.7, -7.2, -0.4], "European gallery": [-5.55, 0.55, -0.4, 28.1],
                      "Main Hall (fixed)": [0.55, 10.55, 1.8, 28.1], "connector": [1.7, 3.85, -2.8, -1.2],
                      "grey gallery": [3.85, 11.05, -5.8, 1.8], "piano stair": [4.55, 6.55, -7.4, -5.8]}}
N = 4000


def ray(q, f):
    return np.array([(q[0] - PP[0]) / f, (q[1] - PP[1]) / f, 1.0])


def direction(lines, f):
    """3D direction shared by image segments: normal to every segment's viewing plane."""
    rows = []
    for a, b in lines:
        n = np.cross(ray(a, f), ray(b, f))
        rows.append(n / np.linalg.norm(n) * np.hypot(b[0] - a[0], b[1] - a[1]))
    return np.linalg.svd(np.array(rows))[2][-1]


def rectify(frame, f):
    """Returns q -> (along wall, down wall) in one arbitrary unit per frame, and its inverse."""
    r1 = direction(frame["horizontals"].values(), f)
    r2 = direction(frame["verticals"].values(), f)
    r2 = r2 - r2.dot(r1) * r1
    r2 /= np.linalg.norm(r2)
    n = np.cross(r1, r2)

    def plane(q):
        d = ray(q, f)
        p = d / n.dot(d)
        return np.array([p.dot(r1), p.dot(r2)])

    a, b = plane(frame["stations"]["courC_L"]), plane(frame["stations"]["courC_R"])
    t, u = plane(frame["levels"]["courC_top"]), plane(frame["levels"]["courC_bot"])
    sx, sy = np.sign(b[0] - a[0]), np.sign(u[1] - t[1])

    def image(x, y):
        p = x * sx * r1 + y * sy * r2 + n
        return [f * p[0] / p[2] + PP[0], f * p[1] / p[2] + PP[1]]

    return (lambda q: plane(q) * (sx, sy)), image


def jitter(frame, rng):
    """One perturbed copy of a frame's picks."""
    g = lambda q, sx, sy: [q[0] + rng.normal(0, sx), q[1] + rng.normal(0, sy)]
    return {
        "horizontals": {k: [g(p, 0, SIG["line"]) for p in v] for k, v in frame["horizontals"].items()},
        "verticals": {k: [g(p, SIG["line"], 0) for p in v] for k, v in frame["verticals"].items()},
        "stations": {k: g(v, v[2] if len(v) > 2 else SIG["station_x"], 0) for k, v in frame["stations"].items()},
        "levels": {k: g(v, 0, v[2] if len(v) > 2 else SIG["canvas_y"]) for k, v in frame["levels"].items()},
    }


def measure(frame, f, ruler="width"):
    """Named distances in metres. ruler: canvas 'width' (default) or canvas 'height'."""
    R, _ = rectify(frame, f)
    X = {k: R(v)[0] for k, v in frame["stations"].items()}
    Y = {k: R(v)[1] for k, v in frame["levels"].items()}
    s = CW / (X["courC_R"] - X["courC_L"]) if ruler == "width" else CH / (Y["courC_bot"] - Y["courC_top"])
    X = {k: v * s for k, v in X.items()}
    Y = {k: v * s for k, v in Y.items()}
    has = lambda *ks: all(k in X for k in ks)
    out = {"courbet_canvas_w": X["courC_R"] - X["courC_L"], "courbet_canvas_h": Y["courC_bot"] - Y["courC_top"]}
    c = (X["courC_L"] + X["courC_R"]) / 2
    if has("courF_L", "courF_R"):
        out["courbet_frame_w"] = X["courF_R"] - X["courF_L"]
    if has("jamR", "casR"):
        out["stile_w"] = X["casR"] - X["jamR"]
        out["casR_to_courbet_centre"] = c - X["casR"]
    if has("swc", "casL"):
        stile = out["stile_w"]
        out["corner_to_casing"] = X["casL"] - X["swc"]
        out["corner_to_clear_south"] = X["casL"] + stile - X["swc"]
        out["corner_to_clear_north"] = X["jamR"] - X["swc"]
        out["clear_width"] = X["jamR"] - X["casL"] - stile
        out["corner_to_casing_north"] = X["casR"] - X["swc"]
        out["swc_to_courbet_centre"] = c - X["swc"]
    if has("barnF_L", "barnF_R"):
        out["barn_frame_w"] = X["barnF_R"] - X["barnF_L"]
        out["barn_canvas_w"] = X["barnC_R"] - X["barnC_L"]
        out["barn_centre_to_courbet_centre"] = c - (X["barnC_L"] + X["barnC_R"]) / 2
        out["casR_to_barn_frame"] = X["barnF_L"] - X["casR"]
    if has("nwc"):
        out["courbet_centre_to_nwc"] = X["nwc"] - c
    if has("swc", "nwc"):
        out["wall_length"] = X["nwc"] - X["swc"]
    if "base_top" in Y:
        out["canvas_centre_above_baseboard"] = Y["base_top"] - (Y["courC_top"] + Y["courC_bot"]) / 2
        out["baseboard_top_to_ceiling"] = Y["base_top"] - Y["ceiling"]
    return out


def monte_carlo(seed=20261001):
    rng = np.random.default_rng(seed)
    runs = {(k, r): [] for k in picks["frames"] for r in ("width", "height")}
    for _ in range(N):
        f = float(np.clip(rng.normal(F0, F_SD), 700, 1800))
        for k, frame in picks["frames"].items():
            j = jitter(frame, rng)
            for r in ("width", "height"):
                runs[(k, r)].append(measure(j, f, r))
    return {key: {q: np.array([row[q] for row in rows]) for q in rows[0]} for key, rows in runs.items()}


def spread(a):
    p = np.percentile(a, [2.5, 16, 50, 84, 97.5])
    return {"median": round(float(p[2]), 3), "p16_p84": [round(float(p[1]), 3), round(float(p[3]), 3)],
            "p2.5_p97.5": [round(float(p[0]), 3), round(float(p[4]), 3)]}


def failure_cases(frames):
    """Where the method breaks, with numbers."""
    import cv2
    C = picks["frames"]["C1"]
    quad = np.float32(C["horizontals"]["canvas_top"] + C["horizontals"]["canvas_bottom"][::-1])
    target = np.float32([[0, 0], [CW, 0], [CW, CH], [0, CH]])
    corner = np.float32([[C["stations"]["nwc"][:2]]])
    rng = np.random.default_rng(1)
    reach = []
    for _ in range(N):
        H = cv2.getPerspectiveTransform(quad + rng.normal(0, SIG["canvas_y"], quad.shape).astype("float32"), target)
        reach.append(float(cv2.perspectiveTransform(corner, H)[0, 0, 0]) - CW / 2)
    # Long reach: the canvas corners exactly where the wall-line fit puts them in A2, read to
    # the same 2 px, then used alone (no wall lines) to reach the doorway 2.6 m away.
    A = picks["frames"]["A2"]
    R, back = rectify(A, F0)
    x0, x1 = R(A["stations"]["courC_L"])[0], R(A["stations"]["courC_R"])[0]
    y0, y1 = R(A["levels"]["courC_top"])[1], R(A["levels"]["courC_bot"])[1]
    ideal = np.float32([back(x0, y0), back(x1, y0), back(x1, y1), back(x0, y1)])
    door = np.float32([[A["stations"]["casR"][:2]]])
    far = []
    for _ in range(N):
        H = cv2.getPerspectiveTransform(ideal + rng.normal(0, SIG["canvas_y"], ideal.shape).astype("float32"), target)
        far.append(CW / 2 - float(cv2.perspectiveTransform(door, H)[0, 0, 0]))
    frame_w = float(np.mean([frames[k]["width_ruler_m"]["courbet_frame_w"]["median"] for k in frames]))
    wall = frames["B1"]["width_ruler_m"]["wall_length"]["median"]
    return {
        "frame_taken_for_canvas": {
            "courbet_frame_outer_width_m": round(frame_w, 3), "catalogue_canvas_width_m": CW,
            "every_distance_scaled_by": round(CW / frame_w, 3), "wall_length_would_read_m": round(wall * CW / frame_w, 2),
            "note": "Reading the gilt frame's outer edge as the 0.733 m canvas shrinks every distance by this factor."},
        "canvas_only_homography_C1": {
            "courbet_centre_to_nwc_m": spread(np.array(reach)),
            "wall_line_fit_same_frame_m": frames["C1"]["width_ruler_m"]["courbet_centre_to_nwc"],
            "note": "medieval-panel-fit.py pattern: four canvas corners alone, at 400 px across, reaching 0.85 m to the baseboard corner. Short reach, sharp frame: it holds."},
        "canvas_only_homography_A2": {
            "casing_to_courbet_centre_m": spread(np.array(far)),
            "wall_line_fit_same_frame_m": frames["A2"]["width_ruler_m"]["casR_to_courbet_centre"],
            "note": "Same pattern on a 115 px canvas reaching 2.6 m to the doorway: 2 px of corner noise becomes this spread. This is why the wall's own lines carry the perspective and the canvas only sets the scale."},
    }


def held_out_error(frames, chains):
    """Held-out view minus fit view, on medians. Kept apart from the pick intervals."""
    m = lambda k, q: frames[k]["width_ruler_m"][q]["median"]
    out = {q: round(m("B1", q) - m("A1", q), 3) for q in
           ("corner_to_casing", "corner_to_clear_south", "clear_width", "corner_to_clear_north", "swc_to_courbet_centre", "courbet_frame_w")}
    out["courbet_centre_to_nwc"] = round(m("B1", "courbet_centre_to_nwc") - m("A2", "courbet_centre_to_nwc"), 3)
    out["courbet_centre_to_nwc_close_frame_C1"] = round(m("C1", "courbet_centre_to_nwc") - m("A2", "courbet_centre_to_nwc"), 3)
    out["wall_length"] = round(float(np.median(chains["B1"]) - np.median(chains["A1+A2"])), 3)
    return out


def overlay(key, frame):
    image = Image.open(here / frame["file"]).convert("RGB")
    if frame.get("rot180"):
        image = image.rotate(180)
    d = ImageDraw.Draw(image)
    for seg in frame["horizontals"].values():
        d.line([tuple(seg[0]), tuple(seg[1])], fill="cyan", width=2)
    for seg in frame["verticals"].values():
        d.line([tuple(seg[0]), tuple(seg[1])], fill="magenta", width=2)
    S = frame["stations"]
    for i, (name, q) in enumerate(S.items()):
        x, y = q[:2]
        d.line((x, y - 14, x, y + 14), fill="yellow", width=1)
        d.text((x - 12, y + 18 + 11 * (i % 4)), name, fill="yellow")
    for q in frame["levels"].values():
        d.line((q[0] - 10, q[1], q[0] + 10, q[1]), fill="lime", width=1)
    # Metre ticks along the wall from the fit itself, and where the authored doorway would be.
    R, _ = rectify(frame, F0)
    scale = CW / (R(S["courC_R"])[0] - R(S["courC_L"])[0])
    origin = "swc" if "swc" in S else "courC_L"
    x0, y0 = R(S[origin])[0], S["courC_L"][1]
    xs = np.arange(0, image.width, 0.5)
    along = np.array([(R((x, y0))[0] - x0) * scale for x in xs])
    for m in np.arange(np.ceil(along.min() * 2) / 2, along.max(), 0.5):
        x = float(np.interp(m, along, xs))
        d.line((x, y0 - 60, x, y0 - 40), fill="white", width=2)
        d.text((x + 3, y0 - 62), f"{m:g}", fill="white")
    if origin == "swc":
        for z in AUTHORED["door_z"]:
            m = AUTHORED["wall_z"][1] - z
            if along.min() < m < along.max():
                x = float(np.interp(m, along, xs))
                d.line((x, y0 - 150, x, y0 + 150), fill="red", width=3)
                d.text((x + 4, y0 - 150), f"authored jamb {m:g} m", fill="red")
    ys = [q[1] for q in list(S.values()) + list(frame["levels"].values())] + [p[1] for v in frame["horizontals"].values() for p in v]
    top, bottom = max(0, int(min(ys)) - 120), min(image.height, int(max(ys)) + 120)
    d.rectangle((0, top, image.width, top + 22), fill="black")
    d.text((8, top + 5), f"{key}  {frame['video']} {frame['seconds']:.3f} s   cyan/magenta: wall lines   yellow: anchors   white: metres from {origin}", fill="white")
    image.crop((0, top, image.width, bottom)).save(here / "overlays" / f"{key}.jpg", quality=90)


def ratio_overlay(key, frame):
    image = Image.open(here / frame["file"]).convert("RGB")
    d = ImageDraw.Draw(image)
    for row, xs in frame["rows"].items():
        y = int(row)
        d.line((min(xs) - 40, y, max(xs) + 40, y), fill="cyan", width=1)
        for x in xs:
            d.line((x, y - 16, x, y + 16), fill="yellow", width=2)
    for i, name in enumerate(("corner_at_baseboard", "stile_outer_at_baseboard")):
        if name in frame:
            x, y = frame[name]
            d.ellipse((x - 6, y - 6, x + 6, y + 6), outline="yellow", width=2)
            d.text((x - 60, y + 10 + 14 * i), name.replace("_", " "), fill="yellow")
    d.text((8, 8), f"{key}  {frame['video']} {frame['seconds']:.3f} s   {frame['row_meaning']}", fill="white")
    image.crop((0, 300, image.width, 1700)).save(here / "overlays" / f"{key}.jpg", quality=90)


def ratio_frames():
    D, F = picks["ratio_frames"]["D1"], picks["ratio_frames"]["F1"]
    f_rows = list(F["rows"].values())
    f_stile = f_rows[-1][1] - f_rows[-1][0]
    return {
        "grey_corner_to_casing_in_stiles_D1": [round((c - a) / (e - c), 2) for a, c, e in D["rows"].values()],
        "rockefeller_corner_to_casing_in_stiles_F1": round((F["corner_at_baseboard"][0] - F["stile_outer_at_baseboard"][0]) / f_stile, 2),
        "note": "Image ratios of adjacent widths on one wall; no perspective correction and no metres.",
    }


def plan_image(plan):
    """Authored plan beside the recommended one, north end only. x east, z south."""
    s1, s2 = plan["step_1_register"], plan["step_2_wall_length"]
    door, north = s1["door_clear_z"], s2["grey_north_wall_z"]["value"]
    recommended = {"Rockefeller": [-4.7, 1.7, *s1["rooms"]["0 Rockefeller"]["bounds_z"]], "European gallery": [-5.55, 0.55, 1.8, 28.1],
                   "Main Hall (fixed)": [0.55, 10.55, 1.8, 28.1], "connector": [1.7, 3.85, *door],
                   "grey gallery": [3.85, 11.05, north, 1.8], "piano stair": [4.55, 6.55, north - 1.6, north]}
    px, pad, zmin, zmax, xmin, xmax = 34, 30, -8.0, 5.0, -6.2, 11.6
    w = int((xmax - xmin) * px)
    image = Image.new("RGB", (2 * w + 3 * pad, int((zmax - zmin) * px) + 2 * pad + 20), "white")
    d = ImageDraw.Draw(image)
    tone = {"Main Hall (fixed)": "#cfd8e8", "connector": "#c9b6dc", "grey gallery": "#d9d9d4"}
    for col, (title, rooms, dz, courbet) in enumerate([
            ("AUTHORED (v49c geometry.json)", AUTHORED["rooms"], AUTHORED["door_z"], AUTHORED["courbet_z"]),
            ("RECOMMENDED (not built; ranges in plan.json)", recommended, door, s2["courbet_centre_z"]["value"])]):
        ox = pad + col * (w + pad)
        P = lambda x, z: (ox + (x - xmin) * px, pad + 20 + (min(z, zmax) - zmin) * px)
        d.text((ox, 6), title, fill="black")
        for label, (x0, x1, z0, z1) in rooms.items():
            d.rectangle([P(x0, z0), P(x1, z1)], fill=tone.get(label, "#efe9dc"), outline="black", width=2)
            d.text((P(x0, z0)[0] + 4, P(x0, max(z0, zmin))[1] + 4), label, fill="black")
        for x in (1.7, 3.85):  # both ends of the connector
            d.line([P(x, dz[0]), P(x, dz[1])], fill="red", width=5)
        d.line([P(4.55, 1.8), P(6.55, 1.8)], fill="#1a7f37", width=5)  # Hall north door, unchanged
        d.ellipse([P(3.95, courbet)[0] - 4, P(3.95, courbet)[1] - 4, P(3.95, courbet)[0] + 4, P(3.95, courbet)[1] + 4], fill="#8a5a00")
        d.text((P(4.1, courbet)[0], P(4.1, courbet)[1] - 5), "Courbet", fill="#8a5a00")
        if col:
            barn = s2["barn_painting_centre_z"]["value"]
            d.ellipse([P(3.95, barn)[0] - 4, P(3.95, barn)[1] - 4, P(3.95, barn)[0] + 4, P(3.95, barn)[1] + 4], fill="#8a5a00")
            d.text((P(4.1, barn)[0], P(4.1, barn)[1] - 5), "barn", fill="#8a5a00")
        d.line([P(xmin + .3, zmax - .4), P(xmin + 1.3, zmax - .4)], fill="black", width=3)
        d.text((P(xmin + .3, zmax - .4)[0], P(0, zmax - .4)[1] - 14), "1 m (authored units)", fill="black")
    d.text((pad, image.height - 16), "red: connector doorway   green: Hall north door (unchanged)   long galleries cut off at the bottom", fill="black")
    image.save(here / "plan.png")


def main():
    mc = monte_carlo()
    frames = {}
    for k, frame in picks["frames"].items():
        frames[k] = {
            "file": frame["file"], "sha256": hashlib.sha256((here / frame["file"]).read_bytes()).hexdigest(),
            "video": frame["video"], "seconds": frame["seconds"], "view": frame["view"],
            "width_ruler_m": {q: spread(a) for q, a in mc[(k, "width")].items()},
            "height_ruler_m": {q: spread(a) for q, a in mc[(k, "height")].items()},
        }
        overlay(k, frame)
    for k, frame in picks["ratio_frames"].items():
        ratio_overlay(k, frame)
    W = lambda k, q: mc[(k, "width")][q]
    chains = {"A1+A2": W("A1", "swc_to_courbet_centre") + W("A2", "courbet_centre_to_nwc"),
              "A1+C1": W("A1", "swc_to_courbet_centre") + W("C1", "courbet_centre_to_nwc"),
              "B1": W("B1", "wall_length")}
    result = {
        "method": " ".join(__doc__.strip().split("\n\n")[1].split()),
        "monte_carlo": {"draws": N, "sigma_px": SIG, "focal_px": [F0, F_SD], "seed": 20261001,
                        "covers": "pick noise and focal length only; not blur bias, sight-edge loss or the frames standing proud of the wall"},
        "frames": frames,
        "ratio_frames": ratio_frames(),
        "ratio_frame_sha256": {k: hashlib.sha256((here / v["file"]).read_bytes()).hexdigest() for k, v in picks["ratio_frames"].items()},
        "wall_length_m": {k: spread(v) for k, v in chains.items()},
        "held_out_error_m": held_out_error(frames, chains),
        "failure_cases": failure_cases(frames),
        "flags": {"metric_accepted": False, "calibrated_room_metric": False, "physical_loop_accepted": False,
                  "connector_length_accepted": False, "door_at_south_west_corner": True},
    }
    (here / "fit.json").write_text(json.dumps(result, indent=1) + "\n")
    plan_image(json.loads((here / "plan.json").read_text()))
    for k in frames:
        print(f"\n{k}  {frames[k]['video']} {frames[k]['seconds']} s")
        for q, v in frames[k]["width_ruler_m"].items():
            h = frames[k]["height_ruler_m"][q]["median"]
            print(f"  {q:34s} {v['median']:7.3f}  [{v['p16_p84'][0]:.3f}, {v['p16_p84'][1]:.3f}]   height ruler {h:7.3f}")
    print("\nwall length:", {k: (v["median"], v["p2.5_p97.5"]) for k, v in result["wall_length_m"].items()})
    print("held-out minus fit:", result["held_out_error_m"])
    print("ratios:", result["ratio_frames"])
    print("failure cases:", json.dumps(result["failure_cases"], indent=1))
    return result


def check(result):
    """The claims REPORT.md makes, as assertions."""
    F = result["frames"]
    w = lambda k, q: F[k]["width_ruler_m"][q]
    for line in (here / "SHA256SUMS").read_text().splitlines():
        digest, name = line.split()
        assert hashlib.sha256((here / name).read_bytes()).hexdigest() == digest, name
    # 1. Corner door, in both views; the authored 3.0 m of wall south of it is excluded.
    for k in ("A1", "B1"):
        assert w(k, "corner_to_clear_south")["p2.5_p97.5"][1] < 0.6, k
        assert w(k, "corner_to_clear_north")["p2.5_p97.5"][1] < AUTHORED["wall_z"][1] - AUTHORED["door_z"][1], k
    # 2. The held-out view agrees with the fit view.
    for q, limit in [("corner_to_clear_south", .10), ("clear_width", .10), ("corner_to_clear_north", .10),
                     ("swc_to_courbet_centre", .20), ("stile_w", .05)]:
        assert abs(w("A1", q)["median"] - w("B1", q)["median"]) < limit, q
    near = [w(k, "courbet_centre_to_nwc")["median"] for k in ("A2", "B1", "C1")]
    assert max(near) - min(near) < .10, near
    worst = max(abs(v) for v in result["held_out_error_m"].values())
    assert worst < .10, result["held_out_error_m"]
    # 3. An object not used as the ruler comes out the same size in every frame; the canvas height is recovered.
    frame_w = [w(k, "courbet_frame_w")["median"] for k in F]
    assert max(frame_w) / min(frame_w) < 1.04, frame_w
    assert all(abs(w(k, "courbet_canvas_h")["median"] / CH - 1) < .05 for k in F)
    barn = [w(k, "barn_canvas_w")["median"] for k in ("A1", "A2")]
    assert abs(barn[0] - barn[1]) < .03, barn
    # 4. Wall length: three chains agree and none allows the authored 7.6 m.
    lengths = result["wall_length_m"]
    medians = [v["median"] for v in lengths.values()]
    assert max(medians) - min(medians) < .25, medians
    assert all(v["p2.5_p97.5"][1] < AUTHORED["wall_z"][1] - AUTHORED["wall_z"][0] for v in lengths.values())
    # 5. plan.json stays inside what was measured and claims no calibration.
    plan = json.loads((here / "plan.json").read_text())
    s1, s2 = plan["step_1_register"], plan["step_2_wall_length"]
    south, north = 1.8 - s1["door_clear_z"][1], 1.8 - s1["door_clear_z"][0]
    for k in ("A1", "B1"):
        assert abs(south - w(k, "corner_to_clear_south")["median"]) < .05 and abs(north - w(k, "corner_to_clear_north")["median"]) < .05
    assert s1["rooms"]["6 purple connector"]["bounds_z"] == s1["door_clear_z"] == s1["rooms"]["0 Rockefeller"]["openings.east"]
    assert s1["rooms"]["0 Rockefeller"]["bounds_z"][1] <= plan["fixed"]["grey_south_wall_z"], "Rockefeller must not enter the Hall"
    assert min(medians) - .1 < s2["grey_west_wall_length_m"]["value"] < max(medians) + .1
    assert abs(1.8 - s2["courbet_centre_z"]["value"] - np.mean([w(k, "swc_to_courbet_centre")["median"] for k in ("A1", "B1")])) < .05
    for flags in (plan["flags"], result["flags"]):
        assert not any(flags[k] for k in flags if k != "door_at_south_west_corner"), flags
    # 6. The failure case is real: frame taken for canvas is a large error.
    cases = result["failure_cases"]
    assert cases["frame_taken_for_canvas"]["every_distance_scaled_by"] < .8
    lo, hi = cases["canvas_only_homography_A2"]["casing_to_courbet_centre_m"]["p2.5_p97.5"]
    a, b = cases["canvas_only_homography_A2"]["wall_line_fit_same_frame_m"]["p2.5_p97.5"]
    assert hi - lo > 2 * (b - a), "canvas-only reach should be visibly worse than the wall-line fit"
    print("\nCHECK PASSED: 6 groups")


if __name__ == "__main__":
    result = main()
    if "--check" in sys.argv:
        check(result)
