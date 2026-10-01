from pathlib import Path
from datetime import datetime,timezone
import json,hashlib,shutil,subprocess,tarfile,re
from PIL import Image
app=Path('image-work/collection-room-remodel');e=Path('docs/evidence/collection-reconstruction/main-worker-iron-grille-20261001T1040');out=Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion/lowpoly-room-v44b-grille');e.mkdir(exist_ok=False)
def read(p):return json.loads(p.read_text())
def write(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
b=read(out/'evidence/browser-result.json');assert b['pass'] and b['errors']==[] and len(b['engine']['checks'])==158 and all(b['engine']['checks'].values()) and 'NVIDIA' in b['webgl_renderer']
loop=[x for x in b['engine']['samples'] if x['trial'].startswith('loop_')];assert len(loop)==33 and all(x['started_without_reset'] for x in loop[1:])
proof=read(out/'evidence/iron-grille-native.json');assert proof['closed_edges']==30702 and proof['triangles']==20468 and proof['coils']==119 and proof['accepted']==False
ceil=read(out/'evidence/ceiling-visibility.json');assert len(ceil)==2 and all(x['authored_ceilings']==x['baked_copies']==2 for x in ceil) and ceil[0]['visible'] and not ceil[1]['visible']
shell=Path('/tmp/collection-v44b-shell-repeat.log').read_text();passed=len(re.findall('^PASS ',shell,re.M));failed=len(re.findall('^FAIL ',shell,re.M));assert passed+failed==50
assert 'checks passed' in Path('/tmp/collection-v44b-check-final.log').read_text();assert 'BAKE_OK users=825' in Path('/tmp/collection-v44b-bake.log').read_text();assert '[editor_plugins]' not in (out/'project.godot').read_text()
visual=Path('/tmp/collection-v44b-visual.log').read_text();assert 'REMODEL_VISUAL_PROOF' in visual and 'SCRIPT ERROR' not in visual
m=read(out/'manifest.json')
for p,h in m['source_sha256'].items():assert sha(Path(p))==h,p
assert len(m['source_sha256'])==192,len(m['source_sha256'])
records=read(Path('/tmp/collection-v44-automations.json'))['result']['automations'];automation=next(x for x in records if x['id']=='99695359-522b-46ce-bb00-078657d105ea');assert not automation['enabled'];write(e/'heartbeat-disabled.json',{k:automation[k] for k in ['id','name','enabled']})
source=read(out.parent/'medieval-grille-native-v2/manifest.json');assert sha(Path(source['video']))==source['video_sha256']
for item in source['frames']:
 p=Path(item['output']);assert sha(p)==item['sha256'];image=Image.open(p).convert('RGB');image.thumbnail((540,960));image.save(e/(p.stem+'-source.jpg'),quality=92)
write(e/'native-source-manifest.json',source)
old=Path('docs/evidence/collection-reconstruction/main-worker-ceilings-20261001T0945')
for n in ['v42-grille-88.75-review.jpg','medieval-grille-rectified-study.png','medieval-grille-original.webp']:shutil.copyfile(old/n,e/n)
Image.open(out.parent/'lowpoly-room-v43b-ceilings/evidence/medieval-portal-wall-wide.png').save(e/'v43-portal-wall-wide.png')
for n in ['medieval-grille-front','medieval-grille-oblique','medieval-portal-wall-wide','medieval-wide']:
 shutil.copyfile(out.parent/'lowpoly-room-v44-grille/evidence'/(n+'.png'),e/('v44-thin-'+n+'.png'))
for n in ['manifest.json','geometry.json']:shutil.copyfile(out/n,e/n)
for n in ['iron-grille-native.json','ceiling-visibility.json','browser-result.json','medieval-grille-front.png','medieval-grille-oblique.png','medieval-portal-wall-wide.png','medieval-wide.png','medieval-walk.png','renaissance-wide.png','renaissance-walk.png','hall-wide-arch.png','loop-overview.png','medieval-frame-front.png','browser-forward.png','browser-reverse.png']:shutil.copyfile(out/'evidence'/n,e/n)
for n in ['medieval-grille-geometry.json','medieval-grille-metal.png']:shutil.copyfile(app/'trial'/n,e/n)
shutil.copyfile(app/'grille-assemble.py',e/'grille-assemble.py')
for p in (app/'inventory-catalogue').glob('*grille-v44*.json'):shutil.copyfile(p,e/p.name)
shutil.copyfile('/tmp/collection-v44-issues-live.json',e/'issues-live.json')
shutil.copyfile('/tmp/collection-v44-worktree-ps.json',e/'worktree-ps.json')
for n in ['collection-v44b-final-checks.py','collection-v44b-browser-with-server.py','collection-v41-bake.py','collection-publish-v44.py']:shutil.copyfile('/tmp/'+n,e/n)
logs=list(Path('/tmp').glob('collection-v44*.log'))
with tarfile.open(e/'raw-checks-and-shell-film.tar.gz','w:gz') as archive:
 for p in logs:archive.add(p,arcname=p.name)
 archive.add('/tmp/collection-v44b-shell-repeat',arcname='owning-shell-final')
for p in logs:(e/p.name).write_text('\n'.join(x.rstrip() for x in p.read_text().splitlines()).rstrip()+'\n')
next_action='Compare reciprocal wide shots for all rooms, source-fit medieval east-wall fragment/stair doorway and track lights, then refine remaining door/object positions and room contents.'
r=read(app/'reconstruction-coverage.json');r['current_preview']='https://windows-wsl.taile06c45.ts.net/risd-frame-review-01a0ee18/architecture-review-v44/'
r['medieval_grille_geometry']={'installed_prototype':True,'accepted':False,'columns_observed':7,'rows_provisional':17,'coils':119,'native_closed_edges':30702,'native_triangles':20468,'catalogue_identity':'unmatched','metric_accepted':False,'handedness_accepted':False,'material':'Existing OpenRouter Muse iron-post pixels; generated8-column layout rejected.','paid_calls_this_pass':0,'cost_usd_this_pass':'0.00','baked_surfaces':825,'native_front_oblique_wide_inspected':True,'browser_checks':158,'browser_errors':[],'shell_passed':passed,'shell_total':50,'next':next_action,'evidence':str(e)}
r['room_ceilings'].update(browser_checks_passed=158,browser_frame_time_p95_ms=b['engine']['frame_time_p95_ms'],baked_surfaces=825,shell_passed=passed,next=next_action)
r['medieval_panels']['next']=next_action
r['medieval_architecture_review'].update(opaque_ceiling_missing=False,hall_skylight_visible_from_wrong_room=False,grille_identity_unmatched=True,evidence=str(e/'architecture-review.json'))
write(app/'reconstruction-coverage.json',r);write(e/'reconstruction-coverage.json',r)
a={'sources':['IMG_6382 12.25s','IMG_6382 12.375s','IMG_6382 88.75s'],'wide_observations':['Portal on north wall with grille to its right, low white plinth and top rear brace.','Stone wall fragment farther east beside a separate stair opening.','Pale flat ceiling, multiple track lights; precise fixture pattern remains unfinished.'],'source_columns_observed':7,'rows_provisional':17,'metric_accepted':False,'placement_accepted':False,'handedness_accepted':False,'native_closed_coils':119,'grille_bool_union_checked':False,'catalogue_identity':'unmatched','api_query_finding':'items_per_page100 yielded empty lists. Positive controls using25 returned known ID and Monet records; valid broad first-page searches are incomplete and cannot establish absence.','paid_calls_this_pass':0,'cost_usd_this_pass':'0.00','cumulative_actual_usd':'0.75','cumulative_conservative_usd':'0.76','visual_finding':'Final baked front/oblique/room wides inspected; open coil geometry and plinth present. Source has irregular scrolls/rivets and heavier iron than uniform native study. Exact row count, dimensions, wall offsets, support, lighting and adjacent objects remain unaccepted.','packaging_fix':'Previous checkpoint source copies renamed.gd.txt with byte-identical hashes; archive is no longer scanned as live module code. Repository checks rerun successfully.','next':next_action};write(e/'architecture-review.json',a)
now=datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M UTC')
entry=f'''\n### Collection v44 — native open iron grille study ({now})\n\nReciprocal native6382 12.25/12.375/88.75s inspected: grille beside north-wall portal, low plinth, top rear brace, separate east-wall fragment/stair doorway. Seven columns observed;17 rows,alternating handedness,uniform scrolls,profile,metres,plinth,braces and placement provisional. Original Muse run6d9f3b3e3a4b26e3c758f21c,OpenRouter meta/muse-image,$0.01 recorded in v43:8-column sheet remains rejected as geometry. Only its iron-post pixels are reused,source hash50dfca1c60c1039936fad34f3d3777f8a5b265af2859460255068ed64520981c,patch[413,250,419,1550]. New native7-column geometry uses119 closed low polygon coils; independent native proof10472 vertices,20468triangles,30702paired opposite-winding edges,positive volume. This validates individual coil solids,not a boolean union/historical fidelity. Visitor collision blocks the grille and preserves east aisle.825 native surfaces baked with existing CPU Vulkan fallback; final native front/oblique/wide and walking views inspected,ceilings/Main Hall23 paintings retained. RTX Chrome158/158 plus keyboard round trip,33 continuous circuit segments,p95{b['engine']['frame_time_p95_ms']:.3f}ms,errors[]. Owning Shell{passed}/50,{failed} failures archived. scripts/check.sh and git diff --check pass after byte-identical previous evidence source copies were named.gd.txt instead of.gd; no runtime seam changes. All192 prepared source hashes and50 original pending hashes match. Native/source metric and60fps acceptance remain open.\n\nRISD API100-result searches returned invalid empty lists;25-result positive known-ID/Monet controls work. Valid25-result broad searches retained,first pages not exhaustive. Identity remains unmatched; rejected27.184 square grill/53.085 clock are not matches. No paid calls this pass;total$0.75 actual/$0.76 conservative. Failed headv1/v2 remain unaccepted;no blind retry. Full reconstruction unfinished. Next: {next_action} Sole main worker,heartbeat disabled,Viewer/frozen seams untouched,no production integration/ticket closure. Evidence `{e}/`.\n'''
Path('/tmp/collection-provenance-iron-grille-entry.md').write_text(entry);p=Path('modules/shell/PROVENANCE.md');assert not p.read_text().endswith(entry);p.write_text(p.read_text()+entry)
Path('/tmp/collection-v44-staged-provenance.md').write_bytes(subprocess.check_output(['git','show','HEAD:modules/shell/PROVENANCE.md'])+entry.encode())
s=p.read_bytes()
for name in ['iron-grille','ceilings','gabled','panels','loop','perugino','bertin','cases','european-door','wide-scale','ionic','grey','full-survey','sculpture-layout','gallery','wide','inventory']:
 q=Path('/tmp/collection-provenance-'+name+'-entry.md').read_bytes();assert s.endswith(q),name;s=s[:-len(q)]
d=read(Path('/tmp/collection-inventory-pending-before.json'))
for path,h in d.items():assert hashlib.sha256(s if path=='modules/shell/PROVENANCE.md' else Path(path).read_bytes()).hexdigest()==h,path
write(e/'preservation.json',{'original_pending_files':len(d),'all_original_hashes_match':True,'prepared_source_count':len(m['source_sha256']),'all_source_hashes_match':True,'provenance_method':'Strip only17 session-authored entries; original21 pending lines remain unstaged.'})
failures='\n'.join(x.rstrip() for x in re.findall('^FAIL .*',shell,re.M))
(e/'CHECKPOINT.md').write_text(f'''# Collection checkpoint — {now}

Prototype v44; sole main worker; heartbeat disabled. Goal active and unfinished. Viewer/frozen interfaces/tests untouched. No production integration or ticket closure.

1. Wide shots6382 88.75s and closer native12.25/12.375s reviewed. Native open grille added beside portal using7 source-observed columns and existing Muse iron material.17 rows/handedness/profiles/scale/plinth/braces/exact placement provisional.119 closed coil solids,not a verified historical reconstruction. Front/oblique/baked room wides inspected; initial thinner geometry trial retained. East-wall fragment,stair door,case contents and source fixture layout remain incomplete.
2.825 native baked surfaces,CPU Vulkan bake213.44s; engine cleanup warnings retained. Two authored ceilings/two baked copies correctly hide for elevated walking camera. RTX4070SUPER Chrome158/158,33 continuous circuit segments plus keyboard round trip,p95{b['engine']['frame_time_p95_ms']:.3f}ms,ready{b['first_ready_ms']}ms,errors[]. No new native performance claim;60fps unresolved. Owning Shell{passed}/50,{failed} failures retained with full film. scripts/check.sh/git diff --check pass; old source evidence.gd copies renamed.gd.txt byte-identically to avoid seam scanner treating them as modules.
3. RISD API searches with100 returned empty lists; verified known-ID/Monet positive controls and broad searches with25. Identity still unmatched; first-page searches not exhaustive. Source/API/output hashes retained. No new paid call; existing Muse source8-column geometry remains rejected,iron-post material alone reused. Cost$0.00 this pass,cumulative$0.75 actual/$0.76 conservative. All192 prepared source hashes and50 original pending hashes match; original21 PROVENANCE lines preserved unstaged.
4. Next: {next_action} Full source-fitted architecture/door/object positions,remaining rooms/sculptures/cases,stairs,auditorium/modern gallery still unfinished. No external blocker. Failed heads remain unaccepted; no blind paid retries.

Owning Shell failures:

{failures}

https://windows-wsl.taile06c45.ts.net/risd-frame-review-01a0ee18/progress/

Reproduce using saved preparation/native-bake/browser helpers; actual raw logs/full Shell film archived. Source native frames remain in ingestion with exact hashes and CUDA decode commands; repo JPEGs are review derivatives.
''')
shutil.copyfile(__file__,e/'finish-checkpoint.py')
for n in ['remodel_room.gd','remodel_review.gd']:shutil.copyfile(Path('modules/shell/prototype/collection_reconstruction')/n,e/(n+'.txt'))
write(e/'SHA256.json',{str(p.relative_to(e)):sha(p) for p in e.rglob('*') if p.is_file() and p.name!='SHA256.json'})
print('Evidence',e,'Shell',passed,'/50; pending preserved')
