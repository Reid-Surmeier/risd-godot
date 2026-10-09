from pathlib import Path
import json,hashlib,shutil,subprocess
from datetime import datetime,timezone
app=Path('image-work/collection-room-remodel');e=Path('docs/evidence/collection-reconstruction/main-worker-ionic-20261001T0400');out=Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion/lowpoly-room-v34')
a=json.loads((out/'evidence/walk-result.json').read_text());b=json.loads((out/'evidence/browser-result.json').read_text());assert all(a['checks'].values()) and b['pass'];assert 'NVIDIA' in a['renderer'] and 'NVIDIA' in b['webgl_renderer']
for p in (out/'evidence').glob('*'):
 if p.is_file() and p.suffix!='.import':shutil.copyfile(p,e/p.name)
for name in ['geometry.json','manifest.json']:shutil.copyfile(out/name,e/name)
for name in ['reconstruction-coverage.json','ionic-capital-review.json']:shutil.copyfile(app/name,e/name)
for kind in ['prepare','import','bake-prepare','bake','visual','native','export','check']:
 shutil.copyfile('/tmp/collection-v34-'+kind+'.log',e/(kind+'.log'))
shutil.copyfile('/tmp/collection-v34-browser-with-server.log',e/'browser.log')
for script in ['collection-publish-v34.py','collection-v34-browser-with-server.py','collection-bake-only.py']:
 shutil.copyfile('/tmp/'+script,e/script)
shutil.copyfile('/tmp/collection-v32-bake-prepare.log',e/'partial-v32-failure.log')
for name in ['ionic-capital-front','ionic-capital-oblique']:
 shutil.copyfile('/home/reidsurmeier/risd-godot-ingestion/collection-expansion/lowpoly-room-v33/evidence/'+name+'.png',e/(name+'-before-trim-fix.png'))
