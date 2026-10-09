from pathlib import Path
from datetime import datetime,timezone
import json,hashlib,shutil,subprocess,tarfile,re
from PIL import Image
app=Path('image-work/collection-room-remodel');root=Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion');out=root/'lowpoly-room-v46d-landing-modern';e=Path('docs/evidence/collection-reconstruction/main-worker-connected-modern-20261001T1135')
def read(p):return json.loads(p.read_text())
def write(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
b=read(out/'evidence/browser-result.json');assert b['pass'] and b['errors']==[] and len(b['engine']['checks'])==174 and all(b['engine']['checks'].values()) and 'NVIDIA' in b['webgl_renderer']
assert len([x for x in b['engine']['samples'] if x['trial'].startswith('loop_')])==33
for name in ['landing_to_modern','modern_to_landing','landing_white_out','landing_white_back','modern_far_opening_out','modern_far_opening_back','modern_bench_blocked','landing_guard_blocked']:assert b['engine']['checks'][name]
shell=Path('/tmp/collection-v46d-shell-repeat.log').read_text();passed=len(re.findall('^PASS ',shell,re.M));failed=len(re.findall('^FAIL ',shell,re.M));assert passed+failed==50
assert 'checks passed' in Path('/tmp/collection-v46d-check.log').read_text();assert 'BAKE_OK users=1472' in Path('/tmp/collection-v46d-bake.log').read_text();assert '[editor_plugins]' not in (out/'project.godot').read_text();assert 'SCRIPT ERROR' not in Path('/tmp/collection-v46d-visual.log').read_text()
m=read(out/'manifest.json');assert len(m['source_sha256'])==201
for p,h in m['source_sha256'].items():assert sha(Path(p))==h,p
ceilings=read(out/'evidence/ceiling-visibility.json');assert all(x['authored_ceilings']==3 and x['baked_copies']==3 for x in ceilings)
e.mkdir(exist_ok=False)
d=read(root/'lion-modern-native-v1/manifest.json');assert sha(Path(d['video']))==d['video_sha256'];write(e/'native-source-manifest.json',d)
for row in d['frames']:
 p=Path(row['output']);assert sha(p)==row['sha256'];im=Image.open(p).convert('RGB');im.thumbnail((540,960));im.save(e/(p.stem+'-source.jpg'),quality=92)
for n in ['landing-wide.jpg','modern-wide.jpg']:shutil.copyfile(root/'lion-modern-native-v1'/n,e/n)
shutil.copyfile('/tmp/collection-v46-modern-far-wall.jpg',e/'modern-far-wall-sequence.jpg')
for name in ['braque-frame','cezanne-frame']:
 r=read(app/(name+'-receipt.json'));assert r['cost']=='0.010000'
 for suffix in ['prompt.txt','plan.json','recipe.json','prepared.json','planned.json','receipt.json','review.json']:shutil.copyfile(app/(name+'-'+suffix),e/(name+'-'+suffix))
 shutil.copyfile(app/'trial'/(name+'-original.webp'),e/(name+'-original.webp'))
 shutil.copyfile(app/'inventory-references'/('braque-frame-video-native.png' if name=='braque-frame' else 'cezanne-frame-video-native.png'),e/(name+'-reference.png'))
 with tarfile.open(e/(name+'-run.tar.gz'),'w:gz') as archive:archive.add(app/'artifacts/image-generation/runs'/r['runId'],arcname=r['runId'])
for name in ['braque-still-life','cezanne-banks-river','matisse-green-pumpkin','villon-head-woman','seated-woman-duchamp-villon']:
 shutil.copyfile(app/'inventory-catalogue'/(name+'.json'),e/(name+'.json'))
 im=Image.open(app/'inventory-catalogue'/(name+'-zoom-0.jpg'));im.thumbnail((700,1000));im.save(e/(name+'-official.jpg'),quality=93)
with tarfile.open(e/'official-api-and-pages.tar.gz','w:gz') as archive:archive.add(root/'modern-candidates-v2',arcname='queries-and-official-images');archive.add(root/'modern-candidates-v3',arcname='next-object-queries-and-official-images')
for n in ['manifest.json','geometry.json']:shutil.copyfile(out/n,e/n)
for n in ['layout-source-proof.json','ceiling-visibility.json','browser-result.json','landing-medieval-reverse.png','landing-modern-door.png','landing-white-door.png','landing-stair-void.png','modern-entry-wide.png','modern-windows-wide.png','modern-braque.png','modern-villon.png','modern-pumpkin.png','modern-cezanne.png','modern-walk.png','landing-walk.png','medieval-stair-wall-wide.png','hall-wide-arch.png','loop-overview.png','browser-forward.png','browser-reverse.png']:shutil.copyfile(out/'evidence'/n,e/n)
shutil.copyfile(root/'lowpoly-room-v46-landing-modern/evidence/modern-windows-wide.png',e/'initial-review-offset-error.png')
shutil.copyfile(root/'lowpoly-room-v46-landing-modern/geometry.json',e/'initial-mirrored-layout.json')
shutil.copyfile(root/'lowpoly-room-v45b-stair-wall/evidence/medieval-stair-door-detail.png',e/'v45-capped-stair-door.png')
for n in ['collection-v46d-final-checks.py','collection-v46d-browser-with-server.py','collection-v46d-unbaked.py','collection-v46d-bake-driver.py','collection-v41-bake.py','collection-v46-source.py','collection-v46-identities.py','collection-v46-pumpkin-api.py','collection-v46-official-images.py','collection-v46-landscape-source.py','collection-v46-proof.py','collection-v46-correct-handedness.py','collection-v46-next-identities.py','collection-v46-seated-official.py','collection-v46-onview-candidates.py','collection-v46-onview-all.py','collection-publish-v46.py']:shutil.copyfile('/tmp/'+n,e/n)
for n in ['worktree-ps','issues-live','pipeline-identity']:shutil.copyfile('/tmp/collection-v46-'+n+'.json',e/(n+'.json'))
automation=next(x for x in read(Path('/tmp/collection-v46-automations.json'))['result']['automations'] if x['id']=='99695359-522b-46ce-bb00-078657d105ea');assert not automation['enabled'];write(e/'heartbeat-disabled.json',{k:automation[k] for k in ['id','name','enabled']})
logs=list(Path('/tmp').glob('collection-v46*.log'))
with tarfile.open(e/'raw-checks-and-shell-film.tar.gz','w:gz') as archive:
 for p in logs:archive.add(p,arcname=p.name)
 archive.add('/tmp/collection-v46d-shell-repeat',arcname='owning-shell-final');archive.add('/tmp/collection-v46d-shell-first',arcname='owning-shell-first-42of50')
for p in logs:(e/p.name).write_text('\n'.join(x.rstrip() for x in p.read_text().splitlines()).rstrip()+'\n')
next_action='Generate/install source-preserving lion34.652; identify/capture large figurative painting; generate Duchamp-Villon Seated Woman67.089 from inspected official front/oblique photos and video, rear shape unverified, dedicated Matisse/Villon frames; refine source stair curve/rails/flight destinations, overly bright modern spotlight pools and held-out room/object offsets, then remaining rooms and auditorium.'
r=read(app/'reconstruction-coverage.json');r['current_preview']='https://windows-wsl.taile06c45.ts.net/risd-frame-review-01a0ee18/architecture-review-v46/'
r['connected_modern_v46']={'source_native_frames':32,'landing_doors':3,'landing_floor_void':True,'stair_flights_studies':2,'modern_windows':3,'modern_bench':True,'modern_window_wall_opening':True,'catalogue_paintings_installed':['48.248','70.058','57.037','43.255'],'retracted_false_match':'41.012 replaced by57.037; prior source six-apple claim wrong','placement_metric_accepted':False,'stair_curve_destinations_complete':False,'all_objects_complete':False,'muse_runs':['run-9aee0790a3bad9ca3dc7bb83','run-65e26c80ff7874d3634914a4'],'new_paid_outputs':2,'cost_this_pass_usd':'0.02','cumulative_actual_usd':'0.79','cumulative_conservative_usd':'0.80','baked_surfaces':1472,'browser_checks':174,'browser_errors':[],'shell_passed':passed,'shell_total':50,'evidence':str(e),'next':next_action}
r['room_ceilings'].update(browser_checks_passed=174,baked_surfaces=1472,browser_frame_time_p95_ms=b['engine']['frame_time_p95_ms'],shell_passed=passed,next=next_action)
write(app/'reconstruction-coverage.json',r);write(e/'reconstruction-coverage.json',r)
now=datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M UTC')
entry=f'''\n### Collection v46 — connected lion landing and modern gallery ({now})\n\n32 CUDA-native6387 wides and full far-wall sequence inspected; three distinct doors retained. Capped medieval stair threshold replaced by provisional landing, alternating square parquet, physical floor void, initial ascending/descending ramp/tread studies and iron/wood balustrades. Modern doorway opposite medieval, white ancient sculpture room on adjacent wall remains a threshold; deeper modern opening likewise threshold only. Room handedness corrected after reciprocal review: entry/large painting west, three blinded windows east; Braque/Villon south beside entry; pumpkin/Cézanne north far wall. Native window/radiator bases,bench,track fixtures,cornice and door leaves reuse saved Muse architectural textures. Flight curve/rails/destinations, all metres/offsets and unseen interiors unaccepted. Lion34.652,large figurative painting,seated gold sculpture and chair rack still missing; full object coverage false. Main Hall23 preserved; no point cloud/Viewer/frozen seam changes.\n\nCatalogue correction: prior41.012 six-apple source match was wrong.6387:148-151 instead matches Henri Matisse The Green Pumpkin57.037(id1539041,.645x.800m); red table,one ribbed green pumpkin,white dish/window mullion/village. Landscape matches Paul Cézanne On the Banks of a River43.255(id1538666,.737x.610m),blue river,red left roof,yellow/white village/right foreground rail. Seated gold sculpture identity independently matched to Raymond Duchamp-Villon Seated Woman67.089(id1552686,bronze/gold wash,71.1x20.3x24.1cm) using native64.25/66.25s and inspected official photos0/1; asset/case still absent. Four modern originals installed,including Braque48.248(.721x.464m) and Villon70.058(.460x.548m,48-sided oval crop). Three rectangular museum JPEGs copied byte-identically; Villon review crop from preserved official photo. White frame and Matisse frame reuse unaccepted; painted images never generated.\n\nTwo OpenRouter meta/muse-image outputs,$0.01 each: Braque frame run-9aee0790a3bad9ca3dc7bb83(hash3b1f9bcf18c98976d2c0ab2e4aa502cc2afc634f255c2a175818fe682a135753),Cézanne frame run-65e26c80ff7874d3634914a4(hashf9efa0ebd05a5f348c014ad3d3b7540ec57231a0025032c40bf6a5d847b6fd0f). Broad cream/gold bands and grey-bronze nested rails visually inspected; fine ornament/profile and frame band metres unaccepted. Cézanne reference right edge cropped,symmetric restoration inferred; square generated aperture corrected by existing nine-slice. No blind retry.68 outputs plus prior$0.11:$0.79 actual/$0.80 conservative; ambiguous river-deities/failed heads/Apostle damage remain unchanged/unaccepted.1472 native surfaces baked CPU Vulkan fallback in6m09.94s; renderer restored. Final RTX native wide/close/walking images inspected. Chrome174/174 including8 new door/bench/guard trials,keyboard round trip/33 loop segments,p95{b['engine']['frame_time_p95_ms']:.3f}ms,errors[]. Three authored/baked ceilings follow cutaway. Owning Shell{passed}/50,{failed} failures archived. First Shell42/50 had four additional animation-timing failures; repeated with browser closed and both films/logs retained. scripts/check.sh/git diff --check pass;201 prepared/50 original pending hashes verified,21 prior PROVENANCE lines remain unstaged.60fps/full native performance acceptance unresolved.\n\nNext: {next_action} Goal active/unfinished;sole worker,heartbeat disabled,no production integration/ticket closure. Evidence `{e}/`.\n'''
Path('/tmp/collection-provenance-connected-modern-entry.md').write_text(entry);p=Path('modules/shell/PROVENANCE.md');assert not p.read_text().endswith(entry);p.write_text(p.read_text()+entry);Path('/tmp/collection-v46-staged-provenance.md').write_bytes(subprocess.check_output(['git','show','HEAD:modules/shell/PROVENANCE.md'])+entry.encode())
s=p.read_bytes()
for name in ['connected-modern','stair-wall','iron-grille','ceilings','gabled','panels','loop','perugino','bertin','cases','european-door','wide-scale','ionic','grey','full-survey','sculpture-layout','gallery','wide','inventory']:
 q=Path('/tmp/collection-provenance-'+name+'-entry.md').read_bytes();assert s.endswith(q),name;s=s[:-len(q)]
d=read(Path('/tmp/collection-inventory-pending-before.json'))
for path,h in d.items():assert hashlib.sha256(s if path=='modules/shell/PROVENANCE.md' else Path(path).read_bytes()).hexdigest()==h,path
write(e/'preservation.json',{'original_pending_files':len(d),'original_hashes_match':True,'prepared_source_count':201,'prepared_source_hashes_match':True,'provenance_method':'Strip only19 session-authored entries; original21 pending lines unstaged.'})
failures='\n'.join(x.rstrip() for x in re.findall('^FAIL .*',shell,re.M))
(e/'CHECKPOINT.md').write_text(f'''# Collection checkpoint — {now}

v46 prototype. Goal active and unfinished; sole main worker,heartbeat disabled. Viewer and frozen seams untouched; no production integration/ticket closure.

1. Replaced medieval stair cap with connected landing/modern-room shells. Three distinct landing doors,real floor void,alternating square parquet,initial straight stair/ramp/iron-rail studies. Modern has three windows/blinds/radiator bases,bench,ceiling tracks and deeper opening. Corrected initially mirrored wall order using native reciprocal wides. All extents/offsets provisional; flight curve/destinations,white ancient sculpture-room interior and modern adjoining gallery still unfinished.
2. Retracted incorrect41.012 source match: video pumpkin is Matisse57.037,not six apples. Village/river painting is Cézanne43.255. Four catalogue-matched modern paintings installed with original museum art;3 JPEGs byte-identical,one oval crop. New Braque/Cézanne Muse frame passes$0.02; native originals/receipts/reservations retained. Fine frame detail/depth/metric band widths unaccepted; Matisse reused frame/Villon white frame need proper source pass. Gold seated sculpture matched to Duchamp-Villon67.089 using official front/oblique photographs; asset and case still missing. Modern spotlight pools visibly too bright against source, refining next. Cumulative68 outputs plus earlier$0.11:$0.79 actual/$0.80 conservative. Apostles still fail damage fidelity; heads remain failed.
3.1472 native surfaces baked CPU Vulkan; renderer restored. Final RTX close/wide/walking views inspected. Chrome174/174,8 new door/bench/guard trials,33 continuous loop segments,real keyboard round trip,p95{b['engine']['frame_time_p95_ms']:.3f}ms,errors[]. Three ceiling copies correctly follow cutaway. Owning Shell{passed}/50,{failed} failures/full film retained. First Shell42/50 had four additional animation-timing failures; repeated with browser closed, both full films/logs retained. Repository/diff/layout/source checks pass.201 prepared hashes and50 original pending hashes verified;21 prior PROVENANCE lines unstaged.60fps/full native performance remains unverified.
4. Missing here: lion34.652,large crowded painting,seated gold figure,chair rack and faithful curve/rails/flight destinations. Other rooms' missing sculptures/case contents,room fit,auditorium and complete coverage also unfinished. Next: {next_action} No external blocker.

Owning Shell failures:

{failures}

https://windows-wsl.taile06c45.ts.net/risd-frame-review-01a0ee18/progress/

Saved wrappers reproduce preparation/native bake/browser checks. Raw checks/full Shell film archived; source-native hashes/CUDA commands recorded. Artist research queries are first pages,not exhaustive absence evidence. Experimental on-view/API filter queries returned zero rows and do not prove absence. Repository source JPEGs are review derivatives.
''')
shutil.copyfile(__file__,e/'finish-checkpoint.py')
for name in ['remodel_room.gd','remodel_review.gd','remodel_bake.gd']:shutil.copyfile(Path('modules/shell/prototype/collection_reconstruction')/name,e/(name+'.txt'))
write(e/'SHA256.json',{str(p.relative_to(e)):sha(p) for p in e.rglob('*') if p.is_file() and p.name!='SHA256.json'})
print(e,'Shell',passed,'/50,original pending preserved')
