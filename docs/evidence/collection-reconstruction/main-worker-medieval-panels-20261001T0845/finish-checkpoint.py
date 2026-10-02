from pathlib import Path
from datetime import datetime,timezone
import json,hashlib,shutil,subprocess,tarfile,re
app=Path('image-work/collection-room-remodel');e=Path('docs/evidence/collection-reconstruction/main-worker-medieval-panels-20261001T0845');out=Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion/lowpoly-room-v41d-panels')
b=json.loads((out/'evidence/browser-result.json').read_text());assert b['pass'] and b['errors']==[] and len(b['engine']['checks'])==154 and all(b['engine']['checks'].values());assert 'NVIDIA' in b['webgl_renderer']
loop=[x for x in b['engine']['samples'] if x['trial'].startswith('loop_')];assert len(loop)==33 and all(x['started_without_reset'] for x in loop[1:])
first_shell=Path('/tmp/collection-v41d-shell.log').read_text();first_passed=len(re.findall(r'^PASS ',first_shell,re.M));assert first_passed==44
shell=Path('/tmp/collection-v41d-shell-repeat.log').read_text();passed=len(re.findall(r'^PASS ',shell,re.M));failed=len(re.findall(r'^FAIL ',shell,re.M));assert passed+failed==50
assert 'checks passed' in Path('/tmp/collection-v41d-check.log').read_text()
assert 'BAKE_OK users=794' in Path('/tmp/collection-v41d-bake.log').read_text()
assert '[editor_plugins]' not in (out/'project.godot').read_text()
manifest=json.loads((out/'manifest.json').read_text())
for p,h in manifest['source_sha256'].items():assert hashlib.sha256(Path(p).read_bytes()).hexdigest()==h,p
coverage=json.loads((app/'reconstruction-coverage.json').read_text());coverage['current_preview']='https://windows-wsl.taile06c45.ts.net/risd-frame-review-01a0ee18/architecture-review-v41/'
coverage['medieval_panels']['next']='Fit corrected Muse Magdalene frame to source profiles as closed native geometry, keep authentic panel separate; then reciprocal wide placement checks. No additional generation before fitting.'
coverage['medieval_panels']['qa']={'browser_checks_passed':154,'browser_errors':b['errors'],'browser_frame_time_p95_ms':b['engine']['frame_time_p95_ms'],'baked_surfaces':794,'shell_passed':passed,'shell_total':50,'shell_first_passed':first_passed,'native_detail_views_inspected':True,'placement_accepted':False}
(app/'reconstruction-coverage.json').write_text(json.dumps(coverage,indent=2)+'\n')
for n in ['manifest.json','geometry.json']:shutil.copyfile(out/n,e/n)
for n in ['reconstruction-coverage.json','sculpture-room-inventory.json']:shutil.copyfile(app/n,e/n)
for n in ['medieval-panel-bartolo','medieval-panel-virgin','medieval-panel-peter','medieval-north-panel-wide','medieval-portal-wall-wide','hall-source-camera','hall-wide-arch','portal-front','loop-overview']:shutil.copyfile(out/'evidence'/(n+'.png'),e/(n+'.png'))
shutil.copyfile(out/'evidence/browser-result.json',e/'browser-result.json')
for n in ['collection-v41d-final-checks.py','collection-v41d-browser-with-server.py','collection-publish-v41.py']:shutil.copyfile('/tmp/'+n,e/n)
logs=list(e.glob('*.log'))+list(Path('/tmp').glob('collection-v41d-*.log'))
with tarfile.open(e/'raw-repeat-checks-and-shell-film.tar.gz','w:gz') as a:
 for i,p in enumerate(logs):a.add(p,arcname=('retained/' if p.parent==e else 'current/')+p.name)
 a.add('/tmp/collection-v41d-shell',arcname='owning-shell-playtest')
 a.add('/tmp/collection-v41d-shell-repeat',arcname='owning-shell-repeat-playtest')
 a.add(out/'evidence/browser-result.json',arcname='browser-result.json')
for p in logs:
 target=e/p.name;target.write_text('\n'.join(line.rstrip() for line in p.read_text().splitlines()).rstrip()+'\n')
