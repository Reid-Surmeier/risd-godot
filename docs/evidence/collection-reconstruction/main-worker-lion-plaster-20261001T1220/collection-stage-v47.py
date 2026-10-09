from pathlib import Path
import subprocess,json,hashlib,shutil
app=Path('image-work/collection-room-remodel');e=Path('docs/evidence/collection-reconstruction/main-worker-lion-plaster-20261001T1220')
shutil.copyfile('/tmp/collection-v47-archived-check.log',e/'archived-tree-check.log')
(e/'SHA256.json').write_text(json.dumps({str(p.relative_to(e)):hashlib.sha256(p.read_bytes()).hexdigest() for p in e.rglob('*') if p.is_file() and p.name!='SHA256.json'},indent=2)+'\n')
paths=[str(app/n) for n in ['.qwen-pipeline/project-contract.json','.qwen-pipeline/muse-9470d730d66d149c277d.json','.qwen-pipeline/muse-b19f8a1990a70fc1ed22.json','hall-stairs-inventory.json','reconstruction-coverage.json']]
for name in ['lion-panel','landing-plaster']:
 paths += [str(app/(name+'-'+suffix)) for suffix in ['prompt.txt','plan.json','recipe.json','prepared.json','planned.json','receipt.json','review.json']]
 paths += [str(app/'trial'/(name+'-original.webp'))]
for n in ['lion-panel-official.png','landing-plaster-video-native.png','landing-plaster-style-main-hall.png']:paths.append(str(app/'inventory-references'/n))
for n in ['striding-lion','fauconnier-mountaineers']:
 paths += [str(app/'inventory-catalogue'/(n+suffix)) for suffix in ['.json','-zoom-0.jpg']]
paths += ['modules/shell/prototype/collection_reconstruction/'+n for n in ['prepare_remodel.py','remodel_room.gd','remodel_review.gd','remodel_bake.gd']]
paths += [str(p) for p in e.rglob('*') if p.is_file()]
assert len(paths)==len(set(paths)) and all(Path(p).is_file() for p in paths)
assert not subprocess.check_output(['git','diff','--cached','--name-only']).strip(),'Index contains other work'
original=json.loads(Path('/tmp/collection-inventory-pending-before.json').read_text());assert not set(paths)&set(original)
subprocess.run(['git','add','--',*paths],check=True)
h=subprocess.check_output(['git','hash-object','-w','/tmp/collection-v47-staged-provenance.md'],text=True).strip();subprocess.run(['git','update-index','--cacheinfo','100644,'+h+',modules/shell/PROVENANCE.md'],check=True)
actual=set(subprocess.check_output(['git','diff','--cached','--name-only','-z'],text=True).split('\0')[:-1]);assert actual<=set(paths)|{'modules/shell/PROVENANCE.md'}
assert not any('/sculpture_viewer/' in p or p.endswith(('/interface.gd','/errors.gd')) or '/playtest/' in p for p in actual)
Path('/tmp/collection-v47-own-stage-paths.json').write_text(json.dumps(sorted(actual),indent=2)+'\n')
subprocess.run(['git','diff','--cached','--check'],check=True);print('Scoped stage:',len(actual),'files')
