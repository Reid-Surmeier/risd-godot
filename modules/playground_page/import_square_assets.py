"""Import issue #158's selected snapshot into issue #164's runtime assets."""
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import urllib.request

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
DEST = ROOT / "modules/playground_page/assets/square"
DEST.mkdir(parents=True, exist_ok=True)
arena = json.loads(subprocess.check_output([
    "git", "show", "542f1394:modules/playground_page/prototype-158/arena.json"
], cwd=ROOT))
works = json.loads((ROOT / "docs/evidence/playground-gallery/corpus.json").read_text())["records"]
manifest = []
for item in arena + works:
    if "makers" in item:
        source = ROOT / "docs/evidence/playground-gallery/images" / (item["image"]["sha256"] + ".jpg")
        target = DEST / source.name
        shutil.copyfile(source, target)
        origin = item["image"]["source_url"]
    else:
        target = DEST / (str(item["id"]) + ".jpg")
        origin = item["image"]
        if not target.exists():
            request = urllib.request.Request(origin, headers={"User-Agent": "RISD-Playground/1.0"})
            with urllib.request.urlopen(request, timeout=45) as response:
                target.write_bytes(response.read())
    item["texture"] = "res://modules/playground_page/assets/square/" + target.name
    item["source_width"] = Image.open(target).width
    manifest.append({"file": target.name, "source": origin,
                     "sha256": hashlib.sha256(target.read_bytes()).hexdigest(),
                     "provider": "RISD Museum" if "makers" in item else "Are.na",
                     "cost_usd": 0})
(DEST / "catalog.json").write_text(json.dumps({"arena": arena, "works": works}, ensure_ascii=False, indent=2) + "\n")
(DEST / "provenance.json").write_text(json.dumps(manifest, indent=2) + "\n")
print(f"Imported {len(arena)} public connections and {len(works)} RISD works")
