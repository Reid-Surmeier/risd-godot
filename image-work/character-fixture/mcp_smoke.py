"""Unpaid actual stdio MCP smoke against the temporary fixture GUI."""
import asyncio, json, os
from datetime import timedelta, datetime, timezone
from pathlib import Path
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

HERE=Path(__file__).resolve().parent
PROMPT="$wayfinder $prototype and start charting this map along with doing $research tickets. and start some of the subissues."
CODE="""import bpy, json
rig=next(o for o in bpy.context.scene.objects if o.type=='ARMATURE')
assert len(rig.data.bones)==41 and len(bpy.data.actions)==76
rig.animation_data.action=bpy.data.actions['Walking_A_Rig']
for track in rig.animation_data.nla_tracks: track.mute=True
bpy.context.scene.frame_set(8)
print('FIXTURE_MCP_QUERY='+json.dumps({'blender':bpy.app.version_string,'background':bpy.app.background,'file':bpy.data.filepath,'bones':len(rig.data.bones),'clips':len(bpy.data.actions),'frame':bpy.context.scene.frame_current,'active_clip':rig.animation_data.action.name,'mesh_armature':bpy.data.objects['Original visitor skin'].find_armature().name}))
"""
def result_text(result):
 assert not result.isError
 return "\n".join(block.text for block in result.content if hasattr(block,'text'))
async def main():
 env={**os.environ,"BLENDER_HOST":"localhost","BLENDER_PORT":"9876","DISABLE_TELEMETRY":"true"}
 params=StdioServerParameters(command="/home/reidsurmeier/.local/bin/uvx",args=["--from","mcp-for-blender==2.0.0","mcp-for-blender"],env=env)
 async with stdio_client(params) as (read,write):
  async with ClientSession(read,write,read_timeout_seconds=timedelta(seconds=30)) as session:
   init=await session.initialize()
   listing=await session.list_tools()
   status_text=result_text(await session.call_tool("get_addon_status",{"user_prompt":PROMPT}))
   decoder=json.JSONDecoder();status,_=decoder.raw_decode(status_text.lstrip())
   assert status["up_to_date"] and status["protocol_version"]==7
   query=result_text(await session.call_tool("execute_blender_code",{"code":CODE,"user_prompt":PROMPT}))
   assert 'FIXTURE_MCP_QUERY=' in query, query
   payload,_=decoder.raw_decode(query.split('FIXTURE_MCP_QUERY=',1)[1])
   assert payload["blender"]=="4.3.2" and not payload["background"] and payload["bones"]==41 and payload["clips"]==76 and payload["frame"]==8
   proof={"timestamp":datetime.now(timezone.utc).isoformat(),"success":True,"transport":"actual MCP stdio client -> mcp-for-blender2.0.0 -> loopback socket -> Blender GUI","server_name":init.serverInfo.name,"mcp_protocol":init.protocolVersion,"tool_count":len(listing.tools),"addon_status":{k:status.get(k) for k in ["up_to_date","protocol_version","expected_protocol_version","addon_version","blender_version","telemetry_consent"]},"query":payload,"paid_calls":0,"global_config_changed":False,"codex_session_tools_loaded":False,"gui_display":":99","owned_gui_stopped_after_test":False}
   (HERE/"mcp-smoke.json").write_text(json.dumps(proof,indent=2)+"\n")
   print(json.dumps(proof,indent=2))
asyncio.run(main())
