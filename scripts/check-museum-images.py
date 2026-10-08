#!/usr/bin/env python3
"""Keep registered catalogue images at their measured wall/zoom sizes (#278)."""
import hashlib
import json
from pathlib import Path
import sys
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
REGISTRIES = (
    ROOT / 'modules/shell/prototype/gallery_walk4/works.json',
    ROOT / 'modules/shell/collection_rooms/objects.json',
)

def check_images():
    failures = []
    works = files = 0
    for registry in REGISTRIES:
        records = json.loads(registry.read_text())
        if isinstance(records, dict):
            records = [dict(work, tag=key) for key, work in records.items()]
        for work in records:
            policy = work.get('image_resolution')
            if not policy:
                if registry.name == "works.json":
                    failures.append(f"{work['tag']}: missing image resolution record")
                continue
            works += 1
            source_long = max(policy['original_pixels'])
            for role, image in policy['images'].items():
                files += 1
                path = ROOT / image['path']
                try:
                    with Image.open(path) as photograph:
                        size = photograph.size
                    required = min(image['required_long_side'], source_long)
                    if max(size) < required:
                        failures.append(f"{work['tag']} {role}: {size}, needs {required} px; original {source_long} px")
                    if hashlib.sha256(path.read_bytes()).hexdigest() != image['sha256']:
                        failures.append(f"{work['tag']} {role}: photograph hash differs from its source record")
                    runtime_picture = role == 'zoom' or (role == 'detail' and registry.name == 'objects.json')
                    if runtime_picture and work.get('image') != 'res://' + image['path']:
                        failures.append(f"{work['tag']} zoom: runtime path differs from its source record")
                    if role == 'zoom_external':
                        if not (path.parent / '.gdignore').exists():
                            failures.append(f"{work['tag']} zoom: missing .gdignore; full photograph would enter the pack")
                        if work.get('zoom_image') != 'res://' + image['path']:
                            failures.append(f"{work['tag']} zoom: runtime path differs from its source record")
                    else:
                        settings = Path(str(path) + '.import').read_text()
                        if 'compress/mode=1\n' not in settings or 'compress/lossy_quality=0.8\n' not in settings:
                            failures.append(f"{work['tag']} {role}: needs lossy import at quality 0.8")
                except (OSError, ValueError) as error:
                    failures.append(f"{work['tag']} {role}: {error}")
    for failure in failures:
        print('FAIL museum image:', failure)
    print(f"museum images: {works} works, {files} images, {len(failures)} failures")
    return 1 if failures else 0

if __name__ == '__main__':
    sys.exit(check_images())
