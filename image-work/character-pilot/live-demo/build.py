"""Build the isolated #231 playtest; no runtime project or paid provider is touched."""
from pathlib import Path
import hashlib,json,shutil,subprocess,os,sys

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
models={name:"fitted-"+name for name in ['walk','run','dash','skid','axe','net']}
sources={key:HERE.parent/'iterations/video-match'/name/'footplant-candidate.glb' for key,name in models.items()}
hand_atlas=HERE.parent/'iterations/video-match/hand-atlas-profile/hand-atlas.png'
digest=lambda path:hashlib.sha256(path.read_bytes()).hexdigest()
stamp=hashlib.sha256((''.join(digest(p) for p in sorted(HERE.glob('*.gd')))+digest(HERE/'build.py')+digest(HERE/'appearance_check.py')+digest(HERE/'tool_clearance_check.py')+digest(hand_atlas)+''.join(digest(p) for p in sources.values())).encode()).hexdigest()[:12]
out=ROOT/'build/character-playtest'/stamp
project=out/'project';site=out/'site'
project.mkdir(parents=True,exist_ok=True);site.mkdir(exist_ok=True)
shutil.copy2(HERE/'demo.gd',project/'demo.gd')
shutil.copy2(hand_atlas,project/'hand-atlas.png')
for name in ['locomotion.gd','controller_check.gd','driven_check.gd','record.gd','sound.gd','appearance_check.gd','quality_check.gd','tool_clearance_check.gd']:shutil.copy2(HERE/name,project/name)
for name,path in sources.items():shutil.copy2(path,project/(name+'.glb'))
(project/'main.tscn').write_text('[gd_scene load_steps=2 format=3]\n[ext_resource type="Script" path="res://demo.gd" id="1"]\n[node name="CharacterPlaytest" type="Node3D"]\nscript = ExtResource("1")\n')
(project/'project.godot').write_text('''config_version=5
[application]
config/name="Character playtest"
run/main_scene="res://main.tscn"
boot_splash/show_image=false
[display]
window/size/viewport_width=960
window/size/viewport_height=720
window/stretch/mode="disabled"
[rendering]
renderer/rendering_method="gl_compatibility"
renderer/rendering_method.mobile="gl_compatibility"
textures/default_filters/use_nearest_mipmap_filter=false
textures/vram_compression/import_etc2_astc=true
''')
(project/'export_presets.cfg').write_text('''[preset.0]
name="Web"
platform="Web"
runnable=true
export_filter="all_resources"
export_path=""
include_filter=""
exclude_filter="appearance-*,audio-*,*-check.json,record-*,jump-record*,effects-record*,hand-rest-*,*_check.gd,record.gd"
[preset.0.options]
variant/extensions_support=false
variant/thread_support=false
vram_texture_compression/for_desktop=true
vram_texture_compression/for_mobile=true
html/export_icon=false
html/canvas_resize_policy=2
html/focus_canvas_on_start=true
''')
godot='/home/reidsurmeier/bin/godot'
def run(name,args,rendered=False):
    display=['--display-driver','x11','--rendering-method','gl_compatibility'] if rendered else ['--headless']
    with (out/name).open('w') as log:subprocess.run([godot,*display,'--path',str(project),*args],env={**os.environ,'DISPLAY':os.environ.get('DISPLAY',':99')},stdout=log,stderr=subprocess.STDOUT,check=True,timeout=240)
    assert 'SCRIPT ERROR' not in (out/name).read_text(),(out/name).read_text()[-2000:]
run('import.log',['--editor','--import','--quit'])
for path in project.glob('*.glb.import'):
    text=path.read_text().replace('animation/fps=30','animation/fps=240').replace('_subresources={}','_subresources={"nodes":{"PATH:AnimationPlayer":{"optimizer/enabled":false}}}')
    assert 'animation/fps=240' in text and 'optimizer/enabled' in text
    path.write_text(text)
    for cached in (project/'.godot/imported').glob(path.name.removesuffix('.import')+'-*'):cached.unlink()
run('precise-import.log',['--editor','--import','--quit'])
run('controller-check.log',['--script','res://controller_check.gd'])
run('driven-check.log',['--fixed-fps','60','--script','res://driven_check.gd'])
run('quality-check.log',['--fixed-fps','60','--script','res://quality_check.gd'])
run('tool-clearance-check.log',['--fixed-fps','60','--script','res://tool_clearance_check.gd'])
with (out/'tool-clearance-geometry.log').open('w') as log:subprocess.run([sys.executable,str(HERE/'tool_clearance_check.py'),str(project)],stdout=log,stderr=subprocess.STDOUT,check=True)
shutil.rmtree(project/'tool-clearance')
run('appearance-check.log',['--fixed-fps','60','--script','res://appearance_check.gd'],rendered=True)
with (out/'appearance-pixel-check.log').open('w') as log:subprocess.run([sys.executable,str(HERE/'appearance_check.py'),str(project)],stdout=log,stderr=subprocess.STDOUT,check=True)
run('export.log',['--export-release','Web',str(site/'index.html')])
assert all((site/('index'+ext)).exists() for ext in ['.html','.js','.wasm','.pck'])
(out/'provenance.json').write_text(json.dumps({'issue':231,'models':{k:{'trial':models[k],'sha256':digest(p)} for k,p in sources.items()},'hand_atlas_sha256':digest(hand_atlas),'import_fps':240,'animation_optimizer':False,'additional_api_cost_usd':0,'stamp':stamp,'standalone_prototype':True},indent=2)+'\n')
print(site)
