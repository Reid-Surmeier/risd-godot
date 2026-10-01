from pathlib import Path
import json,hashlib,shutil,tarfile,re,subprocess
app=Path('image-work/collection-room-remodel');root=Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion');out=root/'lowpoly-room-v47c-lion-plaster';e=Path('docs/evidence/collection-reconstruction/main-worker-lion-plaster-20261001T1220')
assert 'BAKE_OK users=1486' in Path('/tmp/collection-v47c-bake.log').read_text()
b=json.loads((out/'evidence/browser-result.json').read_text());assert b['pass'] and not b['errors'] and len(b['engine']['checks'])==174
s=Path('/tmp/collection-v47c-shell-repeat.log').read_text();passed=len(re.findall('^PASS ',s,re.M));fails=re.findall('^FAIL .*',s,re.M);assert passed==46 and len(fails)==4
assert 'checks passed' in Path('/tmp/collection-v47c-check.log').read_text()
subprocess.run(['python3','/tmp/collection-v47-proof.py'],check=True)
e.mkdir(exist_ok=False)
for name,run in [('lion-panel','run-49b57942e799e34216bc2687'),('landing-plaster','run-20fa6fddf9fc645f616f8335')]:
 for suffix in ['prompt.txt','plan.json','recipe.json','prepared.json','planned.json','receipt.json','review.json']:shutil.copyfile(app/(name+'-'+suffix),e/(name+'-'+suffix))
 shutil.copyfile(app/'trial'/(name+'-original.webp'),e/(name+'-original.webp'))
 with tarfile.open(e/(name+'-run.tar.gz'),'w:gz') as a:a.add(app/'artifacts/image-generation/runs'/run,arcname=run)
