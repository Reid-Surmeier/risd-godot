"""Temporary GUI bridge for unpaid fixture smoke; no preferences/config writes."""
import bpy, importlib.util, sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
bpy.ops.wm.open_mainfile(filepath=str(HERE/'fixture.blend'))
addon=Path('/home/reidsurmeier/.config/blender/4.3/scripts/addons/blender_mcp.py')
spec=importlib.util.spec_from_file_location('blender_mcp',addon)
module=importlib.util.module_from_spec(spec); sys.modules['blender_mcp']=module
spec.loader.exec_module(module); module.register()
for name in ('blendermcp_use_polyhaven','blendermcp_use_hyper3d','blendermcp_use_sketchfab','blendermcp_use_hunyuan3d'):
 if hasattr(bpy.context.scene,name): setattr(bpy.context.scene,name,False)
bpy.context.scene.blendermcp_port=9876
bpy.ops.blendermcp.start_server()
print('FIXTURE_MCP_BOOTSTRAP_READY',bpy.app.version_string,flush=True)

