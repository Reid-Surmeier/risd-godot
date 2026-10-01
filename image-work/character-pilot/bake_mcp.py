"""Actual MCP launches one saved native pilot stage and returns its PID."""
import asyncio,json,os,sys
from pathlib import Path
from datetime import timedelta,datetime,timezone
from mcp import ClientSession,StdioServerParameters
from mcp.client.stdio import stdio_client

HERE=Path(__file__).resolve().parent
normalizing='--normalize-idle' in sys.argv
stage=str(HERE/('normalize_idle.py' if normalizing else 'bake_stage.py'))
custom='--stage' in sys.argv
if custom:
 stage=str(Path(sys.argv[sys.argv.index('--stage')+1]).resolve())
 assert Path(stage).is_relative_to(HERE/'iterations') and Path(stage).is_file()
launch_path=Path(stage).with_suffix('.mcp-launch.json') if custom else HERE/('target-mcp-normalization-launch.json' if normalizing else 'target-mcp-launch.json')
completion=str(Path(stage).with_suffix('.json')) if custom else ('target-idle-normalization.json' if normalizing else 'target-bake-completion.json')
if '--completion' in sys.argv:
 completion=str(Path(sys.argv[sys.argv.index('--completion')+1]).resolve())
 assert custom and Path(completion).is_relative_to(HERE/'iterations')
stage_args=[]
if '--profile' in sys.argv:
 profile=Path(sys.argv[sys.argv.index('--profile')+1]).resolve()
 assert custom and profile.is_relative_to(HERE/'iterations') and profile.is_file()
 stage_args=['--','--profile',str(profile)]
 launch_path=Path(completion).parent/'mcp-launch.json'
native_log=Path(completion).parent/'mcp-native.log' if stage_args else Path(stage).with_suffix('.native.log') if custom else HERE/('normalize-native.log' if normalizing else 'bake-native.log')
native_log.parent.mkdir(parents=True,exist_ok=True)
code=f"""import subprocess, json
path={stage!r}
log={str(native_log)!r}
command=['/home/reidsurmeier/.local/opt/blender-4.3.2/blender','--background','--factory-startup','--threads','1','--python-exit-code','1','--python',path]+{stage_args!r}
process=subprocess.Popen(command,cwd={str(HERE.parents[1])!r},stdout=open(log,'w'),stderr=subprocess.STDOUT,start_new_session=True)
print('TARGET_BAKE_SCHEDULED='+json.dumps({{'native_pid':process.pid,'saved_stage':path,'log':log}}))
"""
async def main():
 params=StdioServerParameters(command='/home/reidsurmeier/.local/bin/uvx',args=['--from','mcp-for-blender==2.0.0','mcp-for-blender'],env={**os.environ,'BLENDER_HOST':'localhost','BLENDER_PORT':'9876','DISABLE_TELEMETRY':'true'})
 async with stdio_client(params) as (read,write):
  async with ClientSession(read,write,read_timeout_seconds=timedelta(seconds=30)) as session:
   init=await session.initialize()
   status=await session.call_tool('get_addon_status',{'user_prompt':'and then the rigging of the t pose and animations, and animation affects etc. also should be researched.'})
   status_text='\n'.join(c.text for c in status.content if hasattr(c,'text'))
   assert not status.isError and status_text.lstrip().startswith('{'),status_text
   addon,_=json.JSONDecoder().raw_decode(status_text.lstrip())
   assert addon['up_to_date'] and addon['protocol_version']==7
   result=await session.call_tool('execute_blender_code',{'code':code,'user_prompt':'$wayfinder $prototype and start charting this map along with doing $research tickets. and start some of the subissues.'})
   output='\n'.join(c.text for c in result.content if hasattr(c,'text'))
   assert not result.isError and 'TARGET_BAKE_SCHEDULED' in output,output
   proof={'timestamp':datetime.now(timezone.utc).isoformat(),'successfully_scheduled':True,'transport':'actual MCP stdio','server':init.serverInfo.name,'protocol':init.protocolVersion,'addon_protocol':addon['protocol_version'],'blender':addon['blender_version'],'saved_stage':Path(stage).name,'native_launch':json.loads(output.split('TARGET_BAKE_SCHEDULED=',1)[1].strip()),'telemetry_consent':addon.get('telemetry_consent'),'paid_calls':0,'completion_file':completion,'completion_not_inferred_from_scheduling':True}
   launch_path.write_text(json.dumps(proof,indent=2)+'\n')
   print(json.dumps(proof))
asyncio.run(main())
