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
        resource = "res://" + specification["path"]
        imported = "res://.godot/imported/" + output.name + "-" + hashlib.md5(resource.encode()).hexdigest() + ".ctex"
        settings = template.replace('uid="uid://b1jkxo4cyw23d"\n', "")
        settings = settings.replace("res://modules/shell/collection_rooms/assets/details/34.016-preview.jpg", resource)
        settings = settings.replace("res://.godot/imported/34.016-preview.jpg-958a5d9471445ae5a25cb9175b5bdc29.ctex", imported)
        settings = settings.replace("mipmaps/generate=false", "mipmaps/generate=true")
        Path(str(output) + ".import").write_text(settings)

RECORDS.write_text(json.dumps(records, indent=2, ensure_ascii=False) + "\n")
print("Prepared 12 works / 36 images; source hashes and sizes match; no upscaling")
