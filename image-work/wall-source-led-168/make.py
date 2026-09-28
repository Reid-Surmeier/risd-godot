"""Rebuild the #168 quiet wall tile from the recorded Muse wall pass."""
from pathlib import Path
from PIL import Image
import hashlib

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "modules/shell/prototype/gallery_walk4/textures/wall-muse.webp"
OUTPUT = ROOT / "modules/shell/prototype/gallery_walk4/textures/wall-source-led-168.png"
assert hashlib.sha256(SOURCE.read_bytes()).hexdigest() == "f3191776008e78ab6a3306fa164bf10b91af1a4ed43a2ac621e1cc95f8b68f36"

source = Image.open(SOURCE).convert("RGB").resize((256, 256), Image.Resampling.LANCZOS)
pixels = list(source.getdata())
mean = [sum(p[i] for p in pixels) / len(pixels) for i in range(3)]
# Match the already reviewed wall's average colour while retaining documented
# Muse pigment variation at a quiet level. No pixels from wall.png are sampled.
target = (82.5, 90.5, 98.5)
result = Image.new("RGB", source.size)
result.putdata([tuple(max(0, min(255, round(target[i] + 0.4 * (p[i] - mean[i])))) for i in range(3)) for p in pixels])
result.save(OUTPUT)
print(hashlib.sha256(OUTPUT.read_bytes()).hexdigest())
