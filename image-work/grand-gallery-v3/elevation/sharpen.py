"""For each painting, find its sharpest view anywhere in the wall's stretch of video: features for every frame
(10 fps) are computed once, each painting's clean elevation crop is matched against all of them, and the
sharpest correctly aligned re-projection wins. usage: sharpen.py <name> <t_from> <t_to> <paintings dir>"""
import sys, json, subprocess, tempfile, glob, numpy as np, cv2
name, ta, tb, pdir = sys.argv[1], float(sys.argv[2]), float(sys.argv[3]), sys.argv[4]
V = "/home/reidsurmeier/risd-godot-ingestion/walkthrough/IMG_6344.MOV"
sift = cv2.SIFT_create(3000); bf = cv2.BFMatcher()
tmp = tempfile.mkdtemp()
subprocess.run(["ffmpeg", "-v", "error", "-ss", str(ta), "-to", str(tb), "-i", V, "-vf", "fps=10", "-q:v", "2", f"{tmp}/%04d.jpg"], check=True)
frames = []
for f in sorted(glob.glob(f"{tmp}/*.jpg")):
    im = cv2.imread(f); g = cv2.cvtColor(cv2.resize(im, (540, 960)), cv2.COLOR_BGR2GRAY)
    k, d = sift.detectAndCompute(g, None)
    frames.append((f, k, d))
print(name, len(frames), "frames")
for i, p in enumerate(json.load(open(f"{name}-strip.json"))["paintings"]):
    ref = cv2.imread(f"{name}-ref-{i:02d}.png"); rh, rw = ref.shape[:2]
    Wd, Hd = int(p["width"] * 700), int(p["height"] * 700)
    kr, dr = sift.detectAndCompute(cv2.cvtColor(ref, cv2.COLOR_BGR2GRAY), None)
    if dr is None: continue
    best, bs = None, -1
    for f, kf, df in frames:
        if df is None: continue
        m = [a for a, b in (x for x in bf.knnMatch(dr, df, k=2) if len(x) == 2) if a.distance < 0.8 * b.distance]
        if len(m) < 12: continue
        Hh, inl = cv2.findHomography(np.float32([kr[x.queryIdx].pt for x in m]), np.float32([kf[x.trainIdx].pt for x in m]) * 2, cv2.RANSAC, 4.0)
        if Hh is None or inl.sum() < 10 or abs(np.linalg.det(Hh)) < 1e-6: continue
        S = np.diag([rw / Wd, rh / Hd, 1.0])  # detail pixels -> ref pixels
        out = cv2.warpPerspective(cv2.imread(f), Hh @ S, (Wd, Hd), flags=cv2.INTER_CUBIC | cv2.WARP_INVERSE_MAP)
        a = cv2.cvtColor(cv2.resize(out, (64, 64)), cv2.COLOR_BGR2GRAY).astype(np.float32)
        b = cv2.cvtColor(cv2.resize(ref, (64, 64)), cv2.COLOR_BGR2GRAY).astype(np.float32)
        if ((a - a.mean()) * (b - b.mean())).mean() / (a.std() * b.std() + 1e-6) < 0.5: continue
        sh = cv2.Laplacian(cv2.cvtColor(cv2.resize(out, (400, int(400 * Hd / Wd))), cv2.COLOR_BGR2GRAY), cv2.CV_64F).var()
        if sh > bs: bs, best = sh, out
    if best is not None:
        cv2.imwrite(f"{pdir}/{p['id']}.jpg", best, [cv2.IMWRITE_JPEG_QUALITY, 92]); print(p["id"], "sharpness", round(bs))
