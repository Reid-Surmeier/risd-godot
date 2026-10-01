"""Authentic texture crops for renaissance_case_b_assets.gd, from the official RISD photographs in the accepted inventory (read only).
python3 prep.py [root checkout]            writes textures/*.png and sources.json
python3 prep.py --verify [root checkout]   re-checks every hash and that each in-bound texel equals the source decode; writes nothing

Inside its bound a crop is the source decode, untouched. From 98.5% of the bound outward (soft edge, backdrop, stand, shadow)
every texel is a copy of the nearest kept texel, so filtering and mipmaps cannot pull backdrop colour onto the rim.
Nothing is painted or generated."""
import hashlib, json, sys
from pathlib import Path
import cv2
import numpy as np
from PIL import Image
from scipy import ndimage

here = Path(__file__).parent
args = [a for a in sys.argv[1:] if a != '--verify']
verify = '--verify' in sys.argv
review = Path(args[0] if args else '/home/reidsurmeier/orca/workspaces/risd-godot/collection-reconstruction') / 'docs/evidence/collection-reconstruction/opus-renaissance-case-inventory-20261001'
PAD = 8
KEEP = .985 # the photographed edge is soft and not a perfect ellipse: the outer 1.5% of every bound is padding too
# Round objects: the outline in full-photograph pixels as centre and radii. `how` says where each number comes from.
# The plates stand on acrylic prongs over a soft shadow, so their lower edge is read by hand from pixel columns.
PLATE = 'left, right and top are the outermost colour edge on 240 rays from the centre; bottom read by hand from pixel columns at the centre line (+-3 px)'
FIT = 'cv2.fitEllipse over the outermost colour edge on 360 rays from the centre, then the axis-aligned extent of that ellipse'
ROUND = {
    'plate-46391-front': ('bella-donna-plate-46391-zoom-0.jpg', (649.2, 573.4, 518.2, 510.6), PLATE),
    'plate-57302-front': ('bella-donna-plate-57302-zoom-0.jpg', (663.6, 643.5, 480.6, 484.5), PLATE),
    'plate-57302-rear': ('bella-donna-plate-57302-zoom-1.jpg', (635.6, 679.4, 461.7, 458.6), PLATE),
    'roundel-51105-front': ('death-virgin-51105-zoom-0.jpg', (659, 673), FIT),
    'roundel-51105-rear': ('death-virgin-51105-zoom-1.jpg', (656, 676), FIT),
    'glass-201729-front': ('virgin-woman-apocalypse-201729-zoom-0.jpg', (655, 621), FIT),
    'glass-201729-rear': ('virgin-woman-apocalypse-201729-zoom-1.jpg', (661, 639), FIT),
}
# The enamel plaque: its four outer corners, read by hand from 3x corner enlargements (+-3 px): top left, top right, bottom right, bottom left.
QUAD = {'plaque-34024-front': ('virgin-and-child-clerics-and-donors-34024-zoom-0.jpg', [(166, 83), (1134, 78), (1125, 1232), (184, 1230)],
    'four outer corners read by hand from 3x enlargements (+-3 px)')}
CHAMFER = (.2 / 10.7, .2 / 12.9) # the mesh cuts each corner by 2 mm so the rounded corners' backdrop is never mapped

def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()

def fit(rgb, centre):
    """Axis-aligned extent of the ellipse through the outermost colour edge."""
    lab = cv2.cvtColor(cv2.GaussianBlur(rgb, (0, 0), 2), cv2.COLOR_RGB2LAB).astype(np.float32)
    h, w = lab.shape[:2]
    pts = []
    for a in np.linspace(0, 2 * np.pi, 360, endpoint=False):
        d = np.array([np.cos(a), np.sin(a)])
        reach = min((w - 1 - centre[0]) / d[0] if d[0] > 1e-9 else centre[0] / -d[0] if d[0] < -1e-9 else 1e9,
            (h - 1 - centre[1]) / d[1] if d[1] > 1e-9 else centre[1] / -d[1] if d[1] < -1e-9 else 1e9) - 3
        ts = np.arange(reach, 50, -1.0)
        v = lab[(centre[1] + ts * d[1]).astype(int), (centre[0] + ts * d[0]).astype(int)]
        g = np.linalg.norm(v[6:] - v[:-6], axis=1)
        i = int(np.argmax(g > 14))
        if g[i] > 14:
            pts.append(centre + ts[i + 3] * d)
    (cx, cy), (a, b), angle = cv2.fitEllipse(np.array(pts, np.float32))
    t = np.radians(angle)
    return (round(cx, 1), round(cy, 1), round(float(np.hypot(a / 2 * np.cos(t), b / 2 * np.sin(t))), 1), round(float(np.hypot(a / 2 * np.sin(t), b / 2 * np.cos(t))), 1))

