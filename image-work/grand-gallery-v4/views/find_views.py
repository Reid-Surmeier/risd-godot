"""Find each painting's best video views: SIFT-match the museum photo to every frame (3 fps), keep frames where the
canvas is found by a sane homography, score by size x frontality x sharpness, save the top views as framed crops
(canvas quad grown 32% so the frame is included, rectified)."""
import cv2, numpy as np, json, glob
works = json.load(open('../canvas/works.json'))
frames = sorted(glob.glob('/tmp/claude-1000/gg-frames/*.jpg'))
sift = cv2.SIFT_create(2500); flann = cv2.FlannBasedMatcher({'algorithm': 1, 'trees': 4}, {'checks': 48})
feat = []
for f in frames:
    g = cv2.cvtColor(cv2.resize(cv2.imread(f), (540, 960)), cv2.COLOR_BGR2GRAY)
    feat.append(sift.detectAndCompute(g, None))
print('frames', len(frames), flush=True)
res = {}
for w in works:
    ref = cv2.imread(f"../canvas/{w['acc']}.jpg"); rh, rw = ref.shape[:2]
    sc = 700 / max(rh, rw); refs = cv2.resize(ref, (int(rw * sc), int(rh * sc)))
    kr, dr = sift.detectAndCompute(cv2.cvtColor(refs, cv2.COLOR_BGR2GRAY), None)
    cands = []
    for i, (kf, df) in enumerate(feat):
        if df is None or len(kf) < 20: continue
        m = [a for a, b in (x for x in flann.knnMatch(dr, df, k=2) if len(x) == 2) if a.distance < 0.72 * b.distance]
        if len(m) < 18: continue
        H, inl = cv2.findHomography(np.float32([kr[x.queryIdx].pt for x in m]), np.float32([kf[x.trainIdx].pt for x in m]), cv2.RANSAC, 4.0)
        if H is None or inl.sum() < 15: continue
        q = cv2.perspectiveTransform(np.float32([[0, 0], [refs.shape[1], 0], [refs.shape[1], refs.shape[0]], [0, refs.shape[0]]]).reshape(-1, 1, 2), H).reshape(-1, 2) * 2  # full-res
        if not cv2.isContourConvex(q.astype(np.int32)): continue
        area = cv2.contourArea(q)
        sides = [np.linalg.norm(q[(k + 1) % 4] - q[k]) for k in range(4)]
        front = min(sides[0], sides[2]) / max(sides[0], sides[2]) * min(sides[1], sides[3]) / max(sides[1], sides[3])
        if area < 40000 or front < 0.6: continue
        cands.append((area * front ** 2 * min(1.0, inl.sum() / 60), i, q.tolist(), int(inl.sum())))
    cands.sort(reverse=True)
    keep = []
    for c in cands:
        if all(abs(c[1] - k[1]) > 6 for k in keep): keep.append(c)
        if len(keep) == 3: break
    views = []
    for rank, (s, i, q, n) in enumerate(keep):
        img = cv2.imread(frames[i]); q = np.float32(q); c = q.mean(0); qg = c + (q - c) * 1.32
        cw, ch = int(700 * rw / max(rh, rw) * 1.32), int(700 * rh / max(rh, rw) * 1.32)
        crop = cv2.warpPerspective(img, cv2.getPerspectiveTransform(qg, np.float32([[0, 0], [cw, 0], [cw, ch], [0, ch]])), (cw, ch), borderMode=cv2.BORDER_CONSTANT)
        name = f"{w['tag']}-view{rank}.png"; cv2.imwrite(name, crop)
        views.append({'file': name, 'frame': frames[i].split('/')[-1], 't': round(i / 3, 2), 'inliers': n, 'score': round(s)})
    res[w['tag']] = views
    print(w['tag'], w['acc'], len(cands), 'candidates;', [(v['t'], v['inliers']) for v in views], flush=True)
json.dump(res, open('views.json', 'w'), indent=1)
