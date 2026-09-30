"""Small receipt check for selected native models, reference movies and the spend ceiling."""
from pathlib import Path
import hashlib, json, subprocess

HERE=Path(__file__).resolve().parent
read=lambda path:json.loads(path.read_text())
digest=lambda path:hashlib.sha256(path.read_bytes()).hexdigest()
result={'additional_paid_calls':0,'additional_cost_usd':0,'exact_visual_match':False,'models':{}}
for name in ['authored-walk-v5','authored-fast-v5','authored-fast-v6']:
    folder=HERE/name;sha=digest(folder/'footplant-candidate.glb')
    correction=read(folder/'correction.json');contact=read(folder/'contact-manifest.json');launch=read(folder/'mcp-launch.json')
    assert sha==correction['output_sha256']==contact['candidate_sha256']
    assert correction['bones']==24 and correction['rest_signature_unchanged'] and correction['bake_fps']==240
    assert launch['transport']=='actual MCP stdio' and launch['successfully_scheduled']
    log=(folder/'mcp-native.log').read_text();assert sha in log and 'Blender quit' in log
    for clip in ['idle','walk']:
        probe=contact['contact_probe'][clip]
        assert probe['sample_count']==257 and probe['floor_penetration_max_m']<.001
        assert probe['endpoint_vertex_error_max_m']<.001
        assert read(folder/f'candidate-proof/{clip}.json')['source_sha256']==sha
    assert not contact['sampled_planar_contact_verified']
    result['models'][name]={'sha256':sha,'native_probe':contact['contact_probe']}
for view,cycles in [('game',4),('profile',2)]:
    folder=HERE.parent/f'video-match-{view}-fast-v6';config=read(folder/'config.json');evidence=read(folder/'evidence.json')
    assert config['models'][0]['sha256']==result['models']['authored-fast-v6']['sha256']
    assert evidence['animation_import_fps']==240 and not evidence['godot_animation_optimizer_enabled']
    assert evidence['effects']['native_method_track_tested'] and evidence['effects']['calls']==2*cycles
    assert evidence['effects']['idle_added_calls']==0
    for index,event in enumerate(evidence['models'][0]['contact_events']):
        assert abs(event['time']-index*7/30)<.00001 and len(event['world_origin'])==3
for view in ['front','profile']:
    folder=HERE/f'youtube-{view}-v6'
    stream=read(folder/'comparison.json');assert stream['frames']==24 and not stream['exact_fit']
    movie=json.loads(subprocess.check_output(['ffprobe','-v','error','-select_streams','v:0','-show_entries','stream=nb_frames,avg_frame_rate','-of','json',str(folder/'comparison.mp4')]))['streams'][0]
    assert int(movie['nb_frames'])==24 and movie['avg_frame_rate']=='30/1'
clips=read(HERE/'youtube/verified-short-clips.json')
for view in ['front','profile']:
    source=next((HERE/'youtube').glob(view+'-*.mp4'))
    assert digest(source)==clips[view]['sha256'] and clips[view]['probe']['streams'][0]['nb_frames']=='24'
pilot=HERE.parents[1];hashes=read(pilot/'hashes.json')
for name in ['front.png','mesh-output-model_glb.glb','rig-output-rigged_character_glb.glb','rig-output-animations-0-animation_glb.glb','rig-output-basic_animations-walking_glb.glb']:
    assert digest(pilot/name)==hashes[name]
spend=read(pilot/'spend.json');result['aggregate_liability_usd']=round(sum(e['liability_usd'] for e in spend['entries']),2)
assert result['aggregate_liability_usd']==1.54 and spend['ceiling_usd']==4
(HERE/'checked.json').write_text(json.dumps(result,indent=2)+'\n')
print('PASS: MCP completion, dense native floor/endpoints, effect timing, source movies and $1.54 liability')