entry_path=Path('/tmp/collection-provenance-panels-entry.md');old=entry_path.read_bytes()
addition=f'''\nThree verified medieval originals20.207/57.301/22.047 installed as thin exposed wood panels with integral gilt borders;57.301 source silhouette62 vertices. Grey supports, thicknesses except catalogue3.2cm and all positions remain provisional. Native6382 66.75/70.25/72.75/75.25/85.75/86.75 retained. Local planar54x38.7cm22.047 ruler places centre1.388/1.509m from west corner; held-out87.25 only relative Magdalene/Peter0.871m. Unknown intrinsics, manual picks and different mounting planes do not establish room metrics. Display projection and upper/lower vents added; 794 surfaces baked. Explicit Mobile scene priming fixes new painting texture3D reimport during bake. Dark initial render rejected; three missing neutral art spots added using existing Hall light recipe. Final bake646.39s CPU Vulkan fallback, RTX native detail/wide renders inspected; usual engine cleanup errors retained. Grey wall/support colour, source offsets and portal reverse still unaccepted.\n\nRTX Chrome154/154 plus keyboard round trip,p95{b['engine']['frame_time_p95_ms']:.3f}ms,errors[]. No new native performance claim. Owning Shell repeat{passed}/50,{failed} existing frozen failures; first44/50 had2 additional animation timing failures that did not recur; full film and exact raw logs archived, readable log copies trimmed at line ends. scripts/check.sh and git diff --check passed. All183 runtime source hashes and50 original pending hashes preserved. Evidence `{e}/`. Corrected frame candidate remains outside runtime. Next: fit gabled frame closed geometry and source-correct painting separately, then refine reciprocal wide placement/architecture. Full reconstruction and60fps target unfinished. Heartbeat remains disabled; Viewer/frozen seams untouched.\n'''.encode()
p=Path('modules/shell/PROVENANCE.md');assert p.read_bytes().endswith(old);new=old.split(b'\nThree verified medieval originals')[0]+addition;p.write_bytes(p.read_bytes()[:-len(old)]+new);entry_path.write_bytes(new)
head=subprocess.check_output(['git','show','HEAD:modules/shell/PROVENANCE.md']);Path('/tmp/collection-v41-staged-provenance.md').write_bytes(head+new)
s=p.read_bytes()
for n in ['panels','loop','perugino','bertin','cases','european-door','wide-scale','ionic','grey','full-survey','sculpture-layout','gallery','wide','inventory']:
 q=Path('/tmp/collection-provenance-'+n+'-entry.md').read_bytes();assert s.endswith(q),n;s=s[:-len(q)]
d=json.loads(Path('/tmp/collection-inventory-pending-before.json').read_text())
for path,h in d.items():assert hashlib.sha256(s if path=='modules/shell/PROVENANCE.md' else Path(path).read_bytes()).hexdigest()==h,path
(e/'preservation.json').write_text(json.dumps({'all_original_50_hashes_match':True,'runtime_source_hashes':len(manifest['source_sha256']),'all_runtime_source_hashes_match':True,'provenance_method':'Strip only14 session-authored entries; original21 pending lines remain unchanged'},indent=2)+'\n')
now=datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M UTC');failures='\n'.join(x.rstrip() for x in re.findall(r'^FAIL .*',shell,re.M))
(e/'CHECKPOINT.md').write_text(f'''# Collection checkpoint — {now}

Prototype v41. Sole main worker; heartbeat disabled. Goal active and unfinished. Collection only; Viewer and frozen seams untouched; no ticket closure or production integration.

1. Three verified originals now built: Bartolo Madonna20.207, Virgin of Annunciation57.301 and Taking of Peter22.047. Source-shaped wood panels retain authentic museum images and integral gilt borders. Added north projecting display and vents. Grey mount dimensions, mounting heights and positions remain unaccepted. Native wide/close sources retained. Planar panel ruler corrects Saint Peter centre to worldx2.00 from earlier1.70; two estimates1.388/1.509m from west corner; held-out87.25 checks relative spacing only. No point-cloud recreation or metric completion claim.
2. Two Muse frame passes via pinned saved pipeline/OpenRouter, $0.02 combined. First rejected for invented inner chevron/blue wear; targeted guide/style correction produces proper high opening and three crockets per slope. Corrected candidate UNINSTALLED and UNACCEPTED: needs source proportions, closed relief geometry and authentic painting separation. Both outputs/prompts/receipts/run archives retained. Unpaid wrong-count draft preserved, never submitted. Total$0.74 actual/$0.75 conservative; ambiguous river-deities and failed heads unchanged.
3.794 baked surfaces, final CPU Vulkan646.39s. Scene priming fixes texture import race; failed imports/parse and dark render retained. Added three neutral art spots after visual rejection. Final native close/corner/portal/Hall views inspected. Portal reverse, room metrics, support offsets, Hall palette/trim and source-faithful lighting still need refinement.
4. RTX Chrome154/154 plus real keyboard round trip,p95{b['engine']['frame_time_p95_ms']:.3f}ms,ready{b['first_ready_ms']}ms,errors[]. No new native performance assertion. Owning Shell repeat{passed}/50 with{failed} existing frozen failures below. First44/50 had two additional animation timing failures that did not recur; both films/logs retained. scripts/check.sh/git diff --check pass. All183 prepared source and50 original pending hashes verified. Exact raw logs and Shell full film archived; readable log copies have trailing whitespace removed.60fps target unmet/unverified.
5. Next: fit corrected Magdalene21.250 gabled frame to original inner/outer profiles as closed native low polygon geometry, add authentic panel separately, inspect native close/oblique/wide and reciprocal video placement before any more paid work. Then remaining room assets, exact door/wall placement, lighting, stairs, auditorium and modern gallery. All ten videos already surveyed; comprehensive geometry/object reconstruction still incomplete. No external blocker.

Shell failures:

{failures}

https://windows-wsl.taile06c45.ts.net/risd-frame-review-01a0ee18/progress/

Reproduce using saved final-checks/browser/bake scripts and prepare_remodel.py into a fresh isolated output. Bake/show/browser tasks run sequentially; preserve original provider output. No provider subjective acceptance or owner approval inferred from local inspection.
''')
shutil.copyfile(__file__,e/'finish-checkpoint.py')
hashes={str(p.relative_to(e)):hashlib.sha256(p.read_bytes()).hexdigest() for p in e.rglob('*') if p.is_file() and p.name!='SHA256.json'};(e/'SHA256.json').write_text(json.dumps(hashes,indent=2)+'\n')
print('Evidence:',len(hashes),'files; Shell',passed,'/50; original pending preserved')
