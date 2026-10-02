"""Writes the two proposed Muse frame plans (not executed) and SHA256.json for every file in this folder.

python3 seal.py   Run last. Nothing here calls a provider.
"""
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).parent
VIDEO = "8cfd089e769000369419f577f28a1bfc68b09f8cc7cda4cbe93d840194e6eeef"  # IMG_6383.MOV, checked before decoding


def sha(path):
    return hashlib.sha256((HERE / path).read_bytes()).hexdigest()


# Root's own plan shape (image-work/collection-room-remodel/*-frame-plan.json). Paths are relative to this folder.
for name, size, inputs in [
    ("cleric", "1280x1760", ["muse-reference/cleric-frame-native-49.80-straightened.png", "muse-reference/cleric-frame-native-49.80.png", "muse-reference/cleric-frame-native-41.20.png"]),
    ("woman", "1216x1760", ["textures/portrait-woman-34861-zoom-0.jpg", "muse-reference/woman-frame-native-46.40.png", "muse-reference/woman-frame-native-41.20.png"]),
]:
    prompt = "muse-reference/%s-frame-prompt.proposed.txt" % name
    plan = {"status": "proposed by a worker; not executed; no request made", "attempts": [{"id": "%s-frame-001" % name, "prompt": prompt, "promptSha256": sha(prompt),
        "size": size, "inputs": [{"path": p, "sha256": sha(p)} for p in inputs]}]}
    (HERE / ("muse-reference/%s-frame-plan.proposed.json" % name)).write_text(json.dumps(plan, indent=2) + "\n")

files = sorted(str(p.relative_to(HERE)) for p in HERE.rglob("*") if p.is_file() and p.name != "SHA256.json" and "__pycache__" not in p.parts)
out = {"source_video": {"file": "IMG_6383.MOV", "sha256": VIDEO, "read_only": True}, "files": {f: sha(f) for f in files}}
(HERE / "SHA256.json").write_text(json.dumps(out, indent=1) + "\n")
print(len(files), "files hashed")
