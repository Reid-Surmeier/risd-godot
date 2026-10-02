"""Cut the RISD catalogue photographs into the textures european_west_additions.gd loads.

Run: /usr/bin/python3 prepare_assets.py SOURCE_DIR   (needs cv2; no network, no paid call)
SOURCE_DIR holds the catalogue zoom images named by accession (42_042-0.jpg ...), fetched from the
URLs in SOURCES.md. They are 51 MB and are not kept in the repository.
Writes <name>.jpg beside this file (JPEG, 1600 px on the long side at most) and cutouts.json
(outline of each free-standing object, 0..1 of its texture, y down, for Painting.build_shaped).
Flat works are cropped by the fractions below (plate or canvas only). Objects are cut from their
studio background with GrabCut, seeded by a border rectangle.
ponytail: one GrabCut pass and a polygon outline; hand-trace an outline only if one reads wrong.
"""
import json
import pathlib
import sys

import cv2
import numpy as np

HERE = pathlib.Path(__file__).parent
SOURCE = pathlib.Path(sys.argv[1])
# name: (source file, crop as fractions x0, y0, x1, y1)
FLAT = {
    'tironi-42.042': ('42_042-0.jpg', (0, 0, 1, 1)),
    'guardi-53.115': ('53_115-0.jpg', (0, 0, 1, 1)),
    'guardi-24.508': ('24_508-0.jpg', (.006, .012, .994, .988)),
    'piranesi-63.066.45': ('63_066_45-0.jpg', (.055, .03, .945, .825)),
    'zompini-67.106.31': ('67_106_31-0.jpg', (.045, .07, .80, .92)),
    'zompini-67.106.8': ('67_106_8-0.jpg', (.06, .09, .75, .92)),
    'kussell-2024.17.5': ('2024_17_5-0.jpg', (.13, .20, .89, .87)),
    'kussell-2024.17.6': ('2024_17_6-0.jpg', (.12, .22, .90, .90)),
    'lawrence-42.072': ('42_072-0.jpg', (0, 0, 1, 1)),
    'textile-85.075.6': ('85_075_6-0.jpg', (0, 0, 1, 1)),
    'previtali-16.237': ('16_237-0.jpg', (0, 0, 1, 1)),
    'mosaic-1990.060': ('1990_060-0.jpg', (.025, .025, .975, .975)),
}
CUT = {
    'tabernacle-06.057': '06_057-0.jpg',
    'knocker-55.091': '55_091-1.jpg',
    'apollo-73.079': '73_079-3.jpg',
    'dress-2000.103.3': '2000_103_3-0.jpg',
    'jug-47.625': '47_625-0.jpg',
    'cup-45.188': '45_188-0.jpg',
    'cup-32.010': '32_010-0.jpg',
    'bowl-73.060': '73_060-0.jpg',
    'owl-52.533': '52_533-0.jpg',
}


def save(name, image):
    scale = min(1.0, 1600 / max(image.shape[:2]))
    if scale < 1:
        image = cv2.resize(image, None, fx=scale, fy=scale, interpolation=cv2.INTER_AREA)
    for quality in (88, 80, 72, 64):  # every picture stays under 600 KB
        cv2.imwrite(str(HERE / f'{name}.jpg'), image, [cv2.IMWRITE_JPEG_QUALITY, quality])
        if (HERE / f'{name}.jpg').stat().st_size < 600_000:
            return
    assert False, name


cuts = {}
for name, (source, (x0, y0, x1, y1)) in FLAT.items():
    image = cv2.imread(str(SOURCE / source))
    h, w = image.shape[:2]
    image = image[int(y0 * h):int(y1 * h), int(x0 * w):int(x1 * w)]
    save(name, image)
    cuts[name] = {'aspect': image.shape[1] / image.shape[0]}
for name, source in CUT.items():
    image = cv2.imread(str(SOURCE / source))
    small = cv2.resize(image, None, fx=600 / image.shape[0], fy=600 / image.shape[0], interpolation=cv2.INTER_AREA)
    h, w = small.shape[:2]
    mask = np.zeros((h, w), np.uint8)
    cv2.grabCut(small, mask, (int(w * .03), int(h * .02), int(w * .94), int(h * .96)), np.zeros((1, 65)), np.zeros((1, 65)), 5, cv2.GC_INIT_WITH_RECT)
    solid = np.where((mask == cv2.GC_FGD) | (mask == cv2.GC_PR_FGD), 255, 0).astype(np.uint8)
    solid = cv2.morphologyEx(solid, cv2.MORPH_CLOSE, np.ones((9, 9), np.uint8))
    contours, _ = cv2.findContours(solid, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    contour = max(contours, key=cv2.contourArea)
    x, y, cw, ch = cv2.boundingRect(contour)
    filled = cv2.contourArea(contour) / (w * h)
    if not .04 < filled < .92:  # the cut failed: keep the whole photograph as a card
        x, y, cw, ch = 0, 0, w, h
        outline = [[0, 0], [1, 0], [1, 1], [0, 1]]
    else:
        polygon = cv2.approxPolyDP(contour, .004 * cv2.arcLength(contour, True), True)[:, 0, :]
        outline = ((polygon - [x, y]) / [cw, ch]).round(4).tolist()
    k = image.shape[0] / 600
    save(name, image[int(y * k):int((y + ch) * k), int(x * k):int((x + cw) * k)])
    cuts[name] = {'aspect': cw / ch, 'outline': outline, 'filled': round(filled, 3)}
    print(name, len(outline), 'points', round(filled, 3))
(HERE / 'cutouts.json').write_text(json.dumps(cuts, indent=1) + '\n')
