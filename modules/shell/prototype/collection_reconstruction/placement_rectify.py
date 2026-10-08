"""Where a work hangs, read from footage (#266). Matches a work's own picture to video frames (SIFT,
RANSAC homography) and, because the picture's size is known, redraws the best frame square-on to
its wall at 100 px per metre with a 0.5 m grid (picture centre at x 300, y 160). Heights, corners
and door edges are then read off rect-<key>.jpg in metres; works matched in one frame print a
computed centre-to-centre PAIR line. Sculpture does not match. Reference only: nothing here is a
texture in the game.
    python3 placement_rectify.py "<frames glob>" "<room label>" key[,key...] <parts.json> <out dir>
parts.json is placement_dump.gd's output. Frames: ffmpeg -ss T -t N -i clip.MOV -vf fps=2,<tonemap> f%03d.jpg"""
import sys, json, glob, os, numpy as np, cv2
WT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../collection_rooms/assets')
frames_glob, room, keys, parts, S = sys.argv[1], sys.argv[2], sys.argv[3].split(','), sys.argv[4], sys.argv[5]
objs = {o['key']: o for o in json.load(open(parts))['objects'] if o['room'] == room}
sift = cv2.SIFT_create(6000); bf = cv2.BFMatcher()
fr = {}
for f in sorted(glob.glob(frames_glob)):
    im = cv2.imread(f); fr[f] = (im,) + sift.detectAndCompute(cv2.cvtColor(im, cv2.COLOR_BGR2GRAY), None)
PX = 100.0
res = {}
allm = {}
for key in keys:
    o = objs[key]
    p = max([p for p in o['parts'] if p[8] and 'frame' not in p[8]], key=lambda p: max(p[5], p[7]) * p[6])
    a = cv2.imread(glob.glob(WT + '/**/' + p[8], recursive=True)[0], cv2.IMREAD_UNCHANGED)
    if a.ndim == 3 and a.shape[2] == 4:
        a = (a[:, :, :3] * (a[:, :, 3:] / 255.0) + 128 * (1 - a[:, :, 3:] / 255.0)).astype(np.uint8)
    g = cv2.cvtColor(a, cv2.COLOR_BGR2GRAY); k = 800.0 / max(g.shape); g = cv2.resize(g, None, fx=k, fy=k)
    kp, de = sift.detectAndCompute(g, None)
    hh, ww = g.shape; W, H = max(p[5], p[7]), p[6]
    best = None
    for f, (im, fk, fd) in fr.items():
        good = [m for m, q in bf.knnMatch(de, fd, k=2) if m.distance < 0.75 * q.distance]
        if len(good) < 10: continue
        src = np.float32([kp[m.queryIdx].pt for m in good]); dst = np.float32([fk[m.trainIdx].pt for m in good])
        Hm, mask = cv2.findHomography(src, dst, cv2.RANSAC, 3.0)
        if Hm is None or mask.sum() < 10: continue
        qd = cv2.perspectiveTransform(np.float32([[[0, 0], [ww, 0], [ww, hh], [0, hh]]]), Hm)[0]
        e = [np.linalg.norm(qd[i] - qd[(i + 1) % 4]) for i in range(4)]
        ins = src[mask.ravel() == 1]
        if not cv2.isContourConvex(qd) or min(e) < 40 or (np.ptp(ins[:, 0]) / ww) * (np.ptp(ins[:, 1]) / hh) < 0.25: continue
        allm.setdefault(os.path.basename(f), {})[key] = (Hm, W, H, ww, hh, int(mask.sum()))
        room_below = im.shape[0] - qd[:, 1].max()
        score = mask.sum() * (1 if room_below > 0.6 * (e[1] + e[3]) / 2 * 0.5 else 0.3)
        if best is None or score > best[0]: best = (score, f, Hm, int(mask.sum()), qd)
    if best is None: print(key, 'no match'); continue
    _, f, Hm, inl, qd = best
    # texture px -> wall metres (origin at the picture's centre, y up) -> output px
    T = np.array([[W / ww, 0, -W / 2], [0, -H / hh, H / 2], [0, 0, 1]])
    XR, YU, YD = 3.0, 1.6, 2.6
    M = np.array([[PX, 0, XR * PX], [0, -PX, YU * PX], [0, 0, 1]]) @ T @ np.linalg.inv(Hm)
    out = cv2.warpPerspective(fr[f][0], M, (int(2 * XR * PX), int((YU + YD) * PX)))
    for i in range(int(2 * XR * 2) + 1):
        x = int(i * 50); cv2.line(out, (x, 0), (x, out.shape[0]), (0, 255, 255) if i % 2 == 0 else (90, 160, 160), 1)
    for j in range(int((YU + YD) * 2) + 1):
        y = int(j * 50); cv2.line(out, (0, y), (out.shape[1], y), (0, 255, 255) if j % 2 == 0 else (90, 160, 160), 1)
    cv2.imwrite(S + '/rect-%s.jpg' % key, out, [cv2.IMWRITE_JPEG_QUALITY, 80])
    res[key] = dict(frame=os.path.basename(f), inliers=inl, W=W, H=H, quad=qd.tolist())
    print(key, os.path.basename(f), 'inliers', inl, 'quad h px', round((np.linalg.norm(qd[0]-qd[3])+np.linalg.norm(qd[1]-qd[2]))/2), 'size', W, H)
for f, d in sorted(allm.items()):
    ks = list(d)
    for a in ks:
        for b in ks:
            if a == b: continue
            Ha, Wa, Ha_m, wa, ha, ia = d[a]; Hb, Wb, Hb_m, wb, hb, ib = d[b]
            cb = cv2.perspectiveTransform(np.float32([[[wb / 2, hb / 2], [wb / 2, hb]]]), Hb)
            T = np.array([[Wa / wa, 0, -Wa / 2], [0, -Ha_m / ha, Ha_m / 2], [0, 0, 1]])
            m = cv2.perspectiveTransform(cb, T @ np.linalg.inv(Ha))[0]
            print('PAIR', f, a, '->', b, 'centre dx %.3f dy %.3f bottom dy %.3f' % (m[0][0], m[0][1], m[1][1]), 'inl', ia, ib)
json.dump(res, open(S + '/rect-%s.json' % room.split()[1], 'w'))
