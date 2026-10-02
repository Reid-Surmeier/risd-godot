"""CPU-decode the native frames used here, rectify the two low-case works and build the comparison sheets.
python3 make_evidence.py   (no GPU; writes frames/, sheets/ and SHA256.json; ffmpeg commands and PNG hashes go to frames/manifest.json)"""
import hashlib, json, subprocess, tempfile
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw, ImageEnhance, ImageFilter, ImageOps
here = Path(__file__).parent
V = '/home/reidsurmeier/risd-godot-ingestion/collection-expansion/verified/'
sha = lambda p: hashlib.sha256(Path(p).read_bytes()).hexdigest()
manifest = {'videos': {v: sha(V + v) for v in ('IMG_6382.MOV', 'IMG_6383.MOV')}, 'cuda_decode': False, 'frames': []}

def decode(video, start, count, keep, label):
    """Decode `count` consecutive native frames from `start` seconds and keep the listed 1-based indexes."""
    with tempfile.TemporaryDirectory() as tmp:
        cmd = ['ffmpeg', '-v', 'error', '-hwaccel', 'none', '-noautorotate', '-ss', str(start), '-i', V + video, '-vf', 'transpose=clock', '-frames:v', str(count), f'{tmp}/%04d.png']
        subprocess.run(cmd, check=True)
        for n in keep:
            png = Path(tmp) / f'{n:04d}.png'; seconds = round(start + (n - 1) * 1001 / 30000, 2)
            jpg = here / 'frames' / f'{video[:8]}-{label}-{n:04d}.jpg'; Image.open(png).save(jpg, quality=95)
            manifest['frames'].append({'video': video, 'seconds': seconds, 'frame_index_from_start': n, 'start_seconds': start, 'command': cmd, 'png_sha256': sha(png), 'kept_file': jpg.name, 'kept_sha256': sha(jpg)})
decode('IMG_6382.MOV', 0, 10, range(1, 11), 'start')       # 0.00-0.30 s: low case seen from its far side, close
decode('IMG_6382.MOV', 93.5, 45, [45], 'from93.5')          # 94.97 s: low case from the label side
decode('IMG_6383.MOV', 46.4, 1, [1], 'at46.40')             # emblem book open, case A
decode('IMG_6383.MOV', 45.7, 1, [1], 'at45.70')             # emblem book label
(here / 'frames/manifest.json').write_text(json.dumps(manifest, indent=1) + '\n')
frame = lambda name: Image.open(here / 'frames' / name).convert('RGB')
photo = lambda name: Image.open(here / 'photos' / name).convert('RGB')

def rect(im, quad, size):
    """quad = picture TL, TR, BR, BL in reading order, as frame pixels."""
    return im.transform(size, Image.QUAD, [c for p in (quad[0], quad[3], quad[2], quad[1]) for c in p], Image.BICUBIC)
def sheet(name, tiles, scale=2):
    W, H = max(t.width for _, t in tiles), max(t.height for _, t in tiles)
    s = Image.new('RGB', ((W + 8) * len(tiles), H + 20), 'white')
    for i, (label, t) in enumerate(tiles):
        s.paste(t, (i * (W + 8), 20)); ImageDraw.Draw(s).text((i * (W + 8) + 2, 4), label, fill='black')
    s.resize((s.width * scale, s.height * scale), Image.LANCZOS).save(here / 'sheets' / name, quality=92); print(name)
like = lambda name, size, blur: photo(name).resize(size, Image.LANCZOS).filter(ImageFilter.GaussianBlur(blur))
con = lambda im: ImageOps.autocontrast(im, cutoff=1)

# L2, the larger work. At 0.00 s the camera is on the far side, so the picture is upside down: reading TL is the frame's BR corner.
# Corners read from a 6x gridded crop; the bottom-left corner is 10 px outside the frame.
a1 = frame('IMG_6382-start-0001.jpg'); W, H = 228, 280
l2 = rect(a1, [(120, 1688), (-10, 1692), (60, 1583), (176, 1580)], (W, H))
b45 = frame('IMG_6382-from93.5-0045.jpg')
l2b = rect(b45, [(1000, 1002), (1062, 1086), (905, 1118), (853, 1030)], (H, W)).rotate(90, expand=True)
G = 'mary-magdalene-51020-zoom-0.jpg'
sheet('L2-vs-goltzius-51.020.jpg', [('L2 at 0.00s, rectified', l2), ('same, contrast stretched', con(l2)), ('L2 at 94.97s, rectified (blurred by motion)', con(l2b)),
                                    ('RISD 51.020 official photo', like(G, (W, H), 0)), ('51.020 blurred to film resolution', like(G, (W, H), 3.5))])