def build(name, photo, mask_of, bound):
    """Crop, pad outside the bound, and return the sources.json row. `bound` is in full-photograph pixels."""
    src = review / 'photos' / photo
    rgb = np.array(Image.open(src).convert('RGB'))
    mask = mask_of(rgb.shape[:2], KEEP)
    ys, xs = np.nonzero(mask_of(rgb.shape[:2], 1)) # the crop holds the whole bound, so no UV leaves the texture
    box = [max(0, int(xs.min()) - PAD), max(0, int(ys.min()) - PAD), min(rgb.shape[1], int(xs.max()) + PAD + 1), min(rgb.shape[0], int(ys.max()) + PAD + 1)]
    crop = rgb[box[1]:box[3], box[0]:box[2]]
    inside = mask[box[1]:box[3], box[0]:box[2]]
    near = ndimage.distance_transform_edt(~inside, return_distances=False, return_indices=True)
    out = crop[near[0], near[1]]
    assert (out[inside] == crop[inside]).all()
    path = here / 'textures' / f'{name}.png'
    if verify:
        assert (np.array(Image.open(path).convert('RGB')) == out).all(), f'{name}: texture differs from the source decode'
    else:
        Image.fromarray(out).save(path, optimize=True)
    # Median colour of the outermost 3% of the kept area: the plain colour for faces the photograph cannot texture.
    rim = inside & ~ndimage.binary_erosion(inside, iterations=max(2, int(.03 * inside.shape[1] / 2)))
    return {'texture': f'textures/{name}.png', 'texture_sha256': sha(path), 'size_px': [out.shape[1], out.shape[0]], 'source_photo': f'photos/{photo}',
        'source_sha256': sha(src), 'crop_box_px': box, 'bound_in_crop_px': bound(box), 'kept_fraction_of_bound': KEEP, 'kept_texels_identical_to_source': True,
        'outside_kept_area': 'nearest kept texel copied outward (edge padding); no backdrop or shadow pixel is kept',
        'rim_median_rgb': '%02x%02x%02x' % tuple(int(v) for v in np.median(crop[rim], axis=0))}

def main():
    ledger = {p['file']: p['sha256'] for o in json.loads((review / 'ledger.json').read_text())['objects'] for p in o.get('photos', [])}
    rows = {}
    for name, (photo, spec, how) in ROUND.items():
        assert sha(review / 'photos' / photo) == ledger[photo], f'{photo} does not match the inventory ledger'
        cx, cy, rx, ry = spec if len(spec) == 4 else fit(np.array(Image.open(review / 'photos' / photo).convert('RGB')), np.array(spec, float))
        def mask_of(shape, keep, e=(cx, cy, rx, ry)):
            y, x = np.mgrid[:shape[0], :shape[1]]
            return ((x - e[0]) / e[2]) ** 2 + ((y - e[1]) / e[3]) ** 2 <= keep ** 2
        rows[name] = build(name, photo, mask_of, lambda box, e=(cx, cy, rx, ry): {'ellipse_centre': [round(e[0] - box[0], 1), round(e[1] - box[1], 1)], 'ellipse_radii': [e[2], e[3]]})
        rows[name]['bound_method'] = how
    for name, (photo, corners, how) in QUAD.items():
        assert sha(review / 'photos' / photo) == ledger[photo], f'{photo} does not match the inventory ledger'
        def mask_of(shape, keep, c=corners):
            # The kept area follows the mesh: the plaque rectangle with its corners cut at CHAMFER, drawn through the same bilinear map.
            m = np.zeros(shape, np.uint8)
            lo, hi = (1 - keep) / 2, (1 + keep) / 2
            cs, ct = (lo + CHAMFER[0], lo + CHAMFER[1]) if keep < 1 else (lo, lo)
            st = [(cs, lo), (1 - cs, lo), (hi, ct), (hi, 1 - ct), (1 - cs, hi), (cs, hi), (lo, 1 - ct), (lo, ct)]
            tl, tr, br, bl = [np.array(q, float) for q in c]
            cv2.fillPoly(m, [np.array([(tl * (1 - s) + tr * s) * (1 - t) + (bl * (1 - s) + br * s) * t for s, t in st]).round().astype(np.int32)], 1)
            return m.astype(bool)
        rows[name] = build(name, photo, mask_of, lambda box, c=corners: {'corners_tl_tr_br_bl': [[x - box[0], y - box[1]] for x, y in c]})
        rows[name]['bound_method'] = how
    record = {'inventory': 'opus-renaissance-case-inventory-20261001 (root checkout, read only)', 'ledger_sha256': sha(review / 'ledger.json'), 'textures': rows,
        'cost_usd': 0, 'generated_pixels': 0}
    if verify:
        assert json.loads((here / 'sources.json').read_text()) == record, 'sources.json does not match a fresh run'
        print(f'verified {len(rows)} textures: hashes match the ledger, kept texels equal the source decode, sources.json is current')
    else:
        (here / 'sources.json').write_text(json.dumps(record, indent=1) + '\n')
        for name, row in rows.items():
            print(name, row['size_px'], row['bound_in_crop_px'], row['rim_median_rgb'])

main()
