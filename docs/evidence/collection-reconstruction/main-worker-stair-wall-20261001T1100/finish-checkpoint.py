from pathlib import Path
from datetime import datetime,timezone
import json,hashlib,shutil,subprocess,tarfile,re
from PIL import Image
app=Path('image-work/collection-room-remodel');root=Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion');out=root/'lowpoly-room-v45b-stair-wall';e=Path('docs/evidence/collection-reconstruction/main-worker-stair-wall-20261001T1100')
def read(p):return json.loads(p.read_text())
def write(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
b=read(out/'evidence/browser-result.json');assert b['pass'] and b['errors']==[] and len(b['engine']['checks'])==158 and all(b['engine']['checks'].values()) and 'NVIDIA' in b['webgl_renderer']
assert len([x for x in b['engine']['samples'] if x['trial'].startswith('loop_')])==33
shell=Path('/tmp/collection-v45b-shell-repeat.log').read_text();passed=len(re.findall('^PASS ',shell,re.M));failed=len(re.findall('^FAIL ',shell,re.M));assert passed+failed==50
assert 'checks passed' in Path('/tmp/collection-v45b-check.log').read_text();assert 'BAKE_OK users=900' in Path('/tmp/collection-v45b-bake.log').read_text();assert '[editor_plugins]' not in (out/'project.godot').read_text();assert 'SCRIPT ERROR' not in Path('/tmp/collection-v45b-visual.log').read_text()
m=read(out/'manifest.json');assert len(m['source_sha256'])==194
for p,h in m['source_sha256'].items():assert sha(Path(p))==h,p
e.mkdir(exist_ok=False)
for folder in ['medieval-stair-native-v1']:
 d=read(root/folder/'manifest.json');assert sha(Path(d['video']))==d['video_sha256'];write(e/'native-source-manifest.json',d)
 for row in d['frames']:
  p=Path(row['output']);assert sha(p)==row['sha256'];im=Image.open(p).convert('RGB');im.thumbnail((540,960));im.save(e/(p.stem+'-source.jpg'),quality=92)
for n in ['collection-v45-IMG_6382-east-wide.jpg','collection-v45-IMG_6387-east-wide.jpg','collection-v45-modern-wide.jpg','collection-v45-apostle-side-study.jpg']:shutil.copyfile('/tmp/'+n,e/n)
api=root/'medieval-fragments-api-v1'
for p in api.glob('*.json'):shutil.copyfile(p,e/('api-'+p.name))
for p in api.glob('*zoom-*.jpg'):
 im=Image.open(p);im.thumbnail((500,1000));im.save(e/p.name,quality=92)
with tarfile.open(e/'official-pages-and-modern-searches.tar.gz','w:gz') as archive:
 for p in api.glob('*.html'):archive.add(p,arcname=p.name)
 archive.add(root/'modern-identities-api-v1',arcname='modern-query-and-villon-match')
modern=root/'modern-identities-api-v1'
for name in ['villon.json','villon-head-image.json']:shutil.copyfile(modern/name,e/name)
im=Image.open(modern/'villon-head-zoom.jpg');im.thumbnail((700,1000));im.save(e/'villon-head-official.jpg',quality=92)
shutil.copyfile('/tmp/collection-v45-villon-video.jpg',e/'villon-head-video.jpg')
shutil.copyfile(app/'inventory-catalogue/villon-head-woman.json',e/'villon-head-woman.json')
source=root/'survey-2fps/IMG_6387/000113.jpg'
write(e/'villon-identity.json',{'accession':'70.058','id':'1539421','maker':'Jacques Villon','title':'Head of a Woman','source':str(source),'source_sha256':sha(source),'derivative':'clockwise90deg video review','official_image':read(modern/'villon-head-image.json'),'identity_visually_matched':True,'geometry_built':False,'placement_accepted':False})
for name in ['apostle-41045','apostle-41046']:
 r=read(app/(name+'-receipt.json'));assert r['cost']=='0.010000'
 for suffix in ['prompt.txt','plan.json','recipe.json','planned.json','receipt.json','review.json']:shutil.copyfile(app/(name+'-'+suffix),e/(name+'-'+suffix))
 shutil.copyfile(app/'trial'/(name+'-original.webp'),e/(name+'-original.webp'))
 with tarfile.open(e/(name+'-run.tar.gz'),'w:gz') as archive:archive.add(app/'artifacts/image-generation/runs'/r['runId'],arcname=r['runId'])
for n in ['manifest.json','geometry.json']:shutil.copyfile(out/n,e/n)
for n in ['browser-result.json','apostle-mesh-proof.json','ceiling-visibility.json','iron-grille-native.json','medieval-stair-wall-wide.png','medieval-stair-door-detail.png','medieval-apostle-left.png','medieval-apostle-right.png','medieval-portal-wall-wide.png','medieval-wide.png','medieval-walk.png','renaissance-wide.png','hall-wide-arch.png','loop-overview.png','browser-forward.png','browser-reverse.png']:shutil.copyfile(out/'evidence'/n,e/n)
shutil.copyfile(root/'lowpoly-room-v45-stair-wall/evidence/medieval-stair-door-detail.png',e/'v45-stretched-sides-unbaked.png')
shutil.copyfile(root/'lowpoly-room-v44b-grille/evidence/medieval-wide.png',e/'v44-medieval-wide.png')
for n in ['collection-v45b-final-checks.py','collection-v45b-browser-with-server.py','collection-v45b-unbaked.py','collection-v41-bake.py','collection-publish-v45.py','collection-v45-source-and-api.py','collection-v45-fragment-api.py','collection-v45-modern-api.py','collection-v45-villon-source.py']:shutil.copyfile('/tmp/'+n,e/n)
shutil.copyfile('/tmp/collection-v45-worktree-ps.json',e/'worktree-ps.json')
automation=next(x for x in read(Path('/tmp/collection-v45-automations.json'))['result']['automations'] if x['id']=='99695359-522b-46ce-bb00-078657d105ea');assert not automation['enabled'];write(e/'heartbeat-disabled.json',{k:automation[k] for k in ['id','name','enabled']})
logs=list(Path('/tmp').glob('collection-v45*.log'))
with tarfile.open(e/'raw-checks-and-shell-film.tar.gz','w:gz') as archive:
 for p in logs:archive.add(p,arcname=p.name)
 archive.add('/tmp/collection-v45b-shell-repeat',arcname='owning-shell-final')
for p in logs:(e/p.name).write_text('\n'.join(x.rstrip() for x in p.read_text().splitlines()).rstrip()+'\n')
next_action='Build the source-constrained lion landing/modern-gallery connection from6387 reciprocal wides, retain three distinct doorways and correct floor/window/bench positions; continue missing room objects, tracks, sculptures/cases and auditorium.'
r=read(app/'reconstruction-coverage.json');r['current_preview']='https://windows-wsl.taile06c45.ts.net/risd-frame-review-01a0ee18/architecture-review-v45/'
r['medieval_stair_wall']={'catalogue_accessions':['41.046','41.045'],'catalogue_identity_matched':True,'catalogue_width_height_m':[[.267,.826],[.254,.864]],'geometry_installed_prototype':True,'geometry_accepted':False,'muse_damage_fidelity_accepted':False,'door_leaves':2,'hardware':'Open double leaves, black push bars/hinges/closers,green EXIT; texture reused from Muse two-panel asset','source':['IMG_6382 17.25/20.75/26.25/77.75/78.75s','Official RISD front/side photos/API'],'muse_runs':['run-d3f8116583dea973b1b4a81b','run-54d9c9f23373622b070af56e'],'new_paid_outputs':2,'cost_this_pass_usd':'0.02','cumulative_actual_usd':'0.77','cumulative_conservative_usd':'0.78','baked_surfaces':900,'browser_checks':158,'browser_errors':[],'shell_passed':passed,'shell_total':50,'next':next_action,'evidence':str(e)}
r['room_ceilings'].update(browser_checks_passed=158,baked_surfaces=900,browser_frame_time_p95_ms=b['engine']['frame_time_p95_ms'],shell_passed=passed,next=next_action)
r['medieval_panels'].update(cumulative_map_actual_usd='0.77',cumulative_map_conservative_usd='0.78',next=next_action)
write(app/'reconstruction-coverage.json',r);write(e/'reconstruction-coverage.json',r)
now=datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M UTC')
entry=f'''\n### Collection v45 — medieval stair-door group ({now})\n\nNative CUDA6382 15.75..27.25/77.75/78.75/82.75s and6387 reciprocal wides inspected. Official RISD API/front/side photos identify left Apostle41.046(.267x.826m width/height) and right Apostle41.045(.254x.864m); turned head/halo/diagonal arm/lower fracture versus missing face/crossed hands/feet. Both placed on wall brackets/backplates at provisionalx10.38,z28.75/31.50,bottom1.04m; mount dimensions/.12m nominal relief depth(max.138m),metres and offsets unaccepted. Existing faceted volume builder adds wall-backed slab profile; each162 vertices/320triangles/480opposite paired edges,positive volume independently checked from prepared native asset bytes. Front Muse UVs and plain Muse stone side/back swatch fix initial stretched facial bands. Open stair double leaves,push bars,black hinges/closers and green EXIT added; existing Muse ivory panel crops reused. Actual landing beyond remains threshold stub,source track layout/lighting and adjacent sculptures/case contents unfinished. No room extents or frozen seams changed. Main Hall23 works retained.\n\nTwo OpenRouter meta/muse-image outputs,$0.01 each: run-d3f8116583dea973b1b4a81b(hash596e35d1f8ae020237f7110fa79c52d865a0b0af289284b77490f9abe3053214) and run-54d9c9f23373622b070af56e. Immutable native/prompt/reference/receipt/reservation evidence archived. Generated face/robe repairs differ from damaged originals; both are provisional style/geometry studies,not accepted source-preserving sculptures and not finished. No blind retry.66 outputs plus prior$0.11:$0.77 actual/$0.78 conservative. Failed heads and ambiguous river-deities unchanged.900 native surfaces baked152.62s CPU Vulkan fallback; renderer restored. Final RTX native close/wide/walking renders inspected. Chrome158/158 plus keyboard round trip/33 circuit segments,p95{b['engine']['frame_time_p95_ms']:.3f}ms,errors[]. Owning Shell{passed}/50,{failed} failures archived. scripts/check.sh/git diff --check pass. All194 prepared source hashes and50 original pending hashes match;21 original PROVENANCE lines remain unstaged. No new native performance claim;60fps unresolved.\n\n6387 modern wides separately confirm straight boards,central bench,three windows,window-wall deeper doorway; landing has three distinct doors. Villon Head of a Woman70.058 visually matched to6387:113 and official zoom photograph;54.8x46cm,vertical oval inside white square frame. Other artist candidates remain unmatched. Next: {next_action} Full reconstruction unfinished;sole main worker,heartbeat disabled,Viewer untouched,no production integration/ticket closure. Evidence `{e}/`.\n'''
Path('/tmp/collection-provenance-stair-wall-entry.md').write_text(entry);p=Path('modules/shell/PROVENANCE.md');assert not p.read_text().endswith(entry);p.write_text(p.read_text()+entry);Path('/tmp/collection-v45-staged-provenance.md').write_bytes(subprocess.check_output(['git','show','HEAD:modules/shell/PROVENANCE.md'])+entry.encode())
s=p.read_bytes()
for name in ['stair-wall','iron-grille','ceilings','gabled','panels','loop','perugino','bertin','cases','european-door','wide-scale','ionic','grey','full-survey','sculpture-layout','gallery','wide','inventory']:
 q=Path('/tmp/collection-provenance-'+name+'-entry.md').read_bytes();assert s.endswith(q),name;s=s[:-len(q)]
d=read(Path('/tmp/collection-inventory-pending-before.json'))
for path,h in d.items():assert hashlib.sha256(s if path=='modules/shell/PROVENANCE.md' else Path(path).read_bytes()).hexdigest()==h,path
write(e/'preservation.json',{'original_pending_files':len(d),'original_hashes_match':True,'prepared_source_count':194,'prepared_source_hashes_match':True,'provenance_method':'Strip only18 session-authored entries; original21 pending lines unstaged.'})
failures='\n'.join(x.rstrip() for x in re.findall('^FAIL .*',shell,re.M))
(e/'CHECKPOINT.md').write_text(f'''# Collection checkpoint — {now}

v45 prototype; sole main worker; heartbeat disabled. Goal active and unfinished. Viewer/frozen seams unchanged; no production integration or ticket closure.

1. Stair-door wall group now has two catalogue-matched Apostle studies,41.046 left/41.045 right,using official width/height and low polygon closed wall-backed slabs. Native17.25/26.25s and official front/side photos inspected. Door double leaves/push bars/hinges/closers/green EXIT added from18.25..24.75s. Source-compatible grouping; exact offsets/room geometry,depth/mounts/door metrics unaccepted. Landing still a capped threshold,not complete stairs.
2. Two Muse OpenRouter passes,$0.02 this turn. Both repair eroded faces/folds or decorative damage contrary to source: unaccepted style/geometry studies,not finished museum assets. No blind retry. Initial stretched side UVs corrected with separate plain Muse stone swatch; failed render retained.66 outputs plus earlier$0.11,cumulative$0.77 actual/$0.78 conservative. Heads remain failed/unaccepted. Full generation records and immutable images archived.
3.900 surfaces baked152.62s CPU Vulkan; renderer restored. Final native close/wide/walking views inspected; independent prepared mesh proof each162vertices/320triangles/480opposite pairededges/positive volume. RTX Chrome158/158,33 circuit segments/keyboard round trip,p95{b['engine']['frame_time_p95_ms']:.3f}ms,ready{b['first_ready_ms']}ms,errors[]. Owning Shell{passed}/50,{failed} failures/full film retained. Repository/diff checks pass.194 prepared hashes and50 original pending hashes match;21 prior PROVENANCE lines preserved unstaged.60fps acceptance unresolved.
4. Modern6387 wides reviewed: separate wall groups,straight boards,central bench,three windows and window-wall deeper opening; three distinct landing doors. Villon Head of a Woman70.058 now source/API matched; other artist candidates unmatched,source geometry not yet built. Next: {next_action} Other medieval/Renaissance contents,failed heads,whole-room fit,stair flights,auditorium and complete coverage remain unfinished. No external blocker.

Owning Shell failures:

{failures}

https://windows-wsl.taile06c45.ts.net/risd-frame-review-01a0ee18/progress/

Reproduce with saved preparation/native-bake/browser wrappers. Exact raw logs/full Shell film archived; source native frames remain in ingestion with hash manifests and CUDA commands; repo JPEGs are review derivatives.
''')
shutil.copyfile(__file__,e/'finish-checkpoint.py')
for name in ['remodel_room.gd','remodel_review.gd']:shutil.copyfile(Path('modules/shell/prototype/collection_reconstruction')/name,e/(name+'.txt'))
write(e/'SHA256.json',{str(p.relative_to(e)):sha(p) for p in e.rglob('*') if p.is_file() and p.name!='SHA256.json'})
print(e,'Shell',passed,'/50,original pending preserved')
