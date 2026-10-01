from pathlib import Path
import subprocess,os
root=Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion/lowpoly-room-v47c-lion-plaster');godot='/home/reidsurmeier/.local/opt/godot-4.7.2/Godot_v4.7.2-stable_linux.x86_64'
rtx=dict(os.environ);rtx.pop('LIBGL_ALWAYS_SOFTWARE',None);rtx.update(GALLIUM_DRIVER='d3d12',MESA_D3D12_DEFAULT_ADAPTER_NAME='NVIDIA',LD_LIBRARY_PATH='/usr/lib/wsl/lib',DISPLAY=':0')
for kind,args in [('visual',['--quit-after','600','--script','remodel_review.gd']),('export',['--headless','--export-release','Web',str(root/'web/index.html')])]:
 with open('/tmp/collection-v47c-'+kind+'.log','w') as log:r=subprocess.run([godot,'--path',str(root),'--rendering-method','gl_compatibility',*args],env=rtx,stdout=log,stderr=subprocess.STDOUT,timeout=180)
 text=Path('/tmp/collection-v47c-'+kind+'.log').read_text();assert r.returncode==0 and 'SCRIPT ERROR' not in text,(kind,r.returncode);print(kind,'complete',flush=True)
r=subprocess.run(['python3','/tmp/collection-v47c-browser-with-server.py'],env=rtx);assert r.returncode==0
with open('/tmp/collection-v47c-shell-repeat.log','w') as log:r=subprocess.run(['scripts/playtest.sh','shell','/tmp/collection-v47c-shell-repeat'],env=rtx,stdout=log,stderr=subprocess.STDOUT)
print('Owning Shell exit',r.returncode,flush=True)
subprocess.run(['git','diff','--check'],check=True)
