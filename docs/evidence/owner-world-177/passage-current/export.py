"""Private #177 fixture export; restore the two original config files even on failure."""
from pathlib import Path
import subprocess
project=Path('project.godot');preset=Path('export_presets.cfg')
oldproject=project.read_bytes();oldpreset=preset.read_bytes()
try:
 project.write_text(oldproject.decode().replace('res://modules/shell/boot_loader.tscn','res://docs/evidence/owner-world-177/passage-current/probe.tscn'))
 preset.write_text('''[preset.0]
name="Passage Evidence"
platform="Web"
runnable=true
export_filter="resources"
export_files=PackedStringArray("res://docs/evidence/owner-world-177/passage-current/probe.tscn", "res://docs/evidence/owner-world-177/passage-current/probe.gd", "res://modules/shell/prototype/gallery_walk4/baked/room.tscn")
include_filter="docs/evidence/owner-world-177/passage-current/*.gd"
exclude_filter=""
[preset.0.options]
variant/extensions_support=false
variant/thread_support=false
vram_texture_compression/for_desktop=true
vram_texture_compression/for_mobile=true
html/export_icon=false
html/custom_html_shell="res://web/loading_shell.html"
html/head_include="<meta name=\\"risd-standalone-preview\\" content=\\"true\\">"
html/canvas_resize_policy=2
html/focus_canvas_on_start=true
''')
 out=Path('/tmp/risd-passage-177-current/web');out.mkdir(parents=True,exist_ok=True)
 subprocess.run(['godot','--headless','--editor','--path','.','--quit'],check=True)
 subprocess.run(['godot','--headless','--path','.','--export-release','Passage Evidence',str(out/'index.html')],check=True)
 for suffix in ['pck','wasm']:subprocess.run(['gzip','-k','-f',str(out/f'index.{suffix}')],check=True)
finally:
 project.write_bytes(oldproject);preset.write_bytes(oldpreset)
 print('RESTORED project.godot/export_presets.cfg original bytes')
