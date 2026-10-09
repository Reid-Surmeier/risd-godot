"""CPU-only review renders of the OBJ files check.gd writes, set beside their sources.

python3 render.py <ingestion collection-expansion dir>
Flat-shaded z-buffer; the acrylic hood is drawn as edges only. Not the game's renderer or bake.
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw

HERE = Path(__file__).parent
TONE = {"seated_woman_67_089": (202, 160, 70), "body": (175, 171, 163), "trim": (238, 234, 226)}


def load(path):
    vertices, groups, name = [], {}, None
    for line in path.read_text().splitlines():
        kind, *rest = line.split() or [""]
        if kind == "o":
            name = rest[0]
        elif kind == "v":
            vertices.append([float(x) for x in rest])
        elif kind == "f":
            groups.setdefault(name, []).append([int(x) - 1 for x in rest])
    return np.array(vertices), groups


def view(path, eye, target, size=(540, 960), fov=38, ground=(196, 190, 180)):
    vertices, groups = load(path)
    eye, target = np.array(eye, float), np.array(target, float)
    forward = (target - eye) / np.linalg.norm(target - eye)
    right = np.cross(forward, [0, 1, 0])
    right /= np.linalg.norm(right)
    up = np.cross(right, forward)
    cam = (vertices - eye) @ np.stack([right, up, forward]).T
    focal = size[1] / 2 / np.tan(np.radians(fov) / 2)
    screen = np.stack([size[0] / 2 + cam[:, 0] / cam[:, 2] * focal, size[1] / 2 - cam[:, 1] / cam[:, 2] * focal], 1)
    colour = np.full((size[1], size[0], 3), ground, np.uint8)
    depth = np.full((size[1], size[0]), np.inf)
    ys, xs = np.mgrid[0:size[1], 0:size[0]]
    for name, faces in groups.items():
        if name == "glass":
            continue
        for face in faces:
            a, b, c = vertices[face]
            normal = np.cross(c - a, b - a)  # Godot clockwise front
            normal /= np.linalg.norm(normal)
            if normal @ (eye - a) <= 0:
                continue
            shade = .45 + .55 * max(0, normal @ ((eye - a) / np.linalg.norm(eye - a) * .6 + np.array([.2, .75, .2])))
            p, z = screen[face], cam[face, 2]
            x0, x1 = int(max(0, p[:, 0].min())), int(min(size[0] - 1, p[:, 0].max())) + 1
            y0, y1 = int(max(0, p[:, 1].min())), int(min(size[1] - 1, p[:, 1].max())) + 1
            if x0 >= x1 or y0 >= y1:
                continue
            gx, gy = xs[y0:y1, x0:x1] + .5, ys[y0:y1, x0:x1] + .5
            area = (p[1, 0] - p[0, 0]) * (p[2, 1] - p[0, 1]) - (p[2, 0] - p[0, 0]) * (p[1, 1] - p[0, 1])
            w1 = ((gx - p[0, 0]) * (p[2, 1] - p[0, 1]) - (p[2, 0] - p[0, 0]) * (gy - p[0, 1])) / area
            w2 = ((p[1, 0] - p[0, 0]) * (gy - p[0, 1]) - (gx - p[0, 0]) * (p[1, 1] - p[0, 1])) / area
            w0 = 1 - w1 - w2
            zz = w0 * z[0] + w1 * z[1] + w2 * z[2]
            hit = (w0 >= 0) & (w1 >= 0) & (w2 >= 0) & (zz < depth[y0:y1, x0:x1])
            depth[y0:y1, x0:x1][hit] = zz[hit]
            colour[y0:y1, x0:x1][hit] = np.clip(np.array(TONE[name]) * min(shade, 1.15), 0, 255)
    image = Image.fromarray(colour)
    draw = ImageDraw.Draw(image)
    for face in groups.get("glass", []):
        draw.line([tuple(screen[i]) for i in face + face[:1]], fill=(236, 244, 244), width=1)
    return image


def sheet(name, cells):
    height = 960
    images = []
    for label, image in cells:
        image = image.convert("RGB")
        image = image.resize((round(image.width * height / image.height), height))
        ImageDraw.Draw(image).rectangle([0, 0, 9 + 7 * len(label), 16], fill=(0, 0, 0))
        ImageDraw.Draw(image).text((5, 3), label, fill=(255, 255, 255))
        images.append(image)
    out = Image.new("RGB", (sum(i.width for i in images), height), "white")
    x = 0
    for image in images:
        out.paste(image, (x, 0))
        x += image.width
    out.save(HERE / name, quality=90)


def main():
    source = Path(sys.argv[1])
    figure, case = HERE / "seated-woman.obj", HERE / "seated-woman-case.obj"
    mid = (0, .36, 0)
    official = lambda i: Image.open(source / f"modern-candidates-v3/seated-woman-zoom-{i}.jpg")
    native = lambda t, box: Image.open(HERE / f"native-IMG_6387-{t}s.png").crop(box)
    sheet("figure-vs-official.jpg", [
        ("official photograph 1", official(1)),
        ("low polygon, same side", view(figure, (-.35, .62, 1.25), mid, fov=36, ground=(150, 154, 146))),
        ("official photograph 0", official(0)),
        ("low polygon, same side", view(figure, (1.0, .48, .95), mid, fov=36, ground=(88, 88, 92))),
    ])
    sheet("figure-turnaround.jpg", [
        ("front", view(figure, (0, .40, 1.4), mid, fov=34)),
        ("figure's left", view(figure, (1.4, .40, 0), mid, fov=34)),
        ("REAR - not observed", view(figure, (0, .40, -1.4), mid, fov=34)),
        ("figure's right", view(figure, (-1.4, .40, 0), mid, fov=34)),
        ("above front", view(figure, (.5, 1.3, 1.0), mid, fov=34)),
    ])
    sheet("case-vs-native.jpg", [
        ("native IMG_6387 63.5s", native("63.5", (0, 0, 1080, 1920))),
        ("low polygon case, from the south", view(case, (.95, 1.50, .95), (0, 1.02, .30), fov=75)),
        ("native IMG_6387 65.5s", native("65.5", (0, 0, 1080, 1920))),
        ("low polygon case, from the room", view(case, (-.12, 1.52, 1.25), (0, 1.12, .30), fov=75)),
    ])
    sheet("case-far.jpg", [
        ("native IMG_6387 51.25s (crop)", Image.open(source / "lion-modern-native-v1/wide-51.25.png").crop((330, 480, 870, 1200))),
        ("low polygon case, far oblique", view(case, (-2.6, 1.45, 3.4), (0, .95, .3), size=(720, 960), fov=30)),
    ])


if __name__ == "__main__":
    main()
