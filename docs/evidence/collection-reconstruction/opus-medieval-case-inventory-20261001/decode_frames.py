"""CPU-decode selected native IMG_6382 frames (no GPU), upright as root's transpose=clock; records command + PNG sha256.
The ~10 MB PNG is then replaced by a quality-95 JPEG viewing copy; rerun the recorded command to reproduce the hashed PNG."""
import hashlib, json, subprocess, sys
from PIL import Image
from pathlib import Path
V = '/home/reidsurmeier/risd-godot-ingestion/collection-expansion/verified/IMG_6382.MOV'
out = Path(__file__).parent / 'frames'; man = {'video': V, 'video_sha256': hashlib.sha256(open(V, 'rb').read()).hexdigest(), 'cuda_decode': False, 'frames': []}
for t in sys.argv[1:]:
    p = out / f'IMG_6382-{float(t):06.2f}.png'
    cmd = ['ffmpeg', '-v', 'error', '-y', '-hwaccel', 'none', '-noautorotate', '-ss', t, '-i', V, '-frames:v', '1', '-vf', 'transpose=clock', '-update', '1', str(p)]
    subprocess.run(cmd, check=True)
    j = p.with_suffix('.jpg'); Image.open(p).save(j, quality=95)
    man['frames'].append({'seconds': float(t), 'png_sha256': hashlib.sha256(p.read_bytes()).hexdigest(), 'command': cmd, 'kept_file': j.name, 'kept_sha256': hashlib.sha256(j.read_bytes()).hexdigest()})
    p.unlink()
(out / 'manifest.json').write_text(json.dumps(man, indent=1) + '\n')
print(man['video_sha256'], len(man['frames']))
