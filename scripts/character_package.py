"""Build the accepted #235 character alone, without importing the museum or trials."""
from pathlib import Path
import json,hashlib,shutil,subprocess,os,sys
ROOT=Path(__file__).resolve().parents[1]
PACKAGE=ROOT/'modules/shell/character'
OUTPUT=ROOT/'build/character-package'
PROJECT=OUTPUT/'project'
SITE=OUTPUT/'site'

def run(name,args,rendered=False):
    display=['--display-driver','x11','--rendering-method','gl_compatibility'] if rendered else ['--headless']
    with (OUTPUT/name).open('w') as log:
        subprocess.run(['godot',*display,'--path',str(PROJECT),*args],stdout=log,stderr=subprocess.STDOUT,env={**os.environ,'DISPLAY':os.environ.get('DISPLAY',':99')},check=True,timeout=240)
    text=(OUTPUT/name).read_text()
    assert 'SCRIPT ERROR' not in text and '\nERROR:' not in text,text[-3000:]

if __name__=='__main__' and '--serve' in sys.argv:
    from http.server import ThreadingHTTPServer,SimpleHTTPRequestHandler
    from functools import partial
    class Handler(SimpleHTTPRequestHandler):
        def end_headers(self):
            self.send_header('Cross-Origin-Opener-Policy','same-origin')
            self.send_header('Cross-Origin-Embedder-Policy','require-corp')
            super().end_headers()
    # Threaded Godot needs these headers; serve only the isolated accepted export.
    ThreadingHTTPServer(('127.0.0.1',9863),partial(Handler,directory=str(SITE))).serve_forever()

if __name__=='__main__':
    manifest=json.loads((PACKAGE/'provenance.json').read_text())
    for name,row in manifest['inputs'].items():
        assert hashlib.sha256((PACKAGE/name).read_bytes()).hexdigest()==row['sha256'],name
    PROJECT.mkdir(parents=True,exist_ok=True);SITE.mkdir(exist_ok=True)
    shutil.copytree(PACKAGE,PROJECT/'modules/shell/character',dirs_exist_ok=True,ignore=shutil.ignore_patterns('*.uid','*_target-albedo512.png'))
    (PROJECT/'project.godot').write_text('''config_version=5
[application]
config/name="Accepted character · original sound comparison"
run/main_scene="res://modules/shell/character/playtest.tscn"
boot_splash/show_image=false
[display]
window/size/viewport_width=960
window/size/viewport_height=720
window/stretch/mode="disabled"
[audio]
driver/output_latency.web=10
general/default_playback_type.web=0
[rendering]
renderer/rendering_method="gl_compatibility"
renderer/rendering_method.mobile="gl_compatibility"
textures/vram_compression/import_etc2_astc=true
''')
    (PROJECT/'export_presets.cfg').write_text('''[preset.0]
name="Web"
platform="Web"
runnable=true
export_filter="all_resources"
export_path=""
include_filter=""
exclude_filter="*_check.gd,record.gd,*.json,appearance-*,audio-*,*record*,*.md"
[preset.0.options]
variant/extensions_support=false
variant/thread_support=true
vram_texture_compression/for_desktop=true
vram_texture_compression/for_mobile=true
html/export_icon=false
html/canvas_resize_policy=2
html/focus_canvas_on_start=true
''')
    run('import.log',['--editor','--import','--quit'])
    for path in (PROJECT/'modules/shell/character').glob('*.glb.import'):
        previous=path.read_text()
        text=previous.replace('animation/fps=30','animation/fps=240').replace('_subresources={}','_subresources={"nodes":{"PATH:AnimationPlayer":{"optimizer/enabled":false}}}')
        assert 'animation/fps=240' in text and 'optimizer/enabled' in text
        path.write_text(text)
        # Import receipts are package inputs; preserve dense animation on clean clone.
        shutil.copy2(path,PACKAGE/path.name)
        if text!=previous:
            for cached in (PROJECT/'.godot/imported').glob(path.name.removesuffix('.import')+'-*'):cached.unlink()
    for path in (PROJECT/'modules/shell/character/audio').glob('*.wav.import'):
        previous=path.read_text()
        text=previous.replace('compress/mode=2','compress/mode=0')
        assert 'compress/mode=0' in text
        path.write_text(text);shutil.copy2(path,PACKAGE/'audio'/path.name)
        if text!=previous:
            for cached in (PROJECT/'.godot/imported').glob(path.name.removesuffix('.import')+'-*'):cached.unlink()
    run('precise-import.log',['--editor','--import','--quit'])
    for name in ['controller','driven','quality','contact']:
        run(name+'-check.log',['--fixed-fps','60','--script','res://modules/shell/character/'+name+'_check.gd'])
    if (PACKAGE/'audio_check.gd').exists():
        run('audio-check.log',['--max-fps','60','--quit-after','1200','--script','res://modules/shell/character/audio_check.gd'])
    run('appearance-check.log',['--fixed-fps','60','--script','res://modules/shell/character/appearance_check.gd'],True)
    subprocess.run(['python3',str(PACKAGE/'appearance_check.py'),str(PROJECT)],check=True)
    run('export.log',['--export-release','Web',str(SITE/'index.html')])
    assert all((SITE/('index'+ext)).exists() for ext in ['.html','.js','.wasm','.pck'])
    (OUTPUT/'verification.json').write_text(json.dumps({'issue':235,'inputs':manifest['inputs'],'pck_sha256':hashlib.sha256((SITE/'index.pck').read_bytes()).hexdigest(),'import_fps':240,'animation_optimizer':False,'package_code_sha256':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in PACKAGE.glob('*.gd')},'animation_import_sha256':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in PACKAGE.glob('*.glb.import')},'packager_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),'additional_cost_usd':0},indent=2)+'\n')
    print(SITE)
