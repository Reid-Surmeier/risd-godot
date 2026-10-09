from pathlib import Path
from collections import Counter
from PIL import Image
import json,hashlib,numpy as np
app=Path('image-work/collection-room-remodel');root=Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion/lowpoly-room-v47c-lion-plaster');m=json.loads((root/'manifest.json').read_text());assert len(m['source_sha256'])==205
for p,h in m['source_sha256'].items():assert hashlib.sha256(Path(p).read_bytes()).hexdigest()==h,p
source=app/'inventory-catalogue/striding-lion-zoom-0.jpg';assert source.read_bytes()==(root/'assets/lion-panel-official.jpg').read_bytes()
a=np.array(Image.open(root/'assets/lion-panel-volume.png'));ref=np.array(Image.open(source).convert('RGB').resize((1024,1024)));assert np.array_equal(a[:,:1024],ref)
j=json.loads((root/'assets/catalogue-objects.json').read_text());lion=j['meshes']['lion-panel'];v=np.array(lion['vertices']);t=lion['triangles'];edges=Counter(tuple(sorted((q[i],q[(i+1)%3]))) for q in t for i in range(3));assert len(t)==12 and len(edges)==18 and all(n==2 for n in edges.values())
volume=sum(np.dot(v[q[0]],np.cross(v[q[1]],v[q[2]])) for q in t)/6;assert abs(volume-2.286*1.041*.08)<1e-8
pos=json.loads((root/'evidence/lion-installed-position.json').read_text());assert np.allclose(pos['position'],[16.07,1.18,33.15],atol=.00001)
geometry=json.loads((root/'geometry.json').read_text());landing=next(x for x in geometry['rooms'] if x['label']=='lion stair landing');assert landing['openings']['east'][1]<33.15-2.446/2 and 33.15+2.446/2<landing['bounds'][3]
wall=np.array(Image.open(root/'presentation/landing-plaster.png'));assert np.array_equal(wall[0],wall[-1]) and np.array_equal(wall[:,0],wall[:,-1])
review=json.loads((app/'lion-panel-review.json').read_text());assert not review['accepted'] and not review['exact_aspect_preserved'] and not review['exact_damage_layout_preserved']
(root/'evidence/lion-source-proof.json').write_text(json.dumps({'prepared_sources':205,'source_hashes_match':True,'original_jpeg_byte_identical':True,'source_front_atlas_changed_pixels':int(np.any(a[:,:1024]!=ref,axis=2).sum()),'closed_slab_triangles':len(t),'paired_edges':len(edges),'signed_volume_m3':volume,'installed_position':pos['position'],'correct_wall_after_group_shift':True,'frame_between_door_and_corner':True,'wall_texture_edges_identical':True,'individual_brick_relief_complete':False,'depth_placement_metric_accepted':False,'generated_damage_accepted':False,'runnable_check':'collection-v47-proof.py'},indent=2)+'\n')
print('205 source hashes, original front, closed slab, world position and seamless wall edges verified')
