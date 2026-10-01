"""Export a fresh full-app preview; fail on errors instead of publishing partial packs."""
import gzip, hashlib, json, os
from pathlib import Path
import shutil, subprocess, sys
project, output=map(lambda x:Path(x).resolve(), sys.argv[1:3])
label=sys.argv[3]
assert output.parent.exists() and not output.exists()
assert (project/'collection_rooms/main-build-adapter.json').exists()
output.mkdir()
env=dict(os.environ,DISPLAY=':99',LIBGL_ALWAYS_SOFTWARE='1',GALLIUM_DRIVER='llvmpipe')
env.pop('WAYLAND_DISPLAY',None)
for kind, args in [('boot',['--export-release','Web',str(output/(label+'.html'))]),('game',['--export-pack','Web Game',str(output/(label+'.game.pck'))])]:
 log=output/(kind+'-export.log')
 with log.open('w') as stream:
  result=subprocess.run(['godot','--headless','--path',str(project),*args],env=env,stdout=stream,stderr=subprocess.STDOUT,timeout=600)
 text=log.read_text()
 assert result.returncode==0 and not any(line.startswith(('ERROR:','SCRIPT ERROR:')) for line in text.splitlines()), (kind,result.returncode,str(log))
for suffix in ['wasm','pck','game.pck']:
 path=output/(label+'.'+suffix)
 assert path.stat().st_size>0
 with path.open('rb') as source, gzip.open(str(path)+'.gz','wb',compresslevel=9) as zipped:shutil.copyfileobj(source,zipped)
(output/'index.html').write_text('<!doctype html><meta charset="utf-8"><meta http-equiv="Cache-Control" content="no-store"><meta http-equiv="refresh" content="0; url='+label+'.html"><a href="'+label+'.html">Collection preview</a>')
# The same auxiliary resources used by the actual main-build exporter; no tenant edits.
shutil.copytree(project/'modules/video_player/media',output/'media')
shutil.copytree(project/'modules/flowers_page/web',output/'flowers')
ignored=output/'flowers/.gdignore'
if ignored.exists():ignored.unlink()
files={p.name:{'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()} for p in output.iterdir() if p.is_file() and p.suffix not in ['.log']}
(output/'export.json').write_text(json.dumps({'source_project':str(project),'label':label,'files':files},indent=2)+'\n')
print('FULLAPP_WEB_EXPORTED',label,flush=True)
