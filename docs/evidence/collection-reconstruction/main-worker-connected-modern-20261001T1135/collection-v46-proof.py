from pathlib import Path
import json,hashlib
root=Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion');out=root/'lowpoly-room-v46d-landing-modern';app=Path('image-work/collection-room-remodel');g=json.loads((out/'geometry.json').read_text());rooms={r['label']:r for r in g['rooms']};modern=rooms['modern painting gallery'];landing=rooms['lion stair landing']
assert landing['openings']['east']==modern['openings']['west'] and modern['bounds'][2]<landing['openings']['east'][0]<modern['bounds'][3]
assert modern['bounds'][2]<25.1<26<28<30<modern['bounds'][3]
assert landing['floor_void']==[10.55,13.55,32,35.9]
assert set(landing['openings'])=={'west','east','south'}
assert set(modern['openings'])=={'west','east'}
patches={p['label']:p for p in g['patches']};assert 'stairs landing threshold study limit' not in patches
assert max(v[2] for v in patches['landing north floor']['vertices'])==32
assert min(v[0] for v in patches['landing east floor']['vertices'])==13.55
assert max(v[1] for v in patches['ascending stair study']['vertices'])==3.2
assert min(v[1] for v in patches['descending stair study']['vertices'])==-3.2
for source,name in [('braque-still-life','48.248'),('matisse-green-pumpkin','57.037'),('cezanne-banks-river','43.255')]:
 assert (app/'inventory-catalogue'/(source+'-zoom-0.jpg')).read_bytes()==(out/'assets'/('painting-'+name+'.jpg')).read_bytes()
for i,a in enumerate(g['rooms']):
 for b in g['rooms'][i+1:]:
  aa,bb=a['bounds'],b['bounds'];assert min(aa[1],bb[1])-max(aa[0],bb[0])<1e-8 or min(aa[3],bb[3])-max(aa[2],bb[2])<1e-8
m=json.loads((out/'manifest.json').read_text());assert len(m['source_sha256'])==201
for p,h in m['source_sha256'].items():assert hashlib.sha256(Path(p).read_bytes()).hexdigest()==h,p
(out/'evidence/layout-source-proof.json').write_text(json.dumps({'room_shells':len(g['rooms']),'no_plan_overlaps':True,'openings_agree':True,'landing_doors':3,'floor_void_not_capped':True,'flight_ramp_heights_m':[3.2,-3.2],'flight_curve_destinations_accepted':False,'modern_paintings_byte_identical_to_official_images':['48.248','57.037','43.255'],'villon':'Official photograph crop and 48-sided oval; original unmodified retained','retracted_false_match':'41.012 replaced by57.037','prepared_source_hashes_checked':201,'metric_and_placement_accepted':False,'runnable_check':'collection-v46-proof.py'},indent=2)+'\n')
print('Layout/source checks pass;201 hashes verified')