B = photo('river-landscape-mercury-abducting-psyche-841981032-zoom-0.jpg').crop((130, 80, 1195, 830))
l2w = rect(a1, [(120, 1688), (-10, 1692), (60, 1583), (176, 1580)], (346, 276))
sheet('L2-rejected-bruegel-84.198.1032.jpg', [('L2 at 0.00s, forced to 34.6 x 27.6 shape', con(l2w)), ('RISD 84.198.1032 image area', B.resize((346, 276), Image.LANCZOS)),
                                              ('blurred to film resolution', B.resize((346, 276), Image.LANCZOS).filter(ImageFilter.GaussianBlur(4)))])

# L1, the small work: washed out in any one frame, so ten consecutive frames are rectified and averaged.
W, H = 204, 268; stack = []; boxes = []; cx, cy = 111, 108
for n in range(1, 11):
    im = frame(f'IMG_6382-start-{n:04d}.jpg'); win = (400, 1500, 680, 1800)
    g = np.asarray(im.crop(win)).astype(float).mean(2); ys, xs = np.where(g < np.median(g) - 14)   # the picture is darker than its mount
    k = (abs(xs - cx) < 45) & (abs(ys - cy) < 45); xs, ys = xs[k], ys[k]
    x0, x1, y0, y1 = np.percentile(xs, 2), np.percentile(xs, 98), np.percentile(ys, 2), np.percentile(ys, 98); cx, cy = (x0 + x1) / 2, (y0 + y1) / 2
    box = (win[0] + x0, win[1] + y0, win[0] + x1, win[1] + y1); boxes.append([round(v) for v in box])
    stack.append(np.asarray(rect(im, [(box[2], box[3]), (box[0], box[3]), (box[0], box[1]), (box[2], box[1])], (W, H))).astype(float))
l1 = Image.fromarray(np.mean(stack, axis=0).astype('uint8'))
(here / 'frames/L1-boxes.json').write_text(json.dumps(boxes) + '\n')
M, R, = 'penitent-magdalene-glory-821902-zoom-0.jpg', 'st-margaret-and-dragon-821901-zoom-0.jpg'
sheet('L1-vs-miniatures.jpg', [('L1, mean of 10 frames 0.00-0.30s', l1), ('same, contrast stretched', con(l1)), ('same, colour x3', ImageEnhance.Color(con(l1)).enhance(3)),
                               ('RISD 82.190.2 official photo', like(M, (W, H), 0)), ('82.190.2 blurred to film resolution', like(M, (W, H), 7)),
                               ('82.190.1 blurred (rejected)', like(R, (W, H), 7)), ('51.020 blurred (rejected for L1)', like(G, (W, H), 7))])

# R12: the open book in the film beside the same opening in Glasgow University Library's copy of the 1584 edition.
book = frame('IMG_6383-at46.40-0001.jpg').crop((0, 820, 520, 1320)).resize((1040, 1000), Image.LANCZOS)
pages = [Image.open(here / 'web' / f'glasgow-sm772_{p}.jpg').convert('RGB') for p in ('f2v', 'f3r')]
pages = [p.resize((round(p.width * 1000 / p.height), 1000), Image.LANCZOS) for p in pages]
sheet('R12-opening-vs-glasgow-sm772.jpg', [('SOURCE IMG_6383 46.40s, case A', book), ('Glasgow Univ. Library SM772, f2v (emblem 15 verse)', pages[0]), ('Glasgow Univ. Library SM772, f3r (emblem 15)', pages[1])], scale=1)
label = frame('IMG_6383-at45.70-0001.jpg').crop((0, 1380, 1000, 1680)); label = label.resize((label.width * 2, label.height * 2), Image.LANCZOS)
sheet('R12-case-label.jpg', [('SOURCE IMG_6383 45.70s: label for the book (left) and the drug jar (right)', label)], scale=1)

files = {str(p.relative_to(here)): sha(p) for p in sorted(here.rglob('*')) if p.is_file() and p.name != 'SHA256.json' and '__pycache__' not in p.parts}
(here / 'SHA256.json').write_text(json.dumps(files, indent=1) + '\n'); print(len(files), 'files hashed')
