from pathlib import Path
import os,subprocess
out=Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion/lowpoly-room-v45b-stair-wall');godot='/home/reidsurmeier/.local/opt/godot-4.7.2/Godot_v4.7.2-stable_linux.x86_64';env=dict(os.environ);env.pop('LIBGL_ALWAYS_SOFTWARE',None);env.update(GALLIUM_DRIVER='d3d12',MESA_D3D12_DEFAULT_ADAPTER_NAME='NVIDIA',LD_LIBRARY_PATH='/usr/lib/wsl/lib',DISPLAY=':0')
for kind,args in [('import',['--headless','--editor','--import','--quit']),('unbaked-visual',['--quit-after','600','--script','remodel_review.gd'])]:
 with open('/tmp/collection-v45b-'+kind+'.log','w') as log:r=subprocess.run([godot,'--path',str(out),'--rendering-method','gl_compatibility',*args],env=env,stdout=log,stderr=subprocess.STDOUT,timeout=180)
 s=Path('/tmp/collection-v45b-'+kind+'.log').read_text();assert r.returncode==0 and 'SCRIPT ERROR' not in s,(kind,s[-3000:]);print(kind,'complete',flush=True)
