"""Run with python3 check.py. No Blender or paid services required."""
import json, struct, hashlib, sys
from pathlib import Path
from PIL import Image, ImageChops

HERE=Path(__file__).resolve().parent
SOURCE=HERE.parents[1]/'target-baked-normalized-idle.glb'
RESOLUTION=1024 if '--resolution1024' in sys.argv else 512
if RESOLUTION==1024:HERE=HERE/'atlas1024'
def load(path):
    b=path.read_bytes();n=struct.unpack_from('<I',b,12)[0]
    j=json.loads(b[20:20+n]);start=20+n
    return b,j,b[start+8:start+8+struct.unpack_from('<I',b,start)[0]]
source,j,bin_source=load(SOURCE)
out,k,bin_out=load(HERE/'face-projection.glb')
assert bin_out[:len(bin_source)]==bin_source,'Original accessor bytes changed'
for key in ['meshes','accessors','nodes','skins','animations','textures','materials']:
    assert j[key]==k[key],key+' changed'
assert j['bufferViews']==k['bufferViews'][:-1]
assert len(k['animations'])==4 and len(k['skins'][0]['joints'])==24
assert sum(j['accessors'][p['indices']]['count']//3 for m in j['meshes'] for p in m['primitives'])==7719
report=json.loads((HERE/'report.json').read_text())
assert hashlib.sha256(source).hexdigest()==report['source_sha256']
assert hashlib.sha256(out).hexdigest()==report['output_sha256']
a=Image.open(HERE/f'before-atlas{RESOLUTION}.png').convert('RGBA')
b=Image.open(HERE/f'projected-albedo{RESOLUTION}.png').convert('RGBA')
mask=Image.open(HERE/f'uv-coverage{RESOLUTION}.png').convert('RGB')
pixels=list(a.getdata());after=list(b.getdata());coverage=list(mask.getdata())
assert a.size==b.size==(RESOLUTION,RESOLUTION)
changed=0;untouched=0
for old,new,m in zip(pixels,after,coverage):
    changed+=old!=new
    if m==(0,0,0):assert old==new;untouched+=1
assert changed>100 and untouched>RESOLUTION*RESOLUTION*.75
assert ImageChops.difference(Image.open(HERE/'before-back.png').convert('RGB'),Image.open(HERE/'after-back.png').convert('RGB')).getbbox() is None
print(json.dumps({'pass':True,'triangles':7719,'bones':24,'clips':4,
 'original_geometry_uv_skin_animation_bytes_identical':True,'back_render_pixels_identical':True,
 'changed_encoded_atlas_pixels':changed,'zero_coverage_atlas_pixels_unchanged':untouched}))
