"""Resize the twelve recorded museum photographs, without fetching or enlarging.

python3 prepare_images.py ~/risd-godot-ingestion/catalogue-masters/impressionist-277
The source hashes, crop rectangles and required sizes live in catalogue.json.
Packed images keep their module paths in both the app and standalone room project.
"""
import hashlib
import json
from pathlib import Path
import sys

from PIL import Image

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
MASTERS = Path(sys.argv[1]).expanduser()
RECORDS = HERE / "catalogue.json"
records = json.loads(RECORDS.read_text())
assert len(records) == 12
template = (ROOT / "modules/shell/collection_rooms/assets/details/34.016-preview.jpg.import").read_text()


def write_import(output):
    resource = "res://" + str(output.relative_to(ROOT))
    imported = "res://.godot/imported/" + output.name + "-" + hashlib.md5(resource.encode()).hexdigest() + ".ctex"
    metadata = Path(str(output) + ".import")
    previous = metadata.read_text() if metadata.exists() else ""
    uid = next((line + "\n" for line in previous.splitlines() if line.startswith("uid=")), "")
    settings = template.replace('uid="uid://b1jkxo4cyw23d"\n', uid)
    settings = settings.replace("res://modules/shell/collection_rooms/assets/details/34.016-preview.jpg", resource)
    settings = settings.replace("res://.godot/imported/34.016-preview.jpg-958a5d9471445ae5a25cb9175b5bdc29.ctex", imported)
    settings = settings.replace("mipmaps/generate=false", "mipmaps/generate=true")
    metadata.write_text(settings)

for accession, record in records.items():
    policy = record["image_resolution"]
    master = MASTERS / (accession + "-source.jpg")
    assert hashlib.sha256(master.read_bytes()).hexdigest() == policy["source_sha256"], accession
    with Image.open(master) as photograph:
        assert list(photograph.size) == policy["source_pixels"], accession
        image = photograph.convert("RGB").crop(policy["crop_px"])
    assert image.width > 0 and image.height > 0
    for role, specification in policy["images"].items():
        output = ROOT / specification["path"]
        output.parent.mkdir(parents=True, exist_ok=True)
        copy = image.copy()
        side = specification["required_long_side"]
        copy.thumbnail((side, side), Image.Resampling.LANCZOS)
        assert max(copy.size) == min(side, max(image.size)), (accession, role, copy.size)
        copy.save(output, quality=92 if role == "zoom_external" else 95, optimize=True)
        specification["pixels"] = list(copy.size)
        specification["sha256"] = hashlib.sha256(output.read_bytes()).hexdigest()
        if role == "zoom_external":
            assert (output.parent / ".gdignore").exists()
            continue
        write_import(output)

RECORDS.write_text(json.dumps(records, indent=2, ensure_ascii=False) + "\n")
print("Prepared 12 works / 36 images; source hashes and sizes match; no upscaling")


# Numerical palette copies of the unchanged W7 carving, not new painting images.
# Use the stock PS1 material so remodel_bake.gd preserves the colour and work shading.
palette_file = HERE / "frame-palettes.json"
palettes = json.loads(palette_file.read_text())
linear = [v / 255 / 12.92 if v / 255 <= .04045 else ((v / 255 + .055) / 1.055) ** 2.4 for v in range(256)]

def srgb(v):
    v = 12.92 * v if v <= .0031308 else 1.055 * v ** (1 / 2.4) - .055
    return round(max(0, min(1, v)) * 255)

for key, specification in palettes.items():
    source = ROOT / specification["source"]
    assert hashlib.sha256(source.read_bytes()).hexdigest() == specification["source_sha256"]
    image = Image.open(source).convert("RGBA")
    assert list(image.size) == specification["pixels"]
    chroma, lift = specification["chroma"], specification["lift"]
    pixels = []
    for red, green, blue, alpha in image.getdata():
        rgb = [linear[red], linear[green], linear[blue]]
        grey = sum(a * b for a, b in zip(rgb, [.2126, .7152, .0722]))
        pixels.append(tuple(srgb(((1 - chroma) * grey + chroma * value) * (1 - lift) + .5 * lift) for value in rgb) + (alpha,))
    image.putdata(pixels)
    output = ROOT / specification["path"]
    image.save(output, optimize=True)
    specification["sha256"] = hashlib.sha256(output.read_bytes()).hexdigest()
    write_import(output)
palette_file.write_text(json.dumps(palettes, indent=2) + "\n")
print("Prepared two frame palette copies; source dimensions/carving/alpha kept; colours changed without AI generation")
