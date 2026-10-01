from pathlib import Path
import tempfile,shutil,subprocess,json,hashlib,sys
HERE=Path(__file__).resolve().parent
SOURCE=Path(sys.argv[1]).resolve() if len(sys.argv)>1 else HERE.parents[1]/'target-baked-normalized-idle.glb'
DEST=HERE/'candidate-proof' if len(sys.argv)>1 else HERE
DEST.mkdir(exist_ok=True)
with tempfile.TemporaryDirectory(prefix='motion-diagnosis-') as scratch:
 p=Path(scratch)
 shutil.copy2(SOURCE,p/'target.glb');shutil.copy2(HERE/'probe.gd',p/'probe.gd')
 (p/'project.godot').write_text('[application]\nconfig/name="Throwaway motion diagnosis"\n[rendering]\nrenderer/rendering_method="gl_compatibility"\n')
 for name,args in [('import.log',['--editor','--import','--quit']),('probe.log',['--script','res://probe.gd'])]:
  with (DEST/name).open('w') as log:
   subprocess.run(['/home/reidsurmeier/bin/godot','--headless','--path',scratch,*args],stdout=log,stderr=subprocess.STDOUT,check=True,timeout=90)
 evidence=json.loads((p/'evidence.json').read_text());evidence['source_sha256']=hashlib.sha256(SOURCE.read_bytes()).hexdigest()
 (DEST/'evidence.json').write_text(json.dumps(evidence,indent=2)+'\n')
 print(json.dumps({k:evidence[k] for k in ('seconds','head_to_headfront_local_direction','source_sha256')}))
 print(json.dumps({k:v for k,v in evidence['seam'].items() if k not in ('bones','one_sided_velocities')}))
