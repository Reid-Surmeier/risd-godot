"""THROWAWAY native comparison. Config JSON selects existing models, clip, camera, contacts."""
from pathlib import Path
import hashlib,json,os,re,shutil,subprocess,sys,tempfile
HERE=Path(__file__).resolve().parent
config_path=Path(sys.argv[1]).resolve();config=json.loads(config_path.read_text())
dest=HERE/config_path.stem;dest.mkdir(exist_ok=True)
proof=(HERE/'preview.gd').read_text()
# Reuse the already-proven native skin calculation from the original pilot.
original=(HERE.parent/'godot-proof/proof.gd').read_text()
proof+='\nfunc skin_bounds('+original.split('func skin_bounds(',1)[1].split('\nfunc capture',1)[0]+'\n'
with tempfile.TemporaryDirectory(prefix='character231-continuous-') as scratch:
 project=Path(scratch)
 for i,entry in enumerate(config['models']):
  source=(HERE/entry['source']).resolve()
  entry['sha256']=hashlib.sha256(source.read_bytes()).hexdigest()
  shutil.copy2(source,project/f'model-{i}.glb')
 (project/'config.json').write_text(json.dumps(config))
 (project/'preview.gd').write_text(proof)
 (project/'project.godot').write_text('[application]\nconfig/name="Character231 iteration"\n[display]\nwindow/size/viewport_width=960\nwindow/size/viewport_height=640\n[rendering]\nrenderer/rendering_method="gl_compatibility"\n')
 for name,args in [('import.log',['--headless','--editor','--import','--quit']),('precise-import.log',['--headless','--editor','--import','--quit']),('preview.log',['--display-driver','x11','--rendering-method','gl_compatibility','--script','res://preview.gd'])]:
  if name=='precise-import.log':
   for i in range(len(config['models'])):
    metadata=project/f'model-{i}.glb.import'
    text=metadata.read_text()
    text,count=re.subn(r'^_subresources=.*?(?=^\w|\Z)','_subresources={"nodes":{"PATH:AnimationPlayer":{"optimizer/enabled":false}}}\n',text,flags=re.M|re.S)
    assert count==1,'AnimationPlayer import settings missing'
    metadata.write_text(text)
    for cached in (project/'.godot/imported').glob(f'model-{i}.glb-*'):cached.unlink()
  with (dest/name).open('w') as log:
   subprocess.run(['/home/reidsurmeier/bin/godot','--path',scratch,*args],env={**os.environ,'DISPLAY':':99'},stdout=log,stderr=subprocess.STDOUT,timeout=240,check=True)
 evidence=json.loads((project/'evidence.json').read_text())
 evidence['godot_animation_optimizer_enabled']=False
 assert evidence['fps']==30 and all(m['bones']==24 for m in evidence['models'])
 for name in ['comparison.png','effects.png','evidence.json']:
  shutil.copy2(project/name,dest/name)
 subprocess.run(['ffmpeg','-loglevel','error','-y','-framerate','30','-i',str(project/'frame-%03d.png'),'-c:v','libx264','-pix_fmt','yuv420p','-movflags','+faststart',str(dest/'loop.mp4')],check=True)
 # Keep one full cycle for independently replayable proof; movie contains every frame of all cycles.
 keep=range(124) if config.get('transition') else range(evidence['frames_per_cycle'])
 for i in keep:shutil.copy2(project/f'frame-{i:03d}.png',dest/f'frame-{i:03d}.png')
 (dest/'config.json').write_text(json.dumps(config,indent=2)+'\n')
 print(json.dumps(evidence))
 if config.get('transition'):assert evidence['transition']['floor_gate']=='PASS',evidence['models'][-1]
