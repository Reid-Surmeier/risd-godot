"""Assert the candidate's native Godot planar contact and exact-period gates ($0)."""
from pathlib import Path
import json,tempfile,shutil,subprocess,hashlib,sys
HERE=Path(__file__).resolve().parent
DEST=Path(sys.argv[1]).resolve() if len(sys.argv)>1 else HERE
reference='--reference' in sys.argv
assert DEST.is_relative_to(HERE.parent)
SOURCE=DEST/'footplant-candidate.glb'
REPORT=json.loads((DEST/'correction.json').read_text())
results={}
for kind in ['idle','walk']:
 with tempfile.TemporaryDirectory(prefix='contact-validation-') as scratch:
  p=Path(scratch);shutil.copy2(SOURCE,p/'target.glb')
  code=(HERE/'probe.gd').read_text().replace('player.get_animation("walk")',f'player.get_animation("{kind}")')
  # Measure exactly rigid Foot vertices; mixed upper-shoe/leg weights are separate deformation evidence.
  code=code.replace('if name==side+"Foot" or name==side+"ToeBase"','if name==side+"Foot"').replace('if weights[side]>.5','if weights[side]>.9999').replace('var epsilon=length/32.0','var epsilon=0.001')
  code=code.replace('vertices with >50% total Foot+ToeBase weight','vertices with >99.99% Foot weight')
  (p/'probe.gd').write_text(code)
  (p/'project.godot').write_text('[application]\nconfig/name="Throwaway contact assertions"\n[rendering]\nrenderer/rendering_method="gl_compatibility"\n')
  dest=DEST/'candidate-proof';dest.mkdir(exist_ok=True)
  for name,args in [('import',['--editor','--import','--quit']),('reimport',['--editor','--import','--quit']),('probe',['--script','res://probe.gd'])]:
   if name=='reimport':
    metadata=p/'target.glb.import'
    text=metadata.read_text().replace('_subresources={}', '_subresources={"nodes": {"PATH:AnimationPlayer": {"optimizer/enabled": false}}}')
    if reference:text=text.replace('animation/fps=30','animation/fps='+str(REPORT['bake_fps']))
    metadata.write_text(text)
    cache=p/'.godot/imported'
    for asset in cache.glob('target.glb-*'):asset.unlink()
   with (dest/f'{kind}-{name}.log').open('w') as log:
    subprocess.run(['/home/reidsurmeier/bin/godot','--headless','--path',scratch,*args],stdout=log,stderr=subprocess.STDOUT,timeout=60,check=True)
  shutil.copy2(p/'target.glb.import',dest/f'{kind}-target.glb.import')
  evidence=json.loads((p/'evidence.json').read_text());evidence['source_sha256']=hashlib.sha256(SOURCE.read_bytes()).hexdigest()
  (dest/f'{kind}.json').write_text(json.dumps(evidence,indent=2)+'\n')
  assert evidence['bones']==24
  assert abs(evidence['seconds']-(REPORT['walk_period_seconds'] if kind=='walk' else REPORT.get('idle_period_seconds',121/30)))<1e-6
  assert evidence['seam']['maximum_vertex_displacement_m']<.001
  convergence=evidence['velocity_convergence']
  if reference:
   floors=[s['feet'][side]['min'][1] for s in evidence['samples'] for side in ['Left','Right']]
   penetration=max(0,-min(floors))
   assert penetration<.001,(kind,'dense-floor-penetration',penetration)
   event_floors={}
   if kind=='walk':
    contacts=[]
    for index in [0,128]:
     sample=evidence['samples'][index]
     side=min(['Left','Right'],key=lambda side:sample['feet'][side]['min'][1])
     event_floors[side]=sample['feet'][side]['min'][1]
     contacts.append({'time':sample['time'],'foot':side})
    assert len(event_floors)==2 and max(abs(y) for y in event_floors.values())<.001,('event-floor',event_floors)
   results[kind]={'seconds':evidence['seconds'],'sample_count':257,'endpoint_vertex_error_max_m':evidence['seam']['maximum_vertex_displacement_m'],'floor_penetration_max_m':penetration,'authored_event_sole_height_m':event_floors,'velocity_convergence':convergence,'planar_stance_lock_verified':False}
   continue
  if kind=='idle':
   assert max(v['maximum_joint_velocity_jump_mps'] for v in convergence)<.002,('idle-tangent',convergence)
  else:
   assert convergence[-1]['maximum_joint_velocity_jump_mps']<convergence[0]['maximum_joint_velocity_jump_mps']*.1,('walk-tangent-convergence',convergence)
  deviations=[];slips=[]
  for side,offset in [('Left',.25),('Right',.75)]:
   samples=evidence['samples']
   if kind=='idle':segments=[samples]
   elif side=='Left':segments=[[s for s in samples if .25<=s['time']/evidence['seconds']<.75]]
   else:
    # One full right stance straddles the wrap. Unwrap next-cycle times to test an identical world anchor.
    segment=[s for s in samples if s['time']/evidence['seconds']>=.75]
    segment += [dict(s,time=s['time']+evidence['seconds']) for s in samples if s['time']/evidence['seconds']<.25]
    segments=[segment]
   for segment in segments:
    deviations += [abs(s['feet'][side]['min'][1]) for s in segment]
    worldz=[s['feet'][side]['centroid'][2]+(REPORT['controller_speed_mps']*s['time'] if kind=='walk' else 0) for s in segment]
    worldx=[s['feet'][side]['centroid'][0] for s in segment]
    slips.append(max(worldz)-min(worldz));slips.append(max(worldx)-min(worldx))
  max_floor=max(deviations);max_slip=max(slips)
  assert max_floor<.001,(kind,'stance-floor',max_floor)
  assert max_slip<.001,(kind,'stance-slip',max_slip)
  results[kind]={'seconds':evidence['seconds'],'sample_count':257,'stance_floor_error_max_m':max_floor,'stance_xz_drift_max_m':max_slip,'endpoint_vertex_error_max_m':evidence['seam']['maximum_vertex_displacement_m'],'one_millisecond_velocity_jump_max_mps':max(s['velocity_jump_mps'] for s in evidence['seam']['one_sided_velocities']),'planar_contact_gate':'PASS','visual_acceptance':'pending'}
length=REPORT['walk_period_seconds']
manifest={'source_sha256':REPORT['source_sha256'],'candidate_sha256':hashlib.sha256(SOURCE.read_bytes()).hexdigest(),'bones':24,'period_seconds':length,'controller_speed_mps':REPORT['controller_speed_mps'],'contacts':[{'time':length*.25,'foot':'Left'},{'time':length*.75,'foot':'Right'}],'sampled_planar_contact_verified':True,'terrain_turning_blending_verified':False,'idle_event_count_expected':0,'walk_events_per_loop_expected':2,'contact_probe':results,'cost_usd':0}
if reference:
 manifest.update(contacts=contacts,sampled_planar_contact_verified=False,source_reference_mode=True,import_fps=REPORT['bake_fps'],contact_assignment='target minimum sole at phases0/.5; this may differ from source side labels')
(DEST/'contact-manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
print(json.dumps(manifest,indent=2))