for n in ['lion-panel-official.png','landing-plaster-video-native.png','landing-plaster-style-main-hall.png']:shutil.copyfile(app/'inventory-references'/n,e/n)
for n in ['striding-lion.json','striding-lion-zoom-0.jpg','fauconnier-mountaineers.json','fauconnier-mountaineers-zoom-0.jpg']:shutil.copyfile(app/'inventory-catalogue'/n,e/n)
for n in ['landing-lion-front.png','landing-lion-oblique.png','landing-lion-wide.png','landing-modern-door.png','landing-stair-void.png','landing-walk.png','modern-entry-wide.png','modern-windows-wide.png','modern-walk.png','hall-wide-arch.png','browser-result.json','lion-installed-position.json','lion-source-proof.json','ceiling-visibility.json']:shutil.copyfile(out/'evidence'/n,e/n)
for p in (out/'evidence').glob('browser*.png'):shutil.copyfile(p,e/p.name)
previous=Path('docs/evidence/collection-reconstruction/main-worker-connected-modern-20261001T1135')
shutil.copyfile(previous/'modern-entry-wide.png',e/'v46-modern-entry-wide.png')
shutil.copyfile(root/'lowpoly-room-v47b-lion-plaster/evidence/landing-lion-wide.png',e/'v47b-lion-floating-before-fix.png')
for n in ['36.25','42.25','80.25']:shutil.copyfile(previous/('wide-'+n+'-source.jpg'),e/('wide-'+n+'-source.jpg'))
for n in ['manifest.json','geometry.json']:shutil.copyfile(out/n,e/n)
for p in Path('/tmp').glob('collection-v47*.log'):shutil.copyfile(p,e/p.name)
for n in ['collection-v47-proof.py','collection-v47c-final-checks.py','collection-v47c-browser-with-server.py','collection-v41-bake.py','collection-v47-large-painting-api.py','collection-v47-more-painting-api.py','collection-v47-battle-painting-api.py','collection-v47-fauconnier-api.py','collection-v47-issues-live.json','collection-v47-worktree-ps.json','collection-v47-pipeline-identity.json','collection-v47-automations.json','collection-v47-worktree-final-ps.json','collection-publish-v47.py','collection-stage-v47.py']:shutil.copyfile(Path('/tmp')/n,e/n)
for n in ['prepare_remodel.py','remodel_room.gd','remodel_review.gd','remodel_bake.gd']:shutil.copyfile(Path('modules/shell/prototype/collection_reconstruction')/n,e/(n+'.txt'))
for v in ['v4','v5','v6','v7']:shutil.copytree(root/('modern-candidates-'+v),e/('modern-candidates-'+v))
with tarfile.open(e/'shell-film.tar.gz','w:gz') as a:a.add('/tmp/collection-v47c-shell-repeat',arcname='shell-playtest');a.add('/tmp/collection-v47c-shell-first',arcname='shell-first')
next_action='Generate/capture Duchamp-Villon Seated Woman67.089 and its case from inspected catalogue/video; install verified Le Fauconnier Mountaineers1995.043 with source frame and dedicate Matisse/Villon frame passes; verify landing roof/stair void, source stair curve/rails/destinations and held-out room/object offsets; continue remaining rooms, case contents and auditorium.'
entry=f'''\n### Collection v47 — source-protected lion and Muse plaster (2026-10-01 12:20 UTC)\n\nCollection-only prototype, issues178/181/182/183; sole main worker,heartbeat disabled. Reviewed native6387 reciprocal wides: lion between modern door and adjacent corner. Installed original RISD34.652 front at catalogue2.286x1.041m with inferred.08m closed slab,8vertices/12triangles/18pairededges. Original JPEG byte-identical; atlas front exactly equals deterministic resized source,zerochangedpixels. First native trial caught existing catalogue group's-1.95m shift leaving lion floating; authorx18.02 compensates,actualdrawn world(16.07,1.18,33.15),yaw-PI/2 independently asserted. Bracket/lips/vent inferred. Exact metres/offsets,individualbrickrelief and slabdepth remain unaccepted.\n\nTwo OpenRouter meta/muse-image outputs,$0.01 each. Lion run-49b57942e799e34216bc2687,nativeSHA2564db83425d72b5a349276c11644efb5720f111740b7ba408af2f7e8584257a3c8; generatedaspect1.4596versuscatalogue2.196,cracks/erodeddamagealtered,frontREJECTED,no blindretry. Official front protected; Museochreswatch only supplies inferred sides/back. Plaster run-20fa6fddf9fc645f616f8335,nativeSHA256c58b89f37f64f619bb4e97975f97241a32c360e7a120c72b0040958bfa059bad; quiet warmgrey wallstudy with existing.15contrast/mirrorededges,only landing/modern walls. Full sourcecolour/facetfidelity unaccepted. MainHall23artworks/lighting retained. Modern fourpainting spotenergy5to1.2/angle28to40; baked native pools visibly reduced.70outputs plus prior$0.11:$0.81actual/$0.82conservative. Nativeoriginals,prompts,refs,receipts/fullrunarchives retained; failedheads/Apostlesdamage/ambiguousriverdeities unchanged.\n\n1486native surfaces baked CPUVulkanfallback in5m53.93s,rendererrestored; finalRTXfront/oblique/wide/walking inspected. Chrome174/174,keyboardroundtrip/33loopsegments,p95{b['engine']['frame_time_p95_ms']:.3f}ms,errors[]. Three existing opaqueceilings followcutaway; landingroofaroundstairvoid remains missing. OwningShell46/50,4priorfailures/fullfilm archived. First45/50 had one additional pressed-animationtimingfailure; repeated afterbrowserclosed,bothfilms/logs retained. scripts/check.sh/gitdiffcheck pass;205preparedsourcehashes and50originalpendinghashes verified,21originalPROVENANCElines remain unstaged. Fullnative60fps/metricgeometry unverified.\n\nNext: {next_action} Large painting independently matched to Le Fauconnier Mountaineers Attacked by Bears1995.043,RISD API1557106,dimensions239.6x305.4x4.4cm using official photograph and native80.25s; original/API archived, installation next. Other research first-page queries do not prove absence. No externalblocker; allobjects/fullmap unfinished. Viewer/frozenseams untouched,no productionintegration/ticketclosure. Evidence `{e}/`.\n'''
entry_path=Path('/tmp/collection-provenance-lion-plaster-entry.md');assert not entry_path.exists();entry_path.write_text(entry)
prov=Path('modules/shell/PROVENANCE.md');prov.write_text(prov.read_text()+entry)
head=subprocess.check_output(['git','show','HEAD:modules/shell/PROVENANCE.md'],text=True);Path('/tmp/collection-v47-staged-provenance.md').write_text(head+entry)
inventory=json.loads((app/'hall-stairs-inventory.json').read_text());landing=inventory['rooms']['lion_stair_landing'];lion=next(x for x in landing['groups'] if x['id']=='blue-brick-lion');lion['status']='Original museum front installed; Muse generated front rejected for aspect/damage; inferred side/back and slab depth unaccepted';landing['layout_v47']={'installed_world_position':[16.07,1.18,33.15],'lion_front_original':True,'lion_brick_relief_complete':False,'new_muse_plaster':True,'vent_bracket_studies':True,'metric_accepted':False,'missing_objects':['chair rack'],'landing_roof_complete':False}
modern=inventory['rooms']['modern_painting_gallery'];modern['large_painting_v47']={'accession':'1995.043','title':'Mountaineers Attacked by Bears','maker':'Henri Victor Gabriel Le Fauconnier','catalogue_id':'1557106','source_match_verified':True,'installed':False,'dimensions_cm':[239.6,305.4,4.4],'record_file':'inventory-catalogue/fauconnier-mountaineers.json'};modern['lighting_v47']='Four painting spots energy1.2,angle40; pools reduced in inspected bake, exact source intensity unaccepted'
(app/'hall-stairs-inventory.json').write_text(json.dumps(inventory,indent=2)+'\n')
coverage=json.loads((app/'reconstruction-coverage.json').read_text());coverage['lion_plaster_v47']={'official_lion_front_installed':True,'generated_lion_front_accepted':False,'individual_brick_relief_complete':False,'metric_accepted':False,'muse_runs':['run-49b57942e799e34216bc2687','run-20fa6fddf9fc645f616f8335'],'paid_outputs':2,'cost_this_pass_usd':'0.02','cumulative_actual_usd':'0.81','cumulative_conservative_usd':'0.82','prepared_sources':205,'baked_surfaces':1486,'browser_checks':174,'browser_errors':[],'browser_frame_p95_ms':b['engine']['frame_time_p95_ms'],'shell_passed':46,'shell_total':50,'all_objects_complete':False,'evidence':str(e),'next':next_action};(app/'reconstruction-coverage.json').write_text(json.dumps(coverage,indent=2)+'\n')
(e/'CHECKPOINT.md').write_text(f'# Collection checkpoint — 2026-10-01 12:20 UTC\n\n'+entry.split('\n\n',1)[1]+'\nOwning Shell retained failures:\n\n'+ '\n'.join(fails)+'\n\nhttps://windows-wsl.taile06c45.ts.net/risd-frame-review-01a0ee18/progress/\n')
original=json.loads(Path('/tmp/collection-inventory-pending-before.json').read_text())
names=['lion-plaster','connected-modern','stair-wall','iron-grille','ceilings','gabled','panels','loop','perugino','bertin','cases','european-door','wide-scale','ionic','grey','full-survey','sculpture-layout','gallery','wide','inventory']
for p,h in original.items():
 data=Path(p).read_bytes()
 if p=='modules/shell/PROVENANCE.md':
  for n in names:
   tail=(Path('/tmp')/('collection-provenance-'+n+'-entry.md')).read_bytes();assert data.endswith(tail),n;data=data[:-len(tail)]
 assert hashlib.sha256(data).hexdigest()==h,p
(e/'pending-preservation.json').write_text(json.dumps({'original_paths':50,'original_hashes_match':True,'provenance_original_lines_unstaged':21},indent=2)+'\n')
# Keep verbatim text in an archive; review copies omit trailing whitespace for git checks.
with tarfile.open(e/'raw-text-records.tar.gz','w:gz') as a:
 for p in e.rglob('*'):
  if p.is_file() and p.suffix in ['.log','.html']:a.add(p,arcname=str(p.relative_to(e)))
for p in e.rglob('*'):
 if p.is_file() and p.suffix in ['.log','.html','.md']:
  text=p.read_text();p.write_text('\n'.join(line.rstrip() for line in text.splitlines())+'\n')
(e/'SHA256.json').write_text(json.dumps({str(p.relative_to(e)):hashlib.sha256(p.read_bytes()).hexdigest() for p in e.rglob('*') if p.is_file() and p.name!='SHA256.json'},indent=2)+'\n')
print('Checkpointed',e)
