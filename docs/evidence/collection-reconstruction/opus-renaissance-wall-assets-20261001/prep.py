"""Authentic textures and source measurements for renaissance_wall_assets.gd. CPU only, 0 USD, nothing generated.
python3 prep.py [root checkout]            writes textures/, references/ and sources.json
python3 prep.py --verify [root checkout]   rebuilds everything in memory and fails if any file or number differs; writes nothing

Inputs, all read only: the official RISD photographs in the accepted inventory (hash-checked against its ledger), four
frames of the owner's IMG_6383.MOV, decoded here on the CPU with the inventory's own command, and one official photograph the
inventory did not download: the velvet's back (live/, fetch_carousel.py, hash pinned below).

Painted and woven pixels: every opaque texel of the three artwork textures equals the source decode. Backdrop is alpha 0;
its colour channels copy the nearest kept texel so filtering cannot pull white onto an edge. Each textile also gets its outline as a
white alpha mask, which the asset tints one plain colour for the back nobody photographed.
Frame strips: the only pixels that are resampled. They are the native 15.10 s frame warped into the plane of the painting
through a homography fitted to the official photograph, then cut into one strip per frame member.
Sizes read from the video (mount board, frame bands, velvet width cross-check) are measurements with stated error, not catalogue facts."""
import hashlib, io, json, subprocess, sys, tempfile
from pathlib import Path
import cv2
import numpy as np
from PIL import Image
from scipy import ndimage

here = Path(__file__).parent
args = [a for a in sys.argv[1:] if a != '--verify']
verify = '--verify' in sys.argv
root = Path(args[0] if args else '/home/reidsurmeier/orca/workspaces/risd-godot/collection-reconstruction')
review = root / 'docs/evidence/collection-reconstruction/opus-renaissance-case-inventory-20261001'
VIDEO = Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion/verified/IMG_6383.MOV')
VIDEO_SHA = '8cfd089e769000369419f577f28a1bfc68b09f8cc7cda4cbe93d840194e6eeef'
PAD = 8

VELVET = 'velvet-cover-23307x-zoom-0.jpg'
# Third of four photographs on the velvet's catalogue page: the back, a plain lining with the museum's sewn tag. Not in the inventory ledger.
VELVET_BACK = 'carousel-velvet-cover-23307x-zoom-2.jpg'
VELVET_BACK_SHA = 'eac340d07a06c91cdf1069f11c7e3d5ed9b8a0cfda458be219742dca287572e4'
VELVET_BODY_ROWS = {'front': (242, 2866), 'back': (273, 2895)}  # between the two fringes: braid lines on the front, the lining's ends on the back
TAPESTRY = 'woodcutters-29280-zoom-0.jpg'
PANEL = 'madonna-and-child-saint-barbara-and-saint-catherine-58196-zoom-0.jpg'    # studio photograph, unframed crop: the texture
PANEL_FRAMED = 'madonna-and-child-saint-barbara-and-saint-catherine-58196-zoom-1.jpg'  # taken in its frame: registration only
# Catalogue records 1202276, 1201986, 1591076 (api/cached-records.json). Metres.
VELVET_LENGTH = 1.27
TAPESTRY_SIZE = (.94, 1.524)
PANEL_SIZE = (.87, .914)

# Hand readings from the rectified video, in pixels of the registered official photograph. See references/.
# Velvet 6.10 s, photograph zoom-0: mount board edges left, top, right, bottom (+-15 px sides and bottom, +-40 px top, soft under the hood).
BOARD_PX = (-495, -110, 1800, 3314)
# Acrylic hood outer edges, same frame. Not built; reported for whoever builds the case. +-40 px.
HOOD_PX = (-580, -180, 1890, 3595)
# Painting 15.10 s, photograph zoom-1: pixels outward from each photograph edge to the sight edge, the inner moulding's outer edge,
# the frieze's outer edge and the frame's outer edge (+-5 px, the left frieze edge +-10 px).
BANDS_PX = {'left': (3, 30, 78, 118), 'top': (1, 28, 68, 114), 'right': (24, 53, 105, 147), 'bottom': (7, 37, 77, 134)}
# The model's symmetric bands, metres from sight edge outward: inner moulding, frieze, outer moulding. Means of the four readings.
BANDS_M = (.018, .029, .030)
STRIP = (880, 64)  # one strip per member: along x across, about the video's own 1.2 mm per pixel