r=json.loads((app/'ionic-capital-receipt.json').read_text());assert float(r['cost'])==.01
m=json.loads((out/'manifest.json').read_text())['source_sha256'];assert len(m)==113
for p,h in m.items():assert hashlib.sha256(Path(p).read_bytes()).hexdigest()==h,p
assert hashlib.sha256((app/'trial/ionic-capital-original.webp').read_bytes()).hexdigest()==r['result'][0]['sha256']
g=json.loads((app/'trial/ionic-capital-geometry.json').read_text());assert g['source_sha256']==r['result'][0]['sha256'] and g['edge_pair_counts']==[2] and g['triangles']==1928
assert 'BAKE_OK users=545' in (e/'bake.log').read_text();assert 'native_lightmap_users' in (e/'native.log').read_text();assert 'checks passed' in (e/'check.log').read_text()
entry=f'''\n### Collection room v34 — source-guided Muse Ionic capitals (2026-10-01)\n\nIssues #178/#181/#182/#183; owner-directed low-polygon Collection prototype only. One Muse twin-scroll capital, OpenRouter meta/muse-image, {r['runId']}, one output $0.01. Original1760x1440 retained intact; SHA256 {r['result'][0]['sha256']}. Reference native6380:34.25s capital/context and saved Main Hall style. Reused existing closed silhouette assembly:1928 triangles, every mesh edge paired twice, provisional0.72x0.40x0.32m. Two capitals parented to existing columns; ordinary door trim removed from column openings after close-up showed it crossed the capitals. Entablature remains a plain beam; scroll relief, side/rear and exact scale remain unaccepted.\n\nNew spend$0.01; cumulative map$0.69 actual/$0.70 conservative,58 successful expansion outputs plus prior$0.11 baseline. Unresolved river-deities submission reserved separately; no retry. JSON numbers versus integer-array equality stopped v32 scratch construction; corrected the closure guard and added a bake-wrapper check for complete grey-gallery inventory before baking. Partial scratch output never published.\n\nEvidence: `{e}/`. Native RTX54/54, p95{a['frame_time_p95_ms']:.2f}ms; Chrome RTX54/54 plus actual keyboard round trip, p95{b['engine']['frame_time_p95_ms']:.2f}ms. LightmapGI545 users,44.81s CPU Vulkan bake, original GLES renderer config restored. Known editor cleanup errors retained; no runtime/JS browser errors.113 source hashes and native paid hash verified. Native source, front, oblique, wider room and browser renders inspected. Repository/diff checks pass; most recent owning Shell44/50 retains four layout/pixel failures and two timing failures; frozen Shell unchanged. Original50 pending files preserved.\n\nWide-view review found current grey and medieval Hall entrance centres offset4.60m laterally and17.05m along the prototype axis; this does not fit saved authored Hall26.3m long with aligned doors. Recorded in loop-spacing-check.json; no invented connector added. All room/object metric fits, most objects and full Hall/stair reconstruction remain unfinished. Viewer unchanged, heartbeat disabled. Preview `/risd-frame-review-01a0ee18/progress/`.\n'''
Path('/tmp/collection-provenance-ionic-entry.md').write_text(entry)
p=Path('modules/shell/PROVENANCE.md');assert not p.read_text().endswith(entry);p.write_text(p.read_text()+entry)
head=subprocess.check_output(['git','show','HEAD:modules/shell/PROVENANCE.md']);Path('/tmp/collection-v34-staged-provenance.md').write_bytes(head+entry.encode())
checkpoint=f'''# Collection reconstruction checkpoint — {datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M UTC')}

Collection prototype branch only; heartbeat disabled, sole main worker. Owner goal remains active and unfinished. No point-cloud reconstruction, production integration, ticket closure, frozen Shell or 3D Viewer changes.

1. Installed one newly generated Muse Ionic capital at each existing grey-gallery column. Reused closed silhouette mesh assembly:1928 triangles and paired edges,0.72x0.40x0.32m provisional. Native original/ordered references/prompt/receipt/run archive preserved. New paid cost$0.01, OpenRouter meta/muse-image, run-db146fcf707e6f70e45cd014; cumulative map$0.69 actual/$0.70 conservative.58 expansion outputs plus prior$0.11 baseline. Never retry unresolved river-deities or failed head meshes.
2. Runtime JSON float/integer Array equality stopped first v32 scratch build; fixed with individual integer closure check. Bake wrapper now rejects partial grey inventory and restores project.godot exactly in finally. Initial v33 close-up revealed ordinary door trim crossed the capitals; removed ordinary trim from column openings, rebuilt v34. Before/after images retained. Capital sides/rear and scroll relief remain inferred, beam/dentils unfinished; this is not architectural acceptance.
3. Native RTX54/54 collision/camera checks, p95{a['frame_time_p95_ms']:.2f}ms. Chrome RTX54/54 plus actual keyboard round trip, p95{b['engine']['frame_time_p95_ms']:.2f}ms, first ready{b['first_ready_ms']}ms, no browser runtime/JS errors. These exceed a60fps frame budget. LightmapGI545 users,44.81s CPU Vulkan bake; expected editor cleanup messages retained.113 source hashes and native Muse hash verified. scripts/check.sh and git diff --check pass. Most recent owning Shell44/50: four original layout/pixel failures and two timing failures; unchanged Shell. All50 original pending files byte-preserved.
4. Reinspected source Ionic native wide,6380 frames193–216 and6382 frames1–24/145–168, official floor5 schematic, plus native front/oblique/wide/walking and browser images. Existing grey entrance centre(10.15,1.8) and medieval portal(5.55,18.85) differ4.60m laterally and17.05m axially. Saved Main Hall length26.3m/width10m has centred aligned end doors, far reveal2.6m. Metric map currently cannot fit it. Source topology remains real; schematic is not metrically scaled. No fabricated corridor or Hall deformation. loop-spacing-check.json records the concrete contradiction.
5. Next: fit long European-gallery length and Renaissance/medieval portal/corner offsets against reciprocal wide shots and catalogue dimensions, then reuse full saved Main Hall geometry once the loop fits. Add source-guided Ionic dentil/beam, seven missing grey paintings/Rodin sculpture and remaining surveyed rooms. Exact object positions, palette, hidden geometry and full map unfinished. No external blocker; catalogue identities for coach/waterfall remain unresolved, several candidates visually rejected. Bookcase scale provisional due stepped nonplanar structure. All2485 available2fps survey frames across ten videos reviewed previously; not every native frame and not reconstruction complete. Preview kept through2026-10-02T18:51:46UTC.

https://windows-wsl.taile06c45.ts.net/risd-frame-review-01a0ee18/progress/

Reproduce using prepare_remodel.py NEW_OUTPUT, headless Godot import, saved collection-bake-only.py OUTPUT LABEL, RTX remodel_review.gd and -- --selfcheck --out=OUTPUT/evidence, headless Web export and saved browser wrapper. Keep native/browser GPU runs sequential. Full commands/scripts/logs/hashes retained here.
'''
(e/'CHECKPOINT.md').write_text(checkpoint)
s=p.read_bytes()
for n in ['ionic','grey','full-survey','sculpture-layout','gallery','wide','inventory']:
 q=Path('/tmp/collection-provenance-'+n+'-entry.md').read_bytes();assert s.endswith(q),n;s=s[:-len(q)]
d=json.loads(Path('/tmp/collection-inventory-pending-before.json').read_text())
for path,h in d.items():assert hashlib.sha256(s if path=='modules/shell/PROVENANCE.md' else Path(path).read_bytes()).hexdigest()==h,path
(e/'pending-preservation.json').write_text(json.dumps({'verified_original_pending_files':len(d),'all_sha256_match':True},indent=2)+'\n')
hashes={str(p.relative_to(e)):hashlib.sha256(p.read_bytes()).hexdigest() for p in e.rglob('*') if p.is_file() and p.suffix!='.import' and p.name!='SHA256.json'};(e/'SHA256.json').write_text(json.dumps(hashes,indent=2)+'\n');print('Verified checkpoint; preserved',len(d),'original pending files; evidence',len(hashes),'files')
