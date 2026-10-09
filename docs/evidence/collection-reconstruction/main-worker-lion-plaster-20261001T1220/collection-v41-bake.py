from pathlib import Path
import os,sys,subprocess,re,json
out=Path(sys.argv[1]);tag=sys.argv[2];godot='/home/reidsurmeier/.local/opt/godot-4.7.2/Godot_v4.7.2-stable_linux.x86_64'
def run(args,env,kind):
 p=Path(f'/tmp/collection-{tag}-{kind}.log')
 with p.open('w') as log:r=subprocess.run([godot,'--path',str(out),*args],env=env,stdout=log,stderr=subprocess.STDOUT)
 s=p.read_text();assert r.returncode==0 and 'SCRIPT ERROR' not in s,(kind,r.returncode);return s
rtx=dict(os.environ);rtx.pop('LIBGL_ALWAYS_SOFTWARE',None);rtx.update(GALLIUM_DRIVER='d3d12',MESA_D3D12_DEFAULT_ADAPTER_NAME='NVIDIA',LD_LIBRARY_PATH='/usr/lib/wsl/lib',DISPLAY=':0')
s=run(['--rendering-method','gl_compatibility','--script','remodel_bake.gd'],rtx,'bake-prepare');surfaces=int(re.search(r'BAKE_PREPARE surfaces=(\d+)',s)[1]); inventory=json.loads(re.search(r'REMODEL_READY (\{.*\})',s)[1]); assert inventory['main_hall_verified_paintings']==23 and inventory['connected_museum_loop'] and not inventory['museum_metric_accepted']; print('Prepared',surfaces,'Hall+room surfaces',flush=True)
run(['--headless','--editor','--import'],rtx,'bake-import')
# Prime the edited 3D scene under the bake renderer before enabling the plugin.
# New textures otherwise request VRAM reimports during LightmapGI atlas saving.
cpu=dict(os.environ,LIBGL_ALWAYS_SOFTWARE='1',GALLIUM_DRIVER='llvmpipe',VK_ICD_FILENAMES='/usr/share/vulkan/icd.d/lvp_icd.json',DISPLAY=':99')
run(['--editor','--rendering-method','mobile','--quit-after','120','res://modules/shell/prototype/gallery_walk4/baked/room.tscn'],cpu,'bake-prime')
run(['--headless','--editor','--import'],rtx,'bake-prime-import')
p=out/'project.godot';original=p.read_text();assert '[editor_plugins]' not in original
try:
 p.write_text(original+'\n[editor_plugins]\nenabled=PackedStringArray("res://bake/plugin.cfg")\n')
 cpu=dict(os.environ,LIBGL_ALWAYS_SOFTWARE='1',GALLIUM_DRIVER='llvmpipe',VK_ICD_FILENAMES='/usr/share/vulkan/icd.d/lvp_icd.json',DISPLAY=':99');s=run(['--editor','--rendering-method','mobile'],cpu,'bake');assert int(re.search(r'BAKE_OK users=(\d+)',s)[1])==surfaces
finally:p.write_text(original)
print('Baked',surfaces,'complete room surfaces; renderer config restored')