def sha(data):
    return hashlib.sha256(data if isinstance(data, bytes) else Path(data).read_bytes()).hexdigest()


def photo(name, ledger):
    path = review / 'photos' / name
    assert sha(path) == ledger[name], f'{name} does not match the inventory ledger'
    return cv2.imread(str(path))


def frame(seconds, manifest):
    """One native frame, decoded exactly as the inventory did. Returns pixels, the PNG hash and the command."""
    with tempfile.TemporaryDirectory() as tmp:
        png = Path(tmp) / 'frame.png'
        cmd = ['ffmpeg', '-v', 'error', '-y', '-hwaccel', 'none', '-noautorotate', '-ss', f'{seconds:.2f}', '-i', str(VIDEO), '-frames:v', '1', '-vf', 'transpose=clock', '-update', '1']
        subprocess.run(cmd + [str(png)], check=True)
        digest = sha(png)
        if seconds in manifest:
            assert digest == manifest[seconds], f'{seconds} s does not decode to the inventory frame'
        return cv2.imread(str(png)), {'seconds': seconds, 'png_sha256': digest, 'in_inventory_manifest': seconds in manifest, 'command': cmd + ['<png>']}


def register(picture, shot, scale, blur):
    """Homography from photograph pixels to video pixels. The photograph is shrunk and blurred to the video's sharpness first."""
    grey = cv2.GaussianBlur(cv2.resize(cv2.cvtColor(picture, cv2.COLOR_BGR2GRAY), None, fx=scale, fy=scale, interpolation=cv2.INTER_AREA), (0, 0), blur)
    sift = cv2.SIFT_create(6000, contrastThreshold=.02)
    k1, d1 = sift.detectAndCompute(grey, None)
    k2, d2 = sift.detectAndCompute(cv2.cvtColor(shot, cv2.COLOR_BGR2GRAY), None)
    good = [a for a, b in cv2.BFMatcher().knnMatch(d1, d2, k=2) if a.distance < .8 * b.distance]
    src = np.float32([k1[m.queryIdx].pt for m in good]) / scale
    dst = np.float32([k2[m.trainIdx].pt for m in good])
    cv2.setRNGSeed(1)
    H, inliers = cv2.findHomography(src, dst, cv2.RANSAC, 4.0)
    keep = inliers.ravel() == 1
    error = np.linalg.norm(cv2.perspectiveTransform(src.reshape(-1, 1, 2), H).reshape(-1, 2) - dst, axis=1)[keep]
    return H, {'matches': len(good), 'inliers': int(keep.sum()), 'inlier_rms_video_px': round(float(np.sqrt((error ** 2).mean())), 2)}


def rectify(shot, H, size, margin):
    """The video frame drawn in photograph pixels, with `margin` (x, y) extra pixels all round."""
    shift = np.array([[1, 0, margin[0]], [0, 1, margin[1]], [0, 0, 1]], float)
    return cv2.warpPerspective(shot, shift @ np.linalg.inv(H), (size[0] + 2 * margin[0], size[1] + 2 * margin[1]), flags=cv2.INTER_LINEAR)


def textile(picture, fringe_rows=None):
    """Mask of the textile on its white backdrop: coloured or dark pixels, largest piece. Holes are filled except in the fringe rows,
    where the white seen between the threads is backdrop."""
    lab = cv2.cvtColor(picture, cv2.COLOR_BGR2LAB).astype(np.float32)
    raw = ndimage.binary_opening((np.hypot(lab[..., 1] - 128, lab[..., 2] - 128) > 12) | (lab[..., 0] < 110))
    label, count = ndimage.label(raw)
    raw = label == 1 + int(np.argmax(ndimage.sum(raw, label, range(1, count + 1))))
    mask = ndimage.binary_fill_holes(raw)
    if fringe_rows:
        mask[:fringe_rows[0]] = raw[:fringe_rows[0]]
        mask[fringe_rows[1]:] = raw[fringe_rows[1]:]
    return mask


