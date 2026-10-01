"""Small native45degree visual check of the selected correction, isolated from root preview."""
from pathlib import Path
import tempfile,shutil,subprocess
HERE=Path(__file__).resolve().parent
SOURCE=HERE/'footplant-candidate.glb'
DEST=HERE/'quintic-visual';DEST.mkdir(exist_ok=True)
# Reuse existing inspection staging, with the source-supported camera and actual rest sole plane.
proof=(HERE.parents[1]/'godot-proof/normalized/proof.gd').read_text()
proof=proof.replace('camera.projection = Camera3D.PROJECTION_ORTHOGONAL','camera.projection = Camera3D.PROJECTION_PERSPECTIVE\n\tcamera.fov=20')
proof=proof.replace('bounds.position.y-0.015','bounds.position.y').replace('Vector3(-0.55,0.25,2.5)*common_height','Vector3(0,3.2,3.2)*common_height')
with tempfile.TemporaryDirectory(prefix='quintic-visual-') as scratch:
 p=Path(scratch)
 for name in ['idle','walk']:shutil.copy2(SOURCE,p/f'{name}.glb')
 (p/'proof.gd').write_text(proof)
 (p/'project.godot').write_text('[application]\nconfig/name="Throwaway quintic visual"\n[rendering]\nrenderer/rendering_method="gl_compatibility"\n')
 for phase,args in [('import',['--headless','--editor','--import','--quit']),('reimport',['--headless','--editor','--import','--quit']),('render',['--display-driver','x11','--rendering-method','gl_compatibility','--script','res://proof.gd'])]:
  if phase=='reimport':
   for name in ['idle','walk']:
    f=p/f'{name}.glb.import';f.write_text(f.read_text().replace('_subresources={}','_subresources={"nodes":{"PATH:AnimationPlayer":{"optimizer/enabled":false}}}'))
    for cached in (p/'.godot/imported').glob(f'{name}.glb-*'):cached.unlink()
  with (DEST/f'{phase}.log').open('w') as log:subprocess.run(['/home/reidsurmeier/bin/godot','--path',scratch,*args],stdout=log,stderr=subprocess.STDOUT,check=True,timeout=60)
 for f in p.glob('*.png'):shutil.copy2(f,DEST/f.name)
 shutil.copy2(p/'evidence.json',DEST/'evidence.json')