def outline(mask, bridge):
    """The textile's outer edge as a simple polygon. Gaps narrower than `bridge` pixels (between fringe threads) are spanned."""
    solid = cv2.morphologyEx(mask.astype(np.uint8), cv2.MORPH_CLOSE, cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (bridge, bridge)))
    contours, _ = cv2.findContours(solid, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE)
    return cv2.approxPolyDP(max(contours, key=cv2.contourArea), 5, True).reshape(-1, 2)


def png(array):
    out = io.BytesIO()
    Image.fromarray(array).save(out, 'PNG', optimize=True)
    return out.getvalue()


def body(mask, rows):
    """Centre of the velvet between its fringes, and its width at five heights from top to bottom."""
    spans = [np.nonzero(mask[int(rows[0] + (rows[1] - rows[0]) * f)])[0][[0, -1]] for f in (.1, .3, .5, .7, .9)]
    return np.array([np.mean(spans), (rows[0] + rows[1]) / 2]), [int(b - a) for a, b in spans]


def cutout(name, picture, mask, files, outline_mask=False):
    """RGBA crop: source pixels where the mask is set, alpha 0 elsewhere with the nearest kept colour underneath."""
    rgb = cv2.cvtColor(picture, cv2.COLOR_BGR2RGB)
    ys, xs = np.nonzero(mask)
    box = [max(0, int(xs.min()) - PAD), max(0, int(ys.min()) - PAD), min(rgb.shape[1], int(xs.max()) + PAD + 1), min(rgb.shape[0], int(ys.max()) + PAD + 1)]
    crop, inside = rgb[box[1]:box[3], box[0]:box[2]], mask[box[1]:box[3], box[0]:box[2]]
    near = ndimage.distance_transform_edt(~inside, return_distances=False, return_indices=True)
    out = np.dstack([crop[near[0], near[1]], np.where(inside, 255, 0).astype(np.uint8)])
    assert (out[inside][:, :3] == crop[inside]).all()
    files[f'textures/{name}.png'] = png(out)
    if outline_mask:  # the same outline as a white alpha mask: the asset tints it one plain colour for an unobserved back
        files[f"textures/{name.replace('front', 'outline')}.png"] = png(np.dstack([np.full_like(crop, 255), out[..., 3]]))
    rim = inside & ~ndimage.binary_erosion(inside, iterations=6)
    return box, '%02x%02x%02x' % tuple(int(v) for v in np.median(crop[rim], axis=0)), int(inside.sum())


def strips(flat, margin, size, files):
    """One texture per frame member from the rectified video: x runs along the member anticlockwise seen from the front,
    y runs from the sight edge (row 0) to the outer edge, each band stretched to the model's symmetric band width."""
    w, h = size
    stops = np.cumsum((0,) + BANDS_M) / sum(BANDS_M)
    outer = {'left': margin - BANDS_PX['left'][3], 'right': margin + w + BANDS_PX['right'][3], 'top': margin - BANDS_PX['top'][3], 'bottom': margin + h + BANDS_PX['bottom'][3]}
    u = (np.arange(STRIP[0]) + .5) / STRIP[0]
    v = (np.arange(STRIP[1]) + .5) / STRIP[1]
    colours = {}
    for side in ['bottom', 'right', 'top', 'left']:
        # 2 px inside the sight edge and 3 px inside the outer edge, so neither the painting nor the wall is sampled
        reach = np.interp(v, stops, np.clip(BANDS_PX[side], BANDS_PX[side][0] + 2, BANDS_PX[side][3] - 3))
        if side == 'bottom':
            mx, my = np.meshgrid(outer['left'] + u * (outer['right'] - outer['left']), margin + h + reach)
        elif side == 'top':
            mx, my = np.meshgrid(outer['right'] - u * (outer['right'] - outer['left']), margin - reach)
        elif side == 'right':
            my, mx = np.meshgrid(outer['bottom'] - u * (outer['bottom'] - outer['top']), margin + w + reach)
        else:
            my, mx = np.meshgrid(outer['top'] + u * (outer['bottom'] - outer['top']), margin - reach)
        strip = cv2.cvtColor(cv2.remap(flat, mx.astype(np.float32), my.astype(np.float32), cv2.INTER_LINEAR), cv2.COLOR_BGR2RGB)
        files[f'textures/frame-58196-{side}.png'] = png(strip)
        colours[side] = '%02x%02x%02x' % tuple(int(c) for c in np.median(strip[-12:].reshape(-1, 3), axis=0))
    return colours


def ruled(image, step, scale):
    """A viewing copy with a pixel ruler every `step` pixels, shrunk by `scale`."""
    out = image.copy()
    for x in range(0, out.shape[1], step):
        cv2.line(out, (x, 0), (x, 40), (0, 0, 255), 3)
        cv2.putText(out, str(x), (x + 6, 80), cv2.FONT_HERSHEY_SIMPLEX, 1.4, (0, 0, 255), 3)
    for y in range(step, out.shape[0], step):
        cv2.line(out, (0, y), (40, y), (0, 0, 255), 3)
        cv2.putText(out, str(y), (48, y + 14), cv2.FONT_HERSHEY_SIMPLEX, 1.4, (0, 0, 255), 3)
    return cv2.imencode('.jpg', cv2.resize(out, None, fx=scale, fy=scale, interpolation=cv2.INTER_AREA), [cv2.IMWRITE_JPEG_QUALITY, 88])[1].tobytes()


def lossless(image):
    return cv2.imencode('.png', image)[1].tobytes()


def main():
    assert sha(VIDEO) == VIDEO_SHA, 'IMG_6383.MOV is not the verified source'
    ledger_file = review / 'ledger.json'
    ledger = {p['file']: p['sha256'] for o in json.loads(ledger_file.read_text())['objects'] for p in o.get('photos', [])}
    manifest = {f['seconds']: f['png_sha256'] for f in json.loads((review / 'frames/manifest.json').read_text())['frames']}
    files, frames, geometry = {}, [], {}

    # Velvet Cover 23.307X. The catalogue gives the length only; the width follows from the photograph's own proportion.
    picture = photo(VELVET, ledger)
    mask = textile(picture, fringe_rows=VELVET_BODY_ROWS['front'])  # the braid lines that close each fringe, read from row coverage
    box, rim, kept = cutout('velvet-23307x-front', picture, mask, files)
    edge = outline(mask, 41) - box[:2]
    lo, hi = edge.min(0), edge.max(0)
    scale = VELVET_LENGTH / (hi[1] - lo[1])
    centre = (lo + hi) / 2
    shot, record = frame(6.1, manifest)
    frames.append(record)
    H, fit = register(picture, shot, .25, 1.5)
    flat = rectify(shot, H, picture.shape[1::-1], (1100, 700))
    files['references/velvet-23307x-mount-rectified-06.10.jpg'] = ruled(flat, 500, .4)
    files['references/velvet-23307x-mount-native-06.10.png'] = lossless(shot[380:1180, 480:1060])
    board = np.array(BOARD_PX, float) - np.tile(box[:2], 2)  # into crop pixels
    hood = np.array(HOOD_PX, float) - np.tile(box[:2], 2)
    white = np.median(flat[2200:3700, 700:1050].reshape(-1, 3), axis=0)[::-1]  # board to the left of the textile, away from reflections
    geometry['velvet_23307x'] = {
        'texture': 'velvet-23307x-front.png', 'px': list(picture[box[1]:box[3], box[0]:box[2]].shape[1::-1]), 'origin_px': centre.tolist(), 'm_per_px': [scale, scale],
        'outline_px': edge.tolist(), 'size_m': [round(float((hi[0] - lo[0]) * scale), 5), VELVET_LENGTH], 'edge_colour': rim,
        'mount': {'size_m': [round(float((board[2] - board[0]) * scale), 3), round(float((board[3] - board[1]) * scale), 3)],
            'centre_m': [round(float(((board[0] + board[2]) / 2 - centre[0]) * scale), 3), round(float((centre[1] - (board[1] + board[3]) / 2) * scale), 3)],
            'colour': '%02x%02x%02x' % tuple(int(c) for c in white)},
        'hood_observed_not_built': {'size_m': [round(float((hood[2] - hood[0]) * scale), 2), round(float((hood[3] - hood[1]) * scale), 2)],
            'centre_m': [round(float(((hood[0] + hood[2]) / 2 - centre[0]) * scale), 2), round(float((centre[1] - (hood[1] + hood[3]) / 2) * scale), 2)]}}
    # The back. Both photographs are at one scale (the body is 2624 and 2622 pixels long, and its width tapers the same way top to
    # bottom, which also fixes which end is up), so the back takes the front's scale and is laid body centre on body centre, mirrored.
    assert sha(here / 'live' / VELVET_BACK) == VELVET_BACK_SHA, 'the back photograph is not the one inspected'
    behind = cv2.imread(str(here / 'live' / VELVET_BACK))
    behind_mask = textile(behind, fringe_rows=VELVET_BODY_ROWS['back'])
    behind_box, _, behind_kept = cutout('velvet-23307x-rear', behind, behind_mask, files)
    front_centre, front_widths = body(mask, VELVET_BODY_ROWS['front'])
    back_centre, back_widths = body(behind_mask, VELVET_BODY_ROWS['back'])
    offset = centre + box[:2] - front_centre  # the origin, measured from the body's centre in the front photograph
    geometry['velvet_23307x']['rear'] = {'texture': 'velvet-23307x-rear.png', 'px': list(behind[behind_box[1]:behind_box[3], behind_box[0]:behind_box[2]].shape[1::-1]),
        'origin_px': (back_centre + offset * [-1, 1] - behind_box[:2]).tolist(), 'm_per_px': [scale, scale]}
    velvet_source = {'back_photo': f'live/{VELVET_BACK}', 'back_photo_sha256': VELVET_BACK_SHA, 'back_photo_url': 'https://risdmuseum.cdn.picturepark.com/v/e6l3lIgP/',
        'back_photo_in_inventory_ledger': False, 'back_crop_box_px': behind_box, 'back_kept_texels': behind_kept,
        'body_widths_px_top_to_bottom': {'front': front_widths, 'back': back_widths}, 'body_rows_px': VELVET_BODY_ROWS,
        'photo': f'photos/{VELVET}', 'photo_sha256': ledger[VELVET], 'crop_box_px': box, 'kept_texels': kept, 'registration_06.10': fit,
        'width_from_photo_ratio_m': geometry['velvet_23307x']['size_m'][0]}

    # The same velvet measured against the tapestry, which hangs on the same wall and has a catalogue height and width.
    weave = photo(TAPESTRY, ledger)
    shot, record = frame(68.4, manifest)
    frames.append(record)
    weave_mask = textile(weave)
    wy, wx = np.nonzero(weave_mask)
    my, mx = np.nonzero(mask)
    ends = np.float32([[(mx.min() + mx.max()) / 2, my.min()], [(mx.min() + mx.max()) / 2, my.max()], [mx.min(), (my.min() + my.max()) / 2], [mx.max(), (my.min() + my.max()) / 2]])
    fits = []
    for shrink, blur in [(.2, 2.5), (.15, 3.0)]:  # the frame is motion-blurred, so the fit is weak: two settings show the spread
        to_velvet, fit_velvet = register(picture, shot, shrink, blur)
        to_weave, fit_weave = register(weave, shot, shrink, blur)
        on_wall = cv2.perspectiveTransform(cv2.perspectiveTransform(ends.reshape(-1, 1, 2), to_velvet), np.linalg.inv(to_weave)).reshape(-1, 2)
        on_wall *= [TAPESTRY_SIZE[0] / (wx.max() - wx.min() + 1), TAPESTRY_SIZE[1] / (wy.max() - wy.min() + 1)]
        fits.append({'velvet_registration': fit_velvet, 'tapestry_registration': fit_weave,
            'length_with_fringe_m': round(float(np.linalg.norm(on_wall[1] - on_wall[0])), 3), 'width_m': round(float(np.linalg.norm(on_wall[3] - on_wall[2])), 3)})
    velvet_source['against_tapestry_68.40'] = {'fits': fits, 'body_without_fringe_share_of_length': round((2866 - 242) / (my.max() - my.min() + 1), 3),
        'reading': 'the catalogue length of 1.27 m is the whole textile with both fringes; were it the velvet body alone the whole would be about 1.46 m'}

    # The Woodcutters 29.280. Height and width are both catalogued; the photograph's proportion differs slightly and is stretched to them.
    box, rim, kept = cutout('woodcutters-29280-front', weave, weave_mask, files, outline_mask=True)
    edge = outline(weave_mask, 9) - box[:2]
    lo, hi = edge.min(0), edge.max(0)
    geometry['woodcutters_29280'] = {'texture': 'woodcutters-29280-front.png', 'px': list(weave[box[1]:box[3], box[0]:box[2]].shape[1::-1]), 'origin_px': ((lo + hi) / 2).tolist(),
        'm_per_px': [TAPESTRY_SIZE[0] / (hi[0] - lo[0]), TAPESTRY_SIZE[1] / (hi[1] - lo[1])], 'outline_texture': 'woodcutters-29280-outline.png', 'outline_px': edge.tolist(), 'size_m': list(TAPESTRY_SIZE), 'edge_colour': rim}
    shot, record = frame(11.5, manifest)
    frames.append(record)
    H, fit = register(weave, shot, .4, 1.5)
    files['references/woodcutters-29280-rectified-11.50.jpg'] = ruled(rectify(shot, H, weave.shape[1::-1], (300, 300)), 500, .5)
    weave_source = {'photo': f'photos/{TAPESTRY}', 'photo_sha256': ledger[TAPESTRY], 'crop_box_px': box, 'kept_texels': kept, 'registration_11.50': fit,
        'photo_width_over_height': round(float((hi[0] - lo[0]) / (hi[1] - lo[1])), 4), 'catalogue_width_over_height': round(TAPESTRY_SIZE[0] / TAPESTRY_SIZE[1], 4)}

    # Madonna and Child with Saint Barbara and Saint Catherine 58.196. The studio photograph is the texture, every pixel, unscaled in proportion.
    panel = photo(PANEL, ledger)
    files['textures/madonna-58196-front.png'] = png(cv2.cvtColor(panel, cv2.COLOR_BGR2RGB))
    h, w = panel.shape[:2]
    scale = PANEL_SIZE[1] / h
    framed = photo(PANEL_FRAMED, ledger)
    shot, record = frame(15.1, manifest)
    frames.append(record)
    H, fit = register(framed, shot, .5, 1.5)
    margin = 320
    flat = rectify(shot, H, framed.shape[1::-1], (margin, margin))
    sides = strips(flat, margin, framed.shape[1::-1], files)
    files['references/frame-58196-native-15.10.png'] = lossless(shot[500:1320, 260:1060])
    files['references/frame-58196-rectified-15.10.png'] = lossless(flat[margin - 170:margin + framed.shape[0] + 190, margin - 170:margin + framed.shape[1] + 200])
    for name, (x, y) in {'top-left': (margin - 140, margin - 140), 'bottom-right': (margin + framed.shape[1] - 180, margin + framed.shape[0] - 170)}.items():
        files[f'references/frame-58196-corner-{name}-15.10.png'] = lossless(cv2.resize(flat[y:y + 340, x:x + 340], None, fx=3, fy=3, interpolation=cv2.INTER_CUBIC))
    # Where the studio photograph sits inside the framed one, and so inside the visible opening.
    sift = cv2.SIFT_create(6000)
    k1, d1 = sift.detectAndCompute(cv2.cvtColor(panel, cv2.COLOR_BGR2GRAY), None)
    k2, d2 = sift.detectAndCompute(cv2.cvtColor(framed, cv2.COLOR_BGR2GRAY), None)
    good = [a for a, b in cv2.BFMatcher().knnMatch(d1, d2, k=2) if a.distance < .7 * b.distance]
    cv2.setRNGSeed(1)
    place, _ = cv2.estimateAffine2D(np.float32([k1[m.queryIdx].pt for m in good]), np.float32([k2[m.trainIdx].pt for m in good]), method=cv2.RANSAC, ransacReprojThreshold=2)
    corners = (place @ np.array([[0, 0, 1], [w, 0, 1], [w, h, 1], [0, h, 1]], float).T).T
    fw, fh = framed.shape[1::-1]
    sight = [fw - BANDS_PX['left'][0] + BANDS_PX['right'][0], fh - BANDS_PX['top'][0] + BANDS_PX['bottom'][0]]
    total = {side: BANDS_PX[side][3] - BANDS_PX[side][0] for side in BANDS_PX}
    per_px = PANEL_SIZE[1] / sight[1]  # if the visible opening is the whole catalogue height
    geometry['madonna_58196'] = {'texture': 'madonna-58196-front.png', 'px': [w, h], 'origin_px': [w / 2, h / 2], 'm_per_px': [scale, scale], 'size_m': list(PANEL_SIZE),
        'photo_m': [round(w * scale, 5), PANEL_SIZE[1]], 'frame': {'bands_m': list(BANDS_M), 'strip_px': list(STRIP), 'side_colour': sides}}
    panel_source = {'photo': f'photos/{PANEL}', 'photo_sha256': ledger[PANEL], 'texture_is_the_whole_photograph': True,
        'framed_photo': f'photos/{PANEL_FRAMED}', 'framed_photo_sha256': ledger[PANEL_FRAMED], 'registration_15.10': fit,
        'photo_width_over_height': round(w / h, 4), 'catalogue_width_over_height': round(PANEL_SIZE[0] / PANEL_SIZE[1], 4),
        'studio_photo_corners_in_framed_photo_px': np.round(corners, 1).tolist(), 'framed_photo_px': [fw, fh],
        'sight_opening_px': sight, 'sight_width_over_height': round(sight[0] / sight[1], 4),
        'studio_photo_share_of_sight': [round(float(np.linalg.norm(corners[1] - corners[0]) / sight[0]), 3), round(float(np.linalg.norm(corners[3] - corners[0]) / sight[1]), 3)],
        'frame_bands_px_from_photo_edge': {k: list(v) for k, v in BANDS_PX.items()}, 'frame_band_total_px': total,
        'frame_band_total_m_if_sight_is_catalogue_size': {side: round(total[side] * per_px, 3) for side in total},
        'frame_strips': 'resampled (bilinear) from the native 15.10 s frame through the registration homography; not identical to any source pixel'}

    files['textures/geometry.json'] = (json.dumps(geometry, indent=1) + '\n').encode()
    record = {'inventory': 'opus-renaissance-case-inventory-20261001 (root checkout, read only)', 'ledger_sha256': sha(ledger_file),
        'video': str(VIDEO), 'video_sha256': VIDEO_SHA, 'native_frames': frames,
        'objects': {'velvet_23307x': velvet_source, 'woodcutters_29280': weave_source, 'madonna_58196': panel_source},
        'hand_readings': {'velvet_board_px': BOARD_PX, 'velvet_hood_px': HOOD_PX, 'frame_bands_px': {k: list(v) for k, v in BANDS_PX.items()}},
        'files_sha256': {name: sha(data) for name, data in sorted(files.items())}, 'cost_usd': 0, 'generated_pixels': 0}
    files['sources.json'] = (json.dumps(record, indent=1) + '\n').encode()
    for name, data in files.items():
        if verify:
            assert (here / name).read_bytes() == data, f'{name} differs from a fresh run'
        else:
            (here / name).parent.mkdir(exist_ok=True)
            (here / name).write_bytes(data)
    print(f"{'verified' if verify else 'wrote'} {len(files)} files: photographs match the ledger, frames decode from the verified video, opaque artwork texels equal the source decode")
    if not verify:
        print(json.dumps({k: {f: v[f] for f in v if f != 'outline_px'} for k, v in geometry.items()}, indent=1))
        print(json.dumps(record['objects'], indent=1))


main()
